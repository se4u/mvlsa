# This script receives the following input in stdin
# 41 -1 0 0
# 16 -1 0 1
# The first column is the number of times the trigram denoted by the
# next three numbers occured. We would add one to all the rest of the
# numbers and make sure trigrams do not have middle number < 0
# Then we would assign a unique id to all the contexts (consisting of
# the first and last word) and add the number to respective words'
# rows' respective column (the column indexed by the unique number of
# the context)

import sys
#from scipy.io import savemat
#from scipy.sparse import coo_matrix as sparse
from itertools import izip
input_filename=sys.argv[1]
vocabulary_size=int(sys.argv[2])
out_mat_filename=sys.argv[3]
limit=int(sys.argv[4])
context_size=int(sys.argv[5])
context_dict={}
word_row=[]
col=[]
data=[]
# Read the file once to find the number of words and the number of
# contexts that would be required.
col_cntr=0
for idx, row in enumerate(open(input_filename)):
    if idx > limit and limit != 0:
        break
    row=[int(e) for e in row.strip().split()]
    assert row[1+context_size] >= 0
    assert all(e < vocabulary_size for e in row[1:])
    tup=(row[1], row[3])
    if tup in context_dict:
        pass        
    else:
        context_dict[tup]=col_cntr
        col_cntr+=1
    word_row.append(row[1+context_size])
    col.append(context_dict[tup])
    data.append(row[0])
tmp=len(context_dict)
assert(all(e <  tmp and e >= 0 for  e in col ))
assert(all(e < vocabulary_size and e >= 0 for e in word_row))
with open(out_mat_filename, "wb") as f:
    f.write("%d\t%d\t%d\n"%(vocabulary_size,len(context_dict),0))
    for a,b,c in izip(word_row, col, data):
        f.write("%d\t%d\t%d\n"%(a+1,b+1,c))

# align_mat=sparse((data, (word_row, col)),
#                  shape=(vocabulary_size,len(context_dict)))
# savemat(out_mat_filename,
#         dict(align_mat=align_mat),
#         oned_as='column',format='4')
#print loadmat('tmp.mat')['align_mat']
    
