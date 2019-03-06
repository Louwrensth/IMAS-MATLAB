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
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="PUT_SLICE">
  <xsl:result-document href="src/ids/put_slice_{@name}.c" standalone="yes" method="text">
    #include "mex.h"
    #include "ual_low_level.h"
    #include "imas_mex_utils.h"
    #include &lt;stdlib.h&gt;
    #include &lt;string.h&gt;
    #include &lt;stdio.h&gt;

    int put_slice_<xsl:value-of select="@name"/>(int expIdx, int idx, const mxArray* ids)
    {
    int status;
    int numSamples;
    void *obj_all_times;
    int numDims, dim1, dim2, dim3, dim4, dim5, dim6, dim7;
    int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
    int int0d;
    double double0d;
    int *intArray;
    double *doubleArray;
    char **stringArray;
    char *str;
    // Pointers for duplicating strings
    const char **dstringArray;
    char *dstr;
    // Paths-specific variables
    int maxpathsize=1024;
    char clepath[maxpathsize];
    char fullpath[maxpathsize];
    char *timepath;
    char *timebasepath;
    // AoS-specific variables<xsl:for-each select=".//field[@data_type='struct_array']">
    int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
    int n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
    const mxArray* pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;
    const mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
    // Structure-specific variables<xsl:for-each select=".//field[@data_type='structure']">
    const mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
    const mxArray* data=NULL;
    const mxArray* ptime;
    double* dtime;
    const mxArray* pids_props=NULL;
    const mxArray* phomog_time=NULL;
    int homogeneous_time=EMPTY_INT;
    int ifield;
    const mwSize* dims;
    int _i;
    char *basePath = "<xsl:value-of select="@name"/>";
    char path[strlen(basePath)+4];
    pids_props = mxGetField(ids, (mwIndex) 0, "ids_properties");
    if (pids_props == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put_slice::invalid_ids_properties",
      "Unable to retrieve ids%%ids_properties");
    phomog_time = mxGetField(pids_props, (mwIndex) 0, "homogeneous_time");
    if (phomog_time == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put_slice::invalid_homogeneous_time",
      "Unable to retrieve ids%%ids_properties%%homogeneous_time");
    homogeneous_time = (int) mxGetScalar(phomog_time);
    if( homogeneous_time == EMPTY_INT )
    {
    mexWarnMsgIdAndTxt("IMAS:ids_put_slice:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT_SLICE quits with no action.");
    return 0;
    }
    if (homogeneous_time != 1) {
    mexErrMsgIdAndTxt("IMAS:ids_put_slice:inhomogeneous_time", "the PUT_SLICE routine works only for homogeneous timebase IDS");
    return (-99);
    }
    timebasepath = "time";
    if(idx &lt; 1)
    sprintf(path, "%s", basePath);
    else
    sprintf(path, "%s/%d", basePath, idx);
    ptime = mxGetField(ids, (mwIndex) 0, "time");
    if (ptime == NULL)
    mexErrMsgIdAndTxt("IMAS:ids_put:invalid_time",
    "Unable to retrieve ids%%time");
    dtime = mxGetPr(ptime);
    status = beginIdsPutSlice(expIdx,  path);
    checkStatus(status);
    if(status) return status;
    <xsl:apply-templates select="field" mode="PUT_SLICE">
      <xsl:with-param name="pointer_name" select="'ids'"/>
      <xsl:with-param name="AosParent_name" select="'ids'"/>
    </xsl:apply-templates>
    endIdsPutSlice(expIdx, path);
    return 0;
    }
  </xsl:result-document>
</xsl:template>

<!--=================================================-->
<!--              put field into a slice             -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_SLICE">
  <xsl:param name="pointer_name"/>
  <xsl:param name="AosParent_name"/>
  <xsl:param name="path_format"/>
  <xsl:param name="path_args"/>

  <xsl:param name="currentpath_format">
    <xsl:choose>
      <xsl:when test="$path_format"><xsl:value-of select="concat($path_format,'/',@name)"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="currentpath_expr">
    <xsl:choose>
      <xsl:when test="$path_args">
      snprintf(clepath,maxpathsize,"<xsl:value-of select="$currentpath_format"/>"<xsl:value-of select="$path_args"/>);</xsl:when>
      <xsl:otherwise>
      snprintf(clepath,maxpathsize,"%s","<xsl:value-of select="$currentpath_format"/>");</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:if test="@type ='dynamic' or @data_type='structure' or @data_type='struct_array'">
  // Doc PutSlice <xsl:value-of select="@path_doc"/>
    <xsl:choose>
      <!--========== Regular structures ==========-->
      <xsl:when test="@data_type='structure'">
	p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetField(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, "<xsl:value-of select="@name"/>");
	if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
	"Unable to retrieve field %s (in PUT_SLICE)", "<xsl:value-of select="@path"/>");
	<xsl:apply-templates select="field" mode="PUT_SLICE">
	  <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	  <xsl:with-param name="AosParent_name" select="$AosParent_name"/>
	  <xsl:with-param name="path_format" select="$currentpath_format"/>
	  <xsl:with-param name="path_args" select="$path_args"/>
	</xsl:apply-templates>
      </xsl:when>

      <!--========== Arrays of structures ==========-->
      <xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
	<!-- Type 1 arrays of structure, with potentially multiple time bases -->
	/* AoS of type 1 */
	<xsl:choose>
	  <xsl:when test="$path_args">
	  snprintf(clepath,maxpathsize,"<xsl:value-of select="$currentpath_format"/>/Shape_of"<xsl:value-of select="$path_args"/>);</xsl:when>
	  <xsl:otherwise>
	  snprintf(clepath,maxpathsize,"%s","<xsl:value-of select="$currentpath_format"/>/Shape_of");</xsl:otherwise>
	</xsl:choose>
	pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetField(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, "<xsl:value-of select="@name"/>");
	if (pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
	"Unable to retrieve field %s (in PUT_SLICE)", "<xsl:value-of select="@path"/>");
	n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetNumberOfElements(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
        if (n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> &gt; 0) {
	status = putInt(expIdx, path, clepath, n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
	checkStatus(status);
	if (status) return status;
	for (i<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = 0;i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>&lt; n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>; i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>++){
	p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
	if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_AoS_element",
      "Unable to retrieve element %d in %s (in PUT_SLICE)", i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, "<xsl:value-of select="@path"/>");
	<xsl:apply-templates select="field" mode="PUT_SLICE">
	  <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	  <xsl:with-param name="AosParent_name" select="concat('p',@name,'_',generate-id(.))"/>
	  <xsl:with-param name="path_format" select="concat($currentpath_format,'/%d')"/>
	  <xsl:with-param name="path_args" select="concat($path_args,',i',@name,'_',generate-id(.),'+1')"/>
	</xsl:apply-templates>
	}
        }
      </xsl:when>

      <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
	<!-- Type 3 arrays of structure, with a unique time base -->
	/* AoS of type 3 */
	pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetField(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, "<xsl:value-of select="@name"/>");
	if (pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
	"Unable to retrieve field %s (in PUT_SLICE)", "<xsl:value-of select="@path"/>");
	n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetNumberOfElements(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
        if (n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> &gt; 0) {
	<xsl:choose>
	  <xsl:when test="$path_args">
	  snprintf(clepath,maxpathsize,"path/<xsl:value-of select="$currentpath_format"/>"<xsl:value-of select="$path_args"/>);</xsl:when>
	  <xsl:otherwise>
	  snprintf(clepath,maxpathsize,"%s","path/<xsl:value-of select="$currentpath_format"/>");</xsl:otherwise>
	</xsl:choose>
	void *obj_single_time = beginObject(expIdx, (void *) -1, 0, clepath, TIMED);
	void *obj1 = beginObject(expIdx, obj_single_time, 0, "ALLTIMES", TIMED);
	int i1 = 0; // Used in PUT_IN_OBJECT
	p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) 0);
	if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_AoS_element",
	"Unable to retrieve element %d in %s (in PUT_SLICE)", 0, "<xsl:value-of select="@path"/>");
        <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
          <xsl:with-param name="level" select="1"/>
          <xsl:with-param name="objpath" select="@name"/>
	  <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	</xsl:apply-templates>
	void *obj = putObjectInObject(expIdx, obj_single_time, "ALLTIMES", i1, obj1);
	<xsl:value-of select="$currentpath_expr"/>
	status = putObjectSlice(expIdx, path, clepath, dtime[0], obj);
	checkStatus(status);
	if (status) return status;
        // Store time of the array of structure (hidden variable for the user, but used by the UAL for future get_slice operations)
        // A temporary "time" vector is filled then put as a regular variable (outside of the object) as AoS%time
        double timeh = -1;

	// Check the presence of a time vector at the root of the  AoS (on the first index only)
        if (homogeneous_time == 1) 
        {
        timeh = dtime[0];
        }
        else
	{   
	p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) 0);
	data = mxGetField(p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) 0, "time");
        if ( mxGetScalar(data) == EMPTY_DOUBLE) 
        {
        mexErrMsgIdAndTxt("IMAS:ids_put_slice:Aos_3_invalid_time","The time vector of the type 3 array of structure <xsl:value-of select = "translate(@path,'/','.')"/> must be filled");
        return (-1);
        }
        else 
        {
        // the AoS time vector is there, fill time with it
	p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) 0);
	data = mxGetField(p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) 0, "time");
        timeh = mxGetScalar(data);
        }
        }
        // Start to put time1
        status = putDoubleSlice(expIdx, path, timebasepath, timebasepath, timeh, timeh);
        checkStatus(status);
        if (status) return status;
        }
      </xsl:when>

      <!--========== Vectors ==========-->
      <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
	<xsl:value-of select="$currentpath_expr"/>
	str = mxArrayToString(data);
	status = putStringSlice(expIdx, path,  clepath, timebasepath, str, dtime[0]);
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
	<xsl:value-of select="$currentpath_expr"/>
	status = putIntSlice(expIdx, path, clepath, timebasepath, *(int *) mxGetData(data), dtime[0]);
	checkStatus(status);
	if (status)  return status;
      </xsl:when>

      <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
	<xsl:value-of select="$currentpath_expr"/>
	status = putDoubleSlice(expIdx, path, clepath, timebasepath, mxGetScalar(data), dtime[0]);
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== Matrices ==========-->
      <xsl:when test="@data_type='FLT_2D'">
	<xsl:value-of select="$currentpath_expr"/>
	dim1 = mxGetM(data);
	doubleArray = mxGetPr(data);
	status = putVect1DDoubleSlice(expIdx, path, clepath, timebasepath, doubleArray, dim1, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <xsl:when test="@data_type='INT_2D'">
	<xsl:value-of select="$currentpath_expr"/>
	dim1 = mxGetM(data);
	intArray = (int *) mxGetData(data);
	status = putVect1DIntSlice(expIdx, path, clepath, timebasepath, intArray, dim1, dtime[0]);
	intArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== 3D arrays ==========-->
      <xsl:when test="@data_type='FLT_3D'">
	<xsl:value-of select="$currentpath_expr"/>
	dim1 = mxGetM(data);
	dim2 = mxGetN(data);
	doubleArray = mxGetPr(data);
	status = putVect2DDoubleSlice(expIdx, path, clepath, timebasepath, doubleArray, dim1, dim2, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <xsl:when test="@data_type='INT_3D'">
	<xsl:value-of select="$currentpath_expr"/>
	dim1 = mxGetM(data);
	dim2 = mxGetN(data);
	intArray = (int *) mxGetData(data);
	status = putVect2DIntSlice(expIdx, path, clepath, timebasepath, intArray, dim1, dim2, dtime[0]);
	intArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== 4D arrays ==========-->
      <xsl:when test="@data_type='FLT_4D'">
	<xsl:value-of select="$currentpath_expr"/>
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = dims[2];
	doubleArray = mxGetPr(data);
	status = putVect3DDoubleSlice(expIdx, path, clepath,timebasepath, doubleArray, dim1, dim2, dim3, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <xsl:when test="@data_type='INT_4D'">
	<xsl:value-of select="$currentpath_expr"/>
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = dims[2];
	intArray = (int *) mxGetData(data);
	status = putVect3DIntSlice(expIdx, path, clepath, timebasepath, intArray, dim1, dim2, dim3, dtime[0]);
	intArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== 5D arrays ==========-->
      <xsl:when test="@data_type='FLT_5D'">
	<xsl:value-of select="$currentpath_expr"/>
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = dims[2];
	dim4 = dims[3];
	doubleArray = mxGetPr(data);
	status = putVect4DDoubleSlice(expIdx, path, clepath, timebasepath, doubleArray, dim1, dim2, dim3, dim4, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== 6D arrays ==========-->
      <xsl:when test="@data_type='FLT_6D'">
	<xsl:value-of select="$currentpath_expr"/>
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = dims[2];
	dim4 = dims[3];
	dim5 = dims[4];
	doubleArray = mxGetPr(data);
	status = putVect5DDoubleSlice(expIdx, path, clepath, timebasepath, doubleArray, dim1, dim2, dim3, dim4, dim5, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <xsl:otherwise>
	// PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
      </xsl:otherwise>

    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
