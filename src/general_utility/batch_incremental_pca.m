function [Ut_new, St_new]=batch_incremental_pca(x, U, S)
r = size(U, 2);
b = size(x, 2);

xh = U'*x;
H = x - U*xh;
[J, W] = qr(H, 0);
Q = [diag(S)     xh ;...
     zeros(b,r)  W];
[Ut_new, St_new, ~]=fastsvd(Q);
St_new=St_new(1:r);
Ut_new=[U J] * Ut_new(:, 1:r);

end

function [U, S, V]=fastsvd(M) %#ok<INUSD>
% Ideally I want to exploit the c-bordered diagonal structure of the matrix
% (see Matthew Brand's 2002 Incremental SVD paper) however I am taking the
% easy route for now and doing standard SVD. But at least I convert the
% stupid identity matrix to its diagonal form.
[U, S, V]=svd(M);
S=diag(S);
end