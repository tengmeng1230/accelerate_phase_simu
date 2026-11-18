function [fids,cleanup] = XuOpenProjectionRawFiles(paths,mode)
% Keep each little-endian RAW stream open for a sequence of views.
fids = zeros(size(paths));
cleanup = cell(size(paths));
for idx = 1:numel(paths)
    [fid,message] = fopen(paths{idx},mode,'ieee-le');
    if fid < 0
        error('Cannot open %s: %s',paths{idx},message);
    end
    fids(idx) = fid;
    cleanup{idx} = onCleanup(@() fclose(fid));
end
end
