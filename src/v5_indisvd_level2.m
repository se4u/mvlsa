function [ajtj, kj_diag, aj, sj] = v5_indisvd_level2(...
    align_mat, mc_muc, preprocess_option, svd_size, r, outfile)
%% Some helpful lambdas
regularized_proj=@(x, r) x*inv(x'*x+r*eye(size(x,2)))*x';
sparse_diag_mat=@(s) spdiags(diag(s), 0, length(s), length(s));

%% First do the SVD of the align_mat file
[aj, sj, ~, kj_diag]=v5_indisvd(align_mat, mc_muc, preprocess_option,svd_size);

%% Then do compute ajtj that are needed, with regularization
tj=sqrt(regularized_proj(sparse_diag_mat(sj), r))
ajtj=aj*tj;
end