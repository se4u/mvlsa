clc;
x = 0:0.0001:1;
pb = @(a,b) betapdf(x,a,b);
for n=[ 10675 8869 80];
pval_of_null_hypothesis = 5e-2;
% alpha is the prior belief. Lc is lower at higher values of
% belief.
disp('new n');
disp(n);
for alpha = [0.5 1]
    for lc = .06:0.01:10
        done = 0;
        for ac1 = min(100-lc, 90):-1:75
            %disp(ac1);
            ac2 = ac1+lc;
            sys_1=round(ac1/100*n);
            sys_2=round(ac2/100*n);
            pos_sys_1=pb(alpha+sys_1,alpha+(n-sys_1));
            pos_sys_2=pb(alpha+sys_2,alpha+(n-sys_2));
            % this is being done through convnfft since difference of two
            % pdf is like convolution with flipped version, and convolution
            % is faster through fft. All this needs to be done for faster
            % precision. 
            pos_sys_1_m_2 = convnfft(pos_sys_1, fliplr(pos_sys_2));
            pos_sys_1_m_2 = pos_sys_1_m_2/sum(pos_sys_1_m_2);
            % pos_sym_1_m_2 is \theta_1 - \theta_2
            p_ac2_better_than_ac1 = sum(pos_sys_1_m_2(1:floor(end/2)));
            if p_ac2_better_than_ac1 > (1-pval_of_null_hypothesis)
                done = 1;
                break;
            end
        end
        if done == 1
            break
        end
    end
    fprintf(1,['lc = %0.3f.\nWe can say with pval=%0.3f \n',...
                'that when sys1 = %0.3f and sys2 = %0.3f \n',...
                'then sys2 better than sys1\n'], ...
                lc, pval_of_null_hypothesis, ac1, ac2);
end
end
