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
<!--                Template for IDSs               -->
<!--================================================-->

<xsl:template match="IDS" mode="LIST">
  <xsl:param name="prefix"/>
  <xsl:param name="suffix"/>
<xsl:value-of select="concat($prefix,@name,$suffix)"/></xsl:template>

<xsl:template match="IDS" mode="SWITCH">
  <xsl:param name="function_name"/>
  <xsl:param name="function_args"/>
  if (!strcmp(name, "<xsl:value-of select="@name"/>")) {
  #ifndef NDEBUG
  mexPrintf("Matched <xsl:value-of select="@name"/>\n");
  #endif
  int err = <xsl:value-of select="concat($function_name,'_',@name,'(',$function_args,');')"/>
  if (err) 
  mexErrMsgIdAndTxt("IMAS:ids_<xsl:value-of select="$function_name"/>:internal_error","internal error occured in function <xsl:value-of select="concat($function_name,'_',@name)"/> with code err=%d", err);
  return;
}</xsl:template>

</xsl:stylesheet>
