SHELL := /bin/bash
.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input $(STORE2)/agigastandep

## GENERIC
# TARGET : Contains just the words. extracted from 1st column of source
%_word: %
	awk '{print $$1}' $+ > $@
%_2column: %
	awk '{print $$1, $$2}' $+ > $@
%_lowercase: %
	cat $< | tr '[:upper:]' '[:lower:]' > $@
echo_qstatfull:
	qstat | cut -c 73-75 | sort | uniq -c
echo_qstatarg_%:
	qstat -j $* | grep arg
echovar_%:
	echo $($*)
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
OPT_EXTRACTOR_ = $(word $1,$(subst _, ,$*))
OPT_EXTRACTOR_tilde = $(word $1,$(subst ~, ,$*))
## VARIABLES
# LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 addpath('src/kdtree');
QSDM := 15G
QSUB1 := qsub
QSUB2 := -V -j y -l mem_free=$(QSDM) -r yes #-verify ,ram_free=$(QSDM),h_vmem=$(QSDM)
QSUBCMD := $(QSUB1) $(QSUB2)
QSUBP1CMD := $(QSUB1) -p -1 $(QSUB2)
CWD_SUBMIT := -cwd submit_grid_stub.sh
QSUBMAKE := $(QSUBCMD) $(CWD_SUBMIT)
QSUBP1MAKE := $(QSUBP1CMD) $(CWD_SUBMIT)
QSUBPEMAKE := $(QSUBCMD) -pe smp 10 $(CWD_SUBMIT)
QSUBP1PEMAKE := $(QSUBP1CMD) -pe smp 10 $(CWD_SUBMIT)
QSUBPEMAKEHOLD = qsub -N $1 -V -hold_jid $2 -l mem_free=$3 -r yes -cwd submit_grid_stub.sh # -pe smp $4
QSUBPEMAKEHOLD2 = qsub -N $1 -V -hold_jid $2,$3 -l mem_free=$4 -r yes  -cwd submit_grid_stub.sh # -pe smp $5
QSUBPEMAKEHOLD3 = qsub -N $1 -V -hold_jid $2 -l mem_free=$3 -r yes  -cwd submit_grid_stub.sh # ,ram_free=$4 -pe smp $5
QSUBPEMAKEHOLD4 = qsub -N $1 -V -l hostname=$2 -l mem_free=$3 -r yes -cwd submit_grid_stub.sh # -pe smp $4
QSUBPEMAKEHOLD5 = qsub -N $1 -V -hold_jid $4 -l hostname=$2 -l mem_free=$3 -r yes -cwd submit_grid_stub.sh # -pe smp $4
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
STORE2 := /export/a14/prastog3
TOOLDIR := $(HOME)/tools
GLOVEDIR := $(TOOLDIR)/glove
WORD2VECDIR := $(TOOLDIR)/word2vec/trunk
PROJECT_PATH := $(HOME)/projects/mvppdb
RESPATH := $(PROJECT_PATH)/res/word_sim
SRC_DIR := $(PROJECT_PATH)/src
PREPROCESSING_CODE_DIR := $(SRC_DIR)/preprocessing_code

VOCABWITHCOUNT_500K_FILE := $(STORE2)/VOCAB/full.txt.vc5.500K
VOCAB_500K_FILE := $(VOCABWITHCOUNT_500K_FILE)_word
BIG_LANG := ar cs de es fr zh
BIG_INPUT := $(addprefix $(STORE2)/ppdb-input-simplified-,$(BIG_LANG))
BIG_INPUT_WORD := $(addsuffix _word,$(BIG_INPUT))
BIG_ALIGN_MAT := $(patsubst %,$(STORE2)/align_%.mat,$(BIG_LANG))
SVD_DIM := 500
PREPROCESS_OPT := Count logCount logCount-truncatele20 Count-truncatele20 logFreq Freq Freq-truncatele20 logFreq-truncatele20 logFreqPow075 FreqPow075 logFreqPow075-truncatele20 FreqPow075-truncatele20
MATCMD := time matlab -nojvm -nodisplay -r "warning('off', 'MATLAB:maxNumCompThreads:Deprecated'); warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src'); maxNumCompThreads(10); "
MATCMDENV := $(MATCMD)"setenv('TOEFL_QUESTION_FILENAME', '$(RESPATH)/toefl.qst'); setenv('TOEFL_ANSWER_FILENAME', '$(RESPATH)/toefl.ans'); setenv('SCWS_FILENAME', '$(RESPATH)/scws_simplified.txt'); setenv('RW_FILENAME', '$(RESPATH)/rw_simplified.txt'); setenv('MEN_FILENAME', '$(RESPATH)/MEN.txt'); setenv('EN_MC_30_FILENAME', '$(RESPATH)/EN-MC-30.txt'); setenv('EN_MTURK_287_FILENAME', '$(RESPATH)/EN-MTurk-287.txt'); setenv('EN_RG_65_FILENAME', '$(RESPATH)/EN-RG-65.txt'); setenv('EN_TOM_ICLR13_SEM_FILENAME', '$(RESPATH)/EN-TOM-ICLR13-SEM.txt'); setenv('EN_TOM_ICLR13_SYN_FILENAME', '$(RESPATH)/EN-TOM-ICLR13-SYN.txt'); setenv('EN_WS_353_REL_FILENAME', '$(RESPATH)/EN-WS-353-REL.txt'); setenv('EN_WS_353_SIM_FILENAME', '$(RESPATH)/EN-WS-353-SIM.txt'); setenv('EN_WS_353_ALL_FILENAME', '$(RESPATH)/EN-WS-353-ALL.txt'); setenv('WORDNET_TEST_FILENAME', '$(RESPATH)/wordnet.test'); setenv('PPDB_PARAPHRASE_RATING_FILENAME', '$(RESPATH)/ppdb_paraphrase_rating'); setenv('SIMLEX_FILENAME', '$(RESPATH)/simlex_simplified.txt'); setenv('MSR_QUESTIONS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.questions.txt'); setenv('MSR_ANSWERS', '$(RESPATH)/MSR_Sentence_Completion_Challenge_V1/Data/Holmes.machine_format.answers.txt'); "
CALCULATE_DEPENDENCY_CODE := src/makefile_specific/calculate_dependency.py

# AGIGA Related Variables
AGIGADIR := /export/corpora5/LDC/LDC2012T21
AGIGATOOLDIR := $(AGIGADIR)/tools/agiga_1.0
STANDEP_LIST_PART1 := pobj
STANDEP_LIST_PART2 := nsubj,amod,advmod,rcmod,dobj,prep_of,prep_in,prep_to,prep_on,prep_for,prep_with,prep_from,prep_at,prep_by,prep_as,prep_between,xsubj,agent,conj_and,conj_but
STANDEP_LIST := $(STANDEP_LIST_PART1),$(STANDEP_LIST_PART2)
STANDEP_LIST_PREPROCOPT := +nsubj.pass,-pobj,$(STANDEP_LIST_PART2)

# Count Processing Variables
V5_INDISVD_MEM := 25G

# Intermediate Result Folders
EXTRACT_COUNT_FOLDER := $(STORE2)/EXTRACT_COUNT
PROCESS_COUNT_FOLDER := $(STORE2)/PROCESS_COUNT
