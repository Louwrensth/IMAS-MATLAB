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

<xsl:template match="field[@data_type='struct_array']" mode="VALIDATE_CHILD_1D">
    <xsl:choose>
  <xsl:when test="not(contains(@coordinate1,' OR ')) and not(contains(@coordinate1, '1...'))">
  // validation of <xsl:value-of select="@path"/>
  if (status.code &gt;= 0) status = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
    if (status.code &gt;= 0 .and. !(aosArraySize &gt; 0)) {
        status.message = "<xsl:value-of select="@path"/> must be allocated.";
        status.code = HLI_ERR;
    }
  <xsl:if test="contains(@coordinate1,'/time')">
  if (homogeneousTime == IDS_TIME_MODE_HOMOGENEOUS ) {
      if(aosArraySize != timeSize) {
        status.message = "array size of <xsl:value-of select="@path"/> wrong dimension.";
        status.code = HLI_ERR;
      }
  }
  </xsl:if>
  <xsl:if test="not(contains(@coordinate1,'/time'))">
  if (status.code &gt;= 0) status = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;coordSize);
  if (status.code &gt;= 0 .and. !(coordSize &gt; 0)) {
    coordSize = 0;
    }
  if (aosArraySize != coordSize) {
    status.message = "array size of <xsl:value-of select="@path"/> wrong dimension. Must be the size of <xsl:value-of select="@coordinate1"/>.";
    status.code = HLI_ERR;
  }
  </xsl:if>
  </xsl:when>
  <xsl:otherwise>
    // warning <xsl:value-of select="@path_doc"/> coordinates consistency not verified (<xsl:value-of select="@coordinate1"/>)
  </xsl:otherwise>
    </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
