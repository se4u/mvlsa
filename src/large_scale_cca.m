global embedding; % The array which contains embeddings
global mapping; % The array which maps rows to other rows for CCA
global outmatfile_name; % The output file.
global dimension_after_cca; 
global knnK;
global distance_method; %Distance method that is either euclidean
                        %or cosine
global do_knn_only_over_original_embedding;
global do_append;
global dim2append;
global debug;
global use_unique_mapping; % Use uniquified mapping to do CCA.
global do_average_knn; %Flag to specify that we want to find
                       %average neighbor rank of PPDB paraphrases.
if isempty(do_average_knn)
    do_average_knn=0;
end
disp('I am running on machine'); unix('hostname');
embedding=normalize_embedding(embedding);
vocab_size=size(embedding, 1);
width=size(embedding, 2);
[mapping, unique_mapping]=uniquify_mapping(mapping, use_unique_mapping);
vocab_relation_count=size(mapping, 1);
disp(sprintf('the number of vocab_relation_count %d', vocab_relation_count));
assert(all(all(1 <= mapping <= vocab_size)));
%% Include utility functions
lib_util;
%% Prepare Input
[view1, view2]=view_preparor(vocab_relation_count, width, ...
                                      embedding, mapping);
%% Based on the mapping array assign labels
if ~do_average_knn
    tic
    [label, number_of_classes, label_to_freq_map]= ...
        undirected_floodfill(mapping, vocab_size);
    % sparse labels occur because PPDB does not have paraphrase
    % for all the words.
    non_sparse_class_indices=arrayfun(...
        @(i) label_to_freq_map(label(i)) >= 2, ...
        (1:length(label))');
    disp(sprintf('total elements in non sparse labels is %d', ...
                 sum(non_sparse_class_indices)));
    label=label(non_sparse_class_indices);

    disp(sprintf('Floodfill complete in %f sec', toc));
    assert(~isempty(label));
else
    non_sparse_class_indices=1:size(embedding,1);
    label=NaN;
end
cell_select=@(c, i)c{i+1};
acc_or_rank=cell_select({'Accuracy', 'Rank'}, do_average_knn);
%% Do KNN of the original embedding
if do_knn_only_over_original_embedding
    embedding=embedding(non_sparse_class_indices, :);
    [time_taken, acc]=knn_performance(embedding, label, knnK, ...
                                      distance_method, 10, do_average_knn, ...
                                      unique_mapping);
    disp(sprintf(['Knn complete in %f with %s : %f over ' ...
                  'original embedding'], ...
                 time_taken,acc_or_rank,acc));
    return;
end

%% Do KNN over the appended embeddings.
if do_append
    embedding=embedding(non_sparse_class_indices, :);
    % Do CCA
    [Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, ...
                                                   dim2append);
    [time_taken, acc]=knn_performance([embedding (embedding)*Wx], ...
                                      label, knnK, distance_method, ...
                                      10, do_average_knn, ...
                                      unique_mapping); 
    disp(sprintf('Knn complete in %f with %s : %f over AU', ...
                 time_taken,acc_or_rank, acc));
    return;
end
    
%% Do CCA then KNN
[Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, dimension_after_cca);
mu=repmat(mean(embedding), size(embedding,1),1);
U = (embedding-mu)*Wx;
U = U(non_sparse_class_indices, :);
[time_taken, acc]=knn_performance(U, label, knnK, distance_method, ...
                                  10, do_average_knn,  ...
                                  unique_mapping);
disp(sprintf('Knn complete in %f with %s : %f over U', ...
             time_taken,acc_or_rank, acc));

% U__ = (embedding-mu)*Wy;
% U__ = U__(non_sparse_class_indices, :);
% [time_taken, acc]=knn_performance(U__, label, knnK, distance_method, 10);
% disp(sprintf('Knn complete in %f with %s : %f over U__', acc_or_rank, time_taken, ...
%              acc));
return;