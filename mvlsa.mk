include commonheader.mk
## Functions for extracting options from file names
# GCCA_OPT_EXTRACTOR first breaks by tilde, picks 2nd word, then
# breaks by comma and picks 2nd word
GCCA_OPT_EXTRACTOR = $(word 2,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))

# M_OPT_EXTRACTOR first breaks by tilde, picks first, then breaks by
# underscore and picks 3rd
M_OPT_EXTRACTOR = $(word 3,$(subst _, ,$(word 1,$(subst ~, ,$*))))

# DEPGROUP_EXTRACTOR first breaks by tilde, picks 2nd word, then
# breaks by comma and picks 1st word
DEPGROUP_EXTRACTOR = $(word 1,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
#######################################
## GCCA Running Code
# TARGET: The typical target is: v5_embedding_mc_CountPow025-trunccol12500_500~E@mi,300_1e-5_16.mat
# The filename is constructed  by joing 3 parts
# 1. The options given to the underlying SVD (the dataset name is determined in separate script)
# 	a. mc or muc
# 	b. preprocessing
# 	c. number of svd dimensions
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
# 3. GCCA_OPT
#	a. The first is the dimension of the embedding
#	b. The second is regularization
#	c. The third is the number of datasets in which a word must
#          appear before it will be allowed.
QSUB_OR_MAKE := qsub # {make, qsub}
$(EMB_FOLDER)/v5_embedding_%.mat:
	$(MAKE) -f mvlsa.mk \
	  TARGET=$@ \
	  GCCA_OPT=$(GCCA_OPT_EXTRACTOR) \
	  M="$(M_OPT_EXTRACTOR)" \
	  INPUT_FILENAMES=$(PROCESS_COUNT_FILENAMES) \
	  DEPGROUP_TO_PICK=$(DEPGROUP_EXTRACTOR) \
	  v5_generic_$(QSUB_OR_MAKE)

V5_GENERIC_CMD = TARGET=$(TARGET) \
	  GCCA_OPT=$(GCCA_OPT) \
	  M=$(M) \
	  INPUT_FILENAMES=$(INPUT_FILENAMES) \
	  DEPGROUP_TO_PICK=$(DEPGROUP_TO_PICK) \
	  v5_generic

v5_generic_make:
	$(MAKE) -f mvlsa.mk $(V5_GENERIC_CMD)

v5_generic_qsub:
	qsub -V -l mem_free=10G,hostname='a14*' -r yes -cwd submit_grid_stub.sh  -f mvlsa.mk \
	$(V5_GENERIC_CMD)

v5_generic:
	 $(MATCMD)"addpath('src/mvlsa');""gcca_opt=strsplit('$(GCCA_OPT)', '_'); embedding_size=str2num(gcca_opt{1}); reg__unimportant__=gcca_opt{2}; min_view_to_accept_word=str2num(gcca_opt{3}); M=$(M); input_filenames=textscan(fopen('$(INPUT_FILENAMES)'), '%s'); input_filenames=input_filenames{1}; deptoload=filter_input_filenames(input_filenames, '$(DEPGROUP_TO_PICK)'); [G, S_tilde, sort_idx]=mvlsa_incremental_svd(embedding_size, deptoload, min_view_to_accept_word, M); save('$(TARGET)', 'G', 'S_tilde', 'sort_idx', '-v7.3'); disp(getReport(MException.lasterror)); exit;"
