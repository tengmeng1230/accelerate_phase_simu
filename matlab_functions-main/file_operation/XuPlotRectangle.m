function output = XuPlotRectangle(center,size,color)
rectangle('Position',[center(1)-size/2,center(2)-size/2,size,size],'EdgeColor',color);
output = 1;
end