function [G, S_tilde, sort_idx] = mvlsa_incremental_svd(final_embedding_size, deptoload, ...
                                                  min_view_to_accept_word, M)
% function [G, S_tilde, sort_idx] = mvlsa_incremental_svd(final_embedding_size, deptoload, ...
%                                                   min_view_to_accept_word, M)
% INPUTS:
% * final_embedding_size: Dimensionality of lsa embeddings that we want.
% * deptoload           : Cell that contains mat file names.
% * min_view_to_accept_word: A threshold over the number of views
%     that a particular word must appear in. I am overloading
%     min_view_to_accept_word so that if its is greater than 50000
%     then it means that its the top vocabulary that I want to keep.
% * M                   : The maximum dimensionaity of SVD Embeddings that
%     we want to load from the preprocessed individual files containing SVD
%     of counts.
% OUTPUTS:
% * G        : The embeddings.
% * S_tilde  : The corresponding singular values.
% * sort_idx : Logical array describing words that were kept.
%% First Read dimensions of matrices to allocate space.
disp('First quickly read dimensions of big matrices and allocate space.');
K = NaN;
ajtj_row = 0;
for i = 1:length(deptoload)
    ajtj_size = size(matfile(deptoload{i}), 'ajtj');
    load(deptoload{i}, 'kj_diag');
    ajtj_row = ajtj_size(1);
    if isnan(K)
        K = zeros(ajtj_size(1), 1);
    end
    K = K+kj_diag;
end;
%% Remove words that are absent from too many views or just occur too few times.
% Now I would find whether there are any words which are
% completely absent(or highly sparse). We remove the rows that were
% highly sparse. This is yet another form of noise removal.
if min_view_to_accept_word < 100
    logical_acceptable_rows = (K >= min_view_to_accept_word);
elseif min_view_to_accept_word < 50000
    disp(['Dont know what to do with min_view_to_accept_word = '
          num2str(min_view_to_accept_word)]);
    exit(1);
else
    logical_acceptable_rows = logical([ones(min_view_to_accept_word,1); ...
                        zeros(length(K)-min_view_to_accept_word,1)]) & K~=0;
end
assert(sum(logical_acceptable_rows)>0);
K = K(logical_acceptable_rows);
%% Perform GCCA now.
fprintf(['Performing GCCA now. This process is slow.\nOne by One we would ' ...
      'load the mat files and then incrementally update our estimate of ' ...
      'the left singular vectors.\nWe load one matlab file at a time ' ...
      'to balance memory usage and disk access \nbut that is easy to ' ...
      'change to load more or less data.\nNote that this process needs ' ...
         'close to 10G) and 5 minute per view to run on a 10 core machine. ' ...
         'Although it is possible to decrease the run time and memory ' ...
         'required through more intelligent IO. (pre-loading data, mmap ?)']);
sanity_check_matrix = @(M) (nnz(M) > 0) && ~any(any(isnan(M))) && ...
    ~any(any(isinf(M)));
G = zeros(sum(logical_acceptable_rows), final_embedding_size);
S_tilde = zeros(final_embedding_size, 1);
for i = 1:length(deptoload)
    fprintf('GCCA: starting iteration: %d/%d\n', i, length(deptoload));
    tic;
    load(deptoload{i}, 'ajtj');
    ajtj = ajtj(logical_acceptable_rows,1:min(M, end));
    assert(sanity_check_matrix(ajtj));
    ajtj = spdiags(K.^(-1/2), 0, length(K), length(K))*ajtj;
    assert(sanity_check_matrix(ajtj));
    fprintf('GCCA: Data load, sanity checks took %.2f minutes\n', toc/60);
    [G, S_tilde] = batch_incremental_pca(ajtj, G, S_tilde);
    fprintf('GCCA: iteration %d took %.2f minutes\n', i, toc/60);
end;
sort_idx = logical_acceptable_rows;
end
