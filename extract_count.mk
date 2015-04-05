include commonheader.mk
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
#	  2. The embeddings for english words present in google and bitext
# 	  3. The simplified file with alignments.
$(STORE2)/bitext_cooccurence_%.mat: $(PREPROCESSING_CODE_DIR)/create_sparse_alignmat.py $(STORE2)/big_vocabcount_% $(VOCABWITHCOUNT_500K_FILE) $(STORE2)/ppdb-input-simplified-%
	time python $+ $@ 2> log/$(@F)

# TARGET: SIMPLIFY THE DATA USED IN PPDB
#         A simplified BIG_INPUT where all the
#         english parses are converted to normal sentences.
$(STORE2)/ppdb-input-simplified-%: $(STORE2)/ppdb-input-%
	pypy src/remove_parse_from_english.py $^  $@

# TARGET: Single files each for a separater language
# This will take 22 files and convert them to 6 files fr es de cs ar zh
# Following are the 22 files that were concatenated.
# Gale, News Commentary, UN French, UN Spanish, Europarl, 10^9 French English
# Concatact Juri Ganitkevitch for this Data
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

###########################################
## MIKOLOV PROCESSING CODE
# TARGET: Mat file which contains the google embeddings.
#       Intersect my own vocabulary and google embedding's vocabulary
# 	Its a file with first column as the word,
#	second column is count in the source files.
#	third column onwards we have the embeddings.
#       Note that this is a sparse matrix with many rows that are completely zero.
# SOURCE : The google embedding and english big vocab
$(STORE2)/mikolov_cooccurence_intersect.mat: $(STORE)/gn300.txt $(VOCABWITHCOUNT_500K_FILE)
	time python src/overlap_between_google_and_big_vocabcount.py $+ $@

# TARGET: A txt file containing the word embeddings downloaded from google word2vec home page.
$(STORE)/gn300.txt: $(STORE)/GoogleNews-vectors-negative300.bin res/convertvec
	./res/convertvec bin2txt $<  $@

$(STORE)/GoogleNews-vectors-negative300.bin: $(STORE)/GoogleNews-vectors-negative300.bin.gz
	gunzip -c $< > $@

# Create the C binary needed to convert mikolov embeddings from .bin to .txt
res/convertvec : $(PREPROCESSING_CODE_DIR)/convertvec.c
	$(CC) $+ -o $@ $(CFLAGS)
