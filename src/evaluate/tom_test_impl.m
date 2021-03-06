function [n_total, n_attempt, n_correct_cosadd, n_correct_cosmul]=tom_test_impl(...
        word, word_map, get_emb, dataset_fn, U)
scws_file=getenv(dataset_fn);
[w1, w2, w3, w4]=textread(scws_file, '%s %s %s %s');
n_total=0;
n_attempt=0;
n_correct_cosadd=0;
n_correct_cosmul=0;
nonlinear_transform=@(x) x;
normalize_vec=@(x) x/norm(x);
for idx=1:length(w1)
    n_total=n_total+1;
    try
        p=[word_map(lower(w1{idx})), ...
           word_map(lower(w2{idx})), ...
           word_map(lower(w3{idx})), ...
           word_map(lower(w4{idx}))];
        e1=get_emb(w1{idx})'; % a
        e2=get_emb(w2{idx})'; % a-star
        e3=get_emb(w3{idx})'; % b
        e4_t=get_emb(w4{idx}); % b-star
        n_attempt=n_attempt+1;
        %% COS-ADD Method
        % e123 = normalize_vec(e3+e2-e1);
        % obj_fnc=@(x) [x*e123 zeros(size(x,1), 2)];
        % combin_fnc=@(v) v(:,1);
        % n_correct_cosadd=tom_test_impl2(obj_fnc, U, e4_t, p, n_correct_cosadd, ...
        %                                   w1, w2, w3, w4, idx, word, ...
        %                                 'cosadd', get_emb,
        %                                 combin_fnc);
        ne123=norm(e3+e2-e1);
        obj_fnc=@(x) nonlinear_transform([x*e1 x*e2 x*e3]/ne123);
        combin_fnc=@(v) v(:,3)+v(:,2)-v(:,1);
        n_correct_cosadd=tom_test_impl2(obj_fnc, U, e4_t, p, n_correct_cosadd, ...
                                        w1, w2, w3, w4, idx, word, 'cosadd', ...
                                        get_emb, combin_fnc);
        %% COS-MUL Method (It would be completely dominated by the denominator)
        % obj_fnc=@(x) [x*e1 x*e2 x*e3];
        % combin_fnc=@(v) v(:,3).*v(:,2)./(1e-4+v(:,1));
        % n_correct_cosmul=tom_test_impl2(obj_fnc, U, e4_t, p, n_correct_cosmul, ...
        %                                 w1, w2, w3, w4, idx, word, ...
        %                                 'cosmul', get_emb, combin_fnc);
    catch err
        fprintf(1, 'We had error in TOM_test %d\n', idx);
        disp(getReport(err, 'extended','hyperlinks','off'));
        continue
    end
end
end

function n_correct=tom_test_impl2(obj_fnc, U, e4_t, p, n_correct, w1, w2, ...
                                w3, w4, idx, word, tag, get_emb, combin_fnc)
    obj_over_vocab=obj_fnc(U);
    obj_over_vocab=combin_fnc(obj_over_vocab);
    keep=@(s,m) s(1:min(m,end));
    %% Find Top K Logic
    obj_e4 = obj_fnc(e4_t);
    obj_e4_orig=obj_e4;
    obj_e4 = combin_fnc(obj_e4);
    i_= obj_over_vocab > obj_e4; i_(p)=0; i=find(i_);
    %%
    if length(i)==0
        n_correct=n_correct+1;
        fprintf(1, ['+' tag ' %s %s %s %s\n'], w1{idx}, w2{idx}, w3{idx}, w4{idx});
    else
        fprintf(1, ['-' tag ' %s %s %s %s ( %d better words, eg %s)\n'],...
                w1{idx}, w2{idx}, w3{idx}, w4{idx}, length(i), ...
                word{i(1)});
        fprintf(1, '%7s\t%0.3f %0.3f %0.3f\n',keep(w4{idx},7), obj_e4_orig);
        fprintf(1, '%7s\t%0.3f %0.3f %0.3f\n',keep(word{i(1)},7), obj_fnc(get_emb(word{i(1)})));
    end
end
