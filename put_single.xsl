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
<!--       put field of a time-dependent IDS         -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_SINGLE">
<xsl:param name="dynamic_only"/>

<xsl:call-template name="COMMENT_FIELD"/>

<xsl:variable name="methodName">
  <xsl:choose>
    <xsl:when test="$dynamic_only !='yes'" >
      <xsl:value-of select="'put'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'put_slice'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

// Doc <xsl:value-of select="concat($methodName,' ',@path_doc)"/>
<xsl:if test="$dynamic_only !='yes' or descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
<xsl:if test="@data_type='str_type'    or @data_type='STR_0D' or
	      @data_type='str_1d_type' or @data_type='STR_1D' or
	      @data_type='int_type'    or @data_type='INT_0D' or
	      @data_type='flt_type'    or @data_type='FLT_0D' or
	      @data_type='flt_1d_type' or @data_type='FLT_1D' or
	      @data_type='int_1d_type' or @data_type='INT_1D' or
	      @data_type='FLT_2D'      or @data_type='INT_2D' or
	      @data_type='FLT_3D'      or @data_type='INT_3D' or
	      @data_type='FLT_4D'      or @data_type='INT_4D' or
	      @data_type='FLT_5D'      or @data_type='INT_5D' or
	      @data_type='FLT_6D'      or @data_type='INT_6D'">
  fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
  <xsl:choose>
    <xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
      if (homogeneousTime == 1) 
      timebasePath="/time";
      else
      timebasePath=&quot;<xsl:value-of select="@timebasepath"/>&quot;;
    </xsl:when>
    <xsl:otherwise>
      timebasePath = "";
    </xsl:otherwise>
  </xsl:choose>
  ifield = mxGetFieldNumber(ids, "<xsl:value-of select="@name"/>");
  if (ifield &lt; 0)
  mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$methodName"/>:invalid_field",
  "Unable to retrieve field %s (in PUT_SINGLE)", "<xsl:value-of select="@path"/>");
  data = mxGetFieldByNumber(ids, (mwIndex) 0, ifield);
</xsl:if>
<xsl:if test="@data_type='str_1d_type' or @data_type='STR_1D' or
	      @data_type='flt_1d_type' or @data_type='FLT_1D' or
	      @data_type='int_1d_type' or @data_type='INT_1D' or
	      @data_type='FLT_2D' or @data_type='INT_2D' or
	      @data_type='FLT_3D' or @data_type='INT_3D' or
	      @data_type='FLT_4D' or @data_type='INT_4D' or
	      @data_type='FLT_5D' or @data_type='INT_5D' or
	      @data_type='FLT_6D' or @data_type='INT_6D'"> 
  if (data != NULL &amp;&amp; mxGetNumberOfElements(data) &gt; 0) {
</xsl:if>
<xsl:choose>
  <!--========== Array of structure ===========-->
  <!-- Type 1 arrays of structure, with potentially multiple time bases -->
  <!-- Type 2 arrays of structure -->
  <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:when test = "@data_type = 'struct_array'">
      fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
      <xsl:if test="ancestor::field[@data_type='struct_array']">
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
      </xsl:if>
      <xsl:choose>	
	<xsl:when test="@type='dynamic'"> <!-- Type 3 -->
	  if (homogeneousTime) 
          timebasePath = "/time";
       	  else
	  timebasePath = &quot;<xsl:call-template  name="printAosRelativePath"/>/time&quot;;
	</xsl:when>
  	<xsl:otherwise> <!-- Type 1 or 2 -->
	  timebasePath = "";
	</xsl:otherwise>
      </xsl:choose>
      ifield = mxGetFieldNumber(ids, "<xsl:value-of select="@name"/>");
      if (ifield &lt; 0)
      mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$methodName"/>:invalid_field",
      "Unable to retrieve field %s (in PUT_SINGLE)", "<xsl:value-of select="@path"/>");
      aosArray = mxGetFieldByNumber(ids, (mwIndex) 0, ifield);
      arraySize = (aosArray == NULL) ? 0 : mxGetNumberOfElements(aosArray);
      if (arraySize &gt; 0) {
      aosCtx = ual_begin_arraystruct_action(ctx, fieldPath, timebasePath, &amp;arraySize);
      if (aosCtx &lt; 0) {
      ual_end_action(ctx);
      return aosCtx;
      }
      for (int i=0; i&lt;arraySize; i++) {
      aosElement=mxGetCell(aosArray,(mwIndex) i);
      if (aosElement==NULL)
      mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$methodName"/>:invalid_AoS_element",
      "Unable to retrieve element %d in %s (in PUT_SINGLE)", i, "<xsl:value-of select="@path"/>");
      status = <xsl:value-of select="concat($methodName,'_',@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime, aosElement);
      if (status &lt; 0) {	
      ual_end_action(ctx);
      return status;
      }
      status = ual_iterate_over_arraystruct(aosCtx, 1);
      if (status &lt; 0) {	
      ual_end_action(aosCtx);
      ual_end_action(ctx);
      return status;
      }
      }
      status = ual_end_action(aosCtx);
      if (status &lt; 0) {
      ual_end_action(ctx);
      return status; 
      }
      }
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      structure = mxGetField(ids, (mwIndex) 0, "<xsl:value-of select="@name"/>");
      if (structure==NULL)
      mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$methodName"/>:invalid_field",
      "Unable to retrieve field %s (in PUT_SINGLE)", "<xsl:value-of select="@path"/>");
      status = <xsl:value-of select="concat($methodName,'_',@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime, structure);
      if (status != 0)
      return status;
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      status = putInt(ctx, fieldPath, timebasePath, *(int *) mxGetData(data));
    </xsl:when>
  
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      status = putDouble(ctx, fieldPath, timebasePath, mxGetScalar(data));
    </xsl:when>
  
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      str = mxArrayToString(data);
      status = putVect1DChar(ctx, fieldPath,  timebasePath, str, strlen(str));
    </xsl:when>
	
  <!--========== Vectors ===========-->
    <xsl:when test = "@data_type='int_1d_type' or @data_type='INT_1D'">
      dim1 = mxGetM(data);
      intArray = (int *) mxGetData(data);
      status = putVect1DInt(ctx, fieldPath, timebasePath, intArray, dim1);
      intArray = NULL;
    </xsl:when>
  
    <xsl:when test = "@data_type='flt_1d_type' or @data_type='FLT_1D'">
      dim1 = mxGetM(data);
      doubleArray = mxGetPr(data);
      status = putVect1DDouble(ctx, fieldPath, timebasePath, doubleArray, dim1);
      doubleArray = NULL;
    </xsl:when>
      
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      dim1 = mxGetM(data);
      dim2 = mxGetN(data);
      str = mxArrayToString(data); // char * only ...
      status = putVect2DChar(ctx, fieldPath, timebasePath, str, dim1, dim2);
      mxFree(str);
    </xsl:when>

  <!--========== Matrices ===========-->
    <xsl:when test="@data_type='INT_2D'">
      dim1 = mxGetM(data);
      dim2 = mxGetN(data);
      intArray = (int *) mxGetData(data);
      status = putVect2DInt(ctx, fieldPath, timebasePath, intArray, dim1, dim2);
      intArray = NULL;
    </xsl:when>

    <xsl:when test="@data_type='FLT_2D'">
      dim1 = mxGetM(data);
      dim2 = mxGetN(data);
      doubleArray = mxGetPr(data);
      status = putVect2DDouble(ctx, fieldPath, timebasePath, doubleArray, dim1, dim2);
      doubleArray = NULL;
    </xsl:when>

    <!--========== 3D arrays ===========-->
    <xsl:when test="@data_type='INT_3D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      intArray = (int *) mxGetData(data);
      status = putVect3DInt(ctx, fieldPath, timebasePath, intArray, dim1, dim2, dim3);
      intArray = NULL;
    </xsl:when>

    <xsl:when test="@data_type='FLT_3D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      doubleArray = mxGetPr(data);
      status = putVect3DDouble(ctx, fieldPath, timebasePath, doubleArray, dim1, dim2, dim3);
      doubleArray = NULL;
    </xsl:when>

    <!--========== 4D arrays ===========-->
    <xsl:when test="@data_type='INT_4D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      dim4 = numDims > 3 ? dims[3] : 1;
      intArray = (int *) mxGetData(data);
      status = putVect4DInt(ctx, fieldPath, timebasePath, intArray, dim1, dim2, dim3, dim4);
      intArray = NULL;
    </xsl:when>

    <xsl:when test="@data_type='FLT_4D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      dim4 = numDims > 3 ? dims[3] : 1;
      doubleArray = mxGetPr(data);
      status = putVect4DDouble(ctx, fieldPath, timebasePath, doubleArray, dim1, dim2, dim3, dim4);
      doubleArray = NULL;
    </xsl:when>

    <!--========== 5D arrays ===========-->
    <xsl:when test="@data_type='INT_5D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      dim4 = numDims > 3 ? dims[3] : 1;
      dim5 = numDims > 4 ? dims[4] : 1;
      intArray = (int *) mxGetData(data);
      status = putVect5DInt(ctx, fieldPath, timebasePath, intArray, dim1, dim2, dim3, dim4, dim5);
      intArray = NULL;
    </xsl:when>

    <xsl:when test="@data_type='FLT_5D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      dim4 = numDims > 3 ? dims[3] : 1;
      dim5 = numDims > 4 ? dims[4] : 1;
      doubleArray = mxGetPr(data);
      status = putVect5DDouble(ctx, fieldPath, timebasePath, doubleArray, dim1, dim2, dim3, dim4, dim5);
      doubleArray = NULL;
    </xsl:when>

    <!--========== 6D arrays ===========-->
    <xsl:when test="@data_type='INT_6D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      dim4 = numDims > 3 ? dims[3] : 1;
      dim5 = numDims > 4 ? dims[4] : 1;
      dim6 = numDims > 5 ? dims[5] : 1;
      intArray = (int *) mxGetData(data);
      status = putVect6DInt(ctx, fieldPath, timebasePath, intArray, dim1, dim2, dim3, dim4, dim5, dim6);
      intArray = NULL;
    </xsl:when>

    <xsl:when test="@data_type='FLT_6D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1 = dims[0];
      dim2 = dims[1];
      dim3 = numDims > 2 ? dims[2] : 1;
      dim4 = numDims > 3 ? dims[3] : 1;
      dim5 = numDims > 4 ? dims[4] : 1;
      dim6 = numDims > 5 ? dims[5] : 1;
      doubleArray = mxGetPr(data);
      status = putVect6DDouble(ctx, fieldPath, timebasePath, doubleArray, dim1, dim2, dim3, dim4, dim5, dim6);
      doubleArray = NULL;
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>

<xsl:if test="@data_type='str_1d_type' or @data_type='STR_1D' or
	      @data_type='flt_1d_type' or @data_type='FLT_1D' or
	      @data_type='int_1d_type' or @data_type='INT_1D' or
	      @data_type='FLT_2D'      or @data_type='INT_2D' or
	      @data_type='FLT_3D'      or @data_type='INT_3D' or
	      @data_type='FLT_4D'      or @data_type='INT_4D' or
	      @data_type='FLT_5D'      or @data_type='INT_5D' or
	      @data_type='FLT_6D'      or @data_type='INT_6D'">
  }
</xsl:if>
<xsl:if test="@data_type='str_type'    or @data_type='STR_0D'
	   or @data_type='str_1d_type' or @data_type='STR_1D'
	   or @data_type='int_type'    or @data_type='INT_0D'
	   or @data_type='flt_type'    or @data_type='FLT_0D'
	   or @data_type='flt_1d_type' or @data_type='FLT_1D'
	   or @data_type='int_1d_type' or @data_type='INT_1D'
	   or @data_type='FLT_2D'      or @data_type='INT_2D'
	   or @data_type='FLT_3D'      or @data_type='INT_3D'
	   or @data_type='FLT_4D'      or @data_type='INT_4D'
	   or @data_type='FLT_5D'      or @data_type='INT_5D'
	   or @data_type='FLT_6D'      or @data_type='INT_6D'">
  if (status &lt; 0) {	
  ual_end_action(ctx);
  return status;
  }
</xsl:if>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
