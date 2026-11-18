function [img_fusion, img_mul] = XuGenerateDPCFusionImage(img_l,s_material,density,en_simu,a,eta,epsilon,N)
% Material Length Map: img_l
% Material Name: s_material, e.g. ‘water’
% Pixel Size: a (unit mm)
% X-ray Energy: en_simu
% System visibility: epsilon
% System sensitivity: eta
% Mean number of photons for each pixel (summed for all phase steps): N

lambda = XuEnergyToLambda(en_simu);
mu = XuGetAtten(s_material,density,en_simu)/10;
kappa = XuGetKappa(s_material,en_simu);
N_prelog = N.*exp(-img_l*mu);
img_mul = img_l*mu + randn(size(img_l)) .* sqrt(1./N_prelog);

vec_x = ((0:size(img_l,1)-1) - (size(img_l,1)-1)/2)  * a;
vec_y = ((0:size(img_l,2)-1) - (size(img_l,2)-1)/2)  * a;
[img_fft,vec_fx,vec_fy] = Xufft2Ver2(img_l,vec_x,vec_y,1);
%%
% 
[m_fx,m_fy] = meshgrid(vec_fy,vec_fx);
img_fft_filtered = img_fft.* sqrt(1+((eta*epsilon*lambda*kappa.*m_fx).^2)/8);
img_filtered =  real(Xufft2Ver2(img_fft_filtered,vec_fx,vec_fy,0));
img_mul_filtered = img_filtered*mu + randn(size(img_l)) .* sqrt(1./N_prelog);
img_mul_fft = Xufft2Ver2(img_mul_filtered,vec_x,vec_y,1)./sqrt(1+((eta*epsilon*lambda*kappa.*m_fx).^2)/8);

img_fusion = real(Xufft2Ver2(img_mul_fft,vec_fx,vec_fy,0));


%%


% img_fft = -img_fft.*1i*2*pi.*vec_fx;
% 
% img_diff_x = real(Xufft2Ver2(img_fft,vec_fx,vec_fy,0));
% 
% img_diff_muL = mu*img_diff_x + randn(size(img_l)) .* sqrt(2./N_prelog)*4*pi/(epsilon*eta*lambda*kappa);
% 
% img_diff_muL_fft = Xufft2Ver2(img_diff_muL,vec_x,vec_x,1);
% img_muL_fft = Xufft2Ver2(img_mul,vec_x,vec_x,1);
% 
% nps_1 = 1;
% nps_2 = 8./((eta*epsilon*lambda*kappa.*vec_fx).^2);
% 
% ratio_1 = nps_2 ./ (nps_1 + nps_2);
% ratio_2 = nps_1 ./ (nps_1 + nps_2);
% 
% s_1 = img_muL_fft;
% s_2 = img_diff_muL_fft./ (-1i*2*pi*vec_fx);
% 
% s = s_1.*ratio_1 + s_2.*ratio_2;
% 
% img_fusion = real(Xufft2Ver2(s,vec_fx,vec_fy,0));