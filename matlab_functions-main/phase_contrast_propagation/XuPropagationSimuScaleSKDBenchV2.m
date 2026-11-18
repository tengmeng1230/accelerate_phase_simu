function js_fpj_output = XuPropagationSimuScaleSKDBenchV2(s_jsonc)

js_fpj = XuReadJsonc(s_jsonc);
PhotonNumber_array = js_fpj.PropagationPhotonNumber;
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

if strcmp(js_fpj.OutputFileFormat,'raw')
    img_proj_pbi = XuReadRaw([js_fpj_output.OutputFolder, '/proj_pbi.raw'], ...
        [js_fpj.DetectorElementCountHorizontal,js_fpj.DetectorElementCountVertical,js_fpj.Views]);
    img_proj_no_pbi = XuReadRaw([js_fpj_output.OutputFolder, '/proj_no_pbi.raw'], ...
        [js_fpj.DetectorElementCountHorizontal,js_fpj.DetectorElementCountVertical,js_fpj.Views]);
elseif strcmp(js_fpj.OutputFileFormat,'tif')
    img_proj_pbi = MgReadTiff([js_fpj_output.OutputFolder, '/proj_pbi.tif']);
    img_proj_pbi = permute(img_proj_pbi,[2 1 3]);
    img_proj_no_pbi = MgReadTiff([js_fpj_output.OutputFolder, '/proj_no_pbi.tif']);
    img_proj_no_pbi = permute(img_proj_no_pbi,[2 1 3]);
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
for view_idx = 1:js_fpj.Views
    p.print(view_idx,js_fpj.Views);
    

    for photon_number_idx = 1:length(PhotonNumber_array)

        PhotonNumber = PhotonNumber_array(photon_number_idx);
        img_proj_pbi_final = XuGenSgmNoisyGauss(real(img_proj_pbi(:,:,view_idx)),PhotonNumber);%add noise
        img_proj_no_pbi_final =  XuGenSgmNoisyGauss(real(img_proj_no_pbi(:,:,view_idx)),PhotonNumber);%add noise
        img_proj_pbi_final_phase = XuSMOPhaseV2(exp(-img_proj_pbi_final),en_mean,js_fpj.SourceDetectorDistance,js_fpj.SourceIsocenterDistance,js_fpj.DetectorElementWidth,1);
        img_proj_no_pbi_final_phase = XuSMOPhaseV2(exp(-img_proj_no_pbi_final),en_mean,js_fpj.SourceDetectorDistance,js_fpj.SourceIsocenterDistance,js_fpj.DetectorElementWidth,1);
        if strcmp(js_fpj.OutputFileFormat,'raw')
            if view_idx == 1
                %XuWriteRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur.raw'],img_proj_pbi_final);
                XuWriteRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur_phase_' num2str(PhotonNumber) '.raw'],img_proj_pbi_final_phase);
                XuWriteRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur_' num2str(PhotonNumber) '.raw'],img_proj_pbi_final);
                XuWriteRaw([js_fpj_output.OutputFolder '/proj_no_pbi_fs_dec_blur_' num2str(PhotonNumber) '.raw'],img_proj_no_pbi_final);
                XuWriteRaw([js_fpj_output.OutputFolder '/proj_no_pbi_fs_dec_blur_phase_' num2str(PhotonNumber) '.raw'],img_proj_no_pbi_final_phase);

                XuWriteRaw([js_fpj_output.OutputFolder '/proj_no_pbi_fs_dec_blur_' num2str(PhotonNumber) '_raw_counts.raw'],PhotonNumber*exp(-img_proj_no_pbi_final));
                XuWriteRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur_' num2str(PhotonNumber) '_raw_counts.raw'],PhotonNumber*exp(-img_proj_pbi_final));

            else
                %XuAddRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur.raw'],img_proj_pbi_final);
                XuAddRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur_phase_' num2str(PhotonNumber) '.raw'],img_proj_pbi_final_phase);
                XuAddRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur_' num2str(PhotonNumber) '.raw'],img_proj_pbi_final);
                XuAddRaw([js_fpj_output.OutputFolder '/proj_no_pbi_fs_dec_blur_' num2str(PhotonNumber) '.raw'],img_proj_no_pbi_final);
                XuAddRaw([js_fpj_output.OutputFolder '/proj_no_pbi_fs_dec_blur_phase_' num2str(PhotonNumber) '.raw'],img_proj_no_pbi_final_phase);

                XuAddRaw([js_fpj_output.OutputFolder '/proj_no_pbi_fs_dec_blur_' num2str(PhotonNumber) '_raw_counts.raw'],PhotonNumber*exp(-img_proj_no_pbi_final));
                XuAddRaw([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur_' num2str(PhotonNumber) '_raw_counts.raw'],PhotonNumber*exp(-img_proj_pbi_final));
            end
        elseif strcmp(js_fpj.OutputFileFormat,'tif')
            temp_data = img_proj_pbi_final;
            window = [min(temp_data(:)), max(temp_data(:))];
            if view_idx == 1
                MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur.tif'],img_proj_pbi_final');
                %MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_no_fs_dec_blur.tif'],img_postlog_noisy');
                MgWriteTiff([js_fpj_output.OutputFolder '/prelog/img_prelog_quanta_dark_noise.tif'],img_prelog_quanta_dark_noise');
            else
                MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_fs_dec_blur.tif'],img_proj_pbi_final',window,'single','a');
                %MgWriteTiff([js_fpj_output.OutputFolder '/proj_pbi_fs_no_dec_blur.tif'],img_postlog_noisy',window,'single','a');
                MgWriteTiff([js_fpj_output.OutputFolder '/prelog/img_prelog_quanta_dark_noise.tif'],img_prelog_quanta_dark_noise',window,'single','a');
            end
        end
    end
end
