function p_vec = XuGetPmatrixVec(x_s,x_d,e_u,e_v,detector_pixel_count,detector_pixel_count_z)
%x_d is the position of the center of detector
x_do = x_d+(-detector_pixel_count/2+1/2)*e_u + (-detector_pixel_count_z/2+1/2)*e_v;
matrix_A = [XuTallVector(e_u),XuTallVector(e_v), XuTallVector(x_do)-XuTallVector(x_s)];
pmatrix = [matrix_A^(-1), -matrix_A^(-1)*XuTallVector(x_s)];
pmatrix = pmatrix';
p_vec = pmatrix(:);