function [b,s,mu1,mu2]=v5_indisvd(dtype, lang, mc_muc, ...
                                  preprocess_option, svd_size, basedir)
f2load='';
f2load_maker=@(s) [basedir '/' s '_' lang '.mat'];
if strcmp(dtype, 'bitext')
    f2load=f2load_maker('align');
elseif strcmp(dtype, 'monotext')
    f2load=f2load_maker('cooccur');
elseif strcmp(dtype(1:length('monotext')), 'monotext')
    assert(~isempty(str2num(dtype(length('monotext')+1:end))));
    f2load=[basedir '/cooccur_en_' dtype(length('monotext')+1:end) '.mat'];
elseif strcmp(dtype, 'bvgn')
    f2load=f2load_maker('big_vocabcount_en_intersect_gn');
    preprocess_option='Count';
else
    error(['Wrong dtype argument: ' dtype]);
end
load(f2load);
if ~exist('align_mat')
    align_mat=bvgn_embedding;
end
disp(size(align_mat));
[align_mat, mu1, mu2]=preprocess_align_mat(align_mat, ...
                                           preprocess_option);
disp(size(align_mat));
disp('preprocessing complete');
if strcmp(mc_muc, 'muc')
    [b, s]=svds(align_mat, svd_size);
    s=transpose(diag(s));
elseif strcmp(mc_muc, 'mc')
    [b, s, a]=svds(align_mat, svd_size);
    [b, s, a]=rank_one_svd_update(b, s, a, -1*ones(size(align_mat, ...
                                                      1), 1), mu1', 0);
    s=transpose(diag(s));
else
    error(['Wrong mc_muc option: ' mc_muc]);
end