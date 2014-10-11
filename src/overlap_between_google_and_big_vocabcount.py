import sys
from scipy import io, sparse
import numpy as np
google_f=open(sys.argv[1], 'rb')
[total_words, _dim]=[int(e) for e in google_f.next().strip().split()]
vocab=dict((row.strip().split()[0], i) for i, row in enumerate(open(sys.argv[2], 'rb')))
S = sparse.dok_matrix((len(vocab),_dim), dtype=np.float64)
for row in google_f:
    row=row.strip().split()
    word=row[0]
    vec=[float(e) for e in row[1:]]
    if word in vocab:
        S[vocab[word],:]=vec

with open(sys.argv[3], "wb") as f:
    io.savemat(f, dict(align_mat=S), oned_as='column', format='5', appendmat=False)
