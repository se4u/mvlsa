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

disp('I am running on machine'); unix('hostname');
vocab_size=size(embedding, 1);
width=size(embedding, 2);
vocab_relation_count=size(mapping, 1);
disp(sprintf('the number of vocab_relation_count %d', vocab_relation_count));
assert(all(all(1 <= mapping <= vocab_size)));
%% Include utility functions
lib_util;
%% Prepare Input
tic;
view1=zeros(vocab_relation_count, width);
view2=zeros(vocab_relation_count, width);

for i=1:vocab_relation_count
    view1(i,:)=embedding(mapping(i, 1), :);
    view2(i,:)=embedding(mapping(i, 2), :);
end
disp(sprintf('input prepared in %f', toc));
%% Based on the mapping array assign labels
tic
[label, ~, ~, ~, number_of_classes]= ...
    undirected_floodfill(mapping, vocab_size);
tmp=tabulate(label);
label_to_freq_map=tmp(:,2);
% sparse labels occur because PPDB does not have paraphrase
% for all the words.

non_sparse_class_indices=arrayfun(@(i) label_to_freq_map(label(i)) >= 2, ...
                                  (1:length(label))');
disp(sprintf('total elements in non sparse labels is %d', ...
             sum(non_sparse_class_indices)));
label=label(non_sparse_class_indices);

disp(sprintf('Floodfill complete in %f sec', toc));
assert(~isempty(label));
% if isempty(label)
%     disp(sprintf('Stop KNN: Not a single class with %d neighbors', knnK));
%     return;
% end

%% Do KNN of the original embedding
if do_knn_only_over_original_embedding
    embedding=embedding(non_sparse_class_indices, :);
    [time_taken, acc]=knn_performance(embedding, label, knnK, ...
                                      distance_method, 10);
    disp(sprintf('Knn complete in %f with Accuracy : %f over original embedding', ...
                 time_taken,acc));
    return;
end

%% Do KNN over the appended embeddings.
if do_append
    embedding=embedding(non_sparse_class_indices, :);
    % Do CCA
    [Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, ...
                                                   dimension_after_cca);
    mu=repmat(mean(embedding), size(embedding,1),1);
    % Do KNN
    [time_taken, acc]=knn_performance([embedding (embedding-mu)*Wx], ...
                                      label, knnK, distance_method, ...
                                      10);
    disp(sprintf('Knn complete in %f with Accuracy : %f over AU', time_taken, ...
             acc));
    return;
end
    
%% Do CCA then KNN
[Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, dimension_after_cca);
mu=repmat(mean(embedding), size(embedding,1),1);

U = (embedding-mu)*Wx;
U = U(non_sparse_class_indices, :);
[time_taken, acc]=knn_performance(U, label, knnK, distance_method, 10);
disp(sprintf('Knn complete in %f with Accuracy : %f over U', time_taken, ...
             acc));

% U__ = (embedding-mu)*Wy;
% U__ = U__(non_sparse_class_indices, :);
% [time_taken, acc]=knn_performance(U__, label, knnK, distance_method, 10);
% disp(sprintf('Knn complete in %f with Accuracy : %f over U__', time_taken, ...
%              acc));
return;