: ${DO_ANALOGY_TEST:=1}
: ${VERBOSE:=0}
: ${DEBUGFLAGS=}
: ${FILE_TO_EVALUATE=WITH_GLOVE_MIKO} #
if [ $FILE_TO_EVALUATE == WITH_GLOVE_MIKO ]
then
    make ${DEBUGFLAGS} -f evaluate.mk VERBOSE=${VERBOSE} DO_ANALOGY_TEST=${DO_ANALOGY_TEST} log/fullgcca_extrinsic_test_combined_embedding_0
else
    BEST_SETTING=`make -f commonheader.mk -s echovar_BEST_SETTING`
    make ${DEBUGFLAGS} -f evaluate.mk VERBOSE=${VERBOSE} DO_ANALOGY_TEST=${DO_ANALOGY_TEST} log/fullgcca_extrinsic_test_${BEST_SETTING}
fi
