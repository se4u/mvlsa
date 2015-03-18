# Take the input file which is a ppdb-input-* file
# then remove the
# parse from the english side. and store to output.
import sys, re
input_filename=sys.argv[1]
output_filename=sys.argv[2]
reg=re.compile("([^ \)]+)\)")
with open(output_filename, "wb") as outf:
    for row in open(input_filename, "rb"):
        [fr, en, al]=row.decode('utf8').split(u" ||| ")
        en=u" ".join(reg.findall(en))
        out=(u" ||| ".join([fr, en, al])).encode('utf8')
        outf.write(out)
