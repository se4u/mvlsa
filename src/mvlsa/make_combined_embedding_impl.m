function ajtj=make_combined_embedding_impl(emb, r)
[aj, ~, ~, sj]=v5_indisvd_level2(emb, 'mc', 'Count', 300, r, nan);
ajtj=aj*sqrt(regularized_proj(sparse_diag_mat(sj), r));
