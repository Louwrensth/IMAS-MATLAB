<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
		xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
		xmlns:my="dummy">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<!--=================================================-->
<!--            get all fields from IDS              -->
<!--=================================================-->

<xsl:template match="field" mode="GET_SINGLE">

<xsl:variable name="AosRelativePath">
  <xsl:call-template name="printAosRelativePath"/>
</xsl:variable>

<xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
  <!--========== Array of structure ===========-->
  <!-- Type 1 arrays of structure, with potentially multiple time bases -->
  <!-- Type 2 arrays of structure -->
  <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:when test = "@data_type = 'struct_array'">
      strncpy(field.fieldPath, &quot;<xsl:value-of select="$AosRelativePath"/>&quot;, <xsl:value-of select="string-length($AosRelativePath)+1"/>);
      <xsl:if test="ancestor::field[@data_type='struct_array']">
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
      </xsl:if>
      <xsl:choose>	
	<xsl:when test="@type='dynamic'"> <!-- Type 3 -->
	  if (homogeneousTime) 
          strncpy(field.timebasePath, "/time", 6);
       	  else
	  strncpy(field.timebasePath, &quot;<xsl:value-of select="$AosRelativePath"/>/time&quot;, <xsl:value-of select="string-length($AosRelativePath)+6"/>);
	</xsl:when>
  	<xsl:otherwise> <!-- Type 1 or 2 -->
	  strncpy(field.timebasePath, "", 1);
	</xsl:otherwise>
      </xsl:choose>
      aosCtx = ual_begin_arraystruct_action(ctx, field.fieldPath, field.timebasePath, &amp;aosArraySize);
      if (aosCtx &lt; 0) {
      ual_end_action(ctx);
      return aosCtx;
      }
      if (begin_dataTree_array_read("<xsl:value-of select="@name"/>", aosArraySize) &lt; 0) {	
      ual_end_action(aosCtx);
      ual_end_action(ctx);
      return -1;
      }
      for (int i=0; i&lt;aosArraySize; i++) {
      if (iterate_dataTree_array(i) &lt; 0) {	
      ual_end_action(aosCtx);
      ual_end_action(ctx);
      return -1;
      }
      status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime);
      if (status &lt; 0) {
      <!-- ual_end_action(aosCtx) is taken care of in get_... -->
      ual_end_action(ctx);
      return status;
      }
      status = ual_iterate_over_arraystruct(aosCtx, 1);
      if (status &lt; 0) {	
      ual_end_action(aosCtx);
      ual_end_action(ctx);
      return status;
      }
      }
      status = ual_end_action(aosCtx);
      if (status &lt; 0) {
      ual_end_action(ctx);
      return status;
      }
      // Finished processing array of structure <xsl:value-of select="@name"/>
      if (end_dataTree_array_action() &lt; 0) {
      ual_end_action(ctx);
      return -1;
      }
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      if (begin_dataTree_read("<xsl:value-of select="@name"/>") &lt; 0) {
      ual_end_action(ctx);
      return -1;
      }
      status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(ctx, homogeneousTime);
      if (status &lt; 0) {
      <!-- ual_end_action(ctx) is taken care of in get_... -->
      return status;
      }
      // Finished processing structure <xsl:value-of select="@name"/>
      if (end_dataTree_action() &lt; 0) {
      ual_end_action(ctx);
      return -1;
      }
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="my:get_datatype(@data_type)='CHAR_DATA' or 
		    my:get_datatype(@data_type)='INTEGER_DATA' or 
		    my:get_datatype(@data_type)='DOUBLE_DATA'">
      strncpy(field.fieldPath, &quot;<xsl:value-of select="$AosRelativePath"/>&quot;, <xsl:value-of select="string-length($AosRelativePath)+1"/>);
      <xsl:choose>
	<xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
	  if (homogeneousTime == 1) 
          strncpy(field.timebasePath, "/time", 6);
       	  else
	  strncpy(field.timebasePath, &quot;<xsl:value-of select="@timebasepath"/>&quot;, <xsl:value-of select="string-length(@timebasepath)+1"/>);
	</xsl:when>
	<xsl:otherwise>
	  strncpy(field.timebasePath, "", 1);
	</xsl:otherwise>
      </xsl:choose>
      field.datatype = <xsl:value-of select="my:get_datatype(@data_type)"/>;
      field.dim = <xsl:value-of select="my:get_dim(@data_type)"/>;
      status = my_ual_read_data(&amp;action, &amp;field, &amp;data);
      if (status &lt; 0) {	
      ual_end_action(ctx);
      return status;
      }
      if (put_data_in_dataTree("<xsl:value-of select="@name"/>", data) &lt; 0) {	
      ual_end_action(ctx);
      return -1;
      }
      data=NULL;
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      // PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
