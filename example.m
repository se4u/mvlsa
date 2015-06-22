%----------------------------------------------------------------------
% This example code demonstrates the core algorithm described in
% Multiview LSA: Representation Learning via Generalized CCA. Pushpendre
% Rastogi, Benjamin Van Durme, Raman Arora. NAACL(2015)
%----------------------------------------------------------------------
% In this example we show how to use MVLSA to merge embeddings from two
% sources. E.g. the two sources could be the embeddings of word types
% according to Glove and Word2Vec. This file is self contained and you
% should be able to run this as follows
%----------------------------------------------------------------------
% USAGE: matlab -nojvm -nodesktop -nosplash -r 'cd $PWD; example '
%----------------------------------------------------------------------

% Create two phony embedding matrices.
glv = randn(200, 400); % glv == Glove
w2v = randn(200, 400); % w2v == Word2Vec

% num_word is the number of words in your vocabulary.
num_word = size(glv, 1);

% dim_vec is a vector that contains the dimensionality of the embeddings
% in each view
dim_vec = [size(glv, 2), size(w2v, 2)];

% Now we need to add the paths to matlab environment
addpath('src/mvlsa');
addpath('src/general_utility');
addpath('src/process_count');

% This step basically creates the a_jt_j matrices from the paper.
a_1t_1 = make_combined_embedding_impl(glv, 1e-8);
a_2t_2 = make_combined_embedding_impl(w2v, 1e-8);
M_tilde = [a_1t_1, a_2t_2];
disp(' Finished Creating ajtj ');
% Now since the matrices are not big and they can be kept in memory
% therefore we don't even need to use the mvlsa_incremental_svd code
% which expects that the individual a_jt_j have been stored to their
% individual files. Instead we can just do svd and keep the left
% singular vectors. We talk about this just before the beginning of
% section 3.1 in the paper.
[output, tmp1, tmp2]=svds(M_tilde, 300);
disp(['The output variable contains the new embeddings. Note that since ' ...
      'there are only 200 words we cant have more than 200 dimensions in ' ...
      'the final GCCA embeddings. Actually at this point we could have ' ...
      'even created the exact regularized projection matrices and just ' ...
      'done exact eigen value decomposition of their sum.']);