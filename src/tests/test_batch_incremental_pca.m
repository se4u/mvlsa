N = 100;
X = randn(100, N);
[true_u, true_s, ~]=svd(X, 'econ');
true_s = diag(true_s);
u_hat = zeros(100, N);
s_hat = zeros(N, 1);
increment = 4;
iter = 0;
for epoch = 1:1
    for j = 1:increment:size(X,2);
        C = X(:, j:min(N,j+increment-1));
        [u_hat, s_hat] = batch_incremental_pca(C, u_hat, s_hat);
        iter = iter + 1;
    end
end
S = true_u'*u_hat;
dS = diag(S);
assert(norm(S-diag(dS), 'fro') < 1e-10);
assert(norm(abs(abs(dS) - 1), 'fro') < 1e-10);
assert(norm(true_s - s_hat) < 1e-10);
