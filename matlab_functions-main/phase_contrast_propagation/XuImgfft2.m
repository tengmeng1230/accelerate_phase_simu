function [img_fft,vec_fx,vec_fy,vec_fx_m,vec_fy_m] = XuImgfft2(img,pixel_size)
vec_x = ((1:size(img,1)) - (1+size(img,1))/2) * pixel_size;
vec_y = ((1:size(img,2)) - (1+size(img,2))/2) * pixel_size;
[img_fft,vec_fx,vec_fy ]= Xufft2Ver2(img,vec_x,vec_y,1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);