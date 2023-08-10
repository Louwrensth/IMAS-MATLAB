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
<!--                Debug logs param                -->
<!--================================================-->
<xsl:variable name="enable-logging" select='no'/>

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
   \file ids_validate.c
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

    char *my_strtok_r (char *srcString, char delim, char **save_ptr)
    {
      uint openpar  = 0;
      uint closepar = 0;
      if(!srcString)
      {
          srcString = *save_ptr;
      }
      if(!srcString)
      {
          return NULL;
      }
      // handle beginning of the string containing delims
      while(1)
      {
          if(*srcString==delim)
          {
              srcString++;
              continue;
          }
          if(*srcString == '\0')
          {
              // we've reached the end of the string
              return NULL; 
          }
          break;
      }
      char *ret = srcString;
      while(1)
      {
          if(*srcString == '\0')
          {
              /*end of the input string and
              next exec will return NULL*/
              *save_ptr = srcString;
              return ret;
          }
          if(*srcString==delim)
          {
              if (openpar == closepar) {
              *srcString = '\0';
              *save_ptr = srcString + 1;
              return ret;
              }
          }
          if(*srcString=='(')  openpar++;
          if(*srcString==')')  closepar++;
          srcString++;
      }
    }


    const mxArray* getFieldFromStruct(char *path, const mxArray * data)
    {
      /* Extracts field from given structure 'data' following '/'-separated path */
    
      int ifield = -1;
      char *token;
      const mxArray* pfield; 
      char *relative_path;
      char *pathcopy = strdup(path);
      mwIndex index;
    
      if (!data) {
        return NULL;
      }
    
      /* Extract path after last closing bracket */
      token = strtok(pathcopy, ")");
      while (token != NULL) {
        relative_path = token;
        token = strtok(NULL, ")");
      }
    
      pfield = data;
    
      /* Structure unroll */
      token = strtok(relative_path, "/");
      while (token != NULL &amp;&amp; pfield != NULL) {
        if (!mxIsStruct(pfield) || 
      (params.use_cell_array_for_array_of_structures &amp;&amp; !mxIsScalar(pfield))) {
          pfield = NULL;
          break;
        }
        ifield = mxGetFieldNumber(pfield, token);
        if (ifield &lt; 0) {
          pfield = NULL;
          break;
        }
        pfield = (const mxArray *) mxGetFieldByNumber(pfield, index, ifield);
        token = strtok(NULL, "/");
        index = 0; /* Only the first item can be an array */
      }
      free(pathcopy);
      return pfield;
    }

    const mxArray *getFieldFromPath(const char *path, const mxArray *data, const int *indices_values, const char **indices_names) {

      char *token;
      char *pathcopy = strdup(path);
      char *relative_path;
      char *save_ptr;
      const mxArray *pfield = data;
      token = my_strtok_r(pathcopy, '/', &amp;save_ptr);
      token = my_strtok_r(NULL, '/', &amp;save_ptr);
      
      if (token==NULL) {
        pathcopy = strdup(path);
        token = my_strtok_r(pathcopy, '(', &amp;save_ptr);
        pfield = getFieldFromStruct(token, data);
        if(pfield != NULL) {
          token = my_strtok_r(NULL, ')', &amp;save_ptr);
          if (token != NULL) {
            if (strlen(token)==1) {
              int index = atoi(token);
              pfield = mxGetCell(pfield, index-1);
              return pfield;
            } else {
              // check if is in indices_name array
              for (int i = 0; i &lt; sizeof(*indices_values)/sizeof(int); i++) {
                if (strcmp(indices_names[i],token)==0) {
                  pfield = mxGetCell(pfield, indices_values[i]);
                  return pfield;
                }
              }
              //
              const mxArray *indexfield = getFieldFromPath(token, data, indices_values, indices_names);
              if (indexfield == NULL) {
                return NULL;
              } else {
                if (!mxIsNumeric(indexfield) &amp;&amp; !mxIsScalar(indexfield)) {
                  return NULL;
                } else 
                {
                  int scalar;
                  if (mxIsInt32(data)) {
                    scalar = *(int *) mxGetData(indexfield);
                  } else {
                    scalar = (int) mxGetScalar(indexfield);
                  }
                  pfield = mxGetCell(pfield, scalar-1);
                }
              }
            }
          }
        }
        return pfield;
      }
      pathcopy = strdup(path);
      token = my_strtok_r(pathcopy, '/', &amp;save_ptr);
      while (token != NULL &amp;&amp; pfield != NULL)
      {
        relative_path = token;
        pfield = getFieldFromPath(token, pfield, indices_values, indices_names);
        token = my_strtok_r(NULL, '/', &amp;save_ptr);
      }
      
      free(pathcopy);
      return pfield;
    }

    int getDimSize(const mxArray * data, int dim) {
        /* Find the dimension size of the data mxArray */
        int ndims;
        const mwSize * dims;
        
        if (data == NULL) return 0;
        
        ndims = mxGetNumberOfDimensions(data);
        dims = mxGetDimensions(data);
        
        if (dim &gt; ndims) return 0;
        /* 1D row vectors particular case */
        if (dim == 1 &amp;&amp; dims[0] == 1) {
          return dims[1];
        } 
        /* Other cases */
        else {
          return dims[dim-1];
        }
      }

    <xsl:for-each select="IDS">
    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/>
    
    al_status_t ids_validate_<xsl:value-of select="@name"/>(char* idsFullName, const mxArray* ids)
    {
    al_status_t status;
    int ifield;
    const mxArray* data=NULL;
    const mxArray* pfield=NULL;
    int idsTimeMode = IDS_TIME_MODE_UNKNOWN;
    int timeSize;
    int isEmpty;
    int i1max, i2max, i3max, i4max, itimemax;
    int aosArraySize;
    int coordSize;

    status = init_dataTree_write((mxArray *) ids);
    if (status.code >= 0) status = getHomogeneousTime(&amp;idsTimeMode);
    if (status.code &lt; 0) mexErrMsgIdAndTxt("IMAS:ids_validate:invalid_homogeneous_time",
    "Unable to retrieve ids%%ids_properties%%homogeneous_time"); 
    if( idsTimeMode == IDS_TIME_MODE_UNKNOWN )
    {
    mexErrMsgIdAndTxt("IMAS:ids_validate:empty_ids", "ids%%ids_properties%%homogeneous_time is not defined.");
    return status;
    }
    else if ( idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
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

    status = get_data_from_dataTree(NULL, (mxArray **) &amp;data);

    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_CALL"/>
    <xsl:apply-templates select="field[@data_type='struct_array']" mode="VALIDATE_CHILD_1D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_1D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_2D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_3D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_4D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_5D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_6D"/>

    return status;
    }

    <!-- <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/> -->

    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>
<xsl:template match = "field[@data_type='structure' or @data_type='struct_array']" mode="VALIDATE_CHILD_CALL">
  <xsl:choose>
  <xsl:when test="@data_type='structure'"> 
    if (status.code &gt;= 0) pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
    if (pfield != NULL &amp;&amp; status.code &gt;= 0) {
    if (status.code &gt;= 0) status = begin_dataTree_write("<xsl:value-of select="@name"/>", &amp;isEmpty);
    if (!isEmpty &amp;&amp; status.code &gt;= 0) status = validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(idsTimeMode, timeSize);
    if (status.code &gt;= 0) end_dataTree_action();
    }
  </xsl:when>
  <xsl:when test="@data_type='struct_array'">
    if (status.code &gt;= 0) pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
    if (pfield != NULL &amp;&amp; status.code &gt;= 0) {
    if (status.code &gt;= 0) status = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
    if (status.code &gt;= 0) {
      <xsl:if test="$enable-logging = 'yes'">
        printf("Loop for <xsl:value-of select="@name"/> over %d elements.\n\r",aosArraySize);
      </xsl:if>
      for (int i=0; i&lt;aosArraySize; i++) {
      const mxArray* elem = mxGetCell(pfield, i);
      if (elem != NULL) {
        if (status.code &gt;= 0 &amp;&amp; (mxIsStruct(elem))) {
          if (status.code &gt;= 0) status = iterate_dataTree_array(i);
          if (status.code &gt;= 0) status = validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(idsTimeMode, timeSize);
        }
        }
      }
    }
    if (status.code &gt;= 0) status = end_dataTree_array_action();
    }
  </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE_H">
al_status_t validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int idsTimeMode, int timeSize);
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE">
<xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/>
    al_status_t validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int idsTimeMode, int timeSize)
    {
    const mxArray* data=NULL;
    const mxArray* pfield=NULL;
    al_status_t status = {0,""};
    int isEmpty;
    int aosArraySize;
    int ifield;
    int ndims;
    int i1max, i2max, i3max, i4max, itimemax;
	  const mwSize *dims;

    status = get_data_from_dataTree(NULL, (mxArray **) &amp;data);

    if (data != NULL &amp;&amp; !mxIsEmpty(data)) {

    <xsl:if test="$enable-logging = 'yes'">
      printf("In validate_<xsl:value-of select="@path"/>\n\r");
    </xsl:if>

    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_CALL"/>

    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_1D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_2D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_3D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_4D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_5D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_6D"/>
    }

    <xsl:if test="$enable-logging = 'yes'">
      printf("end validate_<xsl:value-of select="@path"/> with statuscode: %d\n\r",status.code);
    </xsl:if>

    return status;
    }
    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>
</xsl:template>


</xsl:stylesheet>
