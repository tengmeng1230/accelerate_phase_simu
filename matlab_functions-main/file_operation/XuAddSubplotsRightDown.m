function status = XuAddSubplotsRightDown(img_3d,pixel_per_block,num_row,num_col,ratio,img_display_range,...
    row_idx_insert,col_idx_insert,boxcolor,position_adj_for_zoomed_img)
%begin from row_idx and col_idx
if nargin ==8
    boxcolor = 'k';
    position_adj_for_zoomed_img = [0 0];
elseif nargin ==9
    position_adj_for_zoomed_img = [0 0];
end


num_col_adj = num_col+position_adj_for_zoomed_img(2);
num_row_adj = num_row+position_adj_for_zoomed_img(1);
ratio_col_adj = num_col/num_col_adj;
ratio_row_adj = num_row/num_row_adj;

width = 1/num_col*ratio*ratio_col_adj;%define width
height = 1/num_row*ratio*ratio_row_adj;%define height

edge_h = 1/num_col*(1-ratio)*ratio_col_adj+ ...
    position_adj_for_zoomed_img(2)/num_col*ratio_col_adj; %distance to the side
edge_v = 0;%distance to the side

for idx = 1:size(img_3d,3)

    idx_true = (row_idx_insert-1)*num_col + col_idx_insert -1 +idx;

    col_idx = mod(idx_true-1,num_col);
    row_idx = floor((idx_true-1)/num_col);


    axes('position',[edge_h+col_idx/num_col*ratio_col_adj...
        edge_v+(num_row-1-row_idx)/num_row*ratio_row_adj...
        width height]);
    imshow(img_3d(:,:,idx),img_display_range);
        axis on;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'XColor',boxcolor, 'YColor',boxcolor);

end