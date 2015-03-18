function bitext_true_extrinsic_test(G, bvgn_embedding, dimension_after_cca, ...
                               word, domikolov,  do_only_G, emb_word)
if nargin < 5
    domikolov=1;
    do_only_G=1;
    emb_word=nan;
end
    
if ~do_only_G
    bvgn_embedding=normalize_embedding(bvgn_embedding);
    rank_cell_orig=conduct_extrinsic_test_impl(...
        bvgn_embedding,'original embedding', emb_word, domikolov);
end


G=normalize_embedding(G);
rank_cell_orig=conduct_extrinsic_test_impl(...
    G, 'G', word,domikolov);

% if ~do_only_G
%     [Wx, Wy, r]=get_CCA_projection_matrices(...
%         G, bvgn_embedding, dimension_after_cca);

%     get_mu = @(M) repmat(mean(M), size(M,1),1)
%     mean_center = @(M) M-get_mu(M);
%     U = normalize_embedding(mean_center(bvgn_embedding)*Wy);
%     V = normalize_embedding(mean_center(G)*Wx);
    
%     rank_cell_cca_U=conduct_extrinsic_test_impl(...
%         U, 'U', word,domikolov);

%     rank_cell_cca_V=conduct_extrinsic_test_impl(...
%         V, 'V', word,domikolov);

%     assert(length(rank_cell_orig)==length(rank_cell_cca_U));
%     for i=1:length(rank_cell_orig)
%         fprintf(1, '%s\t%s\t%d\t%d\n', rank_cell_orig{i, 1}, ...
%                 rank_cell_orig{i, 2}, rank_cell_orig{i, 3}, ...
%                 rank_cell_cca_U{i, 3});
%     end
% end