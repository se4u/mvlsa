from __future__ import division
conditions="Glove W2Vec(Skipgram) MVLSA(Glove+W2Vec) MVLSA(Wiki) MVLSA(Allviews) MVLSA(Allviews+Glove+W2Vec)".split()
viewperf=r"""
MEN    & 70.4 & 73.9 & 76.0 & 71.4 & 71.2 & 75.8    
RW     & 28.1 & 32.9 & 37.2 & 29.0 & 41.7 & 40.5  
SCWS   & 54.1 & 65.6 & 60.7 & 61.8 & 67.3 & 66.4  
SIMLEX & 33.7 & 36.7 & 41.1 & 34.5 & 42.4 & 43.9 
WS     & 58.6 & 70.8 & 67.4 & 68.0 & 70.8 & 70.1   
MTURK  & 61.7 & 65.1 & 59.8 & 59.1 & 59.7 & 62.9   
WS-REL & 53.4 & 63.6 & 59.6 & 60.1 & 65.1 & 63.5   
WS-SEM & 69.0 & 78.4 & 76.1 & 76.8 & 78.8 & 79.2   
RG     & 73.8 & 78.2 & 80.4 & 71.2 & 74.4 & 80.8   
MC     & 70.5 & 78.5 & 82.7 & 76.6 & 75.9 & 77.7    
An-SYN  & 61.8 & 59.8 & 51.0 & 42.7 & 60.0 & 64.3    
An-SEM  & 80.9 & 73.7 & 73.5 & 36.2 & 38.6 & 77.2        
TOEFL  & 83.8 & 81.2 & 86.2 & 78.8 & 87.5 & 88.8"""


viewperf=viewperf.split("\n")
colors="gbcykr"
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from pylab import savefig
fig = plt.figure()
ax = fig.add_subplot(1,1,1)
xlab=[]
width=0.8
patch_height=0.7
ba=[]
pa=[]
for idx, row in enumerate(viewperf[1:]):
     row=row.split("&")
     dataset=row[0]
     # The dataset is the xlabel
     xlab.append(dataset.strip())
     perf=[float(e) for e in row[1:]]     
     # Plot the last number as a bar
     bar_artist,=plt.bar(idx+0.1, perf[-1], 
                         width=width, 
                         color=colors[-1],
                         edgecolor='black',
                         linewidth=0.4,
                         alpha=0.8)
     bar_artist.set_label(conditions[-1].replace("(", " (").replace("Allviews", "All Views"))
     ba.append(bar_artist)
     # Plot the rest of them as boxes on the bar.
     for j, p in enumerate(perf[0:-1]):
          patch_artist=ax.add_patch(plt.Rectangle((idx+0.01*j, p-patch_height), 
                                                  width, 
                                                  patch_height, 
                                                  facecolor=colors[j],
                                                  alpha=0.7,
                                                  label=conditions[j].replace("(", " (").replace("Allviews", "All Views"),
                                                  edgecolor='white',
                                                  linewidth=0.4,
                                                  ))
          pa.append(patch_artist)
ax.set_xlim(xmax=len(xlab))
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
ax.yaxis.set_minor_locator(MultipleLocator(5))
ax.yaxis.set_ticks_position('both')
ax.set_xticklabels([""]+xlab, rotation=45, ha='left')
ax.xaxis.set_major_locator(MultipleLocator(1))
ax.xaxis.set_ticks_position('bottom')
ax.set_title('Comparison between Word2Vec, Glove and MVLSA',
             color='black')
ymin=25
ax.legend(handles=[ba[-1], pa[-3], pa[-1], pa[-2], pa[-5], pa[-4]], 
          loc=(.08, .74),
          prop={'size':9},
          shadow=True)
ax.set_ylabel("Correlation")
plt.axvline(x=9.95, color='black')
ax.set_ylim(ymin=ymin)
ax.set_yticklabels(["%.2f"%(e/100) for e in range(ymin-5,100,10)])
ax.text(13.2, ymin+37, 'Accuracy', fontsize=13, rotation=270, color='gray')
savefig("comparative_figure.pdf", bbox_inches='tight')

