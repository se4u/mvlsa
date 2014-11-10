function [cl i] = get_question(cl)
    cl=cl(2:end);
    i=find_index_of_optional_word(cl);
    cl{i}=0;
end
