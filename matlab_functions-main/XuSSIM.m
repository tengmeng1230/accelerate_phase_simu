function ssim = XuSSIM(img_0,img_1,c_1,c_2)
if nargin ==2
    c_1 = (0.01 * range(img_0(:)))^2;
    c_2 = (0.03 * range(img_0(:)))^2;
end

mu_0 = mean2(img_0);
mu_1 = mean2(img_1);
cov_matrix = cov(XuTallVector(img_0(:)),XuTallVector(img_1(:)));
ssim = (2*mu_0*mu_1+c_1)*(2*cov_matrix(1,2)+c_2)...
    /(mu_0^2+mu_1^2+c_1)/(cov_matrix(1,1)+cov_matrix(2,2)+c_2);
