%.svmlight.gz: %.svmlight
	gzip $<
%.svmlight:
	matlab -nojvm -r "load('$(@D)/$(basename $(@F)).mat'); addpath('src/general_utility/serialize'); svmlwrite('$@', $(VARNAME), '%d'); exit"
