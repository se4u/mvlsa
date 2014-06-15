import sys
for l in open(sys.argv[1], "rb"):
    l=l.strip().split(" ||| ")
    score=l[0].split("\t")[0]
    p0=l[1]
    p1=l[2].split("\t")[0]
    print "\t".join([p0, p1, score])

