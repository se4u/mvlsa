% The possible inputs are
% logCount, CountPow075, logCountPow075, Freq, logFreq, FreqPow075
% truncatele20 can be apeended to any of them.
function [arr, mu1, mu2, nonmissing_rows]=preprocess_align_mat(arr, opt)
get_log =@(x) spfun(@log, x);
get_log1p =@(x) spfun(@log1p, x);
get_pow=@(x, p) x.^p;
get_freq=@(x) diag(sum(x,2).^-1)*x;

opt_delimiter_idx=find(opt=='-');
num_opt=length(opt_delimiter_idx)+1;
assert(num_opt <= 2);
disp(['Now opt is ', opt]);
if num_opt == 2
    % Basically we remove all columns with less sum than the limit
    % prescribed in opt's second part
    opt2 = opt(opt_delimiter_idx+1:end);
    opt = opt(1:opt_delimiter_idx-1);
    disp(opt2);
    if strcmp(opt2(1:length('truncatele')), 'truncatele')
        trunc_lim=str2num(opt2(length('truncatele')+1:end));
        disp(['trunc_lim is ', num2str(trunc_lim)]);
        aa=sum(arr);
        arr(:,find(aa < trunc_lim))=[];
    elseif strcmp(opt2(1:length('trunccol')), 'trunccol')
        max_col=str2num(opt2(length('trunccol')+1:end));
        disp(['Max col = ', num2str(max_col)]);
        [~, sort_order]=sort(sum(arr), 'descend');
        arr=arr(:, sort_order(1:min(max_col, size(arr, 2))));
    end
end
    
disp(['Now opt is ', opt]);
powloc=strfind(opt, 'Pow');
if ~isempty(powloc)
    power=str2num(opt(powloc+3:powloc+5))*0.01;
    opt=opt(1:powloc+2);
    switch opt
      case 'CountPow'
        arr=get_pow(arr, power);
      case 'FreqPow'
        arr=get_pow(get_freq(arr), power);
      case 'logCountPow'
        arr=get_log(get_pow(arr, power));
      otherwise
        error(['Unknown opt: ' opt]);
    end
else
    switch opt
      case 'Count'
        1; %arr=arr; do do nothing
      case 'logCount'
        arr=get_log(arr);
      case 'Freq'
        arr=get_freq(arr);
      case 'logFreq'
        arr=get_log(get_freq(arr));
      case 'log1pFreq'
        arr=get_log1p(get_freq(arr));
      otherwise
        error(['Unknown opt: ' opt]);
    end
end
% Calculate mean while discarding rows that are completely zero.
assert(nnz(arr)>1);
nonmissing_rows=(sum(arr,2)~=0);
mu1=mean(arr(nonmissing_rows, :), 1);
mu2=mean(arr(nonmissing_rows, :), 2);
assert(any(isnan(mu1))~=1);