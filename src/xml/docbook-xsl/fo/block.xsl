<?xml version='1.0'?>
<xsl:stylesheet exclude-result-prefixes="d"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version='1.0'>

<!-- ********************************************************************
     $Id: block.xsl 9389 2012-06-02 19:02:39Z bobstayton $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:template match="d:blockinfo|d:info">
  <!-- suppress -->
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="block.object">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:para">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="para.properties">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="d:simpara">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="normal.para.spacing">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="d:formalpara">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="normal.para.spacing">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- Only use title from info -->
<xsl:template match="d:formalpara/d:info">
  <xsl:apply-templates select="d:title"/>
</xsl:template>

<xsl:template match="d:formalpara/d:title|d:formalpara/d:info/d:title">
  <xsl:variable name="titleStr">
      <xsl:apply-templates/>
  </xsl:variable>
  <xsl:variable name="lastChar">
    <xsl:if test="$titleStr != ''">
      <xsl:value-of select="substring($titleStr,string-length($titleStr),1)"/>
    </xsl:if>
  </xsl:variable>

  <fo:inline font-weight="bold"
             keep-with-next.within-line="always"
             padding-end="1em">
    <xsl:copy-of select="$titleStr"/>
    <xsl:if test="$lastChar != ''
                  and not(contains($runinhead.title.end.punct, $lastChar))">
      <xsl:value-of select="$runinhead.default.title.end.punct"/>
    </xsl:if>
    <xsl:text>&#160;</xsl:text>
  </fo:inline>
</xsl:template>

<xsl:template match="d:formalpara/d:para">
  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:blockquote">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="blockquote.properties">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <fo:block>
      <xsl:if test="d:title|d:info/d:title">
        <fo:block xsl:use-attribute-sets="formal.title.properties">
          <xsl:apply-templates select="." mode="object.title.markup"/>
        </fo:block>
      </xsl:if>
      <xsl:apply-templates select="*[local-name(.) != 'title'
                                   and local-name(.) != 'attribution']"/>
    </fo:block>
    <xsl:if test="d:attribution">
      <fo:block text-align="right">
        <!-- mdash -->
        <xsl:text>&#x2014;</xsl:text>
        <xsl:apply-templates select="d:attribution"/>
      </fo:block>
    </xsl:if>
  </fo:block>
</xsl:template>

<!-- Use an em dash per Chicago Manual of Style and https://sourceforge.net/tracker/index.php?func=detail&aid=2793878&group_id=21935&atid=373747 -->
<xsl:template match="d:epigraph">
  <fo:block>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates select="d:para|d:simpara|d:formalpara|d:literallayout"/>
    <xsl:if test="d:attribution">
      <fo:inline>
        <xsl:text>&#x2014;</xsl:text>
        <xsl:apply-templates select="d:attribution"/>
      </fo:inline>
    </xsl:if>
  </fo:block>
</xsl:template>

<xsl:template match="d:attribution">
  <fo:inline><xsl:apply-templates/></fo:inline>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="floater">
  <xsl:param name="position" select="'none'"/>
  <xsl:param name="clear" select="'both'"/>
  <xsl:param name="width"/>
  <xsl:param name="content"/>
  <xsl:param name="start.indent">0pt</xsl:param>
  <xsl:param name="end.indent">0pt</xsl:param>

  <xsl:choose>
    <xsl:when test="not($fop.extensions = 0)">
      <!-- fop 0.20.5 does not support floats -->
      <xsl:copy-of select="$content"/>
    </xsl:when>
    <xsl:when test="$position = 'none'">
      <xsl:copy-of select="$content"/>
    </xsl:when>
    <xsl:when test="$position = 'before'">
      <fo:float float="before">
        <xsl:copy-of select="$content"/>
      </fo:float>
    </xsl:when>
    <xsl:when test="$position = 'left' or
                    $position = 'start' or
                    $position = 'right' or
                    $position = 'end' or
                    $position = 'inside' or
                    $position = 'outside'">
      <xsl:variable name="float">
        <fo:float float="{$position}"
                  clear="{$clear}">
          <fo:block-container 
                    start-indent="{$start.indent}"
                    end-indent="{$end.indent}">
            <xsl:if test="$width != ''">
              <xsl:attribute name="inline-progression-dimension">
                <xsl:value-of select="$width"/>
              </xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:copy-of select="$content"/>
            </fo:block>
          </fo:block-container>
        </fo:float>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$axf.extensions != 0 and self::d:sidebar">
          <fo:block xsl:use-attribute-sets="normal.para.spacing"
                    space-after="0pt"
                    space-after.precedence="force"
                    start-indent="0pt" end-indent="0pt">
            <xsl:copy-of select="$float"/>
          </fo:block>
        </xsl:when>
        <xsl:when test="$axf.extensions != 0 and 
                        ($position = 'left' or $position = 'start')">
          <fo:float float="{$position}"
                    clear="{$clear}">
            <fo:block-container 
                      inline-progression-dimension=".001mm"
                      end-indent="{$start.indent} + {$width} + {$end.indent}">
              <xsl:attribute name="start-indent">
                <xsl:choose>
                  <xsl:when test="ancestor::d:para">
                    <!-- Special case for handling inline floats
                         in Antenna House-->
                    <xsl:value-of select="concat('-', $body.start.indent)"/>
                  </xsl:when>
                  <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <fo:block start-indent="{$start.indent}"
                        end-indent="-{$start.indent} - {$width}">
                <xsl:copy-of select="$content"/>
              </fo:block>
            </fo:block-container>
          </fo:float>

        </xsl:when>
        <xsl:when test="$axf.extensions != 0 and 
                        ($position = 'right' or $position = 'end')">
          <!-- Special case for handling inline floats in Antenna House-->
          <fo:float float="{$position}"
                    clear="{$clear}">
            <fo:block-container 
                      inline-progression-dimension=".001mm"
                      end-indent="-{$body.end.indent}"
                      start-indent="{$start.indent} + {$width} + {$end.indent}">
              <fo:block end-indent="{$end.indent}"
                        start-indent="-{$end.indent} - {$width}">
                <xsl:copy-of select="$content"/>
              </fo:block>
            </fo:block-container>
          </fo:float>

        </xsl:when>
        <xsl:when test="$xep.extensions != 0 and self::d:sidebar">
          <!-- float needs some space above  to line up with following para -->
          <fo:block xsl:use-attribute-sets="normal.para.spacing">
            <xsl:copy-of select="$float"/>
          </fo:block>
        </xsl:when>
        <xsl:when test="$xep.extensions != 0">
          <xsl:copy-of select="$float"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$float"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:sidebar" name="sidebar">
  <!-- Also does margin notes -->
  <xsl:variable name="pi-type">
    <xsl:call-template name="pi.dbfo_float-type"/>
  </xsl:variable>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$pi-type = 'margin.note'">
      <xsl:call-template name="margin.note"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="content">
        <fo:block xsl:use-attribute-sets="sidebar.properties"
                  id="{$id}">
          <xsl:call-template name="sidebar.titlepage"/>
          <xsl:apply-templates select="node()[not(self::d:title) and
                                         not(self::d:info) and
                                         not(self::d:sidebarinfo)]"/>
        </fo:block>
      </xsl:variable>

      <xsl:variable name="pi-width">
        <xsl:call-template name="pi.dbfo_sidebar-width"/>
      </xsl:variable>

      <xsl:variable name="position">
        <xsl:choose>
          <xsl:when test="$pi-type != ''">
            <xsl:value-of select="$pi-type"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$sidebar.float.type"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    
      <xsl:call-template name="floater">
        <xsl:with-param name="content" select="$content"/>
        <xsl:with-param name="position" select="$position"/>
        <xsl:with-param name="width">
          <xsl:choose>
            <xsl:when test="$pi-width != ''">
              <xsl:value-of select="$pi-width"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sidebar.float.width"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="start.indent">
          <xsl:choose>
            <xsl:when test="$position = 'start' or 
                            $position = 'left'">0pt</xsl:when>
            <xsl:when test="$position = 'end' or 
                            $position = 'right'">0.5em</xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="end.indent">
          <xsl:choose>
            <xsl:when test="$position = 'start' or 
                            $position = 'left'">0.5em</xsl:when>
            <xsl:when test="$position = 'end' or 
                            $position = 'right'">0pt</xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="d:sidebar/d:title|d:sidebarinfo|d:sidebar/d:info"/>

<xsl:template match="d:sidebar/d:title|d:sidebarinfo/d:title|d:sidebar/d:info/d:title"
              mode="titlepage.mode" priority="1">
  <fo:block xsl:use-attribute-sets="sidebar.title.properties">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- Turn off para space-before if sidebar starts with a para, not title -->
<xsl:template match="d:sidebar/*[1][self::d:para]">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="para.properties">
    <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>

</xsl:template>

<xsl:template name="margin.note">
  <xsl:param name="content">
    <fo:block xsl:use-attribute-sets="margin.note.properties">
      <xsl:if test="./d:title">
        <fo:block xsl:use-attribute-sets="margin.note.title.properties">
          <xsl:apply-templates select="./d:title" mode="margin.note.title.mode"/>
        </fo:block>
      </xsl:if>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:param>

  <xsl:variable name="pi-width">
    <xsl:call-template name="pi.dbfo_sidebar-width"/>
  </xsl:variable>

  <xsl:variable name="position" select="$margin.note.float.type"/>

  <xsl:call-template name="floater">
    <xsl:with-param name="content" select="$content"/>
    <xsl:with-param name="position" select="$position"/>
    <xsl:with-param name="width" >
      <xsl:choose>
        <xsl:when test="$pi-width != ''">
          <xsl:value-of select="$pi-width"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$margin.note.width"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="start.indent">
      <xsl:choose>
        <xsl:when test="$position = 'start' or 
                        $position = 'left'">0pt</xsl:when>
        <xsl:when test="$position = 'end' or 
                        $position = 'right'">0.5em</xsl:when>
        <xsl:otherwise>0pt</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="end.indent">
      <xsl:choose>
        <xsl:when test="$position = 'start' or 
                        $position = 'left'">0.5em</xsl:when>
        <xsl:when test="$position = 'end' or 
                        $position = 'right'">0pt</xsl:when>
        <xsl:otherwise>0pt</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:sidebar/d:title" mode="margin.note.title.mode">
  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:abstract">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="abstract.properties">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="d:abstract/d:title|d:abstract/d:info/d:title">
  <fo:block xsl:use-attribute-sets="abstract.title.properties">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:msgset">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:msgentry">
  <xsl:call-template name="block.object"/>
</xsl:template>

<xsl:template match="d:simplemsgentry">
  <xsl:call-template name="block.object"/>
</xsl:template>

<xsl:template match="d:msg">
  <xsl:call-template name="block.object"/>
</xsl:template>

<xsl:template match="d:msgmain">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:msgsub">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:msgrel">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:msgtext">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:msginfo">
  <xsl:call-template name="block.object"/>
</xsl:template>

<xsl:template match="d:msglevel">
  <fo:block>
    <fo:inline font-weight="bold"
               keep-with-next.within-line="always">
      <xsl:call-template name="gentext.template">
        <xsl:with-param name="context" select="'msgset'"/>
        <xsl:with-param name="name" select="'MsgLevel'"/>
      </xsl:call-template>
    </fo:inline>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="d:msgorig">
  <fo:block>
    <fo:inline font-weight="bold"
               keep-with-next.within-line="always">
      <xsl:call-template name="gentext.template">
        <xsl:with-param name="context" select="'msgset'"/>
        <xsl:with-param name="name" select="'MsgOrig'"/>
      </xsl:call-template>
    </fo:inline>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="d:msgaud">
  <fo:block>
    <fo:inline font-weight="bold"
               keep-with-next.within-line="always">
      <xsl:call-template name="gentext.template">
        <xsl:with-param name="context" select="'msgset'"/>
        <xsl:with-param name="name" select="'MsgAud'"/>
      </xsl:call-template>
    </fo:inline>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="d:msgexplan">
  <xsl:call-template name="block.object"/>
</xsl:template>

<xsl:template match="d:msgexplan/d:title">
  <fo:block font-weight="bold"
            keep-with-next.within-column="always"
            hyphenate="false">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->
<!-- For better or worse, revhistory is allowed in content... -->

<xsl:template match="d:revhistory">
  <fo:table table-layout="fixed" xsl:use-attribute-sets="revhistory.table.properties">
    <xsl:call-template name="anchor"/>
    <fo:table-column column-number="1" column-width="proportional-column-width(1)"/>
    <fo:table-column column-number="2" column-width="proportional-column-width(1)"/>
    <fo:table-column column-number="3" column-width="proportional-column-width(1)"/>
    <fo:table-body start-indent="0pt" end-indent="0pt">
      <fo:table-row>
        <fo:table-cell number-columns-spanned="3" xsl:use-attribute-sets="revhistory.table.cell.properties">
          <fo:block xsl:use-attribute-sets="revhistory.title.properties">
            <xsl:choose>
              <xsl:when test="d:title|d:info/d:title">
                <xsl:apply-templates select="d:title|d:info/d:title" mode="titlepage.mode"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key" select="'RevHistory'"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
      <xsl:apply-templates/>
    </fo:table-body>
  </fo:table>
</xsl:template>

<xsl:template match="d:revhistory/d:title">
  <!-- Handled in titlepage.mode -->
</xsl:template>

<xsl:template match="d:revhistory/d:revision">
  <xsl:variable name="revnumber" select="d:revnumber"/>
  <xsl:variable name="revdate"   select="d:date"/>
  <xsl:variable name="revauthor" select="d:authorinitials|d:author"/>
  <xsl:variable name="revremark" select="d:revremark|d:revdescription"/>
  <fo:table-row>
    <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
      <fo:block>
        <xsl:call-template name="anchor"/>
        <xsl:if test="$revnumber">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'Revision'"/>
          </xsl:call-template>
          <xsl:call-template name="gentext.space"/>
          <xsl:apply-templates select="$revnumber[1]"/>
        </xsl:if>
      </fo:block>
    </fo:table-cell>
    <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
      <fo:block>
        <xsl:apply-templates select="$revdate[1]"/>
      </fo:block>
    </fo:table-cell>
    <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
      <fo:block>
        <xsl:for-each select="$revauthor">
          <xsl:apply-templates select="."/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </fo:block>
    </fo:table-cell>
  </fo:table-row>
  <xsl:if test="$revremark">
    <fo:table-row>
      <fo:table-cell number-columns-spanned="3" xsl:use-attribute-sets="revhistory.table.cell.properties">
        <fo:block>
          <xsl:apply-templates select="$revremark[1]"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:if>
</xsl:template>

<xsl:template match="d:revision/d:revnumber">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:revision/d:date">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:revision/d:authorinitials">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:revision/d:author">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:revision/d:revremark">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:revision/d:revdescription">
  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:ackno|d:acknowledgements[parent::d:article]">
  <fo:block xsl:use-attribute-sets="normal.para.spacing">
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:highlights">
  <xsl:call-template name="block.object"/>
</xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>
