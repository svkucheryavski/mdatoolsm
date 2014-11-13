<?xml version="1.0" encoding="utf-8"?>

<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> <!ENTITY reg "&#174;"> ]>
<xsl:stylesheet
version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd"
exclude-result-prefixes="mwsh">


	<xsl:import href="./mdastyles.xsl"/>

	<xsl:template name="stylesheet">
		<link rel="stylesheet" href="../assets/mdatools.css" type="text/css" />
	</xsl:template>

	<xsl:template name="header">
		<script src="../assets/jquery.js"></script>
		<script>var show_toc = false; var is_method = true;</script>
		<script src="../assets/mdatools.js"></script>
	</xsl:template>


</xsl:stylesheet>
