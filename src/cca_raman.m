%% cca Canonical correlation analysis. 
% [Wx,Wy,r]=cca(X,Y,regX,regY,k) performs canonical correlation analysis on 
% pxn and qxn data matrices X and Y. The data matrices X and Y must have 
% the same number of observations (columns) but can have different number 
% of variables (rows). Wx and Wy are pxk and qxk matrices where k is the 
% dimensionality of the CCA subspace and cannot exceed the minimum 
% of rank(X) and rank(Y). The correlations are returned in the
% vector r in a descending order. The ith columns of matrices Wx and Wy
% span the canonical subspace of X and Y which captures a correlation of 
% r(i). The regularization parameters for X and Y are given as scalars in 
% input arguments regX and regY, respectively. 
% 
% Inputs:
%    X - pxn data matrix (View 1)
%    Y - qxn data matrix (View 2)
% regX - a positive scalar specifying regularization on View1. The
%        covariance matrix of X is estimated as cov(X)+regX*eye(p,p)
% regY - a positive scalar specifying regularization on View2. The
%        covariance matrix of Y is estimated as cov(Y)+regY*eye(q,q)
%    k - dimensionality of the primal CCA subspace
%
% Outputs:
%   Wx - pxk coefficient matrix for the CCA basis for View1 
%   Wy - qxk coefficient matrix for the CCA basis for View2  
%    r - vector of canonical correlations in a descending order
%--------------------------------------------------------------------------
% Author:        Raman Arora
% E-mail:        arora@ttic.edu
% Affiliation:   Toyota Technological Institute at Chicago
% Version:       0.1, created 10/19/11
%--------------------------------------------------------------------------
%%

function [Wx,Wy,r]=cca_raman(X,Y,regX,regY,k)

% --- Check the dimensions ---
[p,N1]=size(X);
[q,N2]=size(Y); 
k=min([k,p,q]);
if((p>N1) || (q>N2))
    warning('Dimensionality greater than the sample size');
end

if(N1 ~= N2)
    error('Number of observations of the two views should be the same');
end

% --- Calculate covariance matrices ---
z=[X;Y];
C=cov(z.');
C=(C+C')/2;
Cxx=C(1:p,1:p)+regX*eye(p);
Cxy=C(1:p,p+1:p+q);
Cyx=Cxy';
Cyy=C(p+1:p+q,p+1:p+q)+regY*eye(q);

% --- Calculate Wx and r ---
invCyy=inv(Cyy);    % Inverse covariance matrix
[Rxx,emsg]=chol(Cxx);     % lower triangular matrix
if(emsg==0)
    Rxx=Rxx';
    invRxx=inv(Rxx);
    A=invRxx*Cxy*invCyy*Cyx*invRxx'; % Symmetric matrix
    A=(A+A')/2;                      % Symmetrize A  
    [V,r]=eig(A);                    % Basis in X
    V=invRxx'*V;                     % Map back through Rxx
else
    [V,r] = eig(inv(Cxx)*Cxy*invCyy*Cyx); % Basis in X
end
r=diag(r);
if(find(~isreal(r)))             % Check for complex singular values
    warning('Complex coefficient matrix entries');
    r=real(r); % Fetch real correlation values
end

%% Flip signs of eigenvectors if negative eigenvalues are found

% ???? WHY ??? Flip sign or set to zero ???
if(find(r<0))
    I=find(r<0);
    r(I)=-r(I);
    V(:,I)=-V(:,I);
end
r=sqrt(r);                    % Canonical correlations
if(find(~isreal(V)))
    error('Complex coefficient matrix entries');
end

% --- Sort correlations and basis vectors ---
Wx=zeros(size(V));
[r,I]=sort(r,'descend');	
for j=1:length(I)
    Wx(:,j)=V(:,I(j));  
end

% --- Calcualte Wy  ---
Wy=invCyy*Cyx*Wx;     % Basis in Y
Wy=Wy./repmat(r',q,1); % Normalize Wy
Wx=Wx(:,1:k);
Wy=Wy(:,1:k);


%% My Correction   ???? WHY ??? I dont understand.
X2=Wx'*X;
Y2=Wy'*Y;
Cxx=cov(X2');
Cyy=cov(Y2');
Wx=Wx*inv(sqrt(diag(diag(Cxx)))); %#ok<*MINV>
Wy=Wy*inv(sqrt(diag(diag(Cyy))));
end
