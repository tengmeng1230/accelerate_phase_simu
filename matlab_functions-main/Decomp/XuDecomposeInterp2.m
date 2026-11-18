function [sgm_material_1,sgm_material_2] = XuDecomposeInterp2(atten_1,atten_2,m1,m2,sgm_1,sgm_2,vec_1,vec_2)
vec_1 = vec_1/norm(vec_1);
vec_2 = vec_2/norm(vec_2);

%change the base vector of input atten
temp = [vec_1',vec_2']^(-1)*[atten_1(:)';atten_2(:)'];

%change the base vector of input atten
sgm_temp = [vec_1',vec_2']^(-1)*[sgm_1(:)';sgm_2(:)'];
scatter(temp(1,:),temp(2,:),'.')
axis equal
sgm_material_1 =  XuInterp2NonGridWithIntermediateGrid(temp(1,:),temp(2,:),m1(:),sgm_temp(1,:),sgm_temp(2,:));
sgm_material_1 = reshape(sgm_material_1,size(sgm_1));
sgm_material_2 =  XuInterp2NonGridWithIntermediateGrid(temp(1,:),temp(2,:),m2(:),sgm_temp(1,:),sgm_temp(2,:));
sgm_material_2 = reshape(sgm_material_2,size(sgm_2));