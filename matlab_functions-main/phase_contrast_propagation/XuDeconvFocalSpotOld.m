function img_deconv = XuDeconvFocalSpotOld(img_prelog,mag)


load('mtf_h.mat');
mtf_h = mtf;
f_fso_h = f;
load('mtf_v.mat');
mtf_v = mtf;
f_fso_v = f;

dect_dimension_u = size(img_prelog,1);
dect_dimension_v = size(img_prelog,2);

dect_pixel_size = 0.05/mag;


vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;

[img_fft, vec_fx, vec_fy]= Xufft2Ver2(img_prelog, vec_x, vec_y, 1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);
focal_spot_filter = interp1(f_fso_h,mtf_h,vec_fy_m*(mag-1)/mag,'linear').*interp1(f_fso_v,mtf_v,vec_fx_m*(mag-1)/mag,'linear');
img_fft(sqrt(vec_fy_m.^2 + vec_fx_m.^2)>10)=0;

img_deconv = real(Xufft2Ver2(img_fft./focal_spot_filter,vec_fx,vec_fy,0));