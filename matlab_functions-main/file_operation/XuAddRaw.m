function status=XuAddRaw(s,data,s_format)
%status=AddRaw(s,data,s_format)
if nargin == 2
    s_format = 'float32';
end
filename= lower(s);
filename=strrep(filename,'.raw','');

filename=[filename,'.raw'];
fid=fopen(filename,'a','l');
fwrite(fid,data,s_format);
fclose(fid);
status=1;