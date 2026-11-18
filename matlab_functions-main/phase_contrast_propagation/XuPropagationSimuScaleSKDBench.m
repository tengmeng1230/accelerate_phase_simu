function js_fpj_output = XuPropagationSimuScaleSKDBench(s_jsonc)

js_fpj = XuReadJsonc(s_jsonc);
PhotonNumber = js_fpj.PropagationPhotonNumber;    
js_fpj = rmfield(js_fpj, 'PropagationPhotonNumber');
mag_factor = js_fpj.SourceDetectorDistance/js_fpj.SourceIsocenterDistance;

name_tag = round(rand(1)*10)/10;%generate a temp config file with a name suffix with rand number
XuStructToJsonc(['config_fpj_' num2str(name_tag) '.jsonc'],js_fpj);
if isfield(js_fpj,'AddNoiseOnly') && js_fpj.AddNoiseOnly == true
    js_fpj_output.OutputFolder = [js_fpj.OutputDir '/phase_simu' ];
    %MgMkdir(js_fpj_output.OutputFolder,1);
else
    js_fpj_output = XuPropagationSimuScale(['config_fpj_' num2str(name_tag) '.jsonc']);
end


delete(['config_fpj_' num2str(name_tag) '.jsonc']);

if isfield(js_fpj,'OutputFileFormat')
    if ~(strcmp(js_fpj.OutputFileFormat,'raw') || strcmp(js_fpj.OutputFileFormat,'tif'))
        error('OutputFileFormat can only be raw or tif!');
    end
else
    js_fpj.OutputFileFormat = 'raw';
end

output_folder = js_fpj_output.OutputFolder;
frame_size = [js_fpj.DetectorElementCountHorizontal,js_fpj.DetectorElementCountVertical];
use_raw = strcmp(js_fpj.OutputFileFormat,'raw');
if use_raw
    input_paths = {fullfile(output_folder,'proj_pbi.raw'),fullfile(output_folder,'proj_no_pbi.raw')};
    [input_fids,input_cleanup] = XuOpenProjectionRawFiles(input_paths,'r'); %#ok<NASGU>
else
    pbi_tiff = Tiff(fullfile(output_folder,'proj_pbi.tif'),'r');
    pbi_cleanup = onCleanup(@() close(pbi_tiff)); %#ok<NASGU>
    no_pbi_tiff = Tiff(fullfile(output_folder,'proj_no_pbi.tif'),'r');
    no_pbi_cleanup = onCleanup(@() close(no_pbi_tiff)); %#ok<NASGU>
end

if isfield(js_fpj,'FocalSpotRatio')
    focal_spot_ratio = js_fpj.FocalSpotRatio;
else
    focal_spot_ratio = 1;
end
%add  source name option
if isfield(js_fpj,'SourceName')
    source_name = js_fpj.SourceName;
else
    source_name = 'kailong'; %by default source name is kailong
end

spec_simu = importdata(js_fpj.SpectrumFile);
en_simu = spec_simu(:,1); % keV
spec_simu = spec_simu(:,2);
spec_simu = spec_simu/sum(spec_simu);

en_mean = sum(en_simu.*spec_simu);

photons_to_quanta_conversion_factor = 1/0.5; % one photon equals to two quanta
dark_current_noise_level_in_quanta = 3.8;
MgMkdir([js_fpj_output.OutputFolder '/prelog']);
p = MgCmdLineProgressBar('Processing view idx: ');
focal_spot_cache = [];
smo_cache = [];
for view_idx = 1:js_fpj.Views
    p.print(view_idx,js_fpj.Views);
    if use_raw
        img_proj_pbi = XuReadProjectionRawView(input_fids(1),frame_size,view_idx);
        img_proj_no_pbi = XuReadProjectionRawView(input_fids(2),frame_size,view_idx);
    else
        if view_idx > 1
            nextDirectory(pbi_tiff);
            nextDirectory(no_pbi_tiff);
        end
        img_proj_pbi = read(pbi_tiff).';
        img_proj_no_pbi = read(no_pbi_tiff).';
    end
    img_prelog = exp(-img_proj_pbi);
    [img_prelog_conv_fs,focal_spot_cache] = XuConvFocalSpot(img_prelog,mag_factor,...
       js_fpj.DetectorElementWidth,focal_spot_ratio,source_name,focal_spot_cache);%add focal spot blur
    img_prelog_noisy = exp(-XuGenSgmNoisyGauss(real(-log(img_prelog_conv_fs)),PhotonNumber));%add noise
    %img_prelog_conv_dec = real(XuConvXineos(img_prelog_noisy));%add detector pixel cross talk
     img_prelog_conv_dec = real((img_prelog_noisy));

    img_prelog_quanta = PhotonNumber *photons_to_quanta_conversion_factor * img_prelog_conv_dec;%conver prelog data to quanta
    img_prelog_quanta_dark_noise = img_prelog_quanta + dark_current_noise_level_in_quanta*randn(size(img_prelog_quanta));%add dark current noise (assume white noise)
    img_proj_pbi_final = real(log(PhotonNumber *photons_to_quanta_conversion_factor./img_prelog_quanta_dark_noise));

    img_prelog = exp(-img_proj_no_pbi);
    img_prelog_conv_fs = XuConvFocalSpot(img_prelog,mag_factor,...
       js_fpj.DetectorElementWidth,focal_spot_ratio,source_name,focal_spot_cache);%add focal spot blur
    img_prelog_noisy = exp(-XuGenSgmNoisyGauss(real(-log(img_prelog_conv_fs)),PhotonNumber));%add noise
    img_prelog_conv_dec = real((img_prelog_noisy));
    img_prelog_quanta = PhotonNumber *photons_to_quanta_conversion_factor * img_prelog_conv_dec;%conver prelog data to quanta
    img_prelog_quanta_dark_noise = img_prelog_quanta + dark_current_noise_level_in_quanta*randn(size(img_prelog_quanta));%add dark current noise (assume white noise)
    img_proj_no_pbi_final = real(log(PhotonNumber *photons_to_quanta_conversion_factor./img_prelog_quanta_dark_noise));

    
    [img_proj_pbi_final_phase,smo_cache] = XuSMOPhaseV2(exp(-img_proj_pbi_final),en_mean,js_fpj.SourceDetectorDistance,js_fpj.SourceIsocenterDistance,js_fpj.DetectorElementWidth,1,smo_cache);
    img_proj_no_pbi_final_phase = XuSMOPhaseV2(exp(-img_proj_no_pbi_final),en_mean,js_fpj.SourceDetectorDistance,js_fpj.SourceIsocenterDistance,js_fpj.DetectorElementWidth,1,smo_cache);
    if use_raw
        if view_idx == 1
            output_paths = {fullfile(output_folder,'proj_pbi_fs_dec_blur.raw'), ...
                fullfile(output_folder,'proj_pbi_fs_dec_blur_phase.raw'), ...
                fullfile(output_folder,'proj_no_pbi_fs_dec_blur.raw'), ...
                fullfile(output_folder,'proj_no_pbi_fs_dec_blur_phase.raw')};
            [output_fids,output_cleanup] = XuOpenProjectionRawFiles(output_paths,'W'); %#ok<NASGU>
        end
        XuWriteProjectionRawViews(output_fids,img_proj_pbi_final,img_proj_pbi_final_phase, ...
            img_proj_no_pbi_final,img_proj_no_pbi_final_phase);
    elseif strcmp(js_fpj.OutputFileFormat,'tif')
        temp_data = img_proj_pbi_final;
        window = [min(temp_data(:)), max(temp_data(:))];
        if view_idx == 1
            MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur.tif'],img_proj_pbi_final');
            MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_phase_retrival.tif'],img_proj_pbi_final_phase');
            %MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_no_fs_dec_blur.tif'],img_postlog_noisy');
            MgWriteTiff([js_fpj_output.OutputFolder '/prelog/img_prelog_quanta_dark_noise.tif'],img_prelog_quanta_dark_noise');
        else
            MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur.tif'],img_proj_pbi_final',window,'single','a');
            MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_phase_retrival.tif'],img_proj_pbi_final_phase',window,'single','a');
            %MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_fs_no_dec_blur.tif'],img_postlog_noisy',window,'single','a');
            MgWriteTiff([js_fpj_output.OutputFolder '/prelog/img_prelog_quanta_dark_noise.tif'],img_prelog_quanta_dark_noise',window,'single','a');
        end
    end
end
end
