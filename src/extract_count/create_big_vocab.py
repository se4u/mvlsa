import sys
from collections import defaultdict
output_filename_prefix=sys.argv[1][:-2]
input_filenames=sys.argv[2:]
output_filename_en=output_filename_prefix+"en"
en_vocab=defaultdict(int)
unl=u"\n"
for filename in input_filenames:
    print >>sys.stderr, "FILE: "+filename
    output_filename=output_filename_prefix+filename[-2:]
    fr_vocab=defaultdict(int)
    for i, row in enumerate(open(filename, "rb")):
        print >>sys.stderr, i
        row=row.decode('utf8')
        try:
            [fr_sent, en_sent, _]=row.strip().split(u" ||| ")
        except:
            continue
        for fr_word in fr_sent.split(u" "):
            fr_vocab[fr_word]+=1
        for en_word in en_sent.split(u" "):
            en_vocab[en_word]+=1
    # Write the fr_vocab to file
    with open(output_filename, "wb") as output_file:
        for k in fr_vocab:
            out=(u"\t".join([k, unicode(fr_vocab[k])])).encode('utf8')
            output_file.write(out)
            output_file.write(unl)
# Write the en_vocab to file
with open(output_filename_en, "wb") as output_file:
    for k in en_vocab:
        out=(u"\t".join([k, unicode(en_vocab[k])])).encode('utf8')
        output_file.write(out)
        output_file.write(unl)
