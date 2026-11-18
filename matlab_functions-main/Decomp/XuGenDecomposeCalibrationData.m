function [m1,m2,atten_1,atten_2] = XuGenDecomposeCalibrationData(s_material_1,s_material_2,...
    length_material_1,length_material_2,density_material_1,density_material_2,...
    spec_1,spec_2,en_simu)
% [m1,m2,atten_1,atten_2] = XuGenDecomposeCalibrationData(s_material_1,s_material_2,...
%     length_material_1,length_material_2,density_material_1,density_material_2,...
%     spec_1,spec_2,en_simu)

mu_material_1 = XuGetAtten(s_material_1,density_material_1,en_simu)/10;
mu_material_2 = XuGetAtten(s_material_2,density_material_2,en_simu)/10;

[m1,m2] = meshgrid(length_material_1,length_material_2);

atten_1 = zeros(size(m1)); 
atten_2 = zeros(size(m1));
for en_idx = 1:length(en_simu)    
    atten_1 = atten_1 + spec_1(en_idx).* exp(-m1.*mu_material_1(en_idx)-...
        m2.*mu_material_2(en_idx) );
    atten_2 = atten_2 + spec_2(en_idx).* exp(-m1.*mu_material_1(en_idx)-...
        m2.*mu_material_2(en_idx) );
end
atten_1 = log(sum(spec_1)./atten_1);
atten_2 = log(sum(spec_2)./atten_2);