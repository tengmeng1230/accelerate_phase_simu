function output = XuMatrixToLatexTable(data,str_col_title,str_row_title,precison,data_std)

if nargin == 4
    data_std = [];
end

if length(str_col_title)~=size(data,2)
    error('length(str_col_title)!=size(data,2)!')
elseif length(str_row_title)~=size(data,1)
    error('length(str_row_title)!=size(data,2)!')
end

fprintf('\n\\toprule\n')
fprintf('&%s',str_col_title)
fprintf('\\\\\n \\midrule\n')
if isempty(data_std)
    for row_idx = 1:size(data,1)
        fprintf('%s',str_row_title(row_idx));
        for col_idx = 1:size(data,2)
            fprintf([' & $%.' num2str(precison(row_idx)) 'f$ '],...
                data(row_idx,col_idx));
        end
        fprintf('\\\\\n')
    end
else
    for row_idx = 1:size(data,1)
        fprintf('%s',str_row_title(row_idx));
        for col_idx = 1:size(data,2)
            fprintf([' & $%.' num2str(precison(row_idx)) 'f \\pm %.' num2str(precison(row_idx)) 'f$ '],...
                data(row_idx,col_idx),data_std(row_idx,col_idx));
        end
        fprintf('\\\\\n')
    end
end
fprintf('\\bottomrule\n')