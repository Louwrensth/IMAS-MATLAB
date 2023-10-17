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
<xsl:include href="get_single.xsl"/>
<xsl:include href="implementations.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
  <xsl:result-document href="src/ids/ids_get.c" standalone="yes" method="text">
/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file ids_get.c
   read IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   ids = ids_get(idx, IDSpath[, occ])
   \endcode

   MATLAB help:
   \include matlab/ids_get.m
 */

/** @}*/

#include "ids_get.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for two or three input arguments   */
  if(nrhs != 3 &amp;&amp; nrhs != 2) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargin",
                      "Two or three inputs required.");
  }

  /* make sure idx is scalar */
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input idx must be a scalar.");
  }
  /* Get the value of idx */
  int idx = (int) mxGetScalar(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input idx is:  %d\n", idx);

  /* make sure IDSpath is a string */
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notChar",
                        "Input IDSpath must be a string.");
  }
  /* Get the value of IDSpath */
  char *IDSpath = mxArrayToString(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);

  if(nrhs == 3) {
  int occ;
  size_t pathlen;
  /* make sure occ is scalar */
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input occurence must be a scalar.");
  }
  /* Get the value of occ */
  occ = (int) mxGetScalar(prhs[2]);
  if (params.verbosity >= 4)
  mexPrintf("The input occurence is:  %d\n", occ);
  if (occ &gt; 0) {
  pathlen = strlen(IDSpath);
  IDSpath = mxRealloc(IDSpath, (pathlen+5)*sizeof(char));
  snprintf(&amp;IDSpath[pathlen], 5, "/%d", occ);
  }
  }

  /* Check for one output argument */
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargout",
                      "One output maximum required.");
  }
  
  /* Extract IDS name */
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");
 
  /* Declare Function Pointer */
  al_status_t(*ids_get)(int, char*, mxArray**) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_get</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_get:unknown_ids",
           "Unknown IDS name: %s", name);

  /* free now as name uses the same memory */
  free(IDSpathcopy);

  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_status_t err = ids_get(idx, IDSpath, &amp;plhs[0]);
  if (err.code &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_get:");
  return;

}
  </xsl:result-document>
  <xsl:result-document href="src/ids/ids_get.h" standalone="yes" method="text">
    #include "mex.h"
    #include "imas_mex_utils.h"
    <xsl:apply-templates select = "IDS" mode="LIST">
      <xsl:with-param name="prefix" select="'al_status_t ids_get_'"/>
      <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, mxArray** ids);'"/>
    </xsl:apply-templates>
  </xsl:result-document>
  <xsl:result-document href="src/ids/get_ids.c" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">
    <xsl:variable name="ids_type" select="@type"/>
    <xsl:apply-templates select="." mode="METHOD_GET_H"/>
    al_status_t ids_get_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, mxArray** ids)
    {
      <xsl:call-template name="get_implementation"/>
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET_H"/>

    <xsl:apply-templates select=". | .//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET">
      <xsl:with-param name="ids_type"><xsl:value-of select="$ids_type"/></xsl:with-param>
    </xsl:apply-templates>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>

<xsl:template match="IDS | field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET_H">
  al_status_t get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, char* dataDictionaryVersion, bool taggedDataDictionaryVersion);</xsl:template>

<xsl:template match="IDS | field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET">
  <xsl:param name="ids_type"/>
  <xsl:call-template name="COMMENT_FIELD"/>
  al_status_t get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, char* dataDictionaryVersion, bool taggedDataDictionaryVersion)
  {
  struct imas_mex_actionInfo action;
  struct imas_mex_fieldInfo field;
  mxArray* data=NULL;
  al_status_t status = {0,""};
  al_status_t status_end;
  int aosArraySize = -1;
  int aosCtx = -1;
  action.context = ctx;
  
  <xsl:call-template name="declareAndAllocateNBCVariables"/>

  <xsl:apply-templates select="field" mode="GET_SINGLE">
    <xsl:with-param name="ids_type"><xsl:value-of select="$ids_type"/></xsl:with-param>
  </xsl:apply-templates>
  
  <xsl:call-template name="freeNBCVariables"/>

  return status;
  }
</xsl:template>


</xsl:stylesheet>
