function write_embedding_to_file2(matfilename)
embname=[matfilename(1:length(matfilename)-3) 'emb.ascii'];
wordname=[matfilename(1:length(matfilename)-3) 'word.ascii'];
disp(wordname);
load(matfilename);
save(embname, 'emb', '-ascii');
fid=fopen(wordname, 'w');
for i=1:length(word)
    fprintf(fid, '%s\n', word{i});
end
fclose(fid);