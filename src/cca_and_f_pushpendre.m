global filename; % The name of file that contains the embeddings 
global columns; % Number of columns to skip from the input file
global dimensions_after_cca; 


lib_util % Include the following 
[view1, view2, words] = prepare_input(filename, columns);
%% Create synonymous partitions with regularized cca
[Wx,Wy,r] = canoncorr_reg(view1, view2);
U = (view1-repmat(mean(view1),size(view1, 1),1))*Wx;
V = (view2-repmat(mean(view2),size(view2, 1),1))*Wy;
if usejava('desktop')
    figure(); show_orthogonality(U, V); 
    figure(); show_correlation(U); 
    figure(); show_correlation(V); 
end
f_measure_orig = f_measure(view1, view2); 
U=U(:, 1:dimension_after_cca);
V=V(:, 1:dimension_after_cca);
f_measure_cca = f_measure(U, V);
make_word_cloud(U, V, words);
disp(f_measure_orig)
disp(f_measure_cca);
%% KNN classifier
idx = knnsearch(view1, view2, 1);
classes=size(view1, 1);
leave1out_knn_perf_before_cca=leave1out_performance(idx, classes);
disp(leave1out_knn_perf_before_cca);
idx = knnsearch(U, V, 1);
leave1out_knn_perf_after_cca =leave1out_performance(idx, classes);
disp(leave1out_knn_perf_after_cca);
%% Do random partitions of mikolov embeddings
if 0
    perm = randperm(size(arr,1));
    view1 = arr(perm(1:500),:);
    view2 = arr(perm(501:1000),:);
    [A,B,~,U,V,stats]=canoncorr(view1, view2);
    if usejava('desktop')
        figure(); show_orthogonality(U, V); 
        figure(); show_correlation(U); 
        figure(); show_correlation(V); 
    end
    f_measure_orig_randpart = f_measure(view1, view2); 
    U=U(:, 1:dimension_after_cca);
    V=V(:, 1:dimension_after_cca);
    make_word_cloud(U, V, words);
    f_measure_cca_randpart = f_measure(U, V);
    disp([f_measure_cca_randpart  f_measure_orig_randpart]);
end

%% Results upto here
%     4.7937    0.7510 (partition by synonyms, use canoncorr)
%     4.7937    0.7510 (partition by synonyms, use ramancorr)
%     2.9818    0.5024 (random vectors)
%     3.1024    0.4925 (random partition of mikolov embeddings)
% This begs the questions how to normalize the original embeddings ? 
% Are the original embeddings normal or not ?
%    3.0125    0.5077 (partition by 80 of the dimensions, (it shouldn't matter cause its LSH right??)
%    3.0125    0.5077 (raman_cca)
%    3.0803    0.5117 (randome permutation)
% Also my metric is not invariant of how many dimensions I keep at the end


