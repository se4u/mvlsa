clc;
% Uncomment this line when running test.
clear; load /export/a14/prastog3/align_ar.mat ; ar = align_mat; load /export/a14/prastog3/align_cs.mat ; cs = align_mat; clear align_mat; 
f=@(X) X'*inv((1e-8)*eye(size(X, 1)) + X*X')*X;
N=10; X1 = ar(1:N, 1:2*N)'; X2 = cs(1:N, 1:3*N)'; X  = f(X1)+f(X2);
% disp(sort(eig(X))');

[U, S, ~]=svd(X, 'econ');
fprintf(1, ['true singular ' repmat('%f ', 1, N) '\n'], diag(S)');
disp(norm(X - U*S*U', 'fro'));
S=diag(S)';

r=5;
ep=5;
U_tilde1=zeros(N, r);
S_tilde1=zeros(1, r);
U_tilde2=zeros(N, N);
S_tilde2=zeros(1, N);
increment=1;

for j=1:increment:size(X,2);
        C=X(:, j:min(N,j+increment-1));
        [U_tilde1, S_tilde1]=incrementalSVD(...
            C, U_tilde1, S_tilde1, r);
        fprintf(1, '%f %f %f %f %f \n', S_tilde1);
    
        [U_tilde2, S_tilde2]=incrementalSVD(...
                C, U_tilde2, S_tilde2, N);
        fprintf(1, '%f %f %f %f %f %f %f %f %f %f\n', S_tilde2);
    
        % disp(j);
        % if j > r
        %     disp('do special now');
        % end
end
rec1 = U_tilde1*diag(S_tilde1)*U_tilde1';
G = U_tilde1'; % Because we have founf the eigen vectors and
fprintf(1, 'test that G is orthogonal, G^T*G - I = %d\n', (norm(G*G'-eye(size(G,1)))));

% Importantly we dont have to compute U_j over the bilingual
% matrices.
% But we do want to know whether U_tilde1 and U_tilde2 (the group
% configuration vectors) are a similar subspace. and measure how
% similar they are ?
% U_tilde1 is a [N r] matrix.
% U_tilde2 is a [N N] matrix
% Basically we can simply show how close the eigen directions are
% to the true eigen directions.
disp('Cosine between calculated direction and true direction is');
disp(arrayfun(@(i) U_tilde1(:,i)'*U(:,i), 1:5));
disp('Cosine between calculated direction 1 and calculated 2 is');
disp(arrayfun(@(i) U_tilde1(:,i)'*U_tilde2(:,i), 1:5));
