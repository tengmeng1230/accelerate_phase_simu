function output_vector = XuPolyValForOneInput(coeff, input_vector, order_cell)

if nargin == 2
    order_cell=cell(1,length(coeff));
    for idx = 1:length(coeff)
        order_cell{idx}= length(coeff)-idx;
    end
else
end

size_input_vector = size(input_vector);

input_vector = input_vector(:);

input_vector = XuTallVector(squeeze(input_vector));

coeff = XuTallVector(squeeze(coeff));


matrix_A = zeros(length(input_vector),length(order_cell));

for idx = 1:length(order_cell)
    temp_order = order_cell{idx};
    matrix_A(:,idx) = input_vector.^temp_order(1);
end

output_vector = matrix_A*coeff;
output_vector= reshape(output_vector,size_input_vector);
