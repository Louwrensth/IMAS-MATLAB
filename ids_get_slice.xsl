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
<xsl:include href="get_slice.xsl"/>
<xsl:include href="get_from_object.xsl"/>
<xsl:include href="time_tools.xsl"/>

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

  // Get the value of the inTime
  double inTime = mxGetScalar(prhs[3]);
#ifndef NDEBUG
  mexPrintf("The input inTime is:  %f\n", inTime);
#endif

  // Get the value of the occurence
  int interpolMode = (int) mxGetScalar(prhs[4]);
#ifndef NDEBUG
  mexPrintf("The input interpolMode is:  %d\n", interpolMode);
#endif
 
  // Call subfunction based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">get_slice</xsl:with-param>
    <xsl:with-param name="function_args">idx,occ,inTime,interpolMode,&amp;plhs[0]</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_get_slice:unknown_ids",
           "Unknown IDS name: %s", name);

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
   #include "imas_mex_utils.h"
   #include &lt;stdlib.h&gt;
   #include &lt;string.h&gt;
   #include &lt;stdio.h&gt;

   int get_slice_<xsl:value-of select="@name"/>(int expIdx, int idx, double inTime, int interpolMode, mxArray** ids)
   {
   int status;
   int numSamples;
   void *obj_single_time;
   int numDims, dim1, dim2, dim3, dim4, dim5, dim6, dim7;
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
   char timebasepath[maxpathsize];
   char* timepath;
   // AoS-specific variables<xsl:for-each select=".//field[@data_type='struct_array']">
   int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
   int n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
   mxArray* pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;
   mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
   // Structure-specific variables<xsl:for-each select=".//field[@data_type='structure']">
   mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
   mxArray* data=NULL;
   mwIndex ifield;
   mwSize* dims;
   mwSize dims_scalar[2] = { 1, 1 };
   int _i;
   char *basePath = "<xsl:value-of select="@name"/>";
   char path[strlen(basePath)+4];
   if(idx &lt; 1)
   sprintf(path, "%s", basePath);
   else
   sprintf(path, "%s/%d", basePath, idx);
   double retTime;
   status = beginIdsGetSlice(expIdx,  path, inTime);
   checkStatus(status);
   if(status) return status;
   *ids = mxCreateStructMatrix(1,1,0,NULL);
   <xsl:apply-templates select="field" mode="GET_SLICE">
     <xsl:with-param name="pointer_name" select="'*ids'"/>
   </xsl:apply-templates>
   endIdsGetSlice(expIdx, path);
   return 0;
   }
 </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
