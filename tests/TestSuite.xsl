<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<xsl:template match="IDSs">
  <xsl:apply-templates select="child::IDS" mode="generate"/>
</xsl:template>

<xsl:template match="IDS" mode="generate">
  <xsl:result-document href="private/rand_{@name}.m" standalone="yes" method="text">
  function ids = rand_<xsl:value-of select="@name"/>(slice);
  rng('default');
  <xsl:apply-templates select="field" mode="generate">
    <xsl:with-param name="Aoslevel" select="1"/>
  </xsl:apply-templates>
end
</xsl:result-document>

</xsl:template>

<xsl:template match="field" mode="generate">
<xsl:param name="path"/>
<xsl:param name="type3"/>
<xsl:param name="Aoslevel"/>

<xsl:param name="currentpath">
  <xsl:choose>
    <xsl:when test="$path"><xsl:value-of select="concat($path,'.',@name)"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="concat('ids.',@name)"/></xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="dynamic">
  <xsl:choose>
    <xsl:when test="not($type3) and @type='dynamic'">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:choose>
    <!-- Type 1 arrays of structure -->
    <xsl:when test = "@data_type = 'struct_array' and @maxoccur!='unbounded' ">
      n<xsl:value-of select="$Aoslevel"/>=min(randi([1,4],1),<xsl:value-of select="@maxoccur"/>);
      <xsl:value-of select="$currentpath"/>=cell(n<xsl:value-of select="$Aoslevel"/>,1);
      for i<xsl:value-of select="$Aoslevel"/>=1:n<xsl:value-of select="$Aoslevel"/>,
      <xsl:apply-templates select="field" mode="generate">
	<xsl:with-param name="path" select="concat($currentpath,'{i',$Aoslevel,'}')"/>
	<xsl:with-param name="type3" select="$type3"/>
	<xsl:with-param name="Aoslevel" select="$Aoslevel+1"/>
      </xsl:apply-templates>
      end
    </xsl:when>
    <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
      ntime=3;
      <xsl:value-of select="$currentpath"/>=cell(ntime,1);
      for itime=1:ntime
      <xsl:apply-templates select="field" mode="generate">
	<xsl:with-param name="path" select="concat($currentpath,'{itime}')"/>
	<xsl:with-param name="type3" select="1"/>
	<xsl:with-param name="Aoslevel" select="$Aoslevel+1"/>
      </xsl:apply-templates>
      end
      if slice
	<xsl:value-of select="$currentpath"/> = <xsl:value-of select="$currentpath"/>(1);
      end
    </xsl:when>
    <!-- Type 2 arrays of structure -->
    <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded'">
      n<xsl:value-of select="$Aoslevel"/>=randi([1,4],1);
      <xsl:value-of select="$currentpath"/>=cell(n<xsl:value-of select="$Aoslevel"/>,1);
      for i<xsl:value-of select="$Aoslevel"/>=1:n<xsl:value-of select="$Aoslevel"/>,
      <xsl:apply-templates select="field" mode="generate">
	<xsl:with-param name="path" select="concat($currentpath,'{i',$Aoslevel,'}')"/>
	<xsl:with-param name="type3" select="$type3"/>
	<xsl:with-param name="Aoslevel" select="$Aoslevel+1"/>
      </xsl:apply-templates>
      end
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      <xsl:apply-templates select="field" mode="generate">
	<xsl:with-param name="path" select="$currentpath"/>
	<xsl:with-param name="type3" select="$type3"/>
	<xsl:with-param name="Aoslevel" select="$Aoslevel"/>
      </xsl:apply-templates>
    </xsl:when>

  <!--========== Simple types ===========-->
  
    <xsl:when test = "@name='homogeneous_time' and (@data_type='int_type' or @data_type='INT_0D')">
      <xsl:value-of select="$currentpath"/> = int32(1);
    </xsl:when>
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      <xsl:value-of select="$currentpath"/> = rand_integer();
    </xsl:when>
  
    <xsl:when test = "@name='time' and (@data_type='flt_type' or @data_type='FLT_0D')">
      time = rand_time(false);
      <xsl:value-of select="$currentpath"/> = time(itime);
    </xsl:when>
  
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      <xsl:value-of select="$currentpath"/> = rand_float();
    </xsl:when>
  
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      <xsl:value-of select="$currentpath"/> = rand_string();
    </xsl:when>
	
  <!--========== Vectors ===========-->
    <xsl:when test = "@data_type='int_1d_type' or @data_type='INT_1D'">
      <xsl:value-of select="$currentpath"/> = rand_array('integer', 1, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>
  
    <xsl:when test = "@name='time' and (@data_type='flt_1d_type' or @data_type='FLT_1D')">
      <xsl:value-of select="$currentpath"/> = rand_time(slice);
    </xsl:when>
  
    <xsl:when test = "@data_type='flt_1d_type' or @data_type='FLT_1D'">
      <xsl:value-of select="$currentpath"/> = rand_array('float', 1, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>
      
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      <xsl:value-of select="$currentpath"/> = rand_array('string', 1, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

  <!--========== Matrices ===========-->
    <xsl:when test="@data_type='INT_2D'">
      <xsl:value-of select="$currentpath"/> = rand_array('integer', 2, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

    <xsl:when test="@data_type='FLT_2D'">
      <xsl:value-of select="$currentpath"/> = rand_array('float', 2, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

  <!--========== 3D arrays ===========-->
    <xsl:when test="@data_type='INT_3D'">
      <xsl:value-of select="$currentpath"/> = rand_array('integer', 3, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

    <xsl:when test="@data_type='FLT_3D'">
      <xsl:value-of select="$currentpath"/> = rand_array('float', 3, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

  <!--========== 4D arrays ===========-->
    <xsl:when test="@data_type='INT_4D'">
      <xsl:value-of select="$currentpath"/> = rand_array('integer', 4, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

    <xsl:when test="@data_type='FLT_4D'">
      <xsl:value-of select="$currentpath"/> = rand_array('float', 4, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

  <!--========== 5D arrays ===========-->
    <xsl:when test="@data_type='INT_5D'">
      <xsl:value-of select="$currentpath"/> = rand_array('integer', 5, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

    <xsl:when test="@data_type='FLT_5D'">
      <xsl:value-of select="$currentpath"/> = rand_array('float', 5, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

  <!--========== 6D arrays ===========-->
    <xsl:when test="@data_type='INT_6D'">
      <xsl:value-of select="$currentpath"/> = rand_array('integer', 6, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

    <xsl:when test="@data_type='FLT_6D'">
      <xsl:value-of select="$currentpath"/> = rand_array('float', 6, <xsl:value-of select="$dynamic"/>, slice);
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type!
      TYPE: <xsl:value-of select="@data_type"/>
      PATH: <xsl:value-of select="@path_doc"/></xsl:message>
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
