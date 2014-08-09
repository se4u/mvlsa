# This script receives the following input in stdin
# 41 -1 0 0
# 16 -1 0 1
# 47 -1 0 10
#  1 -1 0 100077
#  1 -1 0 10009
#  1 -1 0 100099
# 22 -1 0 1001
#  1 -1 0 10010
#  2 -1 0 100155
#  1 -1 0 10017
# The first column is the number of times the trigram denoted by the
# next three numbers occured. We would add one to all the rest of the
# numbers and make sure trigrams do not have middle number < 0
# Then we would assign a unique id to all the contexts (consisting of
# the first and last word) and add the number to respective words'
# rows' respective column (the column indexed by the unique number of
# the context)

import sys
from scipy.io import savemat, loadmat
from scipy.sparse import coo_matrix as sparse

input_filename=sys.argv[1]
vocabulary_size=sys.argv[2]
out_mat_filename=sys.argv[3]
context_dict={}
word_row=[]
col=[]
data=[]
# Read the file once to find the number of words and the number of
# contexts that would be required.
idx=0
for row in open(input_filename):
    row=[int(e) for e in row.strip().split()]
    assert row[2] >= 0
    assert all(e < vocabulary_size for e in row[1:])
    if (row[1], row[3]) in context_dict:
        pass        
    else:
        context_dict[(row[1], row[3])]=idx
        idx+=1
    word_row.append(row[2])
    col.append(context_dict[(row[1], row[3])])
    data.append(row[0])

align_mat=sparse((data, (word_row, col)),
                 shape=(vocabulary_size,len(context_dict)),
                 )
savemat(out_mat_filename,
        dict(align_mat=align_mat),
        oned_as='column',
        format='4')
#print loadmat('tmp.mat')['align_mat']
    
