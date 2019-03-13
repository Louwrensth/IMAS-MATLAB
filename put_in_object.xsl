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
<!--            put fields into an object            -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_IN_OBJECT">
  <xsl:param name="level"/> <!-- recursion level -->
  <xsl:param name="objpath"/> <!-- path inside the object -->
  <xsl:param name="pointer_name"/>

  <!-- build the index to use to add a child in the current object -->
  <xsl:param name="child_index" select="concat('i',$level)"/>
  <!-- build the path of the current field inside the object -->
  <xsl:param name="currentobjpath" select="concat($objpath,'/',@name)"/>
  <xsl:if test="
		@data_type='str_type' or @data_type='STR_0D' or
		@data_type='int_type' or @data_type='INT_0D' or
		@data_type='flt_type' or @data_type='FLT_0D' or
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
    "Unable to retrieve field %s (in PUT_IN_OBJECT)", "<xsl:value-of select="@path"/>");
    data = mxGetFieldByNumber(<xsl:value-of select="$pointer_name"/>, (mwIndex) 0, ifield);
  </xsl:if>

  <xsl:if test="
		@data_type='str_1d_type' or @data_type='STR_1D' or
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
    <!--========== Array of structures ==========-->
    <xsl:when test="@data_type='struct_array'">
      // Put <xsl:value-of select="@path"/>
      <!-- Present implementation assumes that nested AoS are necessarily of level 2, this may need to be upgraded for other cases later (?) -->
      ifield = mxGetFieldNumber(<xsl:value-of select="$pointer_name"/>, "<xsl:value-of select="@name"/>");
      if (ifield &lt; 0)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
           "Unable to retrieve AoS %s (in PUT_IN_OBJECT)", "<xsl:value-of select="@path"/>");
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetFieldByNumber(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, ifield);
      n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = (pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL) ? 0 : mxGetNumberOfElements(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      if (n<xsl:value-of select="concat(@name,'_',generate-id(.))"/> &gt; 0) {
      void *obj<xsl:value-of select="$level + 1"/> = beginObject(expIdx,obj<xsl:value-of select="$level"/>,0,"<xsl:value-of select="$currentobjpath"/>",NON_TIMED);
      // Start to declare a nested Type 2 Aos
      for (int i<xsl:value-of select="$level + 1"/> = 0; i<xsl:value-of select="$level + 1"/> &lt; n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>; i<xsl:value-of select="$level + 1"/>++) {
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>, (mwIndex) i<xsl:value-of select="$level + 1"/>);
      if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
           "Unable to retrieve element %d of AoS %s (in PUT_IN_OBJECT)", i<xsl:value-of select="$level + 1"/>, "<xsl:value-of select="@path"/>");
      <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
	<xsl:with-param name="level" select="$level + 1"/>
	<xsl:with-param name="objpath" select="@name"/>
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
      </xsl:apply-templates>
      }
      obj<xsl:value-of select="$level"/> = putObjectInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, obj<xsl:value-of select="$level + 1"/>);
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <!--========== Regular structure ==========-->
    <xsl:when test="@data_type='structure'">
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxGetField(<xsl:value-of select="$pointer_name"/>,(mwIndex) 0, "<xsl:value-of select="@name"/>");
      if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> == NULL)
      mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
           "Unable to retrieve field %s (in PUT_IN_OBJECT)", "<xsl:value-of select="@path"/>");
      <xsl:apply-templates select="field" mode="PUT_IN_OBJECT">
	<xsl:with-param name="level" select="$level"/>
	<xsl:with-param name="objpath" select="$currentobjpath"/>
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
      </xsl:apply-templates>
    </xsl:when>

    <!--========== Simple types ==========-->
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      obj<xsl:value-of select="$level"/> = putStringInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, (char *)mxArrayToString(data));
      checkObject(obj<xsl:value-of select="$level"/>);
    </xsl:when>

    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      obj<xsl:value-of select="$level"/> = putIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, (int) mxGetScalar(data));
      checkObject(obj<xsl:value-of select="$level"/>);
    </xsl:when>

    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      obj<xsl:value-of select="$level"/> = putDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, mxGetScalar(data));
      checkObject(obj<xsl:value-of select="$level"/>);
    </xsl:when>

    <!--========== Vectors ==========-->
    <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
      dim1In = mxGetNumberOfElements(data);
      if ( dim1In > 0) {
      doubleArray = mxGetPr(data);
      obj<xsl:value-of select="$level"/> = putVect1DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In);
      doubleArray = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      dim1In = mxGetM(data);
      if ( dim1In > 0) {
      dim2In = mxGetN(data);
      str = mxArrayToString(data); // char * only ...
      stringArray = malloc(dim1In*sizeof(char *));
      for (_i = 0; _i &lt; dim1In; _i++) {
      stringArray[_i] = malloc((dim2In+1)*sizeof(char));
      for (_j = 0; _j &lt; dim2In; _j++)
      stringArray[_i][_j] = str[_i+dim1In*_j];
      stringArray[_i][dim2In+1] = '\000';
      }
      obj<xsl:value-of select="$level"/> = putVect1DStringInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, stringArray, dim1In);
      free(stringArray);
      stringArray = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
      dim1In = mxGetNumberOfElements(data);
      if ( dim1In > 0) {
      intArray = (int *)mxGetData(data);
      obj<xsl:value-of select="$level"/> = putVect1DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In);
      intArray = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <!--========== Matrices ==========-->
    <xsl:when test="@data_type='FLT_2D'">
      dim1In = mxGetM(data);
      if ( dim1In > 0) {
      dim2In = mxGetN(data);
      doubleArray = mxGetPr(data);
      obj<xsl:value-of select="$level"/> = putVect2DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In);
      doubleArray = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <xsl:when test="@data_type='INT_2D'">
      dim1In = mxGetM(data);
      if ( dim1In > 0) {
      dim2In = mxGetN(data);
      intArray = (int *) mxGetData(data);
      obj<xsl:value-of select="$level"/> = putVect2DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In, dim2In);
      intArray = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <!--========== 3D arrays ==========-->
    <xsl:when test="@data_type='FLT_3D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1In = (int) dims[0];
      if ( dim1In > 0) {
      dim2In = (int) dims[1];
      dim3In = numDims > 2 ? (int) dims[2] : 1;
      doubleArray = mxGetPr(data);
      obj<xsl:value-of select="$level"/> = putVect3DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In);
      doubleArray = NULL;
      dims = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <xsl:when test="@data_type='INT_3D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1In = (int) dims[0];
      if ( dim1In > 0) {
      dim2In = (int) dims[1];
      dim3In = numDims > 2 ? (int) dims[2] : 1;
      intArray = (int *)mxGetData(data);
      obj<xsl:value-of select="$level"/> = putVect3DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In, dim2In, dim3In);
      intArray = NULL;
      dims = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <!--========== 4D arrays ==========-->
    <xsl:when test="@data_type='FLT_4D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1In = (int) dims[0];
      if ( dim1In > 0) {
      dim2In = (int) dims[1];
      dim3In = numDims > 2 ? (int) dims[2] : 1;
      dim4In = numDims > 3 ? (int) dims[3] : 1;
      doubleArray = mxGetPr(data);
      obj<xsl:value-of select="$level"/> = putVect4DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In);
      doubleArray = NULL;
      dims = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <!--========== 5D arrays ==========-->
    <xsl:when test="@data_type='FLT_5D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1In = (int) dims[0];
      if ( dim1In > 0) {
      dim2In = (int) dims[1];
      dim3In = numDims > 2 ? (int) dims[2] : 1;
      dim4In = numDims > 3 ? (int) dims[3] : 1;
      dim5In = numDims > 4 ? (int) dims[4] : 1;
      doubleArray = mxGetPr(data);
      obj<xsl:value-of select="$level"/> = putVect5DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In);
      doubleArray = NULL;
      dims = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
    </xsl:when>

    <!--========== 6D arrays ==========-->
    <xsl:when test="@data_type='FLT_6D'">
      numDims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);
      dim1In = (int) dims[0];
      if ( dim1In > 0) {
      dim2In = (int) dims[1];
      dim3In = numDims > 2 ? (int) dims[2] : 1;
      dim4In = numDims > 3 ? (int) dims[3] : 1;
      dim5In = numDims > 4 ? (int) dims[4] : 1;
      dim6In = numDims > 5 ? (int) dims[5] : 1;
      doubleArray = mxGetPr(data);
      obj<xsl:value-of select="$level"/> = putVect6DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
      doubleArray = NULL;
      dims = NULL;
      checkObject(obj<xsl:value-of select="$level"/>);
      }
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
</xsl:template>

</xsl:stylesheet>
