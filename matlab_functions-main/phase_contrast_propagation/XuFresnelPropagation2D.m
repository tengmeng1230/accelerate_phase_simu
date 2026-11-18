function img_z = XuFresnelPropagation2D(img_z_0,vec_x,vec_y,z,lambda)
[img_z_0_fft,vec_fx,vec_fy]= Xufft2Ver2(img_z_0,vec_x,vec_y,1);
propagation_kernel = XuPropagationKernel(vec_fx,vec_fy,z,lambda);


%imshow(real(propagation_kernel),[])
img_z_fft = img_z_0_fft.*propagation_kernel;
img_z= Xufft2Ver2(img_z_fft,vec_fx,vec_fy,0);
end
