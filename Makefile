## TODO
# I have to do the followng tasks
# 1. Run glove with symmetric=0, x-max=1 
# 2. Run glove with symmetric=1, x-max=1
# 3. 

SHELL := /bin/bash
.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input $(STORE2)/agigastandep
.INTERMEDIATE: gn_ppdb.itermediate
## GENERIC 
# TARGET : Contains just the words. extracted from 1st column of source
%_word: %
	awk '{print $$1}' $+ > $@
%_2column: %
	awk '{print $$1, $$2}' $+ > $@
%_lowercase: %
	cat $< | tr '[:upper:]' '[:lower:]' > $@
echo_qstatfull:
	qstat | cut -c 73-75 | sort | uniq -c
echo_qstatarg_%:
	qstat -j $* | grep arg
echo_qsubpemake:
	echo $(QSUBPEMAKE)
echo_qsubmake:
	echo $(QSUBMAKE)
sleeper:
	sleep 60
# A literal space.
SPACE :=
SPACE +=
COMMA := ,
# Joins elements of the list in arg 2 with the given separator.
# 1. Element separator.
# 2. The list.
join-with = $(subst $(space),$1,$(strip $2))

## VARIABLES
# LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 addpath('src/kdtree');
QSDM := 15G
QSUB1 := qsub
QSUB2 := -V -j y -l mem_free=$(QSDM) -r yes #-verify ,ram_free=$(QSDM),h_vmem=$(QSDM)
QSUBCMD := $(QSUB1) $(QSUB2) 
QSUBP1CMD := $(QSUB1) -p -1 $(QSUB2)
CWD_SUBMIT := -cwd submit_grid_stub.sh 
QSUBMAKE := $(QSUBCMD) $(CWD_SUBMIT)
QSUBP1MAKE := $(QSUBP1CMD) $(CWD_SUBMIT)
QSUBPEMAKE := $(QSUBCMD) -pe smp 10 $(CWD_SUBMIT)
QSUBP1PEMAKE := $(QSUBP1CMD) -pe smp 10 $(CWD_SUBMIT)
QSUBPEMAKEHOLD = qsub -N $1 -V -hold_jid $2 -l mem_free=$3 -r yes -pe smp $4 -cwd submit_grid_stub.sh
QSUBPEMAKEHOLD2 = qsub -N $1 -V -hold_jid $2,$3 -l mem_free=$4 -r yes -pe smp $5 -cwd submit_grid_stub.sh
QSUBPEMAKEHOLD3 = qsub -N $1 -V -hold_jid $2 -l mem_free=$3,ram_free=$4 -r yes -pe smp $5 -cwd submit_grid_stub.sh
QSUBPEMAKEHOLD4 = qsub -N $1 -V -l hostname=$2 -l mem_free=$3 -r yes -pe smp $4 -cwd submit_grid_stub.sh
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
STORE2 := /export/a14/prastog3
GLOVEDIR := /home/prastog3/tools/glove
TOOLDIR := /home/prastog3/tools
WORD2VECDIR := $(TOOLDIR)/word2vec/trunk
RESPATH := /home/prastog3/projects/mvppdb/res/word_sim
BIG_LANG := ar cs de es fr zh
BIG_INPUT := $(addprefix $(STORE2)/ppdb-input-simplified-,$(BIG_LANG))
BIG_INPUT_WORD := $(addsuffix _word,$(BIG_INPUT))
BIG_ALIGN_MAT := $(patsubst %,$(STORE2)/align_%.mat,$(BIG_LANG))
SVD_DIM := 500
PREPROCESS_OPT := Count logCount logCount-truncatele20 Count-truncatele20 logFreq Freq Freq-truncatele20 logFreq-truncatele20 logFreqPow075 FreqPow075 logFreqPow075-truncatele20 FreqPow075-truncatele20
MATCMD := time matlab -nojvm -nodisplay -r "warning('off', 'MATLAB:maxNumCompThreads:Deprecated'); warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src'); maxNumCompThreads(10); "
MATCMDENV := $(MATCMD)"setenv('TOEFL_QUESTION_FILENAME', '$(RESPATH)/toefl.qst'); setenv('TOEFL_ANSWER_FILENAME', '$(RESPATH)/toefl.ans'); setenv('SCWS_FILENAME', '$(RESPATH)/scws_simplified.txt'); setenv('RW_FILENAME', '$(RESPATH)/rw_simplified.txt'); setenv('MEN_FILENAME', '$(RESPATH)/MEN.txt'); setenv('EN_MC_30_FILENAME', '$(RESPATH)/EN-MC-30.txt'); setenv('EN_MTURK_287_FILENAME', '$(RESPATH)/EN-MTurk-287.txt'); setenv('EN_RG_65_FILENAME', '$(RESPATH)/EN-RG-65.txt'); setenv('EN_TOM_ICLR13_SEM_FILENAME', '$(RESPATH)/EN-TOM-ICLR13-SEM.txt'); setenv('EN_TOM_ICLR13_SYN_FILENAME', '$(RESPATH)/EN-TOM-ICLR13-SYN.txt'); setenv('EN_WS_353_REL_FILENAME', '$(RESPATH)/EN-WS-353-REL.txt'); setenv('EN_WS_353_SIM_FILENAME', '$(RESPATH)/EN-WS-353-SIM.txt'); setenv('EN_WS_353_ALL_FILENAME', '$(RESPATH)/EN-WS-353-ALL.txt'); setenv('WORDNET_TEST_FILENAME', '$(RESPATH)/wordnet.test'); setenv('PPDB_PARAPHRASE_RATING_FILENAME', '$(RESPATH)/ppdb_paraphrase_rating'); setenv('SIMLEX_FILENAME', '$(RESPATH)/simlex_simplified.txt'); setenv('MSR_QUESTIONS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.questions.txt'); setenv('MSR_ANSWERS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.answers.txt'); "
VOCABWITHCOUNT_500K_FILE := $(STORE)/polyglot_wikitxt/en/full.txt.vc5.500K
VOCAB_500K_FILE := $(VOCABWITHCOUNT_500K_FILE)_word

##############################
## LOG ANALYSIS CODE
# TARGET: This finds the least counts for all the datasets by using the
# The first argument is the maximum LC from start, then number of data points, then assumed 3rd correlation then the required confidence level.
find_lcs_datasets:
	for n in 3000 2034 2003 999 353 287 252 203 ; do python src/find_lc_spearman_significance.py 0.1 $$n 0.7 0.05; done \
	for n in 3000 2034 2003 999 353 287 252 203 65 30 ; do python src/find_lc_spearman_significance.py 0.6 $$n 0.5 0.01; done ; \
	for n in 3000 2034 2003 999 353 287 252 203 65 30 ; do python src/find_lc_spearman_significance.py 0.6 $$n 0.5 0.001; done ;\
	matlab -nojvm -r "find_prob_of_difference_of_two_beta_dist"

# TARGET: This finds the 3 way correlation between glove, w2v and me for all the similarity test sets
# make find_all_3way_spearman_corr
# make find_all_3way_pearson_corr
find_all_3way_%_corr:
	echo "ds glove, w2v"; \
	for t in MEN RW SCWS SIMLEX EN_WS_353_ALL EN_MTURK_287 EN_WS_353_REL \
	         EN_WS_353_SIM EN_RG_65 EN_MC_30 ; do \
	    make -s  get_"$$t".$*_3waycorr 2> /dev/null | awk -v ds=$$t '{if(NR == 3){print ds, $$1, $$2}}'; \
	done
get_%_3waycorr:
	$(MAKE) TYPE=$(word 2,$(subst ., ,$*)) get_$(word 1,$(subst ., ,$*))_3waycorr_generic
get_%_3waycorr_generic: log/fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_20.300.1.1 # log/combined_embedding_0 # log/fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_20.300.1.1
	awk 'BEGIN{a=0;b=1;}{if($$2=="$*"){b=0};if(a==1 && b==1){printf "%s-%s %s\n", $$1, $$2, $$3};if($$4=="$*_FILENAME"){a=1};}' log/extrinsic_glove_mytrain_mycode |sort -k1,1 > tmpg ;\
	awk 'BEGIN{a=0;b=1;}{if($$2=="$*"){b=0};if(a==1 && b==1){printf "%s-%s %s\n", $$1, $$2, $$3};if($$4=="$*_FILENAME"){a=1};}' log/extrinsic_word2vec_mytrain_mycode |sort -k1,1 > tmpw ;\
	awk 'BEGIN{a=0;b=1;}{if($$2=="$*"){b=0};if(a==1 && b==1){printf "%s-%s %s\n", $$1, $$2, $$3};if($$4=="$*_FILENAME"){a=1};}' $< |sort -k1,1 > tmpme; \
	join -j 1 tmpg tmpw > tmpgw ; \
	join -j 1 tmpgw tmpme > tmpgwme; \
	python src/get_3way_correlation.py <(awk '{print $$2}' tmpgwme) <(awk '{print $$3}' tmpgwme) <(awk '{print $$4}' tmpgwme) $(TYPE)

##############################
## PAPER MAKING CODE
table_c: 
	for c in glove glove_0  word2vec; do \
	   echo $$c ; $(MAKE) -s ts_extrinsic_"$$c"_mytrain_mycode; done 
	echo "monolingMVLSA"; make -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol12500_500~E@mi@bi@ag@fn@mo,300_1e-5_170000.300.1.1 ; \
	echo "MVLSA"; make -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol12500_500~E@mi,300_1e-5_16.300.1.1 ;\
	echo "3combo"; make -s ts_combined_embedding_0; \
	echo "2combo"; make -s ts_combined_embedding_1 \

table_v:
	for v in 16 17 19 21 23 25 27 29 ; do \
	echo $$v; make -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_300~E@mi,300_1e-5_"$$v".300.1.1 ; done | pr -8 -l 27

table_v2:
	for v in 16 20 25 ; do \
	echo $$v; make -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_"$$v".300.1.1 ; done | pr -3 -l 27

#The @ag job succeded because I lifted the 25 view thresh to 100K top words thresh.
table_vj: 
	for vj in "" @fn @mo @bi @po @ag @mo@fn @mo@fn@bi; do \
	echo $$vj; make -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_300~E@mi"$$vj",300_1e-5_25.300.1.1 ; done | pr -8 -l 27

table_k:
	for k in 10 25 50 100 200 300 500; do \
	echo $$k; $(MAKE) -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_300~E@mi,"$$k"_1e-5_25.300.1.1; done | pr -7 -l 27

table_m:
	for m in 100 200 300 500; do \
	echo $$m; $(MAKE) -s ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_"$$m"~E@mi,300_1e-5_25.300.1.1; done | pr -4 -l 27

table_tj: 
	for tj in 6250 12500 25000 50000 75000 100000 150000 200000 ; do \
	  echo "$$tj" ; $(MAKE) -s  ts_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol"$$tj"_500~E@mi,300_1e-5_16.300.1.1 ; done | pr -8 -l 27

table_nj:
	for nj in  logCount CountPow100 CountPow025  ; do \
	echo $$nj ; $(MAKE) -s ts_fullgcca_extrinsic_test_v5_embedding_mc_"$$nj"-trunccol200000_500~E@mi,300_1e-5_16.300.1.1 ; done | pr -3 -l 27
###################################################
## EXHAUSTIVELY TEST MIKOLOV AND GLOVE
eval_extr:
	for t in glove_theirtrain_mycode glove_mytrain_mycode \
	word2vec_theirtrain_theircode word2vec_theirtrain_mycode word2vec_mytrain_mycode word2vec_mytrain_theircode  ; do \
	$(call QSUBPEMAKEHOLD2,$$t,9223311,9223325,5G,10) log/extrinsic_$$t ; done

eval_extr2:
	for t in glove_0 ; do $(call QSUBPEMAKEHOLD,$$t,9371550,5G,1) log/extrinsic_"$$t"_mytrain_mycode; done

EXTRINSIC_TEST_WORD2VEC_THEIRCODE_CMD = echo $(word 2,$+) > $@ && \
	$(WORD2VECDIR)/compute-accuracy $< 929000 < $(word 2,$+) >> $@ && \
	echo $(word 3,$+) >> $@ && \
	$(WORD2VECDIR)/compute-accuracy $< 929000 < $(word 3,$+) >> $@

# log/extrinsic_word2vec_mytrain_theircode: $(STORE2)/word2vec_mytrain.bin $(PWD)/res/word_sim/EN-TOM-ICLR13-SEM.txt_lowercase $(PWD)/res/word_sim/EN-TOM-ICLR13-SYN.txt_lowercase
# 	$(EXTRINSIC_TEST_WORD2VEC_THEIRCODE_CMD)

log/extrinsic_word2vec_theirtrain_theircode: $(STORE)/word2vec_theirtrain.bin $(PWD)/res/word_sim/EN-TOM-ICLR13-SEM.txt_lowercase $(PWD)/res/word_sim/EN-TOM-ICLR13-SYN.txt_lowercase
	$(EXTRINSIC_TEST_WORD2VEC_THEIRCODE_CMD)

log/extrinsic_%_mycode:
	if   [[ $* == word2vec_theirtrain ]]; then \
	  export VOCAB_FILE=$(STORE)/$*.txt_word;\
	  export EMB_FILE=$(STORE)/$*.txt; \
	  export ROW_SKIP=1; \
	elif [[ $* == word2vec_mytrain ]]; then \
	  export VOCAB_FILE=$(STORE2)/$*.txt_word;\
	  export EMB_FILE=$(STORE2)/$*.txt; \
	  export ROW_SKIP=1 ;\
	elif [[ $* == glove_theirtrain ]]; then \
	  export VOCAB_FILE=$(STORE2)/$*.txt_word ;\
	  export EMB_FILE=$(STORE2)/$*.txt; \
	  export ROW_SKIP=0 ;\
	elif [[ $* =~ glove_.+_mytrain ]] ; then \
	  export VOCAB_FILE=$(VOCAB_500K_FILE);\
	  export EMB_FILE=$(STORE2)/$*.txt; \
	  export ROW_SKIP=0 ;\
	else \
	  echo "unimplemented extrinsic_test type $*"; false; \
	fi && \
	$(MAKE) ROW_SKIP=$$ROW_SKIP VOCAB_FILE=$$VOCAB_FILE EMB_FILE=$$EMB_FILE TARGET=$@ MYTAG=$*  COL_SKIP=1 extrinsic_test_generic

extrinsic_test_generic: $(VOCAB_FILE) $(EMB_FILE)
	$(MATCMDENV)"tic; word=textread('$(VOCAB_FILE)', '%s', 'headerlines', $(ROW_SKIP)); emb=dlmread('$(EMB_FILE)', '', $(ROW_SKIP), $(COL_SKIP)); if size(emb,2)==600 emb=(emb(:,1:300)+emb(:,301:600))/2; end; emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, '$(MYTAG)', word, 1); toc; exit;" | tee $(TARGET)

COMBINED_EMB_JOBNAME_MAKER = combined_embedding_$*_trunccol125000_16
log/combined_embedding_%: $(STORE2)/combined_embedding_%.mat
	sleep 3 && qsub -N log_combined_embedding_$* -hold_jid $(COMBINED_EMB_JOBNAME_MAKER) -V -l mem_free=5G,ram_free=1G,hostname="a*" -r yes -pe smp 1 -cwd submit_grid_stub.sh TARGET=$@ MYDEP=$< MYTAG='combined' log_combined_embedding_generic

log_combined_embedding_generic:
	$(MATCMDENV)"tic; load('$(MYDEP)'); emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, '$(MYTAG)', word, 1); toc; exit;" | tee $(TARGET)

$(STORE2)/combined_embedding_%.mat: 
	qsub -N $(COMBINED_EMB_JOBNAME_MAKER) -V -l mem_free=15G,ram_free=2G,hostname="a*" -r yes -pe smp 10 -cwd submit_grid_stub.sh TARGET=$@ REMOVE_MVLSA=$* combined_embedding_generic

combined_embedding_generic: $(STORE2)/v5_embedding_mc_CountPow025-trunccol12500_500~E@mi,300_1e-5_16.mat
	$(MATCMD)"w2v_vocab_file='$(STORE2)/word2vec_mytrain.txt_word'; w2v_emb_file='$(STORE2)/word2vec_mytrain.txt'; w2v_skip=1;  glove_vocab_file='$(VOCAB_500K_FILE)'; glove_emb_file='$(STORE2)/glove_mytrain.txt'; glove_skip=0; mvlsa_vocab_file=glove_vocab_file; mvlsa_emb_file='$<'; savefile = '$(TARGET)'; remove_mvlsa=$(REMOVE_MVLSA); make_combined_embedding; exit;"

#################################################################################
## TRAIN MIKOLOV/GLOVE ON MY DATA AND PREPARE THEIR EMBEDDINGS FOR MY EVAL SCRIPT
GM_MEM := 20
$(STORE2)/glove_theirtrain.txt: $(STORE2)/glove.6B.300d.txt
	cp $< $@
# Your job 9894541 ("glove_0.1_mytrain") has been submitted
# Your job 9894542 ("submit_grid_stub.sh.glove_0.1_mytrain") has been submitted
# Your job 9894543 ("glove_1.1_mytrain") has been submitted
# Your job 9894545 ("submit_grid_stub.sh.glove_1.1_mytrain") has been submitted
qsub_glove:
	for SYMASYM in 0 1; do \
	  $(call QSUBPEMAKEHOLD4,glove_"$$SYMASYM".1_mytrain,a1[1238],10G,10) $(STORE2)/glove_"$$SYMASYM".1_mytrain.bin; sleep 5; \
	  $(call QSUBPEMAKEHOLD,submit_grid_stub.sh.glove_"$$SYMASYM".1_mytrain,glove_"$$SYMASYM".1_mytrain,1G,10) log/extrinsic_glove_"$$SYMASYM".1_mytrain_mycode; done

$(STORE2)/glove_%_mytrain.bin $(STORE2)/glove_%_mytrain.txt:
	$(MAKE) SYM_ASYM=$(word 1,$(subst ., ,$*)) X_MAX=$(word 2,$(subst ., ,$*)) TARGET=$@ glove_mytrain_generic
glove_mytrain_generic: $(STORE2)/glove_$(SYM_ASYM)_cooccurence_shuf_file $(VOCABWITHCOUNT_500K_FILE)
	$(GLOVEDIR)/glove -save-file $(subst .bin,,$(TARGET)) -threads 20 -input-file $< -x-max $(X_MAX) -iter 25 -vector-size 300 -binary 2 -vocab-file $(word 2,$+) -verbose 2 -model 2
$(STORE2)/glove_%_cooccurence_shuf_file: $(STORE2)/glove_%_cooccurence_file
	$(GLOVEDIR)/shuffle -memory $(GM_MEM) -verbose 2 < $< > $@
$(STORE2)/glove_%_cooccurence_file: $(VOCABWITHCOUNT_500K_FILE) $(STORE)/polyglot_wikitxt/en/full.txt_lowercase
	$(GLOVEDIR)/cooccur -memory $(GM_MEM) -vocab-file $< -verbose 2 -window-size 15 -symmetric $* < $(word 2,$+) > $@

# qsub -V -j y -l mem_free=10G -r yes -pe smp 20 -cwd submit_grid_stub.sh $(STORE2)/word2vec_mytrain.bin
TXT2BIN_CMD = ./res/convertvec txt2bin $<  $@
$(STORE2)/word2vec_mytrain.bin: $(STORE2)/word2vec_mytrain.txt
	$(TXT2BIN_CMD)
$(STORE2)/word2vec_mytrain.txt: $(STORE)/polyglot_wikitxt/en/full.txt_lowercase $(VOCABWITHCOUNT_500K_FILE)
	$(WORD2VECDIR)/word2vec -train $< -size 300 -window 10 -hs 0 -negative 15 -threads 20 -min-count 10 -output $@ -dumpcv $@_context -binary 0 -read-vocab $(word 2,$+)

$(STORE)/word2vec_theirtrain.bin: $(STORE)/word2vec_theirtrain.txt
	$(TXT2BIN_CMD)
$(STORE)/word2vec_theirtrain.txt: $(STORE)/gn300.txt
	 awk '{if(!index($$1, "_")){print $$0}}' $< > $@
##############################
## TABULATION CODE
TABCMD = cat $$F | sed "s%original embedding%O%g" | sed -e "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\), [0-9]*\] is \([0-9.]*\), \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" -e "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" -e "s%The TOEFL score over \([0-9A-Za-z_-]*\) with bare \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The TOEFL $$corrtype score over \1 (\3 out of \2) is \5%g" -e "s%The $$corrtype Corr over \([0-9A-Za-z_-]*\) is%The JURI $$corrtype correlation over \1 (0 out of 0) is%g" | grep -E "The .* $$corrtype"  
TAB_SPEARMAN = export F=log/$* && export corrtype=Spearman &&
TAB_PEARSON = export F=log/$* && export corrtype=Pearson && 
TABCMD1 =  | grep "over G" | awk '{printf "%s\n", $$NF}'
TABCMDA =  | awk '{printf "%s %s out of %s \t %s \t %s\n", $$2, $$7, $$10, $$6, $$NF}' | python src/tabulation_script.py
# TARGET: Call tab_Spearman when you want results only over G
ts_%: #log/%
	$(TAB_SPEARMAN) $(TABCMD) | python src/rearrange_tabs.py MEN RW SCWS SIMLEX  EN_WS_353_ALL EN_MTURK_287 EN_WS_353_REL EN_WS_353_SIM EN_RG_65 EN_MC_30 EN_TOM_ICLR13_SYN EN_TOM_ICLR13_SEM TOEFL | awk '{printf "%0.1f\n", 100*$$NF}' 
vts_%: #log/%
	$(TAB_SPEARMAN) $(TABCMD) | python src/rearrange_tabs.py MEN RW SCWS SIMLEX  EN_WS_353_ALL EN_MTURK_287 EN_WS_353_REL EN_WS_353_SIM EN_RG_65 EN_MC_30 EN_TOM_ICLR13_SYN EN_TOM_ICLR13_SEM TOEFL 
tp_%: #log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMD1)
# TARGET: Call tabulate when you want results over 
tbspearman_%: #log/%
	$(TAB_SPEARMAN) $(TABCMD) $(TABCMDA) $*
tbpearson_%: #log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMDA) $*

#########################
## FULLGCCA EVAL CODE
# TARGET: log/fullgcca_extrinsic_test_%.300.0.1
# Possibilities for % are 
# mc_CountPow025-trunccol200000_100~@fn,300_1e-5_25
# mc_CountPow025-truncatele200_100~@fn,300_1e-5_25
# mc_CountPow025^CountPow075-trunccol200000_100~@fn,300_1e-5_25
# mc_CountPow025-trunccol200000_100~E@mi,300_1e-5_25
# mc_CountPow025-trunccol100000_300~E@mi,300_1e-5_25
# mc_CountPow025-trunccol50000_100~E@mi,300_1e-5_25
# And the parts delimited by the periods are
# 1. The main options given to GCCA
# 2. DIM_AFTER_CCA
# 3. Whether to test over mikolov's analogy
# 4. Whether to DO_ONLY_G
GET_LOG_OPT = $(word $1,$(subst ., ,$*))
V5_EMB_JOBNAME_MAKER = tmp_embqsub_$(subst $(COMMA),,$(subst @,_at_,$*))
log/fullgcca_extrinsic_test_%:
	$(MAKE) JOB_NAME=$(subst $(COMMA),,$(subst @,_at_,tmp_$(@F))) \
		JID_HOLD=$(subst v5_embedding_,,$(word 1,$(subst ., ,$(V5_EMB_JOBNAME_MAKER)))) \
		MEMORY=5G \
		PE=1 \
		TARGET=$@ \
		MYDEP=$(STORE2)/$(call GET_LOG_OPT,1).mat \
		DIM_AFTER_CCA=$(call GET_LOG_OPT,2) \
		DOMIKOLOV=$(call GET_LOG_OPT,3) \
		DO_ONLY_G=$(call GET_LOG_OPT,4) \
	gcca_extrinsic_test_gen1

gcca_extrinsic_test_gen1: $(MYDEP)
	sleep 3 && $(call QSUBPEMAKEHOLD,$(JOB_NAME),$(JID_HOLD),$(MEMORY),$(PE)) \
		TARGET=$(TARGET) \
		MYDEP=$(MYDEP) \
		DIM_AFTER_CCA=$(DIM_AFTER_CCA) \
		DOMIKOLOV=$(DOMIKOLOV) \
		DO_ONLY_G=$(DO_ONLY_G) \
	gcca_extrinsic_test_generic 

gcca_extrinsic_test_generic:  
	$(MATCMDENV)"word=textread('$(VOCAB_500K_FILE)', '%s'); load('$(MYDEP)'); if size(G, 1) < size(G, 2); G=G'; end; word=word(sort_idx); do_only_g=$(DO_ONLY_G); if do_only_g word2vec_emb=nan; emb_word=nan; else word2vec_emb=dlmread('$(STORE2)/word2vec_theirtrain.txt', '', 1, 1); emb_word=textread('$(STORE2)/word2vec_theirtrain.txt_word', '%s', 'headerlines', 1); end; bitext_true_extrinsic_test(G, word2vec_emb, $(DIM_AFTER_CCA), word, $(DOMIKOLOV), do_only_g, emb_word); exit;" | tee $(TARGET)
########################################
## MSR TESTING CODE
check_msr_performance:
	for f in log/gcca_msr_test_mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_25.* ; do \
		python src/count_correct_msr_predictions.py $$f ; done  | awk 'BEGIN{s=0}{s+=$$2}END{print s/1040}'

qsub_msr_test:
	for st in {1..1040..104}; do \
	    $(QSUBMAKE) START=$$st DELTA=103 log/gcca_msr_test_mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_25; done 

MSRMATCMD = time matlab -nojvm -nodisplay -r "addpath('src'); setenv('MSR_QUESTIONS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.questions.txt'); setenv('MSR_ANSWERS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.answers.txt');"
# % can be mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_25
log/gcca_msr_test_%: $(STORE2)/v5_embedding_%.mat
	$(MSRMATCMD)"big_word_list=textread('$(VOCAB_500K_FILE)', '%s'); embedding_file='$<'; load(embedding_file, 'G', 'sort_idx'); msrd=get_msr_data(); G=normalize_embedding(G); big_word_map=containers.Map(big_word_list, 1:length(big_word_list)); small_word_map=containers.Map(big_word_list(sort_idx), 1:sum(sort_idx)); MU1={}; UJ={}; CPL={}; for k=1:15 ll=['$(STORE2)/projection_polyglotwiki_cooccurence_' num2str(k) '.' embedding_file(length('$(STORE2)/v5_embedding_')+1:end)]; pj_mat_file=matfile(ll); UJ{k}=(pj_mat_file.uj); CPL{k}=pj_mat_file.column_picked_logical;   aa=strsplit(ll, '~'); bb=strsplit(aa{1}, '.'); bb=[strrep(bb{1}, 'projection', 'v5_indisvd') '~' strrep(bb{2}, '_', '~') '~1e-5.mat']; bb=matfile(bb); MU1{k}=bb.mu1; end; gcca_msr_test(big_word_list, big_word_map, small_word_map, G, sort_idx, msrd, UJ, CPL, [$(START) $(DELTA)], MU1); exit;" | tee $@.$(START)

########################################
## PROJECTION CREATION CODE
# TARGET: for m in 300 500; do for h in {1..15};
# $STORE2/projection_polyglotwiki_cooccurence_"$h".mc_CountPow025-trunccol100000_"$m"~E@mi,300_1e-5_25.mat;
$(STORE2)/projection_%.mat:
	$(MATCMD)"options=strsplit('$*','.'); load(['$(STORE2)/v5_embedding_' options{2} '.mat'], 'G', 'sort_idx');  tmp=strsplit(options{2}, '~'); poly_view=['$(STORE2)/v5_indisvd_' options{1} '~' strrep(tmp{1}, '_', '~') '~1e-5.mat']; load(poly_view, 'aj', 'sj', 'bj', 'r', 'column_picked_logical'); sj=sparse_diag_mat(sj); sj=inv(sj*sj+r*speye(size(sj,2)))*sj; aj=aj(sort_idx,:)'; uj = bj*(sj*(aj*G)); save('$@', 'uj', 'column_picked_logical'); exit;"

#######################################
## GCCA Running Code
# TARGET: The typical targets are
# (Note : I should always remove mikolov by default)
# $STORE2/v5_embedding_mc_CountPow025-trunccol200000_100~@fn,300_1e-5_25.mat
# $STORE2/v5_embedding_mc_CountPow025-truncatele200_100~@fn,300_1e-5_25.mat
# $STORE2/v5_embedding_mc_CountPow025^CountPow075-trunccol200000_100~@fn,300_1e-5_25.mat
# $STORE2/v5_embedding_mc_CountPow025-trunccol200000_100~E@mi,300_1e-5_25.mat
# $STORE2/v5_embedding_mc_CountPow025-trunccol100000_300~E,300_1e-5_25.mat 
# $STORE2/v5_embedding_mc_CountPow025-trunccol50000_100~E,300_1e-5_25.mat
# $STORE2/v5_embedding_mc_CountPow025-truncatele200_100~E@mi,300_1e-5_25.mat
# The filename is constructed  by joing 3 parts 
# 1. The options given to the underlying SVD (the dataset name is determined in separate script)
# 	a. mc or muc
# 	b. preprocessing (CountPow025^CountPow075-trunccol200000)
# 	c. number of svd dime
# 	d. regularization
# 2. A small descriptor of the datasets that we want to include
# 	We specify whether we want to keep a file or to exclude it by the global flag E
# 	Then delimited by @ we specify datasets by their codes
# 	Acceptable codes are
#	  fn : Framenet/PPDB
#	  mo : Morphology
#	  po : Polyglot Wiki
#	  ag : Agiga
#	  mi : Mikolov
#	  bi : Bitext
# 3. GCCA_OPT (300_1e-5_25)
#	a. The first is the dimension of the embedding
#	b. The second is regularization
#	c. The third is the number of datasets in which a word must appear before it will be allowed.
# SOURCE : mat files containing svd of the individual views.
# This rule basically launches the SVD of the individual files then
# registers another job which hold_jid on dependencies which I have
# named properly. This is the way to depend on makefile dependencies
# that we have qsubbed
GCCA_OPT_EXTRACTOR = $(word 2,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
V5_PREPROC_OPT_EXTRACTOR = $(word 1,$(subst -, ,$(word 2,$(subst _, ,$*))))
$(STORE2)/v5_embedding_%.mat:
	$(MAKE) TARGET=$@ \
		DEP_FILE_NAME=tmpv5dep_$* \
		JOB_NAME=$(V5_EMB_JOBNAME_MAKER) \
		GCCA_OPT=$(GCCA_OPT_EXTRACTOR) \
		M=$(word 3,$(subst _, ,$(word 1,$(subst ~, ,$*))))\
		V56_GENERIC_DEP="`python src/calculate_dependency.py $* $(STANDEP_LIST) $(subst $(SPACE),$(COMMA),$(BIG_LANG)) $(STORE2)`" \
		HOLD_JID="`python src/calculate_dependency.py $* $(STANDEP_LIST) $(subst $(SPACE),$(COMMA),$(BIG_LANG)) $(STORE2)  | sed s%$(STORE2)/v5_indisvd%tmp%g | sed 's%.mat %,%g' | rev | cut -c 2- | rev `" v5_generic_qsub 

v5_generic_qsub: $(V56_GENERIC_DEP)
	echo $(V56_GENERIC_DEP) > $(DEP_FILE_NAME) && \
	sleep 3 &&  \
	  $(call QSUBPEMAKEHOLD3,$(JOB_NAME),$(HOLD_JID),100G,60G,1) \
		TARGET=$(TARGET) \
		DEP_FILE_NAME=$(DEP_FILE_NAME) \
		GCCA_OPT=$(GCCA_OPT) \
		M=$(M) \
	    v5_generic 

v5_generic: $(V56_GENERIC_DEP)
	 $(MATCMD)"options=strsplit('$(GCCA_OPT)', '_'); embedding_size=str2num(options{1}); reg_unused_=options{2}; min_view_to_accept_word=str2num(options{3}); M=$(M); deptoload=textscan(fopen('$(DEP_FILE_NAME)'), '%s'); deptoload=deptoload{1}; [G, S_tilde, sort_idx]=v5_generic_tmp(embedding_size, deptoload, min_view_to_accept_word, M); save('$(TARGET)', 'G', 'S_tilde', 'sort_idx', '-v7.3'); disp(getReport(MException.lasterror)); exit;"

######################################################################
## SVD RUNNING CODE (OVER RAW DATA)
# TARGET: v5_indisvd_fnppdb_cooccurence_xl~mc~CountPow025-truncatele200~100~1e-5.mat
# The options are ddelimited by ~ and the options are
# 1. The name of file to load
# 2. mc or muc
# 3. The preprocessing options (CountPow050-trunccol100000)
# 4. The number of left SVD vectors (100 or 300)
# 5. The regularization value (1e-5)
# TARGET: If you call the impl then you run on the machine, otherwise
#    you qsub the job. This is done because I want to depend on the mat
#    files by name and qsub the dependency by default. I put a wait loop
#    on these jobs so that their parents dont start running till the qsub
#    jobs are complete. 
# SOURCE: It mainly depends on f2load which is options{1}
#    Some massaging is done in the v5_indisvd code takes the svd
#    according to the options and then ajtj are calculated.
# With 300 columns it only takes 5 slots and 15G memory
V5_INDISVD_MEM := 25G
$(STORE2)/v5_indisvd_%.mat:
	qsub -N tmp_$* -p -1 -V -j y -l mem_free=$(V5_INDISVD_MEM),h_vmem=$(V5_INDISVD_MEM) -r yes -pe smp 5 -cwd submit_grid_stub.sh $(STORE2)/v5_indisvd_"$*".impl 

V5_INDISVD_CMD1 = "options=strsplit('$*', '~'); f2load=['$(STORE2)/' options{1} '.mat']; load(f2load); assert(exist('align_mat')==1); mc_muc=options{2}; if strcmp(f2load, '$(STORE2)/mikolov_cooccurence_intersect.mat') preprocess_option='Count'; else preprocess_option=options{3}; end; svd_size=str2num(options{4}); r=str2num(options{5}); outfile='$(word 1,$(subst ., ,$@)).mat';"
# The usage for the below targets is as follows
# for m in 300 500; do for n in {1..15}; do echo /export/a14/prastog3/v5_indisvd_polyglotwiki_cooccurence_"$n"~mc~CountPow025-trunccol100000~"$m"~1e-5.append_mean ; done; done | xargs -I % -P 4 make %
$(STORE2)/v5_indisvd_%.append_mean:
	$(MATCMD)$(V5_INDISVD_CMD1)"[~, mu1, mu2, ~, ~]=preprocess_align_mat(align_mat, preprocess_option); save(outfile, 'mu1', 'mu2', '-append'); exit;"
$(STORE2)/v5_indisvd_%.append_column_picked:
	$(MATCMD)$(V5_INDISVD_CMD1)"[~, column_picked_logical]=process_opt_and_get_column_logical(preprocess_option, align_mat); save(outfile, 'column_picked_logical', '-append'); exit;"
$(STORE2)/v5_indisvd_%.impl:
	$(MATCMD)$(V5_INDISVD_CMD1)"[ajtj, kj_diag, aj, sj, column_picked_logical, bj]=v5_indisvd_level2(align_mat, mc_muc, preprocess_option, svd_size, r, outfile); save(outfile, 'ajtj', 'kj_diag', 'aj', 'sj', 'r', 'column_picked_logical', 'bj'); exit;"

######################################################################
## INPUT PREPARATION CODE 
# Currently all the data files are as follows.
# $STORE2/fnppdb_cooccurence_xl.mat
# $STORE2/morphology_cooccurence_inflection.mat
# $STORE2/polyglotwiki_cooccurence_1 to 15.mat
# $STORE2/agigastandep_cooccurence_$(STANDEP_LIST).mat
# $STORE2/mikolov_cooccurence_intersect.mat
# $STORE2/bitext_cooccurence_$(BIG_LANG).mat
# In order to check that the data files are correct, I did the following
# 1. I loaded the fnppdb_cooccurence_xl.mat file and checked that it
#    contained an entry for 
#    there should be an entry for (renounced, Abandonment)
#    0	2031	Abandonment	renounced.v
#    0	2031	Abandonment	forsaken.n
#    grep -n renounced $VOCAB_500K_FILE = 18778
#    so the entry should be align_mat(18778, 600)==1 and the other
#    entry is align_mat(44449, 600)==1 
# 2. I loaded the morphology_cooccurence_inflection file and checked
#    that spayed, spaying were matched to love 
#    Basically I checked that spayed and spaying map to spay
#    158962:spayed, 176925:spaying and align_mat(176925,:) align_mat(158962,:)
# 3. I loaded the polyglotwiki_cooccurence_1.mat and basically checked
#    that the unigram counts of the rows line up with he information in
#    VOCABWITHCOUNT_500K_FILE
# 4. I had already checked agiga earlier. But I still loaded
#    agigastandep_cooccurence_prep_in.mat and then checked that the row
#    and column made sense.
# 5. bitext_cooccurence_en.mat
#    All of this basically tells me that there are some columns
#    completely zero. Also there can be a large number of rows 
#    completely zero. For example in bitext_ar there are   4815880 zero
#    rows and in bitext_cs there are 4941260 zero rows. (Like all of
#    them.)
H5_TO_MAT_MAKER = $(shell echo "align_mat=spconvert(h5read('$1.h5', '/cooccurence_data')); save('$1', 'align_mat', '-v7.3');")
# TARGET: Basically converts the data in h5 to a 7.3 mat file.
# This is the only good interop method between python and mat
# file that I could find which is
# not an ascii text (too big and prone to corruption)
# I want this rule to fail if the dependency does not exist
# instead of trying to make the dependency. Since this is only
# to fix failed jobs anyway where I am making the targets manually.
h5_to_mat_maker_%: # % 
	$(MATCMD)"$(call H5_TO_MAT_MAKER,$*)"
make_all_cooccurences: # $(STORE2)/freebase_cooccurence_%.mat
	$(MAKE) run_agigastandep_mat_on_grid   morphogrid fnppdbgrid polygrid
COE_LOCATION = prastogi@external.hltcoe.jhu.edu:/export/projects/prastogi/store2/
copy_all_cooccurences_to_coe:
	for file in \
		fnppdb_cooccurence_l.mat fnppdb_cooccurence_xl.mat  \
		morphology_cooccurence_inflection.mat \
		; do \
		echo scp $(STORE2)/$$file $(COE_LOCATION) ; done \
	for i in {1..15}; do echo $$i ; done | xargs -I % -P 3   scp $(STORE2)/polyglotwiki_cooccurence_%.mat $(COE_LOCATION) \
	for r in $(subst $(COMMA), ,$(STANDEP_LIST)); do echo $$r ; done | xargs -I % -P 3   scp $(STORE2)/agigastandep_cooccurence_%.mat $(COE_LOCATION) \
	for b in $(BIG_LANG); do echo $$b ; done | xargs -I % -P 3 scp $(STORE2)/bitext_cooccurence_%.mat $(COE_LOCATION) \
	scp $(VOCAB_500K_FILE) $(COE_LOCATION) \
	scp -r src prastogi@external.hltcoe.jhu.edu:/home/hltcoe/prastogi/mvppdb/ \
	for e in /word_sim/toefl.qst /word_sim/toefl.ans /word_sim/scws_simplified.txt /word_sim/rw_simplified.txt /word_sim/MEN.txt /word_sim/EN-MC-30.txt /word_sim/EN-MTurk-287.txt /word_sim/EN-RG-65.txt /word_sim/EN-TOM-ICLR13-SEM.txt /word_sim/EN-TOM-ICLR13-SYN.txt /word_sim/EN-WS-353-REL.txt /word_sim/EN-WS-353-SIM.txt /word_sim/EN-WS-353-ALL.txt /wordnet.test /ppdb_paraphrase_rating /word_sim/simlex_simplified.txt  ; do echo scp prastog3@login.clsp.jhu.edu:~/projects/mvppdb/res"$e" res/ ; done
#########################################
## FRAMENET/PPDB COOCCURENCE EXTRACTOR
fnppdbgrid:
	$(QSUBMAKE) run_fnppdb_on_grid
run_fnppdb_on_grid:
	for db in l xl ; do $(MAKE)  $(STORE2)/fnppdb_cooccurence_"$db".mat ; done
# This also creates $(STORE2)/wordnet_cooccurence_%.mat
# That is a bit misleading since there is no l or xl in wordnet.
$(STORE2)/fnppdb_cooccurence_%.mat: $(VOCAB_500K_FILE) /home/prastog3/projects/paraphrase_framenet/fn15-frameindexLU-% 
	python src/create_fnppdb_cooccurence.py $+ $@

######################################
## MORPHOLOGY COOCCURENCE EXTRACTOR
morphogrid:
	$(QSUBMAKE) $(STORE2)/morphology_cooccurence_inflection.mat

$(STORE2)/morphology_cooccurence_inflection.mat: $(VOCAB_500K_FILE) $(STORE)/catvar21.txt
	PYTHONPATH=$$PYTHONPATH:~/projects/rephit python src/create_morphological_cooccurence.py $+ $@ 2> $@.log && matlab -r "load $@; align_mat=align_mat(:,sum(align_mat)>1); save('$@', 'align_mat');"

#################################
## WIKIPEDIA POLYGLOT EXTRACTOR
polygrid: 
	qsub -V -j y -l mem_free=50G,ram_free=50G,h_vmem=50G -l hostname=a15 -r yes -cwd submit_grid_stub.sh run_polyglot_on_grid
run_polyglot_on_grid: 
	for i in {1..15}; do echo $$i; done | xargs -I % -P 3 $(MAKE) $(STORE2)/polyglotwiki_cooccurence_%.mat
# TARGET: A target looks like $(STORE2)/polyglotwiki_cooccurence_15. 
#         The number after the last underscore is the window size. 
# SOURCE: The first source is the vocabulary file and the second is
#         the actual text
$(STORE2)/polyglotwiki_cooccurence_%.mat: $(VOCAB_500K_FILE) $(STORE)/polyglot_wikitxt/en/full.txt
	$(MAKE) VOCAB=$< TEXT=$(word 2,$+) WINDOW_SIZE=$* TARGET=$@ polyglotwiki_cooccurence_generic
BOS_TO_MAINTAIN := 15
MIN_LENGTH_SENTENCE := 3
# Polyglot English text has 75,241,648 lines, 1.7 billion tokens.
# 75,241,648 1,703,855,951 9320072335
polyglotwiki_cooccurence_generic: 
	time python src/count_cooccurence.py $(VOCAB) $(TEXT) $(WINDOW_SIZE) $(TARGET).h5 $(BOS_TO_MAINTAIN) $(MIN_LENGTH_SENTENCE) && $(MATCMD)"$(call H5_TO_MAT_MAKER,$(TARGET))"

##############################
## AGIGA PROCESSING CODE
AGIGADIR := /export/corpora5/LDC/LDC2012T21
AGIGATOOLDIR := $(AGIGADIR)/tools/agiga_1.0
STANDEP_LIST_PART1 := pobj
STANDEP_LIST_PART2 := nsubj,amod,advmod,rcmod,dobj,prep_of,prep_in,prep_to,prep_on,prep_for,prep_with,prep_from,prep_at,prep_by,prep_as,prep_between,xsubj,agent,conj_and,conj_but
STANDEP_LIST := $(STANDEP_LIST_PART1),$(STANDEP_LIST_PART2)
STANDEP_LIST_PREPROCOPT := +nsubj.pass,-pobj,$(STANDEP_LIST_PART2)
# TARGET: This creates 21 mat files. One per relation type by gatherings counts from all the files.
# SOURCE: All the files in the $STORE2/agigastandep directory and the 21 relation types.
#         and a mapping of those relations to indices
run_agigastandep_mat_on_grid: 
	for r in $(subst $(COMMA), ,$(STANDEP_LIST)); do qsub -V -j y -l mem_free=$(QSDM),ram_free=$(QSDM),h_vmem=$(QSDM) -l hostname=a14  -cwd submit_grid_stub.sh $(STORE2)/agigastandep_cooccurence_"$$r".mat; done
# for f = {'agigastandep_cooccurence_advmod.mat', 'agigastandep_cooccurence_agent.mat', 'agigastandep_cooccurence_amod.mat', 'agigastandep_cooccurence_conj_and.mat', 'agigastandep_cooccurence_conj_but.mat', 'agigastandep_cooccurence_dobj.mat', 'agigastandep_cooccurence_nsubj.mat', 'agigastandep_cooccurence_pobj.mat', 'agigastandep_cooccurence_prep_as.mat', 'agigastandep_cooccurence_prep_at.mat', 'agigastandep_cooccurence_prep_between.mat', 'agigastandep_cooccurence_prep_by.mat', 'agigastandep_cooccurence_prep_for.mat', 'agigastandep_cooccurence_prep_from.mat', 'agigastandep_cooccurence_prep_in.mat', 'agigastandep_cooccurence_prep_of.mat', 'agigastandep_cooccurence_prep_on.mat', 'agigastandep_cooccurence_prep_to.mat', 'agigastandep_cooccurence_prep_with.mat', 'agigastandep_cooccurence_rcmod.mat', 'agigastandep_cooccurence_xsubj.mat'}
# a=matfile(f{1});
# nnz(a.align_mat)
# end
# [ 4015188     1606652    11387725    14183679     1869579    12336577    25577979     2054765     1661466     2244597      727157     1345576     4556324     2861797     8002769     7681444     3354028     4008591     4289823     7079054     3116996]
$(STORE2)/agigastandep_cooccurence_%.mat:  $(VOCAB_500K_FILE) # $(STORE2)/agigastandep
	time python src/agigastandep_cooccurence_h5.py $* $(STANDEP_LIST) $(STORE2)/agigastandep $<  $@.h5 && $(MATCMD)"$(call H5_TO_MAT_MAKER,$@)"
# TARGET: This just cleans up on a botched attempt.
# clean_agigastandep:
# 	rm -rf $(STORE2)/agigastandep && mkdir $(STORE2)/agigastandep
# TARGET: This runs $(AGIGA)/standep on the grid.
# $STORE2/agigastandep has 1007 files once this finishes
run_agigastandep_directory_on_grid: 
	qsub -V -j y -l mem_free=$(QSDM),ram_free=$(QSDM),h_vmem=$(QSDM) -l hostname=a14  -cwd submit_grid_stub.sh $(STORE2)/agigastandep
# TARGET: This creates a directory which contains the dependency
# cooccurence counts for the list of relations specified in STANDEP_LIST
# and this uses the child _xargs target.
# SOURCE: It takes the vocabulary file and the Agiga data directory 
$(STORE2)/agigastandep: $(VOCAB_500K_FILE) $(AGIGADIR)/data/xml
	find $(word 2,$+) -name [clnwx]*.xml.gz | xargs -I % -P 2 $(MAKE) AGIGATOOLDIR=$(AGIGATOOLDIR) INPUT_FILE=% STANDEP_LIST=$(STANDEP_LIST) STANDEP_LIST_PREPROCOPT=$(STANDEP_LIST_PREPROCOPT) OUTPUT_DIR=$@ VOCAB_FILE=$< agigastandep_xargs
agigastandep_xargs:
	time java -cp "$(AGIGATOOLDIR)/build/agiga-1.0.jar:$(AGIGATOOLDIR)/lib/*" edu.jhu.agiga.AgigaPrinter stanford-deps $(INPUT_FILE) | pypy src/agigastandep_cooccurence_preproc.py $(VOCAB_FILE) $(STANDEP_LIST_PREPROCOPT) $(STANDEP_LIST)  $(OUTPUT_DIR)/$(notdir $(INPUT_FILE))

###########################################
## BITEXT PROCESSING CODE
gridrun_align_mat: 
	for targ in $(BIG_LANG); do $(QSUBMAKE) $(STORE2)/bitext_cooccurence_"$$targ".mat ; done 

# TARGET: sparse matrix encoding the alignment as a mat file
# SOURCE: 1. The vocabulary of the foreign language along with counts.
#	2. The embeddings for english words present in google and bitext
# 	3. The simplified file with alignments.
# Note that the word file is auto generated from the rule on top
$(STORE2)/bitext_cooccurence_%.mat: $(STORE2)/big_vocabcount_% $(VOCABWITHCOUNT_500K_FILE) $(STORE2)/ppdb-input-simplified-%
	time python src/create_sparse_alignmat.py $+ $@ 2> log/$(@F)

###########################################
## MIKOLOV PROCESSING CODE
# TARGET: Mat file which contains the google embeddings.
# TARGET : intersect big_vocabcount_en and google embedding
# 	Its a file with first column as the word,
#	second column is count in the source files.
#	third column onwards we have the embeddings.
# SOURCE : The google embedding and english big vocab
$(STORE2)/mikolov_cooccurence_intersect.mat: $(STORE)/gn300.txt $(VOCABWITHCOUNT_500K_FILE)
	time python src/overlap_between_google_and_big_vocabcount.py $+ $@

##################################
## FREEBASE COCCURENCE EXTRACTOR
# $(STORE2)/freebase_cooccurence_%.mat: # This data is being prepared in the COE grid.
# 	scp prastogi@external.hltcoe.jhu.edu:~/freebase_cooccurence_$*.mat $@

###############################
## FLICKR PREPARATION 
# submit_grid_stub.sh $STORE/flickr30k_PHOW_features.mat
# $(STORE2)/flickr30k_cooccurence_%.mat:
# FLICKR30KDIR := /export/a15/prastog3/flickr30k/flickr30k-images
# $(STORE)/flickr30k_PHOW_features.mat: $(FLICKR30KDIR)
# 	$(MATCMD)"input_dir='$<'; outputFile='$@'; [hists, image_path]=flickr30k_feature_extractor(input_dir, outputFile); save(outputFile, 'hists', 'image_path'); exit;"

###########################################
## BITEXTENGLISH PROCESSING CODE
SENTENCE_COUNT := 63789996
INCREMENT := 500000
VOCAB := 131133
max = if [ $1 -ge $2 ] ; then echo $1; else echo $2; fi


##########################################
## SIMPLIFIED FILE CREATION CODE
res/word_sim/simlex_simplified.txt: 
	awk '{if( NR > 1){print $$1, $$2, $$4}}' res/word_sim/SimLex-999.txt  > $@
# TARGET: The simplified outputs
# SOURCE: These are rare word and contextual word similarity datasets which need to simplified
res/word_sim/rw_simplified.txt: res/word_sim/rw.txt
	awk '{print $$1, $$2, $$3}' $+ > $@
res/word_sim/scws_simplified.txt: res/word_sim/scws.txt
	awk -F $$'\t' '{print $$2, $$4, $$8}' $+ > $@

###############################
## VOCABULARY CREATION CODE
VOCAB_POLYGLOT_CMD = head -n $*000 $< > $@
$(STORE)/polyglot_wikitxt/en/full.txt.vc10.%K: $(STORE)/polyglot_wikitxt/en/full.txt.vc10.1M
	$(VOCAB_POLYGLOT_CMD)
$(STORE)/polyglot_wikitxt/en/full.txt.vc5.%K: $(STORE)/polyglot_wikitxt/en/full.txt.vc5.1M
	$(VOCAB_POLYGLOT_CMD)
$(STORE)/polyglot_wikitxt/en/full.txt.vc%.1M: $(STORE)/polyglot_wikitxt/en/full.txt.vocabcount%.lower
	 head -n 1000000 $<  > $@
$(STORE)/polyglot_wikitxt/en/full.txt.vocabcount%.lower: $(STORE)/polyglot_wikitxt/en/full.txt
	time $(TOOLDIR)/count/vocab_count -min-count $* -verbose 0 -lowercase 1 -replacerandomnumber 1 < $(@D)/full.txt  > $@


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


# $(STORE)/gn300.txt.gz : $(STORE)/gn300.txt
# 	gzip -c $+ > $@

$(STORE)/gn300.txt: $(STORE)/GoogleNews-vectors-negative300.bin res/convertvec
	./res/convertvec bin2txt $<  $@ 

$(STORE)/GoogleNews-vectors-negative300.bin: $(STORE)/GoogleNews-vectors-negative300.bin.gz
	gunzip -c $< > $@

res/convertvec : src/convertvec.c
	$(CC) $+ -o $@ $(CFLAGS)