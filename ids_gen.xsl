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
 <xsl:result-document href="src/ids/ids_gen.c.in" standalone="yes" method="text">
/*
 * ids_gen.c -  initialise IDS in MATLAB External Interfaces
 *
 *		ids = ids_gen(IDSname)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_gen.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for one input arguments  
  if(nrhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_gen:nargin",
                      "One input required.");
  }

  // make sure IDSname is a string
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_gen:notChar",
                        "Input IDSname must be a string.");
  }
  // Get the value of IDSname
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  // Check for one output argument
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_gen:nargout",
                      "One output maximum required.");
  }
  
  // Extract IDS name
  char* name = IDSname;

  // Declare Function Pointer
  int(*gen)(mxArray**) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">gen</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_gen:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  // Clean-up previous errors
  mex_errmsgid[0] = '\000';
  mex_errmsgtxt[0] = '\000';
  // Call function
  int err = gen(&amp;plhs[0]);
  if (err &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_gen:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_gen.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int gen_'"/>
    <xsl:with-param name="suffix" select="'(mxArray** ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:result-document href="src/ids/gen_ids.c.in" standalone="yes" method="text">
   #include "imas_mex_utils.h"
   <xsl:for-each select="IDS">
     int gen_<xsl:value-of select="@name"/>(mxArray** ids)
     {
     int status;
     void *array;
     mxArray* data;
     if (init_dataTree_read() &lt; 0)
     return -1;
     <xsl:apply-templates select="field" mode="ALLOCATE"/>
     if (get_data_from_dataTree(NULL, ids) &lt; 0)
     return -1;
     return 0;
     }
   </xsl:for-each>
 </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
