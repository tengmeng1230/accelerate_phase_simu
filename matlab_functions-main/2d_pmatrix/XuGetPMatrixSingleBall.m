function [matrix_A, x_ball_sol, P] = XuGetPMatrixSingleBall(array_beta,u,v,L_u,L_v,sid,sdd)
views = length(array_beta);
matrix_left = [];vec_Y = [];
for idx = 1:views
    beta = array_beta(idx);
    vec_1 = [-cos(beta),-sin(beta),-1,0,0,0,u(idx)* cos(beta),u(idx)* sin(beta)];
    vec_2 = [0,0,0,-cos(beta),-sin(beta),-1,v(idx)* cos(beta),v(idx)* sin(beta)];
    matrix_left(2*idx-1,:) = vec_1;
    matrix_left(2*idx,:) = vec_2;
    vec_Y(2*idx-1) = -u(idx);vec_Y(2*idx) = -v(idx);
end

P = XuLeastSquareSolution(matrix_left,vec_Y);
P = [P;1];
P = reshape(P,[3,3]);
P = P'*sid/sdd;

matrix_left_1 = zeros(9,9);
matrix_left_1(1:3,1:3) = P';
matrix_left_1(4:6,4:5) = P(2:3,1:3)';
matrix_left_1(7:9,4) = - P(1,1:3)';
matrix_left_1(7:9,6) = P(3,1:3)';
matrix_left_1(1,7) = -1;
matrix_left_1(2,8) = 1;
matrix_left_1(4,8) = -1;
matrix_left_1(5,7) = -1;
matrix_left_1(9,9) = -1;

vec_Y = [0;0;-sid;-L_u*P(1,:)'; L_v*P(2,:)'];
vec_sol  = XuLeastSquareSolution(matrix_left_1,vec_Y);
matrix_A = [vec_sol(1:3)';L_u,vec_sol(4),vec_sol(5);-vec_sol(4),L_v,vec_sol(6)];
x_ball_sol = vec_sol(7:9);