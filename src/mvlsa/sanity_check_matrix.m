function ret = sanity_check_matrix(M)
ret = (nnz(M) > 0) && ~any(any(isnan(M))) && ~any(any(isinf(M)));