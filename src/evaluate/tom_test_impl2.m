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