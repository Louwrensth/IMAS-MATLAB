<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

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
    mexErrMsgIdAndTxt("IMAS:ids_put:nargin",
                      "Two or three inputs required.");
  }

  // make sure idx is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input idx must be a scalar.");
  }
  // Get the value of idx
  int idx = (int) mxGetScalar(prhs[0]);
#ifdef MEX_DEBUG
  mexPrintf("The input idx is:  %d\n", idx);
#endif

  // make sure IDSpath is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notChar",
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
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
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
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargout",
                      "One output required.");
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
  // Call function
  int err = get(idx, IDSpath, &amp;plhs[0]);
  if (err) 
  mexErrMsgIdAndTxt("IMAS:ids_get:internal_error","internal error occured in function get_<xsl:value-of select="@name"/> with code err=%d", err);
  return;

  // free now as name uses the same memory
  free(IDSpathcopy);

}
  </xsl:result-document>
  <xsl:result-document href="src/ids/ids_get.h.in" standalone="yes" method="text">
    #include "mex.h"
    <xsl:apply-templates select = "IDS" mode="LIST">
      <xsl:with-param name="prefix" select="'int get_'"/>
      <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, mxArray** ids);'"/>
    </xsl:apply-templates>
  </xsl:result-document>
  <xsl:apply-templates select = "IDS" mode="GET"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="GET">
  <xsl:result-document href="src/ids/get_{@name}.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET_H"/>

    int get_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, mxArray** ids)
    {
    // Paths-specific variables
    char *fieldPath;
    char *timebasePath;
    // AoS-specific variables
    mxArray* aosArray=NULL;
    mxArray* aosElement=NULL;
    // Structure-specific variables
    mxArray* structure=NULL;
    mxArray* data=NULL;
    int ifield;
    char *idsName = "<xsl:value-of select="@name"/>";
    int status = -1;
    int arraySize = -1;
    int aosCtx = -1;
    int getOpCtx = -1;
    int ctx = -1;
    int homogeneousTime = -1;

    // Open get context
    getOpCtx = ual_begin_global_action(expIdx, idsFullName, READ_OP);
    if(getOpCtx &lt; 0) 
    return getOpCtx;
    ctx = getOpCtx;
    status = getHomogeneousTime(ctx, &amp;homogeneousTime);
    if(status &lt; 0) 
    {	
    ual_end_action(ctx);
    return status;
    }
    *ids = mxCreateStructMatrix(1,1,0,NULL);

    <xsl:apply-templates select="field" mode="GET_SINGLE"/>

    ual_end_action(ctx);
    return 0; // TODO: Should we return status of ual_end_action?
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET"/>
  </xsl:result-document>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET_H">
int get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, mxArray** ids);</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET">
  <xsl:call-template name="COMMENT_FIELD"/>
  int get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, mxArray** ids)
  {
  // Paths-specific variables
  char *fieldPath = "";
  char *timebasePath = "";
  // AoS-specific variables
  mxArray* aosArray=NULL;
  mxArray* aosElement=NULL;
  // Structure-specific variables
  mxArray* structure=NULL;
  mxArray* data=NULL;
  int ifield;
  int status = -1;
  int arraySize = -1;
  int aosCtx = -1;

  <xsl:apply-templates select="field" mode="GET_SINGLE"/>

  return 0;
  }
</xsl:template>


</xsl:stylesheet>
