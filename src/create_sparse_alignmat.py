import sys
from scipy.sparse import coo_matrix as sparse
from scipy.io import savemat
fr_word_filename=sys.argv[1]
en_word_filename=sys.argv[2]
alignment_filename=sys.argv[3]
out_mat_filename=sys.argv[4]
en_word={}
fr_word={}
for i,e in enumerate(open(en_word_filename, "rb")):
    en_word[e.strip()]=i
for i,e in enumerate(open(fr_word_filename)):
    fr_word[e.strip().split("\t")[0]]=i
am_shape=(len(en_word), len(fr_word))
align_mat=sparse(am_shape)
for i,row in enumerate(open(alignment_filename, "rb")):
    try:
        [fr, en, fr2en_al]=row.strip().split(" ||| ")
    except:
        print >>sys.stderr, "COULD NOT SPLIT", row
        continue
    fr=dict(list(enumerate(fr.split(" "))))
    en=dict(list(enumerate(en.split(" "))))
    for al in fr2en_al.split(" "):
        al=al.split("-")
        f=fr[int(al[0])]
        e=en[int(al[1])]
        try:
            idx_e=en_word[e]
            idx_f=fr_word[f]
        except:
            continue
        align_mat=align_mat+\
            sparse(([1],([idx_e], [idx_f])), shape=am_shape)
savemat(out_mat_filename, dict(align_mat=align_mat))
