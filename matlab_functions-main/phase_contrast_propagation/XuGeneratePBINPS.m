function [nps,m_fx,m_fy] = XuGeneratePBINPS(img_l,s_material,density,en_simu,a,z,N)

lambda = XuEnergyToLambda(en_simu);
mu = XuGetAtten(s_material,density,en_simu)/10;
kappa = XuGetKappa(s_material,en_simu);
vec_x = ((0:size(img_l,1)-1) - (size(img_l,1)-1)/2)  * a;

[img_fft,vec_fx,vec_fy] = Xufft2Ver2(img_l,vec_x,vec_x,1);
[m_fx, m_fy] = meshgrid(vec_fx,vec_fy);
psi = N/a^2;
nps = 1/psi*1./(1+(pi*lambda*z*kappa*(m_fy.^2+m_fx.^2))).^2;