function kernel = XuPropagationKernel(fx,fy,z,lambda)
% Keep the same subtraction order as the original angular-spectrum kernel.
kernel = exp(2*pi*1i*z*sqrt(1/(lambda^2) - fx(:).^2 - fy(:).'.^2));
end
