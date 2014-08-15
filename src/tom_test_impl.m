function [n_total, n_attempt, n_correct]=tom_test_impl(...
        word, word_map, get_emb, dataset_fn, U)
scws_file=getenv(dataset_fn);
[w1, w2, w3, w4]=textread(scws_file, '%s %s %s %s');
n_total=0;
n_attempt=0;
n_correct=0;
for idx=1:length(w1)
    n_total=n_total+1;
    try
        p=[word_map(lower(w1{idx})), ...
           word_map(lower(w2{idx})), ...
           word_map(lower(w3{idx})), ...
           word_map(lower(w4{idx}))];
        e1=get_emb(w1{idx});
        e2=get_emb(w2{idx});
        e3=get_emb(w3{idx});
        e4=get_emb(w4{idx});
        e123 = (e3+e2-e1);
        e123=e123/norm(e123);
        e123_t = e123';
        %% check whether there is any other word which
        %%  is closer to e124 than e3
        max_cosim = e4*e123_t;
        i_=U*(e123_t) > max_cosim;
        i_(p)=0; i=find(i_);
        %% 
        n_attempt=n_attempt+1;
        if length(i)==0
            n_correct=n_correct+1;
            fprintf(1, '+ %s %s %s %s\n', w1{idx}, w2{idx}, w3{idx}, w4{idx});
        else
            fprintf(1, '- %s %s %s %s ( %d better words, eg %s)\n',...
                    w1{idx}, w2{idx}, w3{idx}, w4{idx}, length(i), word{i(1)});
        end
    catch err
        fprintf(1, 'We had error in TOM_test %d\n', idx);
        continue
    end
end
