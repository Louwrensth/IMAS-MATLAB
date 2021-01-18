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

<xsl:param name="DD_GIT_DESCRIBE" as="xs:string" required="yes"/>
<xsl:param name="UAL_GIT_DESCRIBE" as="xs:string" required="yes"/>

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
  if (!strcmp(name, "<xsl:value-of select="@name"/>")) {
  if (params.verbosity >= 4)
    mexPrintf("Matched <xsl:value-of select="@name"/>\n");
  <xsl:value-of select="$function_name"/> = &amp;<xsl:value-of select="concat($function_name,'_',@name)"/>;
  } else</xsl:template>

<!-- Generate node path. Take into account fields, AOSs or structures which have been possibly renamed. --> 
<xsl:template name ="generateNodePath">
  <xsl:param name="ignore_nbc_change"/>
  <xsl:choose>
    <xsl:when test="$ignore_nbc_change=1 or (not(ancestor::field[@change_nbc_version]) and not(@change_nbc_version))">
      <xsl:choose>
	<xsl:when test="ancestor::field[@data_type='struct_array']">
	  <xsl:variable name="AoSPath" select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	  <xsl:variable name="elementPath" select="@path"/>
	  <xsl:text>strcpy(field.fieldPath,&quot;</xsl:text><xsl:value-of select="replace($elementPath,concat($AoSPath,'/'),'')"/>&quot;);
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>strcpy(field.fieldPath, &quot;</xsl:text><xsl:value-of select="@path"/>&quot;);
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="ancestor::field[@data_type='struct_array']">
	  <xsl:variable name="AoSPath" select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	  <xsl:variable name="elementPath" select="@path"/>
	  <xsl:text>if (taggedDataDictionaryVersion) {&#xA;</xsl:text> 
	  <xsl:text>getFieldRelativePath(field.fieldPath, ancestors_count, ancestors_names, ancestors_change_nbc_versions, ancestors_change_nbc_previous_names, ancestors_data_types, dataDictionaryVersion);&#xA;</xsl:text>
	  <xsl:text>&#032;}&#xA;</xsl:text>
      <xsl:text>else{&#xA;</xsl:text>
	  <xsl:text>strcpy(field.fieldPath,&quot;</xsl:text><xsl:value-of select="replace($elementPath,concat($AoSPath,'/'),'')"/>&quot;);
	  <xsl:text>}&#xA;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>if (taggedDataDictionaryVersion) {&#xA;</xsl:text> 
	  <xsl:text>getNodePath(field.fieldPath, ancestors_count, ancestors_names, ancestors_change_nbc_versions, ancestors_change_nbc_previous_names, dataDictionaryVersion, 0);&#xA;</xsl:text>
	  <xsl:text>&#032;}&#xA;</xsl:text>
      <xsl:text>else{&#xA;</xsl:text>
	  <xsl:text>strcpy(field.fieldPath, &quot;</xsl:text><xsl:value-of select="@path"/>&quot;);
	  <xsl:text>}&#xA;</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <!-- xsl:text>mexPrintf("field.fieldPath=%s\n", field.fieldPath);&#xA;</xsl:text -->
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

<!-- Generate timebase path. Take into account fields, AOSs or structures which have been possibly renamed. --> 
<xsl:template name ="generateTimebasePath">
  <xsl:param name="ignore_nbc_change"/>
  <xsl:choose>
    <xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
      <xsl:text>if (homogeneousTime == IDS_TIME_MODE_HOMOGENEOUS) {&#xA;</xsl:text> 
      <xsl:text>&#032;strcpy(field.timebasePath, "/time");&#xA;</xsl:text>
      <xsl:text>&#032;}&#xA;</xsl:text>
      <xsl:text>else{&#xA;</xsl:text>
      <xsl:choose>
	<xsl:when test="$ignore_nbc_change=1 or not(ancestor::field[@change_nbc_version] or @change_nbc_version)">
		<xsl:call-template name="generateTimebasePath_strcpy"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>if (taggedDataDictionaryVersion) {&#xA;</xsl:text> 
	  <xsl:text>&#032;getTimeBasePath(field.timebasePath, ancestors_count, ancestors_names, ancestors_change_nbc_versions, ancestors_change_nbc_previous_names, ancestors_data_types, dataDictionaryVersion);&#xA;</xsl:text>
	  <xsl:text>&#032;}&#xA;</xsl:text>
	  <xsl:text>else{&#xA;</xsl:text>
	  <xsl:call-template name="generateTimebasePath_strcpy"/>
	  <xsl:text>&#032;}&#xA;</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>strcpy(field.timebasePath,"");&#xA;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <!-- xsl:text>&#032;mexPrintf("field.timebasePath=%s\n", field.timebasePath);&#xA;</xsl:text -->
  
</xsl:template>

<xsl:template name ="generateTimebasePath_strcpy">
		<xsl:choose>
			<xsl:when test="@data_type='struct_array'">
				<xsl:text>&#032;strcpy(field.timebasePath, &quot;</xsl:text><xsl:value-of select="@path"/><xsl:text>/time&quot;);}&#xA;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#032;strcpy(field.timebasePath, &quot;</xsl:text><xsl:value-of select="@timebasepath"/><xsl:text>&quot;);}&#xA;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>	
	

<!-- Declare variables which contain data provided by the DD concerning fields, AOSs or structures which have been renamed -->
<xsl:template name ="declareAndAllocateNBCVariables">
  <xsl:variable name="level" select="count(ancestor::field[@data_type='struct_array' or @data_type='struct'])"/>
  <xsl:if test="ancestor::field[@change_nbc_version] or @change_nbc_version or count(descendant::field[count(ancestor::field[@data_type='struct_array' or @data_type='struct']) = $level and @change_nbc_version]) > 0">
    <xsl:text>&#xA;</xsl:text>     
    <xsl:text>char *ancestors_names[ANCESTORS_MAX_COUNT];&#xA;</xsl:text>
    <xsl:text>char *ancestors_data_types[ANCESTORS_MAX_COUNT];&#xA;</xsl:text>
    <xsl:text>char *ancestors_change_nbc_versions[ANCESTORS_MAX_COUNT];&#xA;</xsl:text>
    <xsl:text>char *ancestors_change_nbc_previous_names[ANCESTORS_MAX_COUNT];&#xA;</xsl:text>
    <xsl:text>int ancestor_index;&#xA;</xsl:text>
    <xsl:text>int ancestors_count = 0;&#xA;</xsl:text>
    <xsl:text>int i;&#xA;</xsl:text>
  
    <xsl:text>for (i = 0; i &lt; ANCESTORS_MAX_COUNT; i++) {&#xA;</xsl:text>
    <xsl:text>&#032;ancestors_names[i] = malloc(ANCESTOR_NAME_MAX_LENGTH);&#xA;</xsl:text>
    <xsl:text>&#032;ancestors_data_types[i] = malloc(ANCESTOR_TYPE_MAX_LENGTH);&#xA;</xsl:text>
    <xsl:text>&#032;ancestors_change_nbc_versions[i] = malloc(ANCESTORS_VERSIONS_MAX_LENGTH);&#xA;</xsl:text>
    <xsl:text>&#032;ancestors_change_nbc_previous_names[i] = malloc(ANCESTORS_PREVIOUS_NAMES_MAX_LENGTH);&#xA;</xsl:text>
  
    <xsl:text>}&#xA;</xsl:text>
  </xsl:if>
  <xsl:text>field.fieldPath = malloc(IMAS_PATH_MAX_LENGTH);&#xA;</xsl:text>
  <xsl:text>field.timebasePath = malloc(IMAS_PATH_MAX_LENGTH);&#xA;</xsl:text>
  <xsl:text>&#xA;</xsl:text> 
</xsl:template>

<!--Fill variables which contain data provided by the DD concerning field, AOS or structure renaming-->
<xsl:template name ="setNBCVariables">
  <xsl:choose>
    <xsl:when test="ancestor::field[@change_nbc_version] or @change_nbc_version">
      <xsl:text>ancestor_index = 0;&#xA;</xsl:text>
      <xsl:for-each select="ancestor::field[@data_type='struct_array' or @data_type='structure']">
        <xsl:variable name="selected_name" select="@name"/>
        <xsl:variable name="selected_data_type" select="@data_type"/>
        <xsl:variable name="selected_change_nbc_version" select="@change_nbc_version"/>
        <xsl:variable name="selected_change_previous_name" select="@change_nbc_previous_name"/>
    	<xsl:text>strcpy(ancestors_names[ancestor_index], &quot;</xsl:text><xsl:value-of select="$selected_name"/><xsl:text>&quot;);&#xA;</xsl:text>
    	<xsl:text>strcpy(ancestors_data_types[ancestor_index], &quot;</xsl:text><xsl:value-of select="$selected_data_type"/><xsl:text>&quot;);&#xA;</xsl:text>
    	<xsl:text>strcpy(ancestors_change_nbc_versions[ancestor_index], &quot;</xsl:text><xsl:value-of select="$selected_change_nbc_version"/><xsl:text>&quot;);&#xA;</xsl:text>
  	<xsl:text>strcpy(ancestors_change_nbc_previous_names[ancestor_index], &quot;</xsl:text><xsl:value-of select="$selected_change_previous_name"/><xsl:text>&quot;);&#xA;</xsl:text>
  	<xsl:text>ancestor_index++;&#xA;</xsl:text>
      </xsl:for-each>
      <xsl:text>strcpy(ancestors_names[ancestor_index], &quot;</xsl:text><xsl:value-of select="@name"/><xsl:text>&quot;);&#xA;</xsl:text>
      <xsl:text>strcpy(ancestors_data_types[ancestor_index], &quot;</xsl:text><xsl:value-of select="@data_type"/><xsl:text>&quot;);&#xA;</xsl:text>
      <xsl:text>strcpy(ancestors_change_nbc_versions[ancestor_index], &quot;</xsl:text><xsl:value-of select="@change_nbc_version"/><xsl:text>&quot;);&#xA;</xsl:text>
      <xsl:text>strcpy(ancestors_change_nbc_previous_names[ancestor_index], &quot;</xsl:text><xsl:value-of select="@change_nbc_previous_name"/><xsl:text>&quot;);&#xA;</xsl:text>
      <xsl:text>ancestor_index++;&#xA;</xsl:text>
      <xsl:text>ancestors_count = ancestor_index;&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!--Free variables which contain data provided by the DD concerning field, AOS or structure renaming-->
<xsl:template name ="freeNBCVariables">
  <xsl:variable name="level" select="count(ancestor::field[@data_type='struct_array' or @data_type='struct'])"/>
  <xsl:if test="ancestor::field[@change_nbc_version] or @change_nbc_version or count(descendant::field[count(ancestor::field[@data_type='struct_array' or @data_type='struct']) = $level and @change_nbc_version]) > 0">
    <xsl:text>for (i = 0; i &lt; ANCESTORS_MAX_COUNT; i++) {&#xA;</xsl:text>
    <xsl:text>&#032;free(ancestors_names[i]);&#xA;</xsl:text>
    <xsl:text>&#032;free(ancestors_data_types[i]);&#xA;</xsl:text>
    <xsl:text>&#032;free(ancestors_change_nbc_versions[i]);&#xA;</xsl:text>
    <xsl:text>&#032;free(ancestors_change_nbc_previous_names[i]);&#xA;</xsl:text>
    <xsl:text>}&#xA;</xsl:text>
  </xsl:if>
  <xsl:text>&#032;free(field.fieldPath);&#xA;</xsl:text>
  <xsl:text>&#032;free(field.timebasePath);&#xA;</xsl:text>
</xsl:template>

<!--Documentation for a single field-->
<xsl:template name = "COMMENT_FIELD">
  <xsl:text>&#xA;</xsl:text>
  <xsl:text>/*-----------------------------------------------------------------------------------------&#xA;</xsl:text>
  <xsl:text>    </xsl:text><xsl:value-of select="@name"/>:<xsl:value-of select="@path"/>:<xsl:value-of select="@data_type"/>:<xsl:value-of select="@type"/>:<xsl:text>&#xA;</xsl:text>

  <xsl:if test="@data_type='struct_array'">
    <xsl:text>  -----------------------------------------------------------------------------------------&#xA;</xsl:text>

    <xsl:if test="@type='dynamic' and @maxoccur='unbounded'">
      <xsl:text>    ARRAY of TYPE 3 &#xA;</xsl:text>
    </xsl:if>

    <xsl:if test="(not(@type) or @type!='dynamic') and @maxoccur='unbounded'">
      <xsl:text>    ARRAY of TYPE 2  &#xA;</xsl:text>
    </xsl:if>

    <xsl:if test="@maxoccur!='unbounded'">
      <xsl:text>    ARRAY of TYPE 1  &#xA;</xsl:text>
    </xsl:if>
  </xsl:if>

  <xsl:text>  -----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
</xsl:template>

<xsl:function name="my:get_datatype" as="xs:string">
  <xsl:param name="data_type" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$data_type='str_type' or $data_type='STR_0D' or
		    $data_type='str_1d_type' or $data_type='STR_1D'">
      <xsl:sequence select="'CHAR_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='int_type' or $data_type='INT_0D' or
		    $data_type='int_1d_type' or $data_type='INT_1D' or
		    $data_type='INT_2D' or $data_type='INT_3D' or
		    $data_type='INT_4D' or $data_type='INT_5D' or
		    $data_type='INT_6D'">
      <xsl:sequence select="'INTEGER_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='flt_type' or $data_type='FLT_0D' or
		    $data_type='flt_1d_type' or $data_type='FLT_1D' or
		    $data_type='FLT_2D' or $data_type='FLT_3D' or
		    $data_type='FLT_4D' or $data_type='FLT_5D' or
		    $data_type='FLT_6D'">
      <xsl:sequence select="'DOUBLE_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='cpx_type' or $data_type='CPX_0D' or
		    $data_type='cpx_1d_type' or $data_type='CPX_1D' or
		    $data_type='CPX_2D' or $data_type='CPX_3D' or
		    $data_type='CPX_4D' or $data_type='CPX_5D' or
		    $data_type='CPX_6D'">
      <xsl:sequence select="'COMPLEX_DATA'"/>
    </xsl:when>
    <xsl:when test="$data_type='structure' or $data_type='struct_array'">
      <xsl:sequence select="'UNKNOWN_DATA'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="$data_type"/> !</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="my:get_dim" as="xs:integer">
  <xsl:param name="data_type" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$data_type='flt_type' or $data_type='FLT_0D' or
		    $data_type='int_type' or $data_type='INT_0D' or
		    $data_type='cpx_type' or $data_type='CPX_0D'">
      <xsl:sequence select="0"/>
    </xsl:when>
    <xsl:when test="$data_type='str_type' or $data_type='STR_0D' or
		    $data_type='flt_1d_type' or $data_type='FLT_1D' or
		    $data_type='int_1d_type' or $data_type='INT_1D' or
		    $data_type='cpx_1d_type' or $data_type='CPX_1D'">
      <xsl:sequence select="1"/>
    </xsl:when>
    <xsl:when test="$data_type='str_1d_type' or $data_type='STR_1D' or
		    $data_type='FLT_2D' or $data_type='INT_2D' or $data_type='CPX_2D'">
      <xsl:sequence select="2"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_3D' or $data_type='INT_3D' or $data_type='CPX_3D'">
      <xsl:sequence select="3"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_4D' or $data_type='INT_4D' or $data_type='CPX_4D'">
      <xsl:sequence select="4"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_5D' or $data_type='INT_5D' or $data_type='CPX_5D'">
      <xsl:sequence select="5"/>
    </xsl:when>
    <xsl:when test="$data_type='FLT_6D' or $data_type='INT_6D' or $data_type='CPX_6D'">
      <xsl:sequence select="6"/>
    </xsl:when>
    <xsl:when test="$data_type='structure' or $data_type='struct_array'">
      <xsl:sequence select="xs:integer(-1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="$data_type"/> !</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


</xsl:stylesheet>
