function x=regularized_proj(x,r)
% Preserve sparsity as mush as possible.
% returns x=x*inv(x'*x+r*sparse(eye(size(x,2))))*x';
x=x*inv(x'*x+r*sparse(eye(size(x,2))))*x';
end