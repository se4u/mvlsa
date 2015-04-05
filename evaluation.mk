## MOTIVATION
# 1) Scalability (Code first, basically given any number of views
#    first store their symmetric svds, then perform pca on the symmetric svds)
# 2) Task specific representation learning through feedback guided weights (once
#    representation learning becomes online, then all we need to do is
#    train representations, the representations can be
# 3) Which contexts give a boost (this is part of analysis)
#    Basically I code PMI, PPMI, Glove's Data dependent preprocessing as
#    different views and then find which views get a high weight.
#    i should decide the exact weighting strategy to use. Setting
#    x-max really benefits the Semantic dataset however I can do a lot
#    better in terms of weighting by carefully either
#    either premultiply or postmultiply and then get basically a factored
#    weighting.
# 4) Application : PPDB ?
# 5) Finally do humans really break the performance intro matrices of
#    statistics that are called views ?
# 6) Tension between thresholding for noise removal and "missing value imputation for svd"
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
qsub_glove:
	for SYMASYM in 0.1 1.100 ; do \
	  $(call QSUBPEMAKEHOLD4,glove_"$$SYMASYM"_mytrain,a1[1238]*,10G,1) $(STORE2)/glove_"$$SYMASYM"_mytrain.bin; sleep 5; \
	  $(call QSUBPEMAKEHOLD5,submit_grid_stub.sh.glove_"$$SYMASYM"_mytrain,a*,1G,glove_"$$SYMASYM"_mytrain) log/extrinsic_glove_"$$SYMASYM"_mytrain_mycode; done

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

# log/extrinsic_word2vec_mytrain_theircode: $(STORE2)/word2vec_mytrain.bin $(RESPATH)/EN-TOM-ICLR13-SEM.txt_lowercase $(RESPATH)/EN-TOM-ICLR13-SYN.txt_lowercase
# 	$(EXTRINSIC_TEST_WORD2VEC_THEIRCODE_CMD)

log/extrinsic_word2vec_theirtrain_theircode: $(STORE)/word2vec_theirtrain.bin $(RESPATH)/EN-TOM-ICLR13-SEM.txt_lowercase $(RESPATH)/EN-TOM-ICLR13-SYN.txt_lowercase
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
TABCMD = cat $$F | sed "s%original embedding%O%g" | sed -e "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_.-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\), [0-9]*\] is \([0-9.]*\), \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" -e "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" -e "s%The TOEFL score over \([0-9A-Za-z_-]*\) with bare \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The TOEFL $$corrtype score over \1 (\3 out of \2) is \5%g" -e "s%The $$corrtype Corr over \([0-9A-Za-z_-]*\) is%The JURI $$corrtype correlation over \1 (0 out of 0) is%g" | grep -E "The .* $$corrtype"
TAB_SPEARMAN = export F=log/$* && export corrtype=Spearman &&
TAB_PEARSON = export F=log/$* && export corrtype=Pearson &&
TABCMD1 =  | grep "over G" | awk '{printf "%s\n", $$NF}'
TABCMDA =  | awk '{printf "%s %s out of %s \t %s \t %s\n", $$2, $$7, $$10, $$6, $$NF}' | python src/tabulation_script.py
# TARGET: Call tab_Spearman when you want results only over G
ts_%: #log/%
	$(TAB_SPEARMAN) $(TABCMD) | python src/rearrange_tabs.py MEN RW SCWS SIMLEX  EN_WS_353_ALL EN_MTURK_287 EN_WS_353_REL EN_WS_353_SIM EN_RG_65 EN_MC_30 EN_TOM_ICLR13_SYN EN_TOM_ICLR13_SEM TOEFL | awk '{printf "%0.1f %s\n", 100*$$NF, $$2}'
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

# 3. Use log(Count) Preprocessing with the best settings to find out
#    the performance.
check_log_perf: log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-trunccol12500_500~E@mi@bi@ag@fn@mo,300_1e-5_170000.300.1.1

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

###########################################
## SIMPLIFIED EVALUATION FILE CREATION CODE
$(RESPATH)/simlex_simplified.txt:
	awk '{if( NR > 1){print $$1, $$2, $$4}}' $(RESPATH)/SimLex-999.txt  > $@
# TARGET: The simplified outputs
# SOURCE: These are rare word and contextual word similarity datasets which need to simplified
$(RESPATH)/rw_simplified.txt: $(RESPATH)/rw.txt
	awk '{print $$1, $$2, $$3}' $+ > $@
$(RESPATH)/scws_simplified.txt: $(RESPATH)/scws.txt
	awk -F $$'\t' '{print $$2, $$4, $$8}' $+ > $@

#############################################
## VOCABULARY CREATION CODE
PPDB_VOCAB_FILE := $(STORE2)/VOCAB/ppdb.vocab
PPDB_VOCAB_CLEAN := $(STORE2)/VOCAB/ppdb.vocab.clean
REMOVE_NON_ASCII_CMD := perl -nle 'print if m{^[[:ascii:]]+$$}'
$(PPDB_VOCAB_CLEAN): $(PPDB_VOCAB_FILE)
	cat $<  | $(REMOVE_NON_ASCII_CMD) | egrep -v '[^a-zA-Z.,;:-?! ]'  | sed 's#[0-9]#0#g' | egrep -v  '^(a|an|the) ' | egrep -v  ' (and) ' > $@
PHRASAL_VOCAB := $(STORE2)/VOCAB/phrasal_vocab
VOCAB_DIR := $(STORE2)/VOCAB
VOCABWITHCOUNT_1M_FILE := $(VOCAB_DIR)/full.txt.vc5.1M
TOKEN_VOCAB := $(VOCAB_DIR)/full.txt.vocabcount5.lower
$(PHRASAL_VOCAB): $(TOKEN_VOCAB) $(PPDB_VOCAB_CLEAN)
	awk '{print $$1}' $< > $@ && \
	python src/preprocessing_code/filter_ellie_vocab.py $+   >> $@
VOCAB_POLYGLOT_CMD = head -n $*000 $< > $@
$(VOCAB_DIR)/full.txt.vc10.%K: $(VOCAB_DIR)/full.txt.vc10.1M
	$(VOCAB_POLYGLOT_CMD)
$(VOCAB_DIR)/full.txt.vc5.%K: $(VOCABWITHCOUNT_1M_FILE)
	$(VOCAB_POLYGLOT_CMD)
$(VOCAB_DIR)/full.txt.vc%.1M: $(VOCAB_DIR)/full.txt.vocabcount%.lower
	cat $< | $(REMOVE_NON_ASCII_CMD) |  head -n 1000000  > $@
$(VOCAB_DIR)/full.txt.vocabcount%.lower: $(STORE)/polyglot_wikitxt/en/full.txt src/count/vocab_count
	time $(word 2,$+) -min-count $* -verbose 0 -lowercase 1 -replacerandomnumber 1 < $<  > $@
src/count/vocab_count: src/count/vocab_count.c src/count/commoncore.h
	gcc -lm -pthread -O9 -march=native -funroll-loops -Wno-unused-result $< -o $@
