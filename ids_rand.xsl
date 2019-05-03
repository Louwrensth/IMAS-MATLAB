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
<xsl:include href="rand.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:result-document href="src/ids/ids_rand.c.in" standalone="yes" method="text">
/*
 * ids_rand.c -  initialise IDS in MATLAB External Interfaces
 *
 *		ids = ids_rand(IDSname)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_rand.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three input arguments  
  if(nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_rand:nargin",
                      "Three input required.");
  }

  // make sure IDSname is a string
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_rand:notChar",
                        "Input IDSname must be a string.");
  }
  // Get the value of IDSname
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  // make sure ntime is scalar
  if( !mxIsNumeric(prhs[1]) ||
      !mxIsScalar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input ntime must be a scalar.");
  }
  // Get the value of ntime
  int ntime = (int) mxGetScalar(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input ntime is:  %d\n", ntime);

  // make sure slice is scalar
  if( (!mxIsNumeric(prhs[2]) ||
       !mxIsScalar(prhs[2])) &amp;&amp;
       !mxIsLogicalScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input slice must be a scalar.");
  }
  // Get the value of slice
  int slice = (int) mxGetScalar(prhs[2]);
  if (params.verbosity >= 4)
  mexPrintf("The input slice is:  %d\n", slice);

  // Check for one output argument
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_rand:nargout",
                      "One output maximum required.");
  }
  
  // Extract IDS name
  char* name = IDSname;

  // Declare Function Pointer
  int(*rand)(mxArray**, int, int) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">rand</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  if (rand == NULL)
  mexErrMsgIdAndTxt("IMAS:ids_rand:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  // Clean-up previous errors
  mex_errmsgid[0] = '\000';
  mex_errmsgtxt[0] = '\000';
  // Call function
  int err = rand(&amp;plhs[0], ntime, slice);
  if (err &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_rand:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_rand.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int rand_'"/>
    <xsl:with-param name="suffix" select="'(mxArray** ids, int ntime, int slice);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:result-document href="src/ids/rand_ids.c.in" standalone="yes" method="text">
   #include "imas_mex_utils.h"
   #include "imas_mex_rand.h"
   <xsl:for-each select="IDS">
     int rand_<xsl:value-of select="@name"/>(mxArray** ids, int ntime, int slice)
     {
     int status;
     void *array;
     // AoS-specific variables<xsl:for-each select=".//field[@data_type='struct_array']">
     int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
     int n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;</xsl:for-each>
     mxArray* data;
     srandom(0);
     if (init_dataTree_read() &lt; 0)
     return -1;
     <xsl:apply-templates select="field" mode="RAND"/>
     if (get_data_from_dataTree(NULL, ids) &lt; 0)
     return -1;
     return 0;
     }
   </xsl:for-each>
 </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
