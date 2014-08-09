function rank_cell=conduct_extrinsic_test_impl(U, ...
                                              golden_paraphrase_map, ...
                                              ppdb_paraphrase_rating, ...
                                              id, word)
[mrr rank_cell]=find_mrr(U, golden_paraphrase_map, word);
fprintf(1, 'The MRR (1 indexed) over %s is %f\n', ...
        id, mrr);
C1 = U(ppdb_paraphrase_rating(:,1),:);
C2 = U(ppdb_paraphrase_rating(:,2),:);
cosine_sim = sum(C1.*C2, 2);
kc=corr(cosine_sim, ppdb_paraphrase_rating(:,3), 'type', ...
             'Kendall');
%% Perform a battery of tests
get_emb=@(wrd) U(find(strcmp(word, lower(wrd))), :);
% 1. Find the kendall tau correlation  coefficient 
fprintf(1, 'The Kendall Tau over %s is %f\n', id, kc);
% 2. Find the swapped pair rate 
fprintf(1, 'The Swapped Pair rate is %f in percentage\n', ...
        ((1-kc)/2)*100);
% 3. Find PEarson Correlation between juri and chris annotation and
% cosine_sim between embeddings
for corr_type = {'Pearson', 'Spearman'}
    corr_type=corr_type{1};
    fprintf(1, 'The %s Corr over %s is %f\n', corr_type, id, ...
        corr(cosine_sim, ppdb_paraphrase_rating(:,3), 'type', ...
             corr_type));
end
% 4. Find the score on Toefl test
[n_total, n_attempt, n_correct]=toefl_test_impl(word, get_emb);
fprintf(1, 'The TOEFL score over %s with bare [%d, %d, %d] is %f\n', ...
        id, n_total, n_attempt, n_correct, n_correct/n_total);
% 5. Find the score on SCWS, RW, MEN, MC_30, EN_MTURK_287,
% EN_RG_65, EN_WS_353_(ALL/REL/SIM) datasets
for dataset={ 'SCWS', 'RW', 'MEN', 'EN_MC_30', 'EN_MTURK_287', 'EN_RG_65', ...
             'EN_WS_353_ALL', 'EN_WS_353_REL', 'EN_WS_353_SIM' }
    dataset_fn=[dataset{1}, '_FILENAME'];
    disp(['Now working on ', dataset_fn]);
    [n_total, n_attempt, pred_simil, true_simil]=scws_test_impl(...
        word, get_emb, dataset_fn);
    for corr_type = {'Pearson', 'Spearman'}
        corr_type=corr_type{1};
        correl=corr(pred_simil, true_simil, 'type', corr_type);
        fprintf(1, ['The %s %s correlation over %s (%d out of %d) ' ...
            'is %f \n'], dataset{1}, corr_type, id, n_attempt, n_total, ...
            correl);
    end
end
% % 7. Find score on TOM_ICLR13_SEM and TOM_ICLR_SYN dataset
% for dataset = {'EN_TOM_ICLR_SYN', 'EN_TOM_ICLR13_SEM'}
%     dataset_fn=[dataset{1}, '_FILENAME'];
%     disp(['Now working on ', dataset_fn]);
    
%     [n_total, n_attempt, n_correct]=tom_test_impl(...
%         word, get_emb, dataset_fn, U);

%     fprintf(1, 'The %s dataset score over %s [%d, %d, %d] is %f \n',...
%        dataset{1}, id, n_total, n_attempt, n_correct, n_correct/n_total);
% end
for i=1:length(cosine_sim)
    fprintf(1, '%s\t%s\t%f\t%d\n',...
            word{ppdb_paraphrase_rating(i,1)}, ...
            word{ppdb_paraphrase_rating(i,2)}, ...
            cosine_sim(i), ...
            ppdb_paraphrase_rating(i,3));
end
disp('finished printing the true ratings');
%fprintf(1, 'The Logistic Fit is %f\n', logistic_fit());