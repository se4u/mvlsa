function [view1, view2]=view_preparor(vocab_relation_count, width, ...
                                      embedding, mapping)
tic;
view1=zeros(vocab_relation_count, width);
view2=zeros(vocab_relation_count, width);

for i=1:vocab_relation_count
    view1(i,:)=embedding(mapping(i, 1), :);
    view2(i,:)=embedding(mapping(i, 2), :);
end
disp(sprintf('input prepared in %f', toc));
