import sys
from scipy import ones
from scipy.sparse import coo_matrix as sparse
from scipy.io import savemat
import gc
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
idx_en_list=[]
idx_fr_list=[]
gc.disable()
for i,row in enumerate(open(alignment_filename, "rb")):
    print >> sys.stderr, i
    try:
        [fr, en, fr2en_al]=row.strip().split(" ||| ")
    except:
        print >>sys.stderr, "COULD NOT SPLIT", row
        continue
    fr=dict(list(enumerate(fr.split(" "))))
    en=dict(list(enumerate(en.split(" "))))
    try:
        for al in fr2en_al.split(" "):    
            al=al.split("-")
            f=fr[int(al[0])]
            e=en[int(al[1])]
            # Note that this step en_word[e] can fail since we are
            # using gn_intersect_ppdb vocabulary, e.g., -pipe-. This
            # word appears in the text corpus but not in google's
            # embeddings vocabulary. However there is not reason for
            # the fr language to fail.
            try:
                en_word[e]
                fr_word[f]
            except:
                continue
            idx_en_list.append(en_word[e])
            idx_fr_list.append(fr_word[f])
    except:
        print >>sys.stderr, "COULD NOT PROCESS", row
        continue

d=ones((len(idx_en_list),))
sparse_d=(d, (idx_en_list, idx_fr_list))
try:
    align_mat=sparse(sparse_d, shape=am_shape)
    savemat(out_mat_filename, dict(align_mat=align_mat))
except:
    import pdb; pdb.set_trace()
# cPickle.dump((idx_en_list, idx_fr_list), open("tmp_fr.pickle", "wb"), cPickle.HIGHEST_PROTOCOL)
# numpy.asarray(idx_en_list).tofile("tmp_idx_en_list", sep="\n"); numpy.asarray(idx_fr_list).tofile("tmp_idx_fr_list", sep="\n")
