include ../Makefile.common

# Check that "Saxon-HE.jar" utility is set in CLASSPATH
#SAXONJARFILE?=Saxon-HE.jar
include ../Makefile.classpath

ifeq ("no","$(strip $(IMAS_MEX))")
all sources sources_install install clean clean-src:
	$(warning "Ignoring cppinterface (IMAS_MEX=no).")
else

ifeq "$(strip $(CC))" "icc"
 CC=icc
 CFLAGS=-g -fPIC -Wno-write-strings -Wno-deprecated -pthread -shared-intel
 LDFLAGS= -g -pthread
else
 CC=gcc
 CFLAGS=-DTARGET_API_VERSION=700  -DUSE_MEX_CMD -D__USE_XOPEN2K8 -D_GNU_SOURCE -DMATLAB_MEX_FILE  -I"$(MATLAB)/extern/include" -I"$(MATLAB)/simulink/include" -fexceptions -fPIC -fno-omit-frame-pointer -pthread -g
 LDFLAGS= -g -pthread -fPIC -Wl,--no-undefined -Wl,-rpath-link,$(MATLAB)/bin/glnxa64 -shared  -Wl,--version-script,"$(MATLAB)/extern/lib/glnxa64/c_exportsmexfileversion.map"  -L"$(MATLAB)/bin/glnxa64" -lmx -lmex -lmat -lm -lstdc++
endif

BUILD_DIR:=./build
LIB_DIR:=./lib
SRC_DIR:=./src
IDS_SRC_DIR:=$(SRC_DIR)/ids
INCDIR=-I$(SRC_DIR) -I$(IDS_SRC_DIR) -I../lowlevel

IDSDEF= ../xml/IDSDef.xml
LIBS=-Wl,-rpath $(realpath $(CURDIR)/../lowlevel) -L../lowlevel -limas

# Check existence of the "indent" utility to get a clean C format
ifeq "$(shell which indent 2> /dev/null)" ""
 BEAUTIFY = echo
else
 BEAUTIFY = indent -kr --no-tabs -l1000 -fc1
endif

# Sets a path where make will search for files
VPATH = $(SRC_DIR) $(IDS_SRC_DIR) build lib

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))

# Generated sources (excluding static sources)
IDS_C_FILES = $(addprefix get_,$(addsuffix .c,$(IDSNAMES)))
IDS_C_FILES+= $(addprefix get_slice_,$(addsuffix .c,$(IDSNAMES)))
MEX_IDS_FILES = $(addsuffix .c,ids_get ids_get_slice)
# ids_put ids_put_slice ids_put_non_timed)
GENSOURCES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_C_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(MEX_IDS_FILES))
# Add static sources
MEX_SRC_FILES = $(addsuffix .c, imas_open imas_open_env \
				imas_open_hdf5 imas_open_public \
				imas_create imas_create_env \
				imas_create_hdf5 imas_create_public \
				imas_close \
				imas_enable_mem_cache imas_disable_mem_cache \
				imas_flush_mem_cache imas_discard_mem_cache \
				)
SOURCES = $(GENSOURCES) 
SOURCES+= $(addprefix $(SRC_DIR)/,$(MEX_SRC_FILES) imas_mex_utils.c)

# Compiled objects
IDS_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(IDS_C_FILES:.c=.o))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,imas_mex_utils.o)
OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_SRC_FILES:.c=.o))
OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_IDS_FILES:.c=.o))
#TARGETS = $(addprefix $(LIB_DIR)/,libids_get-mex.so)
TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_SRC_FILES:.c=.mexa64))
TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_IDS_FILES:.c=.mexa64))


all: $(SOURCES) $(TARGETS)

#################################################
#                 INIT: SOURCE GENERATION
#################################################
sources: $(SOURCES)

# Use an intermediate target to enforce nonparallel generation.
generate_sources: ids_mex.xsl ids_get.xsl ids_get_slice.xsl $(IDSDEF) | saxonicajar
	@$(mkdir_p) $(BUILD_DIR)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:ids_mex.xsl
#	xsltproc ids_mex.xsl $(IDSDEF)

beautify: generate_sources
	@for i in $(SRC_DIR)/*.c $(SRC_DIR)/*.h $(SRC_DIR)/ids/*; do \
		echo Correcting indentation of $$i; \
		$(BEAUTIFY) $$i; \
	done
	@$(RM) $(SRC_DIR)/*~  $(SRC_DIR)/ids/*~

# Test if all generated sources are found to exist as files to
# gracefully skip generation if not needed.
ifeq ($(words $(GENSOURCES)), $(words $(wildcard $(GENSOURCES))))
$(GENSOURCES):
else
$(GENSOURCES): generate_sources beautify
endif

#################################################
#              BUILD
#################################################
build: $(OBJ_FILES) $(IDS_OBJ_FILES)

$(LIB_DIR)/libids_get-mex.so : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	$(mkdir_p) $(LIB_DIR)
	$(CC) $(LDFLAGS) -o $@ -Wl,-z,defs -shared -Wl,-soname,$(@F).$(IMAS_MAJOR).$(IMAS_MINOR) $(OBJ_FILES) $(IDS_OBJ_FILES) $(LIBS)

$(LIB_DIR)/libids_get-mex.a : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	$(mkdir_p) $(LIB_DIR)
	$(AR) rvs $@ $(OBJ_FILES)

$(LIB_DIR)/ids_get.mexa64: $(addprefix get_,$(addsuffix .o, $(IDSNAMES))) $(BUILD_DIR)/ids_get.o c_mexapi_version.o $(BUILD_DIR)/imas_mex_utils.o
$(LIB_DIR)/ids_get_slice.mexa64: $(addprefix get_slice_,$(addsuffix .o, $(IDSNAMES))) ids_get_slice.o c_mexapi_version.o $(BUILD_DIR)/imas_mex_utils.o
$(LIB_DIR)/%.mexa64: $(BUILD_DIR)/%.o $(BUILD_DIR)/c_mexapi_version.o
	$(mkdir_p) $(LIB_DIR)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)

$(BUILD_DIR)/c_mexapi_version.o: $(MATLAB)/extern/version/c_mexapi_version.c
	$(CC) $(CFLAGS) -c $< -o $(@)

$(OBJ_FILES): $(BUILD_DIR)/%.o : %.c
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(OBJ_FILES) %.c
	$(CC) $(CFLAGS) $(INCDIR) -c $(lastword $^) -o $(@)

#################################################
#              INSTALL
#################################################
install: all pkgconfig_install
	$(mkdir_p) $(libdir) $(includedir)/ids
	$(foreach sofile,$(filter %.so,$(TARGETS)),\
		$(INSTALL_DATA) -T $(sofile) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)) ;\
	)
	$(INSTALL_DATA) $(SRC_DIR)/*.h $(includedir)
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.h $(includedir)/ids

sources_install: $(SOURCES)
	$(mkdir_p) $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.* $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.* $(datadir)/src/cppinterface

#################################################
#              CLEAN
#################################################
clean: test-clean pkgconfig_clean
	$(RM) $(OBJ_FILES)
	$(RM) $(TARGETS)

clean-src: clean
	$(RM) $(GENSOURCES)

#################################################
#                 TESTS
#################################################

test: all
	$(MAKE) -C tests/generator test

test-clean:
	$(MAKE) -C tests/generator clean

test-clean-src:
	$(MAKE) -C tests/generator clean-src

PC_FILES = imas-mex.pc
include ../Makefile.pkgconfig
endif # IMAS_CPP=no?
