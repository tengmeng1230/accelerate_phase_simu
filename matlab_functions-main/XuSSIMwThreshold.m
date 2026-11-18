function val = XuSSIMwThreshold(img,img_ref,dynamic_range,threshold)

[val,ssimmap] = ssim(img,img_ref,'DynamicRange',dynamic_range,'Radius',1.5);
ssimmap = ssimmap.*(img_ref>threshold);
val = XuSum2(ssimmap)/XuSum2(img_ref>threshold);

end