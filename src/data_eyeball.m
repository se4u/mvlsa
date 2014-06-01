global embedding;
global mapping; % The array which maps rows to other rows for CCA
global word; % The cell array that contains word for all the
              % emebeddings
global debug;

embedding=embedding-repmat(mean(embedding), size(embedding, 1), 1);
for i=1:size(embedding, 1)
    embedding(i,:)=embedding(i,:)/norm(embedding(i,:));
end
index_in_embedding=@(w) find(strcmp(w, word));
index_of_paraphrase=@(idx) unique(mapping(mapping(:,1)==idx, 2));
distance_btw_embeddings=@(i,j)embedding(i,:)*embedding(j,:)';
which_words_are_more_similar=...
    @(i, d) (embedding*embedding(i,:)' > d);
% How many other words come between these words ? 
find_nn_rank=@(i, j) ...
    sum(which_words_are_more_similar(i, embedding(i,:)*embedding(j,:)'))-1;
%% I want to find to which word are dog, cheese, walk and kill
% mapped to ?
for w = {'dog', 'cheese', 'walk', 'kill'}
    i=index_in_embedding(w);
    fprintf(1, '%s\n', word{i});
    i_para=index_of_paraphrase(i);
    for j = 1:length(i_para)
        j=i_para(j);
        fprintf(1, '\t%s, ', word{j});
        d=distance_btw_embeddings(i, j);
        wwas=which_words_are_more_similar(i,d);
        wwas(i)=0;
        wwas(j)=0;
        wwas=find(wwas);
        s=length(wwas);
        fprintf(1, '%d, ', s+1);
        for ii=1:min(s, 20)
            fprintf(1, '%s ', word{wwas(randi(s))});
        end
        fprintf(1, '\n');
    end
end

%% I now label the words.
vocab_size=size(embedding,1);
[label, number_of_class, label_to_freq_map]= ...
    undirected_floodfill(mapping, vocab_size);
% I want to see which label has the highest number of members
label_max=label(label_to_freq_map==max(label_to_freq_map));


% I want to see which word belong to these labels
w=word(label==label_max);
lw=length(w);
disp(sprintf('The number of words in the largest group = %d', lw));
for ii=1:min(30, lw)
    fprintf(1, '%s, ', w{randi(lw)});
end