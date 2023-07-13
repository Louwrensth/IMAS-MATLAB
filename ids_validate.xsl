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
<xsl:include href="validate_single.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
  <xsl:result-document href="src/ids/ids_validate.c" standalone="yes" method="text">
/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file ids_get.c
   read IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   ids_validate(IDSname, ids)
   \endcode

   MATLAB help:
   \include matlab/ids_validate.m
 */

/** @}*/

#include "ids_validate.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for one input arguments   */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt("IMAS:ids_validate:nargin",
                      "Two inputs required.");
  }

  /* make sure IDSname is a string */
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_validate:notChar",
                        "Input IDSname must be a string.");
  }
  /* Get the value of IDSname */
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  /* make sure ids is scalar struct */
  if( !mxIsStruct(prhs[1]) ||
      !mxIsScalar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_validate:notScalar",
                        "Input ids must be a scalar structure.");
  }
  /* Get the value of ids */
  if (params.verbosity >= 4)
  mexPrintf("The input ids is:  %s\n", "SKIPPED");

  /* Check for no output argument */
  if(nlhs > 0) {
    mexErrMsgIdAndTxt("IMAS:ids_validate:nargout",
                      "No output required.");
  }

  /* Extract IDS name */
  char* name = IDSname;

  /* Declare Function Pointer */
  al_status_t(*ids_validate)(char*,const mxArray*) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_validate</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_validate:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_status_t err = ids_validate(IDSname, prhs[1]);
  if (err.code &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_validate:");
  return;

}
 </xsl:result-document>

  <xsl:result-document href="src/ids/ids_validate.h" standalone="yes" method="text">
    #include "mex.h"
    #include "imas_mex_utils.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'al_status_t ids_validate_'"/>
    <xsl:with-param name="suffix" select="'(char* idsFullName, const mxArray* ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>

 <xsl:result-document href="src/ids/validate_ids.c" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">
    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/>
    
    al_status_t ids_validate_<xsl:value-of select="@name"/>(char* idsFullName, const mxArray* ids)
    {
    al_status_t status;
    int ifield;
    const mxArray* data=NULL;
    int homogeneousTime = IDS_TIME_MODE_UNKNOWN;
    int timeSize;
    int isEmpty;

    status = init_dataTree_write((mxArray *) ids);
    if (status.code >= 0) status = getHomogeneousTime(&amp;homogeneousTime);
    if (status.code &lt; 0) mexErrMsgIdAndTxt("IMAS:ids_validate:invalid_homogeneous_time",
    "Unable to retrieve ids%%ids_properties%%homogeneous_time"); 
    if( homogeneousTime == IDS_TIME_MODE_UNKNOWN )
    {
    mexErrMsgIdAndTxt("IMAS:ids_validate:empty_ids", "ids%%ids_properties%%homogeneous_time is not defined.");
    return status;
    }
    else if ( homogeneousTime == IDS_TIME_MODE_HOMOGENEOUS ) {
      ifield = mxGetFieldNumber(ids, "time");
      data = mxGetFieldByNumber(ids, (mwIndex) 0, ifield);
      if (data == NULL)
        mexErrMsgIdAndTxt("IMAS:ids_validate:invalid_time",
        "Unable to retrieve ids%%time");
      timeSize = mxGetNumberOfElements(data);
      if (timeSize &lt; 1)
      mexErrMsgIdAndTxt("IMAS:ids_validate:empty_time",
      "If time is homogeneous, ids%%time must have at least one element");
    }

    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_CALL"/>

    return status;
    }

    <!-- <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/> -->

    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>
<xsl:template match = "field[@data_type='structure' or @data_type='struct_array']" mode="VALIDATE_CHILD_CALL">
    if (status.code &gt;= 0) status = validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(homogeneousTime, timeSize);
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE_H">
al_status_t validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int homogeneousTime, int timeSize);
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE">
<xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/>
    al_status_t validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int homogeneousTime, int timeSize)
    {
    const mxArray* data=NULL;
    al_status_t status = {0,""};
    int isEmpty;

    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_CALL"/>

    return status;
    }
    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>
</xsl:template>


</xsl:stylesheet>
