function status = XuAddSubplotsRightDownVer2(img_3d,img_row_col_num,...
    ratio,img_display_range,row_col_idx_insert,boxcolor,...
    position_adj_for_zoomed_img,text_portion,vertical)
%begin from row_idx and col_idx
if nargin ==5
    boxcolor = 'k';position_adj_for_zoomed_img=[0,0];text_portion = [0,0];vertical=0;
elseif nargin==6
    position_adj_for_zoomed_img=[0,0];text_portion = [0,0];vertical=0;
elseif nargin == 7
    text_portion = [0,0];vertical=0;
elseif nargin == 8
    vertical=0;
end


u_pos = text_portion(1)/(img_row_col_num(1)+position_adj_for_zoomed_img(1)+text_portion(1));
l_pos = text_portion(2)/(img_row_col_num(2)+position_adj_for_zoomed_img(2)+text_portion(2));
b_pos = 1 - position_adj_for_zoomed_img(1)/(img_row_col_num(1)+position_adj_for_zoomed_img(1)+text_portion(1));
r_pos = 1 -position_adj_for_zoomed_img(2) /(img_row_col_num(2)+position_adj_for_zoomed_img(2)+text_portion(2));
img_portion_h = r_pos - l_pos;
img_portion_v = b_pos - u_pos;
portion_v_subimg = img_portion_v/img_row_col_num(1);
portion_h_subimg = img_portion_h/img_row_col_num(2);
edge_v = portion_v_subimg + portion_v_subimg * position_adj_for_zoomed_img(1)*0.8; %0.8 is to create a small gap to side
edge_h = (1-ratio)*portion_h_subimg + portion_h_subimg * position_adj_for_zoomed_img(2)*0.8; %0.8 is to create a small gap to side
for idx = 1:size(img_3d,3)

    if vertical==0
        idx_true = (row_col_idx_insert(1)-1)*img_row_col_num(2) ...
        + row_col_idx_insert(2) -1 +idx;
        col_idx = mod(idx_true-1,img_row_col_num(2));
        row_idx = floor((idx_true-1)/img_row_col_num(2));
    else
        idx_true = (row_col_idx_insert(2)-1)*img_row_col_num(1) ...
        + row_col_idx_insert(1) -1 +idx;
        col_idx = floor((idx_true-1)/img_row_col_num(1));
        row_idx = mod((idx_true-1),img_row_col_num(1));
    end
    pos_vec = XuConvertPosVec([u_pos+edge_v+portion_v_subimg*(row_idx), ...
        l_pos+portion_h_subimg*(col_idx)+edge_h, ...
        portion_v_subimg*ratio,portion_h_subimg*ratio]);
    axes('position',pos_vec);
    imshow(img_3d(:,:,idx),img_display_range);
    axis on;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'XColor',boxcolor, 'YColor',boxcolor);

end

status =1; 