function partial_derivative = XuGetDerivative(img,veritial_or_horizontal,delta_x)

if nargin ==2
    delta_x = 1;
end

if strcmp(veritial_or_horizontal,'v')
    img = img';
end
partial_derivative = zeros(size(img));
for idx = 2:size(img,2)-1
    partial_derivative(:,idx) = (img(:,idx+1) - img(:,idx-1))/2/delta_x;
end

if strcmp(veritial_or_horizontal,'v')
    partial_derivative = partial_derivative';
end