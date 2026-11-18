function status = XuPropagationSimu(s_jsonc)
%s_jsonc = 'config_fpj.jsonc';

%fpj
js_fpj = XuReadJsonc(s_jsonc);
MgMkdir(js_fpj.OutputDir,1);
XuFpjFromTaichi(s_jsonc,"v3");


%define the detector
dect_pixel_size = js_fpj.DetectorElementWidth;
dect_dimension_u = js_fpj.DetectorElementCountHorizontal;
dect_dimension_v = js_fpj.DetectorElementCountVertical;
dect_coverage = dect_dimension_u * dect_pixel_size;

%define geometry
source_isocenter_dis = js_fpj.SourceIsocenterDistance;
source_dect_dis = js_fpj.SourceDetectorDistance;
magnification = source_dect_dis/source_isocenter_dis;

%calculate propagation distances
z_1 = source_isocenter_dis; z_2 = source_dect_dis - source_isocenter_dis;
z_eff = z_1*z_2 / (z_2 + z_1);
%focal_spot_sigma = focal_spot_size * z_2 / z_1 /js_fpj.DetectorElementWidth/2;

%read sinogram

input_files = strrep(js_fpj.InputFiles,'.*','*');
output_files = strrep(input_files,js_fpj.OutputFileReplace{1},js_fpj.OutputFileReplace{2});
output_folder_new = [js_fpj.OutputDir '/phase_simu' ];
MgMkdir(output_folder_new,1);
D_output_files = dir([js_fpj.OutputDir '/' output_files]);

num_materials = length(D_output_files);

if strcmp(js_fpj.OutputFileForm,'post_log_images')
    L_4D = zeros([dect_dimension_u dect_dimension_v js_fpj.Views num_materials]);
    for idx = 1:num_materials
        L_4D(:,:,:,idx) = XuReadRaw([D_output_files(idx).folder '/' D_output_files(idx).name],[dect_dimension_u dect_dimension_v js_fpj.Views]);
    end
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

for idx = 1:num_materials
    mu_phase_half(:,idx)= 2*pi./lambda .* XuGetDelta(char(js_fpj.MaterialName(idx)),en_simu);
    mu_half(:,idx)= XuGetAtten(char(js_fpj.MaterialName(idx)),js_fpj.MaterialDensity(idx),en_simu)/10/2;
end


kappa = mu_phase_half(:,1)./ mu_half(:,1);% delta/beta

%plot(en_simu,kappa.*lambda);

%f = 1/lambda; k = f * 2 * pi;

discrete_Fresnel_number =  dect_pixel_size^2/magnification^2 / (z_eff * mean(lambda))

%dose_reduction = 1+mean(kappa)/discrete_Fresnel_number;

vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size/magnification;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size/magnification;
p = MgCmdLineProgressBar('Processing view idx: ');
for view_idx = 1:js_fpj.Views
    p.print(view_idx,js_fpj.Views);
    amplitude_z_0 = zeros(size(L_4D(:,:,view_idx,1)));
    amplitude_z = zeros(size(L_4D(:,:,view_idx,1)));
    for energy_idx = 1:length(en_simu)
        img_z_0 = ones(size(L_4D(:,:,view_idx,1)));
        for idx = 1:num_materials
            img_z_0 = img_z_0.* exp(-L_4D(:,:,view_idx,idx)*mu_half(energy_idx,idx)- 1i*L_4D(:,:,view_idx,idx)*mu_phase_half(energy_idx,idx));
        end
        amplitude_z_0 = amplitude_z_0 + spec_simu(energy_idx)* img_z_0.*conj(img_z_0);

        %obtain vec_fx and vec_fy
        if view_idx == 1 && energy_idx == 1
            [img_z_0_fft, vec_fx, vec_fy]= Xufft2Ver2(img_z_0, vec_x, vec_y, 1);
            [vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);
        end

        img_z= XuFresnelPropagation2D(img_z_0, vec_x, vec_y, z_eff, lambda(energy_idx));
        amplitude_z = amplitude_z + spec_simu(energy_idx)*img_z.*conj(img_z);

    end
    amplitude_z_0 = exp(-XuGenSgmNoisyGauss(-log(amplitude_z_0), js_fpj.PropagationPhotonNumber)); %add noise to amplitude image
    amplitude_z = exp(-XuGenSgmNoisyGauss(-log(amplitude_z), js_fpj.PropagationPhotonNumber)); %add noise to amplitude image

    smo_filter = zeros(size(vec_fx_m));
    for energy_idx = 1:length(en_simu)
        smo_filter = smo_filter + spec_simu(energy_idx)./(1+z_eff*lambda(energy_idx)* kappa(energy_idx)* pi * (vec_fx_m.^2 + vec_fy_m.^2));
    end
    phase_retrived = -log(Xufft2Ver2(Xufft2Ver2(amplitude_z,vec_x,vec_y,1).*smo_filter,vec_fx,vec_fy,0));


    if view_idx == 1
        XuWriteRaw([output_folder_new '/proj_pbi.raw'],-log(real(amplitude_z)));
        XuWriteRaw([output_folder_new '/proj_phase.raw'],real(phase_retrived));
        XuWriteRaw([output_folder_new '/proj_no_pbi.raw'],-log(real(amplitude_z_0)));
    else
        XuAddRaw([output_folder_new '/proj_pbi.raw'],-log(real(amplitude_z)));
        XuAddRaw([output_folder_new '/proj_phase.raw'],real(phase_retrived));
        XuAddRaw([output_folder_new '/proj_no_pbi.raw'],-log(real(amplitude_z_0)));
    end

end
fprintf(['Output files are saved to folder: ' output_folder_new, ' !\n'])
fprintf(['Dimension is %d x %d x %d. \n'],[dect_dimension_u dect_dimension_v js_fpj.Views]);
%fprintf('Finished!\n');
status = 1;
