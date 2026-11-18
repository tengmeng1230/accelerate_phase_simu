function js_fpj_output = XuPropagationSimuScale(s_jsonc)
%s_jsonc = 'config_fpj.jsonc';




%fpj
js_fpj = XuReadJsonc(s_jsonc);
use_gpu = false;
if isfield(js_fpj,'PropagationUseGPU')
    validateattributes(js_fpj.PropagationUseGPU,{'logical','numeric'},{'scalar','binary'});
    use_gpu = logical(js_fpj.PropagationUseGPU);
    js_fpj = rmfield(js_fpj,'PropagationUseGPU');
end
MgMkdir(js_fpj.OutputDir,1);
%define the detector dimension after the upsampling process
js_fpj.DetectorElementWidth = js_fpj.DetectorElementWidth/js_fpj.Upsampling;
js_fpj.DetectorElementHeight = js_fpj.DetectorElementHeight/js_fpj.Upsampling;
js_fpj.DetectorElementCountHorizontal = js_fpj.DetectorElementCountHorizontal*js_fpj.Upsampling;
js_fpj.DetectorElementCountVertical = js_fpj.DetectorElementCountVertical*js_fpj.Upsampling;
% Stream high-resolution projections unless explicitly disabled.
if ~isfield(js_fpj,'StreamingOutput')
    js_fpj.StreamingOutput = true;
end
XuStructToJsonc('config_fpj_temp.jsonc',js_fpj);
XuFpjFromTaichi('config_fpj_temp.jsonc',"v3");
delete 'config_fpj_temp.jsonc'

%define variable names related to the detector
dect_pixel_size = js_fpj.DetectorElementWidth;
dect_dimension_u = js_fpj.DetectorElementCountHorizontal;
dect_dimension_v = js_fpj.DetectorElementCountVertical;
frame_size = [dect_dimension_u dect_dimension_v];

%define geometry
source_isocenter_dis = js_fpj.SourceIsocenterDistance;
source_dect_dis = js_fpj.SourceDetectorDistance;
magnification = source_dect_dis/source_isocenter_dis;

%calculate propagation distances
z_1 = source_isocenter_dis; z_2 = source_dect_dis - source_isocenter_dis;
z_eff = z_1*z_2 / (z_2 + z_1);

if isfield(js_fpj,'FocalSpotSize')
    focal_spot_size = js_fpj.FocalSpotSize;
    focal_spot_size_in_pixels = round(focal_spot_size * z_2 / z_1 /js_fpj.DetectorElementWidth);
    if focal_spot_size_in_pixels>1
        focal_spot_kernel = ones(focal_spot_size_in_pixels)/focal_spot_size_in_pixels^2;
        if use_gpu
            focal_spot_kernel = gpuArray(focal_spot_kernel);
        end
    end
else
    focal_spot_size = 0.0001;
end

%read sinogram

input_files = strrep(js_fpj.InputFiles,'.*','*');
output_files = strrep(input_files,js_fpj.OutputFileReplace{1},js_fpj.OutputFileReplace{2});
output_folder_new = [js_fpj.OutputDir '/phase_simu' ];
MgMkdir(output_folder_new,1);
D_output_files = dir([js_fpj.OutputDir '/' output_files]);

num_materials = length(D_output_files);

if ~strcmp(js_fpj.OutputFileForm,'post_log_images')
    error('Phase propagation requires OutputFileForm to be post_log_images.');
end

%define properties related to x-ray
spec_simu = importdata(js_fpj.SpectrumFile);
en_simu = spec_simu(:,1); % keV
spec_simu = spec_simu(:,2);
spec_simu = spec_simu/sum(spec_simu);
lambda = 1.24 ./ en_simu *1e-6; % in mm

%define materials
if length(js_fpj.MaterialName) ~=num_materials
    error('Number of materials is not consistent!');
end
mu_phase_half = zeros(length(en_simu),num_materials);
mu_half = zeros(length(en_simu),num_materials);
material_paths = cell(1,num_materials);

for idx = 1:num_materials
    material_paths{idx} = fullfile(D_output_files(idx).folder,D_output_files(idx).name);
    mu_phase_half(:,idx)= 2*pi./lambda .* XuGetDelta(char(js_fpj.MaterialName(idx)),en_simu,js_fpj.MaterialDensity(idx));
    mu_half(:,idx)= XuGetAtten(char(js_fpj.MaterialName(idx)),js_fpj.MaterialDensity(idx),en_simu)/10/2;
end
[material_fids,material_cleanup] = XuOpenProjectionRawFiles(material_paths,'r'); %#ok<NASGU>

if isfield(js_fpj,'KappaIdx')
    kappa = mu_phase_half(:,js_fpj.KappaIdx)./ mu_half(:,js_fpj.KappaIdx);% delta/beta
else
    js_fpj.KappaIdx = 1;
    kappa = mu_phase_half(:,1)./ mu_half(:,1);% delta/beta
end
fprintf(['Using Kappa value of ' char(js_fpj.MaterialName(js_fpj.KappaIdx)) ' for initial phase retrival! \n'])

%define detector type 
if isfield(js_fpj,'DetectorType')
    if js_fpj.DetectorType ~= 1 && js_fpj.DetectorType ~= 2
        error('Detector type can only be 1 (PCD) or 2 (EID)!')
    end
else
    js_fpj.DetectorType = 1;
end

%f = 1/lambda; k = f * 2 * pi;

discrete_Fresnel_number =  ((dect_pixel_size*js_fpj.Upsampling*z_1/(z_1+z_2))^2 + (focal_spot_size*z_2/(z_1+z_2))^2) / (z_eff * mean(lambda))

%dose_reduction = 1+mean(kappa)/discrete_Fresnel_number;

%vector of x and y after upsampling
vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size/magnification;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size/magnification;

%vector of x and y before upsampling
vec_x_rescale = ((1:(dect_dimension_u/js_fpj.Upsampling)) - (1+(dect_dimension_u/js_fpj.Upsampling))/2) * dect_pixel_size*js_fpj.Upsampling/magnification;
vec_y_rescale = ((1:(dect_dimension_v/js_fpj.Upsampling)) - (1+(dect_dimension_v/js_fpj.Upsampling))/2) * dect_pixel_size*js_fpj.Upsampling/magnification;

if ~isfield(js_fpj,'OutputFileFormat')
    js_fpj.OutputFileFormat = 'raw';
end

propagation_fft = Xufft2Ver2Plan(frame_size,vec_x,vec_y,1);
propagation_ifft = Xufft2Ver2Plan(frame_size,propagation_fft.vec_kx,propagation_fft.vec_ky,0);
if use_gpu
    propagation_fft.input_modulation = gpuArray(propagation_fft.input_modulation);
    propagation_fft.output_modulation = gpuArray(propagation_fft.output_modulation);
    propagation_ifft.input_modulation = gpuArray(propagation_ifft.input_modulation);
    propagation_ifft.output_modulation = gpuArray(propagation_ifft.output_modulation);
end

% Limit the energy-dependent cache to 128 MiB or one kernel for larger frames.
cached_energies = min(numel(lambda),max(1,floor(128*1024^2/(16*prod(frame_size)))));
propagation_kernels = cell(1,cached_energies);
for energy_idx = 1:cached_energies
    propagation_kernels{energy_idx} = buildKernel(propagation_fft,z_eff,lambda(energy_idx),use_gpu);
end

rescale_size = [numel(vec_x_rescale) numel(vec_y_rescale)];
rescale_fft = Xufft2Ver2Plan(rescale_size,vec_x_rescale,vec_y_rescale,1);
rescale_ifft = Xufft2Ver2Plan(rescale_size,rescale_fft.vec_kx,rescale_fft.vec_ky,0);
[vec_fy_rescale_m, vec_fx_rescale_m] = meshgrid(rescale_fft.vec_ky,rescale_fft.vec_kx);
frequency_squared = vec_fx_rescale_m.^2 + vec_fy_rescale_m.^2;
clear vec_fx_rescale_m vec_fy_rescale_m

p = MgCmdLineProgressBar('Processing view idx: ');
for view_idx = 1:js_fpj.Views
    p.print(view_idx,js_fpj.Views);
    thickness = cell(1,num_materials);
    for idx = 1:num_materials
        thickness{idx} = XuReadProjectionRawView(material_fids(idx),frame_size,view_idx);
        if use_gpu
            thickness{idx} = gpuArray(thickness{idx});
        end
    end
    amplitude_z_0 = zeros(frame_size,'like',thickness{1});
    amplitude_z = zeros(frame_size,'like',thickness{1});
    for energy_idx = 1:length(en_simu)
        img_z_0 = ones(frame_size,'like',thickness{1});
        for idx = 1:num_materials
            img_z_0 = img_z_0.* exp(-thickness{idx}*mu_half(energy_idx,idx)- 1i*thickness{idx}*mu_phase_half(energy_idx,idx));
        end

        if energy_idx <= cached_energies
            kernel = propagation_kernels{energy_idx};
        else
            kernel = buildKernel(propagation_fft,z_eff,lambda(energy_idx),use_gpu);
        end
        img_z = Xufft2Ver2(Xufft2Ver2(img_z_0,propagation_fft).*kernel,propagation_ifft);

        if js_fpj.DetectorType == 1
            amplitude_z = amplitude_z + spec_simu(energy_idx)*img_z.*conj(img_z);
            amplitude_z_0 = amplitude_z_0 + spec_simu(energy_idx)* img_z_0.*conj(img_z_0);
        elseif js_fpj.DetectorType == 2
            amplitude_z = amplitude_z + spec_simu(energy_idx)*en_simu(energy_idx)*img_z.*conj(img_z);
            amplitude_z_0 = amplitude_z_0 + spec_simu(energy_idx)*en_simu(energy_idx)* img_z_0.*conj(img_z_0);
        end

    end
    clear thickness img_z_0 img_z kernel
    
    %normalization
    if js_fpj.DetectorType == 1
        amplitude_z = amplitude_z./ sum(spec_simu);
        amplitude_z_0 = amplitude_z_0./ sum(spec_simu);
    elseif js_fpj.DetectorType == 2
        amplitude_z = amplitude_z./ sum(spec_simu.*en_simu);
        amplitude_z_0 = amplitude_z_0./ sum(spec_simu.*en_simu);
    end

    if use_gpu
        % Intensities are real; drop any roundoff in the imaginary component.
        amplitude_z = real(amplitude_z);
        amplitude_z_0 = real(amplitude_z_0);
    end
    if isfield(js_fpj,'FocalSpotSize') && focal_spot_size_in_pixels>1
        amplitude_z = 1+ conv2(amplitude_z-1,focal_spot_kernel,'same');%focal spot blur
    end
    %re-scale back
    amplitude_z = imresize(amplitude_z,1/js_fpj.Upsampling,'box');
    amplitude_z_0 = imresize(amplitude_z_0,1/js_fpj.Upsampling,'box');
    if use_gpu
        amplitude_z = gather(amplitude_z);
        amplitude_z_0 = gather(amplitude_z_0);
    end
    if isfield(js_fpj,'PropagationPhotonNumber')
        amplitude_z_0 = exp(-XuGenSgmNoisyGauss(-log(amplitude_z_0), js_fpj.PropagationPhotonNumber)); %add noise to amplitude image
        amplitude_z = exp(-XuGenSgmNoisyGauss(-log(amplitude_z), js_fpj.PropagationPhotonNumber)); %add noise to amplitude image
    end
    if view_idx==1
        smo_filter = zeros(rescale_size);
        for energy_idx = 1:length(en_simu)
            if js_fpj.DetectorType == 1
                smo_filter = smo_filter + ...
                    spec_simu(energy_idx)./(1+z_eff*lambda(energy_idx)* kappa(energy_idx)* pi * frequency_squared);
            elseif js_fpj.DetectorType == 2
                smo_filter = smo_filter + ...
                    spec_simu(energy_idx)*en_simu(energy_idx)./(1+z_eff*lambda(energy_idx)* kappa(energy_idx)* pi * frequency_squared);
            end
        end
        if js_fpj.DetectorType == 1
            smo_filter = smo_filter/sum(spec_simu);
        elseif js_fpj.DetectorType == 2
            smo_filter = smo_filter/sum(spec_simu.*en_simu);
        end
        clear frequency_squared
    end
    
    phase_retrived = -log(1+Xufft2Ver2(Xufft2Ver2(amplitude_z-1,rescale_fft).*smo_filter,rescale_ifft));

    if strcmp(js_fpj.OutputFileFormat,'raw')
        if view_idx == 1
            output_paths = {fullfile(output_folder_new,'proj_pbi.raw'), ...
                fullfile(output_folder_new,'proj_phase.raw'),fullfile(output_folder_new,'proj_no_pbi.raw')};
            [output_fids,output_cleanup] = XuOpenProjectionRawFiles(output_paths,'W'); %#ok<NASGU>
            XuWriteProjectionRawViews(output_fids,-real(log(amplitude_z)),real(phase_retrived),-real(log(amplitude_z_0)));
        else
            XuWriteProjectionRawViews(output_fids,-log(real(amplitude_z)),real(phase_retrived),-log(real(amplitude_z_0)));
        end
    elseif strcmp(js_fpj.OutputFileFormat,'tif')
        temp_data = -log(real(amplitude_z));
        window = [min(temp_data(:)), max(temp_data(:))];
        if view_idx == 1
            MgWriteTiff([output_folder_new '/proj_pbi.tif'],-real(log(amplitude_z))');
            MgWriteTiff([output_folder_new '/proj_phase.tif'],real(phase_retrived)');
            MgWriteTiff([output_folder_new '/proj_no_pbi.tif'],-real(log(amplitude_z_0))');
        else
            MgWriteTiff([output_folder_new '/proj_pbi.tif'],-log(real(amplitude_z))',window,'single','a');
            MgWriteTiff([output_folder_new '/proj_phase.tif'],real(phase_retrived)',window,'single','a');
            MgWriteTiff([output_folder_new '/proj_no_pbi.tif'],-log(real(amplitude_z_0))',window,'single','a');
        end
    end

end
fprintf(['Output files are saved to folder: ' output_folder_new, ' !\n'])
fprintf(['Dimension is %d x %d x %d. \n'],[dect_dimension_u/js_fpj.Upsampling dect_dimension_v/js_fpj.Upsampling js_fpj.Views]);
%fprintf('Finished!\n');
js_fpj_output.OutputFolder = output_folder_new;
end

function kernel = buildKernel(fft_plan,z_eff,lambda,use_gpu)
kernel = XuPropagationKernel(fft_plan.vec_kx,fft_plan.vec_ky,z_eff,lambda);
if use_gpu
    kernel = gpuArray(kernel);
end
end
