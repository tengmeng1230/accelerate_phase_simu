function  [img_1p,img_2p] = XuDecomposeDenoiseVer2(img_l,img_h,roi_map,mu_1,mu_2,eta,lambda,save_folder)
%img_l img_h are the input dual energy CT images (in mu)
%roi_map is the roi for std measurement
%mu_1, mu_2 are mu values for basis materials under low and high energy
%eta defines the filter pixel radius
%lambda defines the sigma ratio for ib1 image
%save folder defines the folder to save the files

sigma_vec = [std(img_l(roi_map>0)),std(img_h(roi_map>0))];
decompose_matrix = [XuTallVector(mu_1),XuTallVector(mu_2)]^(-1);
A = decompose_matrix*diag(sigma_vec);
[U,~,~] = svd(A);
[img_1,img_2] = XuDecomposeDualEnergy(img_l,img_h,mu_1,mu_2);
[img_b2, img_b1] = XuBasisRotate(img_1,img_2,U');
MgMkdir(save_folder);
XuWriteRaw([save_folder '/img_b1'],img_b1);
XuWriteRaw([save_folder '/img_b2'],img_b2);
sigma_ib1 = std(img_b1(roi_map>0));

[mx,my] = meshgrid(1:512,1:512);
pixel_scope = 2*eta;
img_b2_denoise = zeros(512,512);
for row_index = pixel_scope+1:512-pixel_scope-1
    for col_index = pixel_scope+1:512-pixel_scope-1
        roi_row_idx = row_index - pixel_scope:row_index+pixel_scope;
        roi_col_idx = col_index - pixel_scope:col_index+pixel_scope;
        my_roi = my(roi_row_idx,roi_col_idx);
        mx_roi = mx(roi_row_idx,roi_col_idx);

        w_d = exp(-((my_roi-row_index).^2+(mx_roi-col_index).^2)/(pixel_scope/2)^2).*...
            (((my_roi-row_index).^2+(mx_roi-col_index).^2)<pixel_scope^2);

        ib1_val = img_b1(row_index,col_index);
        ib1_roi = img_b1(roi_row_idx,roi_col_idx);
        ib2_roi = img_b2(roi_row_idx,roi_col_idx);

        w_ib1 = exp(-(ib1_roi-ib1_val).^2/(lambda*sigma_ib1)^2).*(abs(ib1_roi-ib1_val)<6*lambda*sigma_ib1);
        w_total = w_d.*w_ib1;
        img_b2_denoise(row_index,col_index)= XuSum2(ib2_roi.*w_total)/XuSum2(w_total);
    end
end

XuWriteRaw([save_folder '/img_b2dn'],img_b2_denoise);

[img_1p,img_2p] = XuBasisRotate(img_b2_denoise,img_b1,U);
XuWriteRaw([save_folder '/img_1.raw'],img_1);
XuWriteRaw([save_folder '/img_2.raw'],img_2);
XuWriteRaw([save_folder '/img_1_dn.raw'],img_1p);
XuWriteRaw([save_folder '/img_2_dn.raw'],img_2p);