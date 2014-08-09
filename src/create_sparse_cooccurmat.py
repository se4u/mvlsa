import sys
# This file is used to map words to numeric indexes.
en_word_filename=sys.argv[1]

# This file contains all the bitext data. But only the english portion of those is used.
alignment_filenames=sys.argv[2:]
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
        for i in range(1,len(en)-1):
            try:
                arr=[str(en_word[en[e]]) for e in [i-1, i, i+1]]
                sys.stdout.write(" ".join(arr))
                sys.stdout.write("\n")
            except:
                print >>sys.stderr, "COULD NOT PROCESS", en[i-1], en[i], en[i+1]
                continue

