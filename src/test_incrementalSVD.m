clc;
N=10;
randn('seed', 42);
X = randn(2*N, N); % N is th enumber of data points. 20 = dim
X1 = X;
X = X'*inv(X*X'+1e-8*eye(length(X)))*X;
[U, S, ~]=svd(X, 'econ');
disp(norm(X - U*S*U', 'fro'));
S=diag(S)';
X_orig=X;
fprintf(1, '%f %f %f %f %f %f %f %f %f %f \n', S);
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
    [U_tilde2, S_tilde2]=incrementalSVD(...
        C, U_tilde2, S_tilde2, N);
    disp(j);
    fprintf(1, '%f %f %f %f %f \n', S_tilde1);
    fprintf(1, '%f %f %f %f %f %f %f %f %f %f\n', S_tilde2);
end
rec1 = U_tilde1*diag(S_tilde1)*U_tilde1';
rec2 = U_tilde2*diag(S_tilde2)*U_tilde2';
G = U_tilde1'; % Because we have founf the eigen vectors and
fprintf(1, 'G^T*G - I = %d\n', (norm(G*G'-eye(size(G,1)))));
% G - U' X => G' = X'U
% b = Ax => x = pinv(A)*b
% U = pinv(X') * G' => U = pinv(X1)'*U_tilde1
U = pinv(X1)'*U_tilde1;
emb1 = U'*X1;
emb2 = (pinv(X1)'*U_tilde2(:, 1:5))'*X1;
for i=1:5
    disp(corr([emb1(i,:)', emb2(i,:)']));
end

disp(norm(rec1 - X, 'fro'));
for i=1:2:N
    disp(norm(U_tilde2(:,1:i)*diag(S_tilde2(1:i))*U_tilde2(:,1:i)'- X, 'fro'));
end

