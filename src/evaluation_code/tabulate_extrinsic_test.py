import sys, re
def fnc(log, i):
    try:
        f=re.compile(r"(\d+\.?\d*)")
        l=lambda(i): f.search(log[i][10:]).group(1)[:6]
        tsl=l(i)
        mrco=l(i+1)
        mrr = l(i+2)
        ken = l(i+3)
        spr = l(i+4)
        pcr = l(i+5)
    except:
        import pdb; pdb.set_trace()
    return [tsl, mrco, mrr, ken, spr, pcr]


print "size_unq_map test_size\tMRR_clc\tMRR\tKendall\tSwap\tPearsonCorr"
for fname in sys.argv[1:]:
    log=open(fname, "rb").readlines()
    i=[i for (i,e) in enumerate(log) if e.startswith("The actual test set length is")][0]
    sys.stdout.write(fname[-3:]+"_orig     "+"\t".join(fnc(log, i))+"\n")
    sys.stdout.write(fname[-3:]+"_CCA      "+"\t".join(fnc(log, i+6))+"\n\n")
