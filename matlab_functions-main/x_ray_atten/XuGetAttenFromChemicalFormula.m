function mu_output = XuGetAttenFromChemicalFormula(material_cell, density,en_simu)
%this function generates the mass atten values for a new material 
%material_cell: chemical formula for the material, e.g., '{'S',1,'O',2,...}'
%en_simu: x-ray range for the delta value, in keV. 
%density: density of the material. 
%since this is mass atten, we do not need to indicate the density


%calculation of total mass number
A_total = 0;
for k = 1:2:length(material_cell)
    Z = XuGetZFromName(material_cell{k});
    A = XuGetAFromZ(Z);
    A_total = A_total + A * material_cell{k+1};
end
mu_mass = 0;
for k = 1:2:length(material_cell)
    Z = XuGetZFromName(material_cell{k});
    A = XuGetAFromZ(Z);
    f = A * material_cell{k+1}/ A_total;%mass fraction
    mu_mass = mu_mass+XuGetAtten(material_cell{k},1,en_simu) * f;
end
mu_output = mu_mass * density;