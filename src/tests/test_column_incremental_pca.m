addpath('../general_utility');
M = randn(100, 10);
[true_u, true_s] = svd(M, 'econ');
true_s = diag(true_s);
u_hat = zeros(100, 10);
s_hat = zeros(10, 1);
iter = 0;
for epoch = 1:1
    for col_idx = 1:10
        [u_hat, s_hat] = column_incremental_pca(M(:,col_idx), u_hat, s_hat);
        iter = iter + 1;
    end
end
S = true_u'*u_hat;
dS = diag(S);
assert(norm(S-diag(dS), 'fro') < 1e-10);
assert(norm(abs(abs(dS) - 1), 'fro') < 1e-10);
disp(true_s);
disp(s_hat / iter);