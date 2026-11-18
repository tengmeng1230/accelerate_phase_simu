function f_g = XuGenerateGratingFunction1DMaterialAndEnergy(vec_x,p,c,en_simu,s_material_base,t_material_base,...
    s_material,t_material)

lambda = XuEnergyToLambda(en_simu);

density_material_base = MgGetMaterialDensity(s_material_base);
density_material = MgGetMaterialDensity(s_material);

mu_base = XuGetAtten(s_material_base,density_material_base,en_simu)/10;
mu = XuGetAtten(s_material,density_material,en_simu)/10;

delta_base = XuGetDelta(s_material_base,en_simu);
delta = XuGetDelta(s_material,en_simu);


t_b = exp(-t_material_base*mu_base - t_material*mu);
t_s = exp(-t_material_base*mu_base);

phi_s = -2*pi/lambda * (delta_base*t_material_base);
phi_b = -2*pi/lambda * (delta*t_material + delta_base*t_material_base);


f_g = XuGenerateGratingFunction1D(vec_x,p,c,t_b,phi_b,t_s,phi_s);