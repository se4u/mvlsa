global embedding; % The array that contains the vectors. 1 per row
global mapping; % The array which maps rows to other rows
global dimension_after_cca;
global distance_method;
global w2v_file_name; % Word2Vec output file name
global cca_file_name; % CCA output file name
global word;
lib_util; % Include utility functions
vocab_size=size(embedding, 1);
width=size(embedding, 2);
vocab_relation_count=length(mapping);
[view1, view2]=view_preparor(vocab_relation_count, width, ...
                                      embedding, mapping);
[Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, ...
                                               dimension_after_cca);
mu=repmat(mean(embedding), size(embedding,1),1);
U = (embedding-mu)*Wx;

% disp(U(1,:));
% disp(word{1});
write_embedding_to_file(U, word, cca_file_name);
write_embedding_to_file(embedding, word, w2v_file_name);