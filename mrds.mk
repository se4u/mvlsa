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
