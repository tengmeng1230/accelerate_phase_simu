function zq = XuInterp2NonGridWithIntermediateGrid (X,Y,Z,xq,yq)

X = XuTallVector(X(:));
Y = XuTallVector(Y(:));
Z = XuTallVector(Z(:));
temp_X = linspace(min(X)-0.1*(max(X)-min(X)),max(X)+0.1*(max(X)-min(X)),200);
temp_Y = linspace(min(Y)-0.1*(max(Y)-min(Y)),max(Y)+0.1*(max(Y)-min(Y)),200);
[m_temp_X,m_temp_Y] = meshgrid(temp_X,temp_Y);
m_temp_Z = XuInterp2NonGrid(X,Y,Z,m_temp_X,m_temp_Y);
zq = interp2(m_temp_X,m_temp_Y,m_temp_Z,xq,yq);
end