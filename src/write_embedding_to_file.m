function write_embedding_to_file(U, word, filename)
l=size(U,1);
dim=size(U,2);
fid = fopen(filename, 'w+');
fprintf(fid, '%d %d\n', l, dim);
fspec=[repmat(' %.6f', 1, dim) '\n'];
for i=1:l
    fprintf(fid, '%s', word{i});
    fprintf(fid, fspec, U(i,:));
end
fclose(fid);