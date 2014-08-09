global G;
global bvgn_embedding;
global dimension_after_cca;
global wordnet_test_filename;
global ppdb_paraphrase_rating_filename;
global word;
tic;
golden_paraphrase_map=create_golden_paraphrase_map(...
    wordnet_test_filename,word);
ppdb_paraphrase_rating=create_ppdb_paraphrase_rating(...
    ppdb_paraphrase_rating_filename,word);
fprintf(1, 'time taken to create gold standards = %f seconds\n', toc);
bvgn_embedding=normalize_embedding(bvgn_embedding);
G=normalize_embedding(G);

[Wx, Wy, r]=get_CCA_projection_matrices(...
    G, bvgn_embedding, dimension_after_cca);

rank_cell_orig=conduct_extrinsic_test_impl(...
    bvgn_embedding, golden_paraphrase_map, ...
    ppdb_paraphrase_rating,'original embedding', word);

rank_cell_orig=conduct_extrinsic_test_impl(...
    G, golden_paraphrase_map,...
    ppdb_paraphrase_rating, 'G', word);

get_mu = @(M) repmat(mean(M), size(M,1),1)
mean_center = @(M) M-get_mu(M);
U = normalize_embedding(mean_center(bvgn_embedding)*Wy);
V = normalize_embedding(mean_center(G)*Wx);

rank_cell_cca_U=conduct_extrinsic_test_impl(...
    U, golden_paraphrase_map, ...
    ppdb_paraphrase_rating, 'U', word);

rank_cell_cca_V=conduct_extrinsic_test_impl(...
    V, golden_paraphrase_map, ...
    ppdb_paraphrase_rating, 'V', word);

assert(length(rank_cell_orig)==length(rank_cell_cca_U));
for i=1:length(rank_cell_orig)
    fprintf(1, '%s\t%s\t%d\t%d\n', rank_cell_orig{i, 1}, ...
            rank_cell_orig{i, 2}, rank_cell_orig{i, 3}, ...
            rank_cell_cca_U{i, 3});
end