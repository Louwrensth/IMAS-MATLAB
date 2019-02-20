<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MATLAB access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->
<xsl:template match = "/IDSs">
 <exsl:document href="src/ids_get.c" standalone="yes" method="text">
/*
 * ids_getmex.c - read IDS in MATLAB External Interfaces
 *
 *		ids = ids_getmex(idx, name, occ)
 *
 * This is a MEX file for MATLAB.
*/
#include "mex.h"
#include &lt;string.h&gt;

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for two input arguments  
  if(nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nrhs",
                      "Three inputs required.");
  }
  // make sure the first input argument is scalar
  if( !mxIsDouble(prhs[0]) || 
       mxIsComplex(prhs[0]) ||
       mxGetNumberOfElements(prhs[0]) != 1 ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input index must be a scalar.");
  }
  // make sure the second input argument is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notChar",
                        "Input name must be a string.");
  }
  // make sure the third input argument is scalar
  if( !mxIsDouble(prhs[2]) || 
       mxIsComplex(prhs[2]) ||
       mxGetNumberOfElements(prhs[2]) != 1 ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input occurence must be a scalar.");
  }

  // Check for one output argument
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nlhs",
                      "One output required.");
  }

  // Get the value of the index
  int idx = (int) mxGetScalar(prhs[0]);
#ifndef NDEBUG
  mexPrintf("The input index is:  %d\n", idx);
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

  // Prepare the return argument
  const char** fieldnames = NULL;
  plhs[0] = mxCreateStructMatrix(1,1,0,fieldnames);
 
  // Call subfunction based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH"/>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_get:unknown_ids",
           "Unknown IDS name: %s", name);

}
 </exsl:document>
 <exsl:document href="src/imas_mex_utils.h" standalone="yes" method="text">
   #define NON_TIMED   0
   #define TIMED       1
   #define TIMED_CLEAR 2

   #include "ual_low_level.h"
   #include &lt;stdlib.h&gt;
   #include &lt;string.h&gt;
   #include &lt;stdio.h&gt;

   void checkStatus(int status);
 </exsl:document>
 <exsl:document href="src/imas_mex_utils.c" standalone="yes" method="text">
   #include "imas_mex_utils.h"

   void checkStatus(int status) {if(status) printf("%s\n", imas_last_errmsg());}
 <</exsl:document>
 <xsl:apply-templates select = "IDS" mode="GET"/>
 <!--
     <xsl:apply-templates select = "IDS" mode="GET_SLICE"/>
 -->
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="SWITCH">
  if (!strcmp(name, "<xsl:value-of select="@name"/>")) {
#ifndef NDEBUG
     mexPrintf("Matched <xsl:value-of select="@name"/>");
#endif
     return;
     //int err = get_<xsl:value-of select="@name"/>(idx);
     //if (!err) return;
}</xsl:template>


<!--================================================-->
<!--                 Include section                -->
<!--================================================-->

<xsl:include href="ids_get.xsl"/>

</xsl:stylesheet>
