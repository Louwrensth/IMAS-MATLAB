IDSDEF= ../../xml/IDSDef.xml

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))

GENSOURCES=

all: $(GENSOURCES)

install:

clean:
	$(RM) *~

clean-src: clean
	$(RM) $(GENSOURCES)

$(GENSOURCES): $(IDSDEF)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:$<

test: $(GENSOURCES)
	matlab -nodisplay -r "addpath ../lib ../matlab;res = runtests('imas_unit_tests');exit(~all([res.Passed]))"

