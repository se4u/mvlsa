function [arr, mu1, mu2]=preprocess_align_mat(arr, opt)
get_log =@(x) spfun(@log, x);
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
    assert(strcmp(opt2(1:length('truncatele')), 'truncatele'));
    trunc_lim=str2num(opt2(length('truncatele')+1:end));
    disp(['trunc_lim is ', num2str(trunc_lim)]);
    assert(size(arr, 1) < size(arr, 2));
    aa=sum(arr);
    arr(:,find(aa < trunc_lim))=[];
end
    
disp(['Now opt is ', opt]);
switch opt
  case 'Count'
    1; %arr=arr; do do nothing
  case 'logCount'
    arr=get_log(arr);
end
mu1=mean(arr, 1);
mu2=mean(arr, 2);