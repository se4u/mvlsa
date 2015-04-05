import sys, linecache

syn_loc_file=sys.argv[1]
embeddings_file=sys.argv[2]
explode=False
if len(sys.argv) >= 4 and sys.argv[3]=="explode":
    explode=True
def transform(line, explode):
    if explode:
        line=line.split("\t")
        if len(line) == 1:
            return line[0]
        line[1]=" ".join(list(line[1]))
        line = "\t".join(line)
    return line
print "useless_line_kept_for_file_format_compatibility"
for row in open(syn_loc_file):
    [_, a, _, b]=row.strip().split()
    sys.stdout.write(transform(linecache.getline(embeddings_file, int(a)+1), explode))
    sys.stdout.write(transform(linecache.getline(embeddings_file, int(b)+1), explode))
