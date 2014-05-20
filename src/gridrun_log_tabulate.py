import sys, os, re
from collections import defaultdict 

vocab_relation_prefix="the number of vocab_relation_count "
unique_label_prefix="the number of unique labels is "
time_input_prep_prefix="input prepared in "
time_floodfill_prefix="Floodfill complete in "
#First open the log/gridrun files and make a jobid to parameter map
jid2param={}
#param2jid={}
for row in open(r"log/gridrun"):
    if row.startswith("Your job "):
        a=row.split()
        jid=a[2]
        param=a[3][10:-2]
        jid2param[jid]=param

# fail_pid dont really give me a lot of info, because they dont have job id
# fail_pid=[e[10:-4] for e
#           in os.listdir(os.path.join(os.getcwd(), "log"))
#           if e.startswith("hs_err_pid")]
fail_jid=defaultdict(str)
results={}
f=r"\d+\.\d+"
frag="Knn complete in (%s) with Accuracy : (%s) over "
reg_acc_orig=re.compile((frag+"original embedding")%(f, f))
reg_acc_U=re.compile((frag+"U(?!_)")%(f, f))
for jid, param in jid2param.items(): #Process all the logs
    fname=os.path.join("log", "gridrun_%s.o%s"%(param, jid))
    assert os.path.exists(fname), fname
    log=open(fname, "rb").readlines()
    assert log[0].startswith("make")
    assert param in log[1]
    # Skip log[2] to log[11] since that's matlab preamble.
    # Check that make gracefully exited.
    if not log[-1].startswith("make[1]: Leaving directory"):
        fail_jid[jid]+="didnt reach end "
    l=[e for e in log if e.startswith("Stop KNN: Not a single class with ")]
    if len(l) > 0:
        results[param]=str(-1)
        continue
    reg=None
    if param[-1]=="1":
        reg=reg_acc_orig
    elif param[-1]=="0":
        reg=reg_acc_U
    else:
        raise Exception(NotImplementedError)
    #import pdb; pdb.set_trace()
    l=[e for e in log if reg.match(e)]
    if len(l)==0:
        fail_jid[jid]+="couldnt do knn "
        results[param]=str(-2)
    else:
        assert len(l)==1
        results[param]=reg.match(l[0]).groups()[1]
    continue

ppdb_size_list=['s', 'l']
dist_list=['cosine', 'euclidean']
knnK_list=[str(e) for e in [1, 4, 8, 16]]
cca_dim_list=['0']+[str(e) for e in xrange(10, 310, 20)]
on_original=['0', '1']
# I want to show ppdb_size x dist number of tables.
for p in ppdb_size_list:
    for d in dist_list:
        print p, " ", d
        print "\t".join(["knn"]+cca_dim_list)
        for k in knnK_list:
            sys.stdout.write(k)
            for cd in cca_dim_list:
                sys.stdout.write("\t"+results["_".join([p, d, k, cd, "1" if cd=="0" else "0"])][:5])
            sys.stdout.write("\n")
        sys.stdout.write("\n")
    
    
print "-2 indicates that job crashed"
print "-1 indicates that there weren't enough labels in a class"
