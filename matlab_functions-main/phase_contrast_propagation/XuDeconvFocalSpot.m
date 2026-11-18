function img_conv = XuDeconvFocalSpot(img,mag,dect_pixel_size,ratio,source_name)
%Notice that kailong focal spot may leads to singularity
if nargin == 3
    ratio = 1; % to adjust focal spot size; adjust to be about 0.3 mm * ratio
    source_name = 'kailong';
elseif nargin == 4
    source_name = 'kailong';
end
img = img';
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

dect_dimension_u = size(img,1);
dect_dimension_v = size(img,2);

dect_pixel_size = dect_pixel_size/mag;


vec_x = ((1:dect_dimension_u) - (1+dect_dimension_u)/2) * dect_pixel_size;
vec_y = ((1:dect_dimension_v) - (1+dect_dimension_v)/2) * dect_pixel_size;
img_mean = XuMean2(img);
[img_fft, vec_fx, vec_fy]= Xufft2Ver2(img - img_mean, vec_x, vec_y, 1);
[vec_fy_m, vec_fx_m] = meshgrid(vec_fy, vec_fx);
focal_spot_filter = interp1(f_fso_v,mtf_v,vec_fy_m*(mag-1)/mag*ratio,'linear').*interp1(f_fso_h,mtf_h,vec_fx_m*(mag-1)/mag*ratio,'linear');

img_conv = real(Xufft2Ver2(img_fft./(focal_spot_filter+eps),vec_fx,vec_fy,0)) + img_mean;
img_conv = img_conv';
%mtf_v and mtf_h are calculated from
%C:\Users\xji\Desktop\shangkeda_benchtop\data-25-07-28\PbSlice\PbSlice\process.m
%