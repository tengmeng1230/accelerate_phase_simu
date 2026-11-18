function [output,vec_kx,vec_ky,vec_kz] = Xufft3Ver2(input,vec_x,vec_y,vec_z,fft_or_ifft)
%input is the input 2D image
%fft_or_ifft: 1 for FFT and 0 for inverse FFT. 
%vec_x is the coordinate vector along the row direction
%share the same length of the width of the input 3D image
%vec_y is the coordinate vector along the colomn direction
%share the same length of the height of the input 3D image
%vec_z is the coordinate vector along the colomn direction
%share the same length of the thickness of the input 3D image

%Default value for kx0 and ky0 if there are 4 input arguments. 

length_input_x = size(input,1);%length of the input along row direction (x)
length_input_y = size(input,2);%length of the input along row direction (y)
length_input_z = size(input,3);%length of the input along row direction (z)
delta_x = vec_x(2) - vec_x(1);%spatial interval of the input data
delta_y = vec_y(2) - vec_y(1);%spatial interval of the input data
delta_z = vec_z(2) - vec_z(1);
kx0 = (1 - length_input_x)/2/(length_input_x * delta_x);
ky0 = (1 - length_input_y)/2/(length_input_y * delta_y);
kz0 = (1 - length_input_z)/2/(length_input_z * delta_z);

vec_x = XuTallVector(vec_x)';vec_y = XuTallVector(vec_y)';vec_z = XuTallVector(vec_z)';

[m_vec_x,m_vec_y,m_vec_z] = meshgrid(0:length_input_x-1,0:length_input_y-1,0:length_input_z-1);

if fft_or_ifft ==1
    % mudulation_vec = transpose(exp(-1i*2*pi*(0:length_input_x-1)*delta_x*kx0))...
    %     *exp(-1i*2*pi*(0:length_input_y-1)*delta_y*ky0)*exp(-1i*2*pi*(0:length_input_z-1)*delta_z*kz0);
    mudulation_vec =exp(-1i*2*pi*m_vec_x*delta_x*kx0).*...
         exp(-1i*2*pi*m_vec_y*delta_y*ky0).*exp(-1i*2*pi*m_vec_z*delta_z*kz0);
    input_modulated = input.*mudulation_vec;
    temp = fftn(input_modulated) * delta_x * delta_y * delta_z;
    %initialized fft value using the built-in function
elseif fft_or_ifft ==0
    % mudulation_vec = transpose(exp(1i*2*pi*(0:length_input_x-1)*delta_x*kx0))...
    %     *exp(1i*2*pi*(0:length_input_y-1)*delta_y*ky0)*exp(1i*2*pi*(0:length_input_z-1)*delta_z*kz0);
    mudulation_vec =exp(1i*2*pi*m_vec_x*delta_x*kx0).*...
         exp(1i*2*pi*m_vec_y*delta_y*ky0).*exp(1i*2*pi*m_vec_z*delta_z*kz0);
    input_modulated = input.*mudulation_vec;
    temp = ifftn(input_modulated) *length_input_x*length_input_y*length_input_z* delta_x * delta_y* delta_z ;
    %initialized fft value using the built-in function
end



vec_kx = 1/length_input_x(1)/delta_x*(0:length_input_x-1) + kx0;
vec_ky = 1/length_input_y(1)/delta_y*(0:length_input_y-1) + ky0;
vec_kz = 1/length_input_z(1)/delta_z*(0:length_input_z-1) + kz0;

[m_vec_kx,m_vec_ky,m_vec_kz] = meshgrid(vec_kx,vec_ky,vec_kz);

if fft_or_ifft ==1
    %output = temp.* (transpose(exp(-1i*2*pi*(vec_kx*vec_x(1))))*exp(-1i*2*pi*(vec_ky*vec_y(1))));
    output = temp.* exp(-1i*2*pi*(m_vec_kx*vec_x(1))).* exp(-1i*2*pi*(m_vec_ky*vec_y(1))).* exp(-1i*2*pi*(m_vec_kz*vec_z(1)));
elseif fft_or_ifft ==0
    %output = temp.* (transpose(exp(1i*2*pi*(vec_kx*vec_x(1))))*exp(1i*2*pi*(vec_ky*vec_y(1))));
    output = temp.* exp(1i*2*pi*(m_vec_kx*vec_x(1))).* exp(1i*2*pi*(m_vec_ky*vec_y(1))).* exp(1i*2*pi*(m_vec_kz*vec_z(1)));
end

%in matlab fft, x begins with zero.
%need to shift this x to vec_x(1); 
% in frequency domain, it is equivalent to multiplication of
% exp(-i*2*pi*vec_k*vec_x(1)). 
