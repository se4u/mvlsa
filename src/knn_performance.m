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
try
    % This is all crap for parallel processing which is buggy
    disp('I am running on machine'); unix('hostname');
    distcomp.feature( 'LocalUseMpiexec', false );
    matlabpool('OPEN', crossval_fold);
catch
    %do nothing
    % Basically the loop will not parallelize and would be
    % slow. but whatever.
    disp('Failure to parallelize on this machine');
end
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
try
    % Same here, matlab needs to be told to close the things.
    % Doesn't do that automatically. when the process exits. And
    % this thing itself can give error so put it in a try catch.
    matlabpool close force local;
catch
end
    
% performance_func=@(idx, label, len) ...
%     sum(arrayfun(@(i) sum(label(idx(i,:))==label(i))-1, 1:len))/ ...
%     len;
% tree=kdtree_build(view);
% idx = cell2mat(arrayfun(@(i) kdtree_k_nearest_neighbors(tree, view(i,:), ...
%                                                knnK)', (1:len)', ...
%                'UniformOutput', 0));
% [distance, idx]=knn(view', view', knnK)
% acc=performance(idx, label, len);
