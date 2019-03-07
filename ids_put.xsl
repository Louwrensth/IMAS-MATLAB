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
<xsl:include href="put_in_object.xsl"/>
<xsl:include href="puttime_single.xsl"/>
<xsl:include href="time_tools.xsl"/>

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
#include "mex.h"
#include &lt;string.h&gt;

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
#ifndef NDEBUG
  mexPrintf("The input idx is:  %d\n", idx);
#endif

  // Get the value of the name
  char *name = mxArrayToString(prhs[1]);
#ifndef NDEBUG
  mexPrintf("The input name is:  %s\n", name);
#endif

  // Get the value of the occurence
  int occ = (int) mxGetScalar(prhs[2]);
#ifndef NDEBUG
  mexPrintf("The input occurence is:  %d\n", occ);
#endif

  // Get the value of the ids
#ifndef NDEBUG
  mexPrintf("The input ids is:  %s\n", "SKIPPED");
#endif

 
  // Call subfunction based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">put</xsl:with-param>
    <xsl:with-param name="function_args">idx, occ, prhs[3]</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_put:unknown_ids",
           "Unknown IDS name: %s", name);

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
    #include "mex.h"
    #include "ual_low_level.h"
    #include "imas_mex_utils.h"
    #include &lt;stdlib.h&gt;
    #include &lt;string.h&gt;
    #include &lt;stdio.h&gt;

    int delete_<xsl:value-of select="@name"/>(int expIdx, int idx);

    int put_<xsl:value-of select="@name"/>(int expIdx, int idx, const mxArray* ids)
    {
    int status;
    int numSamples;
    void *obj_all_times;
    int numDims, dim1, dim2, dim3, dim4, dim5, dim6, dim7;
    int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
    int int0d;
    double double0d;
    int *intArray;
    double *doubleArray;
    char **stringArray;
    char *str;
    // Pointers for duplicating strings
    const char **dstringArray;
    char *dstr;
    // Paths-specific variables
    int maxpathsize=1024;
    char clepath[maxpathsize];
    char fullpath[maxpathsize];
    char timepath[maxpathsize];
    char timebasepath[maxpathsize];
    // AoS-specific variables<xsl:for-each select=".//field[@data_type='struct_array']">
    int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
    int n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
    const mxArray* pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;
    const mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
    // Structure-specific variables<xsl:for-each select=".//field[@data_type='structure']">
    const mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
    int ifield;
    const mxArray* data=NULL;
    const mxArray* ptime;
    double* dtime;
    const mxArray* pids_props=NULL;
    const mxArray* phomog_time=NULL;
    int homogeneous_time=EMPTY_INT;
    const mwSize* dims;
    int _i;
    char *basePath = "<xsl:value-of select="@name"/>";
    char path[strlen(basePath)+4];
    pids_props = mxGetField(ids, (mwIndex) 0, "ids_properties");
    if (pids_props == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_ids_properties",
      "Unable to retrieve ids%%ids_properties");
    phomog_time = mxGetField(pids_props, (mwIndex) 0, "homogeneous_time");
    if (phomog_time == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_homogeneous_time",
      "Unable to retrieve ids%%ids_properties%%homogeneous_time");
    homogeneous_time = (int) mxGetScalar(phomog_time);
    if( homogeneous_time == EMPTY_INT )
    {
    mexWarnMsgIdAndTxt("IMAS:ids_put:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT quits with no action.");
    return 0;
    }
    if(idx &lt; 1)
    sprintf(path, "%s", basePath);
    else
    sprintf(path, "%s/%d", basePath, idx);
    ptime = mxGetField(ids, (mwIndex) 0, "time");
    if (ptime == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_time",
      "Unable to retrieve ids%%time");
    dtime = mxGetPr(ptime);
    delete_<xsl:value-of select="@name"/>(expIdx, idx);
    status = beginIdsPut(expIdx, path);
    checkStatus(status);
    if(status) return status;
    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="pointer_name" select="'ids'"/>
      <xsl:with-param name="AosParent_name" select="'ids'"/>
    </xsl:apply-templates>
    endIdsPut(expIdx, path);
    return 0;
    }
  </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
