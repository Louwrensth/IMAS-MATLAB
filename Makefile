include ../Makefile.common

ifneq ("yes","$(strip $(IMAS_MEX))")
all sources sources_install install uninstall clean clean-src:
	$(warning "Ignoring mexinterface (IMAS_MEX=no).")
else

include Makefile.flags # Defines CFLAGS, LDFLAGS (also with _DEBUG/_OPTIM suffix) and MEXSRC

MEX_SO_NUM=1

CFLAGS_EXTRA = $(CFLAGS_DEBUG) #-DCALL_MATLAB_FOR_CASTS
LDFLAGS_EXTRA = $(LDFLAGS_DEBUG)
ifneq ($(DEBUG),yes)
 CFLAGS_EXTRA += $(CFLAGS_OPTIM)
 LDFLAGS_EXTRA += $(LDFLAGS_OPTIM)
endif

CFLAGS+= -std=c11 -D__USE_XOPEN2K8 $(CFLAGS_EXTRA)
LDFLAGS+= $(LDFLAGS_EXTRA)

ifeq "$(strip $(CC))" "icc"
 CC=icc
 LDFLAGS:=$(filter-out -lm,$(LDFLAGS))
endif

BUILD_DIR:=./build
LIB_DIR:=./lib
SRC_DIR:=./src
IDS_SRC_DIR:=$(SRC_DIR)/ids
INCDIR=-I$(SRC_DIR) -I$(IDS_SRC_DIR) -I../lowlevel

IDSDEF= ../xml/IDSDef.xml
LIBS=-L../lowlevel -lal

# Check existence of the "indent" utility to get a clean C format
BEAUTIFY=
ifneq "$(shell which indent 2> /dev/null)" ""
 BEAUTIFY = indent -kr --no-tabs -l1000 -fc1
endif

# Sets a path where make will search for files
VPATH = $(SRC_DIR) $(IDS_SRC_DIR) build lib

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))

all: _all
# Generated sources (excluding static sources)
## This template takes care of most of the dependencies
## Additional dependencies should be added in the init/build section
define TEMPLATE
$(1)_SOURCES = ids_$(1).c ids_$(1).h $(1)_ids.c
ALL_SOURCES += $$($(1)_SOURCES)
$(1)_SRC_FILES= $$(addprefix $$(IDS_SRC_DIR)/,$$($(1)_SOURCES))
# Introducing a fake intermediate file for forcing recipes to be run only once even for parallel builds
ifeq (,$(findstring _to_,$(1)))
INDSOURCES += $(1)_sources # Skip the ones for converter
.INTERMEDIATE: $(1)_sources # Skip the ones for converter
$(1)_sources: ids_$(1).xsl mex_tools.xsl # Skip the ones for converter
$$($(1)_SRC_FILES): $(1)_sources
else
$$($(1)_SRC_FILES): converter_sources
converter_SOURCES += $$($(1)_SOURCES)
endif
$(LIB_DIR)/ids_$(1).mexa64:           $(BUILD_DIR)/$(1)_ids.o
$(BUILD_DIR)/ids_$(1).o:           $(IDS_SRC_DIR)/ids_$(1).h
endef

METHODS = validate get get_slice put put_slice delete allocate gen init int_to_double double_to_int empty_to_nan nan_to_empty cell_to_struct struct_to_cell rand

$(foreach method,$(METHODS),$(eval $(call TEMPLATE,$(method))))

# Do the converter bit
INDSOURCES += converter_sources
.INTERMEDIATE: converter_sources
converter_sources: ids_converter.xsl mex_tools.xsl


IDS_C_FILES   = $(filter-out ids_%     , $(ALL_SOURCES))
MEX_IDS_FILES = $(filter     ids_%.c, $(ALL_SOURCES))
HEADER_FILES  = $(filter     ids_%.h, $(ALL_SOURCES))

GENSOURCES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_C_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(MEX_IDS_FILES))
GENSOURCES+= $(addprefix $(IDS_SRC_DIR)/,$(HEADER_FILES))
GENSOURCES+= matlab/IDS_list.m src/imas_versions.c

INDSOURCES+= matlab/IDS_list.m src/imas_versions.c

# Add static sources
MEX_SRC_FILES = $(addsuffix .c, imas_open_env \
				imas_open_env_backend \
				imas_open \
				imas_create_env \
				imas_create_env_backend \
				imas_close \
				imas_get_backendID \
				imas_get_mex_params imas_set_mex_params \
				imas_al_register_plugin \
				imas_al_unregister_plugin \
				imas_al_bind_plugin \
				imas_al_unbind_plugin \
				imas_al_setvalue_parameter_plugin \
				imas_serialize imas_deserialize \
				imas_list_all_occurrences \
				ids_isdefined \
				imas_versions \
				)
SOURCES = $(GENSOURCES)
UTL_SRC_FILES = $(addsuffix .c, imas_mex_utils imas_mex_structs imas_mex_params imas_mex_casts imas_mex_rand)
SOURCES+= $(addprefix $(SRC_DIR)/,$(MEX_SRC_FILES) $(UTL_SRC_FILES))

# Compiled objects
IDS_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(IDS_C_FILES:.c=.o))
IDS_OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_IDS_FILES:.c=.o))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(UTL_SRC_FILES:.c=.o))
OBJ_FILES+= $(addprefix $(BUILD_DIR)/,$(MEX_SRC_FILES:.c=.o))

TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_SRC_FILES:.c=.mexa64))
TARGETS+= $(addprefix $(LIB_DIR)/,$(MEX_IDS_FILES:.c=.mexa64))
TARGETS+= $(LIB_DIR)/libal-mex.so.$(MEX_SO_NUM)

ifneq ("","$(MEXSRC)")
  MEX_ADD_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(subst .c,.o,$(notdir $(MEXSRC))))
endif

_all: sources $(TARGETS)

.PHONY: all _all


#################################################
#                 INIT: SOURCE GENERATION
#################################################

sources: $(GENSOURCES)

$(validate_SRC_FILES):       validate_single.xsl
$(get_SRC_FILES):            get_single.xsl
$(get_slice_SRC_FILES):      get_single.xsl
$(put_SRC_FILES):            put_single.xsl
$(put_slice_SRC_FILES):      put_single.xsl
$(delete_SRC_FILES): 	     delete.xsl
$(allocate_SRC_FILES):       allocate.xsl
$(gen_SRC_FILES):            allocate.xsl
$(init_SRC_FILES):           allocate.xsl
$(double_to_int_SRC_FILES):  ints_doubles.xsl
$(int_to_double_SRC_FILES):  ints_doubles.xsl
$(nan_to_empty_SRC_FILES):   emptys_nans.xsl
$(empty_to_nan_SRC_FILES):   emptys_nans.xsl
$(struct_to_cell_SRC_FILES): cells_structs.xsl
$(cell_to_struct_SRC_FILES): cells_structs.xsl
$(rand_SRC_FILES):           rand.xsl
matlab/IDS_list.m:           IDS_list.xsl
src/imas_versions.c:		 imas_versions.xsl
$(INDSOURCES): $(IDSDEF) | saxonicajar
	$(SAXON) -t -warnings:fatal DD_GIT_DESCRIBE=$(DD_GIT_DESCRIBE) AL_GIT_DESCRIBE=$(AL_GIT_DESCRIBE) -s:$(IDSDEF) -xsl:$(firstword $(filter %.xsl,$^))
ifneq "$(BEAUTIFY)" ""
        # This script will indent the generated files
        # If an error is triggered during indenting, remove the files
	@[ "$@" = "matlab/IDS_list.m" ] || (echo "[indent] Processing $($(@:_sources=_SOURCES))";\
	VERSION_CONTROL="none" $(BEAUTIFY) $(addprefix $(IDS_SRC_DIR)/,$($(@:_sources=_SOURCES)));\
	x=$$?;\
	[[ $$x == 0 ]] || rm -f $(addprefix $(IDS_SRC_DIR)/,$($(@:_sources=_SOURCES)));\
	[[ $$x == 0 ]])
endif

.PHONY: sources

#################################################
#              BUILD
#################################################

$(LIB_DIR) $(BUILD_DIR): 
	$(mkdir_p) $(@)

$(LIB_DIR)/ids_put.mexa64:           $(BUILD_DIR)/delete_ids.o $(BUILD_DIR)/validate_ids.o
$(LIB_DIR)/ids_put_slice.mexa64:     $(addprefix $(BUILD_DIR)/, delete_ids.o put_ids.o validate_ids.o)
$(LIB_DIR)/%.mexa64: $(BUILD_DIR)/%.o $(MEX_ADD_OBJ_FILES) | $(LIB_DIR) $(LIB_DIR)/libal-mex.so
	$(CC) $^ -o $@ -L $(realpath $(CURDIR)/$(LIB_DIR)) -lal-mex $(LIBS) $(LDFLAGS)

$(LIB_DIR)/libal-mex.so.$(MEX_SO_NUM): $(addprefix $(BUILD_DIR)/,$(UTL_SRC_FILES:.c=.o)) | $(LIB_DIR)
	$(CC) -g -o $@ -shared -Wl,$(SONAME_OPT),$(notdir $@) $^

$(LIB_DIR)/libal-mex.so: $(LIB_DIR)/libal-mex.so.$(MEX_SO_NUM)
	ln -sf $(notdir $<) $@

$(MEX_ADD_OBJ_FILES): $(MEXSRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $(@)

$(OBJ_FILES): $(BUILD_DIR)/%.o : $(SRC_DIR)/%.c |  $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(IDS_SRC_DIR)/%.c  $(addprefix $(SRC_DIR)/,$(UTL_SRC_FILES:.c=.h)) | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCDIR) -c $< -o $(@)

#################################################
#              INSTALL
#################################################

install: all pkgconfig_install doc_install
	$(mkdir_p) $(prefix)/mex $(libdir)
	$(INSTALL) $(filter %.mexa64,$(TARGETS)) $(prefix)/mex
	$(INSTALL_DATA) $(patsubst $(LIB_DIR)/%,matlab/%,$(patsubst %.mexa64,%.m,$(filter %.mexa64,$(TARGETS)))) matlab/IDS_list.m matlab/nan_to_empty.m matlab/empty_to_nan.m $(prefix)/mex	
	$(INSTALL) -T $(LIB_DIR)/libal-mex.so.$(MEX_SO_NUM) $(libdir)/libal-mex.so.$(MEX_SO_NUM)
	ln -sf libal-mex.so.$(MEX_SO_NUM) $(libdir)/libal-mex.so

uninstall: sources_uninstall
	-rm -rf $(prefix)/mex
	-rm -f $(addprefix $(libdir)/,libal-mex.so.$(MEX_SO_NUM) libal-mex.so.$(MEX_SO_NUM) libal-mex.so)
	-rm -rf $(docdir)/dev/mexinterface

sources_install: $(SOURCES)
	$(mkdir_p) $(datadir)/src/mexinterface/ids
	$(INSTALL_DATA) $(filter $(IDS_SRC_DIR)/%, $(SOURCES)) $(datadir)/src/mexinterface/ids
	$(INSTALL_DATA) $(filter-out $(IDS_SRC_DIR)/%, $(filter $(SRC_DIR)/%, $(SOURCES))) $(datadir)/src/mexinterface

sources_uninstall:
	-rm -rf $(datadir)/src/mexinterface

doc_install: doc
	$(mkdir_p) $(docdir)/dev/mexinterface
	cp -r html latex $(docdir)/dev/mexinterface

.PHONY: install uninstall sources_install sources_uninstall doc_install

#################################################
#              CLEAN
#################################################

clean: test-clean pkgconfig_clean
	$(RM) $(IDS_OBJ_FILES)
	$(RM) $(OBJ_FILES) $(addprefix $(BUILD_DIR)/,c_mexapi_version.o)
	$(RM) $(TARGETS)

clean-src: test-clean-src clean-doc clean
	$(RM) $(GENSOURCES)

.PHONY: clean clean-src clean-doc

#################################################
#              DOCUMENTATION
#################################################

#----------------------- Doxygen documentation -------------------
PDFLATEX?=$(shell which pdflatex 2>/dev/null)
doc: latex/refman.pdf html/files.html
latex/files.tex html/files.html: Doxyfile README.md $(SOURCES) 
	doxygen Doxyfile || $(RM) -r latex html
latex/refman.pdf: latex/files.tex
	$(if $(PDFLATEX),$(MAKE) -C latex,$(warning Skipping make -C latex: pdflatex does not exist.))

clean-doc:
	$(RM) -r latex html

.PHONY: doc

#----------------------- Sphinx documentation -------------------

.PHONY: docs clean-docs
docs:
	$(MAKE) -C doc html

clean-docs:
	$(MAKE) -C doc clean

#################################################
#                 TESTS
#################################################

test: all
	$(MAKE) -C tests test

test-clean:
	$(MAKE) -C tests clean

test-clean-src:
	$(MAKE) -C tests clean-src

.PHONY: test test-clean test-clean-src

PC_FILES =
include ../Makefile.pkgconfig
# Check that "Saxon-HE.jar" utility is set in CLASSPATH
#SAXONJARFILE?=Saxon-HE.jar
include ../Makefile.classpath
endif # IMAS_MEX=no?
