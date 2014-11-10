function [arr, mu1, mu2, nonmissing_rows, column_picked_logical]=...
    preprocess_align_mat(arr, opt)
% USAGE:
% opt = logCount, CountPow075, logCountPow075, Freq, logFreq, FreqPow075
%       truncatele<int> or trunccol<int> can be appended to any of
%       them.
% First We pick the columns, store their indices in the
% column_picked_logical variable then process the rest of the file.

%% Helpful Lambdas
get_log =@(x) spfun(@log, x);
get_log1p =@(x) spfun(@log1p, x);
get_pow=@(x, p) x.^p;
get_freq=@(x) diag(sum(x,2).^-1)*x;
%% Parse Options
%% If the Options had truncatele or trunccol appended to them
[opt, column_picked_logical]=process_opt_and_get_column_logical(opt, ...
                                                  arr);
arr=arr(:, column_picked_logical);
%% Now that the columns to process have been fixed we would
%% do non-linear element-wise preprocessing.
disp(['Now opt is ', opt]);
powloc=strfind(opt, 'Pow');
if ~isempty(powloc)
    power=str2num(opt(powloc+3:powloc+5))*0.01;
    opt=opt(1:powloc+2);
    switch opt
      case 'CountPow'
        arr=get_pow(arr, power);
      case 'FreqPow'
        arr=get_pow(get_freq(arr), power);
      case 'logCountPow'
        arr=get_log(get_pow(arr, power));
      otherwise
        error(['Unknown opt: ' opt]);
    end
else
    switch opt
      case 'Count'
        1; %arr=arr; do do nothing
      case 'logCount'
        arr=get_log(arr);
      case 'Freq'
        arr=get_freq(arr);
      case 'logFreq'
        arr=get_log(get_freq(arr));
      case 'log1pFreq'
        arr=get_log1p(get_freq(arr));
      otherwise
        error(['Unknown opt: ' opt]);
    end
end
% Calculate mean while discarding rows that are completely zero.
assert(nnz(arr)>1);
nonmissing_rows=(sum(arr,2)~=0);
mu1=mean(arr(nonmissing_rows, :), 1);
mu2=mean(arr(nonmissing_rows, :), 2);
assert(any(isnan(mu1))~=1);
end

