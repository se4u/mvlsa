NAME := mvppdb
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
	rm $(NAME).[abol][oubl]* $(NAME).tex~
