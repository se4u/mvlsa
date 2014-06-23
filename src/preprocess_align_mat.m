function [arr, mu1, mu2]=preprocess_align_mat(arr, opt)
get_log =@(x) spfun(@log, x);
switch opt
  case 'Count'
    1; %arr=arr; do do nothing
  case 'logCount'
    arr=get_log(arr); 
end
mu1=mean(arr, 1);
mu2=mean(arr, 2);