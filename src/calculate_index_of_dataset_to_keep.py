import sys
GCCA_OR_ST=sys.argv[1]
name_id_map=dict(ar="1", cs="2", de="3", es="4", fr="5", zh="6",
                 en="7",
                 bvgn="8",
                 monotext1="9", monotext2="10", monotext4="11", monotext6="12", monotext8="13",
                 monotext10="14", monotext12="15", monotext14="16", monotext15="17")
total=[str(e) for e in range(1,len(name_id_map)+1)]
if GCCA_OR_ST.startswith("stgccano") or GCCA_OR_ST.startswith("gccano"):
    idx=GCCA_OR_ST.index("no") #Note that this gives the first index only.
    toremove=GCCA_OR_ST[idx+2:]
    if  toremove.isdigit():
        toremove=[toremove]
    elif toremove.startswith("enbvgn") or toremove.startswith("bvgnen"):
        if toremove in ["enbvgn", "bvgnen"]:
            toremove=["en", "bvgn"]
        else:
            toremove=toremove[6:].split("@")+["en", "bvgn"]
        if not toremove[0].isdigit():
            toremove=[name_id_map[e] for e in toremove]
    elif toremove.startswith("@"):
        toremove=[name_id_map[e] for e in toremove.split("@") if e != ""]
    else:
        toremove=[name_id_map[toremove]]
    print ",".join(e for e in total if e not in toremove)
elif "only" in GCCA_OR_ST:
    idx=GCCA_OR_ST.index("only")
    tokeep=GCCA_OR_ST[idx+4:]
    print name_id_map[tokeep]
else:
    print ",".join(total)
