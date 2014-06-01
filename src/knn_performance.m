function [time_taken, acc]=knn_performance(view, label, knnK, ...
                                           distance,crossval_fold, ...
                                           do_average_knn, ...
                                           unique_mapping)
% view is the data
% label are the labels of the data
% knnK are the K 
% distance is either euclidean, or cosine but NEVER correlation
% cosine means no mean substraction.
for i=1:size(view, 1)
    view(i,:)=view(i,:)/norm(view(i,:));
end

tic; 
if do_average_knn
    similarity=@(i,j)view(i,:)*view(j,:)'; assert(strcmp(distance,'cosine'));
    which_words_are_more_similar=@(i, d) (view*view(i,:)' > d);
    rp=randperm(length(unique_mapping));
    test_size=min(10000, length(unique_mapping));
    rng=rp(1:test_size);
    res=NaN(1,length(rng));
    for idx=1:length(rng)
        i=unique_mapping(idx,1);
        j=unique_mapping(idx,2);
        wwas=which_words_are_more_similar(i, similarity(i, j));
        wwas(i)=0;
        wwas(j)=0;
        res(idx)=sum(wwas);
    end
    acc=median(res);
    fprintf(1, 'The median rank over %d mappings is %d\n', ...
            test_size, median(res));
    fprintf(1, 'The mean rank over %d mappings is %f\n', ...
            test_size, mean(res));
else
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
    knnK=knnK+1; %Since the knn query function also returns itself in the result.
    indices=crossvalind('Kfold', label, crossval_fold);
    perf=zeros(1, crossval_fold);
    perf_per_fold=NaN(crossval_fold, 1);
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
    try
        % Same here, matlab needs to be told to close the things.
        % Doesn't do that automatically. when the process exits. And
        % this thing itself can give error so put it in a try catch.
        matlabpool close force local;
    catch
    end    
end
time_taken=toc;
