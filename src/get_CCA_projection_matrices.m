function [Wx, Wy, r]=get_CCA_projection_matrices(view1, view2, ...
                                                        dim2keep)
lib_util;
tic; [Wx,Wy,r] = canoncorr_reg(view1, view2);
disp(sprintf('CCA complete in %f sec', toc));
Wx=Wx(:, 1:dim2keep);
Wy=Wy(:, 1:dim2keep);
width=size(view1,2);
chisq_stat=-(size(view1, 1)-1-(2*width+1)/2)*flipud(cumsum(flipud(log(1-r.^2))));
dof=((width+1)-(1:width)).^2;
for non_negligible_corr_dim=width:-1:1
    i=non_negligible_corr_dim; % For convenience
    if chisq_diff_from_zero(chisq_stat(i), dof(i), 0.95)
        break;
    end
end
disp(sprintf(['At 95 percent confidence the number of dimensions which have ' ...
      'non negative correlation are %d'], non_negligible_corr_dim));