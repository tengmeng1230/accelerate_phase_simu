function [basis_1,basis_2] = XuDecomposeDualEnergyPropagationPhaseCTF(img_l,img_h,en_1,en_2,mu_1,delta_1,mu_2,delta_2,dect_pixel_size,z_eff_1,z_eff_2)
%This version inputs the mu value and delta value of the materials
%This is because for real systems, for a good decomposition, mu and delta
%may correspond to different energies

[projection_pbi_1_fft,vec_fx_1,vec_fy_1,vec_fx_m1,vec_fy_m1] = XuImgfft2(img_l,dect_pixel_size);
[projection_pbi_2_fft,vec_fx_2,vec_fy_2,vec_fx_m2,vec_fy_m2] = XuImgfft2(img_h,dect_pixel_size);
basis_fft_1 = zeros('like',projection_pbi_1_fft);
basis_fft_2 = zeros('like',projection_pbi_1_fft);
inv_A_rec_21 = zeros('like',vec_fx_m2);
inv_A_rec_22 = zeros('like',vec_fx_m2);
lambda_1 = XuEnergyToLambda(en_1);
lambda_2 = XuEnergyToLambda(en_2);
for u_idx = 1:size(vec_fx_m1,1)
    for v_idx = 1:size(vec_fx_m2,2)
        f_x_temp = vec_fx_m1(u_idx,v_idx);
        f_y_temp = vec_fy_m1(u_idx,v_idx);
        f_square = f_y_temp^2 + f_x_temp^2;
        theta_1 = pi * lambda_1 * z_eff_1 * f_square;
        theta_2 = pi * lambda_2 * z_eff_2 * f_square;
        p_1 = projection_pbi_1_fft(u_idx,v_idx,:);
        p_2 = projection_pbi_2_fft(u_idx,v_idx,:);
        matrix_A = [mu_1(1)*cos(theta_1) + 4*pi/lambda_1 *delta_1(1)*sin(theta_1),mu_2(1)*cos(theta_1) + 4*pi/lambda_1 *delta_2(1)*sin(theta_1)
            mu_1(2)*cos(theta_2) + 4*pi/lambda_2 *delta_1(2)*sin(theta_2),mu_2(2)*cos(theta_2) + 4*pi/lambda_2 *delta_2(2)*sin(theta_2)];
        
        % matrix_A = [mu_1(1) + 4*pi^2 *z_eff_1*(f_y_temp^2 + f_x_temp^2)*delta_1(1),mu_2(1) + 4*pi^2 *z_eff_1*(f_y_temp^2 + f_x_temp^2)*delta_2(1)
        %     mu_1(2) + 4*pi^2 *z_eff_2*(f_y_temp^2 + f_x_temp^2)*delta_1(2),mu_2(2) + 4*pi^2 *z_eff_2*(f_y_temp^2 + f_x_temp^2)*delta_2(2)];
        basis_temp = (matrix_A'*matrix_A )^(-1)*(matrix_A'*[squeeze(p_1).';squeeze(p_2).'] );

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