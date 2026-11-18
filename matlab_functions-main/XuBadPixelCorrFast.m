function sgm_c = XuBadPixelCorrFast(sgm, mask)
    sgm_c = sgm;
    % 如果是三通道图像，就逐通道修复
    for c = 1:size(sgm, 3)
        sgm_c(:,:,c) = regionfill(sgm(:,:,c), mask);
    end
end