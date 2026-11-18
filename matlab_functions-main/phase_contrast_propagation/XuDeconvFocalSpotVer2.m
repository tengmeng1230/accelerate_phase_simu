function img_deconv = XuDeconvFocalSpotVer2(img_prelog,mag)

load('mtf_h.mat');
mtf_h = mtf;
f_fso_h = f;

load('para_fs_h.mat');
para_h = para;
load('para_fs_v.mat');
para_v = para;

dect_dimension_u = size(img_prelog,1);
dect_dimension_v = size(img_prelog,2);

dect_pixel_size = 0.05/mag;


vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;

[img_fft, vec_fx, vec_fy]= Xufft2Ver2(img_prelog, vec_x, vec_y, 1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);
focal_spot_filter = interp1(f_fso_h,mtf_h,vec_fy_m*(mag-1)/mag,'linear').*abs(sinc(vec_fx_m*(mag-1)/mag * 0.2));
focal_spot_filter = exp(-(vec_fy_m*(mag-1)/mag).^2/3.^2).*exp(-(vec_fx_m*(mag-1)/mag).^2/3.^2);
focal_spot_filter = focal_spot_filter / max(focal_spot_filter(:));

img_fft(sqrt(vec_fy_m.^2 + vec_fx_m.^2)>10)=0;


img_deconv = real(Xufft2Ver2(img_fft./focal_spot_filter,vec_fx,vec_fy,0));