<?xml 
	version="1.0" 
	encoding="utf-8"
?>

<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:ext="http://goutsidis.gr/extension" 
	exclude-result-prefixes="gml msxsl ext"
>

<xsl:output 
	method="xml" 
	version="1.0" 
	encoding="utf-8" 
	indent="yes" 
	media-type="application/vnd.google-earth.kml+xml"
/>

<msxsl:script language="C#" implements-prefix="ext">
	<![CDATA[
	public string formatPosList(string value)
	{
		string[] res = value.Split(' ');
		return res[1] + "," + res[0] + ",0 " + res[3] + "," + res[2] + ",0";
	}
	
	public string formatTimeStamp(string value)
	{
		string res = value.Replace("/", "-");
		return res.Replace(".", ":") + "Z";
	}
	]]>
</msxsl:script>

	<xsl:template match="/gml:featureCollection">
		<xsl:element name="kml" namespace="http://earth.google.com/kml/2.2">
			<xsl:element name="Document">
				<xsl:element name="Folder">
					<xsl:element name="name">
						<xsl:text>VisualHermes</xsl:text>
					</xsl:element>
					<xsl:element name="Style">
						<xsl:attribute name="id">
							<xsl:text>blueLine</xsl:text>
						</xsl:attribute>
						<xsl:element name="LineStyle">
							<xsl:element name="color">
								<xsl:text>ffff0000</xsl:text>
							</xsl:element>
							<xsl:element name="width">
								<xsl:text>3</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:apply-templates />
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="gml:featureMember">
		<xsl:element name="Placemark">
			<xsl:apply-templates select="gml:name" />
			<xsl:apply-templates select="gml:description" />
			<xsl:apply-templates select="gml:TimePeriod" />
			<xsl:apply-templates select="gml:Point" />
			<xsl:apply-templates select="gml:LineString" />
			<xsl:apply-templates select="gml:Polygon" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="gml:name">
		<xsl:element name="name">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="gml:description">
		<xsl:element name="description">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="gml:TimePeriod">
		<xsl:element name="TimeSpan">
			<xsl:element name="begin">
				<xsl:value-of select="ext:formatTimeStamp(gml:begin)" />
			</xsl:element>
			<xsl:element name="end">
				<xsl:value-of select="ext:formatTimeStamp(gml:end)" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="gml:Point">
		<xsl:element name="Point">
			<xsl:element name="coordinates">
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="gml:LineString">
		<xsl:element name="styleUrl">
			<xsl:text>#blueLine</xsl:text>
		</xsl:element>
		<xsl:element name="LineString">
			<xsl:element name="altitudeMode">
				<xsl:text>relative</xsl:text>
			</xsl:element>
			<xsl:element name="coordinates">
				<xsl:value-of select="ext:formatPosList(gml:posList)" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="gml:Polygon">
		<xsl:element name="Polygon">
			<xsl:element name="tessellate">
				<xsl:text>1</xsl:text>
			</xsl:element>
			<xsl:element name="outerBoundaryIs">
				<xsl:element name="LinearRing">
					<xsl:element name="coordinates">
						<xsl:value-of select="ext:formatPosList(gml:exterior/gml:LinearRing/gml:coordinates)" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="innerBoundaryIs">
				<xsl:element name="LinearRing">
					<xsl:element name="coordinates">
						<xsl:value-of select="ext:formatPosList(gml:interior/gml:LinearRing/gml:coordinates)" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>