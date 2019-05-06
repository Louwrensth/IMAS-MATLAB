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
<xsl:include href="allocate.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:result-document href="src/ids/ids_allocate.c.in" standalone="yes" method="text">
/*
 * ids_allocate.c - read IDS in MATLAB External Interfaces
 *
 *		ids = ids_allocate(IDSname, pathInIDS, n)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_allocate.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three input arguments  
  if(nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_allocate:nargin",
                      "Three inputs required.");
  }

  // make sure IDSname is a string
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_allocate:notChar",
                        "Input IDSname must be a string.");
  }
  // Get the value of IDSname
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  // make sure pathInIDS is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_allocate:notChar",
                        "Input pathInIDS must be a string.");
  }
  // Get the value of pathInIDS
  char *pathInIDS = mxArrayToString(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input pathInIDS is:  %s\n", pathInIDS);

  // make sure n is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_allocate:notScalar",
                        "Input n must be a scalar.");
  }
  // Get the value of n
  int n = (int) mxGetScalar(prhs[2]);
  if (params.verbosity >= 4)
  mexPrintf("The input n is:  %d\n", n);

  // Check for one output argument
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_allocate:nargout",
                      "One output maximum required.");
  }
  
  // Extract IDS name
  char* name = IDSname;

  // Declare Function Pointer
  int(*allocate)(char *, int, mxArray**) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">allocate</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_allocate:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  // Clean-up previous errors
  mex_errmsgid[0] = '\000';
  mex_errmsgtxt[0] = '\000';
  // Call function
  int err = allocate(pathInIDS, n, &amp;plhs[0]);
  if (err &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_allocate:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_allocate.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int allocate_'"/>
    <xsl:with-param name="suffix" select="'(char* pathInIDS, int n, mxArray** ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:result-document href="src/ids/allocate_ids.c.in" standalone="yes" method="text">
   #include "imas_mex_utils.h"
   <xsl:for-each select="IDS">
     int allocate_<xsl:value-of select="@name"/>(char* pathInIDS, int n, mxArray** ids)
     {
     int status;
     void *array;
     // Paths-specific variables
     int maxpathsize=MAXPATHSIZE;
     mxArray* data;
     int i;
     if (init_dataTree_read() &lt; 0)
     return -1;
     <xsl:for-each select=".//field[@data_type='struct_array']">
       if (!strncmp(pathInIDS, "<xsl:value-of select="@path"/>", maxpathsize)) {
       <xsl:apply-templates select="field" mode="ALLOCATE"/>
       } else
     </xsl:for-each>
     mexErrMsgIdAndTxt("IMAS:ids_allocate:unknown_path",
                       "Path '%s' did not match any known AoS in <xsl:value-of select="@name"/>", pathInIDS);
     if (replicate_dataTree_array(NULL, n) &lt; 0)
     return -1;
     if (get_data_from_dataTree(NULL, ids) &lt; 0)
     return -1;
     return 0;
     }
   </xsl:for-each>
 </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
