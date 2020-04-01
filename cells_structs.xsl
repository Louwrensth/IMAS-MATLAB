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

<xsl:template match="field" mode="CELLS_STRUCTS">
  <xsl:param name="method_name"/>

  <xsl:param name="unique_name"><xsl:if test="@data_type='struct_array'"><xsl:value-of select="concat(@name,'_',generate-id(.))"/></xsl:if></xsl:param>


  <xsl:if test="@data_type='structure' or @data_type='struct_array'">
    <xsl:call-template name="COMMENT_FIELD"/>
    <xsl:choose>
      <!--========== Regular structures ==========-->
      <xsl:when test="@data_type='structure' and .//field[@data_type='struct_array']">
	if (status.code >= 0) status = begin_dataTree_write("<xsl:value-of select="@name"/>", &amp;isEmpty);
	if (status.code >= 0 &amp;&amp; !isEmpty) {
	<xsl:apply-templates select="field" mode="CELLS_STRUCTS">
	  <xsl:with-param name="method_name" select="$method_name"/>
	</xsl:apply-templates>
	}
	/* Finished processing structure <xsl:value-of select="@name"/> */
	if (status.code >= 0) status = end_dataTree_action();
	/* Error handling */
	if (status.code &lt; 0) {
	addIdsPathInfoToErrMsg("\n ... in structure <xsl:value-of select="@path"/>",0);
	return status;
	}
      </xsl:when>

      <!--========== Arrays of structures ==========-->
      <xsl:when test="@data_type='struct_array'">
	<xsl:choose>
	  <xsl:when test="$method_name='struct_to_cell'">
	    if (params.use_cell_array_for_array_of_structures) {
	    if (status.code >= 0) status = get_data_from_dataTree("<xsl:value-of select="@name"/>", &amp;data);
	    if (status.code >= 0 &amp;&amp; data != NULL) {
	    status = castStructToCell(&amp;data);
	    if (status.code >= 0) status = replace_data_in_dataTree("<xsl:value-of select="@name"/>", (mxArray *) data);
	    }
	    }
	  </xsl:when>
	  <xsl:when test="$method_name='cell_to_struct'">
	    if (!params.use_cell_array_for_array_of_structures) {
	    if (status.code >= 0) status = get_data_from_dataTree("<xsl:value-of select="@name"/>", &amp;data);
	    if (status.code >= 0 &amp;&amp; data != NULL) {
	    status = castCellToStruct(&amp;data);
	    if (status.code >= 0) status = replace_data_in_dataTree("<xsl:value-of select="@name"/>", (mxArray *) data);
	    }
	    }
	  </xsl:when>
	</xsl:choose>
	<xsl:if test=".//field[@data_type='struct_array']">
	  if (status.code >= 0) status = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;n<xsl:value-of select="$unique_name"/>);
	  for (i<xsl:value-of select="$unique_name"/> = 0;i<xsl:value-of select="$unique_name"/>&lt; n<xsl:value-of select="$unique_name"/>; i<xsl:value-of select="$unique_name"/>++){
	  if (status.code >= 0) status = iterate_dataTree_array(i<xsl:value-of select="$unique_name"/>);
	  <xsl:apply-templates select="field" mode="CELLS_STRUCTS">
	    <xsl:with-param name="method_name" select="$method_name"/>
	  </xsl:apply-templates>
	  }
	  /* Finished processing array of structure <xsl:value-of select="@name"/> */
	  if (status.code >= 0) status = end_dataTree_array_action();
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="$method_name='struct_to_cell'">
	    if (!params.use_cell_array_for_array_of_structures) {
	    if (status.code >= 0) status = get_data_from_dataTree("<xsl:value-of select="@name"/>", &amp;data);
	    if (status.code >= 0 &amp;&amp; data != NULL) {
	    status = castStructToCell(&amp;data);
	    if (status.code >= 0) status = replace_data_in_dataTree("<xsl:value-of select="@name"/>", (mxArray *) data);
	    }
	    }
	  </xsl:when>
	  <xsl:when test="$method_name='cell_to_struct'">
	    if (params.use_cell_array_for_array_of_structures) {
	    if (status.code >= 0) status = get_data_from_dataTree("<xsl:value-of select="@name"/>", &amp;data);
	    if (status.code >= 0 &amp;&amp; data != NULL) {
	    status = castCellToStruct(&amp;data);
	    if (status.code >= 0) status = replace_data_in_dataTree("<xsl:value-of select="@name"/>", (mxArray *) data);
	    }
	    }
	  </xsl:when>
	</xsl:choose>
	/* Error handling */
	if (status.code &lt; 0) {
	addIdsPathInfoToErrMsg("\n ... in aos <xsl:value-of select="@path"/>",0);
	return status;
	}
      </xsl:when>
    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
