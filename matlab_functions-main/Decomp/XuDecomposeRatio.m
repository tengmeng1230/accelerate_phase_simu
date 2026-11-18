function coef=XuDecomposeRatio(s_material,density,s_material_1,density_1,s_material_2,density_2,energy)
%function coef=XuDecompose(s_material,density,s_material_1,density_1,s_material_2,density_2,energy)
mu_1=XuGetAtten(s_material_1,density_1,energy);
mu_2=XuGetAtten(s_material_2,density_2,energy);
mu=XuGetAtten(s_material,density,energy);

x_1 = mu_1./mu;
x_2 = mu_2./mu;
y = mu./mu;
coef=[y]*[x_1;x_2]'*inv([x_1;x_2]*[x_1;x_2]');