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
<xsl:include href="ints_doubles.xsl"/>
<xsl:include href="emptys_nans.xsl"/>
<xsl:include href="cells_structs.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">

  <xsl:apply-templates select="." mode="convert">
    <xsl:with-param name="src" select="'int'"/>
    <xsl:with-param name="dest" select="'double'"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="." mode="convert">
    <xsl:with-param name="src" select="'double'"/>
    <xsl:with-param name="dest" select="'int'"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="." mode="convert">
    <xsl:with-param name="src" select="'empty'"/>
    <xsl:with-param name="dest" select="'nan'"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="." mode="convert">
    <xsl:with-param name="src" select="'nan'"/>
    <xsl:with-param name="dest" select="'empty'"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="." mode="convert">
    <xsl:with-param name="src" select="'cell'"/>
    <xsl:with-param name="dest" select="'struct'"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="." mode="convert">
    <xsl:with-param name="src" select="'struct'"/>
    <xsl:with-param name="dest" select="'cell'"/>
  </xsl:apply-templates>

</xsl:template>


<xsl:template match = "/IDSs" mode="convert">
  <xsl:param name="src"/>
  <xsl:param name="dest"/>

  <xsl:param name="conversion" select="concat($src,'_to_',$dest)" />

 <xsl:result-document href="src/ids/ids_{$conversion}.c" standalone="yes" method="text">
/** \addtogroup extra MEX-interface-extra
 *  @{
 */

/**
   \file ids_<xsl:value-of select="$conversion"/>.c
   Convert IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m}
   ids = ids_<xsl:value-of select="$conversion"/>(IDSname, ids)
   \endcode

   MATLAB help:
   \include matlab/ids_<xsl:value-of select="$conversion"/>.m
 */

/** @}*/

#include "ids_<xsl:value-of select="$conversion"/>.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for one input arguments   */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$conversion"/>:nargin",
                      "Two inputs required.");
  }

  /* make sure IDSpath is a string */
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$conversion"/>:notChar",
                        "Input IDSpath must be a string.");
  }
  /* Get the value of IDSpath */
  char *IDSpath = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);

  /* make sure ids is scalar struct */
  if( !mxIsStruct(prhs[1]) ||
      !mxIsScalar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$conversion"/>:notScalar",
                        "Input ids must be a scalar structure.");
  }
  /* Get the value of ids */
  if (params.verbosity >= 4)
  mexPrintf("The input ids is:  %s\n", "SKIPPED");

  /* Check for one output argument */
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$conversion"/>:nargout",
                      "One output maximum required.");
  }
  
  /* Extract IDS name */
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");

  plhs[0] = mxDuplicateArray(prhs[1]);

  /* Declare Function Pointer */
  al_status_t(*ids_<xsl:value-of select="$conversion"/>)(mxArray*) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_<xsl:value-of select="$conversion"/></xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$conversion"/>:unknown_ids",
           "Unknown IDS path: %s", IDSpath);

  /* free now as name uses the same memory */
  free(IDSpathcopy);
  
  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_status_t err = ids_<xsl:value-of select="$conversion"/>(plhs[0]);
  if (err.code &lt; 0 )
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_<xsl:value-of select="$conversion"/>:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_{$conversion}.h" standalone="yes" method="text">
  #include "mex.h"
    #include "imas_mex_utils.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="concat('al_status_t ids_',$conversion,'_')"/>
    <xsl:with-param name="suffix" select="'(mxArray* ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
  <xsl:result-document href="src/ids/{$conversion}_ids.c" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">
      al_status_t ids_<xsl:value-of select="$conversion"/>_<xsl:value-of select="@name"/>(mxArray* ids)
      {
      al_status_t status;
      int aosArraySize;
      int isEmpty;
      /* AoS-specific variables */<xsl:for-each select=".//field[@data_type='struct_array']">
      int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
      int n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;</xsl:for-each>
      int ifield;
      mxArray* data=NULL;
      status = init_dataTree_write(ids);
      <xsl:choose>
	<xsl:when test="$conversion='int_to_double' or $conversion='double_to_int'">
	  <xsl:apply-templates select="field" mode="INTS_DOUBLES">
	    <xsl:with-param name="method_name" select="$conversion"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:when test="$conversion='empty_to_nan' or $conversion='nan_to_empty'">
	  <xsl:apply-templates select="field" mode="EMPTYS_NANS">
	    <xsl:with-param name="method_name" select="$conversion"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:when test="$conversion='cell_to_struct' or $conversion='struct_to_cell'">
	  <xsl:apply-templates select="field" mode="CELLS_STRUCTS">
	    <xsl:with-param name="method_name" select="$conversion"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message terminate="yes">ERROR: Unidentified conversion: <xsl:value-of select="$conversion"/> !</xsl:message>
	</xsl:otherwise>
      </xsl:choose>
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
