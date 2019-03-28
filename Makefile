include ../Makefile.common

# Check that "Saxon-HE.jar" utility is set in CLASSPATH
#SAXONJARFILE?=Saxon-HE.jar
include ../Makefile.classpath

ifeq ("no","$(strip $(IMAS_MEX))")
all sources sources_install install clean clean-src:
	$(warning "Ignoring mexinterface (IMAS_MEX=no).")
else

CFLAGS_DEBUG = -g
LDFLAGS_DEBUG = -g
CFLAGS_OPTIM = -O -DNDEBUG
LDFLAGS_OPTIM =

CFLAGS_EXTRA = $(CFLAGS_DEBUG)
LDFLAGS_EXTRA = $(LDFLAGS_DEBUG)

ifeq "$(strip $(CC))" "icc"
 CC=icc
 CFLAGS=-DTARGET_API_VERSION=700  -DUSE_MEX_CMD -D__USE_XOPEN2K8 -D_GNU_SOURCE -DMATLAB_MEX_FILE  -I"$(MATLAB)/extern/include" -I"$(MATLAB)/simulink/include" -fexceptions -fPIC -fno-omit-frame-pointer -pthread $(CFLAGS_EXTRA)
 LDFLAGS= $(LDFLAGS_EXTRA) -pthread -fPIC -Wl,--no-undefined -Wl,-rpath-link,$(MATLAB)/bin/glnxa64 -shared  -Wl,--version-script,"$(MATLAB)/extern/lib/glnxa64/c_exportsmexfileversion.map"  -L"$(MATLAB)/bin/glnxa64" -lmx -lmex -lmat -lstdc++
else
 CC=gcc
 CFLAGS=-DTARGET_API_VERSION=700  -DUSE_MEX_CMD -D__USE_XOPEN2K8 -D_GNU_SOURCE -DMATLAB_MEX_FILE  -I"$(MATLAB)/extern/include" -I"$(MATLAB)/simulink/include" -fexceptions -fPIC -fno-omit-frame-pointer -pthread $(CFLAGS_EXTRA)
 LDFLAGS= $(LDFLAGS_EXTRA) -pthread -fPIC -Wl,--no-undefined -Wl,-rpath-link,$(MATLAB)/bin/glnxa64 -shared  -Wl,--version-script,"$(MATLAB)/extern/lib/glnxa64/c_exportsmexfileversion.map"  -L"$(MATLAB)/bin/glnxa64" -lmx -lmex -lmat -lm -lstdc++
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
GET_SOURCES           = $(addprefix get_,          $(addsuffix .c.in,$(IDSNAMES))) ids_get.c.in ids_get.h.in
GET_SLICE_SOURCES     = $(addprefix get_slice_,    $(addsuffix .c.in,$(IDSNAMES))) ids_get_slice.c.in ids_get_slice.h.in
PUT_SOURCES           = $(addprefix put_,          $(addsuffix .c.in,$(IDSNAMES))) ids_put.c.in ids_put.h.in
PUT_SLICE_SOURCES     = $(addprefix put_slice_,    $(addsuffix .c.in,$(IDSNAMES))) ids_put_slice.c.in ids_put_slice.h.in
#PUT_NON_TIMED_SOURCES = $(addprefix put_non_timed_,$(addsuffix .c.in,$(IDSNAMES))) ids_put_non_timed.c.in ids_put_non_timed.h.in
DELETE_SOURCES        = $(addprefix delete_,       $(addsuffix .c.in,$(IDSNAMES))) ids_delete.c.in ids_delete.h.in

ALL_SOURCES = $(GET_SOURCES) $(GET_SLICE_SOURCES) $(PUT_SOURCES) $(PUT_SLICE_SOURCES) $(DELETE_SOURCES)
# TODO/DEPRECATED: $(PUT_NON_TIMED_SOURCES)

IDS_C_FILES   = $(filter-out ids_%     , $(ALL_SOURCES))
MEX_IDS_FILES = $(filter     ids_%.c.in, $(ALL_SOURCES))
HEADER_FILES  = $(filter     ids_%.h.in, $(ALL_SOURCES))

GENSOURCES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_C_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(MEX_IDS_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(HEADER_FILES))

GET_SRC_FILES           = $(addprefix $(IDS_SRC_DIR)/,$(GET_SOURCES))
GET_SLICE_SRC_FILES     = $(addprefix $(IDS_SRC_DIR)/,$(GET_SLICE_SOURCES))
PUT_SRC_FILES           = $(addprefix $(IDS_SRC_DIR)/,$(PUT_SOURCES))
PUT_SLICE_SRC_FILES     = $(addprefix $(IDS_SRC_DIR)/,$(PUT_SLICE_SOURCES))
#PUT_NON_TIMED_SRC_FILES = $(addprefix $(IDS_SRC_DIR)/,$(PUT_NON_TIMED_SOURCES))
DELETE_SRC_FILES        = $(addprefix $(IDS_SRC_DIR)/,$(DELETE_SOURCES))

# Add static sources
MEX_SRC_FILES = $(addsuffix .c, imas_open imas_open_env \
				imas_open_public \
				imas_create imas_create_env \
				imas_create_public \
				imas_close \
				)
# TODO/DEPRECATED: imas_open_hdf5 imas_create_hdf5 imas_enable_mem_cache imas_disable_mem_cache imas_flush_mem_cache imas_discard_mem_cache
SOURCES = $(GENSOURCES)
SOURCES+= $(addprefix $(SRC_DIR)/,$(MEX_SRC_FILES) imas_mex_utils.c)

# Compiled objects
IDS_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(IDS_C_FILES:.c.in=.o))
IDS_OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_IDS_FILES:.c.in=.o))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,imas_mex_utils.o)
OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_SRC_FILES:.c=.o))

TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_SRC_FILES:.c=.mexa64))
TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_IDS_FILES:.c.in=.mexa64))


all: $(SOURCES) $(TARGETS)

#################################################
#                 INIT: SOURCE GENERATION
#################################################

sources: $(SOURCES)

$(GET_SRC_FILES): ids_get.xsl mex_tools.xsl get_single.xsl
$(GET_SLICE_SRC_FILES): ids_get_slice.xsl mex_tools.xsl get_single.xsl
$(PUT_SRC_FILES): ids_put.xsl mex_tools.xsl put_single.xsl
$(PUT_SLICE_SRC_FILES): ids_put_slice.xsl mex_tools.xsl put_single.xsl
#$(PUT_NON_TIMED_SRC_FILES): ids_put_non_timed.xsl mex_tools.xsl put_single.xsl put_in_object.xsl puttime_single.xsl
$(DELETE_SRC_FILES): ids_delete.xsl mex_tools.xsl delete.xsl
$(GENSOURCES):
	@$(mkdir_p) $(BUILD_DIR)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:$(filter ids_%.xsl,$^)
#	xsltproc $(filter ids_%.xsl,$^) $(IDSDEF)

$(IDS_SRC_DIR)/%.c: %.c.in
	$(BEAUTIFY) $< -o $@

$(IDS_SRC_DIR)/%.h: %.h.in
	$(BEAUTIFY) $< -o $@

#################################################
#              BUILD
#################################################

$(LIB_DIR)/ids_get.mexa64:           $(addprefix get_,          $(addsuffix .o, $(IDSNAMES)))
$(LIB_DIR)/ids_get_slice.mexa64:     $(addprefix get_slice_,    $(addsuffix .o, $(IDSNAMES)))
$(LIB_DIR)/ids_put.mexa64:           $(addprefix put_,          $(addsuffix .o, $(IDSNAMES)))  $(addprefix delete_,$(addsuffix .o, $(IDSNAMES)))
$(LIB_DIR)/ids_put_slice.mexa64:     $(addprefix put_slice_,    $(addsuffix .o, $(IDSNAMES)))
$(LIB_DIR)/ids_delete.mexa64:        $(addprefix delete_,       $(addsuffix .o, $(IDSNAMES)))
#$(LIB_DIR)/ids_put_non_timed.mexa64: $(addprefix put_non_timed_,$(addsuffix .o, $(IDSNAMES))) $(addprefix delete_,$(addsuffix .o, $(IDSNAMES)))
$(LIB_DIR)/%.mexa64: $(BUILD_DIR)/%.o $(BUILD_DIR)/c_mexapi_version.o $(BUILD_DIR)/imas_mex_utils.o
	$(mkdir_p) $(LIB_DIR)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)

$(BUILD_DIR)/c_mexapi_version.o: $(MATLAB)/extern/version/c_mexapi_version.c
	$(CC) $(CFLAGS) -c $< -o $(@)

$(OBJ_FILES): $(BUILD_DIR)/%.o : %.c
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

$(BUILD_DIR)/ids_get.o:           $(IDS_SRC_DIR)/ids_get.h
$(BUILD_DIR)/ids_get_slice.o:     $(IDS_SRC_DIR)/ids_get_slice.h
$(BUILD_DIR)/ids_put.o:           $(IDS_SRC_DIR)/ids_put.h
$(BUILD_DIR)/ids_put_slice.o:     $(IDS_SRC_DIR)/ids_put_slice.h
$(BUILD_DIR)/ids_delete.o:        $(IDS_SRC_DIR)/ids_delete.h
#$(BUILD_DIR)/ids_put_non_timed.o: $(IDS_SRC_DIR)/ids_put_non_timed.h
$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(IDS_SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

#################################################
#              INSTALL
#################################################

install: all pkgconfig_install
	$(mkdir_p) $(libdir)
	$(INSTALL_DATA) $(filter %.mexa64,$(TARGETS)) $(libdir)	

sources_install: $(SOURCES)
	$(mkdir_p) $(datadir)/src/mexinterface/ids
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.c $(IDS_SRC_DIR)/*.h $(datadir)/src/mexinterface/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.c $(SRC_DIR)/*.h $(datadir)/src/mexinterface

#################################################
#              CLEAN
#################################################

clean: test-clean pkgconfig_clean
	$(RM) $(IDS_OBJ_FILES)
	$(RM) $(OBJ_FILES) $(addprefix $(BUILD_DIR)/,c_mexapi_version.o)
	$(RM) $(TARGETS)

clean-src: clean
	$(RM) $(GENSOURCES) $(GENSOURCES:.in=)

#################################################
#                 TESTS
#################################################

test: all
	$(MAKE) -C tests test

test-clean:
	$(MAKE) -C tests clean

test-clean-src:
	$(MAKE) -C tests clean-src

PC_FILES =
include ../Makefile.pkgconfig
endif # IMAS_MEX=no?
