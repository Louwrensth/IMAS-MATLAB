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
<!--          Allocate an array of structure         -->
<!--=================================================-->

<xsl:template match="field" mode="ALLOCATE">
<xsl:param name="scalar_aos"/>

<xsl:param name="unique_name"><xsl:if test="@data_type='struct_array'"><xsl:value-of select="concat(@name,'_',generate-id(.))"/></xsl:if></xsl:param>

<xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
  <!--========== Array of structure ===========-->
    <xsl:when test = "@data_type = 'struct_array'">
      <xsl:choose>
	<xsl:when test="$scalar_aos">
	  if (status >= 0) status = begin_dataTree_array_read("<xsl:value-of select="@name"/>",1);
	  if (status >= 0) status = iterate_dataTree_array(0);
	  <xsl:apply-templates select = "field" mode = "ALLOCATE">
	    <xsl:with-param name="scalar_aos" select="$scalar_aos"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  if (status >= 0) status = begin_dataTree_array_read("<xsl:value-of select="@name"/>",0);
	</xsl:otherwise>
      </xsl:choose>
      /* Finished processing array of structure <xsl:value-of select="@name"/> */
      if (status >= 0) status = end_dataTree_array_action();
      /* Error handling */
      if (status &lt; 0) {
      return status;
      }
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      if (status >= 0) status = begin_dataTree_read("<xsl:value-of select="@name"/>");
      <xsl:apply-templates select = "field" mode = "ALLOCATE">
	<xsl:with-param name="scalar_aos" select="$scalar_aos"/>
      </xsl:apply-templates>
      /* Finished processing structure <xsl:value-of select="@name"/> */
      if (status >= 0) status = end_dataTree_action();
      /* Error handling */
      if (status &lt; 0) {
      return status;
      }
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="my:get_datatype(@data_type)='CHAR_DATA' or 
		    my:get_datatype(@data_type)='INTEGER_DATA' or 
		    my:get_datatype(@data_type)='DOUBLE_DATA' or 
		    my:get_datatype(@data_type)='COMPLEX_DATA'">
      if (status >= 0) status = mxArray_default_value(<xsl:value-of select="my:get_datatype(@data_type)"/>, <xsl:value-of select="my:get_dim(@data_type)"/>, &amp;data);
      if (status >= 0) status = put_data_in_dataTree("<xsl:value-of select="@name"/>", data);
      /* Error handling */
      if (status &lt; 0) {
      return status;
      }
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="@data_type"/> !</xsl:message>
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
