function status = XuSubplotsRectangle(img_3d,pixel_per_block_row,pixel_per_block_col,num_row,...
    num_col,ratio,img_display_range,color,boxcolor,position_adj_for_zoomed_img)
if nargin == 7
    color = 'k';boxcolor = 'k';position_adj_for_zoomed_img=[0 0];
elseif nargin ==8
    boxcolor = 'k';position_adj_for_zoomed_img=[0 0];
elseif nargin ==9
    position_adj_for_zoomed_img=[0 0];
end


num_col_adj = num_col+position_adj_for_zoomed_img(2);
num_row_adj = num_row+position_adj_for_zoomed_img(1);
ratio_col_adj = num_col/num_col_adj;
ratio_row_adj = num_row/num_row_adj;

width = 1/num_col*ratio*ratio_col_adj;%define width
height = 1/num_row*ratio*ratio_row_adj;%define height


edge_h = 1/num_col*(1-ratio)/2*ratio_col_adj; %distance to the size
edge_v = 1/num_row*(1-ratio)/2*ratio_row_adj + (1-ratio_row_adj);%distance to the size

figure();

set(gcf,'position',[0 0 ...
    pixel_per_block_col*num_col_adj ...
    pixel_per_block_row*num_row_adj]);



set(gcf,'color',color);
XuSetFigureTheme('darkrm');
for idx = 1:size(img_3d,3)

    col_idx = mod(idx-1,num_col);
    row_idx = floor((idx-1)/num_col);


    axes('position',[edge_h+col_idx/num_col*ratio_col_adj ...
        edge_v+(num_row-1-row_idx)/num_row*ratio_row_adj ...
        width height]);
    imshow(img_3d(:,:,idx),img_display_range);
    axis on;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'XColor',boxcolor, 'YColor',boxcolor);
    status = 1;
end

