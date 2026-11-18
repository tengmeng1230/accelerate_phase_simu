function img= XuMgfbpFromStructVer2(struct_js,rec_name)
if nargin == 1
    rec_name = [];
end
if ~exist(struct_js.OutputDir)
    mkdir(struct_js.OutputDir);
end
XuStructToJsonc('config_fbp_temp.jsonc',struct_js);
!mgfbp.exe config_fbp_temp.jsonc
delete config_fbp_temp.jsonc
D = dir([struct_js.OutputDir '/' char(struct_js.OutputFileReplace(2)) '*.raw']);
img = [];
if isempty(rec_name)
    
    if length(D) == 0
        error('No recon file found!')
    else
        for idx = 1:length(D)
            if isfield(struct_js, 'SliceCount')
                img = cat(3,img,XuReadRaw([struct_js.OutputDir '/' D(idx).name],...
                    [struct_js.ImageDimension,struct_js.ImageDimension,struct_js.SliceCount]));
            elseif isfield(struct_js, 'ImageDimensionZ')
                img = cat(3,img,XuReadRaw([struct_js.OutputDir '/' D(idx).name],...
                    [struct_js.ImageDimension,struct_js.ImageDimension,struct_js.ImageDimensionZ]));
            end
        end
    end
else
    if isfield(struct_js, 'SliceCount')
        img = cat(3,img,XuReadRaw([struct_js.OutputDir '/' rec_name],...
            [struct_js.ImageDimension,struct_js.ImageDimension,struct_js.SliceCount]));
    elseif isfield(struct_js, 'ImageDimensionZ')
        img = cat(3,img,XuReadRaw([struct_js.OutputDir '/' rec_name],...
            [struct_js.ImageDimension,struct_js.ImageDimension,struct_js.ImageDimensionZ]));
    end
end