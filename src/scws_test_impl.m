function [n_total, n_attempt, scws_correlation]=scws_test_impl( ...
                                                  word, get_emb, fn)
scws_file=getenv(fn);
[w1, w2, true_simil]=textread(scws_file, '%s %s %f');
assert(size(true_simil, 2)==1);
pred_simil=zeros(length(true_simil), 1);
n_total=length(pred_simil);
n_attempt=0;
for i=1:n_total
    try
    e1=get_emb(w1{i});
    e2=get_emb(w2{i});
    pred_simil(i)=sum(e1.*e2);
    n_attempt=n_attempt+1;
    fprintf(1, '%s %s %d %d\n', w1{i}, w2{i}, pred_simil(i), true_simil(i));
    catch err
        pred_simil(i)=0;
    end
end
scws_correlation=corr(pred_simil, true_simil, 'type', 'Pearson');