% ste means space and time efficient.
function [G, S_tilde, sort_idx]=ste_rgcca(S, B, r, svd_reg_seq)
% S is a cell with singular values. 
% B contains singular vectors. Each entry in cell is a matrix
% with rows corresponding to a word and a small number of columns
% each corresponding to singular vectors.
% r is the number of gcca_components we want.
% svd_reg_seq is the amount of regularization.

J = length(S); % J = number of sources of data
N = size(B{1}, 1); % N = number of rows.
B_concat=zeros(N, sum(arrayfun(@(i) size(B{i}, 2), 1:J)));
proj_mat=@(x, r) x*inv(x'*x+r*eye(size(x,2)))*x';
for j=1:J
    s_=S{j};
    l=length(S{j});
    t=sqrt(proj_mat(spdiags(s_(:), 0, l, l), svd_reg_seq(j)));
    B_concat(:, (j*l-l+1):(j*l))=B{j}*t;
end
[Q, R]=qr(B_concat, 0);
assert(size(Q,1)==N);
[V, D,~]=svds(R, r);
% Now Q*V is the GCCA embedding.
G = Q*V;
S_tilde = D.^2;
sort_idx=1:N;
