import sys, random, linecache
in_file=sys.argv[1]
num_of_para_pair_to_print=int(sys.argv[2])
num_line=sum(1 for  e in open(in_file).readlines())
random.seed(89)
cnt=0
d={}
while cnt < num_of_para_pair_to_print:
    rand_idx=random.randint(0, num_line-1)
    l=[e for e in linecache.getline(in_file, rand_idx).strip().split(",") if " " not in e]
    ll=len(l)
    if ll < 2:
        continue
    r1=random.randint(0, ll-1)
    r2=random.randint(0, ll-1)
    r2 = (r2 + (r2==r1))%ll
    if r1 > r2:
        r1, r2 = r2, r1
    else:
        pass
    if (rand_idx, r1, r2) in d:
        continue
    else:
        d[(rand_idx, r1, r2)]=1
        cnt+=1
        print l[r1], l[r2]
