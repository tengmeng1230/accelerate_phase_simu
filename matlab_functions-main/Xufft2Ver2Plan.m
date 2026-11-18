function plan = Xufft2Ver2Plan(input_size,vec_x,vec_y,fft_or_ifft,kx0,ky0)
% Prepare the grid-dependent factors used by Xufft2Ver2.
nx = input_size(1);
ny = input_size(2);
if nargin == 4
    delta_x = vec_x(2) - vec_x(1);
    delta_y = vec_y(2) - vec_y(1);
    kx0 = (1-nx)/2/(nx*delta_x);
    ky0 = (1-ny)/2/(ny*delta_y);
end

vec_x = XuTallVector(vec_x)';
vec_y = XuTallVector(vec_y)';
delta_x = vec_x(2) - vec_x(1);
delta_y = vec_y(2) - vec_y(1);
vec_kx = 1/nx/delta_x*(0:nx-1) + kx0;
vec_ky = 1/ny/delta_y*(0:ny-1) + ky0;

if fft_or_ifft == 1
    phase_sign = -1i*2*pi;
elseif fft_or_ifft == 0
    phase_sign = 1i*2*pi;
else
    error('Transform direction must be 1 (FFT) or 0 (inverse FFT).');
end
plan.input_modulation = transpose(exp(phase_sign*(0:nx-1)*delta_x*kx0)) ...
    * exp(phase_sign*(0:ny-1)*delta_y*ky0);
plan.output_modulation = transpose(exp(phase_sign*(vec_kx*vec_x(1)))) ...
    * exp(phase_sign*(vec_ky*vec_y(1)));
plan.fft_or_ifft = fft_or_ifft;
plan.delta_x = delta_x;
plan.delta_y = delta_y;
plan.vec_kx = vec_kx;
plan.vec_ky = vec_ky;
end
