isdiag=@(x)all(all(x==diag(diag(x))));
proj_mat=@(x, r) x*inv(x'*x+r*eye(length(x)))*x';
dim=1000;
load /export/a14/prastog3/align_cs.mat ;
x1=full(align_mat(1:dim, 1:dim));
load /export/a14/prastog3/align_de.mat ;
x2=full(align_mat(1:dim, 1:dim));
r=1e-6;
p1=proj_mat(x1,r);
p2=proj_mat(x2,r);
m=p1+p2;
m=(m+m')/2;
[u_ref, s_ref]=eig(m);
[u_ref, s_ref]=sort_eig(u_ref, s_ref);
assert(isreal(s_ref));
assert(isdiag(s_ref));
assert(mean(abs(s_ref(s_ref<0)))<1e-10);

[a1, s1, b1]=svd(x1);
[a2, s2, b2]=svd(x2);

t1=sqrt(proj_mat(s1, r));
t2=sqrt(proj_mat(s2, r));
M_tilde=[a1*t1 a2*t2];

m_second=M_tilde*M_tilde';
fprintf(1, 'Reconstructed m %d\n', norm(m-m_second, 'fro'));

[q, r_]=qr(M_tilde);
[u, s]=eig(r_*r_');
[u, s]=sort_eig(u, s);
fprintf(1, 'Reconstructed m %d %d\n', norm(q*u*s*u'*q'-m, 'fro'), norm(m, 'fro'));
fprintf(1, 'Difference in s %d %d\n', norm(s_ref-s, 'fro'), norm(s, 'fro'));
g = q*u;
fprintf(1, 'Cosine between u_ref and g %d\n', u_ref(:,end)'*g(:,end));

S={diag(s1), diag(s2)};
B={a1, a2};
svd_reg_seq=[r r];
r=dim;
[G, S_tilde, sort_idx]=ste_rgcca(S, B, r, svd_reg_seq);
norm(S_tilde-s, 'fro')
