function status = XuAddRowTitle(str_cell,img_row_col_num,img_size,...
    position_adj_for_zoomed_img,text_portion,FontName,font_size)
%begin from row_idx and col_idx

if nargin == 5
    FontName = 'Times New Roman';
    font_size = 14;
end
if nargin == 6
    font_size=14;
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
        'VerticalAlignment','top','EdgeColor','none','Rotation',90,'FontName',FontName);
    t.Position= XuConvertPosVec([u_pos+img_portion_v/img_row_col_num(1)*(idx) ...
        l_pos ...
        width_pixel*l_pos/height_pixel height_pixel*img_portion_v/img_row_col_num(1)/width_pixel]);
    %We need to rotate the image, and the portion is calculated for row and
    %col first
    %for example, the width for the textbox before rotation should be
    %height_pixel*img_portion_v/img_row_col_num(1) (unit pixel)
    %it occupies "This absolution width"/width_pixel
    t.String = char(str_cell(idx));
end


status =1; 