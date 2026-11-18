function img_sgm = XuMgfpjFromStructVer2(struct_js, sgm_name)

if nargin == 1
    sgm_name = [];
else
end
mkdir(struct_js.OutputDir);
XuStructToJsonc('config_fpj_temp.jsonc',struct_js);
!mgfpj.exe config_fpj_temp.jsonc
delete config_fpj_temp.jsonc

D = dir([struct_js.OutputDir '/' char(struct_js.OutputFileReplace(2)) '*.raw']);
img = [];
if isempty(sgm_name)
    if isempty(D)
        error('No sinogram file found!')
    else
        for idx = 1:length(D)
            if isfield(struct_js, 'DetectorElementCountVertical')
                img_sgm = cat(3,img,XuReadRaw([struct_js.OutputDir '/' D(idx).name],...
                    [struct_js.DetectorElementCountHorizontal,struct_js.Views,struct_js.DetectorElementCountVertical]));
            elseif isfield(struct_js, 'SliceCount')
                img_sgm = cat(3,img,XuReadRaw([struct_js.OutputDir '/' D(idx).name],...
                    [struct_js.DetectorElementCount,struct_js.Views,struct_js.SliceCount]));
            end
        end
    end
else
    if isfield(struct_js, 'DetectorElementCountVertical')
        img_sgm = cat(3,img,XuReadRaw([struct_js.OutputDir '/' sgm_name],...
            [struct_js.DetectorElementCountHorizontal,struct_js.Views,struct_js.DetectorElementCountVertical]));
    elseif isfield(struct_js, 'SliceCount')
        img_sgm = cat(3,img,XuReadRaw([struct_js.OutputDir '/' sgm_name],...
            [struct_js.DetectorElementCount,struct_js.Views,struct_js.SliceCount]));
    end
end