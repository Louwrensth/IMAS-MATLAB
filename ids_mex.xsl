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
 <xsl:result-document href="src/ids_get.c" standalone="yes" method="text">
/*
 * ids_get.c - read IDS in MATLAB External Interfaces
 *
 *		ids = ids_get(idx, name, occ)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_get.h"
#include "mex.h"
#include &lt;string.h&gt;

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three input arguments  
  if(nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargin",
                      "Three inputs required.");
  }
  // make sure the 1st input argument is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input idx must be a scalar.");
  }
  // make sure the 2nd input argument is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notChar",
                        "Input name must be a string.");
  }
  // make sure the 3rd input argument is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_get:notScalar",
                        "Input occurence must be a scalar.");
  }

  // Check for one output argument
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_get:nargout",
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
 
  // Call subfunction based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH"/>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_get:unknown_ids",
           "Unknown IDS name: %s", name);

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_get.h" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST"/>
 </xsl:result-document>
 <xsl:apply-templates select = "IDS" mode="GET"/>
 <xsl:result-document href="src/ids/ids_get_slice.c" standalone="yes" method="text">
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
  <xsl:apply-templates select = "IDS" mode="SWITCH_SLICE"/>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_get_slice:unknown_ids",
           "Unknown IDS name: %s", name);

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_get_slice.h" standalone="yes" method="text">
  #include "mex.h"
  <xsl:apply-templates select = "IDS" mode="LIST_SLICE"/>
 </xsl:result-document>
 <xsl:apply-templates select = "IDS" mode="GET_SLICE"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="SWITCH">
  if (!strcmp(name, "<xsl:value-of select="@name"/>")) {
#ifndef NDEBUG
     mexPrintf("Matched <xsl:value-of select="@name"/>");
#endif
     int err = get_<xsl:value-of select="@name"/>(idx,occ,&amp;plhs[0]);
     if (!err) return;
}</xsl:template>

<xsl:template match="IDS" mode="SWITCH_SLICE">
  if (!strcmp(name, "<xsl:value-of select="@name"/>")) {
#ifndef NDEBUG
     mexPrintf("Matched <xsl:value-of select="@name"/>");
#endif
     int err = get_slice_<xsl:value-of select="@name"/>(idx,occ,inTime,interpolMode,&amp;plhs[0]);
     if (!err) return;
}</xsl:template>

<xsl:template match="IDS" mode="LIST">
int get_<xsl:value-of select="@name"/>(int expIdx, int occ, mxArray** ids);</xsl:template>

<xsl:template match="IDS" mode="LIST_SLICE">
int get_slice_<xsl:value-of select="@name"/>(int expIdx, int occ, double inTime, int interpolMode, mxArray** ids);</xsl:template>
<!--================================================-->
<!--                Template for time               -->
<!--================================================-->


<xsl:template name="printtimepath">
  <xsl:if test="@type = 'dynamic'">
    <xsl:choose>
      <xsl:when test="contains(@coordinate7,'time')"> <xsl:value-of select="translate(replace(@coordinate7,'(itime)',''),'()','')"/></xsl:when> <!-- We remove the (itime) pattern from the coordinate attribute in IDSDef, which is documentation-oriented -->
      <xsl:when test="contains(@coordinate6,'time')"> <xsl:value-of select="translate(replace(@coordinate6,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate5,'time')"> <xsl:value-of select="translate(replace(@coordinate5,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate4,'time')"> <xsl:value-of select="translate(replace(@coordinate4,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate3,'time')"> <xsl:value-of select="translate(replace(@coordinate3,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate2,'time')"> <xsl:value-of select="translate(replace(@coordinate2,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate1,'time')"> <xsl:value-of select="translate(replace(@coordinate1,'(itime)',''),'()','')"/></xsl:when>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="@name='time'">
    <xsl:value-of select="@path"/>
  </xsl:if>
  <!-- If the field itself IS time, then it is its own time coordinate -->
</xsl:template>

<xsl:template name="printtimevariable">
  <xsl:if test="@type = 'dynamic'">
    <xsl:choose>
      <xsl:when test="contains(@coordinate7,'time')">
	<xsl:value-of select="translate(@coordinate7,'/','.')"/>
      </xsl:when>
      <xsl:when test="contains(@coordinate6,'time')">
	<xsl:value-of select="translate(@coordinate6,'/','.')"/>
      </xsl:when>
      <xsl:when test="contains(@coordinate5,'time')">
	<xsl:value-of select="translate(@coordinate5,'/','.')"/>
      </xsl:when>
      <xsl:when test="contains(@coordinate4,'time')">
	<xsl:value-of select="translate(@coordinate4,'/','.')"/>
      </xsl:when>
      <xsl:when test="contains(@coordinate3,'time')">
	<xsl:value-of select="translate(@coordinate3,'/','.')"/>
      </xsl:when>
      <xsl:when test="contains(@coordinate2,'time')">
	<xsl:value-of select="translate(@coordinate2,'/','.')"/>
      </xsl:when>
      <xsl:when test="contains(@coordinate1,'time')">
	<xsl:value-of select="translate(@coordinate1,'/','.')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="@name='time'">
    <xsl:value-of select="translate(@path,'/','.')"/>
  </xsl:if>
  <!-- If the field itself IS time, then it is its own time coordinate -->
</xsl:template>

<xsl:template name="printIsTimed">
  <xsl:choose>
    <xsl:when test="@type = 'dynamic'">
      <xsl:value-of select="1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="0"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--================================================-->
<!--                 Include section                -->
<!--================================================-->

<xsl:include href="ids_get.xsl"/>
<xsl:include href="ids_get_slice.xsl"/>

</xsl:stylesheet>
