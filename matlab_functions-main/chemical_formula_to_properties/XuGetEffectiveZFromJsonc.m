function effectiveZ=XuGetEffectiveZFromJsonc(s_jsonc,m)
%effectiveZ=XuGetEffectiveZFromJsonc(s_jsonc)
%get the effective atomic number from the jsonc file
%a sample jsonc file is provided in the folder
%the equation used is given as
%z_eff=(sum_i f_i z_i^(m-1))^(1/(m-1))
%by default m = 3.94
if nargin ==1
    m = 3.94;
end
para_material=XuReadJsonc(s_jsonc);

total_z=0;
temp_sum=0; 
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    %get the name of the element
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    %get the count of the element
    
    z=XuGetZFromName(element_name);
    %get the atomic number of the element from the name
    
    total_z=total_z+z*element_count;
    %get the total atomic number
    
    temp_sum=temp_sum+z*element_count*z^(m-1);
end


effectiveZ=(temp_sum/total_z)^(1/(m-1));