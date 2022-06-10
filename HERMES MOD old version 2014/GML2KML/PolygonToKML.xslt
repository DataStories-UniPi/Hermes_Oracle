<?xml 
	version="1.0" 
	encoding="utf-8"
?>

<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
>

<xsl:output 
	method="xml" 
	version="1.0" 
	encoding="utf-8" 
	indent="yes" 
	media-type="application/vnd.google-earth.kml+xml"
/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="coordinates[parent::LinearRing]">
    <LALA>
      <xsl:apply-templates select="node()"/>
    </LALA>
  </xsl:template>

</xsl:stylesheet>