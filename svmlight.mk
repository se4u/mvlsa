%.svmlight.gz: %.svmlight
	gzip $<
%.svmlight:
	matlab -nojvm -r "load('$(@D)/$(basename $(@F)).mat'); addpath('src/serialization_code'); svmlwrite('$@', $(VARNAME), '%d'); exit"
