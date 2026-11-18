function img_deconv = XuDeconvXineos(img)
dect_dimension_u = size(img,1);
dect_dimension_v = size(img,2);

dect_pixel_size = 0.05;


vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;

[img_fft, vec_fx, vec_fy]= Xufft2Ver2(img, vec_x, vec_y, 1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);

edge_enhancing_filter =(1+6.18e-2 * (vec_fx_m.^2 + vec_fy_m.^2) - 2.34e-4* (vec_fx_m.^2 + vec_fy_m.^2).^2);

img_deconv = real(Xufft2Ver2(img_fft.*edge_enhancing_filter,vec_fx,vec_fy,0)) ;