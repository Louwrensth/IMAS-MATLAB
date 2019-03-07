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
<!--            get fields from an object            -->
<!--=================================================-->
<xsl:template match = "field" mode = "GET_FROM_OBJECT">
<xsl:param name="level"/>
<xsl:param name="objpath"/>
<xsl:param name="pointer_name"/>
<xsl:param name="timed"/>

<xsl:param name="currentobjpath" select="concat($objpath,'/',@name)"/>
// Doc Get_from_object <xsl:value-of select="@path_doc"/>
<xsl:choose>
  <!--========== Arrays of structures ==========-->
    <xsl:when test="@data_type='struct_array'">
      <xsl:choose>
	<xsl:when test="$timed='yes' ">
	  <!-- We are scanning the children of a Type 3 AoS, so we extract the child object at index 0 of the parent object -->
	  {	  /*    1Array of structure     */
	  void *obj<xsl:value-of select="$level + 1"/>;
	  status = getObjectFromObject(expIdx, obj<xsl:value-of select="$level"/>, "<xsl:value-of select = "$currentobjpath"/>", 0,&amp;obj<xsl:value-of select="$level + 1"/>);
	</xsl:when>
	<xsl:otherwise>
	  <!-- Otherwise we assume it is a Type 2 AoS, so we extract the child object at index iobject -->
	  {	  /*    2Array of structure     */
	  void *obj<xsl:value-of select="$level + 1"/>;
	  status = getObjectFromObject(expIdx, obj<xsl:value-of select="$level"/>, "<xsl:value-of select = "$currentobjpath"/>", i<xsl:value-of select="$level"/>, &amp;obj<xsl:value-of select="$level + 1"/>);
	</xsl:otherwise>
      </xsl:choose>
      checkStatus(status);
      if (!status) {
      if (pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> != NULL &amp;&amp; mxIsCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>)) { // does this array already exist? (timed and non timed parts can share the same array)
      if (getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>) != 0 &amp;&amp; mxGetNumberOfElements(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>) != getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>)) { // then it must have the right number of elements
      mexErrMsgIdAndTxt("IMAS:ids_get:invalid_size",
           "Array of structures has different number of timed and nontimed elements for <xsl:value-of select = "@path"/>\n");
      return -1;
      }
      } else { // else allocate it
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxCreateCellMatrix(getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>),1);
      }
      for (int i<xsl:value-of select="$level + 1"/> = 0; i<xsl:value-of select="$level + 1"/> &lt; getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>); i<xsl:value-of select="$level + 1"/>++) {
	  p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,i<xsl:value-of select="$level + 1"/>);
	  if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>==NULL)
	  p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxCreateStructMatrix(1,1,0,NULL);
	  <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
	    <xsl:with-param name="level" select="$level + 1"/>
	    <xsl:with-param name="objpath" select="@name"/>
	    <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	    <xsl:with-param name="timed" select="'no'"/>  <!-- We assume the nested children are necessarily Type 2 -->
	  </xsl:apply-templates>
	  mxSetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,(mwIndex) i<xsl:value-of select="$level + 1"/>,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
	  p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = NULL;
      }
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;
      /* Should we release obj<xsl:value-of select="$level + 1"/>? */
      }
    </xsl:when>
    
  <!--========== Regular structure ==========-->
    <xsl:when test="@data_type='structure'">
      if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>==NULL)
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxCreateStructMatrix(1,1,0,NULL);
      <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
	<xsl:with-param name="level" select="$level"/>
	<xsl:with-param name="objpath" select="$currentobjpath"/>
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	<xsl:with-param name="timed" select="$timed"/>
      </xsl:apply-templates>
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      status = getStringFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;str);
      checkStatus(status);
      if(!status) {
      char* dstr = strdup(str);
      free(str);
      data = mxCreateString(dstr);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      status = getIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;int0d);
      checkStatus(status);
      data = mxCreateNumericArray(2,dims_scalar,mxINT32_CLASS,mxREAL);
      if(!status) {
      *(int *)mxGetData(data) = int0d;
      } else {
      *(int *)mxGetData(data) = EMPTY_INT;
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      status = getDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;double0d);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleScalar(double0d);
      } else {
      data = mxCreateDoubleScalar(EMPTY_DOUBLE);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      status = getVect1DStringFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;stringArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      dstringArray = malloc(dim1*sizeof(char*));
      for (_i = 0; _i &lt; dim1; _i++) {
      dstringArray[_i] = strdup(stringArray[_i]);
      free(stringArray[_i]);
      }
      free((char *)stringArray);
      data = mxCreateCharMatrixFromStrings(dim1,dstringArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
      status = getVect1DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,1,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*sizeof(double));
      free(doubleArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
      status = getVect1DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericMatrix(dim1,1,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*sizeof(int));
      free(intArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='FLT_2D'">
      status = getVect2DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*sizeof(double));
      free(doubleArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='INT_2D'">
      status = getVect2DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*sizeof(int));
      free(intArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='FLT_3D'">
      status = getVect3DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
      checkStatus(status);
      if(!status) {
      dims = malloc(3*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
      data = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*sizeof(double));
      free(doubleArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='INT_3D'">
      status = getVect3DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
      checkStatus(status);
      if(!status) {
      dims = malloc(3*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
      data = mxCreateNumericArray(3,dims,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*dim3*sizeof(int));
      free(intArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='FLT_4D'">
      status = getVect4DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
      checkStatus(status);
      if(!status) {
      dims = malloc(4*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;
      data = mxCreateNumericArray(4,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*dim4*sizeof(double));
      free(doubleArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='FLT_5D'">
      status = getVect5DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
      checkStatus(status);
      if(!status) {
      dims = malloc(5*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;
      data = mxCreateNumericArray(5,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*dim4*dim5*sizeof(double));
      free(doubleArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
    </xsl:when>
    
    <xsl:when test="@data_type='FLT_6D'">
      status = getVect6DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
      checkStatus(status);
      if(!status) {
      dims = malloc(6*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;dims[5] = dim6;
      data = mxCreateNumericArray(6,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*dim4*dim5*dim6*sizeof(double));
      free(doubleArray);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
    </xsl:when>
	
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
