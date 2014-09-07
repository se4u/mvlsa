% m is the number of svd dimensions that I will be calculating
% I would check the discrepancy for these many svd dim
function test_redsvd(m)
load /export/a14/prastog3/align_cs.mat
tic; [U,S,V]=svds(align_mat, m); toc;
S=diag(S);
for it=2:2:10
    tic; [U1,S1,V1]=redsvd(align_mat, m, it); toc;
    S1=diag(S1);
    discrep=norm(S - S1)/length(S);
    fprintf(1, '%d %d\n', it, norm(S - S1));
    if discrep < 1e-10
        break
    end
end