function z=XuGetZFromName(s)
%z=XuGetZFromName(s)
%example 1=XuGetZFromName('H')
element_name=s;
name_and_z=importdata('name_and_z.txt');
find_element = 0;%whether element is found
for idx=1:size(name_and_z.textdata,1)
    if strcmp(element_name,char(name_and_z.textdata(idx,2)))
        find_element = 1;
        break;
    end
end
if find_element == 1
    z=name_and_z.data(idx);
else
    error(['Element ' s ' does not exist!']); 
end