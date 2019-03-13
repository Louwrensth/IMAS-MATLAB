<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
		xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--!!!!!!!!!!!!!!!!!!!!!!!!!        GET_SLICE for FIELDS       !!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- GET_SLICE -->
<xsl:template match="field" mode="GET_SLICE">
  <xsl:param name="pointer_name"/>
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

  // Doc Get_slice <xsl:value-of select="@path_doc"/>
  <xsl:choose>

    <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>==NULL)
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxCreateStructMatrix(1,1,0,NULL);
      <xsl:apply-templates select="field" mode="GET_SLICE">
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	<xsl:with-param name="path_format" select="$currentpath_format"/>
	<xsl:with-param name="path_args" select="$path_args"/>
      </xsl:apply-templates>
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = NULL;
    </xsl:when>

    <!--========== Array of structure ===========-->
    <!-- Type 1 arrays of structure, with potentially multiple time bases -->
    <xsl:when test = "@data_type = 'struct_array' and @maxoccur!='unbounded' ">
      {      /* Type 1 AoS */
      <xsl:choose>
	<xsl:when test="$path_args">
	snprintf(clepath,maxpathsize,"<xsl:value-of select="$currentpath_format"/>/Shape_of"<xsl:value-of select="$path_args"/>);</xsl:when>
	<xsl:otherwise>
	snprintf(clepath,maxpathsize,"%s","<xsl:value-of select="$currentpath_format"/>/Shape_of");</xsl:otherwise>
      </xsl:choose>
      status = getInt(expIdx,path, clepath, &amp;int0d);
      if (status == 0) {
      n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=int0d;
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxCreateCellMatrix(n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,1);
      for (i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=0; i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>&lt;n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>; i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>++) {
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,(mwIndex) i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>==NULL)
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxCreateStructMatrix(1,1,0,NULL);
      <xsl:apply-templates select="field" mode="GET_SLICE">
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	<xsl:with-param name="path_format" select="concat($currentpath_format,'/%d')"/>
	<xsl:with-param name="path_args" select="concat($path_args,',i',@name,'_',generate-id(.),'+1')"/>
      </xsl:apply-templates>
      mxSetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,(mwIndex) i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = NULL;
      }
      }
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = NULL;
    </xsl:when>

    <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
      {      /* Type 3 AoS (maybe nested below a Type 1) */
      <xsl:value-of select="$currentpath_expr"/>
      void *obj1;
      status = getObjectSlice(expIdx, path, clepath, inTime, &amp;obj_single_time);
      checkStatus(status);
      if(!status) {
      status = getObjectFromObject(expIdx,obj_single_time,"ALLTIMES",0,&amp;obj1);
      checkStatus(status);
      if (!status) {
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxCreateCellMatrix(1,1);
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,(mwIndex) 0);
      <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
        <xsl:with-param name="level" select="1"/>
        <xsl:with-param name="objpath" select="@name"/>
        <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
        <xsl:with-param name="timed" select="'yes'"/>
      </xsl:apply-templates>
      mxSetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,(mwIndex) 0,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = NULL;
      releaseObject(expIdx,obj_single_time);
      }
      }
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = NULL;
    </xsl:when>

    <!-- Dynamic objects == TIME-DEPENDENT -->
    <xsl:when test="@type='dynamic'">
      if (*(int *)mxGetData(mxGetField(mxGetField(*ids, 0, "ids_properties"), 0, "homogeneous_time")) == 0) {
      <xsl:choose>
	<xsl:when test="$path_format">
	  <xsl:choose>
	    <xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data']) or @name='data_error_upper' or @name='data_error_lower'">
	      <xsl:choose>
		<xsl:when test="$path_args">
		snprintf(timebasepath,maxpathsize,"<xsl:value-of select="$path_format"/>/time"<xsl:value-of select="$path_args"/>);</xsl:when>
		<xsl:otherwise>
		snprintf(timebasepath,maxpathsize,"%s","<xsl:value-of select="$path_format"/>/time");</xsl:otherwise>
	      </xsl:choose>
	    </xsl:when>
	    <xsl:otherwise>
	      snprintf(timebasepath,maxpathsize,"%s","<xsl:call-template name="printtimepath"/>");
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  snprintf(timebasepath,maxpathsize,"%s","<xsl:call-template name="printtimepath"/>");
	</xsl:otherwise>
      </xsl:choose>
      }  else  {
      snprintf(timebasepath,maxpathsize,"%s","time");
      }

      <xsl:choose>
	<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getStringSlice(expIdx, path, clepath, timebasepath, &amp;str, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  dstr = strdup(str);
	  free(str);
	  data = mxCreateCharMatrixFromStrings(1,&amp;dstr);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getDoubleSlice(expIdx, path, clepath, timebasepath, &amp;double0d , inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  data = mxCreateDoubleScalar(double0d);
	  }
          } else {
	  data = mxCreateDoubleScalar(EMPTY_DOUBLE);
	  }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>

	<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  data = mxCreateNumericArray(2,dims_scalar,mxINT32_CLASS,mxREAL);
	  if (dim1 &gt; 0) {
	  status = getIntSlice(expIdx, path, clepath, timebasepath, &amp;int0d , inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  *(int *)mxGetData(data) = int0d;
	  }
	  } else {
	  *(int *)mxGetData(data) = EMPTY_INT;
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>

	<xsl:when test="@data_type='FLT_2D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect1DDoubleSlice(expIdx, path, clepath, timebasepath, &amp;doubleArray, &amp;dim1, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  data = mxCreateDoubleMatrix(dim1,1,mxREAL);
	  memcpy((double *)mxGetData(data),doubleArray,dim1*sizeof(double));
	  free(doubleArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='INT_2D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect1DIntSlice(expIdx, path, clepath, timebasepath, &amp;intArray, &amp;dim1, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  data = mxCreateNumericMatrix(dim1,1,mxINT32_CLASS,mxREAL);
	  memcpy((int *)mxGetData(data),intArray,dim1*sizeof(int));
	  free(intArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='FLT_3D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect2DDoubleSlice(expIdx, path, clepath, timebasepath, &amp;doubleArray, &amp;dim1, &amp;dim2, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
	  memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*sizeof(double));
	  free(doubleArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='INT_3D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect2DIntSlice(expIdx, path, clepath, timebasepath, &amp;intArray, &amp;dim1, &amp;dim2, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  data = mxCreateNumericMatrix(dim1,dim2,mxINT32_CLASS,mxREAL);
	  memcpy((int *)mxGetData(data),intArray,dim1*dim2*sizeof(int));
	  free(intArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='FLT_4D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect3DDoubleSlice(expIdx, path, clepath, timebasepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  dims = malloc(3*sizeof(mwSize));
	  dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
	  data = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
	  memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*sizeof(double));
	  free(doubleArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='FLT_5D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect4DDoubleSlice(expIdx, path, clepath, timebasepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  dims = malloc(4*sizeof(mwSize));
	  dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;
	  data = mxCreateNumericArray(4,dims,mxDOUBLE_CLASS,mxREAL);
	  memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*dim4*sizeof(double));
	  free(doubleArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>
	
	<xsl:when test="@data_type='FLT_6D'">
	  <xsl:value-of select="$currentpath_expr"/>
	  getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
	  if (dim1 &gt; 0) {
	  status = getVect5DDoubleSlice(expIdx, path, clepath, timebasepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, inTime, &amp;retTime, interpolMode);
	  checkStatus(status);
	  if(!status) {
	  dims = malloc(5*sizeof(mwSize));
	  dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;
	  data = mxCreateNumericArray(5,dims,mxDOUBLE_CLASS,mxREAL);
	  memcpy((double *)mxGetData(data),doubleArray,dim1*dim2*dim3*dim4*dim5*sizeof(double));
	  free(doubleArray);
	  }
          }
          ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
	  mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
	  data = NULL;
	</xsl:when>

	<xsl:otherwise>
	  // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <!-- Static objects == TIME-INDEPENDENT -->
    <xsl:otherwise>
      <!-- Get the data from a time-independent field is the same procedure as GET_SINGLE -->
      <xsl:apply-templates select="." mode="GET_SINGLE">
	<xsl:with-param name="pointer_name" select="$pointer_name"/>
	<xsl:with-param name="path_format" select="$path_format"/>
	<xsl:with-param name="path_args" select="$path_args"/>
      </xsl:apply-templates>
    </xsl:otherwise>
    
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>
