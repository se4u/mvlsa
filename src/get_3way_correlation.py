"""given 3 filenames on cmd line, assuming that they have 1 number per line give a matrix containing the correlations between them
"""
__date__    = "19 November 2014"
__author__  = "Pushpendre Rastogi"
__contact__ = "pushpendre@jhu.edu"
import sys
import numpy as np
a=np.array([[float(e.strip()) for e in open(sys.argv[1])],
            [float(e.strip()) for e in open(sys.argv[2])],
            [float(e.strip()) for e in open(sys.argv[3])]])
print >> sys.stderr, a
ct = sys.argv[4]
if ct=="spearman":
    from scipy.stats import spearmanr
    a01 = spearmanr(a[0], a[1])[0]
    a02 = spearmanr(a[0], a[2])[0]
    a12 = spearmanr(a[1], a[2])[0]
    b=np.asarray([[1, a01, a02], [a01, 1, a12], [a02, a12, 1]])
elif ct=="pearson":
    b=np.corrcoef(a)
else:
    raise NotImplementedError("Unknown correlation type %s"%ct)

for i in range(3):
    for j in range(3):
        sys.stdout.write("%0.2f, "%b[i,j])
    sys.stdout.write("\n")
