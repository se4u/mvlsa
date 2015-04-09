for n in 3000 2034 2003 999 353 287 252 203 65 30
do
    python src/MRDS/find_lc_spearman_significance.py $n
done

matlab -nojvm -r "addpath('src/MRDS'); find_prob_of_difference_of_two_beta_dist"
