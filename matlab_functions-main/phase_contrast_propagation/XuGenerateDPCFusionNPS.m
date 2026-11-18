function [nps,m_fx,m_fy]= XuGenerateDPCFusionNPS(img_l,s_material,density,en_simu,a,eta,epsilon,N)
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
vec_x = ((0:size(img_l,1)-1) - (size(img_l,1)-1)/2)  * a;
[img_fft,vec_fx,vec_fy] = Xufft2Ver2(img_l,vec_x,vec_x,1);
[m_fx, m_fy] = meshgrid(vec_fx,vec_fy);
psi = N/a^2;
nps = 1/psi*1./(1+(lambda*kappa*eta*epsilon*m_fx).^2/8);