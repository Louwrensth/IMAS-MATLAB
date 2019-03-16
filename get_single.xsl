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
<!--            get all fields from IDS              -->
<!--=================================================-->

<xsl:template match="field" mode="GET_SINGLE">

<xsl:call-template name="COMMENT_FIELD"/>

// Doc Get <xsl:value-of select="@path_doc"/>
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
      aosCtx = ual_begin_arraystruct_action(ctx, fieldPath, timebasePath, &amp;arraySize);
      if (aosCtx &lt; 0) {
      ual_end_action(ctx);
      return aosCtx;
      }
      if (aosCtx &gt; 0 &amp;&amp; arraySize &gt; 0) {
      aosArray=mxCreateCellMatrix(arraySize,1);
      for (int i=0; i&lt;arraySize; i++) {
      aosElement=mxGetCell(aosArray,(mwIndex) i);
      if (aosElement==NULL)
      aosElement = mxCreateStructMatrix(1,1,0,NULL);
      status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime, &amp;aosElement);
      if (status &lt; 0) {	
      ual_end_action(ctx);
      return status;
      }
      mxSetCell(aosArray,(mwIndex) i,aosElement);
      aosElement = NULL;
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
      } else {
      aosArray=mxCreateCellMatrix(0,0);
      }
      ifield = mxAddField(*ids,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(*ids,0,ifield,aosArray);
      aosArray=NULL;
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      if (structure==NULL)
      structure = mxCreateStructMatrix(1,1,0,NULL);
      status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime, &amp;structure);
      if (status != 0)
      return status;
      ifield = mxAddField(*ids,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(*ids,0,ifield,structure);
      structure=NULL;
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      status = getInt(ctx, fieldPath, timebasePath, &amp;int0d);
      data = mxCreateNumericArray(2,dims_scalar,mxINT32_CLASS,mxREAL);
      if(!status) {
      *(int *)mxGetData(data) = int0d;
      } else {
      *(int *)mxGetData(data) = EMPTY_INT;
      }
    </xsl:when>
  
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      status = getDouble(ctx, fieldPath, timebasePath, &amp;double0d);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleScalar(double0d);
      } else {
      data = mxCreateDoubleScalar(EMPTY_DOUBLE);
      }
    </xsl:when>
  
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      status = getVect1DChar(ctx, fieldPath, timebasePath, &amp;str, &amp;dim1);
      checkStatus(status);
      if(!status) {
      dstr = strdup(str);
      free(str);
      data = mxCreateString(dstr);
      }
    </xsl:when>
	
  <!--========== Vectors ===========-->
    <xsl:when test = "@data_type='int_1d_type' or @data_type='INT_1D'">
      status = getVect1DInt(ctx, fieldPath, timebasePath, &amp;intArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericMatrix(dim1,1,mxINT32_CLASS,mxREAL);
      memcpy((int *)mxGetData(data),intArray,dim1*sizeof(int));
      free(intArray);
      }
    </xsl:when>
  
    <xsl:when test = "@data_type='flt_1d_type' or @data_type='FLT_1D'">
      status = getVect1DDouble(ctx, fieldPath, timebasePath, &amp;doubleArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,1,mxREAL);
      memcpy((double *)mxGetData(data),doubleArray,dim1*sizeof(double));
      free(doubleArray);
      }
    </xsl:when>
      
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      status = getVect2DChar(ctx, fieldPath, timebasePath, &amp;str, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      dims = malloc(2*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;
      data = mxCreateCharArray(2,dims);
      memcpy((char *)mxGetData(data),str,dim1*dim2*sizeof(char));
      free((char *)str);
      dims = NULL;
      }
    </xsl:when>

  <!--========== Matrices ===========-->
    <xsl:when test="@data_type='INT_2D'">
      status = getVect2DInt(ctx, fieldPath, timebasePath, &amp;intArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericMatrix(dim1,dim2,mxINT32_CLASS,mxREAL);
      memcpy((int *)mxGetData(data),intArray,dim1*dim2*sizeof(int));
      free(intArray);
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_2D'">
      status = getVect2DDouble(ctx, fieldPath, timebasePath, &amp;doubleArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
      memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*sizeof(double));
      free(doubleArray);
      }
    </xsl:when>

  <!--========== 3D arrays ===========-->
    <xsl:when test="@data_type='INT_3D'">
      status = getVect3DInt(ctx, fieldPath, timebasePath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
      checkStatus(status);
      if(!status) {
      dims = malloc(3*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
      data = mxCreateNumericArray(3,dims,mxINT32_CLASS,mxREAL);
      memcpy((int *)mxGetData(data),intArray,dim1*dim2*dim3*sizeof(int));
      free(intArray);
      dims = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_3D'">
      status = getVect3DDouble(ctx, fieldPath, timebasePath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
      checkStatus(status);
      if(!status) {
      dims = malloc(3*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
      data = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*sizeof(double));
      free(doubleArray);
      dims = NULL;
      }
    </xsl:when>

  <!--========== 4D arrays ===========-->
    <xsl:when test="@data_type='INT_4D'">
      status = getVect4DInt(ctx, fieldPath, timebasePath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
      checkStatus(status);
      if(!status) {
      dims = malloc(4*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;
      data = mxCreateNumericArray(4,dims,mxINT32_CLASS,mxREAL);
      memcpy((int *)mxGetData(data),intArray,dim1*dim2*dim3*dim4*sizeof(int));
      free(intArray);
      dims = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_4D'">
      status = getVect4DDouble(ctx, fieldPath, timebasePath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
      checkStatus(status);
      if(!status) {
      dims = malloc(4*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;
      data = mxCreateNumericArray(4,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*dim4*sizeof(double));
      free(doubleArray);
      dims = NULL;
      }
    </xsl:when>

  <!--========== 5D arrays ===========-->
    <xsl:when test="@data_type='INT_5D'">
      status = getVect5DInt(ctx, fieldPath, timebasePath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
      checkStatus(status);
      if(!status) {
      dims = malloc(5*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;
      data = mxCreateNumericArray(5,dims,mxINT32_CLASS,mxREAL);
      memcpy((int *)mxGetData(data),intArray,dim1*dim2*dim3*dim4*dim5*sizeof(int));
      free(intArray);
      dims = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_5D'">
      status = getVect5DDouble(ctx, fieldPath, timebasePath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
      checkStatus(status);
      if(!status) {
      dims = malloc(5*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;
      data = mxCreateNumericArray(5,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*dim4*dim5*sizeof(double));
      free(doubleArray);
      dims = NULL;
      }
    </xsl:when>

  <!--========== 6D arrays ===========-->
    <xsl:when test="@data_type='INT_6D'">
      status = getVect6DInt(ctx, fieldPath, timebasePath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
      checkStatus(status);
      if(!status) {
      dims = malloc(6*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;dims[5] = dim6;
      data = mxCreateNumericArray(6,dims,mxINT32_CLASS,mxREAL);
      memcpy((int *)mxGetData(data),intArray,dim1*dim2*dim3*dim4*dim5*dim6*sizeof(int));
      free(intArray);
      dims = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_6D'">
      status = getVect6DDouble(ctx, fieldPath, timebasePath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
      checkStatus(status);
      if(!status) {
      dims = malloc(6*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;dims[5] = dim6;
      data = mxCreateNumericArray(6,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*dim4*dim5*dim6*sizeof(double));
      free(doubleArray);
      dims = NULL;
      }
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>

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
  ifield = mxAddField(*ids,"<xsl:value-of select="@name"/>");
  mxSetFieldByNumber(*ids,0,ifield,data);
  data = NULL;
  if (status &lt; 0) {	
  ual_end_action(ctx);
  return status;
  }
</xsl:if>
</xsl:template>

</xsl:stylesheet>
