<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0"
		xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
		xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="yaslt exsl">
  <xsl:param name="imaspkgname"/>
  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="IDSs">
    <exsl:document href="tests/ids_rand.m" method="text">
      
      <xsl:text>function ids = ids_rand(idsName, slice)&#10;</xsl:text>
      <xsl:text>&#9;f = sprintf('rand_%s',idsName);&#10;</xsl:text>
      <xsl:text>&#9;ids = feval(f,slice);&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>
      
      <xsl:text>function t = rand_time(slice)&#10;</xsl:text>
      <xsl:text>&#9;t=[1.0:3.0].';&#10;</xsl:text>
      <xsl:text>&#9;if slice, t=t(1);end&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>function f = rand_float()&#10;</xsl:text>
      <xsl:text>&#9;f = randn(1);&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>function i = rand_integer()&#10;</xsl:text>
      <xsl:text>&#9;i = int32(randi([-2^30, 2^30],1));&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>function s = rand_string()&#10;</xsl:text>
      <xsl:text>&#9;s= '12 34 56 78 90';&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>function a = rand_array(type, ndim, dynamic, slice)&#10;</xsl:text>
      <xsl:text>&#9;s = 2.^(randi([0, 4], [1,ndim]));&#10;</xsl:text>
      <xsl:text>&#9;if (dynamic) s(end) = 3; end&#10;</xsl:text>
      <xsl:text>&#9;if (ndim == 1) s(2) = 1; end&#10;</xsl:text>
      <xsl:text>&#9;if (strcmp(type,'float'))&#10;</xsl:text>
      <xsl:text>&#9;&#9;a = randn(s);&#10;</xsl:text>
      <xsl:text>&#9;elseif (strcmp(type,'integer'))&#10;</xsl:text>
      <xsl:text>&#9;&#9;a = int32(randi([-2^30, 2^30],s));&#10;</xsl:text>
      <xsl:text>&#9;elseif (strcmp(type,'string'))&#10;</xsl:text>
      <xsl:text>&#9;&#9;assert(ndim == 1,'Only 1D array of strings are supported');&#10;</xsl:text>
      <xsl:text>&#9;&#9;a = char(arrayfun(@(i) sprintf('label%d',i),1:s(1),'UniformOutput',false));&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#9;if (dynamic &amp;&amp; slice)&#10;</xsl:text>
      <xsl:text>&#9;&#9;if (strcmp(type,'string') &amp;&amp; ndim == 1)&#10;</xsl:text>
      <xsl:text>&#9;&#9;&#9;a = a(1,:);&#10;</xsl:text>
      <xsl:text>&#9;&#9;else&#10;</xsl:text>
      <xsl:text>&#9;&#9;&#9;s = cell(1,ndim);&#10;</xsl:text>
      <xsl:text>&#9;&#9;&#9;s(1:ndim-1) = {':'};&#10;</xsl:text>
      <xsl:text>&#9;&#9;&#9;s(ndim)     = {1};&#10;</xsl:text>
      <xsl:text>&#9;&#9;&#9;a = subsref(a,substruct('()',s));&#10;</xsl:text>
      <xsl:text>&#9;&#9;end&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>
      
      <xsl:apply-templates select="child::IDS" mode="generate"/>
    </exsl:document>
    <exsl:document href="tests/imas_test.m" method="text">

      <xsl:text>function status = imas_test()&#10;</xsl:text>
      <xsl:text>&#9;disp('Starting Matlab HLI tests...')&#10;</xsl:text>
      <xsl:text>&#9;idx = imas_create('ids',9999,9999,0,0);&#10;</xsl:text>
      <xsl:text>&#9;list = IDS_list;&#10;</xsl:text>
      <xsl:text>&#9;for item = list.'&#10;</xsl:text>
      <xsl:text>&#9;&#9;disp(item{1});&#10;</xsl:text>
      <xsl:text>&#9;&#9;ids = ids_rand(item{1},false);&#10;</xsl:text>
      <xsl:text>&#9;&#9;ids_put(idx,item{1},0,ids);&#10;</xsl:text>
      <xsl:text>&#9;&#9;sdi = ids_get(idx,item{1},0);&#10;</xsl:text>
      <xsl:text>&#9;&#9;comparator(ids,sdi,item{1});&#10;</xsl:text>
      <xsl:text>&#9;&#9;ids = ids_rand(item{1},true);&#10;</xsl:text>
      <xsl:text>&#9;&#9;sdi = ids_get_slice(idx,item{1},0,0.0);&#10;</xsl:text>
      <xsl:text>&#9;&#9;comparator(ids,sdi,item{1});&#10;</xsl:text>
      <xsl:text>&#9;&#9;ids_put_non_timed(idx,item{1},0,ids);&#10;</xsl:text>
      <xsl:text>&#9;&#9;ids_put_slice(idx,item{1},0,ids);&#10;</xsl:text>
      <xsl:text>&#9;&#9;sdi = ids_get(idx,item{1},0);&#10;</xsl:text>
      <xsl:text>&#9;&#9;comparator(ids,sdi,item{1});&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#9;disp('Matlab HLI tests finished.')&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>
      
      <xsl:text>function occ = get_occurrence_str(idsName, occurrence)&#10;</xsl:text>
      <xsl:text>&#9;if occurrence == 0&#10;</xsl:text>
      <xsl:text>&#9;&#9;occ=idsName;&#10;</xsl:text>
      <xsl:text>&#9;else&#10;</xsl:text>
      <xsl:text>&#9;&#9;occ=sprintf('%s/%d',idsName, occurrence);&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>function idsx = init()&#10;</xsl:text>
      <xsl:text>&#9;disp('Initializing...')&#10;</xsl:text>
      <xsl:text>&#9;options = {};&#10;</xsl:text>
      <xsl:text>&#9;options.method = 'put';&#10;</xsl:text>
      <xsl:text>&#9;TESTSHOT = 9999;&#10;</xsl:text>
      <xsl:text>&#9;TESTRUN  = 9999;&#10;</xsl:text>
      <xsl:text>&#9;rng('default');&#10;</xsl:text>
      <xsl:text>&#9;if strcmp(options.method,'put')&#10;</xsl:text>
      <xsl:text>&#9;&#9;fname='create';&#10;</xsl:text>
      <xsl:text>&#9;else&#10;</xsl:text>
      <xsl:text>&#9;&#9;fname='open';&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#9;IMAS_MAJOR_VERSION = '3';&#10;</xsl:text>
      <xsl:text>&#9;IMASDB_PATH = sprintf('%s%s', getenv('HOME'), '/public/imasdb/test');&#10;</xsl:text>
      <xsl:text>&#9;if ~exist (IMASDB_PATH, 'dir')&#10;</xsl:text>
      <xsl:text>&#9;&#9;ME = MException('IMAS:noSuchPath','Directory %s not found',IMASDB_PATH);&#10;</xsl:text>
      <xsl:text>&#9;&#9;throw (ME);&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#9;if fname=='create'&#10;</xsl:text>
      <xsl:text>&#9;&#9;idsx=imas_create_env('ids',TESTSHOT,TESTRUN,0,0,getenv('USER'),'test',IMAS_MAJOR_VERSION);&#10;</xsl:text>
      <xsl:text>&#9;else&#10;</xsl:text>
      <xsl:text>&#9;&#9;idsx=imas_open_env('ids',TESTSHOT,TESTRUN,getenv('USER'),'test',IMAS_MAJOR_VERSION);&#10;</xsl:text>
      <xsl:text>&#9;end&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>function finish(idx)&#10;</xsl:text>
      <xsl:text>&#9;disp('Closing...')&#10;</xsl:text>
      <xsl:text>&#9;imas_close(idx);&#10;</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </exsl:document>
  </xsl:template>

  <!-- IDS put()-->
  <xsl:template match="IDS" mode="put">
    <xsl:text>function test_put_</xsl:text><xsl:value-of select="@name"/><xsl:text>(idx)&#10;</xsl:text>
    <xsl:text>&#9;message = ['Testing put() on ','</xsl:text><xsl:value-of select="@name"/><xsl:text>'];&#10;</xsl:text>
    <xsl:text>&#9;disp(message)&#10;</xsl:text>
    <xsl:text>&#9;rng(1);&#10;</xsl:text>
    <xsl:text>&#9;ids = ids_gen('</xsl:text><xsl:value-of select="@name"/><xsl:text>');&#10;</xsl:text>
    <xsl:text>&#9;for occurrence=1:(</xsl:text><xsl:value-of select="@maxoccur"/><xsl:text>)&#10;</xsl:text>
    <xsl:apply-templates select="field" mode="put"/>
    <xsl:text>&#9;&#9;ids_put(idx, get_occurrence_str('</xsl:text><xsl:value-of select="@name"/><xsl:text>', occurrence), ids);&#10;</xsl:text>
    <xsl:text>&#9;end&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- IDS get()-->
  <xsl:template match="IDS" mode="get">
    <xsl:text>function ids = test_get_</xsl:text><xsl:value-of select="@name"/><xsl:text>(idx)&#10;</xsl:text>
    <xsl:text>&#9;message = ['Testing get() on ','</xsl:text><xsl:value-of select="@name"/><xsl:text>'];&#10;</xsl:text>
    <xsl:text>&#9;disp(message)&#10;</xsl:text>
    <xsl:text>&#9;rng(1);&#10;</xsl:text>
    <xsl:text>&#9;for occurrence=1:(</xsl:text><xsl:value-of select="@maxoccur"/><xsl:text>)&#10;</xsl:text>
    <xsl:text>&#9;&#9;ids = ids_get(idx, get_occurrence_str('</xsl:text><xsl:value-of select="@name"/><xsl:text>', occurrence));&#10;</xsl:text>
    <xsl:apply-templates select="field" mode="get"/>
    <xsl:text>&#9;end&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- IDS putSlice()-->
  <xsl:template match="IDS" mode="putSlice">
    <xsl:text>function test_putSlice_</xsl:text><xsl:value-of select="@name"/><xsl:text>(idx)&#10;</xsl:text>
    <xsl:text>&#9;message = ['Testing putSlice() on ','</xsl:text><xsl:value-of select="@name"/><xsl:text>'];&#10;</xsl:text>
    <xsl:text>&#9;disp(message)&#10;</xsl:text>
    <xsl:text>&#9;rng(1);&#10;</xsl:text>
    <xsl:text>&#9;ids = ids_gen('</xsl:text><xsl:value-of select="@name"/><xsl:text>');&#10;</xsl:text>
    <xsl:text>&#9;for occurrence=1:(</xsl:text><xsl:value-of select="@maxoccur"/><xsl:text>)&#10;</xsl:text>
    <xsl:apply-templates select="field" mode="putSlice"/>
    <xsl:text>&#9;&#9;ids_put(idx, get_occurrence_str('</xsl:text><xsl:value-of select="@name"/><xsl:text>', occurrence), ids);&#10;</xsl:text>
    <xsl:text>&#9;&#9;ids_put_slice(idx, get_occurrence_str('</xsl:text><xsl:value-of select="@name"/><xsl:text>', occurrence), ids);&#10;</xsl:text>
    <xsl:text>&#9;end&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- IDS getSlice()-->
  <xsl:template match="IDS" mode="getSlice">
    <xsl:text>function ids = test_getSlice_</xsl:text><xsl:value-of select="@name"/><xsl:text>(idx)&#10;</xsl:text>
    <xsl:text>&#9;message = ['Testing getSlice() on ','</xsl:text><xsl:value-of select="@name"/><xsl:text>'];&#10;</xsl:text>
    <xsl:text>&#9;disp(message)&#10;</xsl:text>
    <xsl:text>&#9;rng(1);&#10;</xsl:text>
    <xsl:text>&#9;for occurrence=1:(</xsl:text><xsl:value-of select="@maxoccur"/><xsl:text>)&#10;</xsl:text>
    <xsl:text>&#9;&#9;interp=1; %closest sample&#10;</xsl:text>
    <xsl:text>&#9;&#9;ids = ids_get_slice(idx, get_occurrence_str('</xsl:text><xsl:value-of select="@name"/><xsl:text>', occurrence), 0.0, interp);&#10;</xsl:text>
    <xsl:apply-templates select="field" mode="getSlice"/>
    <xsl:text>&#9;end&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

<xsl:template match="IDS" mode="generate">
  <xsl:text>function ids = rand_</xsl:text><xsl:value-of select="@name"/><xsl:text>(slice);&#10;</xsl:text>
  <xsl:text>&#9;rng('default');&#10;</xsl:text>
  <xsl:apply-templates select="field" mode="generate">
    <xsl:with-param name="Aoslevel" select="1"/>
  </xsl:apply-templates>
  <xsl:text>&#10;</xsl:text>
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
      % PROBLEM : UNIDENTIFIED TYPE !!!
      % path_doc: <xsl:value-of select="@path_doc"/>
      % data_type: <xsl:value-of select="@data_type"/>
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
