<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited by Luis Lugo (HACH Company) -->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method='text' version='1.0' encoding='UTF-8'/>
<xsl:strip-space elements="*" />

<xsl:template match="Datalog">
     <xsl:for-each select="//Entry">
          <xsl:value-of select="./Time"></xsl:value-of>
          <xsl:apply-templates select=".//Data">
          
          </xsl:apply-templates>
          <xsl:text>&#10;</xsl:text>
     </xsl:for-each>

</xsl:template>

<xsl:template match="Data">
     <xsl:text>,</xsl:text>
     <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>
