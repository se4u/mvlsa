# IT recives the following input on stdin and then it just splits the
# lines by commas properly and make sure that there are no invalid expressions.
# INPUT : 
# [nsubj(giving, I), dep(giving, was), root($WALL$, giving), dobj(giving, time)]
# [nsubj('s, It), root($WALL$, 's), amod(Texas, central), prep_in('s, Texas)]
# DESIRED OUTPUT:
# nsubj	giving	I
# dep	giving	was
import sys, re
def make_dep_dict(inp):
    inp=inp.split(",")
    retval={}
    for e in inp:
        optdic=dict(reverse=False,replace=False)
        if "-" == e[0]:
            e=e[1:]
            optdic["reverse"]=True
        elif "+" == e[0]:
            e=e[1:]
            optdic["replace"]=e.split(".")[0]
            e=e.replace(".", "")
        if not optdic["replace"]:
            optdic["replace"]=e
        retval[e]=optdic
    return retval

def reverse(a,b,c):
    if c:
        return[b,a]
    else:
        return [a,b]
vocab=dict((x[1].strip(), x[0])     # 1
           for x in enumerate(open(sys.argv[1])))
dep_dict=make_dep_dict(sys.argv[2]) # 2
dep_index=dict((e.strip(), i)       # 3
               for i,e
               in enumerate(sys.argv[3].split(",")))
reg=re.compile(r"([^, (]+)\(([^, ]+), ([^) ]+)\)")
with open(sys.argv[4], "wb") as out_file:
    for outcnt, row in enumerate(sys.stdin):
        # Basically 8, 18, 26 ... and so on contain the
        # Collapsed stanford dependency parses that I need
        # So I skip the rest.
        if (outcnt-8)%10 != 0:
            continue
        # The lines are enclosed by useless square brackets.
        row=row.strip()[1:-1]
        for dep in reg.finditer(row):
            dep=dep.groups()
            try:
                # Check whether the words are members of vocabulary.
                d0=dep_dict[dep[0]]
                d1=vocab[dep[1].lower()]
                d2=vocab[dep[2].lower()]
            except:
                continue
            # The pobj relation has swaps the contexts and rows
            # So I reverse in that case. That is told to me by "reverse"
            # field
            if d0["reverse"]:
                d1, d2 = d2, d1
            out_file.write("%d %d %d\n"%(dep_index[d0["replace"]],d1,d2))
