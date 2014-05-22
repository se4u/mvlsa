function [numclass, nummem]=ppdb_class_stats(ppdb_size, vocab_size)
mappath='res/gn_ppdb_lex_%s_paraphrase';
mapping=dlmread(sprintf(mappath, ppdb_size),'',0, 2);
[label, ~, ~, ~, number_of_classes]=undirected_floodfill(mapping, ...
                                                  vocab_size);
tmp=tabulate(label);
label_to_freq_map=tmp(:,2);
b=tmp((tmp(:,2)~=0),2);
bb=tabulate(b);
bbc=bb(bb(:,2)~=0,:);
nummem=bbc(:,1);
numclass=bbc(:,2);

% 72427           1
%  4365           2
%   447           3
%    77           4
%     7           5

% 36002           1
%  5903           2
%  1770           3
%   792           4
%   402           5
%   236           6
%   133           7
%    91           8
%    58           9
%    45          10
%    35          11
%    26          12
%    29          13
%    12          14
%    16          15
%    12          16
%     4          17
%     8          18
%     5          19
%     5          20
%     4          21
%     3          22
%     2          23
%     1          24
%     1          25
%     1          27
%     3          28
%     3          30
%     1          31
%     1          32
%     1          33
%     1          34
%     1          35
%     1          37
%     2          40
%     1          44
%     1          45
%     1          47
%     1       17553

%  3689           1
%  2320           2
%   530           3
%   196           4
%    83           5
%    43           6
%    21           7
%    12           8
%     6           9
%     1          10
%     4          11
%     2          12
%     2          13
%     2          14
%     1          16
%     1       71020