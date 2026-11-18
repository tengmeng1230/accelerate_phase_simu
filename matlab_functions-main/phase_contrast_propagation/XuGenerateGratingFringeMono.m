function [component_zero_f,component_first_f] = XuGenerateGratingFringeMono(vec_x,f_g0,p0,f_g1,p1,source_func,d0,d1,d2,lambda)
[source_func_fft,vec_fx] = XufftVer2(source_func,vec_x,1);
source_func_fft = source_func_fft/max(abs(source_func_fft));
dT = d0+d1+d2;
for s = -1:1
    for t = -s
        one_over_pf = s*1/(p0)*d0/dT + t*(d0+d1)/p1/dT;
        pf = 1/one_over_pf;  %pf is related to s


        one_over_ps = s*1/(p0)*(d1+d2)/dT + t*(d2)/p1/dT;
        %ps = 1/one_over_ps;

        gamma_0 = lambda*d0/p0*one_over_ps;
        gamma_1 = lambda*d2/p1*one_over_pf;

        A_st = XuCalculateGratingCharacteristic(f_g0,vec_x,s,gamma_0,p0);
        B_st = XuCalculateGratingCharacteristic(f_g1,vec_x,t,gamma_1,p1);
        I_f_p_s = abs(interp1(vec_fx,source_func_fft,-one_over_ps,'linear',0));
        if s==1 && t == -1
            component_first_f = 2*abs(A_st)*abs(B_st)*I_f_p_s;
        end
        if s==0 && t == 0
            component_zero_f = abs(A_st)*abs(B_st);
        end
        %temp = temp+A_st*B_st * exp(1i*2*pi*vec_x/pf)*I_f_p_s*spec(en_idx);
    end
end