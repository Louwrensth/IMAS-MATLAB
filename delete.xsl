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
<!--            delete IDS entry in database         -->
<!--=================================================-->

<xsl:template match="field" mode="DELETE">
<xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
    <xsl:when test="@data_type='structure'">
      status = delete_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(ctx);
      if (status != 0)
      return status;
    </xsl:when>
    <xsl:otherwise>
      fieldPath = "<xsl:value-of select="@path"/>";
      status = ual_delete_data(ctx, fieldPath);
      if (status != 0)
      {	
      ual_end_action(ctx);
      return status; 
      }
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
