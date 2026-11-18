function coeff = XuPolyFitForTwoInputs(input_vector_1,input_vector_2, output_vector, order_cell)

input_vector_1 = XuTallVector(squeeze(input_vector_1));
input_vector_2 = XuTallVector(squeeze(input_vector_2));
output_vector = XuTallVector(squeeze(output_vector));


matrix_A = zeros(length(input_vector_1),length(order_cell));

for idx = 1:length(order_cell)
    temp_order = order_cell{idx};
    matrix_A(:,idx) = input_vector_1.^temp_order(1).*input_vector_2.^temp_order(2);
end

coeff = XuLeastSquareSolution(matrix_A, output_vector);