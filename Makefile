.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input 
.INTERMEDIATE: gn_ppdb.itermediate

## GENERIC 
# TARGET : Contains just the words. extracted from 1st column of source
%_word: %
	awk '{print $$1}' $+ > $@
%_2column: %
	awk '{print $$1, $$2}' $+ > $@
qstat:
	qstat | cut -c 73-75 | sort | uniq -c

# Sometime soon, can you send a pointer to an updated latex file that contains a writeup of what leads up to these results? Try your best to write them up in draft paper form. Don't worry about intro, I want to see an updated section on model, then data, then experiment ( which would include what you just sent). And could you remind us when you are returning? I think it is mid / late August?
# Right now I am running three jobs on grid search for "your job"
# I am creating gcca embeddings using monolingual data source. and then I will check its performance.
# I am checking GLOVE embeddings performance on my bench.
# And also I am running the experiments with tomas mikolov ICLR13 dataset.
# For now my biggest job is to write the paper
# (After that I can improve the method of doing SVD.)
# Add more data to the GCCA method. (Test Performance on tasks. Like NER.


## VARIABLES
# LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 addpath('src/kdtree');
# Note the Test names
# TOEFL_QUESTION
# SCWS (Stanford COntextual word similarity)
# Rare Words (RW, by Stanford, Socher)
# MEN : 
# EN_MC_30 : 
# EN_MTURK_287 : 
# EN_RG_65 : 
# EN_WS-353 (ALL/REL/SIM): 
# EN_TOM_ICLR13(SYN/REL) : 
QSUBCMD := qsub -V -j y -l mem_free=25G -r yes #-verify
# QSUBCMD := echo 
QSUBMAKE := $(QSUBCMD) -cwd submit_grid_stub.sh
QSUBPEMAKE := $(QSUBCMD) -pe smp 25 -cwd submit_grid_stub.sh
echo_qsubpe:
	echo $(QSUBPEMAKE)
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
STORE2 := /export/a14/prastog3
RESPATH := /home/prastog3/projects/mvppdb/res
BIG_LANG := ar cs de es fr zh 
BIG_INPUT := $(addprefix $(STORE2)/ppdb-input-simplified-,$(BIG_LANG))
BIG_INPUT_WORD := $(addsuffix _word,$(BIG_INPUT))
BIG_ALIGN_MAT := $(patsubst %,$(STORE2)/align_%.mat,$(BIG_LANG))
SVD_DIM := 500
PREPROCESS_OPT := Count logCount
MATCMD := time matlab -nojvm -nodisplay -r "warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src'); "
MATCMDENV := $(MATCMD)"setenv('TOEFL_QUESTION_FILENAME', '$(RESPATH)/word_sim/toefl.qst'); setenv('TOEFL_ANSWER_FILENAME', '$(RESPATH)/word_sim/toefl.ans'); setenv('SCWS_FILENAME', '$(RESPATH)/word_sim/scws_simplified.txt'); setenv('RW_FILENAME', '$(RESPATH)/word_sim/rw_simplified.txt'); setenv('MEN_FILENAME', '$(RESPATH)/word_sim/MEN.txt'); setenv('EN_MC_30_FILENAME', '$(RESPATH)/word_sim/EN-MC-30.txt'); setenv('EN_MTURK_287_FILENAME', '$(RESPATH)/word_sim/EN-MTurk-287.txt'); setenv('EN_RG_65_FILENAME', '$(RESPATH)/word_sim/EN-RG-65.txt'); setenv('EN_TOM_ICLR13_SEM_FILENAME', '$(RESPATH)/word_sim/EN-TOM-ICLR13-SEM.txt'); setenv('EN_TOM_ICLR13_SYN_FILENAME', '$(RESPATH)/word_sim/EN-TOM-ICLR13-SYN.txt'); setenv('EN_WS_353_REL_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-REL.txt'); setenv('EN_WS_353_SIM_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-SIM.txt'); setenv('EN_WS_353_ALL_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-ALL.txt'); setenv('WORDNET_TEST_FILENAME', '$(RESPATH)/wordnet.test'); setenv('PPDB_PARAPHRASE_RATING_FILENAME', '$(RESPATH)/ppdb_paraphrase_rating'); "

# This process creates a table like the following.
# 		                          O	  G	  U	   V
# EN_TOM_ICLR13_SYN (10043 out of 10675) 0.6336	0.3170	0.5734	0.3265
# EN_TOM_ICLR13_SEM (3662 out of 8869)	 0.1097	0.0392	0.1110	0.0438
# SCWS (1978 out of 2003)		 0.6476	0.5896	0.6207	0.6097
# RW (1808 out of 2034)			 0.4485	0.3189	0.4780	0.3088
# MEN (2946 out of 3000)		 0.7428	0.4810	0.7391	0.4918
# EN_MC_30 (30 out of 30)		 0.7886	0.3591	0.7883	0.4592
# EN_MTURK_287 (275 out of 287)		 0.6327	0.4790	0.6007	0.5218
# EN_RG_65 (65 out of 65)		 0.7607	0.5519	0.7774	0.5847
# EN_WS_353_ALL (350 out of 353)	 0.6833	0.5341	0.6496	0.5494
# EN_WS_353_REL (250 out of 252)	 0.5996	0.4710	0.5464	0.5300
# EN_WS_353_SIM (202 out of 203)	 0.7783	0.5961	0.7499	0.6235
# logCount original G U V
# 50 0.663180 0.761930 0.673395 0.742604 
# 75 0.663180 0.761930 0.686480 0.754124 
# 100 0.663180 0.761930 0.684092 0.758477 
# 125 0.663180 0.761930 0.690841 0.764990 
# 150 0.663180 0.761930 0.694817 0.767735 
# 175 0.663180 0.761930 0.693774 0.770188 
# 200 0.663180 0.761930 0.696455 0.771158 
# 225 0.663180 0.761930 0.694216 0.771636 
# 250 0.663180 0.761930 0.691688 0.772791 
# 275 0.663180 0.761930 0.691138 0.772942 
# 300 0.663180 0.761930 0.687952 0.773492 
tabulate_run_on_grid_bitext_extrinsic:
	for t in logCount Count; do printf "$$t original G U V" && for i in 50 75 100 125 150 175 200 225 250 275 300 ; do  echo "" && printf "$$i " && grep -e "The Pearson Corr over " log/bitext_extrinsic_test_300_7000_1e-8_"$$t"."$$i" | tee -a $@ | awk '{printf "%s ", $$NF}' ; done && echo ""; done
MEGATAB_%:
	make tabulate_$*_bvgnFull_extrinsic_test && \
	make tabulate_$*_bitext_extrinsic_test_300_7000_1e-8_logCount.300 && \
	make tabulate_$*_monotext_extrinsic_test_v2_gcca_run_sans_mu_300_7000_1e-8_logCount && \
	make tabulate_$*_fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount && \
	make tabulate_$*_other_extrinsic_test_glove.42B.300d && \
	make tabulate_$*_other_extrinsic_test_glove.6B.300d 

TABCMD = cat $$F | sed "s%original embedding%O%g" | sed "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" | sed "s%The TOEFL score over \([0-9A-Za-z_-]*\) with bare \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The TOEFL $$corrtype score over \1 (\3 out of \2) is \5%g" | sed "s%The $$corrtype Corr over \([0-9A-Za-z_-]*\) is%The JURI $$corrtype correlation over \1 (0 out of 0) is%g" | grep -E "The .* $$corrtype "  | awk '{printf "%s %s out of %s \t %s \t %s\n", $$2, $$7, $$10, $$6, $$NF}' | python src/tabulation_script.py
tabulate_Spearman_%: 
	export F=log/$* && export corrtype=Spearman && $(TABCMD) $*
tabulate_Pearson_%: 
	export F=log/$* && export corrtype=Pearson && $(TABCMD) $*
##################
## GRID RUN CODE
##################
# This takes 4 hourse now.
run_on_grid_bitext_extrinsic_test:
	for i in  200 250 300 ; do for t in logCount ; do \
          $(QSUBPEMAKE) log/bitext_extrinsic_test_300_7000_1e-8_"$$t"."$$i" ; \
	done ; done | tee $@
# This took 8 hours for the 42B word embeddings and 2 hour for 6B word embeddings
run_on_grid_glove_extrinsic: 
	for i in 6 42 ; do $(QSUBPEMAKE) log/other_extrinsic_test_glove."$$i"B.300d ; done | tee $@
run_on_grid_monotext_extrinsic: #Your job 7691066 (it took 4 hours)
	$(QSUBPEMAKE) log/monotext_extrinsic_test_v2_gcca_run_sans_mu_300_7000_1e-8_logCount
run_on_grid_bvgn%_extrinsic: # Your job 7695340(bvgnPrunedppdb) # Your job 7697487 (bvgnFull)
	$(QSUBPEMAKE) log/bvgn$*_extrinsic_test
###############
## EVAL CODE
###############
# TARGET: log/bitext_extrinsic_test_300_7000_1e-8_logCount.150 log/bitext_extrinsic_test_300_7000_1e-8_Count.150
# This is basically doing CCA with resulting 150 dimensions over the original gn embeddings and the GCCA embeddings.
# The results are basically how well these embeddings work to predict the human similarity judgements.
# And there are 4 types of embeddings
# original embeddings : the bvgn embeddings
# G : the basic GCCA embeddings
# U : The bvgn embeddings projected after doing CCA between bvgn and G
# V : The G embeddings projected after doing CCA between bvgn and G
# This target is pretty quick to make.
# SOURCE: big_vocabcount_en_intersect_gn_embedding which is the gn embeddings intersected with big_vocab that was made from 6 bitext files.
#         300_7000_1e-8_Count/logCount are basically Hyper parameters that were used while creating the GCCA embeddings.
log/bitext_extrinsic_test_%: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat   $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_Count.mat $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_logCount.mat
	$(MATCMDENV)"options=strsplit('$*','.'); load(sprintf('$(STORE2)/gcca_run_sans_mu_%s', options{1})); dimension_after_cca=str2num(options{2});  word=textread('$(word 1,$+)', '%s'); load('$(word 2,$+)'); G=G'; sort_idx=sort_idx'; word=word(sort_idx); bvgn_count=bvgn_count(sort_idx); bvgn_embedding=bvgn_embedding(sort_idx,:);bitext_true_extrinsic_test(G, bvgn_embedding, dimension_after_cca, word);exit; " | tee $@

EXTRINSIC_TEST_CMD = "word=textread('$(word 1,$+)', '%s'); load('$(word 2,$+)'); load('$(word 3,$+)'); G=G'; sort_idx=sort_idx'; word=word(sort_idx); bvgn_count=bvgn_count(sort_idx); bvgn_embedding=bvgn_embedding(sort_idx,:); bitext_true_extrinsic_test(G, bvgn_embedding, 300, word); exit;"
EXTRINSIC_TEST_DEP = $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat $(STORE2)/%.mat
log/monotext_extrinsic_test_%: $(EXTRINSIC_TEST_DEP)
	$(MATCMDENV)$(EXTRINSIC_TEST_CMD) | tee $@
# TARGET: log/fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount
# SOURCE : This job runs from start to stop. I have to set up the data
# file, then take SVD, then store it into a single cell, then take
# gcca, then perform test upon it. 
log/fullgcca_extrinsic_test_%: $(EXTRINSIC_TEST_DEP) #Your job 7730940
	$(MATCMDENV)$(EXTRINSIC_TEST_CMD) | tee $@
# TARGET: a log file with all the test results.
# SOURCE: $(STORE2)/glove.6B.300d.mat (glove.42B etc.)
log/other_extrinsic_test_%:  $(STORE2)/%.mat
	$(MATCMDENV)"tic; load('$(word 1,$+)'); emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, id, word); fprintf(1, 'Total time taken %d\n', toc); exit;" | tee $@

# Target: Basically this tests my word pruned version of the mikolov
# embeddings. I wanted to check whether my version of mikolov
# embeddings was flawed because they were not reaching the desired
# level of accuracy. So I tested both my version and the Full version
# on the test which was certified to be doing the correct thing at
# least for the Mikolov-Analogy task (because it worked for glove embeddings)
# This job took only 1 hour
#                 bvgnPrunedppdb
# SCWS (1978 out of 2003)                 0.647620
# RW (1808 out of 2034)                   0.448516
# MEN (2946 out of 3000)                  0.742855
# EN_MC_30 (30 out of 30)                 0.788607
# EN_MTURK_287 (275 out of 287)           0.632702
# EN_RG_65 (65 out of 65)                 0.760783
# EN_WS_353_ALL (350 out of 353)          0.683337
# EN_WS_353_REL (250 out of 252)          0.599603
# EN_WS_353_SIM (202 out of 203)          0.778387
# EN_TOM_ICLR13_SYN (10043 out of 10675)  0.633630
# EN_TOM_ICLR13_SEM (3662 out of 8869)    0.109708
log/bvgnPrunedppdb_extrinsic_test: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat
	$(MATCMDENV)"tic; word=textread('$(word 1,$+)', '%s'); load('$(word 2,$+)'); emb=normalize_embedding(bvgn_embedding); conduct_extrinsic_test_impl(emb, 'bvgnPrunedppdb', word); fprintf(1, 'Total time taken %f seconds\n', toc); exit;" | tee $@
# This took 5 hours.
log/bvgnFull_extrinsic_test: $(STORE)/gn300_word.txt $(STORE)/gn300.txt 
	$(MATCMDENV)"tic; word=textread('$(word 1,$+)', '%s'); word=word(2:end); emb=dlmread('$(word 2,$+)', '', 1, 1); conduct_extrinsic_test_impl(emb, 'bvgnFull', word); fprintf(1, 'Total time take %f seconds \n', toc); exit;" | tee $@
# This code could be sped up.
# but anyway the problem is that it did not print the required information even after finishing.
log/eval_bvgn_using_word2vec_code_for_analogy_task: # Your job 7696236 (8 hours)
	/home/prastog3/tools/word2vec/trunk/compute-accuracy /export/a15/prastog3/GoogleNews-vectors-negative300.bin < /home/prastog3/projects/mvppdb/res/word_sim/EN-TOM-ICLR13-SEM.txt > $@ && /home/prastog3/tools/word2vec/trunk/compute-accuracy /export/a15/prastog3/GoogleNews-vectors-negative300.bin < /home/prastog3/projects/mvppdb/res/word_sim/EN-TOM-ICLR13-SEM.txt >> $@
# TARGET: A mat file with three variables 'emb' 'word' 'id'
# SOURCE: This takes 3 files as input.
# 	  1. A word file which provides the word to index mapping that must be followed while converting 
$(STORE2)/glove.%B.300d.mat: $(STORE2)/glove.%B.300d.txt_word $(STORE2)/glove.%B.300d.txt
	$(MATCMD)"tic; word=textread('$(word 1,$+)', '%s'); emb=dlmread('$(word 2,$+)', '', 0, 1); id='glove$*'; save('$@', 'emb', 'id', 'word', '-v7.3'); toc; exit;"

# TARGET: The simplified outputs
# SOURCE: These are rare word and contextual word similarity datasets which need to simplified
res/word_sim/rw_simplified.txt: res/word_sim/rw.txt
	awk '{print $$1, $$2, $$3}' $+ > $@

res/word_sim/scws_simplified.txt: res/word_sim/scws.txt
	awk -F $$'\t' '{print $$2, $$4, $$8}' $+ > $@

# TARGET: this creates things like /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_logCount.mat
#       :                     and  /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat
# SOURCE: this creates things like /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat
# This takes roughly 8 hours for 6 files.
# I can experiment with 300_10000 (and higher) or 500_1000 (or higher)
v%_submit_gcca_run_sans_mu_to_grid:  
	    $(QSUBPEMAKE) $(STORE2)/v$*_gcca_run_sans_mu_300_7000_1e-8_logCount
submit_gcca_run_sans_mu_to_grid: 
	for transform in Count logCount; \
	    do $(QSUBPEMAKE) $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_"$$transform" ; done

#####################
## GCCA Running Code
#####################

# TARGET: A Typical run would 300_1000_1e-8 (300 is the number of principal vectors, 1000 is the batch size, (higher is better))
# SOURCE : A mat file containing S, B, Mu1, Mu2 which contain the arabic, chinese, english bitext data
GCCA_RUN_SANS_MU_CMD = $(MATCMD)"options=strsplit('$*', '_'); r=str2num(options{1}); b=str2num(options{2}); load $<;svd_reg_seq=str2num(options{3})*ones(size(S)); [G, S_tilde, sort_idx]=se_gcca(S, B, r, b, svd_reg_seq); tic; save('$@', 'G', 'S_tilde', 'sort_idx'); toc; exit; "
$(STORE2)/v3_gcca_run_sans_mu_%_logCount.mat: $(STORE2)/v3_gcca_input_svd_already_done_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/v2_gcca_run_sans_mu_%_logCount.mat: $(STORE2)/v2_gcca_input_svd_already_done_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/gcca_run_sans_mu_%_logCount: $(STORE2)/gcca_input_svd_already_done_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/gcca_run_sans_mu_%_Count: $(STORE2)/gcca_input_svd_already_done_500_Count.mat
	$(GCCA_RUN_SANS_MU_CMD)

# SOURCE: A small test file to practice doing se_gcca.
test_gcca_run: res/tmp_bitext_svd.mat
	$(MATCMD)"load $<; S={s}; B={b}; [G, S_tilde]=se_gcca(S, B, 10, 2, [1e-8]); U_tilde=S'; exit;"

# TARGET: A single mat file containing S, B, mu1 and mu2 arrays in a
# cell. Currently only three targets exist 
# gcca_input_svd_already_done_2.mat
# gcca_input_svd_already_done_500_Count.mat
# gcca_input_svd_already_done_500_logCount.mat
# Also note that v2 differs from the unversioned one only wrt to
# whether it uses the monolingual cooccurence statistics or not. 
# In the most basica sense I just need to get as input the singular
# vectors of a view after that my code takes the GCCA. (which is in
# se_gcca.m) 
# SOURCE: GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP referes to
# $(STORE2)/bitext_svd_fr/cs_500.mat (500 means the dimensionality of
# the SVD result) 
# Then all those are put into a single cell called S and B
# It calls on the the following files.
# bitext_svd_ar_500_Count.mat                    bitext_svd_ar_500_logCount.mat
# bitext_svd_cs_500_Count.mat                    bitext_svd_cs_500_logCount.mat
GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP = $(foreach lang,$(BIG_LANG),$(STORE2)/bitext_svd_$(lang)_%.mat)
GCCA_INPUT_TODO = $(patsubst %,load %; B=[B b]; S=[S s]; Mu1=[Mu1 full(mu1)]; Mu2=[Mu2 full(mu2)]; whos;,$+)
GCCA_INPUT_SVD_ALREADY_DONE_CMD = $(MATCMD)"tic; S={}; B={}; Mu1={}; Mu2={}; $(GCCA_INPUT_TODO) save('$@', 'S', 'B', 'Mu1', 'Mu2', '-v7.3'); toc; exit;"
# $(STORE2)/gcca_input_svd_already_done_%_v3.mat: $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) monotext_svd_en_%.mat cluewebfreebase_svd_en_%.mat
# 	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)

#TARGET: v3_gcca_input_svd_already_done_500_logCount.mat. This
#       contains data from mikolov's embeddings as well as data from
#       bitext and bitext-monolingual-part-window3 source
$(STORE2)/v3_gcca_input_svd_already_done_%.mat: $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) $(STORE2)/monotext_svd_en_%-truncatele20.mat $(STORE2)/bvgn_svd_embedding_500_Count.mat
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
$(STORE2)/v2_gcca_input_svd_already_done_%.mat: $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) $(STORE2)/monotext_svd_en_%-truncatele20.mat 
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
$(STORE2)/gcca_input_svd_already_done_%.mat: $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP)
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)

# TARGET: A way to submit bitext_svd_%.mat jobs to the grid
submit_bitextsvd_to_grid_%:
	for lang in $(BIG_LANG); do for preproc in $(PREPROCESS_OPT); do $(QSUBPEMAKE) $(STORE2)/bitext_svd_"$$lang"_$*_"$$preproc".mat; done; done
# This example should make the final result of running this target clear
# qsub -V -j y -l mem_free=5G -r yes  -pe smp 25 -cwd submit_grid_stub.sh /export/a14/prastog3/monotext_svd_en_5_logCount-truncatele60.mat
# Your job 7662376 ("submit_grid_stub.sh") has been submitted
# for trunc in 60 40 20; do 
# Your job 7662345 ("submit_grid_stub.sh") has been submitted
# Your job 7662346 ("submit_grid_stub.sh") has been submitted
# Your job 7662347 ("submit_grid_stub.sh") has been submitted
# This job takes two hours for making trunc=20 file.
submit_monotextsvd_to_grid:
	for trunc in 60 40 20; do $(QSUBPEMAKE) $(STORE2)/monotext_svd_en_500_logCount-truncatele"$$trunc".mat; done

# TARGET: Results of taking their SVD stored in individual files like
# bitext_svd_es_500_logCount.mat
# Note that monotext svd is doing exactly the same thing but over the
# monolingual cooccurence statistics.
# However we also need to truncate the matrix because of computational considerations.
# So we would create monotext_svd_en_500_logCount-truncatele20.mat
# SOURCE: 1. The mat file with google embeddings.
#         2. 6 mat files with sparse array denoting alignments to different languages
TAKE_SVD_CMD_PART1 = $(MATCMD)"options=strsplit('$*', '_'); lang=options{1}; svd_size=str2num(options{2}); preprocess_option=options{3}; tic; load(['$(STORE2)/"
TAKE_SVD_CMD_PART2 = "_',lang,'.mat']); if ~exist('align_mat'); align_mat=bvgn_embedding; end; disp(size(align_mat)); [align_mat, mu1, mu2]=preprocess_align_mat(align_mat,preprocess_option); disp(size(align_mat)); disp('preprocessing complete'); [b, s]=svds(align_mat, svd_size); s=transpose(diag(s)); clear('align_mat', 'lang', 'preprocess_option', 'options', 'svd_size'); whos; toc; save('$@', 's', 'b', 'mu1', 'mu2'); exit;"
$(STORE2)/bitext_svd_%.mat:  $(BIG_ALIGN_MAT)
	$(TAKE_SVD_CMD_PART1)"align"$(TAKE_SVD_CMD_PART2)
$(STORE2)/monotext_svd_%.mat : $(STORE2)/cooccur_en.mat
	$(TAKE_SVD_CMD_PART1)"cooccur"$(TAKE_SVD_CMD_PART2)
# TARGET: This creates a file that contains the SVD of the bvgn embeddings.
# 	 We call $STORE2/bvgn_svd_embedding_500_Count
$(STORE2)/bvgn_svd_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat # Your job 7725279
	$(TAKE_SVD_CMD_PART1)"big_vocabcount_en_intersect_gn"$(TAKE_SVD_CMD_PART2)
# SOURCE: All of the vocabulary files.
# TARGET: A sparse matrix of english co-occurence counts.
# This took 1hour 16 minutes for the first half. and 30 minutes for second
## Make the sparse cooccurence matrix of english. using the full
# vocabulary. In fact dont even need to store in memory just write to
# file all the time. I would once again have to use  sort -n | uniq -c
# trick because the data is gonna be large and I would be doing append
# only
# RETHINK THIS APPROACH. LOOK AT penning's code to create cooccur matrices with constant memory.
$(STORE2)/cooccur_en_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(BIG_INPUT)
	pypy src/create_sparse_cooccurmat.py $* $+ 1> tmp_cooccur 2> log/cooccur_en_$*.mat && \
	split -l5000000 tmp_cooccur _tmp && \
        for file in _tmp* ; do sort $FILE -o $FILE & done && \
        wait && \
        sort -m _tmp* | uniq -c > tmp_cooccur_en && \
	rm _tmp* && \
	python src/create_cooccur_en_mat.py tmp_cooccur_en $$(wc -l $$STORE2/big_vocabcount_en_intersect_gn_embedding_word | awk '{print $$1}') tmp_cooccur_en_spconvert_style 0 $* && \
	matlab -r "[a,b,c]=textread('tmp_cooccur_en_spconvert_style', '%d %d %d'); align_mat=spconvert([a,b,c]); save('$@', 'align_mat'); exit;"

$(STORE2)/true_cooccur_en_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_2column $(STORE2)/only_english_from_ppdb_input
	~/tools/glove/cooccur -verbose 2 -symmetric 1 -window-size $* -vocab-file $(word 1,$+) -memory 8.0 -overflow-file tmp_overflow < corpus.txt > $@.bin && ./res/convertvec bin2txt $@.bin  $@.txt && 

$(STORE2)/only_english_from_ppdb_input: $(BIG_INPUT)
	cat $+ | awk -F'|' '{print $$4}' > $@ 

# TARGET: Mat file which contains the google embeddings.
# bvgn means big vocab google news
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
	for targ in $(BIG_LANG); do $(QSUBMAKE) $(STORE2)/align_"$$targ".mat ; done 

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
# Following are the 22 files that were concatenated.
# Gale, News Commentary, UN French, UN Spanish, Europarl, 10^9 French English
# 2.9G ccbword-fr-input-file-00
# 3.0G ccbword-fr-input-file-01
# 3.2G ccbword-fr-input-file-02
# 2.4G ccbword-fr-input-file-03
# 368M europarl-v7-cs-input-file-00
# 1.1G europarl-v7-de-input-file-00
# 1.1G europarl-v7-es-input-file-00
# 1.1G europarl-v7-fr-input-file-00
# 3.3G gale-ar-input-file-00
# 2.2G gale-ar-input-file-01
# 2.7G gale-zh-input-file-00
# 2.7G gale-zh-input-file-01
# 150M gale-zh-input-file-02
#  79M newscomm-cs-input-file-00
#  95M newscomm-de-input-file-00
#  87M newscomm-es-input-file-00
#  77M newscomm-fr-input-file-00
# 2.9G un-es-input-file-00
# 2.5G un-es-input-file-01
# 2.9G un-fr-input-file-00
# 2.9G un-fr-input-file-01
# 326M un-fr-input-file-02
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
