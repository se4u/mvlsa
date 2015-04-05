# Filename: filter_ellie_vocab.py
# Description: 
# Author: Pushpendre Rastogi
# Created: Sat Mar 21 16:50:48 2015 (-0400)
# Last-Updated: Sat Mar 21 16:51:56 2015 (-0400)
#           By: Pushpendre Rastogi
#     Update #: 1

# Commentary: 
# 
import sys
d=set([e.strip().split()[0] for e in open(sys.argv[1])])
for row in open(sys.argv[2]):
    if row.strip() not in d:
        sys.stdout.write(row)
