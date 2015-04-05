import sys, gzip,lib_util

# Read the google file.
google_f=open(sys.argv[1], 'rb')
[total_words, _dim]=[int(e) for e in google_f.next().strip().split()]
google_wordset=set([row.strip().split(" ")[0] for row in google_f])
google_f.seek(0); google_f.next()
assert len(google_wordset)==total_words

# Read the PPDB file
ppdb_wordset=set(word.strip() for word in open(sys.argv[2], 'rb'))
def print_to_output(wf, word, arr):
    wf.write(word)
    for num in arr[1:]:
        wf.write("\t")
        wf.write(num)
    wf.write("\n")
    return

def stuff(google_f, wf, google_wordset):
    g_wordlist=[]
    outputted_words={}
    for row in google_f:
        arr=row.strip().split(" ")
        word=arr[0]
        tword=word.replace("_", "-").lower()        
        assert word in google_wordset, word
        # Basically their can be words like ZURICH and Zurich
        # in the google corpus. Which one do I pick ?
        # I could average but that's not really any better than just
        # picking the first one I see and rejecting the rest. so
        # that's what i am doing here.
        if word in ppdb_wordset:
            g_wordlist.append(word)
            outputted_words[word]=None
            print_to_output(wf, word, arr)
        elif (tword in ppdb_wordset) \
                and (tword not in google_wordset) \
                and (tword not in outputted_words): 
            g_wordlist.append(tword)
            outputted_words[tword]=None
            print_to_output(wf, tword, arr)
        else:
            g_wordlist.append(word)
    google_f.close()
    wf.close()
    return g_wordlist

with gzip.open(sys.argv[3], 'wb') as wf:
    g_wordlist = stuff(google_f, wf, google_wordset)

g=set(g_wordlist)
print "In Both ", len(g.intersection(ppdb_wordset))

print "In Google not in PPDB", \
    lib_util.count_and_print(open(r"res/in_google_not_in_ppdb", "wb"), \
                                 g-ppdb_wordset)

print  "In PPDB not in Google", \
    lib_util.count_and_print(open(r"res/in_ppdb_not_in_google", "wb"), \
                                 ppdb_wordset-g)
