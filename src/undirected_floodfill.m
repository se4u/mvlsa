function [labels, mapped_labels, singletons, singleton_start, number_of_classes]=undirected_floodfill(mapping, vocab_size)
% Mapping contains numbers between 1 and vocab_size.
% It has only two columns.
% labels is a vector of length vocab_size and mapped_labels is a
% vector of length= rows in mapping.
% singletons are the number of classes with a single member. That
% is they never occured in the mapping and these points are not
% related to anything else. 
% singleton_start is the lowest index of amongst the singleton
% classes all singleton classes have label equal to or higher than this.
%{ 
[a,b]=undirected_floodfill([1 2; 3 1; 4 5; 5 6; ], 6);
assert(all(a==[1,1, 1, 2, 2, 2]));
assert(all(b==[1, 1, 2, 2]));
%}
rows=size(mapping, 1);
labels=NaN(vocab_size,1);
max_label=0;
first_element=@(idx) mapping(idx, 1);
second_element=@(idx) mapping(idx, 2);
has_label=@(elem, labels) ~isnan(labels(elem));
for idx=1:rows
    fe=first_element(idx);
    fl=NaN;
    if has_label(fe, labels)
        fl=labels(fe);
    else
        max_label=max_label+1;
        labels(fe)=max_label;
        fl=max_label;
    end
    assert(~isnan(fl));
    se=second_element(idx);
    if has_label(se, labels)
        sl=labels(se);
        if fl == sl
            % Do nothing
        else
            labels(labels==max(fl, sl))=min(fl, sl);
        end
    else
        labels(se)=fl;
    end
end
singletons=0;
singleton_start=max_label+1;
for i=1:vocab_size
    if isnan(labels(i))
        singletons=singletons+1;
        max_label=max_label+1;
        labels(i)=max_label;
    end
end
number_of_classes=max_label;
mapped_labels=NaN(size(mapping,1), 1);
for i=1:length(mapped_labels)
    mapped_labels(i)=labels(mapping(i, 1));
end
assert(~all(labels==1));