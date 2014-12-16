function [ajtj, kj_diag, aj, sj, column_picked_logical, bj, mu1, mu2, sum2] = v5_indisvd_level2(...
    align_mat, mc_muc, preprocess_option, svd_size, r, outfile)
%% First do the SVD of the align_mat file
[aj, sj, mu1, kj_diag, column_picked_logical, bj, mu2, sum2]=...
    v5_indisvd(align_mat, mc_muc, preprocess_option,svd_size);

%% Then do compute ajtj that are needed, with regularization
tj=sqrt(regularized_proj(sparse_diag_mat(sj), r));
ajtj=aj*tj;
end

