function arr = turn_into_distrib_view(sentence, big_word_map, k)
    nr=length(big_word_map);
    nc=nr+15;
    arr=spalloc(nr, nc, length(sentence));
    for i=1:length(sentence)
        try
            wid=big_word_map(lower(sentence{i}));
        catch
            continue
        end
        tmp=i-k;
        if tmp < 1
            context_id=nr-tmp+1;
        else
            try
                context_id=big_word_map(lower(sentence{tmp}));
            catch
                continue
            end
        end
        arr(wid, context_id)=arr(wid, context_id)+1;
    end
end