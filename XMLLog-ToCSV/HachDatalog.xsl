<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited by Robert Yang (HACH Company) -->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method='html' version='1.0' encoding='UTF-8' indent='yes'/>

<xsl:template match="Datalog">
  <html>
  <body>
  	<xsl:for-each select="//DeviceInfo">
  	<h2><xsl:value-of select="."/></h2>
  	</xsl:for-each>
        <table border="1"> 
	   <xsl:apply-templates select = "//Entry" >
	   
	   </xsl:apply-templates>
        </table>  

  </body>
  </html>
</xsl:template>

<xsl:template match="Entry">
<xsl:choose> 
     <!-- Display the title field -->
     <xsl:when test="position() = 1">     
          <tr bgcolor="#9acd32">
             <th align="left"><xsl:value-of select="//Time"/></th>
          <xsl:choose>
              <xsl:when test="./CH1">
                   <th align="left"><xsl:value-of select="//CH1/Data"/></th>
              </xsl:when>
     	       <xsl:otherwise > 
                   <th align="left" style = "display:none"><xsl:text> </xsl:text></th>     	       
              </xsl:otherwise> 
     	   </xsl:choose>
          <xsl:choose>
              <xsl:when test="./CH2">
                   <th align="left"><xsl:value-of select="//CH2/Data"/></th>
              </xsl:when>
     	       <xsl:otherwise > 
                   <th align="left" style = "display:none"><xsl:text> </xsl:text></th>     	       
              </xsl:otherwise> 
     	   </xsl:choose>
          </tr>
     </xsl:when>
     <!-- Display the log data -->
     <xsl:otherwise > 
     	<tr>
     	    <!-- The time stamp -->
     	    <td align="left"><xsl:value-of select="./Time"/></td>
     	    
           <xsl:choose>            
              <xsl:when test="//CH1">
                    <td align="left"><xsl:value-of select="./CH1/Data"/></td>
              </xsl:when>
     	       <xsl:otherwise > 
                    <td align="left" style = "display:none"><xsl:text> </xsl:text></td>     	       
              </xsl:otherwise> 
     	   </xsl:choose>
           <xsl:choose>            
              <xsl:when test="//CH2">
                    <td align="left"><xsl:value-of select="./CH2/Data"/></td>
              </xsl:when>
     	       <xsl:otherwise > 
                    <td align="left" style = "display:none"><xsl:text> </xsl:text></td>     	       
              </xsl:otherwise> 
     	   </xsl:choose>
     	</tr>
      
     </xsl:otherwise> 
     
</xsl:choose> 

</xsl:template>



</xsl:stylesheet>
