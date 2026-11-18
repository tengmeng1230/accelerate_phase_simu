function b = XuBarPlotWErrorBar(data,data_std,xticklabel,num_col_w_error)
if nargin == 3
    num_col_w_error = size(data,2)-1;
end

% data = 10*randn([3,5]); %three groups of data, each group has 5 categories
% data_std = ones(3,5)*0.5; %std has the same size with data
% xticklabel = {'10 mg/mL','20 mg/mL','30 mg/mL'};%should have 3 groups

group_num = size(data,1);
type_num = size(data,2);

data = data';data_std= data_std';

x = 1:length(data(:));
x = reshape(x,[type_num, group_num]);
x = x + (0:group_num-1);

b = bar(x(:),data(:));hold on;
errorbar(x(1:num_col_w_error,:),data(1:num_col_w_error,:),data_std(1:num_col_w_error,:),'k.');
hold off;

set(gca,'xtick',mean(x,1));
set(gca,'xticklabel',xticklabel);
grid on;

b.FaceColor = 'flat';
for idx = 1:length(data(:))
    switch mod(idx,type_num)
        case 1
            b.CData(idx,:)= [0 0.4470 0.7410];
        case 2
            b.CData(idx,:)= [0.8500 0.3250 0.0980];
        case 3 
            b.CData(idx,:)= [0.9290 0.6940 0.1250];
        case 4
            b.CData(idx,:)= [0.4940 0.1840 0.5560];
        case 5
            b.CData(idx,:)= [0.4660 0.6740 0.1880];
        case 6
            b.CData(idx,:)= [0.3010 0.7450 0.9330];
        case 0
            b.CData(idx,:)= [0.6350 0.0780 0.1840];
    end
end
