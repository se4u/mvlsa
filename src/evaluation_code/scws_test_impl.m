function [n_total, n_attempt, pred_simil, true_simil]=scws_test_impl( ...
                                                  word, get_emb, fn)
scws_file=getenv(fn);
[w1, w2, true_simil]=textread(scws_file, '%s %s %f');
assert(size(true_simil, 2)==1);
pred_simil=zeros(length(true_simil), 1);
n_total=length(pred_simil);
n_attempt=0;
for i=1:n_total
    try
        % So it is over here that I try to find the embedding of a
        % word. And if I dont find it then I fail.
        % Ideally If I dont find it then I'd impute the embedding by 
        % trying to find its distributional signature in the
        % original matrices, and then using the projection matrices
        % that I have learnt to project them to 
    e1=get_emb(lower(w1{i}));
    e2=get_emb(lower(w2{i}));
    pred_simil(i)=sum(e1.*e2);
    n_attempt=n_attempt+1;
    fprintf(1, '%s %s %d %d\n', w1{i}, w2{i}, pred_simil(i), true_simil(i));
    catch err
        pred_simil(i)=0;
    end
end