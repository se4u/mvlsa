.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate 
.INTERMEDIATE: gn_ppdb.itermediate

MATCMD := LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 time matlab -nodisplay -r "warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src');addpath('src/kdtree'); "
# QSUBCMD := qsub -V -j y -l mem_free=20G -r yes #-verify
QSUBCMD := echo 
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
tabulate_extrinsic_test: log/extrinsic_test_s_0 log/extrinsic_test_l_0   log/extrinsic_test_s_1 log/extrinsic_test_l_1
	python src/tabulate_extrinsic_test.py $+

extrinsic_test: log/extrinsic_test_s_1 log/extrinsic_test_s_0 log/extrinsic_test_l_1 log/extrinsic_test_l_0

# After all the previous experimentation now I am ready to pick a
# configuration and to do the pre and pos test on that particular
# confiugration. By looking at all the data I decided to use 150 as
# the optimal number of CCA dimensions to keep. By doing this I am
# doing a dimensionality reduction of exactly half which is great. 
# Note that the cosine distance does not do any mean centralization
# which is fine because the embeddings are any way mean centered.
# Also note that cosine distance does divide by the norm of the
# embeddings.
# So the settings are: 
# db = s l xxl
# Uniquify or not before CCA (For Baseline)
# # No longer I need knnK, dim2keep, doavgk. do_knn_only_over_original_embedding (because I do over both all the time) # I dont dist because dist = cosine
# I also checked use_unique_mapping
# log/large_scale_cca_[sl]_cosine_1_0_0_1_170_1_[10]
#     large_scale_cca_[sl]_cosine_1_0_(170|90)_0_0_1_[10]
#     large_scale_cca_[sl]_cosine_1_1_0_0_0_1_[10]
log/extrinsic_test_%: $(STORE)/gn_intersect_ppdb_embeddings.mat res/filtered_paraphrase_list_wordnet.mat res/ppdb_paraphrase_rating_filtered.mat
	$(MATCMD)"load('$<'); load('res/filtered_paraphrase_list_wordnet.mat'); load('res/ppdb_paraphrase_rating_filtered.mat'); word=textread('res/gn_intersect_ppdb_word', '%s'); options=strsplit('$*', '_'); ppdb_size=options{1}; use_unique_mapping=str2num(options{2}); mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); dimension_after_cca=150; distance_method='cosine'; conduct_extrinsic_test; exit;" | tee $@

res/ppdb_paraphrase_rating_filtered.mat: res/ppdb_paraphrase_rating
	$(MATCMD)"[w1 w2 sc]=textread('$<', '%s %s %d', 'delimiter', '\t'); word=textread('res/gn_intersect_ppdb_word', '%s'); M=NaN(length(w1), 3); for i=1:length(w1) i1=find(strcmp(word, w1(i))); i2=find(strcmp(word, w2(i))); if ~isempty(i1) && ~isempty(i2) M(i,:)=[i1 i2 sc(i)]; end; end; M(isnan(M))=[];M= reshape(M, numel(M)/3, 3); ppdb_paraphrase_rating=M; save('$@', 'ppdb_paraphrase_rating'); exit;"

res/ppdb_paraphrase_rating: res/pred-scored-human-ppdb.txt
	python src/preprocess-pred-scored-human-ppdb.py $< > $@

res/filtered_paraphrase_list_wordnet.mat: res/wordnet.test
	$(MATCMD)"[w1 w2]=textread('$<', '%s %s'); word=textread('res/gn_intersect_ppdb_word', '%s'); M=NaN(length(w1), 2); for i=1:length(w1) i1=find(strcmp(word, w1(i))); i2=find(strcmp(word, w2(i))); if ~isempty(i1) && ~isempty(i2) M(i,:)=[i1, i2]; end; end; M(isnan(M))=[];M= reshape(M, numel(M)/2, 2); golden_paraphrase_map=M; save('$@', 'golden_paraphrase_map'); exit;"

# res/filtered_paraphrase_list_moby_thes_%.mat: res/paraphrase_list_moby_thes_%
# 	$(MATCMD)"[w1 w2]=textread('$<', '%s %s'); word=textread('res/gn_intersect_ppdb_word', '%s'); M=NaN(length(w1), 2); for i=1:length(w1) i1=find(strcmp(word, w1(i))); i2=find(strcmp(word, w2(i))); if ~isempty(i1) && ~isempty(i2) M(i,:)=[i1, i2]; end; end; M(isnan(M))=[];M= reshape(M, numel(M)/2, 2); golden_paraphrase_map=M; save('$@', 'golden_paraphrase_map'); exit;"

# res/paraphrase_list_moby_thes_%: res/mthesaur.txt
# 	python src/random_paraphrastic_words.py $< $*  > $@

data_eyeball_%:
	$(MATCMD)"load('/export/a15/prastog3/gn_intersect_ppdb_embeddings.mat'); mapping=dlmread('res/gn_ppdb_lex_$*_paraphrase','', 0, 2); word=textread('res/gn_intersect_ppdb_word', '%s'); cd src; debug=1; data_eyeball; exit;"

log/gridrun_log_tabulate: log/gridrun 
	python src/gridrun_log_tabulate.py | tee $@

qstat:
	qstat | cut -c 73-75 | sort | uniq -c

# These are jobs with changing ppdb size and whether I am using unique
# mapping or not. The basic purpose is to find out whether things work
# better or not ?
slapdash_14: 
	make log/large_scale_cca_l_cosine_1_0_0_1_170_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_1_1 && \
	make log/large_scale_cca_l_cosine_1_0_0_1_170_1_0 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_1_0 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_1_0 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_1_0 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_1_0 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_1_0 &&\
	make log/large_scale_cca_s_cosine_1_0_90_0_0_1_0 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_1_0

slapdash:
	make log/large_scale_cca_s_cosine_1_0_90_0_0_0_1 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_0_1 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_0_1 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_0_1 &&\
	make log/large_scale_cca_s_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_0_1 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_0_1 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_0_1 &&\
	make log/large_scale_cca_l_cosine_1_0_0_1_170_0_1 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_0_1_170_1_1 

log/gridrun:
	for db in s ; do \
	 for dist in cosine ; do \
	  for knnK in 1  ; do \
	   for uum in 0 1 ; do \
            for doavgk in 1 ; do\
	     for dim2keep in  90 170 ; do \
                $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_0_"$$dim2keep"_0_0_"$$uum"_"$$doavgk" -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_0_"$$dim2keep"_0_0_"$$uum"_"$$doavgk" ;\
             done;\
	     $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_1_0_0_0_"$$uum"_"$$doavgk" -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_1_0_0_0_"$$uum"_"$$doavgk" ; \
	     for dim2append in 170 ; do \
	        $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_0_0_1_"$$dim2append"_"$$uum"_"$$doavgk" -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_0_0_1_"$$dim2append"_"$$uum"_"$$doavgk" ;\
	     done;\
            done;\
	   done;\
	  done;\
	 done;\
	done 

# TARGET : Now do CCA over embeddings. The second file contains the
# mapping. Currently it has 660584 rows. There are 2 arrays each with
# 660584 rows and 300 columns. So the total memory requirement is
# 497,046,000 (doubles 8 Bytes) == 3GB. (4 GB for xxl) After running
# CCA. I get new embeddings and then I need to run KNN.

# EXAMPLE: $(STORE)/large_scale_cca_xxl_euclidean_1_10_1
# The first is size of ppdb, then the distance method then knnK then the
# dimensions to keep and then whether to do it over
# original embedding or the CCA ones. You only need to do CCA over
# original embeddings once. 
log/large_scale_cca_%: $(STORE)/gn_intersect_ppdb_embeddings.mat # res/gn_ppdb_lex_s_paraphrase res/gn_ppdb_lex_l_paraphrase res/gn_ppdb_lex_xl_paraphrase res/gn_ppdb_lex_xxl_paraphrase
	$(MATCMD)"load('$<'); options=strsplit('$*', '_'); ppdb_size=options{1}; distance_method=options{2}; knnK=str2num(options{3}); do_knn_only_over_original_embedding=str2num(options{4}); dimension_after_cca=str2num(options{5}); do_append=str2num(options{6}); dim2append=str2num(options{7}); use_unique_mapping=str2num(options{8}); do_average_knn=str2num(options{9}); mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); large_scale_cca; exit" | tee $@

# $(STORE)/gn_intersect_ppdb_embeddings.mat : $(STORE)/gn_intersect_ppdb_embeddings
# 	$(MATCMD)"embeddingdlmread('$<', ,'', 0, 1); save('$<.mat','embedding');exit;"

src/top.mexa64: src/top.cpp
	mex -o src/top.mexa64 src/top.cpp

# TARGET : Contains paraphrases for the words that were in SOURCE. The
# paraphrases themselves must also be in the SOURCE.
# The output file is source, index, paraphrase, index
# and the indexing starts with 1.
# The sampling scheme itself is coded in java. (I dont do uniform
# because I want to bring the information that PPDB is providing to
# the embeddings.)
res/gn_ppdb_lex_%_paraphrase: res/gn_intersect_ppdb_word 
	python src/get_paraphrase.py $< 10 $* > $@

# TARGET : Just the words from the gn_intersect_ppdb file
res/gn_intersect_ppdb_word: $(STORE)/gn_intersect_ppdb_embeddings
	awk '{print $$1}' $+ > $@

$(STORE)/gn_intersect_ppdb_embeddings : $(STORE)/gn_intersect_ppdb_embeddings.gz
	zcat $+ > $@

# TARGET : Contains embeddings of overlapping words in Google News
# Vectors and the PPDB lexical words. The first column is the
# word. currently the number of common words is 56870. zcat TARGET | wc -l
# In Both  82841
# In Google not in PPDB 2917159 (Skewed because contains phrases)
# In PPDB not in Google 42406
# PPDB has 125,247 words
# Google has 3 Million Phrases and roughly 300k words.
# This also builds res/in_google_not_in_ppdb res/in_ppdb_not_in_google
$(STORE)/gn_intersect_ppdb_embeddings.gz : $(STORE)/gn300.txt $(STORE)/PPDB_Lexical_Data/ppdb-1.0-xxxl-lexical-words-uniq 
	PYTHONPATH=$$PWD/src/:$$PYTHONPATH python src/overlap_between_google_and_ppdb.py $+ $(STORE)/gn_intersect_ppdb_embeddings.gz

# $(STORE)/gn300.txt.gz : $(STORE)/gn300.txt
# 	gzip -c $+ > $@

$(STORE)/gn300.txt: $(STORE)/GoogleNews-vectors-negative300.bin res/convertvec
	./res/convertvec bin2txt $<  $@ 

$(STORE)/GoogleNews-vectors-negative300.bin: $(STORE)/GoogleNews-vectors-negative300.bin.gz
	gunzip -c $< > $@

res/convertvec : src/convertvec.c
	$(CC) $+ -o $@ $(CFLAGS)

optimal_cca_dimension_table: optimal_cca_dimension.log
	awk '{if( (NR - 3)%13==0 || (NR - 5)%13==0 ||(NR - 6)%13==0 ||(NR - 8)%13==0){printf "%s  ", $$1} else if((NR - 11)%13==0 ){print $$0}}' $^ | tee $@

optimal_cca_dimension.log:
	for i in 1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70; do  make cca_over_rnnlm_knn_$$i | awk '{if(NR == 1 || NR > 34){print $$0}}' >> $@ ; done

cca_over_rnnlm_knn_%: res/rnnlm_synonym_embedding res/rnnlm_synonym_embedding_word
	$(MATCMD)"filename='res/rnnlm_synonym_embedding'; columns=1; dimension_after_cca=$*; cca_and_f_pushpendre ;exit"

cca_over_lsh_embeddings_%: res/ben_synonym_embedding res/ben_synonym_embedding_word
	$(MATCMD)"filename='res/ben_synonym_embedding'; columns= $*; dimension_after_cca=2; cca_and_f_pushpendre;exit"

## Random Embedding and Random partition Baselines. The purpose of
## these two sorts of experiments is always to find out what is the
## absolute baseline for the metric that you are using to test your
## technique. 
random_partition_rnnlm_cca.png: res/rnnlm_synonym_embedding res/rnnlm_synonym_embedding_word
	$(MATCMD);"filename='res/rnnlm_synonym_embedding'; columns=1; dimension_after_cca=2; random_embedding_cca;exit;"

random_embedding_cca.png:
	$(MATCMD)"filename='res/rnnlm_synonym_embedding'; columns=1; dimension_after_cca=2; random_embedding_cca;exit;"

###########################################################################################
# TARGET : Contains just the words. extracted from the first column of the source
CMD3 = awk '{if(NR > 1){print $$1}}' $+ > $@
%_word: %
	$(CMD3)
##############################################################################################
# TARGET : This file contains synonyms on the even and odd lines like 1-2 and 3-4 are synonyms.
#          Its length is decided below.
# SOURCE : It uses the synonyms pairs and locations and the original embeddings file.
CMD2 = python src/properly_arrange_synonym_embedding_to_feed_matlab.py $+
res/ben_synonym_embedding: res/ben_synonym_pair_and_location res/ben_lsh_projection_of_rnnlm_vocab
	$(CMD2) explode > $@

res/rnnlm_synonym_embedding:  res/rnnlm_synonym_pair_and_location res/rnnlm_word_projection-80
	$(CMD2) > $@
###############################################################################################
# TARGET : Contains 1 pair of synonyms per line and their line location in the source file
# SOURCE : Table of embeddings where the first column is the word and the rest are the embedding.
CMD1 = python src/get_synonym_pair_and_location.py $+ 2>/dev/null | head -n 2000 > $@
res/ben_synonym_pair_and_location: res/ben_lsh_projection_of_rnnlm_vocab_word
	$(CMD1)
res/rnnlm_synonym_pair_and_location:  res/rnnlm_word_projection-80_word
	$(CMD1)
