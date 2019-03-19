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

<xsl:if test="$dynamic_only !='yes' or descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
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
      <!-- ual_end_action(aosCtx) is taken care of in get_... -->	
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
      status = <xsl:value-of select="concat($methodName,'_',@name,'_',generate-id(.))"/>(ctx, homogeneousTime, structure);
      if (status &lt; 0) {
      <!-- ual_end_action(aosCtx) is taken care of in get_... -->
      ual_end_action(ctx);
      return status;
      }
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
    ifield = mxGetFieldNumber(ids, "<xsl:value-of select="@name"/>");
    if (ifield &lt; 0)
    mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$methodName"/>:invalid_field",
    "Unable to retrieve field %s (in PUT_SINGLE)", "<xsl:value-of select="@path"/>");
    data = mxGetFieldByNumber(ids, (mwIndex) 0, ifield);
    if (data != NULL &amp;&amp; mxGetNumberOfElements(data) &gt; 0) {
    status = write_data_from_mxArray(ctx, fieldPath, timebasePath, <xsl:call-template name="DATATYPE_AND_DIM"/>, data);
    if (status &lt; 0) {	
    ual_end_action(ctx);
    return status;
    }
    }
  </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
