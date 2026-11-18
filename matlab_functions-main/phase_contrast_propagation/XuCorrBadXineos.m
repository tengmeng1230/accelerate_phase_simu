function img = XuCorrBadXineos(img)
img(:,2303) = 1/3*img(:,2302) +2/3*img(:,2305);
img(:,2304) = 2/3*img(:,2302) +1/3*img(:,2305);


img(2945,:) = 1/3*img(2944,:)  +2/3*img(2947,:) ;
img(2946,:) = 2/3*img(2944,:)  +1/3*img(2947,:) ;

end