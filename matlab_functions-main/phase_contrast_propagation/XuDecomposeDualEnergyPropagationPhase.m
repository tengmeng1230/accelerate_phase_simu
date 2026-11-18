function [basis_1,basis_2] = XuDecomposeDualEnergyPropagationPhase(img_l,img_h,mu_1,s_material_1,mu_2,s_material_2,dect_pixel_size,z_eff_1,z_eff_2)
%This version inputs the mu value and name of the material
%The program will find the delta values automatically
%mu is in mm^-1
en_simu = 10:100;
mu_1_for_interp = XuGetAtten(s_material_1,MgGetMaterialDensity(s_material_1),en_simu)/10;
delta_1 = XuGetDelta(s_material_1,interp1(mu_1_for_interp,en_simu,mu_1),MgGetMaterialDensity(s_material_1));

mu_2_for_interp = XuGetAtten(s_material_2,MgGetMaterialDensity(s_material_2),en_simu)/10;
delta_2= XuGetDelta(s_material_2,interp1(mu_2_for_interp,en_simu,mu_2),MgGetMaterialDensity(s_material_2));

[projection_pbi_1_fft,vec_fx_1,vec_fy_1,vec_fx_m1,vec_fy_m1] = XuImgfft2(img_l,dect_pixel_size);
[projection_pbi_2_fft,vec_fx_2,vec_fy_2,vec_fx_m2,vec_fy_m2] = XuImgfft2(img_h,dect_pixel_size);
basis_fft_1 = zeros('like',projection_pbi_1_fft);
basis_fft_2 = zeros('like',projection_pbi_1_fft);

for u_idx = 1:size(vec_fx_m1,1)
    for v_idx = 1:size(vec_fx_m2,2)
        f_x_temp = vec_fx_m1(u_idx,v_idx);
        f_y_temp = vec_fy_m1(u_idx,v_idx);
        p_1 = projection_pbi_1_fft(u_idx,v_idx,:);
        p_2 = projection_pbi_2_fft(u_idx,v_idx,:);
        matrix_A = [mu_1(1) + 4*pi^2 *z_eff_1*(f_y_temp^2 + f_x_temp^2)*delta_1(1),mu_2(1) + 4*pi^2 *z_eff_1*(f_y_temp^2 + f_x_temp^2)*delta_2(1)
            mu_1(2) + 4*pi^2 *z_eff_2*(f_y_temp^2 + f_x_temp^2)*delta_1(2),mu_2(2) + 4*pi^2 *z_eff_2*(f_y_temp^2 + f_x_temp^2)*delta_2(2)];
        %matrix_A = [mu_1(1) mu_2(1);mu_1(2) mu_2(2)];
        basis_temp = matrix_A^(-1) * [squeeze(p_1).';squeeze(p_2).'];
        basis_fft_1(u_idx,v_idx,:) = basis_temp(1,:);
        basis_fft_2(u_idx,v_idx,:) = basis_temp(2,:);
    end
end

basis_1 = real(Xufft2Ver2(basis_fft_1,vec_fx_1,vec_fy_1,0));
basis_2 = real(Xufft2Ver2(basis_fft_2,vec_fx_1,vec_fy_1,0));