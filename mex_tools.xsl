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

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="LIST">
  <xsl:param name="prefix"/>
  <xsl:param name="suffix"/>
<xsl:value-of select="concat($prefix,@name,$suffix)"/></xsl:template>

<xsl:template match="IDS" mode="SWITCH">
  <xsl:param name="function_name"/>
  if (!strcmp(name, "<xsl:value-of select="@name"/>")) {
  if (params.verbosity >= 4)
    mexPrintf("Matched <xsl:value-of select="@name"/>\n");
  <xsl:value-of select="$function_name"/> = &amp;<xsl:value-of select="concat($function_name,'_',@name)"/>;
  } else</xsl:template>

<xsl:template name ="printAosRelativePath">
  <xsl:variable name="AoSPath" select="ancestor::field[@data_type='struct_array'][1]/@path"/>
  <xsl:variable name="elementPath" select="@path"/>

  <xsl:choose>
    <xsl:when test="ancestor::field[@data_type='struct_array']">
      <xsl:value-of select="replace($elementPath,concat($AoSPath,'/'),'')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$elementPath"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--Documentation for a single field-->
<xsl:template name = "COMMENT_FIELD">
  <xsl:text>&#xA;</xsl:text>
  <xsl:text>/*-----------------------------------------------------------------------------------------&#xA;</xsl:text>
  <xsl:text>    </xsl:text><xsl:value-of select="@name"/>:<xsl:value-of select="@path"/>:<xsl:value-of select="@data_type"/>:<xsl:value-of select="@type"/>:<xsl:text>&#xA;</xsl:text>

  <xsl:if test="@data_type='struct_array'">
    <xsl:text>  -----------------------------------------------------------------------------------------&#xA;</xsl:text>

    <xsl:if test="@type='dynamic' and @maxoccur='unbounded'">
      <xsl:text>    ARRAY of TYPE 3 &#xA;</xsl:text>
    </xsl:if>

    <xsl:if test="(not(@type) or @type!='dynamic') and @maxoccur='unbounded'">
      <xsl:text>    ARRAY of TYPE 2  &#xA;</xsl:text>
    </xsl:if>

    <xsl:if test="@maxoccur!='unbounded'">
      <xsl:text>    ARRAY of TYPE 1  &#xA;</xsl:text>
    </xsl:if>
  </xsl:if>

  <xsl:text>  -----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
</xsl:template>

<xsl:function name="my:get_datatype" as="xs:string">
  <xsl:param name="data_type" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$data_type='str_type' or $data_type='STR_0D' or
		    $data_type='str_1d_type' or $data_type='STR_1D'">
      <xsl:sequence select="'CHAR_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='int_type' or $data_type='INT_0D' or
		    $data_type='int_1d_type' or $data_type='INT_1D' or
		    $data_type='INT_2D' or $data_type='INT_3D' or
		    $data_type='INT_4D' or $data_type='INT_5D' or
		    $data_type='INT_6D'">
      <xsl:sequence select="'INTEGER_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='flt_type' or $data_type='FLT_0D' or
		    $data_type='flt_1d_type' or $data_type='FLT_1D' or
		    $data_type='FLT_2D' or $data_type='FLT_3D' or
		    $data_type='FLT_4D' or $data_type='FLT_5D' or
		    $data_type='FLT_6D'">
      <xsl:sequence select="'DOUBLE_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='cpx_type' or $data_type='CPX_0D' or
		    $data_type='cpx_1d_type' or $data_type='CPX_1D' or
		    $data_type='CPX_2D' or $data_type='CPX_3D' or
		    $data_type='CPX_4D' or $data_type='CPX_5D' or
		    $data_type='CPX_6D'">
      <xsl:sequence select="'COMPLEX_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='structure' or $data_type='struct_array'">
      <xsl:sequence select="'UNKNOWN_DATA'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="$data_type"/> !</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="my:get_dim" as="xs:integer">
  <xsl:param name="data_type" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$data_type='flt_type' or $data_type='FLT_0D' or
		    $data_type='int_type' or $data_type='INT_0D' or
		    $data_type='cpx_type' or $data_type='CPX_0D'">
      <xsl:sequence select="0"/>
    </xsl:when>
    <xsl:when test="$data_type='str_type' or $data_type='STR_0D' or
		    $data_type='flt_1d_type' or $data_type='FLT_1D' or
		    $data_type='int_1d_type' or $data_type='INT_1D' or
		    $data_type='cpx_1d_type' or $data_type='CPX_1D'">
      <xsl:sequence select="1"/>
    </xsl:when>
    <xsl:when test="$data_type='str_1d_type' or $data_type='STR_1D' or
		    $data_type='FLT_2D' or $data_type='INT_2D' or $data_type='CPX_2D'">
      <xsl:sequence select="2"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_3D' or $data_type='INT_3D' or $data_type='CPX_3D'">
      <xsl:sequence select="3"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_4D' or $data_type='INT_4D' or $data_type='CPX_4D'">
      <xsl:sequence select="4"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_5D' or $data_type='INT_5D' or $data_type='CPX_5D'">
      <xsl:sequence select="5"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_6D' or $data_type='INT_6D' or $data_type='CPX_6D'">
      <xsl:sequence select="6"/>
    </xsl:when>
    <xsl:when test="$data_type='structure' or $data_type='struct_array'">
      <xsl:sequence select="xs:integer(-1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="$data_type"/> !</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


</xsl:stylesheet>
