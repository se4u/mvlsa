import sys, os, re
from StringIO import StringIO
from collections import defaultdict 

vocab_relation_prefix="the number of vocab_relation_count "
unique_label_prefix="the number of unique labels is "
time_input_prep_prefix="input prepared in "
time_floodfill_prefix="Floodfill complete in "
#First open the log/gridrun files and make a jobid to parameter map
jid2param={}
param2jid={}
for row in open(r"log/gridrun"):
    if row.startswith("Your job "):
        a=row.split()
        jid=a[2]
        param=a[3][10:-2]
        jid2param[jid]=param
        param2jid[param]=jid

fail_jid=defaultdict(str)
results={}
f=r"\d+\.\d+"
frag="Knn complete in (%s) with Accuracy : (%s) over "%(f,f)
reg_acc_orig=re.compile(frag+"original embedding")
reg_acc_U=re.compile(frag+"U(?!_)")
reg_acc_AU=re.compile(frag+"AU")
for jid, param in jid2param.items(): #Process all the logs
    fname=os.path.join("log", "gridrun_%s.o%s"%(param, jid))
    if not os.path.exists(fname):
        fail_jid[jid]+="job not complete "
        results[param]=str(-3)
        continue;
    log=open(fname, "rb").readlines()
    assert log[0].startswith("make")
    assert param in log[1]
    # Skip log[2] to log[11] since that's matlab preamble.
    # Check that make gracefully exited.
    host_preamble=[i for i,e in enumerate(log) if e.startswith("I am running on machine")]
    if len(host_preamble)>0:
        hostname=log[host_preamble[0]+1].strip()
    else:
        hostname=""
    if not log[-1].startswith("make[1]: Leaving directory"):
        fail_jid[jid]+="host %s, didnt reach end "%hostname
    l=[e for e in log if e.startswith("Stop KNN: Not a single class with ")]
    if len(l) > 0:
        results[param]=str(-1)
        continue
    l=[e for e in log if e.startswith("Out of memory.") ]
    if len(l) > 0:
        fail_jid[jid]+="Out of memory "
        results[param]=str(-4)
    #reg_acc_AU, reg_acc_U, reg_acc_orig
    for reg in [reg_acc_orig, reg_acc_U, reg_acc_AU]:
        l=[e for e in log if reg.match(e)]
        if len(l) > 0:
            break
    if len(l)==0:
        fail_jid[jid]+="host %s, couldnt do knn "%hostname
        results[param]=str(-2)
    else:
        assert len(l)==1
        results[param]=reg.match(l[0]).groups()[1]
    continue

ppdb_size_list=['s', 'l']
dist_list=['cosine']
knnK_list=[str(e) for e in [1, 2 , 3 , 4 ]]
cca_dim_list=['1']+[str(e) for e in xrange(10, 290, 40)]+['300','0']
cca_app_list=[str(e) for e in xrange(10, 210, 40)]
on_original=['0', '1']
# I want to show ppdb_size x dist number of tables.
out1 = StringIO()
out2 = StringIO()
def print2both(out1, out2, s):
    out1.write(s)
    out2.write(s)
for p in ppdb_size_list:
    for d in dist_list:
        print2both(out1, out2,  p+" "+d+"\n")
        print >>out1, "\t".join(["knn"]+cca_dim_list[:-1])
        print >>out2, "\t".join(["knn"]+cca_app_list)
        for k in knnK_list:
            print2both( out1, out2, k)
            for cd in cca_dim_list:
                out1.write("\t"+results["_".join([p, d, k, "1" if cd=="0" else "0", cd, "0", "0"])][:5])
            for ca in cca_app_list:
                out2.write("\t"+results["_".join([p, d, k, "0", "0", "1", ca])][:5])
            print2both(out1, out2, "\n")
        print2both(out1, out2, "\n")
print out1.getvalue()
print out2.getvalue()
print "-4 indicates OutOfMemory"
print "-3 indicates job not complete"    
print "-2 indicates that job crashed"
print "-1 indicates that there weren't enough labels in a class"
for k,e in fail_jid.items():
    print k, jid2param[k], e







