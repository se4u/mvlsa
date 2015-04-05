# Multi View LSA #
The code for the paper:
"Multiview LSA: Representation Learning Via Generalized CCA", Pushpendre Rastogi, Benjamin Van Durme and Raman Arora, NAACL(2015).

@conference{rastogi2015multiview,
	Author = {Pushpendre Rastogi, Benjamin {Van Durme} and Raman Arora},
	Booktitle = {Proceedings of NAACL},
	Keywords = {mvlsa,multiview lsa,mvppdb},
	Title = {Multiview LSA: Representation Learning Via Generalized CCA},
	Year = {2015}
}

The code works in 4 stages
1. EXTRACT_COUNT
2. PROCESS_COUNT
3. PERFORM_MVLSA
4. EVALUATE

Every stage creates files, for the next stage and to run a particular
stage, just run the shell script associated with it. For example, run
process\_count.sh after running the EXTRACT_COUNT stage that dumps
co-occurrence counts into sparse .mat files.

## EXTRACT_COUNT ##
This is a tedious stage, and though the code is provided you might not
have access to the underlying resources. In stead just download the
processed co-occurrence counts from the url mentioned in the paper.


## PROCESS_COUNT ##

## PERFORM_MVLSA ##
