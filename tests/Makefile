# This Makefile expects you've got UAL already built (using the installer), but not yet installed, so we're testing the current build.

IDSDEF= ../../xml/IDSDef.xml

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))

GENSOURCES= IDS_list.h IDS_list.f90 IDS_test_f90.f90

all:

install:

clean:
	$(RM) *~ *.o *.mod

clean-src: clean
	$(RM) $(GENSOURCES)

$(GENSOURCES): test_utils.xsl $(IDSDEF)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:$<

test:
	LD_LIBRARY_PATH=$(realpath $(CURDIR)/../lib):$$LD_LIBRARY_PATH matlab -nodisplay -r "addpath ../lib ../matlab;res = runtests('imas_unit_tests');exit(~all([res.Passed]))"

.PHONY: all install clean clean-src perf_tools

perf_tools: run_perf_f90 imas_mex_c_workflow_tests

%.o: %.f90
	gfortran -O0 -g -c $^ -ffree-line-length-none  $(shell pkg-config --cflags imas-gfortran) -o $@

run_perf_f90: run_perf_f90.o IDS_list.o IDS_test_f90.o
	gfortran -O0 -g $^ -o $@ $$(pkg-config --libs imas-gfortran)

imas_mex_c_workflow_tests: imas_mex_c_workflow_tests.c | IDS_list.h 
	gcc -DTARGET_API_VERSION=700  -DUSE_MEX_CMD -D__USE_XOPEN2K8 -D_GNU_SOURCE -DMATLAB_MEX_FILE  -I"/gw/swvend/matlab/r2017a/extern/include" -I"/gw/swvend/matlab/r2017a/simulink/include" -fexceptions -fPIC -fno-omit-frame-pointer -pthread -g -Wl,--no-undefined -Wl,-rpath $(realpath ../lib) -L"/gw/swvend/matlab/r2017a/bin/glnxa64" -lmx -lmex -ldl $^ -o $@
