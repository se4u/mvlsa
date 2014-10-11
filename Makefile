.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input $(STORE2)/agigastandep
.INTERMEDIATE: gn_ppdb.itermediate
## GENERIC 
# TARGET : Contains just the words. extracted from 1st column of source
%_word: %
	awk '{print $$1}' $+ > $@
%_2column: %
	awk '{print $$1, $$2}' $+ > $@
echo_qstatfull:
	qstat | cut -c 73-75 | sort | uniq -c
echo_qstatarg_%:
	qstat -j $* | grep arg
echo_qsubpemake:
	echo $(QSUBPEMAKE)
# A literal space.
space :=
space +=
COMMA := ,
# Joins elements of the list in arg 2 with the given separator.
# 1. Element separator.
# 2. The list.
join-with = $(subst $(space),$1,$(strip $2))


## VARIABLES
# LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 addpath('src/kdtree');
QSUB1 := qsub
QSUB2 := -V -j y -l mem_free=30G -r yes #-verify
QSUBCMD := $(QSUB1) $(QSUB2) 
QSUBP1CMD := $(QSUB1) -p -1 $(QSUB2)
CWD_SUBMIT := -cwd submit_grid_stub.sh 
QSUBMAKE := $(QSUBCMD) $(CWD_SUBMIT)
QSUBP1MAKE := $(QSUBP1CMD) $(CWD_SUBMIT)
QSUBPEMAKE := $(QSUBCMD) -pe smp 10 $(CWD_SUBMIT)
QSUBP1PEMAKE := $(QSUBP1CMD) -pe smp 10 $(CWD_SUBMIT)
# QSUBPEMAKE := echo
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
STORE2 := /export/a14/prastog3
GLOVEDIR := /home/prastog3/tools/glove
TOOLDIR := /home/prastog3/tools
WORD2VECDIR := $(TOOLDIR)/word2vec/trunk
RESPATH := /home/prastog3/projects/mvppdb/res
BIG_LANG := ar cs de es fr zh 
BIG_INPUT := $(addprefix $(STORE2)/ppdb-input-simplified-,$(BIG_LANG))
BIG_INPUT_WORD := $(addsuffix _word,$(BIG_INPUT))
BIG_ALIGN_MAT := $(patsubst %,$(STORE2)/align_%.mat,$(BIG_LANG))
SVD_DIM := 500
PREPROCESS_OPT := Count logCount logCount-truncatele20 Count-truncatele20 logFreq Freq Freq-truncatele20 logFreq-truncatele20 logFreqPow075 FreqPow075 logFreqPow075-truncatele20 FreqPow075-truncatele20
MATCMD := time matlab -nojvm -nodisplay -r "warning('off', 'MATLAB:maxNumCompThreads:Deprecated'); warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src'); maxNumCompThreads(10); "
MATCMDENV := $(MATCMD)"setenv('TOEFL_QUESTION_FILENAME', '$(RESPATH)/word_sim/toefl.qst'); setenv('TOEFL_ANSWER_FILENAME', '$(RESPATH)/word_sim/toefl.ans'); setenv('SCWS_FILENAME', '$(RESPATH)/word_sim/scws_simplified.txt'); setenv('RW_FILENAME', '$(RESPATH)/word_sim/rw_simplified.txt'); setenv('MEN_FILENAME', '$(RESPATH)/word_sim/MEN.txt'); setenv('EN_MC_30_FILENAME', '$(RESPATH)/word_sim/EN-MC-30.txt'); setenv('EN_MTURK_287_FILENAME', '$(RESPATH)/word_sim/EN-MTurk-287.txt'); setenv('EN_RG_65_FILENAME', '$(RESPATH)/word_sim/EN-RG-65.txt'); setenv('EN_TOM_ICLR13_SEM_FILENAME', '$(RESPATH)/word_sim/EN-TOM-ICLR13-SEM.txt'); setenv('EN_TOM_ICLR13_SYN_FILENAME', '$(RESPATH)/word_sim/EN-TOM-ICLR13-SYN.txt'); setenv('EN_WS_353_REL_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-REL.txt'); setenv('EN_WS_353_SIM_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-SIM.txt'); setenv('EN_WS_353_ALL_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-ALL.txt'); setenv('WORDNET_TEST_FILENAME', '$(RESPATH)/wordnet.test'); setenv('PPDB_PARAPHRASE_RATING_FILENAME', '$(RESPATH)/ppdb_paraphrase_rating'); setenv('SIMLEX_FILENAME', '$(RESPATH)/word_sim/simlex_simplified.txt'); "

######################################################################
## PAPER MAKING CODE
table_absbest: 
	make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-truncatele20_500~stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14,300_1e-8,monomultiwindow.300

table_m: 
	for m in 50 100 300 500 800 1000; do echo m=$$m && make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_"$$m"~stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14,300_1e-5,monomultiwindow.300 ; done 

table_t: 
	for trunc in 20 200 1000 2000 ; do echo trunc=$$trunc && make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele"$$trunc"_100~stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14,300_1e-5,monomultiwindow.300 ; done

table_n:
	for n in Count Freq logFreq logCount CountPow050 FreqPow050 CountPow025 FreqPow025 ; do echo n=$$n && make tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_"$$n"-truncatele200_100~stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14,300_1e-5,monomultiwindow.300 ; done

table_n_ext:
	for n in CountPow012 FreqPow012; do make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_"$$n"-truncatele200_100~stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14,300_1e-5,monomultiwindow.300 ; done

table_nconcat: 
	for n in CountPow025^CountPow050^logFreq^FreqPow025^FreqPow050^logCount^Count^Freq \
	         CountPow025^CountPow050^logFreq^FreqPow025^FreqPow050^logCount^Count \
	         CountPow025^CountPow050^logFreq^FreqPow025^FreqPow050^logCount \
	         CountPow025^CountPow050^logFreq^FreqPow025^FreqPow050 \
	         CountPow025^CountPow050^logFreq^FreqPow025 \
	         CountPow025^CountPow050^logFreq \
	         CountPow025^CountPow050 ; do \
	            echo $$n ; make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_"$$n"-truncatele200_100~stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14,300_1e-5,monomultiwindow.300; \
	done

table_mean:
	for m in mc muc ; do echo "Mean Normalization"=$$m && make  tab_Spearman_fullgcca_extrinsic_test_v5_embedding_"$$m"_FreqPow025-truncatele200_100~stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6@monotext8,300_1e-5,monomultiwindow.300 ; done | pr -2

table_r:
	for r in 2 3 4 5 6 7 8 9 10 ; do echo r=1e-$$r && make  tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_100~stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6@monotext8,300_1e-"$$r",monomultiwindow.300; done | pr -9 -l 26

table_multiviewcontri:
	for pc in stgccanoenbvgnmonotext1 stgccanoenbvgnmonotext1@monotext2 stgccanoenbvgnmonotext1@monotext2@monotext4 stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6 stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6@monotext8 stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6@monotext8@monotext10 stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6@monotext8@monotext10@monotext12 stgccanoenbvgnmonotext1@monotext2@monotext4@monotext6@monotext8@monotext10@monotext12@monotext14 stgccano@en@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14 stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14

table_multiviewcontri2:
	for pc in stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de@es@fr@zh stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de@es@fr stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de@es stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar ; do echo pc=$$pc && make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_100~"$$pc",300_1e-5,monomultiwindow.300; done
######################################################################
##  TABULATION CODE
# TARGET: Either MEGATAB_Spearman or MEGATAB_Pearson
MEGATAB_%:
	make tabulate_$*_bvgnFull_extrinsic_test && \
	make tabulate_$*_bitext_extrinsic_test_300_7000_1e-8_logCount.300 && \
	make tabulate_$*_monotext_extrinsic_test_v2_gcca_run_sans_mu_300_7000_1e-8_logCount && \
	make tabulate_$*_fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount && \
	make tabulate_$*_other_extrinsic_test_glove.42B.300d && \
	make tabulate_$*_other_extrinsic_test_glove.6B.300d 

TABCMD = cat $$F | sed "s%original embedding%O%g" | sed "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" | sed "s%The TOEFL score over \([0-9A-Za-z_-]*\) with bare \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The TOEFL $$corrtype score over \1 (\3 out of \2) is \5%g" | sed "s%The $$corrtype Corr over \([0-9A-Za-z_-]*\) is%The JURI $$corrtype correlation over \1 (0 out of 0) is%g" | grep -E "The .* $$corrtype"  | 
TAB_SPEARMAN = export F=log/$* && export corrtype=Spearman &&
TAB_PEARSON = export F=log/$* && export corrtype=Pearson && 
TABCMD1 = grep "over G" | awk '{printf "%s\n", $$NF}'
TABCMDA = awk '{printf "%s %s out of %s \t %s \t %s\n", $$2, $$7, $$10, $$6, $$NF}' | python src/tabulation_script.py
TABCMDB = $(TABCMD) $(TABCMDA)
tab_Spearman_%: log/%
	$(TAB_SPEARMAN) $(TABCMD) $(TABCMD1)
tab_Pearson_%: log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMD1)
tabulate_Spearman_%: log/%
	$(TAB_SPEARMAN) $(TABCMD) $(TABCMDA) $*
tabulate_Pearson_%: log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMDA) $*

##################################
#### GRID RUN CODE
##################################
MEGA_BIG_LOOP:
	for reg in 5 6 7 8 9; do \
	  for b in 1000 2000 3000; do\
	    $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_"$$b"_1e-"$$reg"_logCount; \
	  done ; \
	  $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v3_stgcca_run_sans_mu_300_1e-"$$reg"_logCount; \
	done
V4_MEGA_LOOP:
	for i in 5 6 7 8 9; do $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v4_stgcca_run_sans_mu_300_1e-"$$i"_logCount ; done

# TARGET: this creates things like
#       /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_logCount.mat 
#       /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat
# SOURCE: this uses things like
#       /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat 
# This takes roughly 8 hours for 6 files.
# I can experiment with 300_10000 (and higher) or 500_1000 (or higher)
v%_submit_gcca_run_sans_mu_to_grid:  
	    $(QSUBPEMAKE) $(STORE2)/v$*_gcca_run_sans_mu_300_7000_1e-8_logCount
submit_gcca_run_sans_mu_to_grid: 
	for transform in Count logCount; \
	    do $(QSUBPEMAKE) $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_"$$transform" ; done

# TARGET: A way to submit bitext_svd_%.mat jobs to the grid
submit_bitextsvd_to_grid_%:
	for lang in $(BIG_LANG); do for preproc in $(PREPROCESS_OPT); do $(QSUBPEMAKE) $(STORE2)/bitext_svd_"$$lang"_$*_"$$preproc".mat; done; done
# This example should make the final result of running this target clear
# qsub -V -j y -l mem_free=5G -r yes  -pe smp 25 -cwd submit_grid_stub.sh /export/a14/prastog3/monotext_svd_en_5_logCount-truncatele60.mat
# This job takes two hours for making trunc=20 file.
submit_monotextsvd_to_grid:
	for trunc in 60 40 20; do $(QSUBPEMAKE) $(STORE2)/monotext_svd_en_500_logCount-truncatele"$$trunc".mat; done


# TARGET: Mean centered SVD mat files
MEAN_CENTERED_SVD_LOOP:
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_ar_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_cs_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_de_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_es_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_fr_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_zh_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/monotext_mean_centered_svd_en_500_logCount-truncatele20.mat &&\
	$(QSUBPEMAKE) /export/a14/prastog3/monotext_mean_centered_svd_en_500_logCount-truncatele60.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bvgn_mean_centered_svd_embedding_500_Count.mat

NEWFANGLED_CAP:
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_300~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_800~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_1000~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele40_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele60_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele80_500~stgcca,300_1e-8.300
TOFANGLE_CAP:
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_Count-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_CountPow075-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_CountPow050-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_CountPow025-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCountPow075-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_Freq-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow012-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow025-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow025-truncatele200_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow050-truncatele200_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow075-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logFreq-truncatele20_500~stgcca,300_1e-8.300

MC_FANGLE_CAP: # 7975796  7975797  7975798
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele600_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele400_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele600_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele400_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele600_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele400_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele600_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele400_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele600_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_log1pFreq-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_FreqPow050-truncatele200_100~stgcca,300_1e-8.300

NO_FANGLE_CAP:
	for d2rm in stgccanoar stgccanocs stgccanode stgccanoes stgccanofr stgccanozh stgccanoen stgccanobvgn; do \
	  for meanchoice in mc muc; do \
	     $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_"$$meanchoice"_logCount-truncatele200_100~"$$d2rm",300_1e-8.300 ; \
	done; done

COMPARE_FANGLE_CAP:
	do for meanchoice in mc muc; do for preproc in logCount logFreq log1pFreq FreqPow025 FreqPow050; do\
	  $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_"$$meanchoice"_"$$preproc"-truncatele200_100~stgccanoenbvgn,300_1e-8.300 ; \
	done; done
ONLY_FANGLE_CAP: # 8003506  8003507  8003508  8003509  8003510  8003512  8003513  8003517  8003518  8003519 
	for meanchoice in mc muc; do for preproc in logCount logFreq log1pFreq FreqPow025 FreqPow050; do\
	  $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_"$$meanchoice"_"$$preproc"-truncatele200_100~stgccaonlyen,100_1e-8.100 ; \
	done; done
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
# log/fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount.300
# log/fullgcca_extrinsic_test_v3_stgcca_run_sans_mu_300_1e-8_logCount.300
# log/fullgcca_extrinsic_test_v4_stgcca_run_sans_mu_300_1e-8_logCount.300 # Your job 7869124
# make -n log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele2000_1000~gcca,300_1e-8_1000.300
# make -n log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele2000_1000~stgcca,300_1e-8.300
# mc : mean center, muc : mean uncentered
# logCount-truncatele2000 : truncate all less than 20
# 1000 : the original svd size
# gcca : Original gcca code, stgcca : the spacetime efficient gcca code
# 300_1e-8_1000 : the gcca parameters(gcca embedding size, reg_size, batch column size), 300_1e-8 : the stgcca parameters
# 300 the final gcca embeddings which would be used for evaluataion.
# SOURCE : This job runs from start to stop. I have to set up the data
# file, then take SVD, then store it into a single cell, then take
# gcca, then perform test upon it.
# SOURCE: big_vocabcount_en_intersect_gn_embedding which is the gn embeddings intersected with big_vocab that was made from 6 bitext files.
#         300_7000_1e-8_logCount are basically Hyper parameters that were used while creating the GCCA embeddings.
EXTRINSIC_TEST_CMD = "word=textread('$(word 1,$+)', '%s'); load('$(word 2,$+)'); load('$(word 3,$+)'); if size(G, 1) < size(G, 2); G=G'; end; sort_idx=sort_idx'; word=word(sort_idx); bvgn_count=bvgn_count(sort_idx); bvgn_embedding=bvgn_embedding(sort_idx,:); domikolov=1; do_only_G=0; bitext_true_extrinsic_test(G, bvgn_embedding, $(MYOPT), word, domikolov, do_only_G); exit;"
EXTRINSIC_TEST_DEP1 = $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat
log/fullgcca_extrinsic_test_%: 
	$(MAKE) TARGET=$@ MYOPT=$(word 2,$(subst ., ,$*)) MYDEP="$(EXTRINSIC_TEST_DEP1) $(STORE2)/$(word 1,$(subst ., ,$*)).mat" gcca_extrinsic_test_generic
gcca_extrinsic_test_generic: $(MYDEP)
	$(MATCMDENV)$(EXTRINSIC_TEST_CMD) | tee $(TARGET)
###### OTHER TEST  
# TARGET: a log file with all the test results.
# SOURCE: $(STORE2)/glove.6B.300d.mat (glove.42B etc.)
log/other_extrinsic_test_%:  $(STORE2)/%.mat
	$(MATCMDENV)"tic; load('$(word 1,$+)'); emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, id, word); fprintf(1, 'Total time taken %d\n', toc); exit;" | tee $@

####### MIKOLOV TEST
# Target: Basically this tests my word pruned version of the mikolov
# embeddings. I wanted to check whether my version of mikolov
# embeddings was flawed because they were not reaching the desired
# level of accuracy. So I tested both my version and the Full version
# on the test which was certified to be doing the correct thing at
# least for the Mikolov-Analogy task (because it worked for glove embeddings)
# bvgnPrunedppdb took only 1 hour
# bvgnFull took 5 hours.
log/%_extrinsic_test:
	if [ $* == bvgnPrunedppdb ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat" SECOND_DEP_IS_MAT=1 MYTAG=bvgnPrunedppdb mikolov_generic_test ; \
	elif [ $* == bvgnFull ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE)/gn300_word.txt $(STORE)/gn300.txt" SECOND_DEP_IS_MAT=0 MYTAG=bvgnFull HEADERLINES=1 mikolov_generic_test ; \B
	elif [ $* == word2vecBitext ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE2)/word2vec_embedding_file_word $(STORE2)/word2vec_embedding_file" SECOND_DEP_IS_MAT=0 MYTAG=word2vecBitext HEADERLINES=1  mikolov_generic_test ; \
	elif [ $* == gloveBitext ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE2)/glove_embedding_file.txt_word $(STORE2)/glove_embedding_file.txt" SECOND_DEP_IS_MAT=0 MYTAG=gloveBitext  HEADERLINES=0 mikolov_generic_test ; \
	else echo "unimplemented extrinsic_test type $*"; false; fi

mikolov_generic_test: $(MYDEP)
	$(MATCMDENV)"tic; if $(SECOND_DEP_IS_MAT)==1 load('$(word 2,$(MYDEP))'); word=textread('$(word 1,$(MYDEP))', '%s'); emb=normalize_embedding(bvgn_embedding); else word=textread('$(word 1,$(MYDEP))', '%s', 'headerlines', $(HEADERLINES)); emb=dlmread('$(word 2,$(MYDEP))', '', $(HEADERLINES), 1); end; conduct_extrinsic_test_impl(emb, '$(MYTAG)', word); fprintf(1, 'Total time taken %f seconds\n', toc); exit;" | tee $(TARGET)

# This code could be sped up.
# but anyway the problem is that it did not print the required information even after finishing.
log/eval_bvgn_using_word2vec_code_for_analogy_task: # Your job 7696236 (8 hours)
	$(WORD2VECDIR)/compute-accuracy /export/a15/prastog3/GoogleNews-vectors-negative300.bin < /home/prastog3/projects/mvppdb/res/word_sim/EN-TOM-ICLR13-SEM.txt > $@ && $(WORD2VECDIR)/compute-accuracy /export/a15/prastog3/GoogleNews-vectors-negative300.bin < /home/prastog3/projects/mvppdb/res/word_sim/EN-TOM-ICLR13-SEM.txt >> $@

run_glove_and_word2vec : Your job 7972791 7972792
	qsub -V -j y -l mem_free=40G -r yes  -pe smp 10 -cwd submit_grid_stub.sh $(STORE2)/glove_embedding_file && qsub -V -j y -l mem_free=20G -r yes -pe smp 20 -cwd submit_grid_stub.sh $(STORE2)/word2vec_embedding_file
$(STORE2)/glove_embedding_file: $(STORE2)/glove_cooccurence_shuf_file $(STORE2)/glove_vocab_file
	$(GLOVEDIR)/glove -save-file $@ -threads 10 -input-file $< -x-max 100 -iter 15 -vector-size 300 -binary 2 -vocab-file $(word 2,$+) -verbose 2 -model 0
$(STORE2)/glove_cooccurence_shuf_file: $(STORE2)/glove_cooccurence_file
	$(GLOVEDIR)/shuffle -memory 40 -verbose 2 < $< > $@
$(STORE2)/glove_cooccurence_file: $(STORE2)/glove_vocab_file $(STORE2)/only_english_from_ppdb_input
	$(GLOVEDIR)/cooccur -memory 40 -vocab-file $< -verbose 2 -window-size 10 < $(word 2,$+) > $@
$(STORE2)/glove_vocab_file: $(STORE2)/only_english_from_ppdb_input
	$(GLOVEDIR)/vocab_count -min-count 100 -verbose 2 < $< > $@
$(STORE2)/word2vec_embedding_file: $(STORE2)/only_english_from_ppdb_input
	$(WORD2VECDIR)/word2vec -train $< -size 300 -window 10 -hs 0 -negative 15 -threads 20 -min-count 100 -output $@ -dumpcv $@_context
#######################################
## GCCA Running Code
# TARGET: A Typical run would 300_1000_1e-8 (300 is the number of
# principal vectors, 1000 is the batch size, (higher is better))
# Or v3_stgcca_run_sans_mu_300_1e-8_logCount.mat
# Or $STORE2/v4_stgcca_run_sans_mu_300_1e-8_logCount.mat
# SOURCE : A mat file containing S, B, Mu1, Mu2 which contain the
# arabic, chinese, english bitext data 
GCCA_OR_ST_EXTRACTOR = $(word 1,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
GCCA_OPT_EXTRACTOR = $(word 2,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
V5_PREPROC_OPT_EXTRACTOR = $(word 1,$(subst -, ,$(word 2,$(subst _, ,$*))))
MONOMULTIWINDOW_DEP_OPT_EXTRACTOR = $(word 3,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
V56_EMBEDDING_CMD1 = TARGET=$@ V5_GCCA_OPT=$(GCCA_OPT_EXTRACTOR) GCCA_OR_ST=$(GCCA_OR_ST_EXTRACTOR) V56_GENERIC_DEP=
V56_EMBEDDING_CMD2 = DATASET_TO_KEEP=`python src/calculate_index_of_dataset_to_keep.py $(GCCA_OR_ST_EXTRACTOR)` v5_generic 
$(STORE2)/v5_embedding_%.mat:
	if [ "$(MONOMULTIWINDOW_DEP_OPT_EXTRACTOR)" == "monomultiwindow" ] ; then \
	   if [[ $(V5_PREPROC_OPT_EXTRACTOR) == *^* ]]; then \
	       $(MAKE) $(V56_EMBEDDING_CMD1)"$(foreach ppopt,$(subst ^, ,$(V5_PREPROC_OPT_EXTRACTOR)),$(subst $(V5_PREPROC_OPT_EXTRACTOR),$(ppopt),$(STORE2)/monomultiwindow_cell_input_$(word 1,$(subst ~, ,$*)).mat))" $(V56_EMBEDDING_CMD2) ; \
	   else \
	       $(MAKE) $(V56_EMBEDDING_CMD1)"$(STORE2)/monomultiwindow_cell_input_$(word 1,$(subst ~, ,$*)).mat" $(V56_EMBEDDING_CMD2) ; \
	   fi; \
	elif [ "$(MONOMULTIWINDOW_DEP_OPT_EXTRACTOR)" == "" ] ; then \
	    if [[ $(V5_PREPROC_OPT_EXTRACTOR) == *^* ]]; then \
	       echo $* && exit 1; \
	    else \
	       $(MAKE) $(V56_EMBEDDING_CMD1)"$(STORE2)/v5_cell_input_$(word 1,$(subst ~, ,$*)).mat" $(V56_EMBEDDING_CMD2) ; \
	    fi; \
	else \
	    echo $* && exit 1 ; \
	fi;

V5_GENERIC_CMD1 = "options=strsplit('$(V5_GCCA_OPT)', '_'); r=str2num(options{1}); "
V5_GENERIC_CMD2 = "tic; save('$(TARGET)', 'G', 'S_tilde', 'sort_idx'); toc; exit; "
v5_generic: $(V56_GENERIC_DEP)
ifeq ($(findstring stgcca,$(GCCA_OR_ST)),stgcca)
	$(MATCMD)$(V5_GENERIC_CMD1)"deptoload={$(foreach dep,$(V56_GENERIC_DEP),'$(dep)',)}; dsettokeep=[$(DATASET_TO_KEEP)]; S1={}; B1={}; for i=1:length(deptoload) load(deptoload{i}); S1=[S1 S(dsettokeep)]; B1=[B1 B(dsettokeep)]; end; svd_reg_seq=str2num(options{2})*ones(size(S1)); [G, S_tilde, sort_idx]=ste_rgcca(S1, B1, r, svd_reg_seq); "$(V5_GENERIC_CMD2)
else
	exit 1 && $(MATCMD)$(V5_GENERIC_CMD1)" [G, S_tilde, sort_idx]=se_gcca(S([$(DATASET_TO_KEEP)]), B([$(DATASET_TO_KEEP)]), r, str2num(options{3}), svd_reg_seq); "$(V5_GENERIC_CMD2)
endif

# SOURCE: A small test file to practice doing se_gcca.
test_gcca_run: res/tmp_bitext_svd.mat
	$(MATCMD)"load $<; S={s}; B={b}; [G, S_tilde]=se_gcca(S, B, 10, 2, [1e-8]); U_tilde=S'; exit;"

######################################################################
## CELL PREPARATION CODE
# TARGET: A single mat file containing S, B cell
# SOURCE: muc is mean uncentered. so if we have muc then mean uncentered svd is used
GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP = $(foreach lang,$(BIG_LANG),$(STORE2)/bitext_svd_$(lang)_%.mat)
GCCA_INPUT_TODO = $(patsubst %,load %; B=[B b]; S=[S s]; whos;,$+)
GCCA_INPUT_SVD_ALREADY_DONE_CMD = $(MATCMD)"tic; S={}; B={}; $(GCCA_INPUT_TODO) save('$@', 'S', 'B', '-v7.3'); toc; exit;"
V5_SVD_DEP = $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) $(STORE2)/monotext_svd_en_%.mat $(STORE2)/bvgn_svd_embedding_%.mat
MONOMULTIWINDOW_SVD_DEP = $(V5_SVD_DEP) $(STORE2)/monotext1_svd_en_%.mat $(STORE2)/monotext2_svd_en_%.mat $(STORE2)/monotext4_svd_en_%.mat $(STORE2)/monotext6_svd_en_%.mat $(STORE2)/monotext8_svd_en_%.mat $(STORE2)/monotext10_svd_en_%.mat $(STORE2)/monotext12_svd_en_%.mat $(STORE2)/monotext14_svd_en_%.mat $(STORE2)/monotext15_svd_en_%.mat
V5_MONOMULTI_CMD = if [ ! -e tmptouchfile_$(@F) ] ; then echo $(@F) && qsub -hold_jid $(call join-with,$(COMMA),$(+F)) -cwd submit_grid_stub.sh tmptouchfile_$(@F) && while [ ! -f tmptouchfile_$(@F) ] ; do sleep 300 ;done &&  $(GCCA_INPUT_SVD_ALREADY_DONE_CMD) ; else echo $(@F) && $(GCCA_INPUT_SVD_ALREADY_DONE_CMD) ; fi
$(STORE2)/monomultiwindow_cell_input_%.mat: $(subst $(STORE2)/,$(STORE2)/v5_indisvd_,$(MONOMULTIWINDOW_SVD_DEP))
	$(V5_MONOMULTI_CMD)

$(STORE2)/v5_cell_input_%.mat: $(subst $(STORE2)/,$(STORE2)/v5_indisvd_,$(V5_SVD_DEP))
	$(V5_MONOMULTI_CMD)

tmptouchfile_%:
	touch $@

######################################################################
## SVD RUNNING CODE (OVER RAW DATA)
$(STORE2)/v5_indisvd_%.mat:
	qsub -N $(@F) -p -1 -V -j y -l mem_free=25G -r yes -pe smp 10 -cwd submit_grid_stub.sh $(STORE2)/v5_indisvd_"$*".impl
$(STORE2)/v5_indisvd_%.impl:
	$(MATCMD)"optstr='$*'; options=strsplit(optstr, '_'); dtype=options{1}; lang=options{3}; mc_muc=options{4}; preprocess_option=options{5}; svd_size=str2num(options{6}); outfile='$(word 1,$(subst ., ,$@)).mat'; outdirname='$(@D)'; lif=larger_indisvd_filename(outdirname, outfile, optstr, options{6}); if isempty(lif) [b,s]=v5_indisvd(dtype, lang, mc_muc, preprocess_option, svd_size, '$(STORE2)'); else load(lif); s=s(1:svd_size); b=b(:,1:svd_size); end; save(outfile, 's', 'b'); exit;"

######################################################################
## INPUT PREPARATION CODE 
# Currently all the data files are as follows.
# $STORE2/fnppdb_cooccurence_xl.mat
# $STORE2/morphology_cooccurence_inflection.mat
# $STORE2/polyglotwiki_cooccurence_1 to 15.mat
# $STORE2/agigastandep_cooccurence_$(STANDEP_LIST).mat
# $STORE2/mikolov_cooccurence_intersect.mat
# $STORE2/bitext_cooccurence_$(BIG_LANG).mat
VOCABWITHCOUNT_500K_FILE := $(STORE)/polyglot_wikitxt/en/full.txt.vc5.500K
VOCAB_500K_FILE := $(VOCABWITHCOUNT_500K_FILE)_word
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
make_all_cooccurences: ## $(STORE2)/freebase_cooccurence_%.mat
	$(MAKE) run_agigastandep_mat_on_grid   morphogrid fnppdbgrid polygrid 
#########################################
#### FRAMENET/PPDB COOCCURENCE EXTRACTOR
fnppdbgrid:
	$(QSUBMAKE) run_fnppdb_on_grid
run_fnppdb_on_grid:
	for db in l xl ; do $(MAKE)  $(STORE2)/fnppdb_cooccurence_"$db".mat ; done
# This also creates $(STORE2)/wordnet_cooccurence_%.mat
# That is a bit misleading since there is no l or xl in wordnet.
$(STORE2)/fnppdb_cooccurence_%.mat: $(VOCAB_500K_FILE) /home/prastog3/projects/paraphrase_framenet/fn15-frameindexLU-% 
	python src/create_fnppdb_cooccurence.py $+ $@

######################################
#### MORPHOLOGY COOCCURENCE EXTRACTOR
morphogrid:
	$(QSUBMAKE) $(STORE2)/morphology_cooccurence_inflection.mat

$(STORE2)/morphology_cooccurence_inflection.mat: $(VOCAB_500K_FILE) $(STORE)/catvar21.txt
	PYTHONPATH=$$PYTHONPATH:~/projects/rephit python src/create_morphological_cooccurence.py $+ $@ 2> $@.log && matlab -r "load $@; align_mat=align_mat(:,sum(align_mat)>1); save('$@', 'align_mat');"

#################################
#### WIKIPEDIA POLYGLOT EXTRACTOR
# The actual final command ran was the following
polygrid: # your job 8494220
	qsub -V -j y -l mem_free=50G -l hostname=a15 -r yes -cwd submit_grid_stub.sh run_polyglot_on_grid
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
polyglotwiki_cooccurence_generic: # the full text file has 75241648 lines 
	time python src/count_cooccurence.py $(VOCAB) $(TEXT) $(WINDOW_SIZE) $(TARGET).h5 $(BOS_TO_MAINTAIN) $(MIN_LENGTH_SENTENCE) && $(MATCMD)"$(call H5_TO_MAT_MAKER,$(TARGET))"

##############################
### AGIGA PROCESSING CODE
AGIGADIR := /export/corpora5/LDC/LDC2012T21
AGIGATOOLDIR := $(AGIGADIR)/tools/agiga_1.0
STANDEP_LIST_PART1 := pobj
STANDEP_LIST_PART2 := nsubj,amod,advmod,rcmod,dobj,prep_of,prep_in,prep_to,prep_on,prep_for,prep_with,prep_from,prep_at,prep_by,prep_as,prep_between,xsubj,agent,conj_and,conj_but
STANDEP_LIST := $(STANDEP_LIST_PART1),$(STANDEP_LIST_PART2)
STANDEP_LIST_PREPROCOPT := +nsubj.pass,-pobj,$(STANDEP_LIST_PART2)
# TARGET: This creates 21 mat files. One per relation type by gatherings counts from all the files.
# SOURCE: All the files in the $STORE2/agigastandep directory and the 21 relation types.
#         and a mapping of those relations to indices
run_agigastandep_mat_on_grid: # The jobs are 8591191-211
	for r in $(subst $(COMMA), ,$(STANDEP_LIST)); do qsub -V -j y -l mem_free=30G -l hostname=a14  -cwd submit_grid_stub.sh $(STORE2)/agigastandep_cooccurence_"$$r".mat; done
$(STORE2)/agigastandep_cooccurence_%.mat:  $(VOCAB_500K_FILE) # $(STORE2)/agigastandep
	time python src/agigastandep_cooccurence_h5.py $* $(STANDEP_LIST) $(STORE2)/agigastandep $<  $@.h5 && $(MATCMD)"$(call H5_TO_MAT_MAKER,$@)"
# TARGET: This just cleans up on a botched attempt.
clean_agigastandep:
	rm -rf $(STORE2)/agigastandep && mkdir $(STORE2)/agigastandep
# TARGET: This runs $(AGIGA)/standep on the grid.
# check that $STORE2/agigastandep has 1007 files once this finishes
run_agigastandep_directory_on_grid: # your job 8494207
	qsub -V -j y -l mem_free=30G -l hostname=a14  -cwd submit_grid_stub.sh $(STORE2)/agigastandep
# TARGET: This creates a directory which contains the dependency
# cooccurence counts for the list of relations specified in STANDEP_LIST
# and this uses the child _xargs target.
# SOURCE: It takes the vocabulary file and the Agiga data directory 
# $(STORE2)/agigastandep: $(VOCAB_500K_FILE) $(AGIGADIR)/data/xml
# 	find $(word 2,$+) -name [clnwx]*.xml.gz | xargs -I % -P 2 $(MAKE) AGIGATOOLDIR=$(AGIGATOOLDIR) INPUT_FILE=% STANDEP_LIST=$(STANDEP_LIST) STANDEP_LIST_PREPROCOPT=$(STANDEP_LIST_PREPROCOPT) OUTPUT_DIR=$@ VOCAB_FILE=$< agigastandep_xargs
agigastandep_xargs:
	time java -cp "$(AGIGATOOLDIR)/build/agiga-1.0.jar:$(AGIGATOOLDIR)/lib/*" edu.jhu.agiga.AgigaPrinter stanford-deps $(INPUT_FILE) | pypy src/agigastandep_cooccurence_preproc.py $(VOCAB_FILE) $(STANDEP_LIST_PREPROCOPT) $(STANDEP_LIST)  $(OUTPUT_DIR)/$(notdir $(INPUT_FILE))

###########################################
## BITEXT PROCESSING CODE
gridrun_align_mat: # 8591368 to 72
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

############################################
## GLOVE PROCESSING CODE
# TARGET: A mat file with three variables 'emb' 'word' 'id'
# SOURCE: This takes 3 files as input.
# 	  1. A word file which provides the word to index mapping that must be followed while converting 
$(STORE2)/glove.%B.300d.mat: $(STORE2)/glove.%B.300d.txt_word $(STORE2)/glove.%B.300d.txt
	$(MATCMD)"tic; word=textread('$(word 1,$+)', '%s'); emb=dlmread('$(word 2,$+)', '', 0, 1); id='glove$*'; save('$@', 'emb', 'id', 'word', '-v7.3'); toc; exit;"

##################################
## FREEBASE COCCURENCE EXTRACTOR
# $(STORE2)/freebase_cooccurence_%.mat: # This data is being prepared in the COE grid.
# 	scp prastogi@external.hltcoe.jhu.edu:~/freebase_cooccurence_$*.mat $@

###############################
#### FLICKR PREPARATION 
# # qsub -V -j y -l mem_free=25G -r yes  -cwd submit_grid_stub.sh $STORE/flickr30k_PHOW_features.mat
# # Your job 8421424
# $(STORE2)/flickr30k_cooccurence_%.mat:
# FLICKR30KDIR := /export/a15/prastog3/flickr30k/flickr30k-images
# $(STORE)/flickr30k_PHOW_features.mat: $(FLICKR30KDIR)
# 	$(MATCMD)"input_dir='$<'; outputFile='$@'; [hists, image_path]=flickr30k_feature_extractor(input_dir, outputFile); save(outputFile, 'hists', 'image_path'); exit;"
# res/test_set.vocabulary: res/

###########################################
##### BITEXTENGLISH PROCESSING CODE
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
##### VOCABULARY CREATION CODE
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
