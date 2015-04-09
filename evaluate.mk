include commonheader.mk
##################################
## PAPER MAKING CODE (TABULATION)
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
	$(MATCMD)"tic; word=textread('$(VOCAB_FILE)', '%s', 'headerlines', $(ROW_SKIP)); emb=dlmread('$(EMB_FILE)', '', $(ROW_SKIP), $(COL_SKIP)); if size(emb,2)==600 emb=(emb(:,1:300)+emb(:,301:600))/2; end; emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, '$(MYTAG)', word, 1); toc; exit;" | tee $(TARGET)

COMBINED_EMB_JOBNAME_MAKER = combined_embedding_$*_trunccol125000_16
log/combined_embedding_%: $(STORE2)/combined_embedding_%.mat
	sleep 3 && qsub -N log_combined_embedding_$* -hold_jid $(COMBINED_EMB_JOBNAME_MAKER) -V -l mem_free=5G,ram_free=1G,hostname="a*" -r yes -pe smp 1 -cwd submit_grid_stub.sh TARGET=$@ MYDEP=$< MYTAG='combined' log_combined_embedding_generic

log_combined_embedding_generic:
	$(MATCMD)"tic; load('$(MYDEP)'); emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, '$(MYTAG)', word, 1); toc; exit;" | tee $(TARGET)

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
ts_%: log/%
	$(TAB_SPEARMAN) $(TABCMD) | python src/rearrange_tabs.py MEN RW SCWS SIMLEX  EN_WS_353_ALL EN_MTURK_287 EN_WS_353_REL EN_WS_353_SIM EN_RG_65 EN_MC_30 EN_TOM_ICLR13_SYN EN_TOM_ICLR13_SEM TOEFL | awk '{printf "%0.1f %s\n", 100*$$NF, $$2}'
vts_%: log/%
	$(TAB_SPEARMAN) $(TABCMD) | python src/rearrange_tabs.py MEN RW SCWS SIMLEX  EN_WS_353_ALL EN_MTURK_287 EN_WS_353_REL EN_WS_353_SIM EN_RG_65 EN_MC_30 EN_TOM_ICLR13_SYN EN_TOM_ICLR13_SEM TOEFL
tp_%: log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMD1)
#################################
### THE CRUX OF THE EVAL CODE.
# TARGET: Call tabulate when you want results over
tbspearman_%: log/%
	$(TAB_SPEARMAN) $(TABCMD) $(TABCMDA) $*
tbpearson_%: log/%
	$(TAB_PEARSON) $(TABCMD) $(TABCMDA) $*

# TARGET: A log of the evaluation.
log/fullgcca_extrinsic_test_%: $(VOCAB_500K_FILE)
	@mkdir log; \
	$(MAKE) -f evaluate.mk \
	  TARGET=$@ \
	  EMB_FILE=$(EMB_FOLDER)/$*.mat \
	  VOCAB=$(VOCAB_500K_FILE) \
	  DO_ANALOGY_TEST=$(DO_ANALOGY_TEST) \
	  VERBOSE=$(VERBOSE) \
	eval_generic

eval_generic:
	$(MATCMD)"addpath('src/evaluate');""word=textread('$(VOCAB_500K_FILE)', '%s'); load('$(EMB_FILE)'); if exist('sort_idx') word=word(sort_idx); end; if ~exist('G') G=emb; end; if size(G, 1) < size(G, 2); G=G'; end; G = normalize_embedding(G); do_analogy_test=$(DO_ANALOGY_TEST); verbose=$(VERBOSE); conduct_extrinsic_test_impl(G, 'G', word, do_analogy_test, '$(EVALFILE_FOLDER)/', verbose); exit;"  | tee $(TARGET)

# SIMPLIFIED EVALUATION FILE CREATION CODE
$(RESPATH)/simlex_simplified.txt:
	awk '{if( NR > 1){print $$1, $$2, $$4}}' $(RESPATH)/SimLex-999.txt  > $@

# TARGET: A simplified output file which contains a word pairs and a
# single number representing a score of how similar the two words are
# according to judgments by mechanical turkers or linguistics undergrads.
$(RESPATH)/rw_simplified.txt: $(RESPATH)/rw.txt
	awk '{print $$1, $$2, $$3}' $+ > $@

$(RESPATH)/scws_simplified.txt: $(RESPATH)/scws.txt
	awk -F $$'\t' '{print $$2, $$4, $$8}' $+ > $@
