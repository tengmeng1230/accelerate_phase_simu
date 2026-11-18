function [NPS2D,frequency]=Xu2DNPSVer2(Roi,DeltaX,offset)

if nargin==2
    offset =0;
else
end
Roi = Roi+offset;
RoiSize=size(Roi,1);
Zdim = size(Roi,3);
roi_mean = mean(mean(mean(Roi)));

Roi = Roi./mean(Roi,3)*roi_mean;



NPS2D=zeros(RoiSize,RoiSize);
for fidx=1:Zdim
    [NPS_temp,kx,ky] = Xufft2(Roi(:,:,fidx),(1:RoiSize)*DeltaX,(1:RoiSize)*DeltaX);
    NPS_temp = (NPS_temp).*conj(NPS_temp);
    NPS2D = NPS2D+NPS_temp;
end

NPS2D=NPS2D/(Zdim-1)/DeltaX^2/RoiSize^2;

frequency = kx;

