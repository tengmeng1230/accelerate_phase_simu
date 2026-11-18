function img_ct_phase = XuSMOPhaseCT(img_ct,en_ave,sdd,sid,img_voxel_size,adj_ratio,hu_or_not)
%en_ave is average energy to calculate kappa and lambda
%sdd is source to detector distance
%sid is source to isocenter distance
%img_voxel_size is the recon voxel size (voxel must be cube)
%adj_ratio adjusts the voxel size to adjust the retreival strength
%hu_or_not: image is in mu unit or HU unit; deteremine boundary conditions for FFT; 
%1 for hu and 0 for mu

% if nargin ==5
%     adj_ratio = 1;
%     mu_or_hu = 'hu';
% else
% endd

img_voxel_size = img_voxel_size * adj_ratio;

z_eff = 1/(1/(sdd-sid) + 1/sid);

img_ct(isnan(img_ct)) = 0;
img_ct(isinf(img_ct)) = 0;

dect_dimension_x = size(img_ct,1);
dect_dimension_y = size(img_ct,2);
dect_dimension_z = size(img_ct,3);

vec_x = ((1:dect_dimension_x) - (1+dect_dimension_x)/2) * img_voxel_size;
vec_y = ((1:dect_dimension_y) - (1+dect_dimension_y)/2) * img_voxel_size;
vec_z = ((1:dect_dimension_z) - (1+dect_dimension_z)/2) * img_voxel_size;.0


[img_ct_fft,vec_kx,vec_ky,vec_kz] = Xufft3Ver2(img_ct+1000 * hu_or_not,vec_x,vec_y,vec_z,1);
[m_vec_kx,m_vec_ky,m_vec_kz] = meshgrid(vec_kx,vec_ky,vec_kz);
lambda = 1.24 ./ en_ave *1e-6; % in mm
kappa = XuGetKappa('water',en_ave);

smo_filter =1./(1+z_eff*lambda* kappa* pi * (m_vec_kx.^2 + m_vec_ky.^2+ m_vec_kz.^2));
img_ct_fft = img_ct_fft.*smo_filter;
img_ct_phase = real(Xufft3Ver2(img_ct_fft,vec_kx,vec_ky,vec_kz,0))-1000 * hu_or_not;
img_ct_phase(isnan(img_ct_phase)) = 0;
