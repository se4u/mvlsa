import sys
file_name=sys.argv[1]
def get_col_name(file_name):
    if file_name == "bvgnFull_extrinsic_test":
        col_name=["bvgnFull"]
    elif any(file_name.startswith(e) for e in ["bitext_extrinsic_test", "monotext_extrinsic_test", "fullgcca_extrinsic_test"]):
        col_name=["O", "G", "U", "V"]
    elif file_name=="other_extrinsic_test_glove.6B.300d":
        col_name=["glove6"]
    elif file_name=="other_extrinsic_test_glove.42B.300d":
        col_name=["glove42"]
    return col_name
col_name=get_col_name(file_name)
row_header=[]
row_cnt=0
data={}
for i,row in enumerate(sys.stdin):
    row=[e.strip() for e in row.strip().split("\t")]
    if row[1]==col_name[0]:
        row_header.append(row[0])
        row_cnt+=1
    else:
        assert row[0]==row_header[i%row_cnt], str((row, row_header, i, row_cnt))
    data[(row[0], row[1])]=row[2]

# TODO: Pretty insert tabs on the basis of maximum length of
# row_header that appear on the left hand side. 
print "\t\t"+"\t".join(col_name)
for r in row_header:
    print "\t".join([r, "\t"]+[data[(r, c)] for c in col_name])
    
        
