function output = XuGenAttenNewMaterial(s_material,material_cell,en_simu)
%this function generates the mass atten values for a new material and saved it
%to the 'x_ray_atten' folder
%s_material: string for the material name, e.g., nylon
%material_cell: chemical formula for the material, e.g., '{'S',1,'O',2,...}'
%en_simu: x-ray range for the delta value, in keV. 
%since this is mass atten, we do not need to indicate the density

folder = fileparts(mfilename('fullpath'));
mu_output = XuGetAttenFromChemicalFormula(material_cell, 1, en_simu);
%this is mass attenuation, density is set to be 1
writematrix([en_simu'*1e-3,mu_output'],[folder '\' s_material '_atten.txt']);
fprintf('Atten file is saved to %s!\n',[folder '\' s_material '_delta.txt']);
output = 1;
