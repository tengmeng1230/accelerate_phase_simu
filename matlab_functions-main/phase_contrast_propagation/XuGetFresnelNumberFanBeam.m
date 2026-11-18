function discrete_fresnel_number = XuGetFresnelNumberFanBeam(en_simu,R_1,R_2,fs_size,pixel_size)

lambda = 1.24e-6 / en_simu;
R_effective = R_2*R_1 / (R_1 + R_2);
mag = (R_2+R_1)/(R_1);
fs_size_eff = fs_size*(mag-1)/mag;
pixel_size_eff = pixel_size/mag;
discrete_fresnel_number = (fs_size_eff^2 + pixel_size_eff^2)/(lambda * R_effective);