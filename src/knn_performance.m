function [time_taken, acc]=knn_performance(view, label, knnK, distance,crossval_fold)
% view is the data
% label are the labels of the data
% knnK are the K 
% distance is either euclidean, or cosine but NEVER correlation
% cosine means no mean substraction.

knnK=knnK+1; %Since the knn query function also returns itself in the result.
tic; 
perf=0;
indices=crossvalind('Kfold', label, crossval_fold);
perf=zeros(1, crossval_fold);
matlabpool('OPEN', crossval_fold);
parfor i=1:crossval_fold
    disp(sprintf('Starting Fold number %d', i));
    test=(indices==i);
    train=~test;
    pred_labels=knnclassify(view(test,:), view(train,:), label(train), ...
                      knnK, distance, 'nearest');
    perf(i)=sum(pred_labels==label(test));
end
acc=sum(perf)/length(label)*100;
time_taken=toc;

% performance_func=@(idx, label, len) ...
%     sum(arrayfun(@(i) sum(label(idx(i,:))==label(i))-1, 1:len))/ ...
%     len;
% tree=kdtree_build(view);
% idx = cell2mat(arrayfun(@(i) kdtree_k_nearest_neighbors(tree, view(i,:), ...
%                                                knnK)', (1:len)', ...
%                'UniformOutput', 0));
% [distance, idx]=knn(view', view', knnK)
% acc=performance(idx, label, len);
