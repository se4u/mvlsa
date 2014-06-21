function [Ut_new, St_new]=incrementalSVD(C, U_tilde, S_tilde, r)
[N, b]=size(C); %#ok<ASGLU>
L = U_tilde'*C;
H = C - U_tilde*L;
[J, W]=qr(H, 0);
%% If S_tilde is not empty then Q incorporates it otherwise forget it.
Q = [diag(S_tilde) L; zeros(b,r) W];
[Ut_prime, St_prime, ~]=fastsvd(Q,b);
St_new=St_prime(1:r);
%% If determinant of W is greater than machine tolerance then use it,
% otherwise loose it.
Ut_new=[U_tilde J] * Ut_prime(:, 1:r);
end

function [U, S, V]=fastsvd(M, b) %#ok<INUSD>
% Ideally I want to exploit the c-bordered diagonal structure of the matrix
% (see Matthew Brand's 2002 Incremental SVD paper) however I am taking the
% easy route for now and doing standard SVD. But at least I convert the
% stupid identity matrix to its diagonal form.
[U, S, V]=svd(M);
S=diag(S)';
end