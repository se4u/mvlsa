%% cca Canonical correlation analysis. 
% [Wx,Wy,Wz,r]=gcca(X,Y,Z,regX,regY,regZ,k) performs generalized canonical 
% correlation analysis on three sets of variates: pxn data matrix X, 
% qxn matrix Y and rxn matrix Z. The data matrices X, Y and Z must have 
% the same number of observations (columns) but can have different number 
% of variables (rows). Wx, Wy, Wz are pxk, qxk and rxk matrices where k is 
% the dimensionality of the CCA subspace and cannot exceed the minimum 
% of rank(X), rank(Y) and rank(Z). The correlations are returned in the
% vector r in a descending order. The ith columns of matrices Wx, Wy, Wz
% span the canonical subspace of X, Y, Z which captures a correlation of 
% r(i). The regularization parameters for X, Y, Z are given as scalars in 
% input arguments regX, regY, and regZ respectively. 
% 
% Inputs:
%    X - pxn data matrix (View 1)
%    Y - qxn data matrix (View 2)
%    Z - txn data matrix (View 3)
% regX - a positive scalar specifying regularization on View1. The
%        covariance matrix of X is estimated as cov(X)+regX*eye(p,p)
% regY - a positive scalar specifying regularization on View2. The
%        covariance matrix of Y is estimated as cov(Y)+regY*eye(q,q)
% regZ - a positive scalar specifying regularization on View3. The
%        covariance matrix of Z is estimated as cov(Z)+regZ*eye(r,r)
%    k - dimensionality of the primal CCA subspace
%    S - (optional) a positive integer specifying number of subsamples to 
%        draw. Note that GCCA will require O(S^2) memory and O(S^3) flops
%        so choose S wisely (typically S<<n).
%
% Outputs:
%   Wx - pxk coefficient matrix for the CCA basis for View1 
%   Wy - qxk coefficient matrix for the CCA basis for View2  
%   Wz - txk coefficient matrix for the CCA basis for View3  
%    r - vector of canonical correlations in a descending order
%--------------------------------------------------------------------------
% Author:        Raman Arora
% E-mail:        arora@ttic.edu
% Affiliation:   Toyota Technological Institute at Chicago
% Version:       0.1, created 10/19/11
%--------------------------------------------------------------------------
%%

function [Wx,Wy,Wz,r]=gcca(X,Y,Z,regX,regY,regZ,k,S)

%% --- Check the dimensions ---
[p,N1]=size(X);
[q,N2]=size(Y);
[t,N3]=size(Z);

k=min([k,p,q,t]);
if((p>N1) || (q>N2) || (t>N3))
    warning('Dimensionality greater than the sample size');
end

if(min([N1,N2,N3])~=max([N1,N2,N3]))
    error('Number of observations across different views should be the same');
end

%% Subsampling
N=N1;
if((nargin < 8))
    S=N;
end 
iperm=randperm(N);
iperm=iperm(1:S);
X=X(:,iperm);
Y=Y(:,iperm);
Z=double(Z(:,iperm)); %% Z: one-hot encoding of labels
%% It OOMS over here.
%% Error using eye
Rxx=X'*(inv((X*X')+regX*eye(p)))*X;
Ryy=Y'*(inv((Y*Y')+regY*eye(q)))*Y;
Rzz=Z'*(inv((Z*Z')+regZ*eye(t)))*Z;
R=double(Rxx+Ryy+Rzz);
clear('Rxx','Ryy','Rzz');

%% --- Calculate Wx and r ---
[V,r]=eigs(R,k); % Basis in X
r=diag(r);
if(find(~isreal(r)))             % Check for complex singular values
    warning('Complex coefficient matrix entries');
    r=real(r); % Fetch real correlation values
end

%% Flip signs of eigenvectors if negative eigenvalues are found
if(find(r<0))
    I=find(r<0);
    r(I)=-r(I);
    V(:,I)=-V(:,I);
end
if(find(~isreal(V)))
    error('Complex coefficient matrix entries');
end

%% --- Sort correlations and basis vectors ---
G=zeros(size(V));
[r,I]=sort(r,'descend');	
for j=1:length(I)
    G(:,j)=V(:,I(j));  
end
G=G(:,1:k);
Wx=pinv(X*X'+regX*eye(p))*X*G;
Wy=pinv(Y*Y'+regY*eye(q))*Y*G;
Wz=pinv(Z*Z'+regZ*eye(t))*Z*G;
r=r/3; %% Scale back the singular values
end
