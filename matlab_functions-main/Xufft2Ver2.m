function [output,vec_kx,vec_ky] = Xufft2Ver2(input,vec_x,vec_y,fft_or_ifft,kx0,ky0)
% Transform a 2-D image on the given coordinate grid, or reuse a prepared plan.
if nargin == 2
    plan = vec_x;
elseif nargin == 4
    plan = Xufft2Ver2Plan(size(input),vec_x,vec_y,fft_or_ifft);
else
    plan = Xufft2Ver2Plan(size(input),vec_x,vec_y,fft_or_ifft,kx0,ky0);
end

input_modulated = input.*plan.input_modulation;
if plan.fft_or_ifft == 1
    temp = fft2(input_modulated) * plan.delta_x * plan.delta_y;
else
    temp = ifft2(input_modulated) * size(input,1) * size(input,2) * plan.delta_x * plan.delta_y;
end
output = temp.*plan.output_modulation;
vec_kx = plan.vec_kx;
vec_ky = plan.vec_ky;
end
