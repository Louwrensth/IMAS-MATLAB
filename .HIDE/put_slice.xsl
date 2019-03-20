<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
		xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

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
    <xsl:if test="
		  @data_type='str_1d_type' or @data_type='STR_1D' or
		  @data_type='flt_1d_type' or @data_type='FLT_1D' or
		  @data_type='int_1d_type' or @data_type='INT_1D' or
		  @data_type='FLT_2D' or @data_type='INT_2D' or
		  @data_type='FLT_3D' or @data_type='INT_3D' or
		  @data_type='FLT_4D' or @data_type='INT_4D' or
		  @data_type='FLT_5D' or @data_type='INT_5D' or
		  @data_type='FLT_6D' or @data_type='INT_6D'"> 
      ifield = mxGetFieldNumber(<xsl:value-of select="$pointer_name"/>, "<xsl:value-of select="@name"/>");
      if (ifield &lt; 0)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
      "Unable to retrieve field %s (in PUT_SLICE)", "<xsl:value-of select="@path"/>");
      data = mxGetFieldByNumber(<xsl:value-of select="$pointer_name"/>, (mwIndex) 0, ifield);
      if (data != NULL &amp;&amp; mxGetNumberOfElements(data) &gt; 0) {
    </xsl:if>

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
	ifield = mxGetFieldNumber(<xsl:value-of select="$pointer_name"/>, "<xsl:value-of select="@name"/>");
	if (ifield &lt; 0)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
	"Unable to retrieve field %s (in PUT_SLICE)", "<xsl:value-of select="@path"/>");
	pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetFieldByNumber(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, ifield);
	n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = (pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL) ? 0 : mxGetNumberOfElements(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
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
	ifield = mxGetFieldNumber(<xsl:value-of select="$pointer_name"/>, "<xsl:value-of select="@name"/>");
	if (ifield &lt; 0)
	mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
	"Unable to retrieve field %s (in PUT_SLICE)", "<xsl:value-of select="@path"/>");
	pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetFieldByNumber(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, ifield);
	n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = (pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL) ? 0 : mxGetNumberOfElements(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
        if (n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> &gt; 0) {
	<xsl:choose>
	  <xsl:when test="$path_args">
	  snprintf(clepath,maxpathsize,"%s/<xsl:value-of select="$currentpath_format"/>",path<xsl:value-of select="$path_args"/>);</xsl:when>
	  <xsl:otherwise>
	  snprintf(clepath,maxpathsize,"%s/%s",path,"<xsl:value-of select="$currentpath_format"/>");</xsl:otherwise>
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
          <xsl:with-param name="child_index" select="0"/>
	</xsl:apply-templates>
	obj_single_time = putObjectInObject(expIdx, obj_single_time, "ALLTIMES", i1, obj1);
	<xsl:value-of select="$currentpath_expr"/>
	status = putObjectSlice(expIdx, path, clepath, dtime[0], obj_single_time);
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
	<xsl:choose>
	  <xsl:when test="$path_args">
	  snprintf(timepath,maxpathsize,"<xsl:value-of select="$currentpath_format"/>/time"<xsl:value-of select="$path_args"/>);</xsl:when>
	  <xsl:otherwise>
	  snprintf(timepath,maxpathsize,"%s","<xsl:value-of select="$currentpath_format"/>/time");</xsl:otherwise>
	</xsl:choose>
        status = putDoubleSlice(expIdx, path, timepath, timepath, timeh, timeh);
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
	numDims = mxGetNumberOfDimensions(data);
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = numDims > 2 ? (int) dims[2] : 1;
	doubleArray = mxGetPr(data);
	status = putVect3DDoubleSlice(expIdx, path, clepath,timebasepath, doubleArray, dim1, dim2, dim3, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <xsl:when test="@data_type='INT_4D'">
	<xsl:value-of select="$currentpath_expr"/>
	numDims = mxGetNumberOfDimensions(data);
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = numDims > 2 ? dims[2] : 1;
	intArray = (int *) mxGetData(data);
	status = putVect3DIntSlice(expIdx, path, clepath, timebasepath, intArray, dim1, dim2, dim3, dtime[0]);
	intArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== 5D arrays ==========-->
      <xsl:when test="@data_type='FLT_5D'">
	<xsl:value-of select="$currentpath_expr"/>
	numDims = mxGetNumberOfDimensions(data);
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = numDims > 2 ? dims[2] : 1;
	dim4 = numDims > 3 ? dims[3] : 1;
	doubleArray = mxGetPr(data);
	status = putVect4DDoubleSlice(expIdx, path, clepath, timebasepath, doubleArray, dim1, dim2, dim3, dim4, dtime[0]);
	doubleArray = NULL;
	checkStatus(status);
	if (status) return status;
      </xsl:when>

      <!--========== 6D arrays ==========-->
      <xsl:when test="@data_type='FLT_6D'">
	<xsl:value-of select="$currentpath_expr"/>
	numDims = mxGetNumberOfDimensions(data);
	dims = mxGetDimensions(data);
	dim1 = dims[0];
	dim2 = dims[1];
	dim3 = numDims > 2 ? dims[2] : 1;
	dim4 = numDims > 3 ? dims[3] : 1;
	dim5 = numDims > 4 ? dims[4] : 1;
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
    <xsl:if test="
		  @data_type='str_1d_type' or @data_type='STR_1D' or
		  @data_type='flt_1d_type' or @data_type='FLT_1D' or
		  @data_type='int_1d_type' or @data_type='INT_1D' or
		  @data_type='FLT_2D' or @data_type='INT_2D' or
		  @data_type='FLT_3D' or @data_type='INT_3D' or
		  @data_type='FLT_4D' or @data_type='INT_4D' or
		  @data_type='FLT_5D' or @data_type='INT_5D' or
		  @data_type='FLT_6D' or @data_type='INT_6D'"> 
      }
    </xsl:if>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
