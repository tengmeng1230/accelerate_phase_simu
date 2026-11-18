function zq = XuInterp2NonGrid (X,Y,Z,xq,yq)
size_xq = size(xq); % get size of the points to be interpolated
xq = xq(:);
yq = yq(:);
zq = zeros(size_xq);
X = XuTallVector(X(:));
Y = XuTallVector(Y(:));
Z = XuTallVector(Z(:));
pb = MgCmdLineProgressBar('Processing progress:');
for xq_idx = 1:length(xq)

    if (mod(xq_idx,round(length(xq)/100))==0)
        pb.print(round(xq_idx/length(xq)*100),100);
    end
    r = sqrt((xq(xq_idx)-X).^2 + (yq(xq_idx)-Y).^2);
    %calculate the distance between the position to be interpolated and the
    %positin of the reference points

    r = XuTallVector(r);
    temp_table = [r,X,Y,Z];
    temp_table = sortrows(temp_table,1);

    
    coefs = XuLeastSquareSolution([temp_table(1:4,2:3),ones(4,1)],temp_table(1:4,4));
    zq(xq_idx) = [xq(xq_idx),yq(xq_idx),1]*coefs;
end
end