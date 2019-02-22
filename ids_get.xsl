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

<xsl:template match="IDS" mode="GET">
 <xsl:result-document href="src/ids/get_{@name}.c" standalone="yes" method="text">
   #include "mex.h"
   #include "ual_low_level.h"
   #include "imas_mex_utils.h"
   #include &lt;stdlib.h&gt;
   #include &lt;string.h&gt;
   #include &lt;stdio.h&gt;

   int get_<xsl:value-of select="@name"/>(int expIdx, int idx, mxArray** ids)
   {
   int status;
   int numSamples;
   void *obj_all_times;
   int numDims, dim1, dim2, dim3, dim4, dim5, dim6, dim7;
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
   int maxpathsize=128;
   char clepath[maxpathsize];
   // AoS-specific variables<xsl:for-each select=".//field[@data_type='struct_array']">
   int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
   int n<xsl:value-of select="concat(@name,'_',generate-id(.))"/>;
   mxArray* pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;
   mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
   // Structure-specific variables<xsl:for-each select=".//field[@data_type='structure']">
   mxArray* p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=NULL;</xsl:for-each>
   mxArray* data=NULL;
   int ifield;
   mwSize* dims;
   mwSize dims_scalar[2] = { 1, 1 };
   int _i;
   char *basePath = "<xsl:value-of select="@name"/>";
   char path[strlen(basePath)+4];
   if(idx &lt; 1)
   sprintf(path, "%s", basePath);
   else
   sprintf(path, "%s/%d", basePath, idx);
   status = beginIdsGet(expIdx, path, NON_TIMED, &amp;numSamples);
   checkStatus(status);
   if (status) return status;
   *ids = mxCreateStructMatrix(1,1,0,NULL);
   <xsl:apply-templates select="field" mode="GET_SINGLE">
     <xsl:with-param name="pointer_name" select="'*ids'"/>
   </xsl:apply-templates>
   endIdsGet(expIdx, path);
   return 0;
   }
 </xsl:result-document>
</xsl:template>


<xsl:template match="field" mode="GET_SINGLE">
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

// Doc Get <xsl:value-of select="@path_doc"/>
<xsl:choose>
  <!--========== Array of structure ===========-->
    <!-- Type 1 arrays of structure, with potentially multiple time bases -->
    <xsl:when test = "@data_type = 'struct_array' and @maxoccur!='unbounded' ">
      /* Type 1 AoS */
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
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      <xsl:apply-templates select="field" mode="GET_SINGLE">
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	<xsl:with-param name="path_format" select="concat($currentpath_format,'/%d')"/>
	<xsl:with-param name="path_args" select="concat($path_args,',i',@name,'_',generate-id(.),'+1')"/>
      </xsl:apply-templates>
      mxSetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      }
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
    </xsl:when>
    <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
      /* Type 3 AoS (maybe nested below a Type 1) */
      <xsl:value-of select="$currentpath_expr"/>
      status = getObject(expIdx, path, clepath, &amp;obj_all_times, TIMED); // read the whole non-timed block
      checkStatus(status);
      if(!status) {
      dim1 = getObjectDim(expIdx,obj_all_times);
      pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxCreateCellMatrix(dim1,1);
      //if (ual_debug =='yes') write(*,*) &amp; 'Get <xsl:value-of select = "@path"/>, lentime =', lentime
      for (int i1 = 0; i1 &lt; dim1; i1++) {  // fill every time slice
      void *obj1;
      status = getObjectFromObject(expIdx,obj_all_times, "ALLTIMES", i1, &amp;obj1);  // extract a single time
      checkStatus(status);
      if (!status) {
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>=mxGetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
        <xsl:with-param name="level" select="1"/>
        <xsl:with-param name="objpath" select="@name"/>
        <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
        <xsl:with-param name="timed" select="'yes'"/>
      </xsl:apply-templates>
      mxSetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,i1,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      }
      }
      releaseObject(expIdx,obj_all_times);
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      if (p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>==NULL)
      p<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = mxCreateStructMatrix(1,1,0,NULL);
      <xsl:apply-templates select="field" mode="GET_SINGLE">
	<xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	<xsl:with-param name="path_format" select="$currentpath_format"/>
	<xsl:with-param name="path_args" select="$path_args"/>
      </xsl:apply-templates>
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getInt(expIdx, path, clepath, &amp;int0d);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericArray(2,dims_scalar,mxINT32_CLASS,mxREAL);
      memcpy(&amp;int0d,mxGetData(data),sizeof(int));
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
  
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getDouble(expIdx, path, clepath, &amp;double0d);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleScalar(double0d);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
  
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getString(expIdx, path, clepath, &amp;str);
      checkStatus(status);
      if(!status) {
      dstr = strdup(str);
      free(str);
      data = mxCreateString(dstr);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
	
  <!--========== Vectors ===========-->
    <xsl:when test = "@data_type='int_1d_type' or @data_type='INT_1D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect1DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericMatrix(dim1,1,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
  
    <xsl:when test = "@data_type='flt_1d_type' or @data_type='FLT_1D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect1DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,1,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
      
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect1DString(expIdx, path, clepath, &amp;stringArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      dstringArray = malloc(dim1*sizeof(char*));
      for (_i = 0; _i &lt; dim1; _i++) {
      dstringArray[_i] = strdup(stringArray[_i]);
      free(stringArray[_i]);
      }
      free((char *)stringArray);
      data = mxCreateCharMatrixFromStrings(dim1,dstringArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>

  <!--========== Matrices ===========-->
    <xsl:when test="@data_type='INT_2D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect2DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericMatrix(dim1,dim2,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_2D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect2DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>

  <!--========== 3D arrays ===========-->
    <xsl:when test="@data_type='INT_3D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect3DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
      checkStatus(status);
      if(!status) {
      dims = malloc(3*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
      data = mxCreateNumericArray(3,dims,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*dim3*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_3D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect3DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
      checkStatus(status);
      if(!status) {
      dims = malloc(3*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;
      data = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

  <!--========== 4D arrays ===========-->
    <xsl:when test="@data_type='INT_4D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect4DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
      checkStatus(status);
      if(!status) {
      dims = malloc(4*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;
      data = mxCreateNumericArray(4,dims,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*dim3*dim4*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_4D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect4DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
      checkStatus(status);
      if(!status) {
      dims = malloc(4*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;
      data = mxCreateNumericArray(4,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*dim4*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

  <!--========== 5D arrays ===========-->
    <xsl:when test="@data_type='INT_5D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect5DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
      checkStatus(status);
      if(!status) {
      dims = malloc(5*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;
      data = mxCreateNumericArray(5,dims,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*dim3*dim4*dim5*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_5D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect5DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
      checkStatus(status);
      if(!status) {
      dims = malloc(5*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*dim4*dim5*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

  <!--========== 6D arrays ===========-->
    <xsl:when test="@data_type='INT_6D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect6DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
      checkStatus(status);
      if(!status) {
      dims = malloc(6*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;dims[5] = dim6;
      data = mxCreateNumericArray(6,dims,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*dim3*dim4*dim5*dim6*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

    <xsl:when test="@data_type='FLT_6D'">
      <xsl:value-of select="$currentpath_expr"/>
      status = getVect6DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
      checkStatus(status);
      if(!status) {
      dims = malloc(6*sizeof(mwSize));
      dims[0] = dim1;dims[1] = dim2;dims[2] = dim3;dims[3] = dim4;dims[4] = dim5;dims[5] = dim6;
      data = mxCreateNumericArray(6,dims,mxDOUBLE_CLASS,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*dim3*dim4*dim5*dim6*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>

</xsl:template>




<!--=================================================-->
<!--            get fields from an object            -->
<!--=================================================-->
<!--YBYB 2014 -->
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
      if (mxIsCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>)) { // does this array already exist? (timed and non timed parts can share the same array)
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
	  <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
	    <xsl:with-param name="level" select="$level + 1"/>
	    <xsl:with-param name="objpath" select="@name"/>
	    <xsl:with-param name="pointer_name" select="concat('p',@name,'_',generate-id(.))"/>
	    <xsl:with-param name="timed" select="'no'"/>  <!-- We assume the nested children are necessarily Type 2 -->
	  </xsl:apply-templates>
	  mxSetCell(pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>,i<xsl:value-of select="$level + 1"/>,p<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
      }
      }
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,pa<xsl:value-of select="concat(@name,'_',generate-id(.))"/>);
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
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      status = getStringFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;str);
      checkStatus(status);
      if(!status) {
      char* dstr = strdup(str);
      free(str);
      data = mxCreateString(dstr);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
    
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      status = getIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;int0d);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericArray(2,dims_scalar,mxINT32_CLASS,mxREAL);
      memcpy(&amp;int0d,mxGetData(data),sizeof(int));
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
    
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      status = getDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;double0d);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleScalar(double0d);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
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
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
    
    <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
      status = getVect1DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,1,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
    
    <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
      status = getVect1DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1);
      checkStatus(status);
      if(!status) {
      data = mxCreateNumericMatrix(dim1,1,mxINT32_CLASS,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
    
    <xsl:when test="@data_type='FLT_2D'">
      status = getVect2DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
      memcpy(doubleArray,mxGetData(data),dim1*dim2*sizeof(double));
      free(doubleArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
    </xsl:when>
    
    <xsl:when test="@data_type='INT_2D'">
      status = getVect2DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1, &amp;dim2);
      checkStatus(status);
      if(!status) {
      data = mxCreateDoubleMatrix(dim1,dim2,mxREAL);
      memcpy(intArray,mxGetData(data),dim1*dim2*sizeof(int));
      free(intArray);
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      data = NULL;
      }
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
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
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
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
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
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
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
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
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
      ifield = mxAddField(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(<xsl:value-of select="$pointer_name"/>,0,ifield,data);
      dims = NULL;
      data = NULL;
      }
    </xsl:when>
	
</xsl:choose>

</xsl:template>



</xsl:stylesheet>
