function [mrr, rank_cell]=find_mrr(U, map, word)
% U is the embeddings matrix
% map maps the words to each other.
fprintf(1, 'The actual test set length is %d\n', length(map));
fprintf(1, 'The MRR is calc over %d\n', size(U, 1));
Ut=U(map(:,2),:)'; % This is the true best paraphrase.
len_map=size(map, 1);
r=NaN(1,len_map);
rank_cell=cell(len_map, 2);
for i=1:len_map
    d=1-U(map(i,1),:)*Ut;
    % Now we want to find rank of map(i,2)
    % (which is the ith element) amongst d
    [~, tmp]=sort(d);
    rank=find(tmp==i);
    rank_cell{i, 1}=word{map(i,1)};
    rank_cell{i, 2}=word{map(i,2)};
    rank_cell{i, 3}=rank;
    r(i)=rank^-1;
end
mrr=mean(r);