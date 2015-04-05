import numpy as np
import contextlib
import mmap
import sys
def get_vocab(vocab_fn):
    return dict(map(lambda x: (x[1].strip().split()[0], x[0]+1), enumerate(open(vocab_fn))))

def count(vocab_fn, text_fn, window_size, bos_to_maintain):
    vocab=get_vocab(vocab_fn)
    len_vocab=len(vocab)
    len_contexts=len_vocab+bos_to_maintain
    ret_dict={}
    # mh means mmap handle
    with open(text_fn, "rb") as tf:
        with contextlib.closing(mmap.mmap(tf.fileno(), 0, access=mmap.ACCESS_READ)) as mh:
            line_idx=0
            while True:
                row=mh.readline().strip().lower().split()
                if line_idx%1000000==0: print >> sys.stderr, "Processed %dM lines"%line_idx
                if row==[]:
                    print >> sys.stderr, "Lines read %d"%line_idx
                    break
                else:
                    line_idx+=1
                converted_row=[None]*len(row)
                for i,w in enumerate(row):
                    try:
                        w_idx=vocab[w]
                        converted_row[i]=w_idx
                    except:
                        converted_row[i]=-1
                        continue
                    tmp=i-window_size
                    if tmp < 0:
                        context_id = len_vocab-tmp
                    else:
                        context_id = converted_row[tmp]
                    if context_id!=-1:
                        try:
                            ret_dict[w_idx, context_id]+=1
                        except:
                            ret_dict[w_idx, context_id]=1
    retval = np.ndarray(shape=(3,len(ret_dict)+1), dtype=np.float64)
    retval[:,0]=np.array([len_vocab, len_contexts, 0])
    for i, k in enumerate(ret_dict):
        retval[:,i+1]=np.array([k[0], k[1], ret_dict[k]])
    return retval
