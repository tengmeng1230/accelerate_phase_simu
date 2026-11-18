function [basis_1,basis_2] = XuDecomposeDualEnergyPropagationPhaseV2(img_l,img_h,mu_1,delta_1,mu_2,delta_2,dect_pixel_size,z_eff_1,z_eff_2)
%This version inputs the mu value and delta value of the materials
%This is because for real systems, for a good decomposition, mu and delta
%may correspond to different energies

[projection_pbi_1_fft,vec_fx_1,vec_fy_1,vec_fx_m1,vec_fy_m1] = XuImgfft2(img_l,dect_pixel_size);
[projection_pbi_2_fft,vec_fx_2,vec_fy_2,vec_fx_m2,vec_fy_m2] = XuImgfft2(img_h,dect_pixel_size);
basis_fft_1 = zeros('like',projection_pbi_1_fft);
basis_fft_2 = zeros('like',projection_pbi_1_fft);
inv_A_rec_21 = zeros('like',vec_fx_m2);
inv_A_rec_22 = zeros('like',vec_fx_m2);

for u_idx = 1:size(vec_fx_m1,1)
    for v_idx = 1:size(vec_fx_m2,2)
        f_x_temp = vec_fx_m1(u_idx,v_idx);
        f_y_temp = vec_fy_m1(u_idx,v_idx);
        p_1 = projection_pbi_1_fft(u_idx,v_idx,:);
        p_2 = projection_pbi_2_fft(u_idx,v_idx,:);
        matrix_A = [mu_1(1) + 4*pi^2 *z_eff_1*(f_y_temp^2 + f_x_temp^2)*delta_1(1),mu_2(1) + 4*pi^2 *z_eff_1*(f_y_temp^2 + f_x_temp^2)*delta_2(1)
            mu_1(2) + 4*pi^2 *z_eff_2*(f_y_temp^2 + f_x_temp^2)*delta_1(2),mu_2(2) + 4*pi^2 *z_eff_2*(f_y_temp^2 + f_x_temp^2)*delta_2(2)];
        
        matrix_A_ab = [mu_1(1) mu_2(1);mu_1(2) mu_2(2)];

        

        
        
        % inv_A_rec_11(u_idx,v_idx) = inv_A(1,1);
        % inv_A_rec_12(u_idx,v_idx) = inv_A(1,2);
        % inv_A_rec_21(u_idx,v_idx) = inv_A(2,1);
        % inv_A_rec_22(u_idx,v_idx) = inv_A(2,2);
        
        
        

        basis_temp_0 = matrix_A_ab^(-1) * [squeeze(p_1).';squeeze(p_2).'];
        lambda = 0;
        basis_temp = (matrix_A'*matrix_A + lambda * eye(2))^(-1)*(matrix_A'*[squeeze(p_1).';squeeze(p_2).'] + lambda *basis_temp_0);

        basis_fft_1(u_idx,v_idx,:) = basis_temp(1,:);
        basis_fft_2(u_idx,v_idx,:) = basis_temp(2,:);
    end
end
% figure();
% [data,k] = MgRadialAverage(inv_A_rec_21,vec_fx_2(2) - vec_fx_2(1));
% plot(k,abs(data));
% figure();
% [data,k]=MgRadialAverage(inv_A_rec_22,vec_fx_2(2) - vec_fx_2(1));
% plot(k,abs(data));
basis_1 = real(Xufft2Ver2(basis_fft_1,vec_fx_1,vec_fy_1,0));
basis_2 = real(Xufft2Ver2(basis_fft_2,vec_fx_1,vec_fy_1,0));