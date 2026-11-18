function kappa = XuGetKappa(s_material,en_simu)
mu  = XuGetAtten(s_material,1,en_simu)/10;
delta  = XuGetDelta(s_material,en_simu,1);
lambda =  1.24*1e-6./(en_simu);
kappa = delta ./mu*4*pi./lambda;
end