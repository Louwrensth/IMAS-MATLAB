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
<xsl:include href="put_single.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:result-document href="src/ids/ids_put.c.in" standalone="yes" method="text">
/*
 * ids_put.c - write IDS in MATLAB External Interfaces
 *
 *		ids = ids_put(idx, name, occ, ids)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_put.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three input arguments  
  if(nrhs != 4) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargin",
                      "Four inputs required.");
  }
  // make sure the 1st input argument is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input idx must be a scalar.");
  }
  // make sure the 2nd input argument is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notChar",
                        "Input name must be a string.");
  }
  // make sure the 3rd input argument is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input occurence must be a scalar.");
  }
  // make sure the 4th input argument is scalar
  if( !mxIsStruct(prhs[3]) ||
      !mxIsScalar(prhs[3]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input ids must be a scalar structure.");
  }

  // Check for no output argument
  if(nlhs != 0) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargout",
                      "No output required.");
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

  // Get the value of the ids
#ifdef MEX_DEBUG
  mexPrintf("The input ids is:  %s\n", "SKIPPED");
#endif
 
  // Declare Function Pointer
  int(*put)(int, int, const mxArray*) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">put</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  if (put == NULL)
  mexErrMsgIdAndTxt("IMAS:ids_put:unknown_ids",
           "Unknown IDS name: %s", name);
  // Call function
  int err = put(idx, occ, prhs[3]);
  if (err) 
  mexErrMsgIdAndTxt("IMAS:ids_put:internal_error","internal error occured in function put_<xsl:value-of select="@name"/> with code err=%d", err);
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_put.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int put_'"/>
    <xsl:with-param name="suffix" select="'(int expIdx, int occ, const mxArray* ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:apply-templates select = "IDS" mode="PUT"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="PUT">
  <xsl:result-document href="src/ids/put_{@name}.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"

    int delete_<xsl:value-of select="@name"/>(int expIdx, int iOccurence);
    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_H"/>

    int put_<xsl:value-of select="@name"/>(int expIdx, int iOccurence, const mxArray* ids)
    {
    // Paths-specific variables
    char *fieldPath;
    char *timebasePath;
    // AoS-specific variables
    const mxArray* aosArray=NULL;
    const mxArray* aosElement=NULL;
    // Structure-specific variables
    const mxArray* structure=NULL;
    const mxArray* data=NULL;
    int ifield;
    char *idsName = "<xsl:value-of select="@name"/>";
    char idsFullName[strlen(idsName)+4];
    const mxArray* pids_props=NULL;
    const mxArray* phomog_time=NULL;
    int status = -1;
    int arraySize = -1;
    int aosCtx = -1;
    int putOpCtx = -1;
    int ctx = -1;
    int homogeneousTime = -1;

    pids_props = mxGetField(ids, (mwIndex) 0, "ids_properties");
    if (pids_props == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_ids_properties",
      "Unable to retrieve ids%%ids_properties");
    phomog_time = mxGetField(pids_props, (mwIndex) 0, "homogeneous_time");
    if (phomog_time == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_homogeneous_time",
      "Unable to retrieve ids%%ids_properties%%homogeneous_time");
    homogeneousTime = (int) mxGetScalar(phomog_time);
    if( homogeneousTime == EMPTY_INT )
    {
    mexWarnMsgIdAndTxt("IMAS:ids_put:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT quits with no action.");
    return 0;
    }

    if(iOccurence &lt; 1)
    sprintf(idsFullName, "%s", idsName);
    else
    sprintf(idsFullName, "%s/%d", idsName, iOccurence);

    // Delete existing IDS if any
    delete_<xsl:value-of select="@name"/>(expIdx, iOccurence);
    // Open put context
    putOpCtx = ual_begin_global_action(expIdx, idsFullName, WRITE_OP);
    if(putOpCtx &lt; 0) 
    return putOpCtx;
    ctx = putOpCtx;

    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'no'"/>
    </xsl:apply-templates>

    ual_end_action(ctx);
    return 0; // TODO: Should we return status of ual_end_action?
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT"/>
  </xsl:result-document>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_H">
int put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, const mxArray* ids);</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT">
int put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, const mxArray* ids)
    {
    // Paths-specific variables
    char *fieldPath;
    char *timebasePath;
    // AoS-specific variables
    const mxArray* aosArray=NULL;
    const mxArray* aosElement=NULL;
    // Structure-specific variables
    const mxArray* structure=NULL;
    const mxArray* data=NULL;
    int ifield;
    int status = -1;
    int arraySize = -1;
    int aosCtx = -1;

    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'no'"/>
    </xsl:apply-templates>

    return 0;
    }
</xsl:template>

</xsl:stylesheet>
