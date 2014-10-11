import sys
import morphology
from scipy import sparse, io
import numpy as np
mm=morphology.Morphological_Analyzer()
# INFLECTION_TYPE := past participle continuous plural superlative comparative
# fn means filename
vocab_fn=sys.argv[1]
catvar_fn=sys.argv[2]
output_fn=sys.argv[3]
vocab=dict((e[1].strip().split()[0], e[0])
                for e in enumerate(open(vocab_fn)))
S = sparse.dok_matrix((len(vocab),len(vocab)), dtype=np.float64)
print len(vocab)
unknown_lemma_counter=0

for word in vocab:
    for morphacode in ["v", "n", "jj"]:
        mma=mm.analyze(word, morphacode)
        if mma[1]!="":
            try:
                S[vocab[word], vocab[mma[0]]]+=1
            except:
                print >> sys.stderr, "Lemma %s not in vocab"%mma[0]
                unknown_lemma_counter+=1

with open(catvar_fn) as cf:
    for row in cf:
        row=[e.split("_")[0] for e in row.strip().split("#")]
        lemma=row[0]
        for word in row[1:]:
            try:
                S[vocab[word], vocab[lemma]]+=1
            except:
                print >> sys.stderr, "One of %s, %s not in vocab"%(word, lemma)

print >> sys.stderr, "Total lemma unknown %d"%unknown_lemma_counter
with open(output_fn, "wb") as f:
    io.savemat(f, dict(align_mat=S), oned_as='column', format='5', appendmat=False)
    
