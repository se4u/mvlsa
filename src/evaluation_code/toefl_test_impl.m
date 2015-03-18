% load /export/a14/prastog3/gcca_run_sans_mu_300_7000_1e-8_logCount.mat
% word=textread('/export/a14/prastog3/big_vocabcount_en_intersect_gn_embedding_word', '%s');
% load /export/a14/prastog3/big_vocabcount_en_intersect_gn_embedding.mat
function [n_total n_attempt, n_correct]=toefl_test_impl(word, get_emb)

toefl_qst_file=getenv('TOEFL_QUESTION_FILENAME');
toefl_ans_file=getenv('TOEFL_ANSWER_FILENAME');
[toefl_q toefl_data]=textread(toefl_qst_file, '%s %s');
toefl_q_idx=cellfun(@(e) str2num(e(1:length(e)-1)), toefl_q(1:5:400));
assert(all(toefl_q_idx'==1:80));
[~, ~, ~, toefl_ans]=textread(toefl_ans_file, '%s %s %s %s');
toefl_ans=cellfun(@(e) e-96, toefl_ans);
assert(length(toefl_ans)==80);
n_total=80;
n_attempt=0;
n_correct=0;
for qst_idx=1:n_total
    i=qst_idx*5-4;
    qst_word=lower(toefl_data{i});
    ans_sim=[];
    ans_word={};
    try
        qst_emb=get_emb(qst_word);
        for wi=1:4
            ans_word{wi}=toefl_data{i+wi};
            ans_sim(wi)=sum(qst_emb.*lower(get_emb(ans_word{wi})));
        end
        n_attempt=n_attempt+1;
    catch err
        continue
    end
    [~, predicted_ans]=max(ans_sim);
    corr_ans = toefl_ans(qst_idx);
    if predicted_ans==corr_ans
        sign='+';
        n_correct=n_correct+1;
    else
        sign='-';
    end
    fprintf(1, [sign ' %d, Q: %s, A: %s \n'], qst_idx, qst_word, ans_word{predicted_ans});
    disp(ans_sim);
end