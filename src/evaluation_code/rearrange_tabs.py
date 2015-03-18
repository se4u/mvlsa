"""Rearrange the tab_Spearman outputs according to the order provided on the command line
"""
__date__    = "14 November 2014"
__author__  = "Pushpendre Rastogi"
__contact__ = "pushpendre@jhu.edu"

import sys
order=sys.argv[1:]
data = [row for row in sys.stdin]
for o in order:
    for d in data:
        if o in d:
            print d,
    if "NNN" == o.strip():
        print " "
