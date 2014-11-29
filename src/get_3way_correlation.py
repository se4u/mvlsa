"""given 3 filenames on cmd line, assuming that they have 1 number per line give a matrix containing the correlations between them
"""
__date__    = "19 November 2014"
__author__  = "Pushpendre Rastogi"
__contact__ = "pushpendre@jhu.edu"
import numpy as np
import sys
a=np.array([[float(e.strip()) for e in open(sys.argv[1])],
            [float(e.strip()) for e in open(sys.argv[2])],
            [float(e.strip()) for e in open(sys.argv[3])]])
print >> sys.stderr, a
b=np.corrcoef(a)
for i in range(3):
    for j in range(3):
        sys.stdout.write("%0.2f, "%b[i,j])
    sys.stdout.write("\n")
