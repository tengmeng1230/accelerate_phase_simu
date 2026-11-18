function img_output = XuDarkFieldFromDiff(img,pixel_size,epsilon,z_far,z_close,en)
img(isnan(img)) = 0;
dect_dimension_u = size(img,1);
dect_dimension_v = size(img,2);
dect_pixel_size = pixel_size;
vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;

[img_fft, vec_fx, vec_fy]= Xufft2Ver2(img, vec_x, vec_y, 1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);

lambda = XuEnergyToLambda(en);
kappa = XuGetKappa('water',en);

f_perp_square = vec_fx_m.^2 + vec_fy_m.^2;
filter =-4*pi^2*(f_perp_square + epsilon).*(z_far^2 - z_close^2 * (1+pi*kappa*lambda*z_far*f_perp_square)./(1+pi*kappa*lambda*z_close*f_perp_square) );

img_output = Xufft2Ver2(img_fft./filter,vec_fx,vec_fy,0);
img_output(isnan(img_output)) = 0;
img_output = abs(img_output).*sign(real(img_output));