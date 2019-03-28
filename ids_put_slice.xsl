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
 <xsl:result-document href="src/ids/ids_put_slice.c.in" standalone="yes" method="text">
/*
 * ids_put_slice.c - write IDS slice in MATLAB External Interfaces
 *
 *		ids = ids_put_slice(idx, IDSpath[, occ], ids)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_put_slice.h"
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
#ifdef MEX_DEBUG
  mexPrintf("The input occurence is:  %d\n", occ);
#endif
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
#ifdef MEX_DEBUG
  mexPrintf("The input ids is:  %s\n", "SKIPPED");
#endif

  // Check for no output argument
  if(nlhs != 0) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargout",
                      "No output required.");
  }
  
  // Extract IDS name
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");

  // Declare Function Pointer
  int(*put_slice)(int, char*, const mxArray*) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">put_slice</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  if (put_slice == NULL)
  mexErrMsgIdAndTxt("IMAS:ids_put_slice:unknown_ids",
           "Unknown IDS name: %s", name);
  // Call function
  int err = put_slice(idx, IDSpath, prhs[nrhs-1]);
  if (err) 
  mexErrMsgIdAndTxt("IMAS:ids_put_slice:internal_error","internal error occured in function put_slice_<xsl:value-of select="@name"/> with code err=%d", err);
  return;

  // free now as name uses the same memory
  free(IDSpathcopy);

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_put_slice.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int put_slice_'"/>
    <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, const mxArray* ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:apply-templates select = "IDS" mode="PUT_SLICE"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="PUT_SLICE">
  <xsl:result-document href="src/ids/put_slice_{@name}.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_SLICE_H"/>

    int put_slice_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, const mxArray* ids)
    {
    int int0d;
    double double0d;
    int numDims, dim1, dim2, dim3, dim4, dim5, dim6, dim7;
    int *intArray;
    double *doubleArray;
    char *str;
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
    const mwSize* dims;
    char *idsName = "<xsl:value-of select="@name"/>";
    const mxArray* ptime=NULL;
    int status = -1;
    int arraySize = -1;
    int aosCtx = -1;
    int putSliceOpCtx = -1;
    int ctx = -1;
    int homogeneousTime = EMPTY_INT;
    double sliceTime = -1.0;

    if (getHomogeneousTime2(ids, &amp;homogeneousTime) &lt; 0) 
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_homogeneous_time",
      "Unable to retrieve ids%%ids_properties%%homogeneous_time");
    if( homogeneousTime == EMPTY_INT )
    {
    mexWarnMsgIdAndTxt("IMAS:ids_put_slice:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT_SLICE quits with no action.");
    return 0;
    }
    ptime = mxGetField(ids, (mwIndex) 0, "time");
    if (ptime == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put_slice:invalid_time",
      "Unable to retrieve ids%%time");
    sliceTime = mxGetScalar(ptime);

    // Open put context
    putSliceOpCtx = ual_begin_slice_action(expIdx, idsFullName, WRITE_OP, sliceTime, UNDEFINED_INTERP);
    if(putSliceOpCtx &lt; 0) 
    return putSliceOpCtx;
    ctx = putSliceOpCtx;

    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'yes'"/>
    </xsl:apply-templates>

    ual_end_action(ctx);
    return 0; // TODO: Should we return status of ual_end_action?
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_SLICE"/>
  </xsl:result-document>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_SLICE_H">
int put_slice_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, const mxArray* ids);</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_SLICE">
int put_slice_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, const mxArray* ids)
    {
    int int0d;
    double double0d;
    int numDims, dim1, dim2, dim3, dim4, dim5, dim6, dim7;
    int *intArray;
    double *doubleArray;
    char *str;
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
    const mwSize* dims;
    int status = -1;
    int arraySize = -1;
    int aosCtx = -1;

    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'yes'"/>
    </xsl:apply-templates>

    return 0;
    }
</xsl:template>

</xsl:stylesheet>
