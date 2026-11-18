function output = XuRMSE(img_1,img_ref)

img_1 = img_1(:);
img_ref = img_ref(:);
output = rms(img_1-img_ref);