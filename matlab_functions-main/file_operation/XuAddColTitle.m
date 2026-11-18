function status = XuAddColTitle(str_cell,img_row_col_num,img_size,...
    position_adj_for_zoomed_img,text_portion,FontName,font_size)
%begin from row_idx and col_idx

if nargin == 5
    FontName = 'Times New Roman';
    font_size = 14;
end
if nargin == 6
    font_size = 14;
end
width_pixel = img_size(2) * (text_portion(2)+position_adj_for_zoomed_img(2) + img_row_col_num(2));
height_pixel = img_size(1) * (text_portion(1)+position_adj_for_zoomed_img(1) + img_row_col_num(1));


u_pos = text_portion(1)/(img_row_col_num(1)+position_adj_for_zoomed_img(1)+text_portion(1));
l_pos = text_portion(2)/(img_row_col_num(2)+position_adj_for_zoomed_img(2)+text_portion(2));
b_pos = 1 - position_adj_for_zoomed_img(1)/(img_row_col_num(1)+position_adj_for_zoomed_img(1)+text_portion(1));
r_pos = 1 -position_adj_for_zoomed_img(2) /(img_row_col_num(2)+position_adj_for_zoomed_img(2)+text_portion(2));

img_portion_h = r_pos - l_pos;
img_portion_v = b_pos - u_pos;


for idx = 1:length(str_cell)
    t = annotation('textbox','fontsize',font_size,'color','w',...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle','EdgeColor','none','FontName',FontName);
    t.Position= XuConvertPosVec([u_pos l_pos+img_portion_h/img_row_col_num(2)*(idx-1) ...
        u_pos img_portion_h/img_row_col_num(2)]);
    %[v_pos h_pos height width]
    t.String = char(str_cell(idx));
end


status =1; 