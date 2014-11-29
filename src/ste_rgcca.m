function [G, S_tilde, sort_idx]=ste_rgcca(M_tilde, final_embedding_size)
% M_tilde is contains the concatenation of all the singular values.
% final_embedding_size is the number of gcca_components we want.
% svd_reg_seq is the amount of regularization.

[Q, R]=qr(M_tilde, 0);
if any(any(isnan(R))) ||  any(any(isnan(Q)))
    disp(['R or Q because nan, probably because the qr of M_tilde ' ...
          'became unstable']);
    exit(1);
else
    [V, S_tilde]=eigs(R*R', min(final_embedding_size, size(R, 1)-1));
    G = Q*V;
end
sort_idx=1:size(M_tilde, 1);
