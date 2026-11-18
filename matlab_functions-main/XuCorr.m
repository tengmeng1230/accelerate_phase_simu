function output = XuCorr(A,B)

A = A(:);
B = B(:);
A = XuTallVector(A);
B = XuTallVector(B);
output = corr(A,B);
output = output(1,1);