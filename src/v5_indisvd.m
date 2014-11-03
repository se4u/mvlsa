function [a, s, mu1, nonmissing_rows]=v5_indisvd(align_mat, mc_muc, preprocess_option, svd_size)
% Preprocess data and show that its size did not change.
disp(size(align_mat));
[align_mat, mu1, ~, nonmissing_rows]=preprocess_align_mat(align_mat, ...
                                           preprocess_option);
disp(size(align_mat));
disp('preprocessing complete');
% Now 
if strcmp(mc_muc, 'muc')
    [a, s]=svds(align_mat, svd_size);
    s=transpose(diag(s));
elseif strcmp(mc_muc, 'mc')
    [a, s, b]=svds(align_mat, svd_size);
    [a, s, b]=rank_one_svd_update(a, s, b, ...
                                  -1*ones(size(align_mat,1), 1), ...
                                  mu1', ...
                                  0);
    s=transpose(diag(s));
else
    error(['Wrong mc_muc option: ' mc_muc]);
end