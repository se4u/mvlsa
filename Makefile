.SECONDARY:
.PHONY: optimal_cca_dimension_table log/gridrun_log_tabulate big_input 
.INTERMEDIATE: gn_ppdb.itermediate
## GENERIC 
# TARGET : Contains just the words. extracted from 1st column of source
%_word: %
	awk '{print $$1}' $+ > $@
%_2column: %
	awk '{print $$1, $$2}' $+ > $@
echo_qstatfull:
	qstat | cut -c 73-75 | sort | uniq -c
echo_qstatarg_%:
	qstat -j $* | grep arg
echo_qsubpemake:
	echo $(QSUBPEMAKE)
# A literal space.
space :=
space +=
COMMA := ,
# Joins elements of the list in arg 2 with the given separator.
# 1. Element separator.
# 2. The list.
join-with = $(subst $(space),$1,$(strip $2))


## VARIABLES
# LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 addpath('src/kdtree');
QSUBCMD := qsub -V -j y -l mem_free=15G -r yes #-verify
QSUBP1CMD := qsub -p -1 -V -j y -l mem_free=15G -r yes
CWD_SUBMIT := -cwd submit_grid_stub.sh 
QSUBMAKE := $(QSUBCMD) $(CWD_SUBMIT)
QSUBP1MAKE := $(QSUBP1CMD) $(CWD_SUBMIT)
QSUBPEMAKE := $(QSUBCMD) -pe smp 10 $(CWD_SUBMIT)
QSUBP1PEMAKE := $(QSUBP1CMD) -pe smp 10 $(CWD_SUBMIT)
# QSUBPEMAKE := echo
CC := gcc
CFLAGS := -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result
STORE := /export/a15/prastog3
STORE2 := /export/a14/prastog3
GLOVEDIR := /home/prastog3/tools/glove
TOOLDIR := /home/prastog3/tools
WORD2VECDIR := $(TOOLDIR)/word2vec/trunk
RESPATH := /home/prastog3/projects/mvppdb/res
BIG_LANG := ar cs de es fr zh 
BIG_INPUT := $(addprefix $(STORE2)/ppdb-input-simplified-,$(BIG_LANG))
BIG_INPUT_WORD := $(addsuffix _word,$(BIG_INPUT))
BIG_ALIGN_MAT := $(patsubst %,$(STORE2)/align_%.mat,$(BIG_LANG))
SVD_DIM := 500
PREPROCESS_OPT := Count logCount logCount-truncatele20 Count-truncatele20 logFreq Freq Freq-truncatele20 logFreq-truncatele20 logFreqPow075 FreqPow075 logFreqPow075-truncatele20 FreqPow075-truncatele20
MATCMD := time matlab -nojvm -nodisplay -r "warning('off', 'MATLAB:maxNumCompThreads:Deprecated'); warning('off','MATLAB:HandleGraphics:noJVM'); warning('off', 'MATLAB:declareGlobalBeforeUse');addpath('src'); maxNumCompThreads(10); "
MATCMDENV := $(MATCMD)"setenv('TOEFL_QUESTION_FILENAME', '$(RESPATH)/word_sim/toefl.qst'); setenv('TOEFL_ANSWER_FILENAME', '$(RESPATH)/word_sim/toefl.ans'); setenv('SCWS_FILENAME', '$(RESPATH)/word_sim/scws_simplified.txt'); setenv('RW_FILENAME', '$(RESPATH)/word_sim/rw_simplified.txt'); setenv('MEN_FILENAME', '$(RESPATH)/word_sim/MEN.txt'); setenv('EN_MC_30_FILENAME', '$(RESPATH)/word_sim/EN-MC-30.txt'); setenv('EN_MTURK_287_FILENAME', '$(RESPATH)/word_sim/EN-MTurk-287.txt'); setenv('EN_RG_65_FILENAME', '$(RESPATH)/word_sim/EN-RG-65.txt'); setenv('EN_TOM_ICLR13_SEM_FILENAME', '$(RESPATH)/word_sim/EN-TOM-ICLR13-SEM.txt'); setenv('EN_TOM_ICLR13_SYN_FILENAME', '$(RESPATH)/word_sim/EN-TOM-ICLR13-SYN.txt'); setenv('EN_WS_353_REL_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-REL.txt'); setenv('EN_WS_353_SIM_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-SIM.txt'); setenv('EN_WS_353_ALL_FILENAME', '$(RESPATH)/word_sim/EN-WS-353-ALL.txt'); setenv('WORDNET_TEST_FILENAME', '$(RESPATH)/wordnet.test'); setenv('PPDB_PARAPHRASE_RATING_FILENAME', '$(RESPATH)/ppdb_paraphrase_rating'); setenv('SIMLEX_FILENAME', '$(RESPATH)/word_sim/simlex_simplified.txt'); "

#########################################################
####################  TABULATION CODE
#########################################################
# make tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_100~stgcca,300_1e-8,mono1015.300
# 		O	G	U	V
# JURI (0 out of 0)			0.631346	0.650639	0.660756	0.620864
# TOEFL (78 out of 80)			0.862500	0.812500	0.875000	0.775000
# SCWS (1978 out of 2003)		0.647620	0.591340	0.620951	0.572749
# RW (1808 out of 2034)			0.448516	0.363758	0.478068	0.348311
# MEN (2946 out of 3000)		0.742855	0.598809	0.739194	0.539139
# EN_MC_30 (30 out of 30)		0.788607	0.486871	0.788385	0.473075
# EN_MTURK_287 (275 out of 287)		0.632702	0.563260	0.600778	0.550816
# EN_RG_65 (65 out of 65)		0.760783	0.537924	0.777458	0.516506
# EN_WS_353_ALL (350 out of 353)	0.683337	0.494308	0.649617	0.428453
# EN_WS_353_REL (250 out of 252)	0.599603	0.447644	0.546479	0.392421
# EN_WS_353_SIM (202 out of 203)	0.778387	0.585610	0.749919	0.527404
# SIMLEX (999 out of 999)		0.441962	0.389407	0.473977	0.359768
# EN_TOM_ICLR13_SYN (10043 out of 10675)0.633630	0.255363	0.573489	0.240562
# EN_TOM_ICLR13_SEM (3662 out of 8869)	0.109708	0.040704	0.111061	0.031232

# for meanchoice in mc muc; do for preproc in logCount logFreq log1pFreq FreqPow025 FreqPow050; do\
# 	  make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_"$meanchoice"_"$preproc"-truncatele200_100~stgccaonlyen,100_1e-8.100 | sed s#G#G_"$meanchoice"_"$preproc"#g ; done; done  | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -10 -l 26 -w 170
# G_mc_logCount	 G_mc_logFreq	  G_mc_log1pFreq   G_mc_FreqPow025  G_mc_FreqPow050  G_muc_logCount   G_muc_logFreq    G_muc_log1pFreq	G_muc_FreqPow025 G_muc_FreqPow050
# 0.474211	 0.440235	  0.312606	   0.512131	    0.420461	     0.473770	      0.439944	       0.295662		0.512199	 0.419995
# 0.575000	 0.487500	  0.487500	   0.675000	    0.600000	     0.587500	      0.537500	       0.487500		0.675000	 0.600000
# 0.438919	 0.454679	  0.359987	   0.506922	    0.427360	     0.456407	      0.484059	       0.394187		0.507233	 0.428260
# 0.160312	 0.153432	  0.153358	   0.224820	    0.197908	     0.180479	      0.171615	       0.154358		0.252367	 0.221693
# 0.156696	 0.217420	  0.148584	   0.308438	    0.229430	     0.137952	      0.201318	       0.148686		0.308451	 0.224367
# 0.319537	 0.395861	  0.427904	   0.400312	    0.439697	     0.283267	      0.286382	       0.525145		0.396306	 0.467735
# 0.418275	 0.381498	  0.338722	   0.439867	    0.390910	     0.417446	      0.382357	       0.362406		0.443703	 0.392816
# 0.244342	 0.288162	  0.254942	   0.377157	    0.356919	     0.268842	      0.325709	       0.306521		0.376370	 0.368284
# 0.339407	 0.366513	  0.292194	   0.363187	    0.285198	     0.347494	      0.393826	       0.315903		0.365529	 0.285678
# 0.167935	 0.227740	  0.180871	   0.243823	    0.192024	     0.154990	      0.218532	       0.223604		0.243006	 0.187143
# 0.508421	 0.511649	  0.393528	   0.511895	    0.421038	     0.531636	      0.547310	       0.419327		0.517191	 0.428954
# 0.163552	 0.152679	  0.165335	   0.249458	    0.219772	     0.171304	      0.173161	       0.175561		0.249748	 0.217144
# 0.079157	 0.095082	  0.004309	   0.088525	    0.029883	     0.073630	      0.097143	       0.005152		0.083653	 0.026979
# 0.019393	 0.027173	  0.006652	   0.019732	    0.016687	     0.018942	      0.028752	       0.006540		0.019506	 0.015898

# make tabulate_Spearman_word2vecBitext_extrinsic_test  # make tabulate_Spearman_gloveBitext_extrinsic_test #$for meanchoice in mc muc; do for preproc in logCount logFreq log1pFreq FreqPow025 FreqPow050; do  make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_"$meanchoice"_"$preproc"-truncatele200_100~stgccanoenbvgn,300_1e-8.300 | sed s#G#G_"$meanchoice"_"$preproc"#g ; done; done  | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -10 -l 26 -w 170
# 		                   word2vecBitext G_mc_stgccanobvgn G_muc_stgccanobvgn gloveBitext(mono1015) G_mc_logCount G_mc_logFreq	  G_mc_log1pFreq   G_mc_FreqPow025  G_mc_FreqPow050  G_muc_logCount   G_muc_logFreq    G_muc_log1pFreq	G_muc_FreqPow025 G_muc_FreqPow050 
# JURI (0 out of 0)			0.609977    0.681989          0.681918	       	0.574885  0.648926 # 0.686661	 0.640717	  0.492306	   0.627458	    0.575766	     0.686785	      0.643534	       0.487849		0.627705	 0.576054	  
# TOEFL (68 out of 80)			0.612500    0.737500          0.750000	       	0.637500  0.762500 # 0.737500	 0.687500	  0.700000	   0.712500	    0.712500	     0.750000	      0.700000	       0.700000		0.712500	 0.712500	  
# SCWS (1909 out of 2003)		0.518767    0.536503          0.542240	       	0.466286  0.571063 # 0.533019	 0.525738	  0.397062	   0.518809	    0.494410	     0.533069	      0.528122	       0.388574		0.521203	 0.491021	  
# RW (946 out of 2034)			0.045796    0.178746          0.214890	       	0.136810  0.290344 # 0.167818	 0.194352	  0.181530	   0.217943	    0.185825	     0.199358	      0.245670	       0.183154		0.215621	 0.192164	  
# MEN (2831 out of 3000)		0.455359    0.372000          0.373856	       	0.469963  0.535230 # 0.383259	 0.421296	  0.174585	   0.333169	    0.257029	     0.385034	      0.421302	       0.168124		0.332987	 0.256393	  
# EN_MC_30 (29 out of 30)		0.343792    0.388963          0.447041	       	0.378950  0.347575 # 0.303961	 0.103249	  0.301958	   0.062528	    0.285269	     0.334223	      0.092568	       0.273476		0.076101	 0.279261	  
# EN_MTURK_287 (283 out of 287)		0.520690    0.489515          0.491324	       	0.510015  0.543425 # 0.459704	 0.472481	  0.319530	   0.476346	    0.414698	     0.461078	      0.468937	       0.295009		0.473998	 0.408225	  
# EN_RG_65 (63 out of 65)		0.344465    0.473080          0.504114	       	0.395279  0.399231 # 0.414551	 0.234442	  0.100622	   0.282786	    0.319328	     0.428604	      0.231054	       0.125296		0.289233	 0.302084	  
# EN_WS_353_ALL (349 out of 353)	0.502696    0.480037          0.490973	       	0.376691  0.456188 # 0.450338	 0.430266	  0.143697	   0.311522	    0.281854	     0.459412	      0.437907	       0.120061		0.311978	 0.280296	  
# EN_WS_353_REL (252 out of 252)	0.467833    0.413397          0.419393	       	0.372237  0.418960 # 0.401157	 0.374978	  0.057942	   0.309357	    0.265662	     0.402453	      0.372771	       0.036994		0.309657	 0.266451	  
# EN_WS_353_SIM (199 out of 203)	0.540855    0.547696          0.562167	       	0.444957  0.533453 # 0.510515	 0.463199	  0.244611	   0.361338	    0.358920	     0.526663	      0.476838	       0.223590		0.362239	 0.353526	  
# SIMLEX (993 out of 999)		0.237295    0.364863          0.367377	       	0.286670  0.364080 # 0.394337	 0.293126	  0.241932	   0.339661	    0.295190	     0.396807	      0.294622	       0.238087		0.339671	 0.293926	  
# EN_TOM_ICLR13_SYN (10199 out of 10675)0.271756    0.206745          0.204309	       	0.399063  0.222576 # 0.191475	 0.070258	  0.056956	   0.165714	    0.132272	     0.187166	      0.068103	       0.055550		0.162810	 0.131803	  
# EN_TOM_ICLR13_SEM (7598 out of 8869)	0.130342    0.014432          0.013418         	0.280302  0.035179 # 0.008682	 0.014883	  0.001015	   0.008682	    0.002255	     0.008118	      0.012967	       0.000789		0.008005	 0.002368          

# for s in log1pFreq FreqPow025 FreqPow050 ; do make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_"$s"-truncatele200_100~stgcca,300_1e-8.300 | sed s#G#G_"$s"#g ; done  | awk -F"\t" '{print $2, $3, $4, $5}'|  pr -3 -l 27 -w 100 
#  O G_log1pFreq U		  O G_FreqPow025 U		   O G_FreqPow050 U
#   0.631346 0.538630		   0.631346 0.646816		    0.631346 0.605284
#   0.862500 0.775000		   0.862500 0.800000		    0.862500 0.775000
#   0.647620 0.566940		   0.647620 0.582181		    0.647620 0.568515
#   0.448516 0.356455		   0.448516 0.372053		    0.448516 0.326614
#   0.742855 0.602660		   0.742855 0.546721		    0.742855 0.540118
#   0.788607 0.683356		   0.788607 0.396306		    0.788607 0.520694
#   0.632702 0.518654		   0.632702 0.540580		    0.632702 0.531600
#   0.760783 0.646917		   0.760783 0.533510		    0.760783 0.665822
#   0.683337 0.522149		   0.683337 0.433876		    0.683337 0.471005
#   0.599603 0.439877		   0.599603 0.368509		    0.599603 0.427389
#   0.778387 0.638927		   0.778387 0.546907		    0.778387 0.584056
#   0.441962 0.387350		   0.441962 0.386922		    0.441962 0.373980
#   0.633630 0.203185		   0.633630 0.211148		    0.633630 0.220890
#   0.109708 0.007554		   0.109708 0.022550		    0.109708 0.010711

# uses v5_embedding_mc_(preproc)-stgcca,300,1e-8.300          # for d2rm in stgccanoar stgccanocs stgccanode stgccanoes stgccanofr stgccanozh stgccanoen stgccanobvgn; do for meanchoice in mc muc; do make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_"$meanchoice"_logCount-truncatele200_100~"$d2rm",300_1e-8.300 | sed s#G#G_"$meanchoice"_"$d2rm"#g ; done; done  | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -16 -l 26 -w 300   
# G_logCount-truncatele200_100   G_logFreq-truncatele200_100  #G_mcst_ccanoar	  G_muc_stgccanoar  G_mc_stgccanocs   G_muc_stgccanocs	G_mc_stgccanode	  G_muc_stgccanode  G_mc_stgccanoes   G_muc_stgccanoes	G_mc_stgccanofr	  G_muc_stgccanofr  G_mc_stgccanozh   G_muc_stgccanozh	G_mc_stgccanoen	  G_muc_stgccanoen  G_mc_stgccanobvgn G_muc_stgccanobvgn
# 0.682882		       0.646631			      # 0.685434	  0.685779	    0.692875	      0.692946		0.671726	  0.672160	    0.682316	      0.683213		0.673701	  0.673293	    0.678472	      0.679007		0.680293	  0.680309	    0.681989	      0.681918															   
# 0.825000		       0.812500			      # 0.837500	  0.837500	    0.837500	      0.837500		0.825000	  0.825000	    0.812500	      0.812500		0.825000	  0.825000	    0.825000	      0.825000		0.850000	  0.850000	    0.737500	      0.750000															   
# 0.609014		       0.582750			      # 0.605250	  0.605689	    0.606554	      0.606061		0.609691	  0.609434	    0.602125	      0.600615		0.609954	  0.608552	    0.597121	      0.596899		0.604721	  0.603519	    0.536503	      0.542240															   
# 0.426652		       0.419632			      # 0.430595	  0.426965	    0.420140	      0.418068		0.422155	  0.421387	    0.427512	      0.424577		0.433549	  0.431182	    0.424133	      0.421346		0.426596	  0.424630	    0.178746	      0.214890															   
# 0.655968		       0.669217			      # 0.650495	  0.647434	    0.651159	      0.648667		0.653166	  0.649931	    0.660577	      0.657709		0.643563	  0.640163	    0.637177	      0.632585		0.650230	  0.646951	    0.372000	      0.373856															   
# 0.672452		       0.678460			      # 0.692924	  0.691811	    0.670227	      0.676903		0.670004	  0.665554	    0.692256	      0.690476		0.706720	  0.713396	    0.716288	      0.718514		0.658211	  0.655541	    0.388963	      0.447041															   
# 0.612105		       0.580805			      # 0.634153	  0.630226	    0.602954	      0.597700		0.595526	  0.591515	    0.593199	      0.593763		0.578928	  0.576569	    0.565890	      0.560877		0.597814	  0.598089	    0.489515	      0.491324															   
# 0.724962		       0.706472			      # 0.716766	  0.716264	    0.727344	      0.728983		0.723716	  0.724350	    0.736196	      0.733660		0.707347	  0.708527	    0.720897	      0.718799		0.721247	  0.719586	    0.473080	      0.504114															   
# 0.593086		       0.558771			      # 0.577547	  0.575737	    0.587034	      0.584391		0.585133	  0.583195	    0.600201	      0.600736		0.574787	  0.577721	    0.587197	      0.587021		0.584666	  0.582843	    0.480037	      0.490973															   
# 0.509166		       0.452617			      # 0.480424	  0.477881	    0.494025	      0.489542		0.488082	  0.484999	    0.514609	      0.515192		0.468357	  0.470385	    0.486284	      0.487352		0.496076	  0.492846	    0.413397	      0.419393															   
# 0.673502		       0.676089			      # 0.679951	  0.676841	    0.681048	      0.679081		0.667494	  0.664255	    0.684348	      0.685069		0.669978	  0.672117	    0.684574	      0.682313		0.667372	  0.668330	    0.547696	      0.562167															   
# 0.467130		       0.402567			      # 0.457662	  0.457686	    0.471802	      0.470861		0.464748	  0.463964	    0.457577	      0.456668		0.467128	  0.466659	    0.451004	      0.450005		0.478754	  0.478023	    0.364863	      0.367377															   
# 0.401874		       0.376487			      # 0.385667	  0.384824	    0.416206	      0.415738		0.407494	  0.407869	    0.398782	      0.399157		0.375176	  0.374707	    0.362623	      0.362810		0.365902	  0.363747	    0.206745	      0.204309															   
# 0.043410                     0.075431			      # 0.043071	  0.042620	    0.043748	      0.043071		0.043748	  0.043861	    0.049724	      0.049160		0.043184	  0.042282	    0.040929	      0.040365		0.033375	  0.032924	    0.014432	      0.013418                                                                                                                     

# $make tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_muc_FreqPow025-truncatele200_500~stgcca,300_1e-8.300
# 		O	G	U	V
# JURI (0 out of 0)			0.631346	0.724888	0.660756	0.708232
# TOEFL (78 out of 80)			0.862500	0.900000	0.875000	0.925000
# SCWS (1978 out of 2003)			0.647620	0.645942	0.621448	0.628325
# RW (1808 out of 2034)			0.448516	0.438018	0.478068	0.421567
# MEN (2946 out of 3000)			0.742855	0.620752	0.739194	0.561246
# EN_MC_30 (30 out of 30)			0.788607	0.655541	0.788385	0.642190
# EN_MTURK_287 (275 out of 287)			0.632702	0.538021	0.600778	0.528372
# EN_RG_65 (65 out of 65)			0.760783	0.630503	0.777458	0.666128
# EN_WS_353_ALL (350 out of 353)			0.683337	0.631271	0.649617	0.580749
# EN_WS_353_REL (250 out of 252)			0.599603	0.562476	0.546479	0.525847
# EN_WS_353_SIM (202 out of 203)			0.778387	0.710593	0.749919	0.679963
# SIMLEX (999 out of 999)			0.441962	0.494072	0.473977	0.475125

# for p in logFreq-truncatele600_50  logFreq-truncatele400_50  logFreq-truncatele600_100    logFreq-truncatele400_100  logFreq-truncatele200_100  FreqPow025-truncatele600_50 ; do make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_"$p"~stgcca,300_1e-8.300  | sed s#G#G_"$p"#g  ; done | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -6 -l 25 -w 200
# G_logFreq-truncatele600_50	 G_logFreq-truncatele400_50	  G_logFreq-truncatele600_100	   G_logFreq-truncatele400_100	    G_logFreq-truncatele200_100	     G_FreqPow025-truncatele600_50
# 0.635788			 0.633831			  0.648441			   0.645083			    0.646631			     0.543789
# 0.812500			 0.787500			  0.850000			   0.875000			    0.812500			     0.712500
# 0.551958			 0.551100			  0.588798			   0.581126			    0.582750			     0.548381
# 0.347366			 0.346795			  0.416331			   0.417075			    0.419632			     0.318247
# 0.568530			 0.568691			  0.671315			   0.670907			    0.669217			     0.443183
# 0.410102			 0.418781			  0.658656			   0.686471			    0.678460			     0.513129
# 0.553836			 0.543199			  0.606255			   0.607635			    0.580805			     0.510767
# 0.545749			 0.534362			  0.705030			   0.715980			    0.706472			     0.474194
# 0.514097			 0.506608			  0.547056			   0.555222			    0.558771			     0.404736
# 0.378312			 0.388795			  0.435982			   0.447083			    0.452617			     0.344932
# 0.621266			 0.604803			  0.659818			   0.664294			    0.676089			     0.530939
# 0.330595			 0.331012			  0.399168			   0.407856			    0.402567			     0.301618
# 0.177705			 0.179953			  0.367963			   0.376393			    0.376487			     0.140141
# 0.043861			 0.042282			  0.074078			   0.073965			    0.075431			     0.014432
# for p in logCount-truncatele600_50  logCount-truncatele400_50  logCount-truncatele600_100    logCount-truncatele400_100  logCount-truncatele200_100  ; do make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_mc_"$p"~stgcca,300_1e-8.300  | sed s#G#G_"$p"#g  ; done | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -5 -l 25 -w 150
#G_logCount-truncatele600_50   G_logCount-truncatele400_50   G_logCount-truncatele600_100  G_logCount-truncatele400_100	G_logCount-truncatele200_100
# 0.658967		      0.663075			    0.684755			  0.684154			0.682882
# 0.762500		      0.762500			    0.837500			  0.837500			0.825000
# 0.558039		      0.556827			    0.604723			  0.605812			0.609014
# 0.359413		      0.360894			    0.429268			  0.430235			0.426652
# 0.544465		      0.546221			    0.652691			  0.654586			0.655968
# 0.552292		      0.557410			    0.692034			  0.692479			0.672452
# 0.572071		      0.579346			    0.615883			  0.622966			0.612105
# 0.549551		      0.548655			    0.720329			  0.715062			0.724962
# 0.512486		      0.510859			    0.599814			  0.591919			0.593086
# 0.382309		      0.386254			    0.510369			  0.505357			0.509166
# 0.629854		      0.632064			    0.675643			  0.670630			0.673502
# 0.404087		      0.408572			    0.457986			  0.461226			0.467130
# 0.231756		      0.229696			    0.401780			  0.401311			0.401874
# 0.023678		      0.023340			    0.043635			  0.043184			0.043410                       
# make tabulate_Spearman_fullgcca_extrinsic_test_v4_stgcca_run_sans_mu_300_1e-8_logCount.300
# 		O	G	U	V
# JURI (0 out of 0)			0.631346	0.708067	0.660756	0.714275
# TOEFL (78 out of 80)			0.862500	0.862500	0.875000	0.925000
# SCWS (1978 out of 2003)		0.647620	0.586859	0.620711	0.580175
# RW (1808 out of 2034)			0.448516	0.380236	0.478068	0.409997
# MEN (2946 out of 3000)		0.742855	0.487733	0.739194	0.506923
# EN_MC_30 (30 out of 30)		0.788607	0.414775	0.788385	0.468180
# EN_MTURK_287 (275 out of 287)		0.632702	0.498678	0.600778	0.435408
# EN_RG_65 (65 out of 65)		0.760783	0.478828	0.777458	0.591579
# EN_WS_353_ALL (350 out of 353)	0.683337	0.521329	0.649617	0.523833
# EN_WS_353_REL (250 out of 252)	0.599603	0.466345	0.546479	0.473674
# EN_WS_353_SIM (202 out of 203)	0.778387	0.601384	0.749919	0.610702
# EN_TOM_ICLR13_SYN (10043 out of 10675)0.633630	0.391382	0.573489	0.309883
# EN_TOM_ICLR13_SEM (3662 out of 8869)	0.109708	0.049949	0.111061	0.052994
# for i in 5 6 7 8 9 ; do  make -s tabulate_Spearman_fullgcca_extrinsic_test_v3_stgcca_run_sans_mu_300_1e-"$i"_logCount | sed s#G#G_"$i"#g ; done  | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}' | pr -5 -l 24 -w 50
# 2014-08-18 06:20                            Page 1
# G_5          G_6        G_7      G_8	           G_9          G_Mean_centered
# 0.708286  0.708286  0.708286  0.708286	0.708286       0.708067
# 0.900000  0.900000  0.900000  0.900000	0.900000       0.862500
# 0.607756  0.607756  0.608509  0.608509	0.608509       0.586859
# 0.420422  0.420422  0.420422  0.420422	0.420422       0.380236
# 0.478979  0.478979  0.478979  0.478979	0.478979       0.487733
# 0.399421  0.399421  0.399421  0.399421	0.399421       0.414775
# 0.516944  0.516944  0.516944  0.516944	0.516944       0.498678
# 0.528374  0.528374  0.528374  0.528374	0.528374       0.478828
# 0.547046  0.547046  0.547046  0.547046	0.547046       0.521329
# 0.465086  0.465086  0.465086  0.465086	0.465086       0.466345
# 0.632959  0.632959  0.632959  0.632959	0.632959       0.601384
# 0.404122  0.404122  0.404122  0.404122	0.404122       0.391382
# 0.049273  0.049273  0.049273  0.049273	0.049273       0.049949

# ROW HEADERS
# JURI (0 out of 0)			  
# TOEFL (78 out of 80)			  
# SCWS (1978 out of 2003)			  
# RW (1808 out of 2034)			  
# MEN (2946 out of 3000)			  
# EN_MC_30 (30 out of 30)			  
# EN_MTURK_287 (275 out of 287)		  
# EN_RG_preprocCountPow075_65 (65 out of 65)
# EN_WS_353_ALL (350 out of 353)		  
# EN_WS_353_REL (250 out of 252)		  
# EN_WS_353_SIM (202 out of 203)		  
# SIMLEX (999 out of 999)			  
# EN_TOM_ICLR13_SYN (10043 out of 10675)	  
# EN_TOM_ICLR13_SEM (3662 out of 8869)	  

# origdim effect
# for origdim in 300 800 1000; do  make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_"$origdim"~stgcca,300_1e-8.300 | sed s#G#G_origdim"$origdim"#g ; done | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -3 -l 26 -w 100
# 2014-08-28 03:28                                                                              Page 1
# G_origdim300			 G_origdim800			  G_origdim1000
# 0.707020			 0.717758			  0.705521
# 0.912500			 0.937500			  0.937500
# 0.600223			 0.607761			  0.615567
# 0.415820			 0.438715			  0.418812
# 0.441121			 0.511836			  0.519872
# 0.440810			 0.334446			  0.430129
# 0.573339			 0.552758			  0.521445
# 0.533619			 0.511829			  0.544896
# 0.575860			 0.569739			  0.590220
# 0.495099			 0.515047			  0.565376
# 0.641842			 0.638343			  0.635940
# 0.430732			 0.494345			  0.478833
# 0.383044			 0.368806			  0.367213
# 0.049724			 0.048934			  0.044424

# TRUNCATION EFFECT
# for trunc in 20 40 60 80; do  make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele"$trunc"_500~stgcca,300_1e-8.300 | sed s#G#G_trunc"$trunc"#g ; done | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -4 -l 26 -w 100
# 2014-08-28 03:44                                                                              Page 1
# G_trunc20		 G_trunc40		  G_trunc60		   G_trunc80
# 0.708075		 0.705920		  0.706139		   0.705507
# 0.912500		 0.887500		  0.887500		   0.912500
# 0.604867		 0.606613		  0.606612		   0.611189
# 0.419957		 0.422049		  0.421240		   0.423434
# 0.482634		 0.483635		  0.483005		   0.484574
# 0.390521		 0.386070		  0.382065		   0.377837
# 0.509374		 0.521147		  0.514972		   0.517071
# 0.538012		 0.520178		  0.524003		   0.518014
# 0.545194		 0.546518		  0.542044		   0.544546
# 0.461668		 0.463596		  0.460235		   0.464785
# 0.631622		 0.630286		  0.627033		   0.628449
# 0.482694		 0.482086		  0.483605		   0.482767
# 0.397845		 0.393817		  0.393724		   0.390632
# 0.051641		 0.050626		  0.050400		   0.049949

# Preprocessing Effect
# $for preproc in CountPow075 CountPow050 CountPow025 Freq FreqPow075 logFreq; do  make -s tabulate_Spearman_fullgcca_extrinsic_test_v5_embedding_muc_"$preproc"-truncatele20_500~stgcca,300_1e-8.300 | sed s#G#G_preproc"$preproc"#g ; done | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -6 -l 26 -w 130
# 2014-08-28 03:45                                                                                                            Page 1
# G_preprocCountPow075 G_preprocCountPow050 G_preprocCountPow025 G_preprocFreq	    G_preprocFreqPow075	 G_preproclogFreq
# 0.601202	     0.688071		  0.723071	       0.642454		    0.678717		 0.662494
# 0.875000	     0.862500		  0.862500	       0.850000		    0.837500		 0.837500
# 0.523833	     0.582392		  0.627079	       0.607728		    0.624460		 0.564207
# 0.323877	     0.398517		  0.439824	       0.393101		    0.402747		 0.344365
# 0.332868	     0.416284		  0.497342	       0.657529		    0.649033		 0.334414
# 0.451268	     0.325768		  0.419226	       0.567423		    0.662216		 0.251446
# 0.404660	     0.464999		  0.537656	       0.563635		    0.536043		 0.464672
# 0.398772	     0.481144		  0.507414	       0.677689		    0.762444		 0.334320
# 0.427116	     0.493939		  0.559144	       0.594472		    0.613389		 0.464069
# 0.353687	     0.403619		  0.489726	       0.524231		    0.527678		 0.358445
# 0.505380	     0.582492		  0.638279	       0.686033		    0.708104		 0.575453
# 0.349698	     0.448060		  0.465607	       0.473387		    0.499217		 0.381461
# 0.215082	     0.317377		  0.377424	       0.348103		    0.365246		 0.220234
# 0.032924	     0.037547		  0.036306	       0.016575		    0.020070		 0.012854

#                                         G_fast    G_slow
# JURI (0 out of 0)		       0.708523  0.726437
# TOEFL (78 out of 80)		       0.900000  0.950000
# SCWS (1978 out of 2003)		       0.604498  0.605402
# RW (1808 out of 2034)		       0.417530  0.426346
# MEN (2946 out of 3000)		       0.481535  0.513432
# EN_MC_30 (30 out of 30)		       0.395639  0.390521
# EN_MTURK_287 (275 out of 287)	       0.501459  0.488514
# EN_RG_65 (65 out of 65)		       0.527937  0.544306
# EN_WS_353_ALL (350 out of 353)	       0.544601  0.555136
# EN_WS_353_REL (250 out of 252)	       0.463560  0.481364
# EN_WS_353_SIM (202 out of 203)	       0.628619  0.644622
# EN_TOM_ICLR13_SYN (10043 out of 10675) 0.398501  0.361593
# EN_TOM_ICLR13_SEM (3662 out of 8869)   0.051302  0.047018


# for s in 1000 2000 3000; do for i in 5 6 7 8 9 ; do  make -s tabulate_Spearman_fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_"$s"_1e-"$i"_logCount | sed s#G#G_"$s"_"$i"#g ; done; done  | awk -F"\t" '{print $2, $3, $4, $5}' | awk  '{print $2}'  | pr -15 -l 24 -w 150
# 2014-08-18 04:39                                                                                                                                Page 1
# G_1000_5  G_1000_6  G_1000_7  G_1000_8  G_1000_9  G_2000_5  G_2000_6  G_2000_7	G_2000_8  G_2000_9  G_3000_5  G_3000_6	G_3000_7  G_3000_8  G_3000_9
# 0.726437  0.726437  0.726437  0.726437  0.726437  0.719048  0.719048  0.719048	0.719048  0.719048  0.716399  0.716399	0.716399  0.716399  0.716399
# 0.950000  0.950000  0.950000  0.950000  0.950000  0.912500  0.912500  0.912500	0.912500  0.912500  0.900000  0.900000	0.900000  0.900000  0.900000
# 0.605153  0.604384  0.605155  0.605402  0.605060  0.610530  0.609579  0.607699	0.609209  0.609546  0.609402  0.609857	0.611355  0.610720  0.611713
# 0.426346  0.426346  0.426346  0.426346  0.426346  0.426930  0.426930  0.426930	0.426930  0.426930  0.429377  0.429377	0.429377  0.429377  0.429377
# 0.513432  0.513432  0.513432  0.513432  0.513432  0.512818  0.512818  0.512818	0.512818  0.512818  0.517337  0.517337	0.517337  0.517337  0.517337
# 0.390521  0.390521  0.390521  0.390521  0.390521  0.414775  0.414775  0.414775	0.414775  0.414775  0.422341  0.422341	0.422341  0.422341  0.422341
# 0.488514  0.488514  0.488514  0.488514  0.488514  0.496372  0.496372  0.496372	0.496372  0.496372  0.498824  0.498824	0.498824  0.498824  0.498824
# 0.544306  0.544306  0.544306  0.544306  0.544306  0.567036  0.567036  0.567036	0.567036  0.567036  0.555015  0.555015	0.555015  0.555015  0.555015
# 0.555136  0.555136  0.555136  0.555136  0.555136  0.562495  0.562495  0.562495	0.562495  0.562495  0.557018  0.557018	0.557018  0.557018  0.557018
# 0.481364  0.481364  0.481364  0.481364  0.481364  0.486889  0.486889  0.486889	0.486889  0.486889  0.475850  0.475850	0.475850  0.475850  0.475850
# 0.644622  0.644622  0.644622  0.644622  0.644622  0.647653  0.647653  0.647653	0.647653  0.647653  0.639149  0.639149	0.639149  0.639149  0.639149
# 0.361593  0.361593  0.361593  0.361593  0.361593  0.367026  0.367026  0.367026	0.367026  0.367026  0.375644  0.375644	0.375644  0.375644  0.375644
# 0.047018  0.047018  0.047018  0.047018  0.047018  0.047018  0.047018  0.047018	0.047018  0.047018  0.047130  0.047130	0.047130  0.047130  0.047130

# TARGET: Either MEGATAB_Spearman or MEGATAB_Pearson
MEGATAB_%:
	make tabulate_$*_bvgnFull_extrinsic_test && \
	make tabulate_$*_bitext_extrinsic_test_300_7000_1e-8_logCount.300 && \
	make tabulate_$*_monotext_extrinsic_test_v2_gcca_run_sans_mu_300_7000_1e-8_logCount && \
	make tabulate_$*_fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount && \
	make tabulate_$*_other_extrinsic_test_glove.42B.300d && \
	make tabulate_$*_other_extrinsic_test_glove.6B.300d 

TABCMD = cat $$F | sed "s%original embedding%O%g" | sed "s%The EN_TOM_ICLR13_S\([EY]\)\([MN]\) dataset score over \([0-9A-Za-z_-]*\) \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The EN_TOM_ICLR13_S\1\2 $$corrtype score over \3 (\5 out of \4) is \7%g" | sed "s%The TOEFL score over \([0-9A-Za-z_-]*\) with bare \[\([0-9]*\), \([0-9]*\), \([0-9]*\)\] is \([0-9.]*\)%The TOEFL $$corrtype score over \1 (\3 out of \2) is \5%g" | sed "s%The $$corrtype Corr over \([0-9A-Za-z_-]*\) is%The JURI $$corrtype correlation over \1 (0 out of 0) is%g" | grep -E "The .* $$corrtype "  | awk '{printf "%s %s out of %s \t %s \t %s\n", $$2, $$7, $$10, $$6, $$NF}' | python src/tabulation_script.py
tabulate_Spearman_%: log/%
	export F=log/$* && export corrtype=Spearman && $(TABCMD) $*
tabulate_Pearson_%: log/%
	export F=log/$* && export corrtype=Pearson && $(TABCMD) $*

##################################
#### GRID RUN CODE
##################################
MEGA_BIG_LOOP:
	for reg in 5 6 7 8 9; do \
	  for b in 1000 2000 3000; do\
	    $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_"$$b"_1e-"$$reg"_logCount; \
	  done ; \
	  $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v3_stgcca_run_sans_mu_300_1e-"$$reg"_logCount; \
	done
V4_MEGA_LOOP:
	for i in 5 6 7 8 9; do $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v4_stgcca_run_sans_mu_300_1e-"$$i"_logCount ; done

# TARGET: this creates things like
#       /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_logCount.mat 
#       /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat
# SOURCE: this uses things like
#       /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_Count.mat 
# This takes roughly 8 hours for 6 files.
# I can experiment with 300_10000 (and higher) or 500_1000 (or higher)
v%_submit_gcca_run_sans_mu_to_grid:  
	    $(QSUBPEMAKE) $(STORE2)/v$*_gcca_run_sans_mu_300_7000_1e-8_logCount
submit_gcca_run_sans_mu_to_grid: 
	for transform in Count logCount; \
	    do $(QSUBPEMAKE) $(STORE2)/gcca_run_sans_mu_300_7000_1e-8_"$$transform" ; done

# TARGET: A way to submit bitext_svd_%.mat jobs to the grid
submit_bitextsvd_to_grid_%:
	for lang in $(BIG_LANG); do for preproc in $(PREPROCESS_OPT); do $(QSUBPEMAKE) $(STORE2)/bitext_svd_"$$lang"_$*_"$$preproc".mat; done; done
# This example should make the final result of running this target clear
# qsub -V -j y -l mem_free=5G -r yes  -pe smp 25 -cwd submit_grid_stub.sh /export/a14/prastog3/monotext_svd_en_5_logCount-truncatele60.mat
# This job takes two hours for making trunc=20 file.
submit_monotextsvd_to_grid:
	for trunc in 60 40 20; do $(QSUBPEMAKE) $(STORE2)/monotext_svd_en_500_logCount-truncatele"$$trunc".mat; done


# TARGET: Mean centered SVD mat files
MEAN_CENTERED_SVD_LOOP:
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_ar_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_cs_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_de_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_es_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_fr_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bitext_mean_centered_svd_zh_500_logCount.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/monotext_mean_centered_svd_en_500_logCount-truncatele20.mat &&\
	$(QSUBPEMAKE) /export/a14/prastog3/monotext_mean_centered_svd_en_500_logCount-truncatele60.mat && \
	$(QSUBPEMAKE) /export/a14/prastog3/bvgn_mean_centered_svd_embedding_500_Count.mat

NEWFANGLED_CAP:
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_300~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_800~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_1000~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele40_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele60_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCount-truncatele80_500~stgcca,300_1e-8.300
TOFANGLE_CAP:
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_Count-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_CountPow075-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_CountPow050-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_CountPow025-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logCountPow075-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_Freq-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow012-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow025-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow025-truncatele200_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow050-truncatele200_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_FreqPow075-truncatele20_500~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_muc_logFreq-truncatele20_500~stgcca,300_1e-8.300

MC_FANGLE_CAP: # 7975796  7975797  7975798
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele600_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele400_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele600_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele400_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele600_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele400_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele600_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele400_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_logFreq-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele600_50~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_log1pFreq-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_FreqPow025-truncatele200_100~stgcca,300_1e-8.300 && \
	$(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_mc_FreqPow050-truncatele200_100~stgcca,300_1e-8.300

NO_FANGLE_CAP:
	for d2rm in stgccanoar stgccanocs stgccanode stgccanoes stgccanofr stgccanozh stgccanoen stgccanobvgn; do \
	  for meanchoice in mc muc; do \
	     $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_"$$meanchoice"_logCount-truncatele200_100~"$$d2rm",300_1e-8.300 ; \
	done; done

COMPARE_FANGLE_CAP:
	do for meanchoice in mc muc; do for preproc in logCount logFreq log1pFreq FreqPow025 FreqPow050; do\
	  $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_"$$meanchoice"_"$$preproc"-truncatele200_100~stgccanoenbvgn,300_1e-8.300 ; \
	done; done
ONLY_FANGLE_CAP: # 8003506  8003507  8003508  8003509  8003510  8003512  8003513  8003517  8003518  8003519 
	for meanchoice in mc muc; do for preproc in logCount logFreq log1pFreq FreqPow025 FreqPow050; do\
	  $(QSUBPEMAKE) log/fullgcca_extrinsic_test_v5_embedding_"$$meanchoice"_"$$preproc"-truncatele200_100~stgccaonlyen,100_1e-8.100 ; \
	done; done
###############
## EVAL CODE
###############
# TARGET: log/bitext_extrinsic_test_300_7000_1e-8_logCount.150 log/bitext_extrinsic_test_300_7000_1e-8_Count.150
# This is basically doing CCA with resulting 150 dimensions over the original gn embeddings and the GCCA embeddings.
# The results are basically how well these embeddings work to predict the human similarity judgements.
# And there are 4 types of embeddings
# original embeddings : the bvgn embeddings
# G : the basic GCCA embeddings
# U : The bvgn embeddings projected after doing CCA between bvgn and G
# V : The G embeddings projected after doing CCA between bvgn and G
# This target is pretty quick to make.
# log/fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount.300
# log/fullgcca_extrinsic_test_v3_stgcca_run_sans_mu_300_1e-8_logCount.300
# log/fullgcca_extrinsic_test_v4_stgcca_run_sans_mu_300_1e-8_logCount.300 # Your job 7869124
# make -n log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele2000_1000~gcca,300_1e-8_1000.300
# make -n log/fullgcca_extrinsic_test_v5_embedding_mc_logCount-truncatele2000_1000~stgcca,300_1e-8.300
# mc : mean center, muc : mean uncentered
# logCount-truncatele2000 : truncate all less than 20
# 1000 : the original svd size
# gcca : Original gcca code, stgcca : the spacetime efficient gcca code
# 300_1e-8_1000 : the gcca parameters(gcca embedding size, reg_size, batch column size), 300_1e-8 : the stgcca parameters
# 300 the final gcca embeddings which would be used for evaluataion.
# SOURCE : This job runs from start to stop. I have to set up the data
# file, then take SVD, then store it into a single cell, then take
# gcca, then perform test upon it.
# SOURCE: big_vocabcount_en_intersect_gn_embedding which is the gn embeddings intersected with big_vocab that was made from 6 bitext files.
#         300_7000_1e-8_logCount are basically Hyper parameters that were used while creating the GCCA embeddings.
EXTRINSIC_TEST_CMD = "word=textread('$(word 1,$+)', '%s'); load('$(word 2,$+)'); load('$(word 3,$+)'); if size(G, 1) < size(G, 2); G=G'; end; sort_idx=sort_idx'; word=word(sort_idx); bvgn_count=bvgn_count(sort_idx); bvgn_embedding=bvgn_embedding(sort_idx,:); domikolov=1; bitext_true_extrinsic_test(G, bvgn_embedding, $(MYOPT), word, domikolov); exit;"
EXTRINSIC_TEST_DEP1 = $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat
log/fullgcca_extrinsic_test_%: 
	$(MAKE) TARGET=$@ MYOPT=$(word 2,$(subst ., ,$*)) MYDEP="$(EXTRINSIC_TEST_DEP1) $(STORE2)/$(word 1,$(subst ., ,$*)).mat" gcca_extrinsic_test_generic
gcca_extrinsic_test_generic: $(MYDEP)
	$(MATCMDENV)$(EXTRINSIC_TEST_CMD) | tee $(TARGET)
###### OTHER TEST  
# TARGET: a log file with all the test results.
# SOURCE: $(STORE2)/glove.6B.300d.mat (glove.42B etc.)
log/other_extrinsic_test_%:  $(STORE2)/%.mat
	$(MATCMDENV)"tic; load('$(word 1,$+)'); emb=normalize_embedding(emb); conduct_extrinsic_test_impl(emb, id, word); fprintf(1, 'Total time taken %d\n', toc); exit;" | tee $@

####### MIKOLOV TEST
# Target: Basically this tests my word pruned version of the mikolov
# embeddings. I wanted to check whether my version of mikolov
# embeddings was flawed because they were not reaching the desired
# level of accuracy. So I tested both my version and the Full version
# on the test which was certified to be doing the correct thing at
# least for the Mikolov-Analogy task (because it worked for glove embeddings)
# bvgnPrunedppdb took only 1 hour
# bvgnFull took 5 hours.
log/%_extrinsic_test:
	if [ $* == bvgnPrunedppdb ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat" SECOND_DEP_IS_MAT=1 MYTAG=bvgnPrunedppdb mikolov_generic_test ; \
	elif [ $* == bvgnFull ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE)/gn300_word.txt $(STORE)/gn300.txt" SECOND_DEP_IS_MAT=0 MYTAG=bvgnFull HEADERLINES=1 mikolov_generic_test ; \B
	elif [ $* == word2vecBitext ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE2)/word2vec_embedding_file_word $(STORE2)/word2vec_embedding_file" SECOND_DEP_IS_MAT=0 MYTAG=word2vecBitext HEADERLINES=1  mikolov_generic_test ; \
	elif [ $* == gloveBitext ]; then \
	  $(MAKE) TARGET=$@ MYDEP="$(STORE2)/glove_embedding_file.txt_word $(STORE2)/glove_embedding_file.txt" SECOND_DEP_IS_MAT=0 MYTAG=gloveBitext  HEADERLINES=0 mikolov_generic_test ; \
	else echo "unimplemented extrinsic_test type $*"; false; fi

mikolov_generic_test: $(MYDEP)
	$(MATCMDENV)"tic; if $(SECOND_DEP_IS_MAT)==1 load('$(word 2,$(MYDEP))'); word=textread('$(word 1,$(MYDEP))', '%s'); emb=normalize_embedding(bvgn_embedding); else word=textread('$(word 1,$(MYDEP))', '%s', 'headerlines', $(HEADERLINES)); emb=dlmread('$(word 2,$(MYDEP))', '', $(HEADERLINES), 1); end; conduct_extrinsic_test_impl(emb, '$(MYTAG)', word); fprintf(1, 'Total time taken %f seconds\n', toc); exit;" | tee $(TARGET)

# This code could be sped up.
# but anyway the problem is that it did not print the required information even after finishing.
log/eval_bvgn_using_word2vec_code_for_analogy_task: # Your job 7696236 (8 hours)
	$(WORD2VECDIR)/compute-accuracy /export/a15/prastog3/GoogleNews-vectors-negative300.bin < /home/prastog3/projects/mvppdb/res/word_sim/EN-TOM-ICLR13-SEM.txt > $@ && $(WORD2VECDIR)/compute-accuracy /export/a15/prastog3/GoogleNews-vectors-negative300.bin < /home/prastog3/projects/mvppdb/res/word_sim/EN-TOM-ICLR13-SEM.txt >> $@

run_glove_and_word2vec : Your job 7972791 7972792
	qsub -V -j y -l mem_free=40G -r yes  -pe smp 10 -cwd submit_grid_stub.sh $(STORE2)/glove_embedding_file && qsub -V -j y -l mem_free=20G -r yes -pe smp 20 -cwd submit_grid_stub.sh $(STORE2)/word2vec_embedding_file
$(STORE2)/glove_embedding_file: $(STORE2)/glove_cooccurence_shuf_file $(STORE2)/glove_vocab_file
	$(GLOVEDIR)/glove -save-file $@ -threads 10 -input-file $< -x-max 100 -iter 15 -vector-size 300 -binary 2 -vocab-file $(word 2,$+) -verbose 2 -model 0
$(STORE2)/glove_cooccurence_shuf_file: $(STORE2)/glove_cooccurence_file
	$(GLOVEDIR)/shuffle -memory 40 -verbose 2 < $< > $@
$(STORE2)/glove_cooccurence_file: $(STORE2)/glove_vocab_file $(STORE2)/only_english_from_ppdb_input
	$(GLOVEDIR)/cooccur -memory 40 -vocab-file $< -verbose 2 -window-size 10 < $(word 2,$+) > $@
$(STORE2)/glove_vocab_file: $(STORE2)/only_english_from_ppdb_input
	$(GLOVEDIR)/vocab_count -min-count 100 -verbose 2 < $< > $@
$(STORE2)/word2vec_embedding_file: $(STORE2)/only_english_from_ppdb_input
	$(WORD2VECDIR)/word2vec -train $< -size 300 -window 10 -hs 0 -negative 15 -threads 20 -min-count 100 -output $@ -dumpcv $@_context
#####################
## GCCA Running Code
#####################
# TARGET: A Typical run would 300_1000_1e-8 (300 is the number of
# principal vectors, 1000 is the batch size, (higher is better))
# Or v3_stgcca_run_sans_mu_300_1e-8_logCount.mat
# Or $STORE2/v4_stgcca_run_sans_mu_300_1e-8_logCount.mat
# SOURCE : A mat file containing S, B, Mu1, Mu2 which contain the
# arabic, chinese, english bitext data 
GCCA_RUN_SANS_MU_CMD = $(MATCMD)"options=strsplit('$*', '_'); r=str2num(options{1}); b=str2num(options{2}); load $<;svd_reg_seq=str2num(options{3})*ones(size(S)); [G, S_tilde, sort_idx]=se_gcca(S, B, r, b, svd_reg_seq); tic; save('$@', 'G', 'S_tilde', 'sort_idx'); toc; exit; "
STE_GCCA_SANS_MU_CMD = $(MATCMD)"options=strsplit('$*', '_'); r=str2num(options{1}); load $<; svd_reg_seq=str2num(options{2})*ones(size(S)); [G, S_tilde, sort_idx]=ste_rgcca(S, B, r, svd_reg_seq); tic; save('$@', 'G', 'S_tilde', 'sort_idx'); toc; exit; "
GCCA_OR_ST_EXTRACTOR = $(word 1,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
GCCA_OPT_EXTRACTOR = $(word 2,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
MONOMULTIWINDOW_DEP_OPT_EXTRACTOR = $(word 3,$(subst $(COMMA), ,$(word 2,$(subst ~, ,$*))))
V56_EMBEDDING_CMD1 = TARGET=$@ V5_GCCA_OPT=$(GCCA_OPT_EXTRACTOR) GCCA_OR_ST=$(GCCA_OR_ST_EXTRACTOR) V56_GENERIC_DEP=
V56_EMBEDDING_CMD2 = DATASET_TO_KEEP=`python src/calculate_index_of_dataset_to_keep.py $(GCCA_OR_ST_EXTRACTOR)` v5_generic 
$(STORE2)/v5_embedding_%.mat:
	if [ "$(MONOMULTIWINDOW_DEP_OPT_EXTRACTOR)" == "monomultiwindow" ] ; then \
	    $(MAKE) $(V56_EMBEDDING_CMD1)"$(STORE2)/monomultiwindow_cell_input_$(word 1,$(subst ~, ,$*)).mat" $(V56_EMBEDDING_CMD2) ; \
	elif [ "$(MONOMULTIWINDOW_DEP_OPT_EXTRACTOR)" == "" ] ; then \
	    $(MAKE) $(V56_EMBEDDING_CMD1)"$(STORE2)/v5_cell_input_$(word 1,$(subst ~, ,$*)).mat" $(V56_EMBEDDING_CMD2) ; \
	else \
	    echo $* && exit 1 ; \
	fi;

V5_GENERIC_CMD1 = "options=strsplit('$(V5_GCCA_OPT)', '_'); r=str2num(options{1}); load $(word 1,$(V56_GENERIC_DEP)); svd_reg_seq=str2num(options{2})*ones(size(S)); "
V5_GENERIC_CMD2 = "tic; save('$(TARGET)', 'G', 'S_tilde', 'sort_idx'); toc; exit; "
v5_generic: $(V56_GENERIC_DEP)
ifeq ($(findstring stgcca,$(GCCA_OR_ST)),stgcca)
	$(MATCMD)$(V5_GENERIC_CMD1)"[G, S_tilde, sort_idx]=ste_rgcca(S([$(DATASET_TO_KEEP)]), B([$(DATASET_TO_KEEP)]), r, svd_reg_seq); "$(V5_GENERIC_CMD2)
else
	$(MATCMD)$(V5_GENERIC_CMD1)" [G, S_tilde, sort_idx]=se_gcca(S([$(DATASET_TO_KEEP)]), B([$(DATASET_TO_KEEP)]), r, str2num(options{3}), svd_reg_seq); "$(V5_GENERIC_CMD2)
endif

$(STORE2)/v4_stgcca_run_sans_mu_%_logCount.mat: $(STORE2)/v4_gcca_input_svd_already_done_500_logCount.mat
	$(STE_GCCA_SANS_MU_CMD)
$(STORE2)/v3_stgcca_run_sans_mu_%_logCount.mat: $(STORE2)/v3_gcca_input_svd_already_done_500_logCount.mat
	$(STE_GCCA_SANS_MU_CMD)
$(STORE2)/v3_gcca_run_sans_mu_%_logCount.mat: $(STORE2)/v3_gcca_input_svd_already_done_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/v2_gcca_run_sans_mu_%_logCount.mat: $(STORE2)/v2_gcca_input_svd_already_done_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/gcca_run_sans_mu_%_logCount.mat: $(STORE2)/gcca_input_svd_already_done_500_logCount.mat
	$(GCCA_RUN_SANS_MU_CMD)
$(STORE2)/gcca_run_sans_mu_%_Count.mat: $(STORE2)/gcca_input_svd_already_done_500_Count.mat
	$(GCCA_RUN_SANS_MU_CMD)

# SOURCE: A small test file to practice doing se_gcca.
test_gcca_run: res/tmp_bitext_svd.mat
	$(MATCMD)"load $<; S={s}; B={b}; [G, S_tilde]=se_gcca(S, B, 10, 2, [1e-8]); U_tilde=S'; exit;"


# TARGET: A single mat file containing S, B
# cell. Currently only three targets exist 
# gcca_input_svd_already_done_2.mat
# gcca_input_svd_already_done_500_Count.mat
# gcca_input_svd_already_done_500_logCount.mat
# Also note that v2 differs from the unversioned one only wrt to
# whether it uses the monolingual cooccurence statistics or not. 
# In the most basica sense I just need to get as input the singular
# vectors of a view after that my code takes the GCCA. (which is in
# se_gcca.m) 
# SOURCE: GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP referes to
# $(STORE2)/bitext_svd_fr/cs_500.mat (500 means the dimensionality of
# the SVD result) 
# Then all those are put into a single cell called S and B
# It calls on the the following files.
# bitext_svd_ar_500_Count.mat                    bitext_svd_ar_500_logCount.mat
# bitext_svd_cs_500_Count.mat                    bitext_svd_cs_500_logCount.mat
# muc is mean uncentered. so if we have muc then mean uncentered svd is used.
GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP = $(foreach lang,$(BIG_LANG),$(STORE2)/bitext_svd_$(lang)_%.mat)
GCCA_INPUT_TODO = $(patsubst %,load %; B=[B b]; S=[S s]; whos;,$+)
GCCA_INPUT_SVD_ALREADY_DONE_CMD = $(MATCMD)"tic; S={}; B={}; $(GCCA_INPUT_TODO) save('$@', 'S', 'B', '-v7.3'); toc; exit;"
V5_SVD_DEP = $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) $(STORE2)/monotext_svd_en_%.mat $(STORE2)/bvgn_svd_embedding_%.mat
MONOMULTIWINDOW_SVD_DEP = $(V5_SVD_DEP) $(STORE2)/monotext10_svd_en_%.mat $(STORE2)/monotext12_svd_en_%.mat $(STORE2)/monotext14_svd_en_%.mat $(STORE2)/monotext15_svd_en_%.mat 
$(STORE2)/monomultiwindow_cell_input_%.mat: $(subst $(STORE2)/,$(STORE2)/v5_indisvd_,$(MONOMULTIWINDOW_SVD_DEP))
ifeq ($(wildcard tmptouchfile_$(@F)),"")
	echo $(@F) && qsub -hold_jid $(call join-with,$(COMMA),$(+F)) -cwd submit_grid_stub.sh tmptouchfile_$(@F) && while [ ! -f tmptouchfile_$(@F) ] ; do sleep 300 ;done &&  $(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
else
	echo $(@F) && $(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
endif

$(STORE2)/v5_cell_input_%.mat: $(subst $(STORE2)/,$(STORE2)/v5_indisvd_,$(V5_SVD_DEP))
ifeq ($(wildcard tmptouchfile_$(@F)),"")
	echo $(@F) && qsub -hold_jid $(call join-with,$(COMMA),$(+F)) -cwd submit_grid_stub.sh tmptouchfile_$(@F) && while [ ! -f tmptouchfile_$(@F) ] ; do sleep 300 ;done &&  $(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
else
	echo $(@F) && $(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
endif

tmptouchfile_%:
	touch $@
$(STORE2)/v4_gcca_input_svd_already_done_%.mat: $(subst _svd_,_mean_centered_svd_,$(V3_SVD_DEP))
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
#TARGET: v3_gcca_input_svd_already_done_500_logCount.mat. This
#       contains data from mikolov's embeddings as well as data from
#       bitext and bitext-monolingual-part-window3 source
V3_SVD_DEP = $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) $(STORE2)/monotext_svd_en_%-truncatele20.mat $(STORE2)/bvgn_svd_embedding_500_Count.mat
$(STORE2)/v3_gcca_input_svd_already_done_%.mat: $(V3_SVD_DEP)
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
$(STORE2)/v2_gcca_input_svd_already_done_%.mat: $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP) $(STORE2)/monotext_svd_en_%-truncatele20.mat 
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)
$(STORE2)/gcca_input_svd_already_done_%.mat: $(GCCA_INPUT_SVD_ALREADY_DONE_MAT_DEP)
	$(GCCA_INPUT_SVD_ALREADY_DONE_CMD)

########################################
### SVD RUNNING CODE (OVER RAW DATA)
#######################################
$(STORE2)/v5_indisvd_%.mat:
	qsub -N $(@F) -p -1 -V -j y -l mem_free=25G -r yes -pe smp 10 -cwd submit_grid_stub.sh $(STORE2)/v5_indisvd_"$*".impl
$(STORE2)/v5_indisvd_%.impl:
	$(MATCMD)"optstr='$*'; options=strsplit(optstr, '_'); dtype=options{1}; lang=options{3}; mc_muc=options{4}; preprocess_option=options{5}; svd_size=str2num(options{6}); outfile='$(word 1,$(subst ., ,$@)).mat'; outdirname='$(@D)'; lif=larger_indisvd_filename(outdirname, outfile, optstr, options{6}); if isempty(lif) [b,s]=v5_indisvd(dtype, lang, mc_muc, preprocess_option, svd_size, '$(STORE2)'); else load(lif); s=s(1:svd_size); b=b(:,1:svd_size); end; save(outfile, 's', 'b'); exit;"

###################################################
########### THESE PORTIONS ARE DEPRECATED 
TAKE_SVD_CMD_PART1 = $(MATCMD)"options=strsplit('$*', '_'); lang=options{1}; svd_size=str2num(options{2}); preprocess_option=options{3}; tic; load(['$(STORE2)/"
TAKE_SVD_CMD_PART2 = "_',lang,'.mat']); if ~exist('align_mat'); align_mat=bvgn_embedding; end; disp(size(align_mat)); [align_mat, mu1, mu2]=preprocess_align_mat(align_mat,preprocess_option); disp(size(align_mat)); disp('preprocessing complete'); [b, s]=svds(align_mat, svd_size); s=transpose(diag(s)); clear('align_mat', 'lang', 'preprocess_option', 'options', 'svd_size'); whos; toc; save('$@', 's', 'b', 'mu1', 'mu2'); exit;"
TAKE_MEAN_CENTERED_SVD_CMD = "_',lang,'.mat']); if ~exist('align_mat'); align_mat=bvgn_embedding; end; disp(size(align_mat)); [align_mat, mu1, mu2]=preprocess_align_mat(align_mat,preprocess_option); disp(size(align_mat)); disp('preprocessing complete'); [b, s, a]=svds(align_mat, svd_size); [b, s, a]=rank_one_svd_update(b, s, a, -1*ones(size(align_mat, 1), 1), mu1', 0); s=diag(s); save('$@', 's', 'b', 'mu1', 'mu2'); exit;"
$(STORE2)/bitext_mean_centered_svd_%.mat:  $(BIG_ALIGN_MAT)
	$(TAKE_SVD_CMD_PART1)"align"$(TAKE_MEAN_CENTERED_SVD_CMD)
$(STORE2)/monotext_mean_centered_svd_%.mat: $(STORE2)/cooccur_en.mat
	$(TAKE_SVD_CMD_PART1)"cooccur"$(TAKE_MEAN_CENTERED_SVD_CMD)
$(STORE2)/bvgn_mean_centered_svd_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat 
	$(TAKE_SVD_CMD_PART1)"big_vocabcount_en_intersect_gn"$(TAKE_MEAN_CENTERED_SVD_CMD)
# TARGET: Results of taking their SVD stored in individual files like
# bitext_svd_es_500_logCount.mat
# Note that monotext svd is doing exactly the same thing but over the
# monolingual cooccurence statistics.
# However we also need to truncate the matrix because of computational considerations.
# So we would create monotext_svd_en_500_logCount-truncatele20.mat
# SOURCE: 1. The mat file with google embeddings.
#         2. 6 mat files with sparse array denoting alignments to different languages
$(STORE2)/bitext_svd_%.mat:  $(BIG_ALIGN_MAT)
	$(TAKE_SVD_CMD_PART1)"align"$(TAKE_SVD_CMD_PART2)
$(STORE2)/monotext_svd_%.mat : $(STORE2)/cooccur_en.mat
	$(TAKE_SVD_CMD_PART1)"cooccur"$(TAKE_SVD_CMD_PART2)
# TARGET: This creates a file that contains the SVD of the bvgn embeddings.
# 	 We call $STORE2/bvgn_svd_embedding_500_Count
$(STORE2)/bvgn_svd_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat 
	$(TAKE_SVD_CMD_PART1)"big_vocabcount_en_intersect_gn"$(TAKE_SVD_CMD_PART2)
############## ABOVE CODE IS DEPRECATED

# SOURCE: All of the vocabulary files.
# TARGET: A sparse matrix of english co-occurence counts.
# This took 1hour 16 minutes for the first half. and 30 minutes for second
## Make the sparse cooccurence matrix of english. using the full
# vocabulary. In fact dont even need to store in memory just write to
# file all the time. I would once again have to use  sort -n | uniq -c
# trick because the data is gonna be large and I would be doing append
# only
# src/create_cooccurence_matrix takes
# 1. Size of vocabulary file
# 2. Name of vocabulary file
# 3. The input file name
# 4. The number of sentences in input file
# 5. The window size
# 6. The number of threads that would run.
# 7. the name of filename to append data to.
# I create #thread number of files and append to them separately instead of worrying about concurrency.
# id_word id_contextword 1 signed_distance (- if on left and + if right)
# 13994 131134 -1
# 13994 2623 1
# 2623 13994 0
# 641 8 6
# 8 641 5
# time python src/print_cooccurence_rows.py 131133 /export/a14/prastog3/big_vocabcount_en_intersect_gn_embedding_word /export/a14/prastog3/only_english_from_ppdb_input 63789996 1 63789900 3189499 tmptmp 2>> /dev/null
# A=fread(fopen('tmp_cooccur_en_1.mat_0'), 'int32'); A=reshape(A, 3, length(A)/3); A=A'; A(:,3)=1./abs(A(:,3));
# This process takes 30G of memory only. (at max it took 29G)
run_cooccurence_on_grid_%: 
	qsub -V -j y -l mem_free=30G -l h_vmem=40G -l hostname=a15 -r yes -cwd submit_grid_stub.sh $(STORE2)/cooccur_en_$*.mat
# When things went bad because of the last file i manually fized by this code.
# load /export/a15/prastog3/cooccur_en_15.mat
# dimarr=[size(align_mat) 0]; window_size=15; input_file={'/export/a15/prastog3/tmpfine_6000000ah'};i=1;
# A=fread(fopen(input_file{i}), [3, Inf], '*int32'); A=A'; A(A(:,3)>window_size | A(:,3)<-window_size,:)=[];   A=double(A);
# A(end+1,:)=A(1,:);
# A(1,:)=dimarr;
# A(2:end,3) = 1./abs(A(2:end, 3));
# align_mat=align_mat+spconvert(A);save('/export/a15/prastog3/cooccur_en_15.mat', 'align_mat', '-v7.3');
SENTENCE_COUNT := 63789996
INCREMENT := 500000
VOCAB := 131133
max = if [ $1 -ge $2 ] ; then echo $1; else echo $2; fi
$(STORE2)/cooccur_en_%.mat: # MYDEP should be "$(shell seq -f '$(STORE)/tmpslice_cooccur_en_$(shell $(call max,$*,15))_%0.f' 0 $(INCREMENT) $(SENTENCE_COUNT))"
	$(MAKE) TARGET=$@ VOCAB=$(VOCAB) WINDOW_SIZE=$* SENTENCE_COUNT=$(SENTENCE_COUNT) INCREMENT=$(INCREMENT) MIN_LENGTH_SENTENCE=3 MYDEP="$(wildcard $(STORE)/tmpfine_*)" cooccur_en_parallel_generic ;

cooccur_en_parallel_generic: $(MYDEP)
	echo "$+" > tmpfilelist_$(WINDOW_SIZE) && $(MATCMD)" align_mat=cooccur_en_parallel_generic(NaN, $(WINDOW_SIZE), strsplit(fileread('tmpfilelist_$(WINDOW_SIZE)'), ' '), NaN); save('$(TARGET)', 'align_mat', '-v7.3'); exit;"

$(STORE)/tmpslice_cooccur_en_%: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/only_english_from_ppdb_input
	pypy src/print_cooccurence_rows.py $(VOCAB) $< $(word 2,$+) $(SENTENCE_COUNT) $(WINDOW_SIZE)   $(word 2,$(subst _, ,$*)) $$INCREMENT $@ $(MIN_LENGTH_SENTENCE)

$(STORE2)/cooccur_en.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(BIG_INPUT)
	pypy src/create_sparse_cooccurmat.py $* $+ 1> tmp_cooccur 2> log/cooccur_en_$*.mat && \
	split -l5000000 tmp_cooccur _tmp && \
        for file in _tmp* ; do sort $FILE -o $FILE & done && \
        wait && \
        sort -m _tmp* | uniq -c > tmp_cooccur_en && \
	rm _tmp* && \
	python src/create_cooccur_en_mat.py tmp_cooccur_en ($$(wc -l $$STORE2/big_vocabcount_en_intersect_gn_embedding_word)) tmp_cooccur_en_spconvert_style 0 $* \
	matlab -r "[a,b,c]=textread('tmp_cooccur_en_spconvert_style', '%d %d %d'); align_mat=spconvert([a,b,c]); save('$@', 'align_mat'); exit;"

$(STORE2)/true_cooccur_en_%.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding_2column $(STORE2)/only_english_from_ppdb_input
	~/tools/glove/cooccur -verbose 2 -symmetric 1 -window-size $* -vocab-file $(word 1,$+) -memory 8.0 -overflow-file tmp_overflow < corpus.txt > $@.bin && ./res/convertvec bin2txt $@.bin  $@.txt && 

$(STORE2)/only_english_from_ppdb_input: $(BIG_INPUT)
	cat $+ | awk -F'|' '{print $$4}' > $@ 

# TARGET: Mat file which contains the google embeddings.
# bvgn means big vocab google news
$(STORE2)/big_vocabcount_en_intersect_gn_embedding.mat: $(STORE2)/big_vocabcount_en_intersect_gn_embedding
	$(MATCMD)"bvgn_embedding=dlmread('$<', '', 0, 1); bvgn_count=bvgn_embedding(:,1);bvgn_embedding=bvgn_embedding(:,2:size(bvgn_embedding,2)); save('$@', 'bvgn_embedding','bvgn_count');"


## 1. Check that the sparse matrix has the correct values. Manually check the result.  (Check using a smaller data file.) DONE
## For processing the french matrix I had to do the following. because of size
# numpy.asarray(idx_en_list).tofile("tmp_idx_en_list", sep="\n"); numpy.asarray(idx_fr_list).tofile("tmp_idx_fr_list", sep="\n")
## paste tmp_idx_en_list tmp_idx_fr_list |  sort -n | uniq -c > tmp_idx_cnt_en_fr
## arr=dlmread('tmp_idx_cnt_en_fr', '', 0, 0); align_mat=sparse(1+arr(:,2), 1+arr(:,3), arr(:,1)); save('/export/a14/prastog3/align_fr.mat', 'align_mat');
## The minimum of tmp_idx_en_list is 0
## The maximum of tmp_idx_en_list is 131132 (0 indexed since total are 131133)
## The minimum of tmp_idx_fr_list is 0
## The maximum of tmp_idx_fr_list is 2243100 (total are 2243101 so 0 indexed)

gridrun_align_mat:
	for targ in $(BIG_LANG); do $(QSUBMAKE) $(STORE2)/align_"$$targ".mat ; done 

# TARGET: A mat file with three variables 'emb' 'word' 'id'
# SOURCE: This takes 3 files as input.
# 	  1. A word file which provides the word to index mapping that must be followed while converting 
$(STORE2)/glove.%B.300d.mat: $(STORE2)/glove.%B.300d.txt_word $(STORE2)/glove.%B.300d.txt
	$(MATCMD)"tic; word=textread('$(word 1,$+)', '%s'); emb=dlmread('$(word 2,$+)', '', 0, 1); id='glove$*'; save('$@', 'emb', 'id', 'word', '-v7.3'); toc; exit;"

res/word_sim/simlex_simplified.txt: 
	awk '{if( NR > 1){print $$1, $$2, $$4}}' res/word_sim/SimLex-999.txt  > $@
# TARGET: The simplified outputs
# SOURCE: These are rare word and contextual word similarity datasets which need to simplified
res/word_sim/rw_simplified.txt: res/word_sim/rw.txt
	awk '{print $$1, $$2, $$3}' $+ > $@

res/word_sim/scws_simplified.txt: res/word_sim/scws.txt
	awk -F $$'\t' '{print $$2, $$4, $$8}' $+ > $@

# TARGET: sparse matrix encoding the alignment as a mat file
# SOURCE: 1. The vocabulary of the foreign language along with counts.
#	2. The embeddings for english words present in google and bitext
# 	3. The simplified file with alignments.
# Note that the word file is auto generated from the rule on top
$(STORE2)/align_%.mat: $(STORE2)/big_vocabcount_% $(STORE2)/big_vocabcount_en_intersect_gn_embedding_word $(STORE2)/ppdb-input-simplified-%
	time python src/create_sparse_alignmat.py $+ $@ 2> log/$(@F)

# TARGET : intersect big_vocabcount_en and google embedding
# 	Its a file with first column as the word,
#	second column is count in the source files.
#	third column onwards we have the embeddings.
# SOURCE : The google embedding and english big vocab
$(STORE2)/big_vocabcount_en_intersect_gn_embedding: $(STORE)/gn300.txt $(STORE2)/big_vocabcount_en
	python src/overlap_between_google_and_big_vocabcount.py $+ $@

# TARGET : A vocabulary of english created from the 6 files.
#          with counts of how many times the words occurred
#          And 6 vocabularies of the foreign languages
#          big_vocabcount_[en ar cs de es fr zh]
$(STORE2)/big_vocabcount_en : $(BIG_INPUT)
	pypy src/create_big_vocab.py $@ $+ 2> log/big_vocabcount

big_input: $(BIG_INPUT)

# TARGET: A simplified BIG_INPUT where all the english parses are converted to normal sentences.
$(STORE2)/ppdb-input-simplified-%: $(STORE2)/ppdb-input-%
	pypy src/remove_parse_from_english.py $^  $@

# TARGET: Single files each for a separater language
# This will take 22 files and convert them to 6 files fr es de cs ar zh
# Following are the 22 files that were concatenated.
# Gale, News Commentary, UN French, UN Spanish, Europarl, 10^9 French English
# 2.9G ccbword-fr-input-file-00
# 3.0G ccbword-fr-input-file-01
# 3.2G ccbword-fr-input-file-02
# 2.4G ccbword-fr-input-file-03
# 368M europarl-v7-cs-input-file-00
# 1.1G europarl-v7-de-input-file-00
# 1.1G europarl-v7-es-input-file-00
# 1.1G europarl-v7-fr-input-file-00
# 3.3G gale-ar-input-file-00
# 2.2G gale-ar-input-file-01
# 2.7G gale-zh-input-file-00
# 2.7G gale-zh-input-file-01
# 150M gale-zh-input-file-02
#  79M newscomm-cs-input-file-00
#  95M newscomm-de-input-file-00
#  87M newscomm-es-input-file-00
#  77M newscomm-fr-input-file-00
# 2.9G un-es-input-file-00
# 2.5G un-es-input-file-01
# 2.9G un-fr-input-file-00
# 2.9G un-fr-input-file-01
# 326M un-fr-input-file-02
$(STORE2)/ppdb-input-%:
	cat /home/juri/ppdb-input/*-$*-* > $@

align_europarlv1_%:
	java -jar /home/prastog3/tools/berkeleyaligner.jar  -trainSources /export/a15/prastog3/europarlv1/$*-en -foreignSuffix $* -englishSuffix en -execDir /export/a15/prastog3/europarlv1/$*-en-aligned  -saveParams false -numThreads 16 -msPerLine 10000 -alignTraining -create true -overwriteExecDir true

# MORE PREPROCESSING STUFF
# for file in *-en.aligned.tgz ; do tar -xzf $file ; done
# for corpus in de es fr ; do 
#     for file in $corpus-en/$corpus/* ; do mv $file $corpus-en/${file:9}.$corpus ; done && 
#     for file in $corpus-en/en/* ; do mv $file $corpus-en/${file:9}.en ; done ; 
# done
# rmdir de-en/de de-en/en es-en/es es-en/en fr-en/fr fr-en/en
/export/a15/prastog3/europarlv1/%-en.aligned.tgz:
	cd $(@D) && wget http://www.statmt.org/europarl/v1/$*-en.aligned.tgz && cd -

tabulate_extrinsic_test: log/extrinsic_test_s_0 log/extrinsic_test_l_0   log/extrinsic_test_s_1 log/extrinsic_test_l_1
	python src/tabulate_extrinsic_test.py $+

# TARGET: pr2xy means pushpendre to xuchen, ppdb_l and ppdb_s refer to
# the ppdb sizes used for doing CCA, word2vec contains the original
# embeddings that google provided. There are 82841 words in these
# files 
extrinsic_test: log/extrinsic_test_s_1 log/extrinsic_test_s_0 log/extrinsic_test_l_1 log/extrinsic_test_l_0

pr2xy: pr2xy_cca_ppdb_l_embedding.bin pr2xy_cca_ppdb_s_embedding.bin pr2xy_word2vec_embedding.bin

$(STORE)/pr2xy_%_embedding.bin: $(STORE)/pr2xy_%_embedding.txt
	./res/convertvec txt2bin $<  $@

# $(STORE)/pr2xy_word2vec_embedding.txt is also made automatically
# TARGET : Save the embeddings as a txt file.
$(STORE)/pr2xy_cca_ppdb_%_embedding.txt: $(STORE)/gn_intersect_ppdb_embeddings.mat 
	$(MATCMD)"load('$<'); word=textread('res/gn_intersect_ppdb_word', '%s'); ppdb_size='$*'; mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); dimension_after_cca=150; distance_method='cosine'; w2v_file_name='$(STORE)/pr2xy_word2vec_embedding.txt'; cca_file_name='$@'; save_embedding_to_txt_file;exit;"

# After all the previous experimentation now I am ready to pick a
# configuration and to do the pre and pos test on that particular
# confiugration. By looking at all the data I decided to use 150 as
# the optimal number of CCA dimensions to keep. By doing this I am
# doing a dimensionality reduction of exactly half which is great. 
# Note that the cosine distance does not do any mean centralization
# which is fine because the embeddings are any way mean centered.
# Also note that cosine distance does divide by the norm of the
# embeddings.
# So the settings are: 
# db = s l xxl
# Uniquify or not before CCA (For Baseline)
# # No longer I need knnK, dim2keep, doavgk. do_knn_only_over_original_embedding (because I do over both all the time), dist (dist = cosine)
# I also checked use_unique_mapping
# log/large_scale_cca_[sl]_cosine_1_0_0_1_170_1_[10]
#     large_scale_cca_[sl]_cosine_1_0_(170|90)_0_0_1_[10]
#     large_scale_cca_[sl]_cosine_1_1_0_0_0_1_[10]
log/extrinsic_test_%: $(STORE)/gn_intersect_ppdb_embeddings.mat res/filtered_paraphrase_list_wordnet.mat res/ppdb_paraphrase_rating_filtered.mat res/gn_intersect_ppdb_word # res/topvocablist.100000
	$(MATCMD)"load('$<'); load('$(word 2,$^)'); load('$(word 3,$^)'); word=textread('$(word 4,$^)', '%s'); options=strsplit('$*', '_'); ppdb_size=options{1}; use_unique_mapping=str2num(options{2}); mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); dimension_after_cca=150; distance_method='cosine'; conduct_extrinsic_test; exit;" | tee $@

res/ppdb_paraphrase_rating_filtered.mat: res/ppdb_paraphrase_rating
	$(MATCMD)"ppdb_paraphrase_rating=create_ppdb_paraphrase_rating('$<', textread('res/gn_intersect_ppdb_word', '%s')); save('$@', 'ppdb_paraphrase_rating'); exit;"

res/ppdb_paraphrase_rating: res/pred-scored-human-ppdb.txt
	python src/preprocess-pred-scored-human-ppdb.py $< | sort > $@

res/filtered_paraphrase_list_wordnet.mat: res/wordnet.test
	$(MATCMD)"golden_paraphrase_map=create_golden_paraphrase_map('$<', textread('res/gn_intersect_ppdb_word', '%s')); save('$@', 'golden_paraphrase_map'); exit;"

data_eyeball_%:
	$(MATCMD)"load('/export/a15/prastog3/gn_intersect_ppdb_embeddings.mat'); mapping=dlmread('res/gn_ppdb_lex_$*_paraphrase','', 0, 2); word=textread('res/gn_intersect_ppdb_word', '%s'); cd src; debug=1; data_eyeball; exit;"

log/gridrun_log_tabulate: log/gridrun 
	python src/gridrun_log_tabulate.py | tee $@

# These are jobs with changing ppdb size and whether I am using unique
# mapping or not. The basic purpose is to find out whether things work
# better or not ?
slapdash_14: 
	make log/large_scale_cca_l_cosine_1_0_0_1_170_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_1_1 && \
	make log/large_scale_cca_l_cosine_1_0_0_1_170_1_0 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_1_0 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_1_0 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_1_0 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_1_0 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_1_0 &&\
	make log/large_scale_cca_s_cosine_1_0_90_0_0_1_0 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_1_0

slapdash:
	make log/large_scale_cca_s_cosine_1_0_90_0_0_0_1 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_0_1 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_0_1 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_0_1 &&\
	make log/large_scale_cca_s_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_1_0_0_0_1_1 &&\
	make log/large_scale_cca_s_cosine_1_0_0_1_170_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_0_1 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_0_1 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_0_1 &&\
	make log/large_scale_cca_l_cosine_1_0_0_1_170_0_1 &&\
	make log/large_scale_cca_l_cosine_1_0_90_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_170_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_1_0_0_0_1_1 &&\
	make log/large_scale_cca_l_cosine_1_0_0_1_170_1_1 

log/gridrun:
	for db in s ; do \
	 for dist in cosine ; do \
	  for knnK in 1  ; do \
	   for uum in 0 1 ; do \
            for doavgk in 1 ; do\
	     for dim2keep in  90 170 ; do \
                $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_0_"$$dim2keep"_0_0_"$$uum"_"$$doavgk" -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_0_"$$dim2keep"_0_0_"$$uum"_"$$doavgk" ;\
             done;\
	     $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_1_0_0_0_"$$uum"_"$$doavgk" -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_1_0_0_0_"$$uum"_"$$doavgk" ; \
	     for dim2append in 170 ; do \
	        $(QSUBCMD) -N gridrun_"$$db"_"$$dist"_"$$knnK"_0_0_1_"$$dim2append"_"$$uum"_"$$doavgk" -cwd submit_grid_stub.sh "$$db"_"$$dist"_"$$knnK"_0_0_1_"$$dim2append"_"$$uum"_"$$doavgk" ;\
	     done;\
            done;\
	   done;\
	  done;\
	 done;\
	done 

# TARGET : Now do CCA over embeddings. The second file contains the
# mapping. Currently it has 660584 rows. There are 2 arrays each with
# 660584 rows and 300 columns. So the total memory requirement is
# 497,046,000 (doubles 8 Bytes) == 3GB. (4 GB for xxl) After running
# CCA. I get new embeddings and then I need to run KNN.

# EXAMPLE: $(STORE)/large_scale_cca_xxl_euclidean_1_10_1
# The first is size of ppdb, then the distance method then knnK then the
# dimensions to keep and then whether to do it over
# original embedding or the CCA ones. You only need to do CCA over
# original embeddings once. 
log/large_scale_cca_%: $(STORE)/gn_intersect_ppdb_embeddings.mat # res/gn_ppdb_lex_s_paraphrase res/gn_ppdb_lex_l_paraphrase res/gn_ppdb_lex_xl_paraphrase res/gn_ppdb_lex_xxl_paraphrase
	$(MATCMD)"load('$<'); options=strsplit('$*', '_'); ppdb_size=options{1}; distance_method=options{2}; knnK=str2num(options{3}); do_knn_only_over_original_embedding=str2num(options{4}); dimension_after_cca=str2num(options{5}); do_append=str2num(options{6}); dim2append=str2num(options{7}); use_unique_mapping=str2num(options{8}); do_average_knn=str2num(options{9}); mapping=dlmread(sprintf('res/gn_ppdb_lex_%s_paraphrase', ppdb_size),'', 0, 2); large_scale_cca; exit" | tee $@

# $(STORE)/gn_intersect_ppdb_embeddings.mat : $(STORE)/gn_intersect_ppdb_embeddings
# 	$(MATCMD)"embeddingdlmread('$<', ,'', 0, 1); save('$<.mat','embedding');exit;"

src/top.mexa64: src/top.cpp
	mex -o src/top.mexa64 src/top.cpp

# TARGET : Contains paraphrases for the words that were in SOURCE. The
# paraphrases themselves must also be in the SOURCE.
# The output file is source, index, paraphrase, index
# and the indexing starts with 1.
# The sampling scheme itself is coded in java. (I dont do uniform
# because I want to bring the information that PPDB is providing to
# the embeddings.)
res/gn_ppdb_lex_%_paraphrase: res/gn_intersect_ppdb_word 
	python src/get_paraphrase.py $< 10 $* > $@

# TARGET : Just the words from the gn_intersect_ppdb file
res/gn_intersect_ppdb_word: $(STORE)/gn_intersect_ppdb_embeddings
	awk '{print $$1}' $+ > $@

$(STORE)/gn_intersect_ppdb_embeddings : $(STORE)/gn_intersect_ppdb_embeddings.gz
	zcat $+ > $@

# TARGET : Contains embeddings of overlapping words in Google News
# Vectors and the PPDB lexical words. The first column is the
# word. currently the number of common words is 56870. zcat TARGET | wc -l
# In Both  82841
# In Google not in PPDB 2917159 (Skewed because contains phrases)
# In PPDB not in Google 42406
# PPDB has 125,247 words
# Google has 3 Million Phrases and roughly 300k words.
# This also builds res/in_google_not_in_ppdb res/in_ppdb_not_in_google
$(STORE)/gn_intersect_ppdb_embeddings.gz : $(STORE)/gn300.txt $(STORE)/PPDB_Lexical_Data/ppdb-1.0-xxxl-lexical-words-uniq 
	python src/overlap_between_google_and_ppdb.py $+ $@

# $(STORE)/gn300.txt.gz : $(STORE)/gn300.txt
# 	gzip -c $+ > $@

$(STORE)/gn300.txt: $(STORE)/GoogleNews-vectors-negative300.bin res/convertvec
	./res/convertvec bin2txt $<  $@ 

$(STORE)/GoogleNews-vectors-negative300.bin: $(STORE)/GoogleNews-vectors-negative300.bin.gz
	gunzip -c $< > $@

res/convertvec : src/convertvec.c
	$(CC) $+ -o $@ $(CFLAGS)

optimal_cca_dimension_table: optimal_cca_dimension.log
	awk '{if( (NR - 3)%13==0 || (NR - 5)%13==0 ||(NR - 6)%13==0 ||(NR - 8)%13==0){printf "%s  ", $$1} else if((NR - 11)%13==0 ){print $$0}}' $^ | tee $@

optimal_cca_dimension.log:
	for i in 1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70; do  make cca_over_rnnlm_knn_$$i | awk '{if(NR == 1 || NR > 34){print $$0}}' >> $@ ; done

cca_over_rnnlm_knn_%: res/rnnlm_synonym_embedding res/rnnlm_synonym_embedding_word
	$(MATCMD)"filename='res/rnnlm_synonym_embedding'; columns=1; dimension_after_cca=$*; cca_and_f_pushpendre ;exit"

cca_over_lsh_embeddings_%: res/ben_synonym_embedding res/ben_synonym_embedding_word
	$(MATCMD)"filename='res/ben_synonym_embedding'; columns= $*; dimension_after_cca=2; cca_and_f_pushpendre;exit"

## Random Embedding and Random partition Baselines. The purpose of
## these two sorts of experiments is always to find out what is the
## absolute baseline for the metric that you are using to test your
## technique. 
random_partition_rnnlm_cca.png: res/rnnlm_synonym_embedding res/rnnlm_synonym_embedding_word
	$(MATCMD);"filename='res/rnnlm_synonym_embedding'; columns=1; dimension_after_cca=2; random_embedding_cca;exit;"

random_embedding_cca.png:
	$(MATCMD)"filename='res/rnnlm_synonym_embedding'; columns=1; dimension_after_cca=2; random_embedding_cca;exit;"

##############################################################################################
# TARGET : This file contains synonyms on the even and odd lines like 1-2 and 3-4 are synonyms.
#          Its length is decided below.
# SOURCE : It uses the synonyms pairs and locations and the original embeddings file.
CMD2 = python src/properly_arrange_synonym_embedding_to_feed_matlab.py $+
res/ben_synonym_embedding: res/ben_synonym_pair_and_location res/ben_lsh_projection_of_rnnlm_vocab
	$(CMD2) explode > $@

res/rnnlm_synonym_embedding:  res/rnnlm_synonym_pair_and_location res/rnnlm_word_projection-80
	$(CMD2) > $@
###############################################################################################
# TARGET : Contains 1 pair of synonyms per line and their line location in the source file
# SOURCE : Table of embeddings where the first column is the word and the rest are the embedding.
CMD1 = python src/get_synonym_pair_and_location.py $+ 2>/dev/null | head -n 2000 > $@
res/ben_synonym_pair_and_location: res/ben_lsh_projection_of_rnnlm_vocab_word
	$(CMD1)
res/rnnlm_synonym_pair_and_location:  res/rnnlm_word_projection-80_word
	$(CMD1)
