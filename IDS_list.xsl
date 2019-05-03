<!--  Generating  Matlab code structs from IDSDefs.xml YB.MA Feb 2008 -->
<!-- -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:my="dummy"
    version="2.0">
  <!-- -->
  <xsl:output method="text"/>

  <xsl:template match = "/IDSs">
    <xsl:result-document href="matlab/IDS_list.m" method="text">
      <xsl:text>function out = IDS_list&#xA;</xsl:text>
      <xsl:text>% Return the list of existing IDSs&#xA;</xsl:text>
      <xsl:text>% This file was generated automatically&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>out = {&#xA;</xsl:text>
      <xsl:apply-templates select = "IDS"/>
      <xsl:text>};&#xA;</xsl:text>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match = "IDS">
    <xsl:text>'</xsl:text>
    <xsl:value-of select = "@name"/>
    <xsl:text>';...&#xA;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
