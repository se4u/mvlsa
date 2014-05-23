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
perf_per_fold=NaN(crossval_fold, 1);
try
    % This is all crap for parallel processing which is buggy
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
    perf_per_fold(i)=perf(i)/sum(test);
end
acc=sum(perf)/length(label)*100;
disp(perf_per_fold);
disp(perf);
disp(sprintf('Accuracy in knn performance is %f in percentage', acc));
disp(sprintf('The n for use in variance calc is %d', ...
             length(label)));
disp(sprintf('the theoretical variance is %f', acc*(1-acc)/ ...
             length(label)));
disp(sprintf('the empirical variance is %f', var(perf_per_fold)));
% This sample variance is over 10 folds.
% sample_mean / sqrt(sample_variance/n) is t distributed with dof = 9
disp(sprintf('the 0.95 confidence interval is %f', tinv(0.95, crossval_fold-1)*sqrt(var(perf_per_fold)/crossval_fold)));
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
