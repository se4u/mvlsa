function [G, S_tilde, sort_idx]=v5_generic(r, deptoload)
disp('First quickly read dimensions of big matrices by looping through files');
tic;
K=NaN; 
ajtj_col=0;
for i=1:length(deptoload)
    ajtj_size=size(matfile(deptoload{i}), 'ajtj');
    load(deptoload{i}, 'kj_diag');
    ajtj_col=ajtj_col+ajtj_size(2);
    if isnan(K)
        K=zeros(ajtj_size(1), 1);
    end
    K = K+kj_diag;
end;
Kn0=find(K~=0);
K=K(Kn0);
ajtj_row=length(Kn0); % We only need to keep Kn0 rows in memory.
toc;
disp('Now start loading the data. This process is slow.\n');
tic;
M_tilde=zeros(ajtj_row, ajtj_col);
start=1;
for i=1:length(deptoload)
    load(deptoload{i}, 'ajtj');
    ajtj=ajtj(Kn0, :); % resize the ajtj by picking rows
    %% The following three statements must remain together.
    end_=start+size(ajtj, 2)-1; 
    M_tilde(:, start:end_) = ajtj;
    start=end_+1;
end;
M_tilde=spdiags(K.^(-1/2), 0, length(K), length(K))*M_tilde;
% Make sure there are no nan
assert(~any(any(isnan(M_tilde))));
toc;
disp('starting GCCA NOW');
tic;
[G, S_tilde, ~]=ste_rgcca(M_tilde, r);
sort_idx = Kn0; % Since sort_idx is used to sort the word list we
                % set it to Kn0 so that the words and embeddings match.
toc;