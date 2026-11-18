function status  = XuGenMultiImgWithZoomVertical(img_3d,s_jsonc,output_fig_name)
%Version of Matlab needs to be 2023 or higher! 
%requires 'textrotation' option in text function
%This function is used to automatically generate multiple images 
%with zoomed regions. 
%The configurations are from a jsonc file. 
%Below is a sample Config File
% {
%     "RowNum":3,//number of rows
%     "ColNum":4,//number of columns
%     "ImgHeight":150,//height for each individual image, unit:pixels
%     "ImgWidth":180,//width for each individual image, unit:pixels
%     "TextPortion":[0.12,0.12],
%       //Space for the row and column titles
%       //[Row, Col] unit: ratio of each image
%
%     "ImgZoomPosAdj":[0.05,0.05],//Row, Col
%       //Space for to adjust the position of the zoomed image
%       //[Row, Col] unit: ratio of each image
%
%     "TitleCol":["Col 1","Col 2","Col 3","Col 4"],//title for each column
%     "TitleRow":["Row 1","Row 2","Row 3"],//title for each row
%     "ImgRatio":0.99,//zoom ratio for each image
%     "ImgZoomRatio":0.4,//zoom ratio for each zoomed ROI image
%     "DisplayRangeArray": [0.80,1.05], 
%       // Each row shares the same display range 
%       // so this array should have 2*RowNum elements: [range_l1, range_h1, range_l2, range_h3,...]
%       // If all images share the same display range, only two elements
%       are needed
%     "CenterCorrArray": [320,140,170,170,256,408],
%       // Defines center of the zoomed region. Each row shares the same roi region
%       // so this array should have 2*RowNum elements: [roi_x1, roi_y1, roi_x2, roi_y2,...]
%     "RoiSizeArray":[100,100,100], 
%       // Each row shares the same roi size
%       // so this array should have RowNum elements: [roi_size1, roi_size2,...]

%     "FontName":"仿宋",//Optional, font for title, by default is Times new roman
%     "IndividualImgWindow":[1,4,0,0.05,2,4,0,0.05,3,4,0,0.05,4,4,0,0.05],
%      //Optional, some images may need individual display range
%      //format:[rowidx1,colidx1,range_l1,range_h1,rowidx2,colidx2,range_l2,range_h2,...]
%      //use rowidx1,colidx1 to indicate which image
%     "RectangleForEverySubplot": 1,
%     //Optional, whether rectangle is drawn all plots
%     "SubCaptionOn": 1
%       //Optional, whether subcaption like a1) a2) are displayed or not. 
% }


js = XuReadJsonc(s_jsonc);
XuSetFigureTheme('darkrm');
position_adj_for_zoomed_img = js.ImgZoomPosAdj;
%to addjust the position of the zoomed img, unit is portion of one sub img
%height and width
img_row_col_num = [js.RowNum,js.ColNum];% num of rows and cols
img_size = [js.ImgHeight js.ImgWidth];% size for each sub img, height and width
text_portion =js.TextPortion;
if isfield(js,'FontName')
    font_name = js.FontName;
else
    font_name = 'Times New Roman';
end
%height and width
%space to keep the title of the figures, unit is is portion of one sub img

str_cell_col = js.TitleCol;
str_cell_row = js.TitleRow;

ratio = js.ImgRatio;
img_display_range_array = js.DisplayRangeArray;
center_coor_array = js.CenterCorrArray;
roi_size_array = js.RoiSizeArray;
zoom_img_ratio = js.ImgZoomRatio;
if isfield(js,'SubCaptionOn')%Turn on or off subcaption
    SubCaptionOn = js.SubCaptionOn;
else
    SubCaptionOn = 1;
end

boxcolor = 'k';

figure();
%make a canvas
set(gcf,'position',[0 0 ...
    img_size(2)*(img_row_col_num(2)+position_adj_for_zoomed_img(2)+text_portion(2)) ...
    img_size(1)*(img_row_col_num(1)+position_adj_for_zoomed_img(1)+text_portion(1))]);

%add title for each column
XuAddColTitle(str_cell_col,img_row_col_num,img_size,...
    position_adj_for_zoomed_img,text_portion,font_name);

%add title for each row
XuAddRowTitle(str_cell_row,img_row_col_num,img_size,...
    position_adj_for_zoomed_img,text_portion,font_name);

for col_idx = 1:img_row_col_num(2)
    idx_begin = (col_idx-1)*img_row_col_num(1)+1;
    idx_end = (col_idx-1)*img_row_col_num(1)+img_row_col_num(1);
    if length(img_display_range_array)==2
        % if img_display_range_array only have two values,
        % Then apply them to all images.
        img_display_range = img_display_range_array(1:2);
    else
        img_display_range = img_display_range_array((col_idx-1)*2+1:(col_idx)*2);
    end
    center_coor = center_coor_array((col_idx-1)*2+1:(col_idx)*2);
    roi_size = roi_size_array(col_idx);
    XuAddSubplotsVer2(img_3d(:,:,idx_begin:idx_end),img_row_col_num,ratio,img_display_range,[1,col_idx],boxcolor,position_adj_for_zoomed_img,text_portion,SubCaptionOn,1);
    XuAddSubplotsVer2(img_3d(:,:,idx_begin),img_row_col_num,ratio,img_display_range,[1,col_idx],boxcolor,position_adj_for_zoomed_img,text_portion,SubCaptionOn,1);
    XuPlotRectangle(center_coor,roi_size,'y');

    if isfield(js,'RectangleForEverySubplot')
        if js.RectangleForEverySubplot ==1
            for idx_row = idx_begin:idx_end
                XuAddSubplotsVer2(img_3d(:,:,idx_row),img_row_col_num,ratio,img_display_range,[1+idx_row-idx_begin,col_idx],boxcolor,position_adj_for_zoomed_img,text_portion,SubCaptionOn,1);
                XuPlotRectangle(center_coor,roi_size,'y');
            end
        end
    end
end



for col_idx = 1:img_row_col_num(2)
    if js.RoiSizeArray(col_idx)~=0
        idx_begin = (col_idx-1)*img_row_col_num(1)+1;
        idx_end = (col_idx-1)*img_row_col_num(1)+img_row_col_num(1);
        if length(img_display_range_array)==2
            % if img_display_range_array only have two values,
            % Then apply them to all images.
            img_display_range = img_display_range_array(1:2);
        else
            img_display_range = img_display_range_array((col_idx-1)*2+1:(col_idx)*2);
        end
        center_coor = center_coor_array((col_idx-1)*2+1:(col_idx)*2);
        roi_size = roi_size_array(col_idx);
        XuAddSubplotsRightDownVer2(img_3d(center_coor(2)-roi_size/2:center_coor(2)+roi_size/2,...
            center_coor(1)-roi_size/2:center_coor(1)+roi_size/2,idx_begin:idx_end),...
            [img_row_col_num(1),img_row_col_num(2)],zoom_img_ratio,img_display_range,[1,col_idx],'y',position_adj_for_zoomed_img,text_portion,1);
    end

end

if isfield(js,'IndividualImgWindow')
    data = js.IndividualImgWindow;
    for idx = 1:round(length(data)/4)
        row_idx = data((idx-1)*4+1);col_idx =  data((idx-1)*4+2);
        idx_begin = (row_idx-1)*img_row_col_num(2)+col_idx;
        idx_end = (row_idx-1)*img_row_col_num(2)+col_idx;
        img_display_range = [ data((idx-1)*4+3)  data((idx-1)*4+4)];
        center_coor = center_coor_array((row_idx-1)*2+1:(row_idx)*2);
        roi_size = roi_size_array(row_idx);
        XuAddSubplotsVer2(img_3d(:,:,idx_begin:idx_end),img_row_col_num,ratio,img_display_range,[row_idx,col_idx],boxcolor,position_adj_for_zoomed_img,text_portion,SubCaptionOn);
        if isfield(js,'RectangleForEverySubplot')
            if js.RectangleForEverySubplot ==1
                for idx_col = idx_begin:idx_end
                    XuPlotRectangle(center_coor,roi_size,'y');
                end
            end
        end
    end
    for idx = 1:round(length(data)/4)
        row_idx = data((idx-1)*4+1);col_idx =  data((idx-1)*4+2);
        idx_begin = (row_idx-1)*img_row_col_num(2)+col_idx;
        idx_end = (row_idx-1)*img_row_col_num(2)+col_idx;
        img_display_range = [ data((idx-1)*4+3)  data((idx-1)*4+4)];
        center_coor = center_coor_array((row_idx-1)*2+1:(row_idx)*2);
        roi_size = roi_size_array(row_idx);
        XuAddSubplotsRightDownVer2(img_3d(center_coor(2)-roi_size/2:center_coor(2)+roi_size/2,...
            center_coor(1)-roi_size/2:center_coor(1)+roi_size/2,idx_begin:idx_end),...
            [img_row_col_num(1),img_row_col_num(2)],zoom_img_ratio,img_display_range,[row_idx,col_idx],'y',position_adj_for_zoomed_img,text_portion);

    end
end




saveas(gcf,output_fig_name,'png')