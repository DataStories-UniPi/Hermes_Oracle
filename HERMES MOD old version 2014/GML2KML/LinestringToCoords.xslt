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

  <xsl:template match="/">
    <coordinates>
      <xsl:for-each select="LineString">
        <xsl:value-of select="coordinates" />
      </xsl:for-each>
    </coordinates>
  </xsl:template>

</xsl:stylesheet>
