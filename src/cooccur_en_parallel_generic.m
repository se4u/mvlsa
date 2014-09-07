function S = cooccur_en_parallel_generic(S, window_size, input_file, ...
                                         dimarr)
i=0;
try
for i=1:length(input_file)
    tic;
    fh=fopen(input_file{i});
    A=fread(fh, [3, Inf], '*int32');
    A=A';
    A(A(:,3)>window_size | A(:,3)<-window_size,:)=[];
    A=double(A);
    if isnan(S)
        assert(A(1,3)==0);
        dimarr=A(1,:);
    end;
    if A(1,3)~=0
        A(end+1,:)=A(1,:);
        A(1,:)=dimarr;
    end;
    A(2:end,3) = 1./abs(A(2:end, 3));
    if isnan(S)
        S=spconvert(A);
    else
        S=S+spconvert(A);
    end;
    disp(i);
    disp(input_file{i});
    whos;
    clear A;
    fclose(fh);
    toc;
end;
catch
fprintf(1, 'We stopped working at %s', input_file{i});
end;
