import sys
file_name=sys.argv[1]
col_names={"bvgnFull_extrinsic_test":["bvgnFull"],
           "bitext_extrinsic_test_300_7000_1e-8_logCount.300":["O", "G", "U", "V"],
           "monotext_extrinsic_test_v2_gcca_run_sans_mu_300_7000_1e-8_logCount":["O", "G", "U", "V"],
           "fullgcca_extrinsic_test_v3_gcca_run_sans_mu_300_1000_1e-8_logCount":["O", "G", "U", "V"],
           "other_extrinsic_test_glove.42B.300d":["glove42"],
           "other_extrinsic_test_glove.6B.300d":["glove6"]}[file_name]

row_header=[]
row_cnt=0
data={}
for i,row in enumerate(sys.stdin):
    row=[e.strip() for e in row.strip().split("\t")]
    if row[1]==col_names[0]:
        row_header.append(row[0])
        row_cnt+=1
    else:
        assert row[0]==row_header[i%row_cnt], str((row, row_header, i, row_cnt))
    data[(row[0], row[1])]=row[2]

# TODO: Pretty insert tabs on the basis of maximum length of
# row_header that appear on the left hand side. 
print "\t\t"+"\t".join(col_names)
for r in row_header:
    print "\t".join([r, "\t"]+[data[(r, c)] for c in col_names])
    
        
