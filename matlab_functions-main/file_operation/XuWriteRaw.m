function status=XuWriteRaw(s,data,s_format)
%status=WriteRaw(s,data)

if nargin == 2
    s_format = 'float32';
end

filename=s;
filename = strrep(filename,'.raw','');
filename = strrep(filename,'.RAW','');
filename=[filename,'.raw'];
fid=fopen(filename,'w','l');
fwrite(fid,data,s_format);
fclose(fid);
status=1;