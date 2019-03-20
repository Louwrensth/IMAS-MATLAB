<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--================================================-->
<!--                 Include section                -->
<!--================================================-->

<xsl:include href="mex_tools.xsl"/>
<xsl:include href="delete.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
  <xsl:result-document href="src/ids/ids_delete.c.in" standalone="yes" method="text">
/*
 * ids_delete.c - delete IDS in MATLAB External Interfaces
 *
 *		ids = ids_delete(idx, name, occ)
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_delete.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for three input arguments  
  if(nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_delete:nargin",
                      "Three inputs required.");
  }
  // make sure the 1st input argument is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_delete:notScalar",
                        "Input idx must be a scalar.");
  }
  // make sure the 2nd input argument is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_delete:notChar",
                        "Input name must be a string.");
  }
  // make sure the 3rd input argument is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_delete:notScalar",
                        "Input occurence must be a scalar.");
  }

  // Check for one output argument
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_delete:nargout",
                      "One output required.");
  }

  // Get the value of the idx
  int idx = (int) mxGetScalar(prhs[0]);
#ifdef MEX_DEBUG
  mexPrintf("The input idx is:  %d\n", idx);
#endif

  // Get the value of the name
  char *name = mxArrayToString(prhs[1]);
#ifdef MEX_DEBUG
  mexPrintf("The input name is:  %s\n", name);
#endif

  // Get the value of the occurence
  int occ = (int) mxGetScalar(prhs[2]);
#ifdef MEX_DEBUG
  mexPrintf("The input occurence is:  %d\n", occ);
#endif
 
  // Declare Function Pointer
  int(*delete)(int, int) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">delete</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  if (delete == NULL)
  mexErrMsgIdAndTxt("IMAS:ids_delete:unknown_ids",
           "Unknown IDS name: %s", name);
  // Call function
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *(int *)mxGetData(plhs[0]) = delete(idx, occ);

}
  </xsl:result-document>
  <xsl:result-document href="src/ids/ids_delete.h.in" standalone="yes" method="text">
    #include "mex.h"
    <xsl:apply-templates select = "IDS" mode="LIST">
      <xsl:with-param name="prefix" select="'int delete_'"/>
      <xsl:with-param name="suffix" select="'(int expIdx, int occ);'"/>
    </xsl:apply-templates>
  </xsl:result-document>
  <xsl:apply-templates select = "IDS" mode="DELETE"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="DELETE">
  <xsl:result-document href="src/ids/delete_{@name}.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"

    <xsl:apply-templates select=".//field[@data_type='structure']" mode="METHOD_DELETE_H"/>

    int delete_<xsl:value-of select="@name"/>(int expIdx, int iOccurence)
    {
    // Paths-specific variables
    char *fieldPath;
    char *idsName = "<xsl:value-of select="@name"/>";
    char idsFullName[strlen(idsName)+4];
    int status = -1;
    int deleteOpCtx = -1;
    int ctx = -1;

    if(iOccurence &lt; 1)
    sprintf(idsFullName, "%s", idsName);
    else
    sprintf(idsFullName, "%s/%d", idsName, iOccurence);
    // Open delete context
    deleteOpCtx = ual_begin_global_action(expIdx, idsFullName, WRITE_OP);
    if(deleteOpCtx &lt; 0) 
    return deleteOpCtx;
    ctx = deleteOpCtx;

    <xsl:apply-templates select="field" mode="DELETE"/>

    ual_end_action(ctx);
    return 0; // TODO: Should we return status of ual_end_action?
    }

    <xsl:apply-templates select=".//field[@data_type='structure']" mode="METHOD_DELETE"/>
  </xsl:result-document>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_DELETE_H">
int delete_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx);</xsl:template>

<xsl:template match="field[@data_type='structure']" mode="METHOD_DELETE">
  <xsl:call-template name="COMMENT_FIELD"/>
  int delete_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx)
  {
  // Paths-specific variables
  char *fieldPath = "";
  int status = -1;

  <xsl:apply-templates select="field" mode="DELETE"/>

  return 0;
  }
</xsl:template>


</xsl:stylesheet>
