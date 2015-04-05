function [opt, column_picked_logical]= ...
    process_opt_and_get_column_logical(opt, arr)
opt_delimiter_idx=find(opt=='-');
num_opt=length(opt_delimiter_idx)+1;
assert(num_opt <= 2);
disp(['Now opt is ', opt]);
if num_opt == 2
    % Basically we remove all columns with sum less than the limit
    % prescribed in opt's second part
    opt2 = opt(opt_delimiter_idx+1:end);
    opt = opt(1:opt_delimiter_idx-1);
    disp(opt2);
    if strcmp(opt2(1:length('truncatele')), 'truncatele')
        trunc_lim=str2num(opt2(length('truncatele')+1:end));
        disp(['trunc_lim is ', num2str(trunc_lim)]);
        aa=sum(arr);
        %% Old Code : arr(:,find(aa < trunc_lim))=[];
        column_picked_logical=aa >= trunc_lim;
    elseif strcmp(opt2(1:length('trunccol')), 'trunccol')
        max_col=str2num(opt2(length('trunccol')+1:end));
        disp(['Max col = ', num2str(max_col)]);
        [~, sort_order]=sort(sum(arr), 'descend');
        column_picked_indices=sort_order(1:min(max_col, size(arr, 2)));
        column_picked_logical=ismember(1:size(arr,2), ...
                                       column_picked_indices);
    else
        error(['Unknown option ', opt]);
        exit(1);
    end
else
    column_picked_logical=logical(ones(1,size(arr,2)));
end

end