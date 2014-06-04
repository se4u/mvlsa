import sys, re
def fnc(log, i):
    f=re.compile(r"(\d+\.\d+)")
    l=lambda(i): f.search(log[i]).group(0)[:6]
    mrr = l(i)
    ken = l(i+1)
    spr = l(i+2)
    pcr = l(i+3)
    return [mrr, ken, spr, pcr]


print "size_uniqmap\tMRR\tKendall\tSwap\tPearsonCorr"
for fname in sys.argv[1:]:
    log=open(fname, "rb").readlines()
    i=[i for (i,e) in enumerate(log) if e.startswith("The MRR (1 indexed) over original embedding is")][0]
    sys.stdout.write(fname[-3:]+"_orig     "+"\t".join(fnc(log, i))+"\n")
    sys.stdout.write(fname[-3:]+"_CCA      "+"\t".join(fnc(log, i+4))+"\n\n")
