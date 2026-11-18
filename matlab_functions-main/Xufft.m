function [output,vec_k] = Xufft(input,vec_x,fft_or_ifft)
%fft_or_ifft = 1 for fft; = 0 for ifft
if nargin == 2
    fft_or_ifft = 1; %fft
else
end

length_input = length(input);%length of the input
delta_x = vec_x(2) - vec_x(1);%spatial interval of the input data
if fft_or_ifft ==1
    temp = fft(input);%initialized fft value using the built-in function
elseif fft_or_ifft ==0
    temp = ifft(input)*length_input;%initialized fft value using the built-in function
end

if mod(length_input,2)==0%if the length is an even number
    vec_k = 1/length_input/delta_x*[-length_input/2+1:length_input/2];
    %for example, if length is 4, then [-1 0 1 2]

    output = circshift(temp,[0,length_input/2-1]);
    %in matlab fft, k begins with 0:[0 1 2 3 4].
    % need to shift this k by 4/2-1.
else
    vec_k = 1/length_input/delta_x*[-(length_input-1)/2:(length_input-1)/2];
    %for example, if length is 5, then [-2 -1 0 1 2]

    output = circshift(temp,[0,(length_input-1)/2]);
    %in matlab fft, k begins with 0:[0 1 2 3 4 5].
    % need to shift this k by (5-1)/2.

end
if fft_or_ifft ==1
    output = exp(-1i*2*pi*vec_k*vec_x(1)).*output* delta_x;
elseif fft_or_ifft ==0
    output = exp(1i*2*pi*vec_k*vec_x(1)).*output* delta_x;
end
%in matlab fft, x begins with zero.
%need to shift this x to vec_x(1);
% in frequency domain, it is equivalent to multiplication of
% exp(-i*2*pi*vec_k*vec_x(1)).
