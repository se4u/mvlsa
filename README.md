# Multi View LSA #
This is the companion code for the paper, `"Multiview LSA: Representation Learning Via Generalized CCA", Pushpendre Rastogi, Benjamin Van Durme and Raman Arora, NAACL(2015).`

    @conference{rastogi2015multiview,
	Author = {Pushpendre Rastogi, Benjamin {Van Durme} and Raman Arora},
	Booktitle = {Proceedings of NAACL},
	Keywords = {mvlsa,multiview lsa,mvppdb},
	Title = {Multiview LSA: Representation Learning Via Generalized CCA},
	Year = {2015}
    }

***pipeline.sh would run all the steps below.***
Assuming that you have downloaded the matlab files containing
co-occurrence counts to the directory
[EXTRACT\_COUNT\_FOLDER](file:commonheader.mk) specified in
`commonheader.mk`.
MultiView LSA works in 4 stages

1. EXTRACT\_COUNT
2. PROCESS\_COUNT
3. MVLSA
4. EVALUATE

Every stage creates files for the next stage. To run a particular
stage, just run the shell script associated with it. For example, run
process\_count.sh after running the EXTRACT\_COUNT stage that dumps
co-occurrence counts into sparse .mat files.

## EXTRACT_COUNT ##
This is a tedious process with lots of grunt work, and though the code
is provided you might not have access to the underlying resources. For
example I used word aligned bitext corpora that were used as inputs
for PPDB amongst others like FrameNet.

To solve this problem just download the extracted co-occurrence counts
as svmlight files or .mat file and go to the next step. Look at
`extract_count.sh` and `extract_count.mk` for more details.

## PROCESS_COUNT ##
There was some non-trivial tuning involved in getting good results
with the Multiview LSA paper. See the file process\_count.sh to see the
best setting reported in the paper. You can simply run
    ./process_count.sh
assuming that `EXTRACT_COUNT_FOLDER` defined in `commonheader.mk` is
set properly and that you downloaded the files from the previos step
into that folder. Note that my code works with matlab files even
though I provide the svmlight from previous stage for convenience.
Also note that this process can be trivially parallelized on
clusters since the commands in `process_count.sh` are independent of
each other.

## MVLSA ##
The heart of the algorithm. At its simplest it is just an SVD of the
concatenated matrices derived from previous step. But care is required
so that the matrices are not simultaneously loaded in memory and
missing values need special attention. Run:
    ./mvlsa.sh
This script would produce the best embeddings reported in the paper.

## EVALUATE ##


## MRDS ##
MRDS is a simple way to assign a minimum threshold `t` to a testset of
size N. If the correlation coefficients of two competing methods
differ by `t` then the difference is significant otherwise not. Please
note that the above sentence hides many details and you should see the
paper for a more qualified and measured explanation.

The code for MRDS can be run through `mrds.sh` which takes two inputs,
1. The size of the dataset
2. The type of dataset. (described in the paper)
