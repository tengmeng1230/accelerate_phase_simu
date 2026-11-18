function [output,vec_kx,vec_ky] = Xufft2(input,vec_x,vec_y,fft_or_ifft)
%fft_or_ifft = 1 for fft; = 0 for ifft
if nargin == 3
    fft_or_ifft = 1; %fft
else
end

size_input = size(input,1);%length of the input
delta_x = vec_x(2) - vec_x(1);%spatial interval of the input data
delta_y = vec_y(2) - vec_y(1);%spatial interval of the input data

if fft_or_ifft ==1
    temp = fft2(input) * delta_x * delta_y ;%initialized fft value using the built-in function
elseif fft_or_ifft ==0
    temp = ifft2(input) * size_input^2 * delta_x * delta_y ;%initialized fft value using the built-in function
end


if mod(size_input(1),2)==0%if the length is an even number

    vec_kx = 1/size_input(1)/delta_x*[-size_input(1)/2+1:size_input(1)/2];
    vec_ky = 1/size_input(1)/delta_y*[-size_input(1)/2+1:size_input(1)/2];
    %for example, if length is 4, then [-1 0 1 2]

    output = circshift(temp,[size_input(1)/2-1,size_input(1)/2-1]);
    %in matlab fft, k begins with 0:[0 1 2 3 4]. 
    % need to shift this k by 4/2-1. 
else
    vec_kx = 1/size_input(1)/delta_x*[-(size_input(1)-1)/2:(size_input(1)-1)/2];
    vec_ky = 1/size_input(1)/delta_y*[-(size_input(1)-1)/2:(size_input(1)-1)/2];
    %for example, if length is 5, then [-2 -1 0 1 2]

    output = circshift(temp,[(size_input(1)-1)/2,(size_input(1)-1)/2]);
    %in matlab fft, k begins with 0:[0 1 2 3 4 5]. 
    % need to shift this k by (5-1)/2. 

end

[m_vec_kx, m_vec_ky] = meshgrid(vec_kx,vec_ky);
if fft_or_ifft ==1
    output = exp(-1i*2*pi*(m_vec_kx*vec_x(1) + m_vec_ky*vec_y(1))).*output;
elseif fft_or_ifft ==0
    output = exp(1i*2*pi*(m_vec_kx*vec_x(1) + m_vec_ky*vec_y(1))).*output;
end
%in matlab fft, x begins with zero.
%need to shift this x to vec_x(1); 
% in frequency domain, it is equivalent to multiplication of
% exp(-i*2*pi*vec_k*vec_x(1)). 

if fft_or_ifft ==1
    output = output.* (exp(-1i*2*pi*(vec_kx*vec_x(1)))'*exp(-1i*2*pi*(vec_ky*vec_y(1))));
elseif fft_or_ifft ==0
    output = output.* exp(1i*2*pi*(vec_kx*vec_x(1)))'.*exp(1i*2*pi*(vec_ky*vec_y(1)));
end
