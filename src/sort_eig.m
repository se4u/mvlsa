function [u, s]=sort_eig(u,s)
s=diag(s);
[~,sort_index]=sort(s, 'descend');
u=u(:, sort_index);
s=diag(s(sort_index));
