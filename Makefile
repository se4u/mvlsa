all:
	pdflatex mvppdb; bibtex mvppdb; pdflatex mvppdb; bibtex mvppdb

c:
	rm -f *.aux *.bbl *.blg *.log *.out *~

v:
	open mt-lrec-14.pdf
