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
 <xsl:result-document href="src/ids/ids_get_slice.c.in" standalone="yes" method="text">
/*
 * ids_get_slice.c - read IDS in MATLAB External Interfaces
 *
 *		ids = ids_get_slice(idx, name, occ, inTime, interpolMode)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_get_slice.h"
#include "mex.h"
#include &lt;string.h&gt;

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three input arguments  
  if(nrhs != 5) {
    mexErrMsgIdAndTxt("IMAS:ids_get_slice:nargin",
                      "Five inputs required.");
  }
  // make sure the 1st input argument is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get_slice:notScalar",
                        "Input idx must be a scalar.");
  }
  // make sure the 2nd input argument is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get_slice:notChar",
                        "Input name must be a string.");
  }
  // make sure the 3rd input argument is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get_slice:notScalar",
                        "Input occurence must be a scalar.");
  }
  // make sure the 4th input argument is scalar
  if( !mxIsNumeric(prhs[3]) ||
      !mxIsScalar(prhs[3]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get_slice:notScalar",
                        "Input inTime must be a scalar.");
  }
  // make sure the 5th input argument is scalar
  if( !mxIsNumeric(prhs[4]) ||
      !mxIsScalar(prhs[4]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get_slice:notScalar",
                        "Input interpolMode must be a scalar.");
  }

  // Check for one output argument
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_get_slice:nargout",
                      "One output required.");
  }

  // Get the value of the idx
  int idx = (int) mxGetScalar(prhs[0]);
#ifdef MEX_DEBUG
  mexPrintf("The input idx is:  %d\n", idx);
#endif

  // Get the value of the name
  char *name = mxArrayToString(prhs[1]);
#ifdef MEX_DEBUG
  mexPrintf("The input name is:  %s\n", name);
#endif

  // Get the value of the occurence
  int occ = (int) mxGetScalar(prhs[2]);
#ifdef MEX_DEBUG
  mexPrintf("The input occurence is:  %d\n", occ);
#endif

  // Get the value of the inTime
  double inTime = mxGetScalar(prhs[3]);
#ifdef MEX_DEBUG
  mexPrintf("The input inTime is:  %f\n", inTime);
#endif

  // Get the value of the occurence
  int interpolMode = (int) mxGetScalar(prhs[4]);
#ifdef MEX_DEBUG
  mexPrintf("The input interpolMode is:  %d\n", interpolMode);
#endif
 
  // Declare Function Pointer
  int(*get_slice)(int, int, double, int, mxArray**) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">get_slice</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  if (get_slice == NULL)
  mexErrMsgIdAndTxt("IMAS:ids_get_slice:unknown_ids",
           "Unknown IDS name: %s", name);
  // Call function
  int err = get_slice(idx, occ, inTime, interpolMode, &amp;plhs[0]);
  if (err) 
  mexErrMsgIdAndTxt("IMAS:ids_get_slice:internal_error","internal error occured in function get_slice_<xsl:value-of select="@name"/> with code err=%d", err);
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_get_slice.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int get_slice_'"/>
    <xsl:with-param name="suffix" select="'(int expIdx, int occ, double inTime, int interpolMode, mxArray** ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:apply-templates select = "IDS" mode="GET_SLICE"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="GET_SLICE">
  <xsl:result-document href="src/ids/get_slice_{@name}.c.in" standalone="yes" method="text">
    #include "mex.h"
    #include "ual_low_level.h"
    #include "ual_lowlevel.h"
    #include "imas_mex_utils.h"
    #include &lt;stdlib.h&gt;
    #include &lt;string.h&gt;
    #include &lt;stdio.h&gt;

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET_H"/>

    int get_slice_<xsl:value-of select="@name"/>(int expIdx, int iOccurence, double inTime, int interpolMode, mxArray** ids)
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
    char idsFullName[strlen(idsName)+4];
    int status = -1;
    int arraySize = -1;
    int aosCtx = -1;
    int getSliceOpCtx = -1;
    int ctx = -1;
    int homogeneousTime = -1;

    if(iOccurence &lt; 1)
    sprintf(idsFullName, "%s", idsName);
    else
    sprintf(idsFullName, "%s/%d", idsName, iOccurence);
    // Open getSlice context
    getSliceOpCtx = ual_begin_slice_action(expIdx, idsFullName, READ_OP, inTime, interpolMode);
    if(getSliceOpCtx &lt; 0) 
    return getSliceOpCtx;
    ctx = getSliceOpCtx;
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
