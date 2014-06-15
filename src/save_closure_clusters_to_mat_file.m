cd /home/prastog3/projects/mvppdb;
addpath src;
mapping_s=dlmread('res/gn_ppdb_lex_s_paraphrase','', 0, 2);
word=textread('res/gn_intersect_ppdb_word', '%s');
mapping_l=dlmread('res/gn_ppdb_lex_l_paraphrase','', 0, 2);
[label_s, number_of_classes_s, label_to_freq_map_s]=undirected_floodfill(mapping_s, length(word));
[label_l, number_of_classes_l, label_to_freq_map_l]=undirected_floodfill(mapping_l, length(word));
assert(length(label_s)==length(word));
assert(length(label_l)==length(word));
save('/export/a15/prastog3/pr2fr_ppdb_closure.mat', 'label_s', 'label_l', 'word');
disp(word(label_s==2))

%{ans = 

    '$'
    'dollars'
%}
word(label_s==3)
%{
ans = 

    'last'
    'past'
%}

word(label_s==4)
%{
ans = 

    'people'
    'persons'
%}
