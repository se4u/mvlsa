import sys
# This file is used to map words to numeric indexes.
context_window_size=int(sys.argv[1]) # This is the context window size on one side. The actualy window is 3 if this number is 1.
en_word_filename=sys.argv[2]
# This file contains all the bitext data. But only the english portion of those is used.
alignment_filenames=sys.argv[3:]
en_word={}
en_word["<BOS>"]=-1
en_word["<EOS>"]=-2
for i,e in enumerate(open(en_word_filename, "rb")):
    en_word[e.strip()]=i
for c_filename in alignment_filenames:
    print >> sys.stderr, c_filename
    for i,row in enumerate(open(c_filename, "rb")):
        if i%10000==0:
            print >> sys.stderr, i
        try:
            [fr, en, fr2en_al]=row.strip().split(" ||| ")
        except:
            print >>sys.stderr, "COULD NOT SPLIT", row
            continue
        en=["<BOS>"]+en.strip().split(" ")+["<EOS>"]
        i=context_window_size
        while i < len(en)-context_window_size:
            arr=[]
            for e in range(i-context_window_size,i+context_window_size+1):
                try:
                    arr.append(str(en_word[en[e]]))
                except:
                    print >>sys.stderr, "Error: ", en[e]
                    i=e+1+context_window_size
                    break
            sys.stdout.write(" ".join(arr))
            sys.stdout.write("\n")
            

