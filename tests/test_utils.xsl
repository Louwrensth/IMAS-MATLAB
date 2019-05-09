<!--  Generating  Matlab code structs from IDSDefs.xml YB.MA Feb 2008 -->
<!-- -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:my="dummy"
    version="2.0">
  <!-- -->
  <xsl:output method="text"/>

  <xsl:template match = "/IDSs">
    <xsl:result-document href="IDS_list.h" method="text">
      const char * IDS_list[] = {
      <xsl:for-each select = "IDS">"<xsl:value-of select = "@name"/>",
      </xsl:for-each>};
      int nIDS = <xsl:value-of select="count(IDS)"/>;
    </xsl:result-document>

    <xsl:result-document href="IDS_list.f90" method="text">
      module IDS_names_mod
      
      integer :: nIDS = <xsl:value-of select="count(IDS)"/>
      character (len=132), dimension(<xsl:value-of select="count(IDS)+1"/>) :: IDS_names = [character (len=132) :: &amp;
      <xsl:for-each select = "IDS">&amp;'<xsl:value-of select = "@name"/>',&amp;
      </xsl:for-each>&amp;'']

      end module IDS_names_mod

    </xsl:result-document>

    <xsl:result-document href="IDS_test_f90.f90" method="text">
      subroutine check_IDS_name(IDSname, bool)
      character(len = 132) :: IDSname
      logical              :: bool
      <xsl:for-each select = "IDS">if (IDSname.eq.'<xsl:value-of select = "@name"/>') then
      bool = .true.
      return
      endif
      </xsl:for-each>
      bool = .false.
      end subroutine check_IDS_name

      subroutine test(IDSname, idxr, idxw, resultr, resultw, ntime)
      character(len = 132) :: IDSname
      integer              :: idxr
      integer              :: idxw
      real                 :: resultr
      real                 :: resultw
      <xsl:for-each select = "IDS">if (IDSname.eq.'<xsl:value-of select = "@name"/>') then
      call test_<xsl:value-of select = "@name"/>(idxr, idxw, resultr, resultw, ntime)
      return
      endif
      </xsl:for-each>
      result=-1
      end subroutine test

      <xsl:for-each select = "IDS">
	subroutine test_<xsl:value-of select = "@name"/>(idxr, idxw, resultr, resultw, ntime)

	use ids_schemas
	use ids_routines

	integer              :: idxr
	integer              :: idxw
	real                 :: resultr
	real                 :: resultw
	character(len = 132) :: IDSname = '<xsl:value-of select = "@name"/>'
	type (ids_<xsl:value-of select = "@name"/>) :: ids
	
	integer :: count_s, count_rate, count_max
	integer :: count_e

	call system_clock(count_s,count_rate,count_max)
	call ids_get(idxr,IDSname,ids)
	call system_clock(count_e,count_rate,count_max)
	resultr = real(count_e - count_s)/real(count_rate)*1000

        call system_clock(count_s,count_rate,count_max)
        call ids_put(idxw,IDSname,ids)
        call system_clock(count_e,count_rate,count_max)
        resultw = real(count_e - count_s)/real(count_rate)*1000
	
	ntime = size(ids%time)

	end subroutine test_<xsl:value-of select = "@name"/>

      </xsl:for-each>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
