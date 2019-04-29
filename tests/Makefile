IDSDEF= ../../xml/IDSDef.xml

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))

GENSOURCES=$(addprefix private/rand_,$(addsuffix .m,$(IDSNAMES)))

all: $(GENSOURCES)

install:

clean:
	$(RM) *~

clean-src: clean
	$(RM) $(GENSOURCES)

$(GENSOURCES): TestSuite.xsl $(IDSDEF)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:$<
#	xsltproc $< $(IDSDEF)
#ifneq "$(shell which emacs 2> /dev/null)" ""
#	@for file in $(GENSOURCES); do \
            echo "emacs -batch $$file --eval '(indent-region (point-min) (point-max) nil)' -f save-buffer"; \
            emacs -batch $$file --eval '(indent-region (point-min) (point-max) nil)' -f save-buffer; \
        done
#else
#	echo "Skip indenting $(GENSOURCES)"
#endif

test: $(GENSOURCES)
	matlab -nodisplay -r "addpath ../lib ../matlab;res = runtests('imas_unit_tests');exit(~all([res.Passed]))"

