import sys
GCCA_OR_ST=sys.argv[1]
name_id_map=dict(ar="1", cs="2", de="3", es="4", fr="5", zh="6", en="7", bvgn="8", monotext10="9", monotext12="10", monotext14="11", monotext15="12")
total=[str(e) for e in range(1,len(name_id_map)+1)]
if "no" in GCCA_OR_ST:
    idx=GCCA_OR_ST.index("no")
    toremove=GCCA_OR_ST[idx+2:]
    if  toremove.isdigit():
        pass
    elif toremove in ["enbvgn", "bvgnen"]:
        toremove=[name_id_map["en"], name_id_map["bvgn"]]
    else:
        toremove=[name_id_map[toremove]]
    print ",".join(e for e in total if e not in toremove)
elif "only" in GCCA_OR_ST:
    idx=GCCA_OR_ST.index("only")
    tokeep=GCCA_OR_ST[idx+4:]
    print name_id_map[tokeep]
else:
    print ",".join(total)
