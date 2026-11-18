function status = XuSubplots(img_3d,pixel_per_block,num_row,num_col,ratio,img_display_range,color,boxcolor)
if nargin == 6
    color = 'k';
elseif nargin ==7
    boxcolor = 'k';
end
width = 1/num_col*ratio;%define width
height = 1/num_row*ratio;%define height
edge_h = 1/num_col*(1-ratio)/2; %distance to the size
edge_v = 1/num_row*(1-ratio)/2;%distance to the size

figure();

set(gcf,'position',[0 0 pixel_per_block*num_col pixel_per_block*num_row]);
set(gcf,'color',color);
XuSetFigureTheme('darkrm');
for idx = 1:size(img_3d,3)

    col_idx = mod(idx-1,num_col);
    row_idx = floor((idx-1)/num_col);


    subplot('position',[edge_h+col_idx/num_col edge_v+(num_row-1-row_idx)/num_row width height]);
    imshow(img_3d(:,:,idx),img_display_range);
    axis on;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'XColor',boxcolor, 'YColor',boxcolor);
    status = 1;
end