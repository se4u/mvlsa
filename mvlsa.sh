OUTPUT_DIR=`make -f commonheader.mk -s echovar_EMB_FOLDER`
BEST_SETTING=`make -f commonheader.mk -s echovar_BEST_SETTING`
OUTPUT_FILE=$OUTPUT_DIR/v5_embedding_${BEST_SETTING}.mat
: {DEBUG=-n}
make $DEBUG -f mvlsa.mk $OUTPUT_FILE
