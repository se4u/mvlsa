import sys
google_f=open(sys.argv[1], 'rb')
big_vocab_en_f=open(sys.argv[2], 'rb')
output_count_embedding_filename=sys.argv[3]

# Handle big_vocab input file
big_vocab={}
for row in open(sys.argv[2], 'rb'):
    [word, count]=row.strip().split("\t")
    big_vocab[word]=count

# Handle google_f input file
[total_words, _dim]=[int(e) for e in google_f.next().strip().split()]
with open(output_count_embedding_filename, "wb") as out_f:
    for row in google_f:
        row=row.strip().split(" ")
        word=row[0]
        row=" ".join(row[1:])
        if word in big_vocab:
            print >> out_f, word, str(big_vocab[word]), row

