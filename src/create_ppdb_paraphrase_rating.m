function ppdb_paraphrase_rating=create_ppdb_paraphrase_rating(ppdb_paraphrase_rating_filename,word)
[w1 w2 sc]=textread(ppdb_paraphrase_rating_filename, '%s %s %d', 'delimiter', '\t');
M=NaN(length(w1), 3);
for i=1:length(w1)
    i1=find(strcmp(word, w1(i)));
    i2=find(strcmp(word, w2(i)));
    if ~isempty(i1) && ~isempty(i2)
        M(i,:)=[i1 i2 sc(i)];
    end;
end;
M(isnan(M))=[];
M= reshape(M, numel(M)/3, 3);
ppdb_paraphrase_rating=M;