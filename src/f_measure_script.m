%Imagine Every group has only 2 points. 
%a, b have single point as a row.
sum_of_squares = @(a) sum(sum(a.^2));
assert(sum_of_squares([1 2; 3 4])==30);
%because there are only two points in the group the expression is
%simplified.
within_group = @(a,b) sum_of_squares((a-b))/2; 
assert(within_group([1 1; 3 4], [2 5; 1 2])==12.5);
between_group = @(a,b,mu) sum_of_squares((a+b)/2 - repmat(mu,size(a,1),1));
f_measure = @(a,b) (size(a,1)/(size(a,1)-1)) ...
    *between_group(a,b, mean([a;b]))/within_group(a,b); 