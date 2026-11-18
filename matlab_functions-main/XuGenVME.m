function img = XuGenVME(img_1,s_1,density_1,img_2,s_2,density_2,energy,HU_or_not)

mu_1 = XuGetAtten(s_1,density_1,energy)/10;
mu_2 = XuGetAtten(s_2,density_2,energy)/10;

img = mu_2*img_2+img_1*mu_1;



if HU_or_not
    mu_water = XuGetAtten('water',1,energy)/10;
    img = XuMuToHU(img,mu_water);
end


