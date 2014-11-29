function ajtj=make_combined_embedding_impl(emb, r)
[aj, sj]=v5_indisvd(emb, 'mc', 'Count', 300);
ajtj=aj*sqrt(regularized_proj(sparse_diag_mat(sj), r));
