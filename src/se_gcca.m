function [G, S_tilde, sort_idx] = se_gcca(S, B, r, b, svd_reg_seq)
% S is a cell with singular values
% B contains associated singular vectors
% r is the number of gcca components we want
% b is the step size from 1 to N
% svd_reg_seq is the regularization to apply to each component.
J = length(S);
N = size(B{1}, 1);
assert(length(svd_reg_seq)==J && length(B)==J); 
assert(all(arrayfun(@(i) size(B{i}, 1), 1:J)==N));%B{i} have N observations
assert(length(S{1})==size(B{1}, 2));
for i=1:J
    if size(S{i}, 1)~=1
        %If S{i} is a column make it a row
        S{i}=S{i}';
    end
end
U_tilde=zeros(N, r);
S_tilde=zeros(1, r);
% We need to schedule the columns that we process according to
% their norm so that the error in the SVD remains low. See
% test_incrementalSVD.m for more information
% THE RIGHT WAY TO DO THIS IS TO SHUFFLE BOTH ROWS AND COLUMNS.
% NOT JUST ONE of THEM. We first need to calculate just the norms
% of all the columns.
ovguard = @(l, b) min(l+b-1, N);
column_norm=zeros(1, N);
for l=1:b:N
    column_norm(l:ovguard(l, b))=sum(...
        get_columns(S, B, l:ovguard(l, b), svd_reg_seq).^2, ...
        1);
end
[~, sort_idx]=sort(column_norm, 'descend');
assert(size(sort_idx,1)==1);

for l=1:b:N
    fprintf(2, 'Will process %d th column out of %d\n', l, N);
    % Cl = get_columns(S, B, l:ovguard(l, b), svd_reg_seq);
    Cl = get_columns(S, B, sort_idx(l:ovguard(l, b)), svd_reg_seq);
    Cl=Cl(sort_idx,:); %Also shuffle the rows so that C remains a
                  %kernel matrix.
    [U_tilde, S_tilde_new]=incrementalSVD(...
        Cl, U_tilde, S_tilde, r);
    fprintf(2, 'S_tilde changed by %f\n', ...
            norm(S_tilde-S_tilde_new)/norm(S_tilde));
    S_tilde=S_tilde_new;
    % Orthogonalize using modified gram schmidt if eigen 
    % directions become non orthogonal
    if abs(U_tilde(:,1)'*U_tilde(:, r)) > 10*eps('double')
        warning('U_tilde has become non-orthogonal'); %#ok<*WNTAG>
        U_tilde=m_gsm(U_tilde);
    end
end
G = U_tilde';
% U = pinv(X{1})'*G'; %Of course we never actually got X1 only its SVD
end

function C = get_columns(S, B, idx, svd_reg_seq)
% This function calculates columns within idx by using S and B and the
% svd_regularization_sequence (which puts a separater regularization
% sequence for each language pair.
a_by_apb=@(a,b) a./(a+b);
C = zeros(size(B{1}, 1), length(idx));
for j=1:length(S)
    sj_prime=a_by_apb(S{j}.^2, svd_reg_seq(j));
    C = C +B{j}*transpose(repmat(sj_prime, length(idx), 1).*B{j}(idx, :));
end
end
