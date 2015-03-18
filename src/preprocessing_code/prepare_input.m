function [view1, view2, words] = prepare_input(filename, columns)
wordsfile=[filename '_word'];
arr=dlmread(filename, '', 1, columns);
words=textread(wordsfile, '%s');
view1 = arr(1:2:size(arr,1),:);
view2 = arr(2:2:size(arr,1),:);
assert(all(size(view1)==size(view2)));
