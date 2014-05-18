import sys, pexpect
ppdb_wordlist=[e.strip() for e in open(sys.argv[1], "rb")]
repetition=int(sys.argv[2])
ppdb_size=sys.argv[3]
ppdb_worddict={}
for i, e in enumerate(ppdb_wordlist):
    ppdb_worddict[e]=i+1

assert len(ppdb_worddict)==len(ppdb_wordlist)

class Paraphraser:
    def __init__(self, repetition):
        command = r"java -cp src/joshua.jar joshua.util.PackedGrammarServer /export/a15/prastog3/ppdb-%s-lex.packed %d"%(ppdb_size, repetition)
        self._process=pexpect.spawn(command)
        self._process.delaybeforesend=0
        self._process.expect_exact("--> ")
        assert self._process.isalive()
        return
    
    def paraphrase(self, target, ppdb_worddict):
        self._process.sendline(target)
        self._process.expect_exact("--> ")
        _ret=self._process.before.strip().split("\n")
        if len(_ret) < 3:
            return []
        ret = _ret[2:]
        return [e for e in ret if e in ppdb_worddict]

lp=Paraphraser(repetition)
for w in ppdb_wordlist:
    for _ in range(repetition):
        out=lp.paraphrase(w, ppdb_worddict)
        for p in out:
            print w, p, ppdb_worddict[w], ppdb_worddict[p]
