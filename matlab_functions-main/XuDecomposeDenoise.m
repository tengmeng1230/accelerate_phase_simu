function  [img_1p,img_2p] = XuDecomposeDenoise(img_1,img_2,sigma_vec,sigma_ib1,decompose_matrix,eta,save_folder)



rec_w = img_1;
rec_i =img_2;

A = decompose_matrix*diag(sigma_vec);

[U S V] = svd(A);

[img_b2, img_b1] = XuBasisRotate(img_1,img_2,U');

if nargin == 6
elseif nargin == 7
    XuWriteRaw([save_folder '/img_b1'],img_b1);
    XuWriteRaw([save_folder '/img_b2'],img_b2);
end




img_h = img_b2;
img_l = img_b1;

[mx my] = meshgrid(1:512,1:512);
pixel_scope = 2*eta;
img_h_denoise = zeros(512,512);
p = MgCmdLineProgressBar('Processing...\n');
for row_index = pixel_scope+1:512-pixel_scope-1
    %p.print(row_index,512);
    for col_index = pixel_scope+1:512-pixel_scope-1
        roi_row_idx = row_index - pixel_scope:row_index+pixel_scope;
        roi_col_idx = col_index - pixel_scope:col_index+pixel_scope;
        my_roi = my(roi_row_idx,roi_col_idx);
        mx_roi = mx(roi_row_idx,roi_col_idx);

        w_d = exp(-((my_roi-row_index).^2+(mx_roi-col_index).^2)/(pixel_scope/2)^2).*...
            (((my_roi-row_index).^2+(mx_roi-col_index).^2)<pixel_scope^2);

        ib1_val = img_l(row_index,col_index);
        ib1_roi = img_l(roi_row_idx,roi_col_idx);
        ib2_roi = img_h(roi_row_idx,roi_col_idx);

        w_ib1 = exp(-(ib1_roi-ib1_val).^2/sigma_ib1^2).*(abs(ib1_roi-ib1_val)<6*sigma_ib1);
        w_total = w_d.*w_ib1;


        img_h_denoise(row_index,col_index)= XuSum2(ib2_roi.*w_total)/XuSum2(w_total);
    end
end
if nargin == 6
elseif nargin == 7
    XuWriteRaw([save_folder '/img_b2dn'],img_h_denoise);
end
[img_1p,img_2p] = XuBasisRotate(img_h_denoise,img_l,U);
