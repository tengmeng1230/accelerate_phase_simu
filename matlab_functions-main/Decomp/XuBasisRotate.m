function [img_1p,img_2p] = XuBasisRotate(img_1,img_2,V)
temp_matrix = [img_1(:)';img_2(:)'];
temp_matrix = V*temp_matrix;

img_1p = reshape( temp_matrix(1,:),size(img_1));
img_2p = reshape( temp_matrix(2,:),size(img_1));