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
 <!-- Second Version: Empty AOS -->
 <xsl:result-document href="src/ids/ids_gen2.c.in" standalone="yes" method="text">
/** \addtogroup extra MEX-interface-extra
 *  @{
 */

/**
   \file ids_gen2.c
   Initialise IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m}
   ids = ids_gen2(IDSname)
   \endcode

   MATLAB help:
   \include matlab/ids_gen2.m
 */

/** @}*/

#include "ids_gen2.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for one input arguments   */
  if(nrhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_gen2:nargin",
                      "One input required.");
  }

  /* make sure IDSname is a string */
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_gen2:notChar",
                        "Input IDSname must be a string.");
  }
  /* Get the value of IDSname */
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  /* Check for one output argument */
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_gen2:nargout",
                      "One output maximum required.");
  }
  
  /* Extract IDS name */
  char* name = IDSname;

  /* Declare Function Pointer */
  int(*ids_gen2)(mxArray**) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_gen2</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_gen2:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  /* Clean-up previous errors */
  mex_errmsgid = NULL;
  mex_errmsgtxt[0] = '\000';
  /* Call function */
  int err = ids_gen2(&amp;plhs[0]);
  if (err &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_gen2:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_gen2.h.in" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'int ids_gen2_'"/>
    <xsl:with-param name="suffix" select="'(mxArray** ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:result-document href="src/ids/gen2_ids.c.in" standalone="yes" method="text">
   #include "imas_mex_utils.h"
   <xsl:for-each select="IDS">
     int ids_gen2_<xsl:value-of select="@name"/>(mxArray** ids)
     {
     int status = 0;
     void *array;
     mxArray* data;
     status = init_dataTree_read();
     <xsl:apply-templates select="field" mode="ALLOCATE"/>
     if (status >= 0) status = get_data_from_dataTree(NULL, ids);
     /* Error handling */
     if (status &lt; 0) {
     strncat(mex_errmsgtxt,"\n ... in IDS <xsl:value-of select="@name"/>",MAXERRMSGTXTSIZE-1-msglen);
     msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
     }

     return status;
     }
   </xsl:for-each>
 </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
