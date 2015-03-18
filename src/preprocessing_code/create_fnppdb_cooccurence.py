""" This takes a vocabulary file and a frameIndexLU file. and then marks the frames as contexts for the words listed under the same frame. so for example there should be an entry for (renounced, Abandonment)
0	2031	Abandonment	renounced.v
0	2031	Abandonment	forsaken.n
grep -n renounced $VOCAB_500K_FILE = 18778
so the entry should be (18778, 1)
"""
import sys
import numpy as np
from scipy import sparse, io
#from nltk.corpus import wordnet as wn
vocab=dict((e[1].strip().split()[0], e[0])
                for e in enumerate(open(sys.argv[1])))
framefile=open(sys.argv[2])
def set_infile(f):
    f.seek(0)
    f.readline()
    f.readline()
    return f
set_infile(framefile)
output_fn=sys.argv[3]
framedict=dict((x[1], x[0]) for x in enumerate(set(e.strip().split()[2] for e in framefile)))

S = sparse.dok_matrix((len(vocab),
                       len(framedict)), dtype=np.float64)
for row in set_infile(framefile):
    row=row.strip().split()
    frame=row[2]
    word=row[3].split(".")[0]
    try:
        vocab[word]
    except:
        print >> sys.stderr, "%s not in vocab"%word
        continue
    S[vocab[word], framedict[frame]]+=1

with open(output_fn, "wb") as f:
    io.savemat(f, dict(align_mat=S), oned_as='column', format='5', appendmat=False)

# wordnet_data=[[(e.name, s.name) for e in s.lemmas] for s in wn.all_synsets() if len(s.lemmas)>1]
# synset_vocab=dict((k, i) for i, k in enumerate(set(e2[1] for e1 in wordnet_data for e2 in e1)))
# S = sparse.dok_matrix((len(vocab),len(synset_vocab)), dtype=np.float64)
# for e1 in wordnet_data:
#     for word, synset in e1:
#         try:
#             S[vocab[word],synset_vocab[synset]]+=1
#         except:
#             print >> sys.stderr, "%s is not in vocab"%word

# with open(output_fn.replace("fnppdb", "wordnet"), "wb") as f:
#     io.savemat(f, dict(align_mat=S), oned_as='column', format='5', appendmat=False)
