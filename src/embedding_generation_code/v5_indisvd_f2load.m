function f2load=v5_indisvd_f2load(dtype, lang,  svd_size, basedir)
f2load='';
f2load_maker=@(s) [basedir '/' s '_' lang '.mat'];
if strcmp(dtype, 'bitext')
    f2load=f2load_maker('align');
elseif strcmp(dtype, 'monotext')
    f2load=f2load_maker('cooccur');
elseif strcmp(dtype(1:min(end, length('monotext'))), 'monotext')
    assert(~isempty(str2num(dtype(length('monotext')+1:end))));
    f2load=[basedir '/cooccur_en_' dtype(length('monotext')+1:end) '.mat'];
elseif strcmp(dtype, 'bvgn')
    f2load=f2load_maker('big_vocabcount_en_intersect_gn');
else
    error(['Wrong dtype argument: ' dtype]);
end