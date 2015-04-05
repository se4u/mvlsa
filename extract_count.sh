
######################################################################
## Code For Extracting Counts From Corpora
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
