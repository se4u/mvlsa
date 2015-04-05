function [Ut_new, St_new, St_discarded, Ut_discarded]=incrementalSVD(C, U_tilde, S_tilde, r)
[N, b]=size(C); %#ok<ASGLU>
L = U_tilde'*C;
H = C - U_tilde*L;
[J, W]=qr(H, 0);
Q = [diag(S_tilde) L; zeros(b,r) W];
[Ut_prime, St_prime, ~]=fastsvd(Q,b);
St_new=St_prime(1:r);
Ut_new=[U_tilde J] * Ut_prime(:, 1:r);
St_discarded = St_prime(r+1:length(St_prime));
Ut_discarded = [U_tilde J] * Ut_prime(:, r+1:size(Ut_prime, 2));
end

function [U, S, V]=fastsvd(M, b) %#ok<INUSD>
% Ideally I want to exploit the c-bordered diagonal structure of the matrix
% (see Matthew Brand's 2002 Incremental SVD paper) however I am taking the
% easy route for now and doing standard SVD. But at least I convert the
% stupid identity matrix to its diagonal form.
[U, S, V]=svd(M);
S=diag(S)';
end