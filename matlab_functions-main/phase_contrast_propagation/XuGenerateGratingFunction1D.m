function f_g = XuGenerateGratingFunction1D(vec_x,p,c,t_b,phi_b,t_s,phi_s)
%c is the duty cycle of bar
bar_section = (mod(vec_x,p)<c*p);
slit_section = (mod(vec_x,p)>=c*p);
f_g = bar_section*t_b*exp(1i*phi_b)+slit_section*t_s*exp(1i*phi_s);

end