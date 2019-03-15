IDSDEF= ../../xml/IDSDef.xml

GENSOURCES=imas_test.m ids_rand.m

all: $(GENSOURCES)

install:

clean:
	$(RM) *~

clean-src: clean
	$(RM) $(GENSOURCES)

$(GENSOURCES): TestSuite.xsl $(IDSDEF)
	xsltproc $< $(IDSDEF)

test: $(GENSOURCES)
	matlab -nodisplay -r'runtests(imas_test)'

