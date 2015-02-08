NAME := mvppdb_poster
PDFCMD := pdflatex \\nonstopmode\\input
.PHONY: $(NAME).pdf
pdf $(NAME).pdf: $(NAME).tex $(NAME).aux $(NAME).bib $(NAME).blg
	$(PDFCMD)  $<

$(NAME).blg $(NAME).bib: $(NAME).aux
	bibtex $(NAME)

$(NAME).aux: $(NAME).tex
	$(PDFCMD) $(NAME).tex

o_%:
	open $(NAME).$*
cl:
	-rm $(NAME).[abol][oubl]* $(NAME).tex~

figures.pdf:
	scp make_*_figure.py prastogi@external.hltcoe.jhu.edu:~/projects/ ;\
	ssh prastogi@external.hltcoe.jhu.edu -t "cd projects; python make_comparative_figure.py ; python make_ablative_figure.py;"; \
	scp prastogi@external.hltcoe.jhu.edu:~/projects/*_figure.pdf ./ ; \
	scp prastogi@external.hltcoe.jhu.edu:~/projects/make_*_figure.py ./ ;
