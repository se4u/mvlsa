function [U_tilde, S_tilde] = se_gcca(S, B, m_prime, b, svd_reg_seq)
J = length(S);
N = size(B{1}, 1);
assert(length(S)==length(B));
assert(length(S{1})==size(B{1}, 2));
assert(size(S{1}, 1)==1); % Check that its a row.
assert(length(svd_reg_seq)==J); % test that svd_reg_seq specifies regularization r_j for each language
assert(b <= N && mod(N,b)==0); % Test that N is divisible by the batch size
assert(all(arrayfun(@(i) size(B{i}, 1), 1:J)==N)); % Test all sets have same number of observations
U_tilde=zeros(N, m_prime);
S_tilde=zeros(1, m_prime);
for l=1:b:N
    fprintf(2, 'Processing column %d to %d out of %d\n', l, l+b-1, N);
    Cl = get_columns(S, B, l, l+b-1, svd_reg_seq);
    [U_tilde, S_tilde]=incrementalSVD(Cl, U_tilde, S_tilde, m_prime);
end
% Orthogonalize using modified gram schmidt if eigen 
% directions become non orthogonal
if U_tilde(:,1)'*U_tilde(:, m_prime) > 10*eps('double')
    warning('U_tilde has become non-orthogonal'); %#ok<*WNTAG>
    U_tilde=m_gsm(U_tilde);
end

end

function C = get_columns(S, B, st, en, svd_reg_seq)
% This function calculates columns from st to en by using S and B and the
% svd_regularization_sequence (which puts a separater regularization
% sequence for each language pair.
a_by_apb=@(a,b) a./(a+b);
C = zeros(size(B{1}, 1), en-st+1);
for j=1:length(S)
    sj_prime=a_by_apb(S{j}.^2, svd_reg_seq(j));
    C = C +B{j}*transpose(repmat(sj_prime, en-st+1, 1).*B{j}(st:en, :));
end
end