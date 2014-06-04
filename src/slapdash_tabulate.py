import sys, re
lp = ['log/large_scale_cca_%s_cosine_1_0_90_0_0_%d_0', # 90 kept after CCA
      'log/large_scale_cca_%s_cosine_1_0_170_0_0_%d_0', # 170 kept after CCA
      'log/large_scale_cca_%s_cosine_1_1_0_0_0_%d_0', # Original Embedding
      'log/large_scale_cca_%s_cosine_1_0_0_1_170_%d_0'] # Appended embedding

f=r"\d+\.\d+"
frag="Knn complete in (%s) with Accuracy : (%s) over .*"%(f,f)
print "\t".join(['ppdb_uum', '90_CCA', '170_CCA', 'Original', '170_App_CCA'])
for ppdb_size in ['s', 'l']:
    for used_unique_mapping in [0, 1]:
        sys.stdout.write("%s_%d"%(ppdb_size, used_unique_mapping))
        for lf in [e%(ppdb_size, used_unique_mapping) for e in lp]:
            sys.stdout.write("\t")
            try:
                log=open(lf, "rb").readlines()
            except:
                sys.stdout.write("NA")
                continue
            l=[e for e in log if e.startswith("Knn complete in")][0]
            if "_1_0_90_0_0_1_" in l or "_1_0_170_0_0_1_" in l:
                assert("over U" in l)
            elif "_1_1_0_0_0_1_" in l:
                assert("over original embedding") in l
            elif "_1_0_0_1_170_1_" in l:
                assert("over AU") in l
            try:
                a=re.match(frag, l).groups()[1]
                sys.stdout.write(a[:5])
            except:
                sys.stdout.write("NA")
        print ""
