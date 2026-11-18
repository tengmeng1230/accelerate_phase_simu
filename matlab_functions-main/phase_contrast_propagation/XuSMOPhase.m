function img_phase = XuSMOPhase(img,en_ave,z_eff,dect_pixel_size)

img(isnan(img)) = 0;
img(isinf(img)) = 0;

dect_dimension_u = size(img,1);
dect_dimension_v = size(img,2);

vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;

[img_fft, vec_fx, vec_fy]= Xufft2Ver2(img - 1, vec_x, vec_y, 1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);

lambda = 1.24 ./ en_ave *1e-6; % in mm

kappa = 4*pi/lambda*XuGetDelta('water',en_ave,1)/(XuGetAtten('water',1,en_ave)/10);

smo_filter =1./(1 + z_eff * lambda * kappa * pi * (vec_fx_m.^2 + vec_fy_m.^2));

img_phase = -log(1+Xufft2Ver2(img_fft.*smo_filter,vec_fx,vec_fy,0));
img_phase(isnan(img_phase)) = 0;
img_phase = real(img_phase);