<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--================================================-->
<!--                Template for time               -->
<!--================================================-->

<xsl:template name="printtimepath">
  <xsl:if test="@type = 'dynamic'">
    <xsl:choose>
      <xsl:when test="contains(@coordinate7,'time')"> <xsl:value-of select="translate(replace(@coordinate7,'(itime)',''),'()','')"/></xsl:when> <!-- We remove the (itime) pattern from the coordinate attribute in IDSDef, which is documentation-oriented -->
      <xsl:when test="contains(@coordinate6,'time')"> <xsl:value-of select="translate(replace(@coordinate6,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate5,'time')"> <xsl:value-of select="translate(replace(@coordinate5,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate4,'time')"> <xsl:value-of select="translate(replace(@coordinate4,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate3,'time')"> <xsl:value-of select="translate(replace(@coordinate3,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate2,'time')"> <xsl:value-of select="translate(replace(@coordinate2,'(itime)',''),'()','')"/></xsl:when>
      <xsl:when test="contains(@coordinate1,'time')"> <xsl:value-of select="translate(replace(@coordinate1,'(itime)',''),'()','')"/></xsl:when>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="@name='time'">
    <xsl:value-of select="@path"/>
  </xsl:if>
  <!-- If the field itself IS time, then it is its own time coordinate -->
</xsl:template>

<xsl:template name="printtimevariable">
  <xsl:param name="pointer_name"/>
  <xsl:param name="AosParent_name"/>
  <!-- This is for simple type fields (cannot be children of dynamic type 3 AoS
       Probably best to use coordinate?_AosParent_relative and pass name of pointer
       for current AosParent (including index) as parameter to template.
       Then we need to parse the path string and navigate in the MATLAB structure
       to evaluate the value.
  -->
  <xsl:if test="@type = 'dynamic'">
    <xsl:choose>
      <xsl:when test="contains(@coordinate7,'time') and not(contains(@coordinate7,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate7"/>")
      </xsl:when>
      <xsl:when test="contains(@coordinate6,'time') and not(contains(@coordinate6,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate6"/>")
      </xsl:when>
      <xsl:when test="contains(@coordinate5,'time') and not(contains(@coordinate5,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate5"/>")
      </xsl:when>
      <xsl:when test="contains(@coordinate4,'time') and not(contains(@coordinate4,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate4"/>")
      </xsl:when>
      <xsl:when test="contains(@coordinate3,'time') and not(contains(@coordinate3,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate3"/>")
      </xsl:when>
      <xsl:when test="contains(@coordinate2,'time') and not(contains(@coordinate2,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate2"/>")
      </xsl:when>
      <xsl:when test="contains(@coordinate1,'time') and not(contains(@coordinate1,'('))">
	getSimpleFieldStruct(<xsl:value-of select="$AosParent_name"/>,"<xsl:value-of select="@coordinate1"/>")
      </xsl:when>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="@name='time'">
    getSimpleFieldStruct(<xsl:value-of select="$pointer_name"/>,"<xsl:value-of select="translate(@path,'/','.')"/>")
  </xsl:if>
  <!-- If the field itself IS time, then it is its own time coordinate -->
</xsl:template>

<xsl:template name="printIsTimed">
  <xsl:choose>
    <xsl:when test="@type = 'dynamic'">
      <xsl:value-of select="1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="0"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
