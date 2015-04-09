# The paths and config in this file affect all of the other parts of the pipeline.
# Hopefully all you'll need to change would be the variables at the top of this file.
## PATHS
SHELL := /bin/bash
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
PREPROCESS_OPT_POSSIBLE := CountPow025-trunccol12500 Count logCount logCount-truncatele20 Count-truncatele20 logFreq Freq Freq-truncatele20 logFreq-truncatele20 logFreqPow075 FreqPow075 logFreqPow075-truncatele20 FreqPow075-truncatele20
PREPROCESS_OPT :=  $(word 1,PREPROCESS_OPT_POSSIBLE)
BEST_SETTING := mc_CountPow025-trunccol12500_500~E@mi,300_1e-5_16
## Intermediate Result Folders
EXTRACT_COUNT_FOLDER := $(STORE2)/EXTRACT_COUNT
PROCESS_COUNT_FOLDER := $(STORE2)/PROCESS_COUNT
PROCESS_COUNT_FILENAMES:=Process_Count_Output_Filenames
EMB_FOLDER:=$(STORE2)/EMB
EVALFILE_FOLDER:=/home/prastog3/projects/mvppdb/res/word_sim
## MATLAB CONFIGURATION
MATCMD := time matlab -nojvm -nodisplay -r "warning('off', 'MATLAB:maxNumCompThreads:Deprecated'); warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src');addpath('src/general_utility'); maxNumCompThreads(10); "

## QSUB COMMANDS
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
## MAKEFILE HACKERY
CALCULATE_DEPENDENCY_CODE := src/mvlsa/calculate_dependency.py
## AGIGA Related Variables
AGIGADIR := /export/corpora5/LDC/LDC2012T21
AGIGATOOLDIR := $(AGIGADIR)/tools/agiga_1.0
STANDEP_LIST_PART1 := pobj
STANDEP_LIST_PART2 := nsubj,amod,advmod,rcmod,dobj,prep_of,prep_in,prep_to,prep_on,prep_for,prep_with,prep_from,prep_at,prep_by,prep_as,prep_between,xsubj,agent,conj_and,conj_but
STANDEP_LIST := $(STANDEP_LIST_PART1),$(STANDEP_LIST_PART2)
STANDEP_LIST_PREPROCOPT := +nsubj.pass,-pobj,$(STANDEP_LIST_PART2)
## Count Processing Variables
V5_INDISVD_MEM := 25G
## HELPER COMMANDS
.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input $(STORE2)/agigastandep
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
SPACE :=
SPACE +=
COMMA := ,
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
# Joins elements of the list in $2 with the separator $1
join-with = $(subst $(space),$1,$(strip $2))
# Split a string $* with _ and get word at $1
OPT_EXTRACTOR_ = $(word $1,$(subst _, ,$*))
OPT_EXTRACTOR_tilde = $(word $1,$(subst ~, ,$*))
