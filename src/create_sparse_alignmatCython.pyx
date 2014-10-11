import sys
from scipy import sparse, io
import numpy as np

def main(fr_word, en_word, alignment_filename, out_mat_filename):
    S = sparse.dok_matrix((len(en_word), len(fr_word)), dtype=np.float64)
    for i,row in enumerate(open(alignment_filename, "rb")):
        if i%100000==0:
            print >> sys.stderr, i
        try:
            [fr, en, fr2en_al]=row.strip().split(" ||| ")
        except:
            print >>sys.stderr, "COULD NOT SPLIT", row
            continue
        fr=dict(list(enumerate(fr.split(" "))))
        en=dict(list(enumerate(en.split(" "))))
        for al in fr2en_al.split(" "):    
            al=al.split("-")
            try:
                f=fr[int(al[0])]
                e=en[int(al[1])]
            except:
                print >>sys.stderr, "Could not process: ", row
            try:
                S[en_word[e], fr_word[f]]+=1
            except:
                continue
    with open(out_mat_filename, "wb") as f:
        io.savemat(f, dict(align_mat=S), oned_as='column', format='5', appendmat=False)
