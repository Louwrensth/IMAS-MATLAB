<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:my="dummy"
    version="2.0">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--================================================-->
<!--                 Include section                -->
<!--================================================-->

<xsl:include href="mex_tools.xsl"/>
<xsl:include href="put_single.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:result-document href="src/ids/ids_put.c.in" standalone="yes" method="text">
/*
 * ids_put.c - write IDS in MATLAB External Interfaces
 *
 *		ids = ids_put(idx, IDSpath[, occ], ids)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_put.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three or four input arguments  
  if(nrhs != 4 &amp;&amp; nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargin",
                      "Three or four inputs required.");
  }

  // make sure idx is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input idx must be a scalar.");
  }
  // Get the value of idx
  int idx = (int) mxGetScalar(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input idx is:  %d\n", idx);

  // make sure IDSpath is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notChar",
                        "Input IDSpath must be a string.");
  }
  // Get the value of IDSpath
  char *IDSpath = mxArrayToString(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);

  if(nrhs == 4) {
  int occ;
  size_t pathlen;
  // make sure occ is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input occurence must be a scalar.");
  }
  // Get the value of occ
  occ = (int) mxGetScalar(prhs[2]);
  if (params.verbosity >= 4)
  mexPrintf("The input occurence is:  %d\n", occ);
  if (occ &gt; 0) {
  pathlen = strlen(IDSpath);
  IDSpath = mxRealloc(IDSpath, (pathlen+5)*sizeof(char));
  snprintf(&amp;IDSpath[pathlen], 5, "/%d", occ);
  }
  }

  // make sure ids is scalar struct
  if( !mxIsStruct(prhs[nrhs-1]) ||
      !mxIsScalar(prhs[nrhs-1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input ids must be a scalar structure.");
  }
  // Get the value of ids
  if (params.verbosity >= 4)
  mexPrintf("The input ids is:  %s\n", "SKIPPED");

  // Check for no output argument
  if(nlhs > 0) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargout",
                      "No output required.");
  }
  
  // Extract IDS name
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");

  // Declare Function Pointer
  int(*put)(int, char*, const mxArray*) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">put</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_put:unknown_ids",
           "Unknown IDS name: %s", name);

  // free now as name uses the same memory
  free(IDSpathcopy);

  // Clean-up previous errors
  mex_errmsgid = NULL;
  mex_errmsgtxt[0] = '\000';
  // Call function
  int err = put(idx, IDSpath, prhs[nrhs-1]);
  if (err) 
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_put:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_put.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int put_'"/>
    <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, const mxArray* ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
  <xsl:result-document href="src/ids/put_ids.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">

    int delete_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName);
#ifndef NO_GLOBAL_CONVERSION
     int double_to_int_<xsl:value-of select="@name"/>(mxArray* ids);
     int nan_to_empty_<xsl:value-of select="@name"/>(mxArray* ids);
#endif
    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_H"/>

    int put_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, const mxArray* ids)
    {
    struct imas_mex_actionInfo action;
    struct imas_mex_fieldInfo field;
    const mxArray* data=NULL;
#ifndef NO_GLOBAL_CONVERSION
     mxArray* ids_conv=NULL;
#endif
    int ifield;
    int cast_status = -1;
    int status = -1;
    int aosArraySize = -1;
    int aosCtx = -1;
    int putOpCtx = -1;
    int ctx = -1;
    int homogeneousTime = EMPTY_INT;
    int isEmpty;

#ifndef NO_GLOBAL_CONVERSION
     if (params.convert_whole_ids == 1) {
     // Conversion of INT fields from double
     if (params.put_int_from_double) {
     ids_conv = mxDuplicateArray(ids);
     if (double_to_int_<xsl:value-of select="@name"/>(ids_conv) &lt; 0)
     return -1;
     ids = ids_conv;
     }
     // Conversion of NaN values for FLT fields to EMPTY_DOUBLE
     if (params.put_empty_from_nan) {
     if (ids_conv == NULL) // if input was not already duplicated
     ids_conv = mxDuplicateArray(ids);
     if (nan_to_empty_<xsl:value-of select="@name"/>(ids_conv) &lt; 0)
     return -1;
     ids = ids_conv;
     }
     }
#endif

    if (init_dataTree_write((mxArray *) ids) &lt; 0)
    return -1;
    if (getHomogeneousTime(&amp;homogeneousTime) &lt; 0) 
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_homogeneous_time",
      "Unable to retrieve ids%%ids_properties%%homogeneous_time");
    if( homogeneousTime == EMPTY_INT )
    {
    mexWarnMsgIdAndTxt("IMAS:ids_put:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT quits with no action.");
    return 0;
    }

    // Delete existing IDS if any
    delete_<xsl:value-of select="@name"/>(expIdx, idsFullName);
    // Open put context
    putOpCtx = ual_begin_global_action(expIdx, idsFullName, WRITE_OP);
    if(putOpCtx &lt; 0) 
    return putOpCtx;
    ctx = putOpCtx;
    action.context = ctx;

    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'no'"/>
    </xsl:apply-templates>

    ual_end_action(ctx);
    return 0; // TODO: Should we return status of ual_end_action?
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT"/>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_H">
int put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime);</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT">
int put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime)
    {
    struct imas_mex_actionInfo action;
    struct imas_mex_fieldInfo field;
    const mxArray* data=NULL;
    int ifield;
    int cast_status = -1;
    int status = -1;
    int aosArraySize = -1;
    int aosCtx = -1;
    int isEmpty;

    action.context = ctx;

    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'no'"/>
    </xsl:apply-templates>

    return 0;
    }
</xsl:template>

</xsl:stylesheet>
