global embedding; % The array which contains embeddings
global mapping; % The array which maps rows to other rows for CCA
global outmatfile_name; % The output file.
global dimension_after_cca; 
global knnK;
global distance_method; %Distance method that is either euclidean
                        %or cosine
global do_knn_only_over_original_embedding;
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
assert(length(tmp)==number_of_classes);
label_to_freq_map=tmp(:,2);
for i=1:length(label)
    if label_to_freq_map(label(i)) < knnK
        label(i)=0;
    end
end
non_sparse_class_indices=find(label~=0);
disp(sprintf('the number of unique labels is %d', number_of_classes));
disp(['FIXME I have removed classes which dont have at least ' ... 
      'knK points in them. Is that correct way to evaluate ?']);
% Note that singletons occur because PPDB does not have paraphrase
% for all the words. Of course mapped_labels would never have
% labels from classes which are singletons.
disp(sprintf('Floodfill complete in %f sec', toc));
label=label(non_sparse_class_indices);
if isempty(label)
    disp(sprintf('Stop KNN: Not a single class with %d neighbors', knnK));
    return;
end
%% Do KNN of the original embedding
if do_knn_only_over_original_embedding
    embedding=embedding(non_sparse_class_indices, :);
    [time_taken, acc]=knn_performance(embedding, label, knnK, ...
                                      distance_method, 10);
    disp(sprintf('Knn complete in %f with Accuracy : %f over original embedding', ...
                 time_taken,acc));
    return;
end
%% Do CCA
tic; [Wx,Wy,r] = canoncorr_reg(view1, view2);
disp(sprintf('CCA complete in %f sec', toc));
Wx=Wx(:, 1:dimension_after_cca);
Wy=Wy(:, 1:dimension_after_cca);
mu=repmat(mean(embedding), size(embedding,1),1);
chisq_stat=-(size(view1, 1)-1-(2*width+1)/2)*flipud(cumsum(flipud(log(1-r.^2))));
dof=((width+1)-(1:width)).^2;
for non_negligible_corr_dim=width:-1:1
    i=non_negligible_corr_dim; % For convenience
    if chisq_diff_from_zero(chisq_stat(i), dof(i), 0.95)
        break;
    end
end
disp(sprintf(['At 95 percent confidence the number of dimensions which have ' ...
      'non negative correlation are %d'], non_negligible_corr_dim));
U = (embedding-mu)*Wx;
U__ = (embedding-mu)*Wy;
% Storing this blob to Disk and loading again might be slow anyway.
% save(outmatfile_name, 'Wx', 'Wy', 'r', 'view1', 'view2');
%% Do KNN
U=U(non_sparse_class_indices, :);
[time_taken, acc]=knn_performance(U, label, knnK, distance_method, 10);
disp(sprintf('Knn complete in %f with Accuracy : %f over U', time_taken, ...
             acc));
[time_taken, acc]=knn_performance(U__, label, knnK, distance_method, 10);
disp(sprintf('Knn complete in %f with Accuracy : %f over U__', time_taken, ...
             acc));
return;