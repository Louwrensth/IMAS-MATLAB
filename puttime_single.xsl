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
<!--        put time for time-dependent field        -->
<!--=================================================-->

<xsl:template name="puttime_SINGLE">
  <xsl:param name="pointer_name"/>
  <xsl:param name="AosParent_name"/>
  <xsl:param name="path_format"/>
  <xsl:param name="path_args"/>
  <xsl:param name="non_timed"/>

  <xsl:param name="currentpath_format">
    <xsl:choose>
      <xsl:when test="$path_format"><xsl:value-of select="concat($path_format,'/',@name)"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:choose>
    <xsl:when test="@type='dynamic'">
      if (homogeneous_time == 0) {
      <!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
      <xsl:choose>
	<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data']) or @name='data_error_upper' or @name='data_error_lower'">
	  <xsl:choose>
	    <xsl:when test="$path_args">
	    snprintf(timebasepath,maxpathsize,"<xsl:value-of select="$currentpath_format"/>/time"<xsl:value-of select="$path_args"/>);</xsl:when>
	    <xsl:otherwise>
	    snprintf(timebasepath,maxpathsize,"%s","<xsl:value-of select="$currentpath_format"/>/time");</xsl:otherwise>
	  </xsl:choose>
	  ptime = mxGetField(<xsl:value-of select="$pointer_name"/>, (mwIndex) 0, "time");
	  if (ptime == NULL)
	  mexErrMsgIdAndTxt("IMAS:ids_put:invalid_field",
	  "Unable to retrieve field time of %s", "<xsl:value-of select="@path"/>");
	  dim1 = mxGetNumberOfElements(ptime);
	  doubleArray = mxGetPr(ptime);
	  beginIdsPutTimed(expIdx, path, dim1, doubleArray);
	  doubleArray = NULL;
	</xsl:when>
	<xsl:otherwise>
	  snprintf(timebasepath,maxpathsize,"%s","<xsl:call-template name="printtimepath"/>");
	  ptime = <xsl:call-template name="printtimevariable">
	  <xsl:with-param name="pointer_name" select="$pointer_name"/>
	  <xsl:with-param name="AosParent_name" select="$AosParent_name"/>
	  </xsl:call-template>;
	  dim1 = mxGetNumberOfElements(ptime);
	  doubleArray = mxGetPr(ptime);
	  beginIdsPutTimed(expIdx, path, dim1, doubleArray);
	  doubleArray = NULL;
	</xsl:otherwise>
      </xsl:choose>
      } else {
      snprintf(timebasepath,maxpathsize,"%s","time");
      dim1 = mxGetNumberOfElements(ptime);
      beginIdsPutTimed(expIdx, path, dim1, dtime);
      }
    </xsl:when>
    <xsl:otherwise>
      snprintf(timebasepath,maxpathsize,"%s","");
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
