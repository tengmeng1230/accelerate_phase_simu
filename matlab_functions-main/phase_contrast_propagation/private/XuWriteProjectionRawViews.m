function XuWriteProjectionRawViews(fids,varargin)
% Append the current view to each corresponding RAW stream.
for idx = 1:numel(fids)
    img = varargin{idx};
    if fwrite(fids(idx),img,'float32') ~= numel(img)
        error('Incomplete write to %s.',fopen(fids(idx)));
    end
end
end
