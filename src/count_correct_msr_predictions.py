"""Goes through the log file named in the argument and counts how many predictions we got right
"""
__date__    = "11 November 2014"
__author__  = "Pushpendre Rastogi"
__contact__ = "pushpendre@jhu.edu"

import sys
correct=0.0
total=0
for row in open(sys.argv[1], "rb"):
    if row.startswith("i="):
        row=row.strip().split()
        total+=1
        correct+=(1.0 if row[2][:-1] == row[-1] else 0.0)

print 0 if total==0 else correct/total, correct, total
