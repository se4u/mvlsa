load /export/a14/prastog3/align_cs.mat ;
dim=500;
M=align_mat(1:dim, 1:dim);
mu=mean(M);
[Uu Su Vu]=svds(M, dim);
[Uc Sc Vc]=svds(M-repmat(mu, dim, 1), dim);
[Uc2, Sc2, Vc2]=rank_one_svd_update(Uu, Su, Vu, -1*ones(dim, 1), ...
                                    mu', 0);
disp(norm(Sc-Sc2, 'fro'))
disp(norm(Uc-Uc2, 'fro'))
disp(norm(Vc-Vc2, 'fro'))