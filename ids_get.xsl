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
<xsl:include href="get_single.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
  <xsl:result-document href="src/ids/ids_get.c.in" standalone="yes" method="text">
/*
 * ids_get.c - read IDS in MATLAB External Interfaces
 *
 *		ids = ids_get(idx, IDSpath[, occ])
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_get.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for two or three input arguments  
  if(nrhs != 3 &amp;&amp; nrhs != 2) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargin",
                      "Two or three inputs required.");
  }

  // make sure idx is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input idx must be a scalar.");
  }
  // Get the value of idx
  int idx = (int) mxGetScalar(prhs[0]);
#ifdef MEX_DEBUG
  mexPrintf("The input idx is:  %d\n", idx);
#endif

  // make sure IDSpath is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notChar",
                        "Input IDSpath must be a string.");
  }
  // Get the value of IDSpath
  char *IDSpath = mxArrayToString(prhs[1]);
#ifdef MEX_DEBUG
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);
#endif

  if(nrhs == 3) {
  int occ;
  size_t pathlen;
  // make sure occ is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input occurence must be a scalar.");
  }
  // Get the value of occ
  occ = (int) mxGetScalar(prhs[2]);
#ifdef MEX_DEBUG
  mexPrintf("The input occurence is:  %d\n", occ);
#endif
  if (occ &gt; 0) {
  pathlen = strlen(IDSpath);
  IDSpath = mxRealloc(IDSpath, (pathlen+5)*sizeof(char));
  snprintf(&amp;IDSpath[pathlen], 5, "/%d", occ);
  }
  }

  // Check for one output argument
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargout",
                      "One output maximum required.");
  }
  
  // Extract IDS name
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");
 
  // Declare Function Pointer
  int(*get)(int, char*, mxArray**) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">get</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  if (get == NULL)
  mexErrMsgIdAndTxt("IMAS:ids_get:unknown_ids",
           "Unknown IDS name: %s", name);

  // free now as name uses the same memory
  free(IDSpathcopy);

  // Clean-up previous errors
  mex_errmsgid[0] = '\000';
  mex_errmsgtxt[0] = '\000';
  // Call function
  int err = get(idx, IDSpath, &amp;plhs[0]);
  if (err &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_get:");
  return;

}
  </xsl:result-document>
  <xsl:result-document href="src/ids/ids_get.h.in" standalone="yes" method="text">
    #include "mex.h"
    <xsl:apply-templates select = "IDS" mode="LIST">
      <xsl:with-param name="prefix" select="'int get_'"/>
      <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, mxArray** ids);'"/>
    </xsl:apply-templates>
  </xsl:result-document>
  <xsl:result-document href="src/ids/get_ids.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">
#ifndef NO_GLOBAL_CONVERSION
     int int_to_double_<xsl:value-of select="@name"/>(mxArray* ids);
     int empty_to_nan_<xsl:value-of select="@name"/>(mxArray* ids);
#endif

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET_H"/>

    int get_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, mxArray** ids)
    {
    struct imas_mex_actionInfo action;
    struct imas_mex_fieldInfo field;
    // Paths-specific variables
    int maxpathsize=MAXPATHSIZE;
    mxArray* data=NULL;
    int ifield;
    int status = -1;
    int aosArraySize = -1;
    int aosCtx = -1;
    int getOpCtx = -1;
    int ctx = -1;
    int homogeneousTime = EMPTY_INT;

    // Open get context
    getOpCtx = ual_begin_global_action(expIdx, idsFullName, READ_OP);
    if(getOpCtx &lt; 0) 
    return getOpCtx;
    ctx = getOpCtx;
    status = getHomogeneousTime2(ctx, &amp;homogeneousTime);
    if(status &lt; 0) 
    {
    ual_end_action(ctx);
    return status;
    }
    action.context = ctx;
     if (init_dataTree_read() &lt; 0) {
    ual_end_action(ctx);
    return -1;
    }

    <xsl:apply-templates select="field" mode="GET_SINGLE"/>

    ual_end_action(ctx);
     if (get_data_from_dataTree(NULL, ids) &lt; 0)
     return -1;
#ifndef NO_GLOBAL_CONVERSION
    if (params.convert_whole_ids == 1) {
    // Conversion of INT fields to double
    if (params.get_int_as_double) {
    if (int_to_double_<xsl:value-of select="@name"/>(*ids) &lt; 0)
    return -1;
    }
    // Conversion of EMPTY_FLOAT values for FLT fields to NaN
    if (params.get_empty_as_nan) {
    if (empty_to_nan_<xsl:value-of select="@name"/>(*ids) &lt; 0)
    return -1;
    }
    }
#endif
    return 0; // TODO: Should we return status of ual_end_action?
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET"/>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET_H">
int get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime);</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET">
  <xsl:call-template name="COMMENT_FIELD"/>
  int get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime)
  {
  struct imas_mex_actionInfo action;
  struct imas_mex_fieldInfo field;
  // Paths-specific variables
  int maxpathsize=MAXPATHSIZE;
  mxArray* data=NULL;
  int ifield;
  int status = -1;
  int aosArraySize = -1;
  int aosCtx = -1;
  action.context = ctx;

  <xsl:apply-templates select="field" mode="GET_SINGLE"/>

  return 0;
  }
</xsl:template>


</xsl:stylesheet>
