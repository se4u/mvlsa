# Multiview LSA #
This is the companion code for the paper\:
[Multiview LSA: Representation Learning Via Generalized CCA](http://www.cs.jhu.edu/~prastog3/mvlsa/mvlsa.pdf), [Pushpendre Rastogi](http://www.cs.jhu.edu/~prastog3), [Benjamin Van Durme](http://www.cs.jhu.edu/~vandurme) and [Raman Arora](http://www.cs.jhu.edu/~raman), NAACL(2015).

    @conference{rastogi2015multiview,
	  Author = {Pushpendre Rastogi, Benjamin {Van Durme} and Raman Arora},
	  Booktitle = {Proceedings of NAACL},
	  Keywords = {mvlsa,multiview lsa,mvppdb},
	  Title = {Multiview LSA: Representation Learning Via Generalized CCA},
	  Year = {2015}
    }

**NOTES:**

1. We have made available the best performing embeddings in both /mat/ and /svmlight/ formats
   (Table 9: column _MVLSA Combined_) at
   [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.16710.svg)](http://dx.doi.org/10.5281/zenodo.16710). Download
   the file [combined_embedding_0.mat](https://zenodo.org/record/16710/files/combined_embedding_0.mat) from that collection or
   [combined_embedding_0.emb.ascii](https://zenodo.org/record/16710/files/combined_embedding_0.emb.ascii.gz) and [combined_embedding_0.word.ascii](https://zenodo.org/record/16710/files/combined_embedding_0.word.ascii.gz)
   If you decide to use other embeddings files then please note that
   the embedding matrices in the matlab file need to be aligned to the
   vocabulary and then normalized as shown in the code below.

        word=textread('$(VOCAB_500K_FILE)', '%s');
        load('$(EMB_FILE)');
        if exist('sort_idx')
           word=word(sort_idx); % VERY IMPORTANT STEP 1 !!!
        end;
        G = normalize_embedding(G); % VERY IMPORTANT STEP 2 !!!
        conduct_extrinsic_test_impl(G, ...);

2. The code is hosted at [github.com/se4u/mvlsa](https://github.com/se4u/mvlsa)

## Acknowledgements ##

This material is based on research sponsored by the Defense Advanced Research Projects Agency (DARPA) under the Deep Exploration and Filtering of Text (DEFT) Program (Agreement number FA8750-13-2-0017). We also thank Juri Ganitkevitch for providing the word aligned bitext corpus as part of [the PPDB project](http://paraphrase.org)

## Detailed Description ##

MultiView LSA works in 4 stages

1. EXTRACT\_COUNT
2. PROCESS\_COUNT
3. MVLSA
4. EVALUATE

Every stage creates files for the next stage. To run a particular
stage, just run the shell script associated with it. For example, run
process\_count.sh after running the EXTRACT\_COUNT stage that dumps
co-occurrence counts into sparse .mat files.

`pipeline.sh` would run all the steps below
Assuming that you have downloaded the matlab files containing
co-occurrence counts to the directory
[EXTRACT\_COUNT\_FOLDER](file:commonheader.mk) and the
`VOCABWITHCOUNT_500K_FILE` points to the vocabulary file that you
downloaded. These configuration variables are specified in `commonheader.mk`.

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
with the Multiview LSA paper. See the file `process_count.sh` to see the
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
Note that this process is the slowest step, one by one we would
load the mat files produced in the previous stage and then
incrementally update our estimate of the left singular vectors. We
load one matlab file at a time to balance memory usage and disk access
but that is easy to change to load more or less data.
Note that this process needs close to 10GB memory and 2.5 minute per
view to run on a 10 core machine. (roughly 2 hours)
It is possible to decrease the run time and memory required through
more intelligent IO. (pre-loading data, mmap ?) but that's not built
in. The best embeddings are also provided for download as:

     `v5_embedding_mc_CountPow025-trunccol12500_500~E@mi,300_1e-5_16.mat`

## EVALUATE ##
Once we have trained the embeddings they should appear in the EMB_FOLDER
defined in the `commonheader.mk` file. For example, running
`./mvlsa.sh` with default settings creates:

     `$EMB_FOLDER/v5_embedding_mc_CountPow025-trunccol12500_500~E@mi,300_1e-5_16.mat`

Now we can evaluate the embedding to reproduce the results reported in
the paper. Run `./evaluate.sh` to get results like the following

    The TOEFL score over G with bare [80, 78, 72] is 0.900000
    Now working on SCWS_FILENAME
    The SCWS Pearson correlation over G (2002 out of 2003) is 0.655713
    The SCWS Spearman correlation over G (2002 out of 2003) is 0.674836
    Now working on RW_FILENAME
    The RW Pearson correlation over G (1868 out of 2034) is 0.380015
    The RW Spearman correlation over G (1868 out of 2034) is 0.411926
    ...
    ...

Note that running the evaluation if you did not extract the counts
yourself requires you to download the vocabulary file that I used for
creating these embeddings. and store it in the vocabulary file
folder. Change variable `VOCABWITHCOUNT_500K_FILE` in file
`commonheader.mk`  to change the location of the vocabulary file. You
can download the vocabulary file that we used to evaluate our
embeddings as well. By default the script produces the results without
combining with Glove embeddings, or Word2Vec embeddings, but the code
provides enough hooks to easily do it.

## MRDS ##
MRDS is a simple way to assign a minimum threshold `t` to a testset of
size N. If the correlation coefficients of two competing methods
differ by `t` then the difference is significant otherwise not. Please
note that the above description hides details and you should see the
paper for a more qualified and measured explanation. Run

    ./mrds.sh

At its default settings `mrds.sh` would produce the last column of
`Table~2` of the paper that describes the datasets used.

## Possible Future Work ##
1. Task specific representation learning through feedback guided
   weights.
2. Which contexts give a boost (this is part of analysis)
   Basically we code PMI, PPMI, Glove's Data dependent preprocessing as
   different views and then find which views get a high weight.
   I should decide the exact weighting strategy to use. Setting
   x-max really benefits the Semantic dataset however I can do a lot
   better in terms of weighting by carefully either
   either premultiply or postmultiply and then get basically a factored
   weighting.
3. Finally do humans really break the performance intro matrices of
   statistics that are called views ?
4. Tension between thresholding for noise removal and "missing value
   imputation for svd".
