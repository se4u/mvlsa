# 1. Size of vocabulary file
# 2. Name of vocabulary file
# 3. The input file name
# 4. The number of sentences in input file
# 5. The window size
# 6. The position from which I will start my work.
# 7. The name of the file to which I would write.
import sys, itertools
import struct
#import contextlib, mmap
vocab_size=int(sys.argv[1])
vocab_dict=dict((v.strip(),i+1) for i,v in enumerate(open(sys.argv[2], "r", 1<<20)))
text_filename=sys.argv[3]
sentence_count=int(sys.argv[4])
window_size=int(sys.argv[5])
starting_position=int(sys.argv[6])
increment_size=int(sys.argv[7])
outfile=open(sys.argv[8], "wb", 100<<20)
min_length_sentence=int(sys.argv[9])
max_pos=min(sentence_count, starting_position+increment_size)
bos_idx=vocab_size+1
eos_idx=vocab_size+2
packer=struct.Struct('iii')
outfile.write(packer.pack(vocab_size, eos_idx, 0));
keyerr_dict={}
with open(text_filename, 'rb', 100<<20) as m:
        # with contextlib.closing(mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)) as m:
        # Skip the lines till we reach starting position
        for _ in xrange(starting_position):
            m.readline()
        for _ in xrange(starting_position, max_pos):
            row=m.readline().strip().split()
            if len(row)>min_length_sentence:
                for i,w in enumerate(row):
                    try:
                        w_idx=vocab_dict[w]
                    except KeyError as k:
                        keyerr_dict[w]=None
                        continue
                    for j in itertools.chain(xrange(-window_size, 0), xrange(1,window_size+1)):
                        e=i+j
                        if e < 0:
                            outfile.write(packer.pack(w_idx, bos_idx, j))
                        elif e >= len(row):
                            outfile.write(packer.pack(w_idx, eos_idx, j))
                        else:
                            try:
                                v=vocab_dict[row[e]]
                            except KeyError as k:
                                continue
                            outfile.write(packer.pack(w_idx, v, j))
outfile.close()
if len(keyerr_dict):
    print >> sys.stderr, str(keyerr_dict.keys())
