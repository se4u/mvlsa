.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input 
.INTERMEDIATE: gn_ppdb.itermediate

## GENERIC 
# TARGET : Contains just the words. extracted from 1st column of source
%_word: %
	awk '{print $$1}' $+ > $@
qstat:
	qstat | cut -c 73-75 | sort | uniq -c

## VARIABLES
# LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 addpath('src/kdtree');
MATCMD := time matlab -nojvm -nodisplay -r "warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src'); "
QSUBCMD := qsub -V -j y -l mem_free=5G -r yes #-verify
# QSUBCMD := echo 
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
STORE2 := /export/a14/prastog3
BIG_LANG := ar cs de es fr zh 
BIG_INPUT := $(addprefix $(STORE2)/ppdb-input-simplified-,$(BIG_LANG))
BIG_INPUT_WORD := $(addsuffix _word,$(BIG_INPUT))
BIG_ALIGN_MAT := $(patsubst %,$(STORE2)/align_%.mat,$(BIG_LANG))
SVD_DIM := 500
PREPROCESS_OPT := Count logCount


run_on_grid_bitext_extrinsic_test:
	for i in 50 100 150 200 250 ; do for t in logCount Count; do \
          $(QSUBCMD) -cwd submit_grid_stub.sh log/bitext_extrinsic_test_300_7000_1e-8_"$$t"."$$i" ; \
	done ; done

# TARGET: log/bitext_extrinsic_test_300_7000_1e-8_logCount.150 log/bitext_extrinsic_test_300_7000_1e-8_Count.150
# SOURCE: 
log/bitext_extrinsic_test_%: $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word res/wordnet.test res/ppdb_paraphrase_rating $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_Count.mat $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_logCount.mat
	$(MATCMD)"options=strsplit('$*','.'); load(sprintf('$(STORE2)/gcca_run_sans_mu_%s', options{1})); dimension_after_cca=str2num(options{2}); load('$(word 1,$+)'); word=textread('$(word 2,$+)', '%s'); wordnet_test_filename='$(word 3,$+)'; ppdb_paraphrase_rating_filename='$(word 4,$+)'; G=G'; sort_idx=sort_idx'; word=word(sort_idx); bvgn_count=bvgn_count(sort_idx); bvgn_embedding=bvgn_embedding(sort_idx,:);bitext_true_extrinsic_test;exit; " | tee $@

# TARGET: this creates things like /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_logCount.mat
#       :                     and  /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat
# SOURCE: this creates things like /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat
submit_gcca_run_sans_mu_to_grid: # I can experiment with 300_10000 (and higher) or 500_1000 (or higher)
	for transform in Count logCount; \
	    do $(QSUBCMD) -pe smp 25 -cwd submit_grid_stub.sh $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_"$$transform" ; done
# TARGET: A Typical run would 300_1000_1e-8 (300 is the number of principal vectors, 1000 is the batch size, (the higher the better))
# SOURCE : A mat file containing S, B, Mu1, Mu2 which contain the arabic, chinese, english bitext data
GCCA_RUN_SANS_MU_CMD = $(MATCMD)"options=strsplit('$*', '_'); r=str2num(options{1}); b=str2num(options{2}); load $<;svd_reg_seq=str2num(options{3})*ones(size(S)); [G, S_tilde, sort_idx]=se_gcca(S, B, r, b, svd_reg_seq); tic; save('$@', 'G', 'S_tilde', 'sort_idx'); toc; exit; "
$(STORE2)/gcca_run_sans_mu_%_logCount: $(STORE2)/gcca_result_svd_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/gcca_run_sans_mu_%_Count: $(STORE2)/gcca_result_svd_500_Count.mat
	$(GCCA_RUN_SANS_MU_CMD)

# SOURCE: A small test file to practice doing se_gcca.
test_gcca_run: res/tmp_bitext_svd.mat
	$(MATCMD)"load $<; S={s}; B={b}; [G, S_tilde]=se_gcca(S, B, 10, 2, [1e-8]); U_tilde=S'; exit;"

## Make the sparse cooccurence matrix of english. using the full
#vocabulary. In fact dont even need to store in memory just write to
#file all the time. I would once again have to use  sort -n | uniq -c
#trick because the data is gonna be large and I would be doing append
#only

# TARGET: A single mat file containing S, B, mu1 and mu2 arrays in a cell
# SOURCE:
GCCA_RESULT_SVD_MAT_DEP = $(foreach lang,$(BIG_LANG),$(STORE2)/bitext_svd_$(lang)_%.mat)
GCCA_RESULT_TODO = $(patsubst %,load %; B=[B b]; S=[S s]; Mu1=[Mu1 full(mu1)]; Mu2=[Mu2 full(mu2)]; whos;,$+)
$(STORE2)/gcca_result_svd_%.mat: $(GCCA_RESULT_SVD_MAT_DEP)
	$(MATCMD)"tic; S={}; B={}; Mu1={}; Mu2={}; $(GCCA_RESULT_TODO) save('$@', 'S', 'B', 'Mu1', 'Mu2', '-v7.3'); toc; exit;"


# TARGET: A way to submit bitext_svd_%.mat jobs to the grid
submit_bitextsvd_to_grid_%:
	for lang in $(BIG_LANG); do for preproc in $(PREPROCESS_OPT); do $(QSUBCMD) -pe smp 20 -cwd submit_grid_stub.sh $(STORE2)/bitext_svd_"$$lang"_$*_"$$preproc".mat; done; done

# SOURCE: 1. The mat file with google embeddings. 6 mat files with
# sparse array denoting alignments to different languages 
# TARGET: Results of doing GCCA over them.
$(STORE2)/bitext_svd_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat $(BIG_ALIGN_MAT)
	$(MATCMD)"options=strsplit('$*', '_'); lang=options{1}; svd_size=str2num(options{2}); preprocess_option=options{3}; tic; load(['$(STORE2)/align_',lang,'.mat']); [align_mat, mu1, mu2]=preprocess_align_mat(align_mat,preprocess_option); [b, s]=svds(align_mat, svd_size); s=transpose(diag(s)); clear('align_mat', 'lang', 'preprocess_option', 'options', 'svd_size'); whos; toc; save('$@', 's', 'b', 'mu1', 'mu2'); exit;"

# SOURCE: All of the vocabulary files.
# TARGET: A sparse matrix of english co-occurence counts.
# This took 1hour 16 minutes
$(STORE2)/cooccur_en.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(BIG_INPUT)
	time pypy src/create_sparse_cooccurmat.py $+ 1> tmp_cooccur 2> log/cooccur_en.mat && sort -n tmp_cooccur | uniq -c > tmp_cooccur_en 

# TARGET: Mat file which contains the google embeddings.
$(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding
	$(MATCMD)"bvgn_embedding=dlmread('$<', '', 0, 1); bvgn_count=bvgn_embedding(:,1);bvgn_embedding=bvgn_embedding(:,2:size(bvgn_embedding,2)); save('$@', 'bvgn_embedding','bvgn_count');"

## 1. Check that the sparse matrix has the correct values. Manually check the result.  (Check using a smaller data file.) DONE
## For processing the french matrix I had to do the following. because of size
# numpy.asarray(idx_en_list).tofile("tmp_idx_en_list", sep="\n"); numpy.asarray(idx_fr_list).tofile("tmp_idx_fr_list", sep="\n")
## paste tmp_idx_en_list tmp_idx_fr_list |  sort -n | uniq -c > tmp_idx_cnt_en_fr
## arr=dlmread('tmp_idx_cnt_en_fr', '', 0, 0); align_mat=sparse(1+arr(:,2), 1+arr(:,3), arr(:,1)); save('/export/a14/prastog3/align_fr.mat', 'align_mat');
## The minimum of tmp_idx_en_list is 0
## The maximum of tmp_idx_en_list is 131132 (0 indexed since total are 131133)
## The minimum of tmp_idx_fr_list is 0
## The maximum of tmp_idx_fr_list is 2243100 (total are 2243101 so 0 indexed)

gridrun_align_mat:
	for targ in $(BIG_LANG); do $(QSUBCMD)  -cwd submit_grid_stub.sh $(STORE2)/align_"$$targ".mat ; done 

# TARGET: sparse matrix encoding the alignment as a mat file
# SOURCE: 1. The vocabulary of the foreign language along with counts.
#	2. The embeddings for english words present in google and bitext
# 	3. The simplified file with alignments.
# Note that the word file is auto generated from the rule on top
$(STORE2)/align_%.mat: $(STORE2)/big_vocabcount_% $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/ppdb-input-simplified-%
	time python src/create_sparse_alignmat.py $+ $@ 2> log/$(@F)

# TARGET : intersect big_vocabcount_en and google embedding
# 	Its a file with first column as the word,
#	second column is count in the source files.
#	third column onwards we have the embeddings.
# SOURCE : The google embedding and english big vocab
$(STORE2)/big_vocabcount_en_intersect_gn_embedding: $(STORE)/gn300.txt $(STORE2)/big_vocabcount_en
	python src/overlap_between_google_and_big_vocabcount.py $+ $@

# TARGET : A vocabulary of english created from the 6 files.
#          with counts of how many times the words occurred
#          And 6 vocabularies of the foreign languages
#          big_vocabcount_[en ar cs de es fr zh]
$(STORE2)/big_vocabcount_en : $(BIG_INPUT)
	pypy src/create_big_vocab.py $@ $+ 2> log/big_vocabcount

big_input: $(BIG_INPUT)

# TARGET: A simplified BIG_INPUT where all the english parses are converted to normal sentences.
$(STORE2)/ppdb-input-simplified-%: $(STORE2)/ppdb-input-%
	pypy src/remove_parse_from_english.py $^  $@

# TARGET: Single files each for a separater language
# This will take 22 files and convert them to 6 files fr es de cs ar zh
$(STORE2)/ppdb-input-%:
	cat /home/juri/ppdb-input/*-$*-* > $@

align_europarlv1_%:
	java -jar /home/prastog3/tools/berkeleyaligner.jar  -trainSources /export/a15/prastog3/europarlv1/$*-en -foreignSuffix $* -englishSuffix en -execDir /export/a15/prastog3/europarlv1/$*-en-aligned  -saveParams false -numThreads 16 -msPerLine 10000 -alignTraining -create true -overwriteExecDir true

# MORE PREPROCESSING STUFF
# for file in *-en.aligned.tgz ; do tar -xzf $file ; done
# for corpus in de es fr ; do 
#     for file in $corpus-en/$corpus/* ; do mv $file $corpus-en/${file:9}.$corpus ; done && 
#     for file in $corpus-en/en/* ; do mv $file $corpus-en/${file:9}.en ; done ; 
# done
# rmdir de-en/de de-en/en es-en/es es-en/en fr-en/fr fr-en/en
/export/a15/prastog3/europarlv1/%-en.aligned.tgz:
	cd $(@D) && wget http://www.statmt.org/europarl/v1/$*-en.aligned.tgz && cd -

tabulate_extrinsic_test: log/extrinsic_test_s_0 log/extrinsic_test_l_0   log/extrinsic_test_s_1 log/extrinsic_test_l_1
	python src/tabulate_extrinsic_test.py $+

# TARGET: pr2xy means pushpendre to xuchen, ppdb_l and ppdb_s refer to
# the ppdb sizes used for doing CCA, word2vec contains the original
# embeddings that google provided. There are 82841 words in these
# files 
extrinsic_test: log/extrinsic_test_s_1 log/extrinsic_test_s_0 log/extrinsic_test_l_1 log/extrinsic_test_l_0

pr2xy: pr2xy_cca_ppdb_l_embedding.bin pr2xy_cca_ppdb_s_embedding.bin pr2xy_word2vec_embedding.bin

$(STORE)/pr2xy_%_embedding.bin: $(STORE)/pr2xy_%_embedding.txt
	./res/convertvec txt2bin $<  $@

# $(STORE)/pr2xy_word2vec_embedding.txt is also made automatically
# TARGET : Save the embeddings as a txt file.
$(STORE)/pr2xy_cca_ppdb_%_embedding.txt: $(STORE)/gn_intersect_ppdb_embeddings.mat 
	$(MATCMD)"load('$<'); word=textread('res/gn_intersect_ppdb_word', '%s'); ppdb_size='$*'; mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); dimension_after_cca=150; distance_method='cosine'; w2v_file_name='$(STORE)/pr2xy_word2vec_embedding.txt'; cca_file_name='$@'; save_embedding_to_txt_file;exit;"

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
# # No longer I need knnK, dim2keep, doavgk. do_knn_only_over_original_embedding (because I do over both all the time), dist (dist = cosine)
# I also checked use_unique_mapping
# log/large_scale_cca_[sl]_cosine_1_0_0_1_170_1_[10]
#     large_scale_cca_[sl]_cosine_1_0_(170|90)_0_0_1_[10]
#     large_scale_cca_[sl]_cosine_1_1_0_0_0_1_[10]
log/extrinsic_test_%: $(STORE)/gn_intersect_ppdb_embeddings.mat res/filtered_paraphrase_list_wordnet.mat res/ppdb_paraphrase_rating_filtered.mat res/gn_intersect_ppdb_word # res/topvocablist.100000
	$(MATCMD)"load('$<'); load('$(word 2,$^)'); load('$(word 3,$^)'); word=textread('$(word 4,$^)', '%s'); options=strsplit('$*', '_'); ppdb_size=options{1}; use_unique_mapping=str2num(options{2}); mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); dimension_after_cca=150; distance_method='cosine'; conduct_extrinsic_test; exit;" | tee $@

res/ppdb_paraphrase_rating_filtered.mat: res/ppdb_paraphrase_rating
	$(MATCMD)"ppdb_paraphrase_rating=create_ppdb_paraphrase_rating('$<', textread('res/gn_intersect_ppdb_word', '%s')); save('$@', 'ppdb_paraphrase_rating'); exit;"

res/ppdb_paraphrase_rating: res/pred-scored-human-ppdb.txt
	python src/preprocess-pred-scored-human-ppdb.py $< | sort > $@

res/filtered_paraphrase_list_wordnet.mat: res/wordnet.test
	$(MATCMD)"golden_paraphrase_map=create_golden_paraphrase_map('$<', textread('res/gn_intersect_ppdb_word', '%s')); save('$@', 'golden_paraphrase_map'); exit;"

data_eyeball_%:
	$(MATCMD)"load('/export/a15/prastog3/gn_intersect_ppdb_embeddings.mat'); mapping=dlmread('res/gn_ppdb_lex_$*_paraphrase','', 0, 2); word=textread('res/gn_intersect_ppdb_word', '%s'); cd src; debug=1; data_eyeball; exit;"

log/gridrun_log_tabulate: log/gridrun 
	python src/gridrun_log_tabulate.py | tee $@

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
	python src/overlap_between_google_and_ppdb.py $+ $@

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
