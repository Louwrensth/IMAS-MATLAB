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

<xsl:template match="field" mode="INTS_DOUBLES">
  <xsl:param name="method_name"/>

  <xsl:param name="unique_name"><xsl:if test="@data_type='struct_array'"><xsl:value-of select="concat(@name,'_',generate-id(.))"/></xsl:if></xsl:param>

  <xsl:variable name="AosRelativePath">
    <xsl:call-template name="printAosRelativePath"/>
  </xsl:variable>

  <xsl:if test="@data_type='structure' or @data_type='struct_array' or my:get_datatype(@data_type)='INTEGER_DATA'">
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:choose>
      <!--========== Regular structures ==========-->
      <xsl:when test="@data_type='structure'">
	<xsl:if test=".//field[my:get_datatype(@data_type)='INTEGER_DATA']">
	  if (status >= 0) status = begin_dataTree_write("<xsl:value-of select="@name"/>", &amp;isEmpty);
	  if (status >= 0 &amp;&amp; !isEmpty) {
	  <xsl:apply-templates select="field" mode="INTS_DOUBLES">
	    <xsl:with-param name="method_name" select="$method_name"/>
	  </xsl:apply-templates>
	  }
	  /* Finished processing structure <xsl:value-of select="@name"/> */
	  if (status >= 0) status = end_dataTree_action();
	  /* Error handling */
	  if (status &lt; 0) {
	  addIdsPathInfoToErrMsg("\n ... in structure <xsl:value-of select="@path"/>",0);
	  return status;
	  }
	</xsl:if>
      </xsl:when>

      <!--========== Arrays of structures ==========-->
      <xsl:when test="@data_type='struct_array'">
	<xsl:if test=".//field[my:get_datatype(@data_type)='INTEGER_DATA']">
	  if (status >= 0) status = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;n<xsl:value-of select="$unique_name"/>);
	  for (i<xsl:value-of select="$unique_name"/> = 0;i<xsl:value-of select="$unique_name"/>&lt; n<xsl:value-of select="$unique_name"/>; i<xsl:value-of select="$unique_name"/>++){
	  if (status >= 0) status = iterate_dataTree_array(i<xsl:value-of select="$unique_name"/>);
	  <xsl:apply-templates select="field" mode="INTS_DOUBLES">
	    <xsl:with-param name="method_name" select="$method_name"/>
	  </xsl:apply-templates>
	  }
	  /* Finished processing array of structure <xsl:value-of select="@name"/> */
	  if (status >=0) status = end_dataTree_array_action();
	  /* Error handling */
	  if (status &lt; 0) {
	  addIdsPathInfoToErrMsg("\n ... in aos <xsl:value-of select="@path"/>",0);
	  return status;
	  }
	</xsl:if>
      </xsl:when>
      <xsl:when test="my:get_datatype(@data_type)='INTEGER_DATA'">
	if (status >= 0) status = get_data_from_dataTree("<xsl:value-of select="@name"/>", (mxArray **) &amp;data);
	if (status >= 0 &amp;&amp; data != NULL) {
	<xsl:choose>
	  <xsl:when test="$method_name='double_to_int'">
	    if (mxIsNumeric(data) &amp;&amp; mxIsDouble(data)) {
	    status = castDoubleToInt32((mxArray **) &amp;data);
	  </xsl:when>
	  <xsl:when test="$method_name='int_to_double'">
	    if (mxIsNumeric(data) &amp;&amp; mxIsInt32(data)) {
	    status = castInt32ToDouble((mxArray **) &amp;data);
	  </xsl:when>
	</xsl:choose>
	if (status >= 0) status = replace_data_in_dataTree("<xsl:value-of select="@name"/>", (mxArray *) data);
	}
	}
	/* Error handling */
	if (status &lt; 0) {
	addIdsPathInfoToErrMsg("\n ... in field <xsl:value-of select="@path"/>",0);
	return status;
	}
      </xsl:when>

      <xsl:otherwise>
	<xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="@data_type"/> !</xsl:message>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
