function [ajtj, kj_diag, aj, sj, column_picked_logical, bj, mu1, mu2, sum2] = v5_indisvd_level2(...
    align_mat, mc_muc, preprocess_option, svd_size, r, outfile)
%% First do the SVD of the align_mat file
[aj, sj, mu1, kj_diag, column_picked_logical, bj, mu2, sum2]=...
    v5_indisvd(align_mat, mc_muc, preprocess_option,svd_size);

%% Then do compute ajtj that are needed, with regularization
tj=sqrt(regularized_proj(sparse_diag_mat(sj), r));
ajtj=aj*tj;
end

function [a, s, mu1, nonmissing_rows, column_picked_logical, b, mu2, sum2]=...
    v5_indisvd(align_mat, mc_muc, preprocess_option, svd_size)
% Preprocess data and show that its size did not change.
disp(size(align_mat));
[align_mat, mu1, mu2, nonmissing_rows, column_picked_logical, sum2]=...
    preprocess_align_mat(align_mat, preprocess_option);
disp(size(align_mat));
disp('preprocessing complete');
if strcmp(mc_muc, 'mc')
    [a, s, b]=svds(align_mat, svd_size);
    [a, s, b]=rank_one_svd_update(a, s, b, ...
                                  -1*ones(size(align_mat,1), 1), ...
                                  mu1', ...
                                  0);
    s=transpose(diag(s));
else
    % Just make these false [a,s,b] so that we can atleast store
    % the results of the preprocessing code.
    a=[0];
    s=[0];
    b=[0];
end
end


function [arr, mu1, mu2, nonmissing_rows, column_picked_logical, sum2]=...
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

%% Calculate statistics that can later be used to estimate how
%% over-powering or noisy this word or context was ?
sum1 = sum(arr,1);
sum2 = sum(arr,2);
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
mu2=mean(arr, 2);
assert(any(isnan(mu1))~=1);
end