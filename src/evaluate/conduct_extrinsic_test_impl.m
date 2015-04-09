function conduct_extrinsic_test_impl(U, id, word, ...
                                               do_analogy_test, ...
                                               evalres_folder,...
                                               verbose)
setenv('TOEFL_QUESTION_FILENAME'         , [evalres_folder 'toefl.qst']);
setenv('TOEFL_ANSWER_FILENAME'           , [evalres_folder 'toefl.ans']);
setenv('SCWS_FILENAME'                   , [evalres_folder 'scws_simplified.txt']);
setenv('RW_FILENAME'                     , [evalres_folder 'rw_simplified.txt']);
setenv('MEN_FILENAME'                    , [evalres_folder 'MEN.txt']);
setenv('EN_MC_30_FILENAME'               , [evalres_folder 'EN-MC-30.txt']);
setenv('EN_MTURK_287_FILENAME'           , [evalres_folder 'EN-MTurk-287.txt']);
setenv('EN_RG_65_FILENAME'               , [evalres_folder 'EN-RG-65.txt']);
setenv('EN_TOM_ICLR13_SEM_FILENAME'      , [evalres_folder 'EN-TOM-ICLR13-SEM.txt']);
setenv('EN_TOM_ICLR13_SYN_FILENAME'      , [evalres_folder 'EN-TOM-ICLR13-SYN.txt']);
setenv('EN_WS_353_REL_FILENAME'          , [evalres_folder 'EN-WS-353-REL.txt']);
setenv('EN_WS_353_SIM_FILENAME'          , [evalres_folder 'EN-WS-353-SIM.txt']);
setenv('EN_WS_353_ALL_FILENAME'          , [evalres_folder 'EN-WS-353-ALL.txt']);
setenv('WORDNET_TEST_FILENAME'           , [evalres_folder 'wordnet.test']);
setenv('PPDB_PARAPHRASE_RATING_FILENAME' , [evalres_folder 'ppdb_paraphrase_rating']);
setenv('SIMLEX_FILENAME'                 , [evalres_folder 'simlex_simplified.txt']);
%% Define accessors to embeddings given words.
word_map=containers.Map(word, 1:length(word));
get_emb=@(wrd) U(word_map(lower(wrd)), :);
%% Evaluate on Toefl test
[n_total, n_attempt, n_correct]=toefl_test_impl(word, get_emb, verbose);
fprintf(1, 'The TOEFL score over %s with bare [%d, %d, %d] is %f\n', ...
        id, n_total, n_attempt, n_correct, n_correct/n_total);
%% Find the score on SCWS, RW, MEN, MC_30, EN_MTURK_287, EN_RG_65, EN_WS_353_(ALL/REL/SIM)
for dataset={ 'SCWS', 'RW', 'MEN', 'EN_MC_30', 'EN_MTURK_287', 'EN_RG_65', ...
             'EN_WS_353_ALL', 'EN_WS_353_REL', 'EN_WS_353_SIM', 'SIMLEX' }
    dataset_fn=[dataset{1}, '_FILENAME'];
    disp(['Now working on ', dataset_fn]);
    [n_total, n_attempt, pred_simil, true_simil]=scws_test_impl(word, ...
                                                      get_emb, dataset_fn, verbose);
    for corr_type = {'Pearson', 'Spearman'}
        corr_type=corr_type{1};
        correl=corr(pred_simil, true_simil, 'type', corr_type);
        fprintf(1, ...
                'The %s %s correlation over %s (%d out of %d) is %f \n',...
                dataset{1}, corr_type, id, n_attempt, n_total, correl);
    end
end
%% Find score on TOM_ICLR13_SEM and TOM_ICLR_SYN dataset
if do_analogy_test
    for dataset = {'EN_TOM_ICLR13_SYN', 'EN_TOM_ICLR13_SEM'}
    tic;
    dataset_fn=[dataset{1}, '_FILENAME'];
    disp(['Now working on ', dataset_fn]);

    [n_total, n_attempt, n_correct_cosadd, n_correct_cosmul]=tom_test_impl(...
        word, word_map, get_emb, dataset_fn, U);

    fprintf(1, 'The %s dataset score over %s [%d, %d, %d, %d] is %f, %f \n',...
            dataset{1}, id, n_total, n_attempt, n_correct_cosadd, n_correct_cosmul, ...
            n_correct_cosadd/n_attempt, n_correct_cosmul/n_attempt);
    fprintf(1, 'The %s dataset over %s took %f minutes\n', dataset{1}, ...
            id, toc/60);
    end
end
end
