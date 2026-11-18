function [img_phase,cache] = XuSMOPhaseV2(img,en_ave,sdd,sid,dect_pixel_size,adj_ratio,cache)
%img is the prelog data
if nargin ==5
    adj_ratio = 1;
end

% Reuse only with the same image dimensions, geometry and energy.
if nargin < 7 || isempty(cache)
    cache = buildFilter(size(img),en_ave,sdd,sid,dect_pixel_size,adj_ratio);
end
img(isnan(img)) = 0;
img(isinf(img)) = 0;

img_fft = Xufft2Ver2(img - 1,cache.forward);
img_phase = -log(1+Xufft2Ver2(img_fft.*cache.filter,cache.inverse));
img_phase(isnan(img_phase)) = 0;
img_phase = real(img_phase);
end

function cache = buildFilter(frame_size,en_ave,sdd,sid,dect_pixel_size,adj_ratio)
mag = sdd/sid;
dect_pixel_size = dect_pixel_size/mag * adj_ratio;

z_eff = 1/(1/(sdd-sid) + 1/sid);

dect_dimension_u = frame_size(1);
dect_dimension_v = frame_size(2);

vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;

cache.forward = Xufft2Ver2Plan(frame_size,vec_x,vec_y,1);
vec_fx = cache.forward.vec_kx;
vec_fy = cache.forward.vec_ky;
cache.inverse = Xufft2Ver2Plan(frame_size,vec_fx,vec_fy,0);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);

lambda = 1.24 ./ en_ave *1e-6; % in mm

kappa = 4*pi/lambda*XuGetDelta('water',en_ave,1)/(XuGetAtten('water',1,en_ave)/10);

cache.filter =1./(1+z_eff*lambda* kappa* pi * (vec_fx_m.^2 + vec_fy_m.^2));
end
