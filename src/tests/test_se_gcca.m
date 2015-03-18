%% test_se_gcca
clc;
% clear; load /export/a14/prastog3/align_ar.mat ; ar = align_mat; load /export/a14/prastog3/align_cs.mat ; cs = align_mat; clear align_mat; whos;
N=10;
X1 = ar(1:N, 1:2*N);
X2 = cs(1:N, 1:3*N);
% Take SVD of this data.
[B1, S1]=svds(X1, 10);
[B2, S2]=svds(X2, 10);
S={diag(S1)', diag(S2)'};
B={B1, B2};
b = 2;
[G, S_tilde, sort_idx] = se_gcca(...
    S, B, 5, 1, (1e-8)*ones(1, 2));
%% Check that the two methods give the same values
U_tilde1 = G';
f=@(X) X'*inv((1e-8)*eye(size(X, 1)) + X*X')*X;
X  = f(X1')+f(X2');
[U, S, ~]=svd(X(sort_idx, sort_idx), 'econ');
disp(norm(X - U*S*U', 'fro'));
disp('Cosine between calculated direction and true direction is');
disp(arrayfun(@(i) U_tilde1(:,i)'*U(:,i), 1:5)); % I have checked
                                                 % that U is correct