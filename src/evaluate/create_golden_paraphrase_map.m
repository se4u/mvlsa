function golden_paraphrase_map= ...
    create_golden_paraphrase_map(wordnet_test_filename, word)
%% Create Golden_paraphrase_map
[w1 w2]=textread(wordnet_test_filename, '%s %s');
M=NaN(length(w1), 2);
for i=1:length(w1)
    i1=find(strcmp(word, w1(i)));
    i2=find(strcmp(word, w2(i)));
    if ~isempty(i1) && ~isempty(i2)
        M(i,:)=[i1, i2];
    end;
end;
M(isnan(M))=[];
M= reshape(M, numel(M)/2, 2);
golden_paraphrase_map=M;
