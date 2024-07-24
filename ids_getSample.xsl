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
  <xsl:result-document href="src/ids/ids_getSample.c" standalone="yes" method="text">
/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file ids_getSample.c
   read IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   ids = ids_getSample(idx, IDSpath[, occ], tmin, tmax, dtime, csize, interpmode)
   \endcode

   MATLAB help:
   \include matlab/ids_getSample.m
 */

/** @}*/

#include "ids_getSample.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for two or three input arguments   */
  if(nrhs != 7 &amp;&amp; nrhs != 8) {
    mexErrMsgIdAndTxt("IMAS:ids_getSample:nargin",
                      "Six or seven inputs required.");
  }

  /* make sure idx is scalar */
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
                        "Input idx must be a scalar.");
  }
  /* Get the value of idx */
  int idx = (int) mxGetScalar(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input idx is:  %d\n", idx);

  /* make sure IDSpath is a string */
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notChar",
                        "Input IDSpath must be a string.");
  }
  /* Get the value of IDSpath */
  char *IDSpath = mxArrayToString(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);

  int occ;
  if(nrhs == 8) {
  size_t pathlen;
  /* make sure occ is scalar */
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
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
  else {
    occ = 0;
  }

  /* Check for tmin */
  if( !mxIsNumeric(prhs[nrhs-5]) ||
      !mxIsScalar(prhs[nrhs-5]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
                        "Input tmin must be a scalar.");
  }
  double tmin = mxGetScalar(prhs[nrhs-5]);
  if (params.verbosity >= 4)
  mexPrintf("The input tmin is:  %f\n", tmin);

  /* Check for tmax */
  if( !mxIsNumeric(prhs[nrhs-4]) ||
      !mxIsScalar(prhs[nrhs-4]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
                        "Input tmax must be a scalar.");
  }
  double tmax = mxGetScalar(prhs[nrhs-4]);
  if (params.verbosity >= 4)
  mexPrintf("The input tmax is:  %f\n", tmax);

  mwSize rank = mxGetNumberOfDimensions(prhs[nrhs-3]);
  mexPrintf("The input rank of dtime is:  %d\n", (int)rank);

  const mwSize * dimensions = mxGetDimensions(prhs[nrhs-3]);
  mexPrintf("The input shape of dtime is:  %d\n", (int)dimensions[0]);
  //csize = dimensions[0];
  /* Check for dtime */
  if(!mxIsScalar(prhs[nrhs-3]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
                        "Input dtime must be a scalar.");
  }
  const double *dtime = mxGetData(prhs[nrhs-3]);

  

  /* Check for csize */
  if( !mxIsNumeric(prhs[nrhs-2]) ||
      !mxIsScalar(prhs[nrhs-2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
                        "Input csize must be a scalar.");
  }
  int csize = (int) mxGetScalar(prhs[nrhs-2]);
  if (params.verbosity >= 4)
  mexPrintf("The input csize is:  %d\n", csize);

  /* Check for interpmode */
  if( !mxIsNumeric(prhs[nrhs-1]) ||
      !mxIsScalar(prhs[nrhs-1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_getSample:notScalar",
                        "Input interpmode must be a scalar.");
  }
  int interpmode = (int) mxGetScalar(prhs[nrhs-1]);
  if (params.verbosity >= 4)
  mexPrintf("The input interpmode is:  %d\n", interpmode);

  /* Check for one output argument */
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_getSample:nargout",
                      "One output maximum required.");
  }
  
  /* Extract IDS name */
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");
 
  /* Declare Function Pointer */
  al_status_t(*ids_getSample)(int, char*, mxArray**) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_getSample</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_getSample:unknown_ids",
           "Unknown IDS name: %s", name);

  /* free now as name uses the same memory */
  free(IDSpathcopy);

  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_status_t err = ids_getSample(idx, IDSpath, &amp;plhs[0], tmin, tmax, dtime, csize, interpmode);
  if (err.code &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_getSample:");
  return;

}
  </xsl:result-document>
  <xsl:result-document href="src/ids/ids_getSample.h" standalone="yes" method="text">
    #include "mex.h"
    #include "imas_mex_utils.h"
    <xsl:apply-templates select = "IDS" mode="LIST">
      <xsl:with-param name="prefix" select="'al_status_t ids_getSample_'"/>
      <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, mxArray** ids);'"/>
    </xsl:apply-templates>
  </xsl:result-document>
  <xsl:result-document href="src/ids/getSample_ids.c" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">
    <xsl:variable name="ids_type" select="@type"/>
    <xsl:apply-templates select="." mode="METHOD_GETSAMPLE_H"/>
    al_status_t ids_getSample_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, mxArray** ids, double tmin, double tmax, const double *dtime, int csize, int interpmode)
    {
      <xsl:call-template name="getSample_implementation"/>
    }
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>

<xsl:template match="IDS | field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GETSAMPLE_H">
  al_status_t get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, char* dataDictionaryVersion, bool taggedDataDictionaryVersion);</xsl:template>


</xsl:stylesheet>
