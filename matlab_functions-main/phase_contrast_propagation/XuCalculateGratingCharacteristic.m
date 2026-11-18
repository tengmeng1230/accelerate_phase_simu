function A_s = XuCalculateGratingCharacteristic(f_g,vec_x,s_vec,gamma,p)
A_s = s_vec;
for idx = 1:length(s_vec)
    s = s_vec(idx);
    shift_dis = (gamma - floor(gamma))*p;
    f_g_shift = interp1(vec_x,f_g,vec_x+shift_dis,'linear',0);
    A_s(idx)= exp(-1i*pi*s*gamma).*sum(conj(f_g_shift).*f_g.*exp(-1i*2*pi*s*vec_x/p))*(vec_x(2)-vec_x(1))/range(vec_x);
end
