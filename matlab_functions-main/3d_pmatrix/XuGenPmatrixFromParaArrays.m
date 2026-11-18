function pmatrix_array = XuGenPmatrixFromParaArrays(sid_array,sdd_array,...
    scan_angle_array,offcenter_u_array,offcenter_v_array,...
    detector_pixel_count,detector_pixel_count_z,delta_u,delta_v,swing_angle_arrray)
if nargin == 9
    swing_angle_arrray = zeros(size(sid_array));
else
end

view_num = length(sid_array);
pmatrix_array =[];
for view_idx = 1:view_num
    sid = sid_array(view_idx);
    sdd = sdd_array(view_idx);
    offcenter_u = offcenter_u_array(view_idx);
    offcenter_v = offcenter_v_array(view_idx);
    beta = scan_angle_array(view_idx);
    swing_angle = swing_angle_arrray(view_idx);


    x_s = [sid*cos(deg2rad(beta)),sid*sin(deg2rad(beta)),0];

    e_u = [x_s(2),-x_s(1),0];
    e_u = [cos(deg2rad(beta+swing_angle-90)),sin(deg2rad(beta+swing_angle-90)),0];
    e_u = [cos(deg2rad(swing_angle))*cos(deg2rad(beta-90)),cos(deg2rad(swing_angle))*sin(deg2rad(beta-90)),-sin(deg2rad(swing_angle))];


    %based on mgfbp and mgfpj convention
    %direction of eu is rotating x_s by 90 clockwise
    e_u = e_u/norm(e_u) * delta_u;%normalize e_u and multiply by its length

    e_v = [sin(deg2rad(swing_angle))*cos(deg2rad(beta-90)),sin(deg2rad(swing_angle))*sin(deg2rad(beta-90)) cos(deg2rad(swing_angle))]*delta_v;
    %based on mgfbp and mgfpj convention
    %direction of e_v is along the z axis

    center_of_det = [(sid-sdd)*cos(deg2rad(beta)),(sid-sdd)*sin(deg2rad(beta)),0] + offcenter_u*e_u/norm(e_u)+ offcenter_v*e_v/norm(e_v);

    x_do = center_of_det+(-detector_pixel_count/2+1/2)*e_u + (-detector_pixel_count_z/2+1/2)*e_v;

    matrix_A = [e_u',e_v', x_do' - x_s'];

    pmatrix = [matrix_A^(-1), -matrix_A^(-1)*x_s'];
    pmatrix = pmatrix';
    pmatrix_array = [pmatrix_array;pmatrix(:)];
end