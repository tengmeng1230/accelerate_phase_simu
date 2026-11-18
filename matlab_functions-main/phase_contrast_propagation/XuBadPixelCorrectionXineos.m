function img_output = XuBadPixelCorrectionXineos(img_input)
%img_input should be 5890 x 4608
bad_pixels = importdata("bad_pixels_xineos.txt");

mask = zeros(size(img_input));
for idx = 1:size(bad_pixels,1)
    mask(bad_pixels(idx,1)+1,bad_pixels(idx,2)+1) = 1;
end
mask(1718+1:2122+1,1776) = 1;
img_output = XuBadPixelCorrFast(img_input,mask);