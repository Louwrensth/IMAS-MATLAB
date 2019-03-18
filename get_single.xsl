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
      status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(ctx, homogeneousTime, &amp;structure);
      if (status != 0)
      return status;
      ifield = mxAddField(*ids,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(*ids,0,ifield,structure);
      structure=NULL;
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="@data_type='str_type'    or @data_type='STR_0D' or
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
      status = read_data_to_mxArray(ctx, fieldPath, timebasePath, <xsl:call-template name="DATATYPE_AND_DIM"/>, data);
      ifield = mxAddField(*ids,"<xsl:value-of select="@name"/>");
      mxSetFieldByNumber(*ids,0,ifield,data);
      data = NULL;
      if (status &lt; 0) {	
      ual_end_action(ctx);
      return status;
      }
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
