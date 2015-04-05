MAKE='make -n -f process_count.mk'
DIR=`make -f commonheader.mk -s echovar_PROCESS_COUNT_FOLDER`
TAKE_SVD_OR_NOT=mc # mc, nosvd
NONLINEAR_PREPROCESSING=CountPow025 # CountPow025, Count etc. See v5_indisvd_level2.m file
TRUNCATE_TO_TOP_COLUMNS=trunccol12500 # Truncate Columns.
SIZE_AFTER_SVD=500
REG=1e-5
OPTIONS=${TAKE_SVD_OR_NOT}~${NONLINEAR_PREPROCESSING}-${TRUNCATE_TO_TOP_COLUMNS}~${SIZE_AFTER_SVD}~${REG}

CORPUS_TYPE=agigastandep
for matrix in advmod agent amod conj_and conj_but dobj nsubj pobj prep_as prep_at prep_between prep_by prep_for prep_from prep_in prep_of prep_on prep_to prep_with rcmod xsubj; do
    ${MAKE} ${DIR}/v5_indisvd_${CORPUS_TYPE}_cooccurence_${matrix}~${OPTIONS}.mat;
done

CORPUS_TYPE=bitext
for matrix in ar cs de es fr zh; do
    ${MAKE} ${DIR}/v5_indisvd_${CORPUS_TYPE}_cooccurence_${matrix}~${OPTIONS}.mat;
done

CORPUS_TYPE=fnppdb
for matrix in l xl; do
    ${MAKE} ${DIR}/v5_indisvd_${CORPUS_TYPE}_cooccurence_${matrix}~${OPTIONS}.mat;
done

CORPUS_TYPE=morphology
for matrix in inflection; do
    ${MAKE} ${DIR}/v5_indisvd_${CORPUS_TYPE}_cooccurence_${matrix}~${OPTIONS}.mat;
done

CORPUS_TYPE=polyglotwiki
for matrix in {1..15}; do
    ${MAKE} ${DIR}/v5_indisvd_${CORPUS_TYPE}_cooccurence_${matrix}~${OPTIONS}.mat;
done
