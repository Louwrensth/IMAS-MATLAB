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
## This template takes care of most of the dependencies
## Additional dependencies should be added in the init/build section
define TEMPLATE =
$(1)_SOURCES = $(1)_ids.c.in ids_$(1).c.in ids_$(1).h.in
ALL_SOURCES += $$($(1)_SOURCES)
$(1)_SRC_FILES = $$(addprefix $(IDS_SRC_DIR)/,$$($(1)_SOURCES))
ifeq (_to_,$(findstring _to_,$(1)))
$$($(1)_SRC_FILES): ids_converter.xsl mex_tools.xsl
else
$$($(1)_SRC_FILES): ids_$(1).xsl mex_tools.xsl
endif
$(LIB_DIR)/ids_$(1).mexa64:           $(BUILD_DIR)/$(1)_ids.o
$(BUILD_DIR)/ids_$(1).o:           $(IDS_SRC_DIR)/ids_$(1).h
endef

METHODS = get get_slice put put_slice delete allocate double_to_int int_to_double nan_to_empty empty_to_nan struct_to_cell cell_to_struct

$(foreach method,$(METHODS),$(eval $(call TEMPLATE,$(method))))

IDS_C_FILES   = $(filter-out ids_%     , $(ALL_SOURCES))
MEX_IDS_FILES = $(filter     ids_%.c.in, $(ALL_SOURCES))
HEADER_FILES  = $(filter     ids_%.h.in, $(ALL_SOURCES))

GENSOURCES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_C_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(MEX_IDS_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(HEADER_FILES))
GENSOURCES+= matlab/IDS_list.m

# Add static sources
MEX_SRC_FILES = $(addsuffix .c, imas_open imas_open_env \
				imas_open_public \
				imas_create imas_create_env \
				imas_create_public \
				imas_close \
				imas_get_backendID \
				imas_get_mex_params imas_set_mex_params \
				)
# TODO/DEPRECATED: imas_open_hdf5 imas_create_hdf5 imas_enable_mem_cache imas_disable_mem_cache imas_flush_mem_cache imas_discard_mem_cache
SOURCES = $(GENSOURCES)
UTL_SRC_FILES = $(addsuffix .c, imas_mex_utils imas_mex_structs imas_mex_params imas_mex_casts)
SOURCES+= $(addprefix $(SRC_DIR)/,$(MEX_SRC_FILES) $(UTL_SRC_FILES))

# Compiled objects
IDS_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(IDS_C_FILES:.c.in=.o))
IDS_OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_IDS_FILES:.c.in=.o))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(UTL_SRC_FILES:.c=.o))
OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_SRC_FILES:.c=.o))

TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_SRC_FILES:.c=.mexa64))
TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_IDS_FILES:.c.in=.mexa64))


all: $(SOURCES) $(TARGETS)

#################################################
#                 INIT: SOURCE GENERATION
#################################################

sources: $(SOURCES)

$(get_SRC_FILES):            get_single.xsl
$(get_slice_SRC_FILES):      get_single.xsl
$(put_SRC_FILES):            put_single.xsl
$(put_slice_SRC_FILES):      put_single.xsl
$(delete_SRC_FILES): 	     delete.xsl
$(allocate_SRC_FILES):       allocate.xsl
$(double_to_int_SRC_FILES):  ints_doubles.xsl
$(int_to_double_SRC_FILES):  ints_doubles.xsl
$(nan_to_empty_SRC_FILES):   emptys_nans.xsl
$(empty_to_nan_SRC_FILES):   emptys_nans.xsl
$(struct_to_cell_SRC_FILES): cells_structs.xsl
$(cell_to_struct_SRC_FILES): cells_structs.xsl
matlab/IDS_list.m:           IDS_list.xsl
$(GENSOURCES):
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:$<
#	xsltproc $< $(IDSDEF)

$(IDS_SRC_DIR)/%.c: $(IDS_SRC_DIR)/%.c.in
	$(BEAUTIFY) $< -o $@

$(IDS_SRC_DIR)/%.h: $(IDS_SRC_DIR)/%.h.in
	$(BEAUTIFY) $< -o $@

#################################################
#              BUILD
#################################################

$(LIB_DIR) $(BUILD_DIR): 
	$(mkdir_p) $(@)

$(LIB_DIR)/ids_get.mexa64:           $(BUILD_DIR)/int_to_double_ids.o $(BUILD_DIR)/empty_to_nan_ids.o
$(LIB_DIR)/ids_get_slice.mexa64:     $(BUILD_DIR)/int_to_double_ids.o $(BUILD_DIR)/empty_to_nan_ids.o
$(LIB_DIR)/ids_put.mexa64:           $(BUILD_DIR)/double_to_int_ids.o $(BUILD_DIR)/nan_to_empty_ids.o 
$(LIB_DIR)/ids_put_slice.mexa64:     $(BUILD_DIR)/double_to_int_ids.o $(BUILD_DIR)/nan_to_empty_ids.o
$(LIB_DIR)/ids_put.mexa64:           $(BUILD_DIR)/delete_ids.o
$(LIB_DIR)/ids_put_non_timed.mexa64: $(BUILD_DIR)/delete_ids.o
$(LIB_DIR)/%.mexa64: $(BUILD_DIR)/%.o $(BUILD_DIR)/c_mexapi_version.o | $(LIB_DIR) $(LIB_DIR)/libimas_mex.so
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS) -Wl,-rpath,$(realpath $(CURDIR)/$(LIB_DIR)) -L $(realpath $(CURDIR)/$(LIB_DIR)) -limas_mex

$(LIB_DIR)/libimas_mex.so: $(addprefix $(BUILD_DIR)/,$(UTL_SRC_FILES:.c=.o)) | $(LIB_DIR)
	$(CC) -g -o $@ -shared -Wl,-soname,$(notdir $@).$(IMAS_MAJOR).$(IMAS_MINOR) $^

$(BUILD_DIR)/c_mexapi_version.o: $(MATLAB)/extern/version/c_mexapi_version.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $(@)

$(OBJ_FILES): $(BUILD_DIR)/%.o : %.c |  $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(IDS_SRC_DIR)/%.c  $(addprefix $(SRC_DIR)/,$(UTL_SRC_FILES:.c=.h)) | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

#################################################
#              INSTALL
#################################################

install: all pkgconfig_install
	$(mkdir_p) $(libdir)
	$(INSTALL_DATA) $(filter %.mexa64,$(TARGETS)) $(libdir)	
	$(foreach sofile,$(filter %.so,$(TARGETS)),\
		$(INSTALL_DATA) -T $(sofile) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)) ;\
	)

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

clean-src: test-clean-src clean
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
