function status = XuImshowTightBorder(img,range)
if nargin == 1
    range = [];
end
imshow(img,range,'border','tight','initialmagnification','fit');
status=1;