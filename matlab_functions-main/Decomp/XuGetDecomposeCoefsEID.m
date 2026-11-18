function [coef_1,coef_2] = XuGetDecomposeCoefsEID(s_material_1,s_material_2,...
    length_material_1,length_material_2,density_material_1,density_material_2,...
    spec_1,spec_2,en_simu,order_cell)
%[coef_1,coef_2] = XuGetDecomposeCoefs(s_material_1,s_material_2,...
%    length_material_1,length_material_2,density_material_1,density_material_2,...
%    en_simu,order_cell)

%Given two materials and the calibrations lengths, Get the decompose coefs
%using polynomial fit


mu_material_1 = XuGetAtten(s_material_1,density_material_1,en_simu)/10;
mu_material_2 = XuGetAtten(s_material_2,density_material_2,en_simu)/10;

[m1,m2] = meshgrid(length_material_1,length_material_2);

atten_1 = zeros(size(m1)); 
atten_2 = zeros(size(m1));
for en_idx = 1:length(en_simu)    
    atten_1 = atten_1 + en_simu(en_idx)*spec_1(en_idx).* exp(-m1.*mu_material_1(en_idx)-...
        m2.*mu_material_2(en_idx) );
    atten_2 = atten_2 + en_simu(en_idx)*spec_2(en_idx).* exp(-m1.*mu_material_1(en_idx)-...
        m2.*mu_material_2(en_idx) );
end
atten_1 = log(sum(en_simu.*spec_1)./atten_1);
atten_2 = log(sum(en_simu.*spec_2)./atten_2);
coef_1 = XuPolyFitForTwoInputs(atten_1(:),atten_2(:),m1(:),order_cell);
coef_2 = XuPolyFitForTwoInputs(atten_1(:),atten_2(:),m2(:),order_cell);