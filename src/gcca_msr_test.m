function gcca_msr_test(big_word_list, big_word_map, small_word_map, ...
                       G, sort_idx, msrd, UJ, CPL)
% msrd{i,1} is the sentence
% msrd{i,2} is the location of options
% msrd{i,3} are the options
% msrd{i,4} is the correct options index.

try
    distcomp.feature( 'LocalUseMpiexec', false );
    num_pool=10;
    ex_ppool=1040/num_pool;
    matlabpool('OPEN', num_pool);
catch
    disp('Failure to parallelize on this machine');
    exit(1);
end

parfor par_idx=1:num_pool
for i = (par_idx-1)*ex_ppool+1:par_idx*ex_ppool
    tic;
    sentence=msrd{i,1};
    opt_loc=msrd{i,2};
    options=msrd{i,3};
    correct_word=options{msrd{i,4}};
    gcca_per_opt={};
    
    imp_r=[];
    for opt_idx=1:5
        sentence{opt_loc}=options{opt_idx};
        % Turn the sentence into a mini corpus 
        dvk=turn_into_distrib_view(sentence, big_word_map, 1);
        [ii,~,~]=find(dvk(sort_idx,:));
        imp_r=[imp_r; ii];
    end
    imp_r=unique(imp_r);
    G2=G(imp_r,:);
    for opt_idx=1:5
        sentence{opt_loc}=options{opt_idx};
        gcca_obj=[];
        for k=1:1:15
            dvk=turn_into_distrib_view(sentence, big_word_map, k);
            % This is the computational bottleneck.
            x = dvk(sort_idx,CPL{k});
            x = x(imp_r,:)*UJ{k};
            gcca_obj=[gcca_obj norm(G2-x, 'fro')];
        end
        gcca_per_opt{opt_idx}=gcca_obj;
    end
    [vv,ii]=min(sum(cell2mat(gcca_per_opt'),2));
    
    %% This method predicts embedding for word and then picks nearest word
    % predicted_embedding=[]
    % for i=1:opt_loc-1 % length(sentence)
    %     try 
    %         predicted_embedding=[predicted_embedding; ...
    %                             G(small_word_map(lower(sentence{i})),:)];
    %     catch
    %     end
    % end
    % predicted_embedding=normalize_embedding(sum(predicted_embedding));
    % for opt_idx=1:5
    %     opt_word=options{opt_idx};
    %     g=normalize_embedding(G(small_word_map(opt_word),:));
    %     disp([opt_idx norm(g-predicted_embedding) g*predicted_embedding']);
    % end
    
    %%
    predicted_word=options{ii};
    
    fprintf(1,'i=%d, Prediction: %s, Actual: %s\n', ...
            i, predicted_word,correct_word);
    toc;
end
end

