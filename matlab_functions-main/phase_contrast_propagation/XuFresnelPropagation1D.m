function img_z = XuFresnelPropagation1D(img_z_0,vec_x,z,lambda)
[img_z_0_fft,vec_fx]= XufftVer2(img_z_0,vec_x,1);
propagation_kernel = exp(2*pi*1i *z* sqrt(1/(lambda^2) -vec_fx.^2));
img_z_fft = img_z_0_fft.*propagation_kernel;
img_z= XufftVer2(img_z_fft,vec_fx,0);