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

<xsl:variable name="AosRelativePath">
  <xsl:call-template name="printAosRelativePath"/>
</xsl:variable>

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
      field.fieldPath = &quot;<xsl:value-of select="$AosRelativePath"/>&quot;;
      <xsl:if test="ancestor::field[@data_type='struct_array']">
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
      </xsl:if>
      <xsl:choose>	
	<xsl:when test="@type='dynamic'"> <!-- Type 3 -->
	  if (homogeneousTime == IDS_TIME_MODE_HOMOGENEOUS) 
          field.timebasePath = "/time";
       	  else
	  field.timebasePath = &quot;<xsl:value-of select="$AosRelativePath"/>/time&quot;;
	</xsl:when>
  	<xsl:otherwise> <!-- Type 1 or 2 -->
	  field.timebasePath = "";
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@type='dynamic'">
	if (homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
      </xsl:if>
      aosCtx = ual_begin_arraystruct_action(ctx, field.fieldPath, field.timebasePath, &amp;aosArraySize);
      if (aosCtx &lt; 0) {
      ual_end_action(ctx);
      return aosCtx;
      }
      <xsl:if test="@type='dynamic'"> <!-- homogeneous_time != IDS_TIME_MODE_INDEPENDENT -->
	} else {
	aosCtx = 0;
	aosArraySize = 0; <!-- Create an empty dynamic AOS for time-independent IDSs -->
	}
      </xsl:if>
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
      status = <xsl:value-of select="concat($method_name,'_',@name,'_',generate-id(.))"/>(aosCtx, homogeneousTime);
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
      /* Finished processing array of structure <xsl:value-of select="@name"/> */
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
      status = <xsl:value-of select="concat($method_name,'_',@name,'_',generate-id(.))"/>(ctx, homogeneousTime);
      if (status &lt; 0) {
      <!-- ual_end_action(ctx) is taken care of in get_... -->
      return status;
      }
      /* Finished processing structure <xsl:value-of select="@name"/> */
      if (end_dataTree_action() &lt; 0) {
      ual_end_action(ctx);
      return -1;
      }
    </xsl:when>

  <!--========== Simple types ===========-->
    <xsl:when test="my:get_datatype(@data_type)='CHAR_DATA' or 
		    my:get_datatype(@data_type)='INTEGER_DATA' or 
		    my:get_datatype(@data_type)='DOUBLE_DATA' or 
		    my:get_datatype(@data_type)='COMPLEX_DATA'">
      field.fieldPath = &quot;<xsl:value-of select="$AosRelativePath"/>&quot;;
      <xsl:choose>
	<xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
	  if (homogeneousTime == IDS_TIME_MODE_HOMOGENEOUS) 
          field.timebasePath = "/time";
       	  else
	  field.timebasePath = &quot;<xsl:value-of select="@timebasepath"/>&quot;;
	</xsl:when>
	<xsl:otherwise>
	  field.timebasePath = "";
	</xsl:otherwise>
      </xsl:choose>
      field.datatype = <xsl:value-of select="my:get_datatype(@data_type)"/>;
      field.dim = <xsl:value-of select="my:get_dim(@data_type)"/>;
      <xsl:if test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
	if (homogeneousTime != IDS_TIME_MODE_INDEPENDENT) {
      </xsl:if>
      status = my_ual_read_data(&amp;action, &amp;field, &amp;data);
      <xsl:if test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])"> <!-- homogeneous_time != IDS_TIME_MODE_INDEPENDENT -->
	} else {
	status = mxArray_default_value(field.datatype, field.dim, &amp;data);
	}
      </xsl:if>
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
      /* PROBLEM : UNIDENTIFIED TYPE !!! */ <!-- for comment only -->
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
