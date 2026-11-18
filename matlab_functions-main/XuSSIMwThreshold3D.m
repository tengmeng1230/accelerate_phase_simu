function [val,std_val]= XuSSIMwThreshold3D(img,img_ref,dynamic_range,threshold)

for idx = 1:size(img,3)
    [val_temp,ssimmap] = ssim(img(:,:,idx),img_ref(:,:,idx),'DynamicRange',dynamic_range);
    ssimmap = ssimmap.*(img_ref(:,:,idx)>threshold);
    val(idx)= XuSum2(ssimmap)/XuSum2(img_ref(:,:,idx)>threshold);
end
std_val = std(val);
val = mean(val);
end