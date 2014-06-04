global embedding; % The array that contains the vectors. 1 per row
global mapping; % The array which maps rows to other rows
global dimension_after_cca;
global distance_method;
global use_unique_mapping; %Whether to uniquify the mapping or not
global golden_paraphrase_map; %The golden paraphrases, that I use
                              %to calculate MRR
global ppdb_paraphrase_rating; 
lib_util; % Include utility functions
embedding=normalize_embedding(embedding); % Set euclidean norm of every row = 1
vocab_size=size(embedding, 1);
width=size(embedding, 2);
[mapping, unique_mapping]=uniquify_mapping(mapping, ...
                                           use_unique_mapping);
vocab_relation_count=length(mapping);
[view1, view2]=view_preparor(vocab_relation_count, width, ...
                                      embedding, mapping);
[Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, ...
                                               dimension_after_cca);
mu=repmat(mean(embedding), size(embedding,1),1);
U = normalize_embedding((embedding-mu)*Wx);
conduct_extrinsic_test_impl(embedding, golden_paraphrase_map, word, ...
                            ppdb_paraphrase_rating, 'original embedding');
conduct_extrinsic_test_impl(U, golden_paraphrase_map, word, ...
                            ppdb_paraphrase_rating, 'U');