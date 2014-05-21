.SECONDARY:
.PHONY: optimal_cca_dimension_table gridrun_log_tabulate
.INTERMEDIATE: gn_ppdb.itermediate

# Active Evaluation
MATCMD := LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 time matlab -nodisplay -r "warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src');addpath('src/kdtree'); "
QSUBCMD := qsub -V -j y -l mem_free=10G -r yes -pe smp 5 
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result

# 1. Sanity check the first row of these results and figure out why are
#    these numbers so low ? and the rest of them so high ?
# 2. Eyeball the data with typical familiar words like dog and cheese
#    and see whether the vector embeddings for them and their paraphrases
#    are close to each other, what are their neighbors, how close are the
#    nearest good paraphrases in the vector space ? Also draw histogram of
#    number of paraphrase per word and the number of words in a class.  
# 3. Run a KNN experiment after appending the new embedding to the original 
# 4. Make runs from CCA_Dim=1:10 and KNN from [16, 32, 64] . Test the limits and find peaks of accuracy. 
# 5. Make run with kNN=1 using only the first dimension or only the
#    second dimension etc. see the trend of performance.  
# 6. Make new graphs of preciosion/recall for real valued K 
#    i.e. Amongst words which have 4 paraphrases how high do I need
#     to set k to capture all of them ? Or to capture 3 of them ? This gives
#     us an average K that has a particular precision or recall. 

gridrun_log_tabulate: # log/gridrun I do not want it to run stuff on grid at all
	python src/gridrun_log_tabulate.py | tee gridrun_log_tabulate

log/gridrun: # qacct -j [jobid]  -l h=plantation,other_resources -verify
	for db in s l ; do \
	  for dist in euclidean cosine ; do \
	    for knnK in 1 4 8 16; do \
	       for dim2keep in 10 30 50 70 90 110 130 150 170 190 210 230 250 270 290 ; do \
		  $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_"$$dim2keep"_0 -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_"$$dim2keep"_0 ;\
	       done;\
	       $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_0_1 -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_0_1 ;\
	    done;\
	  done;\
	done;

# TARGET : Now do CCA over embeddings. The second file contains the
# mapping. Currently it has 660584 rows. There are 2 arrays each with
# 660584 rows and 300 columns. So the total memory requirement is
# 497,046,000 (doubles 8 Bytes) == 3GB. (4 GB for xxl) After running
# CCA. I get new embeddings and then I need to run KNN.

# EXAMPLE: /export/a15/prastog3/large_scale_cca_xxl_euclidean_1_10_1
# The first is size of ppdb, then the distance method then knnK then the
# dimensions to keep and then whether to do it over
# original embedding or the CCA ones. You only need to do CCA over
# original embeddings once.
log/large_scale_cca_%: /export/a15/prastog3/gn_intersect_ppdb_embeddings.mat  #res/gn_ppdb_lex_%_paraphrase
	$(MATCMD)"load('$<'); options=strsplit('$*', '_'); ppdb_size=options{1}; distance_method=options{2}; knnK=str2num(options{3}); dimension_after_cca=str2num(options{4}); do_knn_only_over_original_embedding=str2num(options{5}); mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); large_scale_cca; exit" | tee $@

/export/a15/prastog3/gn_intersect_ppdb_embeddings.mat : # /export/a15/prastog3/gn_intersect_ppdb_embeddings
	$(MATCMD)"embeddingdlmread('$<', ,'', 0, 1); save('$<.mat','embedding');exit;"

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
res/gn_intersect_ppdb_word: /export/a15/prastog3/gn_intersect_ppdb_embeddings
	awk '{print $$1}' $+ > $@

/export/a15/prastog3/gn_intersect_ppdb_embeddings : /export/a15/prastog3/gn_intersect_ppdb_embeddings.gz
	zcat $+ > $@

# TARGET : Contains embeddings of overlapping words in Google News
# Vectors and the PPDB lexical words. The first column is the
# word. currently the number of common words is 56870. zcat TARGET | wc -l
# In Both  82841
# In Google not in PPDB 2917159 (Skewed because contains phrases)
# In PPDB not in Google 42406
# PPDB has 125,247 words
# Google has 3 Million Phrases and roughly 300k words.
/export/a15/prastog3/gn_intersect_ppdb_embeddings.gz res/in_google_not_in_ppdb res/in_ppdb_not_in_google: gn_ppdb.itermediate

gn_ppdb.itermediate: /export/a15/prastog3/gn300.txt /export/a15/prastog3/PPDB_Lexical_Data/ppdb-1.0-xxxl-lexical-words-uniq 
	PYTHONPATH=$$PWD/src/:$$PYTHONPATH python src/overlap_between_google_and_ppdb.py $+ /export/a15/prastog3/gn_intersect_ppdb_embeddings.gz

# /export/a15/prastog3/gn300.txt.gz : /export/a15/prastog3/gn300.txt
# 	gzip -c $+ > $@

/export/a15/prastog3/gn300.txt: /export/a15/prastog3/GoogleNews-vectors-negative300.bin res/convertvec
	./res/convertvec bin2txt $<  $@ 

/export/a15/prastog3/GoogleNews-vectors-negative300.bin: /export/a15/prastog3/GoogleNews-vectors-negative300.bin.gz
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
