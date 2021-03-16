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
<!--       put field of a time-dependent IDS         -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_SINGLE">
<xsl:param name="dynamic_only"/>
<xsl:variable name="methodName">
  <xsl:choose>
    <xsl:when test="$dynamic_only !='yes'" >
      <xsl:value-of select="'put'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'put_slice'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:if test="$dynamic_only !='yes' or descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
<xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
  <!--========== Array of structure ===========-->
  <!-- Type 1 arrays of structure, with potentially multiple time bases -->
  <!-- Type 2 arrays of structure -->
  <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:when test = "@data_type = 'struct_array'">
      <xsl:if test="$dynamic_only !='yes' and @type='dynamic'"> <!-- This could be put in the same statement as aosArraySize>0  -->
	if (homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
      </xsl:if>
      <xsl:call-template name="generateNodePath">
        <xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
  	  </xsl:call-template>
      <xsl:call-template name="generateTimebasePath">
        <xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
      </xsl:call-template>

      status = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
      if (status.code >= 0 &amp;&amp; aosArraySize &gt; 0) {
      status = ual_begin_arraystruct_action(ctx, field.fieldPath, field.timebasePath, &amp;aosArraySize, &amp;aosCtx);
      for (int i=0; i&lt;aosArraySize; i++) {
      if (status.code >= 0) status = iterate_dataTree_array(i);
      if (status.code >= 0) status = <xsl:value-of select="concat($methodName,'_',@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime);
      if (status.code >= 0) status = ual_iterate_over_arraystruct(aosCtx, 1);
      }
      /* Finished processing array of structure <xsl:value-of select="@name"/> */
      if (aosCtx > 0) {
      status_end = ual_end_action(aosCtx);
      if (status.code >= 0) status = status_end; /* Result of ual_end_action is only relevant if there was no error before */
      }
      }
      if (status.code >= 0) end_dataTree_array_action();
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in aos <xsl:value-of select="@path"/>",0);
      return status;
      }
      <xsl:if test="$dynamic_only !='yes' and @type='dynamic'"> <!-- homogeneous_time != IDS_TIME_MODE_INDEPENDENT -->
	}
      </xsl:if>
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      status = begin_dataTree_write("<xsl:value-of select="@name"/>", &amp;isEmpty);
      if (!isEmpty &amp;&amp; status.code >= 0) status = <xsl:value-of select="concat($methodName,'_',@name,'_',generate-id(.))"/>(ctx, homogeneousTime);
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
    <xsl:if test="$dynamic_only !='yes' and @type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])"> <!-- This could be put in the same statement as is_field_valid -->
      if (homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@path='ids_properties/version_put/data_dictionary'">
	data = mxCreateString("<xsl:value-of select="$DD_GIT_DESCRIBE"/>");
	status.code = 0;
      </xsl:when>
      <xsl:when test="@path='ids_properties/version_put/access_layer'">
	data = mxCreateString("<xsl:value-of select="$UAL_GIT_DESCRIBE"/>");
	status.code = 0;
      </xsl:when>
      <xsl:when test="@path='ids_properties/version_put/access_layer_language'">
	data = mxCreateString("<xsl:value-of select="'matlab (mex)'"/>");
	status.code = 0;
      </xsl:when>
      <xsl:otherwise>
	status = get_data_from_dataTree("<xsl:value-of select="@name"/>", (mxArray **) &amp;data);
      </xsl:otherwise>
    </xsl:choose>
    if (status.code >= 0 &amp;&amp; is_field_valid(<xsl:value-of select="concat(my:get_datatype(@data_type), ', ', my:get_dim(@data_type))"/>, data)) {
    <xsl:call-template name="generateNodePath">
        <xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
  	</xsl:call-template>
    <xsl:call-template name="generateTimebasePath">
  		<xsl:with-param name="ignore_nbc_change">1</xsl:with-param>
  	</xsl:call-template>
    field.datatype = <xsl:value-of select="my:get_datatype(@data_type)"/>;
    field.dim = <xsl:value-of select="my:get_dim(@data_type)"/>;
    status = my_ual_write_data(&amp;action, &amp;field, data);
    }
    <xsl:if test="starts-with(@path,'ids_properties/version_put/')">
      mxDestroyArray((mxArray *) data);
    </xsl:if>
    <xsl:if test="$dynamic_only !='yes' and @type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])"> <!-- homogeneous_time != IDS_TIME_MODE_INDEPENDENT -->
      }
    </xsl:if>
    /* Error handling */
    if (status.code &lt; 0) {
    addIdsPathInfoToErrMsg("\n ... in field <xsl:value-of select="@path"/>",0);
    return status;
    }
  </xsl:when>

  <!--========== Unknown type ===========-->
  <xsl:otherwise>
    <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="@data_type"/> !</xsl:message>
  </xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
