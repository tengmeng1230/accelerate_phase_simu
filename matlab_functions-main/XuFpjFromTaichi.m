function status = XuFpjFromTaichi(js_file,version)
recon_paths = importdata('recon_paths.txt');
copyfile([char(recon_paths(1)) '/recon_paths.txt'],'./recon_paths.txt')
if nargin == 1
    version = "v1";
end

if version == "v1"
    copyfile([char(recon_paths(1)) '/fpj_from_taichi.py'],'./fpj_temp.py');
elseif version == "v2"
    copyfile([char(recon_paths(1)) '/fpj_from_taichi_v2.py'],'./fpj_temp.py');
elseif version == "v3"
    copyfile([char(recon_paths(1)) '/fpj_from_taichi_v3.py'],'./fpj_temp.py');
end
if length(recon_paths) == 6
    command = [char(recon_paths(3)) ' ./fpj_temp.py ' js_file];
else
    command = ['/home/tengmeng/miniconda3/envs/tengmeng/bin/python ./fpj_temp.py ' js_file];
end
status = system(command);
delete ./fpj_temp.py
delete ./recon_paths.txt
if status ~= 0
    error('XuFpjFromTaichi:ProjectionFailed', ...
        'Forward projection failed (exit status %d). Command: %s',status,command);
end
end