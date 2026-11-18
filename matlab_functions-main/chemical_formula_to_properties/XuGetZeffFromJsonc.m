function z_eff=XuGetZeffFromJsonc(s_jsonc)
%mu_rho=XuGetZeffFromJsonc(s_jsonc)

para_material=XuReadJsonc(s_jsonc);

total_z = 0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    total_z=total_z+element_count*z;
end

z_eff = 0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    f = element_count*z/total_z;
    z_eff=z_eff+  f* z^2.94;
end

z_eff = z_eff^(1/2.94);
