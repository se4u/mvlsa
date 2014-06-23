%% test_se_gcca
tmp=magic(10);
X1=tmp(1:5, : );
randn('seed', 42);
X2 = randn(5, 10);
r=2;
r_const=1e-7;
% Finally I want to find eigen vectors of 
f=@(X) X'*inv(r_const*eye(size(X, 1)) + X*X')*X;  %#ok<*MINV>
M = f(X1)+f(X2);
[V, D]=eigs(M, r);

%% Now my solution to this problem it to take SVD of X1 and X2
[~, S1, B1]=svd(X1, 'econ');
[~, S2, B2]=svd(X2, 'econ');
S={diag(S1)', diag(S2)'};
B={B1, B2};
b = 2;
[G, S_tilde, sort_idx] = se_gcca(...
    S, B, r, b, (r*ones(1, 2)));
%% Check that the two methods give the same values
disp(norm(diag(D)'-S_tilde)/norm(diag(D)));