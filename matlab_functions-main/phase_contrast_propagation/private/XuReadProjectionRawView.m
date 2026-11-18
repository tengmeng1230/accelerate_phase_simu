function img = XuReadProjectionRawView(fid,frame_size,view_idx)
% Sequential calls are already at the next view. Seek for other accesses.
offset = (view_idx-1)*prod(frame_size)*4;
if ftell(fid) ~= offset && fseek(fid,offset,'bof') ~= 0
    error('Cannot seek to view %d in %s.',view_idx,fopen(fid));
end
[img,count] = fread(fid,frame_size,'single=>double');
if count ~= prod(frame_size)
    error('Incomplete view %d in %s.',view_idx,fopen(fid));
end
end
