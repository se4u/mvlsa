import pyximport; pyximport.install()
from count_cooccurence_cython import count
import sys
import h5py
# fn means filename
vocab_fn = sys.argv[1]
text_fn = sys.argv[2]
window_size = int(sys.argv[3])
target_fn =  sys.argv[4]
bos_to_maintain = int(sys.argv[5])
min_length_sentence = int(sys.argv[6])

def write_sparse_h5_dataset(target_fn, cooc_arr):
    target_f=h5py.File(target_fn, "w")
    target_f['cooccurence_data']=cooc_arr
    target_f.close()

if __name__=="__main__":
    print >>sys.stderr, "Make sure that the file does not contain blank lines. We stop at the first blank line"
    cooc_arr=count(vocab_fn, text_fn, window_size, bos_to_maintain)
    write_sparse_h5_dataset(target_fn, cooc_arr)
