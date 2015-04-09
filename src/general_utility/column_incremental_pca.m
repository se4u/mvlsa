function [Uh, Sh] = column_incremental_pca(x, U, S)
assert(size(x, 2) == 1);
xh = U'*x;                     % Project data onto left singular subspace (rx1)
r = x - U*xh;                  % Residual unexplained by left singular subspace (mx1)
r_norm = norm(r, 2);
if(r_norm > 1e-6)
    r = r/r_norm;              % Normalize residual to get unit vector normal to U
end
%% Transform S into sparse matrix
S = spdiags(S, 0, length(S), length(S));
[Uh, Sh] = svd([ S+xh*xh'   r_norm*xh; ...
                 r_norm*xh' r_norm^2 ], ...
               'econ');
Uh = [U r]*Uh;
Sh = diag(Sh);
%% Go back to being a vector and truncate
[~,idx] = sort(Sh,'descend');
idx = idx(1:size(U,2));
Uh = Uh(:, idx);
Sh = Sh(idx);
end
