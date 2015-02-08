from __future__ import division
viewperf=r"""{All \\Views} & !Framenet & !Morphology & !Bitext & !Wikipedia & !Dependency & {!Morphology\\!Framenet} & {!Morphology\\!Framenet\\!Bitext} \\
          MEN    & {70.1} & {69.8} & {70.1} & {69.9} & 46.4 & 68.4 & {69.5} & 68.4 \\
          RW     & {37.2} & {36.4} & {36.1} & 32.2 & 11.6 & 34.9 & 34.1 & 27.1 \\
          SCWS   & {66.4} & {65.8} & {66.3} & 64.2 & 54.5 & {65.5} & {65.2} & 60.8 \\{
          SIMLEX & 41.1 & 40.1 & 41.1 & 37.8 & 32.4 & {44.1} & 38.9 & 34.4 \\
          WS     & 69.4 & 69.1 & 69.2 & 67.6 & 43.1 & 70.5 & 69.3 & 66.6 \\
          MTURK  & 58.4 & 58.3 & 58.6 & 55.9 & 52.7 & 59.8 & 57.9 & 55.3 \\
          WS-REL & 61.6 & 61.5 & 61.4 & 59.4 & 38.2 & 63.5 & 62.5 & 58.8 \\
          WS-SEM & 76.8 & 76.3 & 76.7 & 75.9 & 48.1 & 75.7 & 75.8 & 73.1 \\
          RG     & 73.2 & 72.0 & 73.2 & 73.7 & 45.0 & 70.8 & 71.9 & 74.0 \\
          MC     & 78.3 & 75.7 & 78.2 & 78.2 & 46.5 & 77.5 & 76.0 & 80.2 \\}
          An-SYN  & {56.4} & {56.3} & {56.2} & 51.2 & 37.6 & 50.5 & 54.4 & 46.0 \\
          An-SEM  & 34.3 & 34.3 & 34.3 & {36.2} & 4.1  & 35.3 & 34.5 & 30.6 \\{
          TOEFL  & 82.5 & 82.5 & 82.5 & 71.2 & 45.0 & 85.0 & 82.5 & 65.0 """
viewperf=viewperf.replace("{", "").replace("}", "").replace(r"\\", "").split("\n")
conditions=viewperf[0].split("&")
colors="rgbcyk"
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
     perf=[float(e) for e in row[1:7]]     
     # Plot the first number as a bar
     bar_artist,=plt.bar(idx+0.1, perf[0], 
                         width=width, 
                         color=colors[0],
                         edgecolor='black',
                         linewidth=0.4,
                         alpha=0.8)
     bar_artist.set_label(conditions[0])
     ba.append(bar_artist)
     # Plot the rest of them as boxes on the bar.
     for j, p in enumerate(perf[1:]):
          patch_artist=ax.add_patch(plt.Rectangle((idx, p-patch_height), 
                                                  width, 
                                                  patch_height, 
                                                  facecolor=colors[j+1],
                                                  alpha=1,
                                                  label=conditions[j+1],
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
ax.set_title('Ablative analysis of performance versus Views',
             color='black')
ymin=25
ax.legend(handles=[ba[-1]]+pa[-5:], 
          loc='upper left',
          prop={'size':((ymin*2)/5)},
          shadow=True)
ax.set_ylabel("Correlation")
plt.axvline(x=9.95, color='black')
ax.set_ylim(ymin=ymin)
ax.set_yticklabels(["%.2f"%(e/100) for e in range(ymin-5,100,10)])
ax.text(13.2, ymin+37, 'Accuracy', fontsize=13, rotation=270, color='gray')
savefig("ablative_figure.pdf", bbox_inches='tight')
