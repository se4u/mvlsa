import sys
for l in open(sys.argv[1], "rb"):
    l=l.strip().split(" ||| ")
    p=l[2].split("\t")
    print "\t".join([l[1], p[0], p[1]])

