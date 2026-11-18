function output = XuConvertPosVec(input)
output(2) = 1 - input(1);
output(1) = input(2);
output(3) = input(4);
output(4) = input(3);
end