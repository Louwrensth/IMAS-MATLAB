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
<!--            get all fields from IDS              -->
<!--=================================================-->

<xsl:template match="field" mode="GET_SINGLE">
  <xsl:param name="slice"/>
  <xsl:param name="ids_type"/>

<xsl:variable name="method_name">
  <xsl:choose>
    <xsl:when test="$slice='yes'">get_slice</xsl:when>
    <xsl:otherwise>get</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
  <!--========== Array of structure ===========-->
  <!-- Type 1 arrays of structure, with potentially multiple time bases -->
  <!-- Type 2 arrays of structure -->
  <!-- Type 3 arrays of structure, with a unique time base -->
  
    <xsl:when test = "@data_type = 'struct_array'">
      <xsl:call-template name="setNBCVariables"/>
      <xsl:call-template name="generateNodePath">
        <xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="generateTimebasePath">
        <xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
        <xsl:with-param name="ids_type"><xsl:value-of select="$ids_type"/></xsl:with-param>
      </xsl:call-template>
      aosCtx = aosArraySize = 0; /* Initialize to avoid reusing old values in case of errors */
      <xsl:if test="@type='dynamic'">
	if (homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
      </xsl:if>
      status = al_begin_arraystruct_action(ctx, field.fieldPath, field.timebasePath, &amp;aosArraySize, &amp;aosCtx);      <xsl:if test="@type='dynamic'"> <!-- homogeneous_time != IDS_TIME_MODE_INDEPENDENT -->
	} else {
	status.code = aosCtx = 0;
	aosArraySize = 0; <!-- Create an empty dynamic AOS for time-independent IDSs -->
	}
      </xsl:if>
      if (status.code >= 0) status = begin_dataTree_array_read("<xsl:value-of select="@name"/>", aosArraySize);
      for (int i=0; i&lt;aosArraySize; i++) {
      if (status.code >= 0) status = iterate_dataTree_array(i);
	  if (status.code >= 0) status = <xsl:value-of select="concat($method_name,'_',@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime, dataDictionaryVersion, taggedDataDictionaryVersion);
      if (status.code >= 0) status = al_iterate_over_arraystruct(aosCtx, 1);
      }
      /* Finished processing array of structure <xsl:value-of select="@name"/> */
      if (aosCtx > 0) {
      status_end = al_end_action(aosCtx);
      if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
      }
      if (status.code >= 0) status = end_dataTree_array_action();
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in aos <xsl:value-of select="@path"/>",0);
      return status;
      }
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      status = begin_dataTree_read("<xsl:value-of select="@name"/>");
	  if (status.code >= 0) status = <xsl:value-of select="concat($method_name,'_',@name,'_',generate-id(.))"/>(ctx, homogeneousTime, dataDictionaryVersion, taggedDataDictionaryVersion);
      /* Finished processing structure <xsl:value-of select="@name"/> */
      if (status.code >= 0) status = end_dataTree_action();
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in structure <xsl:value-of select="@path"/>",0);
      return status;
      }
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="my:get_datatype(@data_type)='CHAR_DATA' or 
		    my:get_datatype(@data_type)='INTEGER_DATA' or 
		    my:get_datatype(@data_type)='DOUBLE_DATA' or 
		    my:get_datatype(@data_type)='COMPLEX_DATA'">
		    
      <xsl:call-template name="setNBCVariables"/>
      <xsl:call-template name="generateNodePath">
        <xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
  	  </xsl:call-template>
      <xsl:call-template name="generateTimebasePath">
  		<xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
      <xsl:with-param name="ids_type"><xsl:value-of select="$ids_type"/></xsl:with-param>
  	  </xsl:call-template>
      field.datatype = <xsl:value-of select="my:get_datatype(@data_type)"/>;
      field.dim = <xsl:value-of select="my:get_dim(@data_type)"/>;
      <xsl:if test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
	if (homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
      </xsl:if>
      status = my_al_read_data(&amp;action, &amp;field, &amp;data);
      <xsl:if test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])"> <!-- homogeneous_time != IDS_TIME_MODE_INDEPENDENT -->
	} else {
	status = mxArray_default_value(field.datatype, field.dim, &amp;data);
	}
      </xsl:if>
      if (status.code >= 0) put_data_in_dataTree("<xsl:value-of select="@name"/>", data);
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in field <xsl:value-of select="@path"/>",0);
      return status;
      }
      data=NULL;
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="@data_type"/> !</xsl:message>
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
