# Filename: ppdb_phrase_analysis.py
# Description: A short script to analyze queries for soundness so that I dont have to stress over completeness
# Author: Pushpendre Rastogi
# Created: Tue Mar 17 02:23:25 2015 (-0400)
# Last-Updated: Tue Mar 17 23:08:20 2015 (-0400)
#           By: Pushpendre Rastogi
#     Update #: 44
# Commentary:
""" Questions to ask:
1. How many words there are in all the lists
2. How many of the words are in the high_priority, low_priority, ppdb files that don't exist in existing_vocab, Let's call them extra "words"
3. How many 'extra' words are there ? How many of these 'extra' words are numeric ? How many are gibberish ?
4. How many of of the phrases are in the  high_priority, low_priority, ppdb files that don't exist in existing_vocab
Let's call these phrases "extra_phrases"
5. How many of the 'extra_phrases' are numeric ? How many are gibberish ?

Q1 length of existing_vocab 361082
Q1 length of high_priority_file 26937
Q1 length of low_priority_file 63549
Q1 length of ppdb_file 1652925

Q2 Missing types from high_priority_file 1107 389 718
Q2 Missing types from low_priority_file 1690 674 1016
Q2 Missing types from ppdb_file 38501 16436 22065

Q3 high_priority_file 14669 2065 12604 656
Q3 low_priority_file 44797 2585 42212 1180
Q3 ppdb_file 1476414 217179 1259235 58549
"""
import functools
from collections import OrderedDict
from gzip import GzipFile
f_getlines = lambda fn: [tuple(e.strip().split())
                         for e
                         in GzipFile(filename=fn).read().strip().split('\n')]
fp = functools.partial
f_total = fp(filter, lambda x: True)
f_single = fp(filter, lambda x: True if len(x) == 1 else False)
f_phrase = fp(filter, lambda x: True if len(x) > 1 else False)
f_numeric_p = lambda x: any((e in x) for e in "0123456789.")
f_numeric = fp(filter, lambda x: True if f_numeric_p(x) else False)
f_numeric_phrase = fp(filter,
                      lambda x: (True
                                 if any(f_numeric_p(e) for e in x)
                                 else False))


def flatten_dict(lis):
    "doc"
    d = {}
    for tup in lis:
        for st in tup:
            d[st] = None
    return d

DIR = r"/export/a14/prastog3/"
files = OrderedDict(
    existing_vocab=f_getlines(DIR+r"combined_embedding_0.word.ascii.gz"),
    high_priority_file=f_getlines(DIR+r"rerank.gz"),
    low_priority_file=f_getlines(DIR+r"contexts.gz"),
    ppdb_file=f_getlines(DIR+r"ppdb.gz")
    )
"Question 1"
for f in ["existing_vocab", "high_priority_file", "low_priority_file",
          "ppdb_file"]:
    print "Q1 length of", f, len(files[f])

existing_vocab_set = set([e[0] for e in files["existing_vocab"]])
for f in ["high_priority_file", "low_priority_file", "ppdb_file"]:
    extra_words = set([e.replace('-', '') for e in flatten_dict(files[f]).keys()]) - existing_vocab_set
    numeric_extra_words = set(f_numeric(extra_words))
    remaining_extra_words = (extra_words - numeric_extra_words)
    print "Q2 Missing types from", f, len(extra_words), \
        len(numeric_extra_words), len(remaining_extra_words)
# set([e.replace('-', '') for e in remaining_extra_words]) - existing_vocab_set
# 539


def f_nonderivable(phrases, dic):
    def derivable_p(p):
        return (False
                if all(((e.replace('-', '') in dic)
                        or e.replace('-', '') == ''
                        or e == '-lrb-'
                        or e == '-rrb-')
                       for e
                       in p)
                else True)
    return filter(lambda p: derivable_p(p), phrases)

for f in ["high_priority_file", "low_priority_file", "ppdb_file"]:
    extra_phrases = set(files[f]) - set(files["existing_vocab"])
    numeric_extra_phrases = set(f_numeric_phrase(extra_phrases))
    remaining_extra_phrases = extra_phrases - numeric_extra_phrases
    non_derivable_extra_phrases = f_nonderivable(remaining_extra_phrases,
                                                 existing_vocab_set)
    print "Q3", f, len(extra_phrases), len(numeric_extra_phrases),\
        len(remaining_extra_phrases), len(non_derivable_extra_phrases)
