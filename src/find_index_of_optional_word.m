function i=find_index_of_optional_word(cl)
    for i=1:length(cl)
        c=cl{i};
        if c(1)=='[' && c(end)==']'
            break
        end
    end
end