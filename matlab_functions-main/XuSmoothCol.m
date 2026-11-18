function output = XuSmoothCol(input,span)
output = input; 
for idx = 1:size(input,1)
    output(idx,:) = smooth(input(idx,:),span);

end