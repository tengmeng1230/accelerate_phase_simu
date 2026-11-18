function delta_output = XuGetDeltaFromChemicalFormula(material_cell,density,en_simu)
%this function generates the delta values for a new material 
%material_cell: chemical formula for the material, e.g., '{'S',1,'O',2,...}'
%density: density for the material, since delta value includes density,
%density must be indicated
%en_simu: x-ray range for the delta value, in keV. 


%calculation of total mass number and total atomic number
Z_total = 0;A_total = 0;
for k = 1:2:length(material_cell)
    Z = XuGetZFromName(material_cell{k});
    Z_total = Z_total + Z * material_cell{k+1};
    A = XuGetAFromZ(Z);
    A_total = A_total + A * material_cell{k+1};
end
delta_output = XuGetDeltaCalc(en_simu,A_total,Z_total,density);