function status = XuStructToIn(s_in,s_struct)

cell_in = struct2cell(s_struct);
materials_cell=cell_in{end};
cell_in{end}=[];
writecell(cell_in,s_in,'delimiter',' ');
writecell(materials_cell,s_in,'delimiter',' ','WriteMode','append');
status = 1;

end