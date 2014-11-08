function s=sparse_diag_mat(s)
    % Make a diagonal matrix into a vector
    % Raise error if s is not diagonal.
    if(size(s,1)~=1 && size(s,2)~=1)
        assert(isdiag(s));
        s=diag(s);
    end
    % Make a row vector into a column vector
    if size(s,1)==1
        s=s';
    end
    s=spdiags(s, 0, length(s), length(s));
end