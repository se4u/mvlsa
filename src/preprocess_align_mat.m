% The possible inputs are
% logCount, CountPow075, logCountPow075, Freq, logFreq, FreqPow075
% truncatele20 can be apeended to any of them.
function [arr, mu1, mu2]=preprocess_align_mat(arr, opt)
get_log =@(x) spfun(@log, x);
get_log1p =@(x) spfun(@log1p, x);
get_pow=@(x, p) x.^p;
get_freq=@(x) diag(sum(x,2).^-1)*x;

opt_delimiter_idx=find(opt=='-');
num_opt=length(opt_delimiter_idx)+1;
assert(num_opt <= 2);
disp(['Now opt is ', opt]);
if num_opt == 2
    assert(size(arr, 1) < size(arr, 2));
    % Basically we remove all columns with less sum than the limit
    % prescribed in opt's second part
    opt2 = opt(opt_delimiter_idx+1:end);
    opt = opt(1:opt_delimiter_idx-1);
    disp(opt2);
    assert(strcmp(opt2(1:length('truncatele')), 'truncatele'));
    trunc_lim=str2num(opt2(length('truncatele')+1:end));
    disp(['trunc_lim is ', num2str(trunc_lim)]);
    aa=sum(arr);
    arr(:,find(aa < trunc_lim))=[];
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
mu1=mean(arr, 1);
mu2=mean(arr, 2);