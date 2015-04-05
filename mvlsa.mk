########################################
## PROJECTION CREATION CODE
# This target was made for the Microsoft Sentence Completion task
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
		V56_GENERIC_DEP="`python $(CALCULATE_DEPENDENCY_CODE) $* $(STANDEP_LIST) $(subst $(SPACE),$(COMMA),$(BIG_LANG)) $(STORE2)`" \
		HOLD_JID="`python $(CALCULATE_DEPENDENCY_CODE) $* $(STANDEP_LIST) $(subst $(SPACE),$(COMMA),$(BIG_LANG)) $(STORE2)  | sed s%$(STORE2)/v5_indisvd%tmp%g | sed 's%.mat %,%g' | rev | cut -c 2- | rev `" v5_generic_qsub

v5_generic_qsub: $(V56_GENERIC_DEP)
	echo $(V56_GENERIC_DEP) > $(DEP_FILE_NAME) && \
	sleep 3 &&  \
	  $(call QSUBPEMAKEHOLD3,$(JOB_NAME),$(HOLD_JID),57G,60G,1) \
		TARGET=$(TARGET) \
		DEP_FILE_NAME=$(DEP_FILE_NAME) \
		GCCA_OPT=$(GCCA_OPT) \
		M=$(M) \
	    v5_generic

v5_generic: $(V56_GENERIC_DEP)
	 $(MATCMD)"options=strsplit('$(GCCA_OPT)', '_'); embedding_size=str2num(options{1}); reg_unused_=options{2}; min_view_to_accept_word=str2num(options{3}); M=$(M); deptoload=textscan(fopen('$(DEP_FILE_NAME)'), '%s'); deptoload=deptoload{1}; [G, S_tilde, sort_idx]=v5_generic_tmp(embedding_size, deptoload, min_view_to_accept_word, M); save('$(TARGET)', 'G', 'S_tilde', 'sort_idx', '-v7.3'); disp(getReport(MException.lasterror)); exit;"
