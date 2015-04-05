include commonheader.mk
OPERATION := process_count
############################################################################
## SVD RUNNING CODE (OVER EXTRACTED COUNTS STORED IN SPARSE MATLAB MATRICES)
# TARGET: v5_indisvd_fnppdb_cooccurence_xl~mc~CountPow025-truncatele200~100~1e-5.mat
# The options are delimited by ~ and the options are
# 1. The name of mat file containing the sparse matrix
# 2. The name of the preprocessing option,
#    In case the option is mc: Then we compute svd of the processed counts
#    Otherwise we don't compute svd and just store the sparse matrices.
# 3. The preprocessing options (CountPow050-trunccol100000)
# 4. The number of left SVD vectors (100 or 300)
# 5. The regularization value (1e-5)
# TARGET: If you call the impl then you run on the machine, otherwise
#    you qsub the job. This is done because I want to depend on the mat
#    files by name and qsub the dependency by default. I put a wait loop
#    on these jobs so that their parents dont start running till the qsub
#    jobs are complete.
$(PROCESS_COUNT_FOLDER)/v5_indisvd_%.mat:
	qsub -N tmp_$* -p -1 -V -j y -l mem_free=20G,'hostname=a*' -pe smp 5 -r yes -cwd submit_grid_stub.sh -f $(OPERATION).mk DEPENDENCY=$(EXTRACT_COUNT_FOLDER)/$(call OPT_EXTRACTOR_tilde,1).mat $(@D)/v5_indisvd_"$*".impl

$(PROCESS_COUNT_FOLDER)/v5_indisvd_%.impl: $(DEPENDENCY)
	$(MATCMD)"addpath('src/$(OPERATION)'); options=strsplit('$*', '~'); f2load=['$(DEPENDENCY)']; load(f2load); assert(exist('align_mat')==1); mc_muc=options{2}; if strcmp(f2load, '$(EXTRACT_COUNT_FOLDER)/mikolov_cooccurence_intersect.mat') preprocess_option='Count'; else preprocess_option=options{3}; end; svd_size=str2num(options{4}); r=str2num(options{5}); outfile='$(word 1,$(subst ., ,$@)).mat';""[ajtj, kj_diag, aj, sj, column_picked_logical, bj, mu1, mu2, sum2]=v5_indisvd_level2(align_mat, mc_muc, preprocess_option, svd_size, r, outfile); save(outfile, 'ajtj', 'kj_diag', 'aj', 'sj', 'r', 'column_picked_logical', 'bj', 'mu2', 'sum2'); exit;"
