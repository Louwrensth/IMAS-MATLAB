<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:my="dummy"
    version="2.0">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--=================================================-->
<!--       put field of a time-dependent IDS         -->
<!--=================================================-->

<xsl:template match="field" mode="EMPTYS_NANS">
  <xsl:param name="method_name"/>

  <xsl:param name="unique_name"><xsl:if test="@data_type='struct_array'"><xsl:value-of select="concat(@name,'_',generate-id(.))"/></xsl:if></xsl:param>

  <xsl:if test="@data_type='structure' or @data_type='struct_array' or my:get_datatype(@data_type)='DOUBLE_DATA'">
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:choose>
      <!--========== Regular structures ==========-->
      <xsl:when test="@data_type='structure'">
	<xsl:if test=".//field[my:get_datatype(@data_type)='DOUBLE_DATA']">
	  if (begin_dataTree_write("<xsl:value-of select="@name"/>", &amp;isEmpty) &lt; 0)
	  return -1;
	  if (!isEmpty) {
	  <xsl:apply-templates select="field" mode="EMPTYS_NANS">
	    <xsl:with-param name="method_name" select="$method_name"/>
	  </xsl:apply-templates>
	  }
	  // Finished processing structure <xsl:value-of select="@name"/>
	  if (end_dataTree_action() &lt; 0)
	  return -1;
	</xsl:if>
      </xsl:when>

      <!--========== Arrays of structures ==========-->
      <xsl:when test="@data_type='struct_array'">
	<xsl:if test=".//field[my:get_datatype(@data_type)='DOUBLE_DATA']">
	  if (begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;n<xsl:value-of select="$unique_name"/>) &lt; 0)
	  return -1;
	  for (i<xsl:value-of select="$unique_name"/> = 0;i<xsl:value-of select="$unique_name"/>&lt; n<xsl:value-of select="$unique_name"/>; i<xsl:value-of select="$unique_name"/>++){
	  if (iterate_dataTree_array(i<xsl:value-of select="$unique_name"/>) &lt; 0)
	  return -1;
	  <xsl:apply-templates select="field" mode="EMPTYS_NANS">
	    <xsl:with-param name="method_name" select="$method_name"/>
	  </xsl:apply-templates>
	  }
	  // Finished processing array of structure <xsl:value-of select="@name"/>
	  if (end_dataTree_array_action() &lt; 0)
	  return -1;
	</xsl:if>
      </xsl:when>
      <xsl:when test="my:get_datatype(@data_type)='DOUBLE_DATA'">
	if (get_data_from_dataTree("<xsl:value-of select="@name"/>", (mxArray **) &amp;data) &lt; 0)
	return -1;
	if  (data != NULL) {
	<xsl:choose>
	  <xsl:when test="$method_name='empty_to_nan'">
	    if (mxIsNumeric(data) &amp;&amp; mxIsDouble(data)) {
	    cast_status = castEmptyToNaN((mxArray **) &amp;data);
	    if (cast_status &lt; 0) {
	    strncpy(mex_errmsgid,"cast_failed",12);
	    strncpy(&amp;mex_errmsgtxt[msglen], "Unable to replace EMPTY_FLOATs by NaNs for field <xsl:value-of select="@path"/>", MAXERRMSGTXTSIZE-msglen);
	    return -1;
	  </xsl:when>
	  <xsl:when test="$method_name='nan_to_empty'">
	    if (mxIsNumeric(data) &amp;&amp; mxIsDouble(data)) {
	    cast_status = castNaNToEmpty((mxArray **) &amp;data);
	    if (cast_status &lt; 0) {
	    strncpy(mex_errmsgid,"cast_failed",12);
	    strncpy(&amp;mex_errmsgtxt[msglen], "Unable to replace NaNs by EMPTY_FLOATs for field <xsl:value-of select="@path"/>", MAXERRMSGTXTSIZE-msglen);
	    return -1;
	  </xsl:when>
	</xsl:choose>
	} else {
	if (replace_data_in_dataTree("<xsl:value-of select="@name"/>", (mxArray *) data) &lt; 0)
	return -1;
	}
	}
	}
      </xsl:when>

      <xsl:otherwise>
	<xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="@data_type"/> !</xsl:message>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
