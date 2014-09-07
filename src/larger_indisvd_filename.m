function lif=larger_indisvd_filename(outdirname, outfile, optstr, ...
                                     svdsizestr)
pat=[outfile(1:end-length(svdsizestr)-4) '*'];
candidate_files=dir(pat);
svdsize=str2num(svdsizestr);
lif=[];
best_size=Inf;
if length(candidate_files)~=0
    candidate_files={candidate_files.name};
    gf=@(p) str2num(p{8});
    for i=1:length(candidate_files)
        try
            f=candidate_files{i};
            f_size=gf(strsplit(f(1:end-4), '_'));
            if f_size > svdsize && f_size < best_size
                lif = [outdirname '/' f];
                best_size=f_size;
            end
        catch
        end
    end
end