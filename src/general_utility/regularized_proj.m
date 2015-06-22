function x=regularized_proj(x,r)
% Preserve sparsity as much as possible.
x=x*inv(x'*x+r*speye(size(x,2)))*x';
end