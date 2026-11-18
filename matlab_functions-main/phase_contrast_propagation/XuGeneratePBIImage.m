function [img_pbi, img_mul] = XuGeneratePBIImage(img_l,s_material,density,en_simu,a,z,N)

lambda = XuEnergyToLambda(en_simu);
mu = XuGetAtten(s_material,density,en_simu)/10;
kappa = XuGetKappa(s_material,en_simu);
img_pre_log = exp(-img_l*mu);
vec_x = ((0:size(img_l,1)-1) - (size(img_l,1)-1)/2)  * a;

[img_fft,vec_fx,vec_fy] = Xufft2Ver2(img_pre_log,vec_x,vec_x,1);
[m_fx, m_fy] = meshgrid(vec_fx,vec_fy);
img_fft = img_fft.*(1+pi*kappa*lambda*z*(m_fx.^2+m_fy.^2));
img_edge_enhance = real(Xufft2Ver2(img_fft,vec_fx,vec_fy,0));
img_edge_enhance_noisy  = (N*img_edge_enhance + randn(size(img_l)) * sqrt(N)) / N;
img_pbi = XuSMOPhase(img_edge_enhance_noisy,en_simu,z,a);
img_mul = img_l*mu + randn(size(img_l)) * sqrt(1/N);