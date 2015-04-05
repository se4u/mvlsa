# SUMMARY: for file in input_dir grep lines which have the relation_id+" " as the start.
# Then collect counts by using a dictionary. All numbers in the file need to be incremented by 1.
# then populate the h5 file using the data in the dict.
import sys, h5py, os
from collections import defaultdict
import numpy as np
relation_to_process=sys.argv[1]
relation_list=sys.argv[2]
input_dir=sys.argv[3]
vocab_file=sys.argv[4]
output_filename=sys.argv[5]
vocab_size=sum(1 for _ in open(vocab_file))
relation_id=relation_list.split(",").index(relation_to_process)
prefix_to_check="%d "%relation_id
ret_dict=defaultdict(int)

for f in os.listdir(input_dir):
    print >> sys.stderr, "Reading file %s"%f
    if f.endswith("xml.gz"):
        try:
            with open(os.path.join(input_dir, f), "rb", 1<<20) as fh: 
                data=fh.read()
                for ii, row in enumerate(data.split("\n")):
                    if ii%1000000==0:
                        print >> sys.stderr, "Processed %d lines"%ii
                    if row.startswith(prefix_to_check):
                        r=[int(e) for e in row.strip().split()]
                        ret_dict[r[1]+1, r[2]+1]+=1
                    elif row=="":
                        break
        except IOError:
            print >> sys.stderr, "couldnt open file %s"%f
            continue

retval=np.ndarray(shape=(3, len(ret_dict)+1), dtype=np.float64)
retval[:,0]=np.array([vocab_size, vocab_size, 0])
for i, k in enumerate(ret_dict):
    retval[:, i+1]=np.array([k[0], k[1], ret_dict[k]])
with h5py.File(output_filename, 'w') as outf:
    outf['cooccurence_data']=retval
    
