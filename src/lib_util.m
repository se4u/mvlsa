sum_of_squares = @(a) sum(sum(a.^2));
within_group = @(a,b) sum_of_squares((a-b))/2; 
between_group = @(a,b,mu) sum_of_squares((a+b)/2 - repmat(mu,size(a,1),1));
f_measure = @(a,b) (size(a,1)/(size(a,1)-1)) ...
    *between_group(a,b, mean([a;b]))/within_group(a,b); 
% Following conditions should be satisfied by CCA projections.
% Orthogonality : The new projections are uncorrelated across
% individuals 
% Correlation : The new projections of the same view are also
% uncorrelated to each other.
% So we define these two lambdas
show_orthogonality = @(U, V) bar3(corr(U, V));
show_correlation = @(U) bar3(corr(U, U));
leave1out_performance=@(idx, classes) sum(arrayfun(@(i) any(idx(i,:)==(i)), ...
                                                  1:classes))/classes;

canoncorr_reg = @(v1, v2) cca_raman(v1', v2', 1e-8, 1e-8, ...
                                        min(size(v1,2), size(v2, ...
                                                  2)));
chisq_diff_from_zero = @(st,dof,p) 2*(1-chi2cdf(abs(st), dof)) < (1-p);