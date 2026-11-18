function [img_conv,cache] = XuConvFocalSpot(img,mag,dect_pixel_size,ratio,source_name,cache)

if nargin == 3
    ratio = 1; % to adjust focal spot size; adjust to be about 0.3 mm * ratio
    source_name = 'kailong';
elseif nargin == 4
    source_name = 'kailong';
end

% Reuse only with the same image dimensions, geometry and source.
if nargin < 6 || isempty(cache)
    cache = buildFilter(size(img),mag,dect_pixel_size,ratio,source_name);
end
img_mean = XuMean2(img);
img_fft = Xufft2Ver2(img - img_mean,cache.forward);
img_conv = real(Xufft2Ver2(img_fft.*cache.filter,cache.inverse)) + img_mean;
end

function cache = buildFilter(frame_size,mag,dect_pixel_size,ratio,source_name)
if strcmp(source_name,'kailong')
    load('mtf_h.mat');
    mtf_h = mtf;%./max(mtf);
    f_fso_h = f;
    load('mtf_v.mat');
    mtf_v =  mtf;%./max(mtf);
    f_fso_v = f;
elseif strcmp(source_name,'vj')
    load('mtf_h_vj.mat');
    mtf_h = mtf;%./max(mtf);
    f_fso_h = f;
    load('mtf_v_vj.mat');
    mtf_v =  mtf;%./max(mtf);
    f_fso_v = f;
elseif strcmp(source_name,'mps')
    load('mtf_h_mps.mat');
    mtf_h = mtf;%./max(mtf);
    f_fso_h = f;
    load('mtf_v_mps.mat');
    mtf_v =  mtf;%./max(mtf);
    f_fso_v = f;
else
    error('source name must be kailong or vj or mps!');
end

dect_dimension_u = frame_size(1);
dect_dimension_v = frame_size(2);

dect_pixel_size = dect_pixel_size/mag;


vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;
cache.forward = Xufft2Ver2Plan(frame_size,vec_x,vec_y,1);
vec_fx = cache.forward.vec_kx;
vec_fy = cache.forward.vec_ky;
cache.inverse = Xufft2Ver2Plan(frame_size,vec_fx,vec_fy,0);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);
cache.filter = interp1(f_fso_v,mtf_v,vec_fy_m*(mag-1)/mag*ratio,'linear').*interp1(f_fso_h,mtf_h,vec_fx_m*(mag-1)/mag*ratio,'linear');
end
