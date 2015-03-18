global w2v_vocab_file;
global w2v_emb_file;
global w2v_skip;
global glove_vocab_file;
global glove_emb_file;
global glove_skip;
global mvlsa_vocab_file;
global mvlsa_emb_file;
global savefile ;
global remove_mvlsa;
assert(glove_skip==0);
assert(w2v_skip==1);
w2v_vocab=textread(w2v_vocab_file, '%s', 'headerlines', w2v_skip);
w2v_vmap=containers.Map(w2v_vocab, 1:length(w2v_vocab));

glove_vocab=textread(glove_vocab_file, '%s', 'headerlines', ...
                     glove_skip);
glove_vmap=containers.Map(glove_vocab, 1:length(glove_vocab));

mvlsa_vocab=textread(glove_vocab_file, '%s', 'headerlines', glove_skip);
load(mvlsa_emb_file, 'sort_idx');
mvlsa_vocab=mvlsa_vocab(sort_idx);
%% Now merge these three vocab's into a single vocab
mvlsa_l=zeros(size(mvlsa_vocab));
w2v_l=mvlsa_l;
glove_l=w2v_l;
for i=1:length(mvlsa_vocab)
    if isKey(w2v_vmap, mvlsa_vocab{i}) && isKey(glove_vmap, ...
                                                mvlsa_vocab{i})
        mvlsa_l(i)=i;
        w2v_l(i)=w2v_vmap(mvlsa_vocab{i});
        glove_l(i)=glove_vmap(mvlsa_vocab{i});
    end
end
mvlsa_l(mvlsa_l==0)=[];
w2v_l(w2v_l==0)=[];
glove_l(glove_l==0)=[];

%% Final Vocab
word=w2v_vocab(w2v_l); % Check that its' equal to
gg=glove_vocab(glove_l);
assert(all(arrayfun(@(i) strcmp(word{i},gg{i}), 1:length(gg))));

%% Final Embedding
w2v_emb=dlmread(w2v_emb_file, '', w2v_skip, 1);
glove_emb=dlmread(glove_emb_file, '', glove_skip, 1);
if(size(glove_emb,2)==600)
    glove_emb=(glove_emb(:,1:300)+glove_emb(:,301:600))/2;
end
load(mvlsa_emb_file, 'G');
w2v_emb=w2v_emb(w2v_l,:);
glove_emb=glove_emb(glove_l,:);
mvlsa_emb=G(mvlsa_l,:); clear G; 
assert(all(size(w2v_emb)==size(glove_emb)));
assert(all(size(w2v_emb)==size(mvlsa_emb)));
%% Actually do the gcca
if remove_mvlsa==1;
    M_tilde=zeros(length(w2v_emb), 600);
else
    M_tilde=zeros(length(w2v_emb), 900);
    M_tilde(:,601:900)=mvlsa_emb; 
end
clear mvlsa_emb;
M_tilde(:,301:600)=make_combined_embedding_impl(glove_emb, 1e-8);
M_tilde(:,1:300)=make_combined_embedding_impl(w2v_emb, 1e-8);
clear( 'w2v_emb', 'glove_emb');
[emb, S_tilde, ~]=ste_rgcca(M_tilde, 300);
save(savefile, 'emb', 'word');