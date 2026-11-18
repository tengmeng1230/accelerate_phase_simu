
function output = XuGenPolyChromaticSgmFromJsonc(s_jsonc)


js = XuReadJsonc(s_jsonc);

mkdir(js.OutputDir);

%% perform forward projection
js_fpj = js;
js_fpj.OutputDir = [js.OutputDir '/temp'];
%fpj output of the basis materials are saved in a temp folder
mkdir(js_fpj.OutputDir);
mkdir('temp');
XuStructToJsonc('temp/config_mgfpj.jsonc',js_fpj);
if ~isfield(js,'AlreadyHaveBasisSgm') || (isfield(js,'AlreadyHaveBasisSgm') && ~js.AlreadyHaveBasisSgm)
    s_in = sprintf('mgfpj.exe %s','temp/config_mgfpj.jsonc');
    system(s_in);
end
%% find the name of the output sgms and read
if ~isfield(js,'DetectorZElementCount')
    js.DetectorZElementCount = js.SliceCount;
    %if there is no "DetectorZElementCount" in jsonc file, 
    %set "DetectorZElementCount" to "SliceCount". 
end

sgm = zeros(js.DetectorElementCount,js.Views,...
    js.DetectorZElementCount,length(js.ImgFileName));

for material_idx = 1:length(js.ImgFileName)
    for outputreplace_idx = 1:round(length(js.OutputFileReplace)/2)
        js.SgmFileName{material_idx} = strrep(char(js.ImgFileName{material_idx}),...
            char(js.OutputFileReplace{2*outputreplace_idx-1}),...
            char(js.OutputFileReplace{2*outputreplace_idx}));
        %generate the name of the sgm file
        %e.g., from "img_water" to "sgm_water"

        sgm(:,:,:,material_idx) = XuReadRaw([js_fpj.OutputDir '/' char(js.SgmFileName{material_idx}) '.raw'],...
            [js.DetectorElementCount,js.Views,js.DetectorZElementCount]);
    end
end
%%
output = zeros([size(sgm(:,:,:,1)),length(js.SpectrumFile)]);

for spec_idx = 1:length(js.SpectrumFile)
    %% initialize mu value for different materials
    if  iscell(js.SpectrumFile)==0
        spec = importdata(js.SpectrumFile);
        %if there is only one spectrum file
    else
        spec = importdata(char(js.SpectrumFile{spec_idx}));
        %if there is only one spectrum file if there are several spectra to
        %simuilate
    end
    en_simu = spec(:,1);
    spec = spec(:,2);
    spec = spec/sum(spec);
    
    mu = zeros(length(en_simu),length(js.ImgFileName));  
    for material_idx = 1:length(js.ImgFileName)
        mu(:,material_idx) = XuGetAtten(char(js.ImgMaterial(material_idx)),...
            js.Density(material_idx),en_simu)/10; %unit is mm^-1
    end
    %% (Optional) Use bowtie filter to alter the input photon fluence
    if isfield(js,'Bowtie') && js.Bowtie
        bt_material_name = js.BowtieMaterial;
        bt_materialdensity = js.BowtieMaterialDensity;
        bt_material_thickness = js.BowtieMaterialThickness;% in mm
        if length(bt_material_thickness)~=js.DetectorElementCount
            error('Num of elements in BowtieMaterialThickness must be equal to DetectorElementCount!');
        end
        mu_bt = XuGetAtten(bt_material_name,bt_materialdensity,en_simu)/10;
        %en_simu is from the spectrum
    else
        bt_material_thickness = zeros(js.DetectorElementCount,1,1);
        mu_bt = zeros(length(spec),1);
    end
    
    
    %% Generate prelog polychromatic sinogram
    atten = zeros(size(sgm(:,:,:,1)));
    atten_bt = zeros(size(sgm(:,:,:,1)));
    pb = MgCmdLineProgressBar('Processing energy idx ...');
    for en_idx = 1:length(en_simu)
        pb.print(en_idx,length(en_simu));
        sgm_sum = zeros(size(sgm(:,:,:,1)));
        for material_idx = 1:length(js.ImgFileName)
            sgm_sum = sgm_sum + sgm(:,:,:,material_idx)*mu(en_idx,material_idx);
        end
        sgm_sum = sgm_sum + bt_material_thickness * mu_bt(en_idx);
        sgm_bt = repmat(bt_material_thickness,[1,js.Views,js.DetectorZElementCount]) ...
            * mu_bt(en_idx);
        atten = atten + spec(en_idx,:).*exp(-sgm_sum);
        atten_bt = atten_bt + spec(en_idx,:).*exp(-sgm_bt);
    end
    
    %% Generate postlog noisy sinogram
    
    if isfield(js,'CountsPerPixel')
%         % tube current modulation
%         % this module may lead to bug
%         if isfield(js,'TubeCurrentModulation') && js.TubeCurrentModulation
%             if spec_idx == 1
%                 N_origin =  js.CountsPerPixel(1);
%                 atten_max_per_view = min(atten,[],1);
%                 modulation_factor = max(atten_max_per_view)./atten_max_per_view;
%                 N0_map_1 = repmat(N_origin*modulation_factor,[js.DetectorElementCount,1]);
%                 N0_map = N0_map_1;
%             else
%                 N0_map = N0_map_1*js.CountsPerPixel(spec_idx)/js.CountsPerPixel(1);
%             end
%         else
%             N0_map = js.CountsPerPixel(spec_idx);
%         end
        
        
        if length(js.CountsPerPixel)==1
            N_map = js.CountsPerPixel.*atten;
            N_map = poissrnd(N_map);
            %N_map = sqrt(N_map) .* randn(size(N_map))+N_map;
            N0_map = js.CountsPerPixel.*atten_bt;
            postlog_atten = -log(N_map./N0_map);
        else
            N_map = js.CountsPerPixel(spec_idx).*atten;
            N_map = sqrt(N_map) .* randn(size(N_map))+N_map;
            N0_map = js.CountsPerPixel(spec_idx).*atten_bt;
            postlog_atten = -log(N_map./N0_map);
        end
        
    else
        postlog_atten =  log(1./atten);
    end
    
    if  iscell(js.OutputSgmFileName)==0
        XuWriteRaw([js.OutputDir '/' js.OutputSgmFileName], postlog_atten);
        fprintf('File saved to %s.\n', [js.OutputDir '/' js.OutputSgmFileName] );
        output = postlog_atten;
    else
        XuWriteRaw([js.OutputDir '/' char(js.OutputSgmFileName{spec_idx})], postlog_atten);
        fprintf('File saved to %s.\n', [js.OutputDir '/'  char(js.OutputSgmFileName{spec_idx})] );
        output(:,:,spec_idx) = postlog_atten;
    end
end

end