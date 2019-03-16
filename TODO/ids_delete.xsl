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
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:apply-templates select = "IDS" mode="DELETE"/>
</xsl:template>

<!--================================================-->
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="DELETE">
  <xsl:result-document href="src/ids/delete_{@name}.c.in" standalone="yes" method="text">
    #include "mex.h"
    #include "ual_low_level.h"
    #include "imas_mex_utils.h"
    #include &lt;stdlib.h&gt;
    #include &lt;string.h&gt;
    #include &lt;stdio.h&gt;

    int delete_<xsl:value-of select="@name"/>(int expIdx, int idx)
    {
    // Paths-specific variables
    int maxpathsize=1024;
    char clepath[maxpathsize];<xsl:for-each select=".//field[@data_type='struct_array' and @maxoccur!='unbounded']">
    int i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>; </xsl:for-each>
    char *basePath = "<xsl:value-of select="@name"/>";
    char path[strlen(basePath)+4];
    if(idx &lt; 1)
    sprintf(path, "%s", basePath);
    else
    sprintf(path, "%s/%d", basePath, idx);
    <xsl:apply-templates select="field" mode="DELETE"/>
    return 0;
    }
  </xsl:result-document>
</xsl:template>

<xsl:template match="field" mode="DELETE">
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

  <xsl:choose>
    <xsl:when test="@data_type='structure'">
      <xsl:apply-templates select="field" mode="DELETE">
	<xsl:with-param name="path_format" select="$currentpath_format"/>
	<xsl:with-param name="path_args" select="$path_args"/>
      </xsl:apply-templates>
    </xsl:when>
    <!--========== Arrays of structures ==========-->
    <xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
      for (i<xsl:value-of select="concat(@name,'_',generate-id(.))"/> = 0;i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>&lt;<xsl:value-of select="@maxoccur"/>; i<xsl:value-of select="concat(@name,'_',generate-id(.))"/>++){
      <xsl:apply-templates select="field" mode="DELETE">
	<xsl:with-param name="path_format" select="concat($currentpath_format,'/%d')"/>
	<xsl:with-param name="path_args" select="concat($path_args,',i',@name,'_',generate-id(.),'+1')"/>
      </xsl:apply-templates>
      }
      <xsl:choose>
	<xsl:when test="$path_args">
	snprintf(clepath,maxpathsize,"<xsl:value-of select="$currentpath_format"/>/Shape_of"<xsl:value-of select="$path_args"/>);</xsl:when>
	<xsl:otherwise>
	snprintf(clepath,maxpathsize,"%s","<xsl:value-of select="$currentpath_format"/>/Shape_of");</xsl:otherwise>
      </xsl:choose>
      deleteData(expIdx, path, clepath);
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$currentpath_expr"/>
      deleteData(expIdx, path, clepath);
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
