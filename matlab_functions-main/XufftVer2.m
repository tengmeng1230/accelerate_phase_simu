function [output,vec_k] = XufftVer2(input,vec_x,fft_or_ifft,k0)
%XufftVer2(input,vec_x,k0,fft_or_ifft)

%fft_or_ifft = 1 for fft; = 0 for ifft
if nargin == 2
    fft_or_ifft = 1; %fft
    length_input = length(input);
    delta_x = vec_x(2) - vec_x(1);
    k0 = (1-length_input)/2/(length_input*delta_x);
elseif nargin == 3
    length_input = length(input);
    delta_x = vec_x(2) - vec_x(1);
    k0 = (1-length_input)/2/(length_input*delta_x);
end

input = XuTallVector(input)';%ensure that the vector is a row vector
vec_x = XuTallVector(vec_x)';%ensure that the vector is a row vector
length_input = length(input);%length of the input
delta_x = vec_x(2) - vec_x(1);%spatial interval of the input data


if fft_or_ifft ==1
    mudulation_vec = exp(-1i*2*pi*(0:length_input-1)*delta_x*k0);
    input_modulated = input.*mudulation_vec;
    temp = fft(input_modulated);%initialized fft value using the built-in function
elseif fft_or_ifft ==0
    mudulation_vec = exp(1i*2*pi*(0:length_input-1)*delta_x*k0);
    input_modulated = input.*mudulation_vec;
    temp = ifft(input_modulated)*length_input;%initialized ifft value using the built-in function
end

vec_k = 1/length_input/delta_x*(0:(length_input-1))+k0;

if fft_or_ifft ==1
    output = exp(-1i*2*pi*vec_k*vec_x(1)).*temp* delta_x;
elseif fft_or_ifft ==0
    output = exp(1i*2*pi*vec_k*vec_x(1)).*temp* delta_x;
end
%in matlab fft, x begins with zero.
%need to shift this x to vec_x(1);
% in frequency domain, it is equivalent to multiplication of
% exp(-i*2*pi*vec_k*vec_x(1)).
