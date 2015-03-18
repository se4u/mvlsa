% HELP 1
function embedding=normalize_embedding(embedding)
for i=1:size(embedding, 1)
    embedding(i,:)=embedding(i,:)/norm(embedding(i,:));
end