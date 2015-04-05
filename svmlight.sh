#!/bin/bash
COUNT_FOLDER=`make -f commonheader.mk -s echovar_PROCESS_COUNT_FOLDER`
: ${MATFILEDIR:=${COUNT_FOLDER}}
: ${DEBUG:=""}
: ${QSUB=yes}
CMD="qsub -V -j y -l 'hostname=a*' -r yes -cwd submit_grid_stub.sh "
if [ ${QSUB} = no ]
then
    CMD=make
fi
for file in ${MATFILEDIR}/*nosvd*.mat;
do
    ${CMD} ${DEBUG} -f svmlight.mk VARNAME='bj' ${file%.mat}.svmlight.gz
done
