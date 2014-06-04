function mrr=find_mrr(U, map, word)
% U is the embeddings matrix
% map maps the words to each other.
% I want to find the MRR of U over map
Ut=U(map(:,2),:)';
Wt=word(map(:,2));
r=NaN(1,size(map, 1));
for i=1:size(map, 1)
    d=1-U(map(i,1),:)*Ut;
    % Now we want to find rank of map(i,2)
    % (which is the ith element) amongst d
    [~, tmp]=sort(d);
    rank=find(tmp==i);
    r(i)=rank^-1;
    % disp(length(word(tmp(1:rank))));
    % disp(word(map(i,1)));
    % disp(word(map(i,2)));
end
mrr=mean(r);