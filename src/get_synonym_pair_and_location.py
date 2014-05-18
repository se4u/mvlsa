import sys, re
reg=re.compile("[^a-zA-Z]")
d={}
for i, word in enumerate(open(sys.argv[1])):
    word=word.strip().lower()
    if not reg.search(word):
        d[word]=i

from nltk.corpus import wordnet
def get_synonym_from_oracle(word):
    return set([lemma.name for synset in wordnet.synsets(word) for lemma in synset.lemmas if not reg.search(lemma.name) and word != lemma.name])
l=[]
for word in d:
    if d[word] is not None:
        syn_list=get_synonym_from_oracle(word)
        for syn in syn_list:
            if syn in d and d[syn] is not None:
                tmp=[word, d[word], syn, d[syn]]
                print " ".join((str(e) for e in tmp))
                l.append(tmp)
                d[word]=None
                d[syn]=None
                break
