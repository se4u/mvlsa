function [n_total, n_attempt, n_correct]=tom_test_impl(...
        word, get_emb, dataset_fn, U)
scws_file=getenv(dataset_fn);
[w1, w2, w3, w4]=textread(scws_file, '%s %s %s %s');
n_attempt=0;
for idx=1:length(w1)
    try
        e1=get_emb(w1{idx});
        e2=get_emb(w2{idx});
        e3=get_emb(w3{idx});
        e4=get_emb(w4{idx});
        e123 = e1-e2 +e3;
        max_allowed_cos_sim = sum(e123.*e4);
        % check whether there is any other word which is closer to e123
        % than e4.
        i=find(U*(e123') > max_allowed_cos_sim);
        n_attempt=n_attempt+1;
        if length(i)==0
            n_correct=n_correct+1;
            fprintf(1, '+ %s %s %s %s', w1{idx}, w2{idx}, w3{idx}, w4{idx});
        else
            fprintf(1, '- %s %s %s %s (We found %d better words like %s)\n',...
                    w1{idx}, w2{idx}, w3{idx}, w4{idx}, length(i), word{i(1)});
        end
    catch err
        fprintf(1, 'We had error in TOM_test %d\n', idx);
        continue
    end
    
end
