function output = XuGenDeltaNewMaterial(s_material,material_cell,density,en_simu)
%this function generates the delta values for a new material and saved it
%to the 'x_ray_refraction' folder
%s_material: string for the material name, e.g., nylon
%material_cell: chemical formula for the material, e.g., '{'S',1,'O',2,...}'
%density: density for the material, since delta value includes density,
%density must be indicated
%en_simu: x-ray range for the delta value, in keV. 


%folder = 'C:\Users\xji\Desktop\matlab_functions\matlab_functions\x_ray_refraction';
folder = fileparts(mfilename('fullpath'));
delta_output = XuGetDeltaFromChemicalFormula(material_cell, density,en_simu);
writematrix([en_simu'*1e3,delta_output'],[folder '\' s_material '_delta.txt']);
fprintf('Delta file is saved to %s!\n',[folder '\' s_material '_delta.txt']);
output = 1;