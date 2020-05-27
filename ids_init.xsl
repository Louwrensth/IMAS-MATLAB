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
 <xsl:result-document href="src/ids/ids_init.c" standalone="yes" method="text">
/** \addtogroup extra MEX-interface-extra
 *  @{
 */

/**
   \file ids_init.c
   Initialise IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m}
   ids = ids_init(IDSname)
   \endcode

   MATLAB help:
   \include matlab/ids_init.m
 */

/** @}*/

#include "ids_init.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for one input arguments   */
  if(nrhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_init:nargin",
                      "One input required.");
  }

  /* make sure IDSname is a string */
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_init:notChar",
                        "Input IDSname must be a string.");
  }
  /* Get the value of IDSname */
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  /* Check for one output argument */
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_init:nargout",
                      "One output maximum required.");
  }
  
  /* Extract IDS name */
  char* name = IDSname;

  /* Declare Function Pointer */
  al_status_t(*ids_init)(mxArray**) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_init</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_init:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_status_t err = ids_init(&amp;plhs[0]);
  if (err.code &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_init:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_init.h" standalone="yes" method="text">
  #include "mex.h"
   #include "imas_mex_utils.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'al_status_t ids_init_'"/>
    <xsl:with-param name="suffix" select="'(mxArray** ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
 <xsl:result-document href="src/ids/init_ids.c" standalone="yes" method="text">
   #include "imas_mex_utils.h"
   <xsl:for-each select="IDS">
     al_status_t ids_init_<xsl:value-of select="@name"/>(mxArray** ids)
     {
     al_status_t status;
     void *array;
     mxArray* data;
     status = init_dataTree_read();
     <xsl:apply-templates select="field" mode="ALLOCATE"/>
     if (status.code >= 0) status = get_data_from_dataTree(NULL, ids);
     /* Error handling */
     if (status.code &lt; 0) {
     addIdsPathInfoToErrMsg("\n ... in IDS <xsl:value-of select="@name"/>",1);
     }

     return status;
     }
   </xsl:for-each>
 </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
