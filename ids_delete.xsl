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
<xsl:include href="delete.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:result-document href="src/ids/ids_delete.c.in" standalone="yes" method="text">
/*
 * ids_delete.c - delete IDS in MATLAB External Interfaces
 *
 *		status = ids_delete(idx, IDSpath[, occ])
 *
 * This is a MEX file for MATLAB.
*/
#include "ids_delete.h"
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  // Check for two or three input arguments  
  if(nrhs != 3 &amp;&amp; nrhs != 2) {
    mexErrMsgIdAndTxt("IMAS:ids_delete:nargin",
                      "Two or three inputs required.");
  }

  // make sure idx is scalar
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_delete:notScalar",
                        "Input idx must be a scalar.");
  }
  // Get the value of idx
  int idx = (int) mxGetScalar(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input idx is:  %d\n", idx);

  // make sure IDSpath is a string
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_delete:notChar",
                        "Input IDSpath must be a string.");
  }
  // Get the value of IDSpath
  char *IDSpath = mxArrayToString(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);

  if(nrhs == 3) {
  int occ;
  size_t pathlen;
  // make sure occ is scalar
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_delete:notScalar",
                        "Input occurence must be a scalar.");
  }
  // Get the value of occ
  occ = (int) mxGetScalar(prhs[2]);
  if (params.verbosity >= 4)
  mexPrintf("The input occurence is:  %d\n", occ);
  if (occ &gt; 0) {
  pathlen = strlen(IDSpath);
  IDSpath = mxRealloc(IDSpath, (pathlen+5)*sizeof(char));
  snprintf(&amp;IDSpath[pathlen], 5, "/%d", occ);
  }
  }

  // Check for one output argument
  if(nlhs > 1) {
    mexErrMsgIdAndTxt("IMAS:ids_delete:nargout",
                      "One output maximum required.");
  }
  
  // Extract IDS name
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");
 
  // Declare Function Pointer
  int(*delete)(int, char*) = NULL;
  // Assign pointer based on IDS name
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">delete</xsl:with-param>
  </xsl:apply-templates>
  // Error if there was no match
  mexErrMsgIdAndTxt("IMAS:ids_delete:unknown_ids",
           "Unknown IDS name: %s", name);
  // Call function
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *(int *)mxGetData(plhs[0]) = delete(idx, IDSpath);

  // free now as name uses the same memory
  free(IDSpathcopy);

}
  </xsl:result-document>
  <xsl:result-document href="src/ids/ids_delete.h.in" standalone="yes" method="text">
    #include "mex.h"
    <xsl:apply-templates select = "IDS" mode="LIST">
      <xsl:with-param name="prefix" select="'int delete_'"/>
      <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName);'"/>
    </xsl:apply-templates>
  </xsl:result-document>
  <xsl:result-document href="src/ids/delete_ids.c.in" standalone="yes" method="text">
    #include "imas_mex_utils.h"
   <xsl:for-each select="IDS">

    <xsl:apply-templates select=".//field[@data_type='structure']" mode="METHOD_DELETE_H"/>

    int delete_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName)
    {
    // Paths-specific variables
    char *fieldPath;
    int status = -1;
    int deleteOpCtx = -1;
    int ctx = -1;

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
   </xsl:for-each>
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
