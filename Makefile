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
QSUB1 := qsub
QSUB2 := -V -j y -l mem_free=30G,ram_free=30G,h_vmem=30G -r yes #-verify
QSUBCMD := $(QSUB1) $(QSUB2) 
QSUBP1CMD := $(QSUB1) -p -1 $(QSUB2)
CWD_SUBMIT := -cwd submit_grid_stub.sh 
QSUBMAKE := $(QSUBCMD) $(CWD_SUBMIT)
QSUBP1MAKE := $(QSUBP1CMD) $(CWD_SUBMIT)
QSUBPEMAKE := $(QSUBCMD) -pe smp 10 $(CWD_SUBMIT)
QSUBP1PEMAKE := $(QSUBP1CMD) -pe smp 10 $(CWD_SUBMIT)
QSUBPEMAKEHOLD = qsub -N $1 -V -hold_jid $2 -l mem_free=$3,ram_free=$3,h_vmem=$3 -r yes -pe smp $4 -cwd submit_grid_stub.sh

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

# TODO
# 1.[-] Compile the results of the jobs in FANGLE. (Write up your paper !! on monday !!)
# 2.[X] Backup the important files onto COE 
# 3.[-] Add code to compute the projection operator and a dictionary to create the feature vector at test time.
# 4.[-] Add Code to compute projections of OOV on the fly.
# 3.[-] Add Microsoft sentence completion test.
# 5. Write code to discriminatively train the embeddings
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
	for pc in \
	stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de@es@fr@zh \
	stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de@es@fr \
	stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de@es \
	stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs@de \
	stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar@cs \
	stgccano@bvgn@monotext1@monotext2@monotext4@monotext6@monotext8@monotext12@monotext14@ar ;\
	do echo pc=$$pc && \
	     make -s tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_100~"$$pc",300_1e-5,monomultiwindow.300; \
	done

####################
###### OTHER TEST
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
	qsub -V -j y -l mem_free=40G,ram_free=40G,h_vmem=40G -r yes  -pe smp 10 -cwd submit_grid_stub.sh $(STORE2)/glove_embedding_file && qsub -V -j y -l mem_free=20G,ram_free=20G,h_vmem=20G -r yes -pe smp 20 -cwd submit_grid_stub.sh $(STORE2)/word2vec_embedding_file
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

##############################
####  TABULATION CODE
TABCMD = cat $$F | sed "s%original embedding%O%g" | sed "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" | sed "s%The TOEFL score over \([0-9A-Za-z_-]*\) with bare \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The TOEFL $$corrtype score over \1 (\3 out of \2) is \5%g" | sed "s%The $$corrtype Corr over \([0-9A-Za-z_-]*\) is%The JURI $$corrtype correlation over \1 (0 out of 0) is%g" | grep -E "The .* $$corrtype"  | 
TAB_SPEARMAN = export F=log/$* && export corrtype=Spearman &&
TAB_PEARSON = export F=log/$* && export corrtype=Pearson && 
TABCMD1 = grep "over G" #| awk '{printf "%s\n", $$NF}'
TABCMDA = awk '{printf "%s %s out of %s \t %s \t %s\n", $$2, $$7, $$10, $$6, $$NF}' | python src/tabulation_script.py
# TARGET: Call tab_Spearman when you want results only over G
tab_Spearman_%: #log/%
	$(TAB_SPEARMAN) $(TABCMD) $(TABCMD1)
tab_Pearson_%: #log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMD1)
# TARGET: Call tabulate when you want results over 
tabulate_Spearman_%: #log/%
	$(TAB_SPEARMAN) $(TABCMD) $(TABCMDA) $*
tabulate_Pearson_%: #log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMDA) $*

##############################
#### PAPER FANGING CODE
# TARGET: TABBING_IT_n (OR) TABBING_IT_s
# n is for checking
# s is for doing
TABBING_IT_%:
	for m in 500; do \
	    echo $$m; make -$* tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_"$$m"~E@mi,300_1e-5_25.300.1.1; done ;\
	for dset in "" @mo @fn @mo@fn @mo@fn@bi @po ; do \
	   echo $$dset; make -$* tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_300~E@mi"$$dset",300_1e-5_25.300.1.1; done ;\
	for dset in @mo@fn@ag @mo@fn@ag@bi  @bi@po @ag@po ; do \
	   echo $$dset; make -$* tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_300~E@mi"$$dset",300_1e-5_100000.300.1.1; done; \
	for thresh in 21 23 25 27 29 ; do \
	    echo $$thresh; make -$* tab_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_CountPow025-trunccol100000_300~E@mi,300_1e-5_"$$thresh".300.1.1; done; 

DATASET_FANG: 
	for dset in @mo@fn @mo@fn@bi @po ; do \
	   make $(STORE2)/v5_embedding_mc_CountPow025-trunccol100000_300~E@mi"$$dset",300_1e-5_25.mat; done
# @ag@bi@po can't be done because the method becomes unstable
DATASET2_FANG: 
	for dset in @mo@fn@ag @mo@fn@ag@bi  @bi@po @ag@po ; do \
	   make -n $(STORE2)/v5_embedding_mc_CountPow025-trunccol100000_300~E@mi"$$dset",300_1e-5_100000.mat; done
VIEW_THRESHOLD_FANG: 
	for thresh in 21 23 25 27 29 ; do \
	    make -n $(STORE2)/v5_embedding_mc_CountPow025-trunccol100000_300~E@mi,300_1e-5_"$$thresh"; done
# Note that there are 114,428 words in the vocabulary here.
# Also note that the mat file target was
# $STORE2/v5_embedding_mc_CountPow025-trunccol100000_"500"~E@mi,300_1e-5_25.mat
BIG_FANG: 
	for m in 500; do make $(STORE2)/v5_embedding_mc_CountPow025-trunccol100000_"$$m"~E@mi,300_1e-5_25.300.1.1; done

#########################
#### EVAL CODE
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
# SOURCE: $STORE2/v5_embedding_%.mat
GET_LOG_OPT = $(word $1,$(subst ., ,$*))
V5_EMB_JOBNAME_MAKER = tmp_embqsub_$(subst $(COMMA),,$(subst @,_at_,$*))
log/fullgcca_extrinsic_test_%:
	$(MAKE) JOB_NAME=$(subst $(COMMA),,$(subst @,_at_,tmp_$(@F))) \
		JID_HOLD=$(subst v5_embedding_,,$(word 1,$(subst ., ,$(V5_EMB_JOBNAME_MAKER)))) \
		MEMORY=5G \
		PE=2 \
		TARGET=$@ \
		MYDEP=$(STORE2)/$(call GET_LOG_OPT,1).mat \
		DIM_AFTER_CCA=$(call GET_LOG_OPT,2) \
		DOMIKOLOV=$(call GET_LOG_OPT,3) \
		DO_ONLY_G=$(call GET_LOG_OPT,4) \
	gcca_extrinsic_test_gen1

gcca_extrinsic_test_gen1: $(MYDEP)
	$(call QSUBPEMAKEHOLD,$(JOB_NAME),$(JID_HOLD),$(MEMORY),$(PE)) \
		TARGET=$(TARGET) \
		MYDEP=$(MYDEP) \
		DIM_AFTER_CCA=$(DIM_AFTER_CCA) \
		DOMIKOLOV=$(DOMIKOLOV) \
		DO_ONLY_G=$(DO_ONLY_G) \
	gcca_extrinsic_test_generic #&& sleep 10

gcca_extrinsic_test_generic:  
	$(MATCMDENV)"word=textread('$(VOCAB_500K_FILE)', '%s'); load('$(MYDEP)'); if size(G, 1) < size(G, 2); G=G'; end; word=word(sort_idx); bvgn_emb=nan; bitext_true_extrinsic_test(G, bvgn_emb, $(DIM_AFTER_CCA), word, $(DOMIKOLOV), $(DO_ONLY_G)); exit;" | tee $(TARGET)

MSRMATCMD = time matlab -nodisplay -r "addpath('src'); setenv('MSR_QUESTIONS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.questions.txt'); setenv('MSR_ANSWERS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.answers.txt');"
# % can be mc_CountPow025-trunccol100000_500~E@mi,300_1e-5_25
gcca_msr_test_%: $(STORE2)/v5_embedding_%.mat
	$(MSRMATCMD)"big_word_list=textread('$(VOCAB_500K_FILE)', '%s'); embedding_file='$<'; load(embedding_file, 'G', 'sort_idx'); msrd=get_msr_data(); G=normalize_embedding(G); big_word_map=containers.Map(big_word_list, 1:length(big_word_list)); small_word_map=containers.Map(big_word_list(sort_idx), 1:sum(sort_idx)); UJ={}; CPL={}; for k=1:15 pj_mat_file=matfile(['$(STORE2)/projection_polyglotwiki_cooccurence_' num2str(k) '.' embedding_file(length('$(STORE2)/v5_embedding_')+1:end)]); UJ{k}=sparse(pj_mat_file.uj); CPL{k}=pj_mat_file.column_picked_logical; end; gcca_msr_test(big_word_list, big_word_map, small_word_map, G, sort_idx, msrd, UJ, CPL); exit;" | tee $@
# TARGET:
# for m in 300 500; do for h in {1..15}; do make \
# $STORE2/projection_polyglotwiki_cooccurence_"$h".mc_CountPow025-trunccol100000_"$m"~E@mi,300_1e-5_25.mat; done; done
# bj*inv(sj'*sj+rI)*bj'*bj*sj'*aj'*G
# Experiment with this at 7:45 AM.
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
		V56_GENERIC_DEP="`python src/calculate_dependency.py $* $(STANDEP_LIST) $(subst $(SPACE),$(COMMA),$(BIG_LANG)) $(STORE2)`" \
		HOLD_JID="`python src/calculate_dependency.py $* $(STANDEP_LIST) $(subst $(SPACE),$(COMMA),$(BIG_LANG)) $(STORE2)  | sed s%$(STORE2)/v5_indisvd%tmp%g | sed 's%.mat %,%g' | rev | cut -c 2- | rev `" v5_generic_qsub 

v5_generic_qsub: $(V56_GENERIC_DEP)
	echo $(V56_GENERIC_DEP) > $(DEP_FILE_NAME) && \
	   $(call QSUBPEMAKEHOLD,$(JOB_NAME),$(HOLD_JID),40G,5) \
		TARGET=$(TARGET) \
		DEP_FILE_NAME=$(DEP_FILE_NAME) \
		GCCA_OPT=$(GCCA_OPT) \
	    v5_generic # && sleep 10

v5_generic: $(V56_GENERIC_DEP)
	 $(MATCMD)"options=strsplit('$(GCCA_OPT)', '_'); embedding_size=str2num(options{1}); reg_unused_=options{2}; min_view_to_accept_word=str2num(options{3}); deptoload=textscan(fopen('$(DEP_FILE_NAME)'), '%s'); deptoload=deptoload{1}; [G, S_tilde, sort_idx]=v5_generic(embedding_size, deptoload, min_view_to_accept_word); save('$(TARGET)', 'G', 'S_tilde', 'sort_idx'); exit;"

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
	qsub -N tmp_$* -p -1 -V -j y -l mem_free=$(V5_INDISVD_MEM),ram_free=$(V5_INDISVD_MEM),h_vmem=$(V5_INDISVD_MEM) -r yes -pe smp 5 -cwd submit_grid_stub.sh $(STORE2)/v5_indisvd_"$*".impl #&&  sleep 3

V5_INDISVD_CMD1 = "options=strsplit('$*', '~'); f2load=['$(STORE2)/' options{1} '.mat']; load(f2load); assert(exist('align_mat')==1); mc_muc=options{2}; if strcmp(f2load, '$(STORE2)/mikolov_cooccurence_intersect.mat') preprocess_option='Count'; else preprocess_option=options{3}; end; svd_size=str2num(options{4}); r=str2num(options{5}); outfile='$(word 1,$(subst ., ,$@)).mat';"
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
	for r in $(subst $(COMMA), ,$(STANDEP_LIST)); do qsub -V -j y -l mem_free=30G,ram_free=30G,h_vmem=30G -l hostname=a14  -cwd submit_grid_stub.sh $(STORE2)/agigastandep_cooccurence_"$$r".mat; done
$(STORE2)/agigastandep_cooccurence_%.mat:  $(VOCAB_500K_FILE) # $(STORE2)/agigastandep
	time python src/agigastandep_cooccurence_h5.py $* $(STANDEP_LIST) $(STORE2)/agigastandep $<  $@.h5 && $(MATCMD)"$(call H5_TO_MAT_MAKER,$@)"
# TARGET: This just cleans up on a botched attempt.
clean_agigastandep:
	rm -rf $(STORE2)/agigastandep && mkdir $(STORE2)/agigastandep
# TARGET: This runs $(AGIGA)/standep on the grid.
# check that $STORE2/agigastandep has 1007 files once this finishes
run_agigastandep_directory_on_grid: # your job 8494207
	qsub -V -j y -l mem_free=30G,ram_free=30G,h_vmem=30G -l hostname=a14  -cwd submit_grid_stub.sh $(STORE2)/agigastandep
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
# # qsub -V -j y -l mem_free=25G,ram_free=25G,h_vmem=25G -r yes  -cwd submit_grid_stub.sh $STORE/flickr30k_PHOW_features.mat
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
