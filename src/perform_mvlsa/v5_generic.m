% THIS FUNCTION IS DEPRECATED REPLACE IT BY v5_generic_tmp and
% rename in the makefile
function [G, S_tilde, sort_idx]=v5_generic(r, deptoload, min_view_to_accept_word)
% r is the number of gcca components that we want.
% deptoload is a cell that contains mat file names.
% min_view_to_accept_word is a threshold over the number of views
% that a particular word must appear in. I am overloading
% min_view_to_accept_word so that if its is greater than 50000
% then it means that its the top vocabulary that I want to keep
%% First Read dimensions of matrices to allocate space.
tic;
disp('First quickly read dimensions of big matrices by looping through files');
  K=NaN; 
  ajtj_col=0;
  ajtj_row=0;
  kj_cell={};
  for i=1:length(deptoload)
      ajtj_size=size(matfile(deptoload{i}), 'ajtj');
      load(deptoload{i}, 'kj_diag');
      kj_cell{i}=kj_diag;
      ajtj_row=ajtj_size(1);
      ajtj_col=ajtj_col+ajtj_size(2);
      if isnan(K)
          K=zeros(ajtj_size(1), 1);
      end
      K = K+kj_diag;
  end;
toc;

% Now I would find whether there are any words which are
% completely absent(or highly sparse). For example the <<N>>> So
% we remove the rows that were highly sparse. For now the criteria
% is that the words must have been observed in atleast 30 rows.
% That reduces the number of rows that I use for GCCA to 73K. And
% then I can perform GCCA.
% K_acc means K_acceptable
if min_view_to_accept_word < 100
    logical_acceptable_rows=(K>=min_view_to_accept_word);
elseif min_view_to_accept_word < 50000
    disp(['Dont know what to do with min_view_to_accept_word = '
          num2str(min_view_to_accept_word)]);
    exit(1);
else
    for idx=1:length(deptoload)
        if sum(K>=idx) < min_view_to_accept_word
            break;
        end
    end
    logical_acceptable_rows=(K>=(idx-1));
end
assert(sum(logical_acceptable_rows)>0);
K=K(logical_acceptable_rows); 
%% Now Start loading data
tic;
disp('Now start loading the data. This process is slow.\n');
  M_tilde=zeros(length(K), ajtj_col);
  start=1;
  for i=1:length(deptoload)
      load(deptoload{i}, 'ajtj');
      ajtj=ajtj(logical_acceptable_rows,:);
      %% The following three statements must remain together.
      end_=start+size(ajtj, 2)-1; 
      M_tilde(:, start:end_) = ajtj;
      start=end_+1;
  end;
toc;
assert(nnz(M_tilde)>0);
assert(~any(any(isnan(M_tilde))));
M_tilde=spdiags(K.^(-1/2), 0, length(K), length(K))*M_tilde;
assert(nnz(M_tilde)>0);
assert(~any(any(isnan(M_tilde))));
clear kj_cell;
clear ajtj;
disp('starting GCCA NOW');
%% Now do the GCCA after checking for NaNs 
tic;
   [G, S_tilde, ~]=ste_rgcca(M_tilde, r);
   sort_idx=logical_acceptable_rows; 
toc;
