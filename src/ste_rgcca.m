function [G, S_tilde, sort_idx]=ste_rgcca(M_tilde, r)
% M_tilde is contains the concatenation of all the singular values.
% r is the number of gcca_components we want.
% svd_reg_seq is the amount of regularization.
[Q, R]=qr(M_tilde, 0);
[V, D]=eigs(R*R', min(r, size(R, 1)-1));
G = Q*V;
S_tilde = D.^2;
sort_idx=1:size(M_tilde, 1);
