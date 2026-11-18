function img_c = XuCropImg(img,roi)
[row_idx, col_idx] = find(roi>=1);
img_c = img(min(row_idx):max(row_idx),min(col_idx):max(col_idx),:);