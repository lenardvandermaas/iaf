<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:validations="http://nn.nl/xsl/validations">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<validations>
			<xsl:for-each select="./validations/validation">
				<xsl:choose>
					<xsl:when test="@type = 'inputBased'">
						<validation type="inputBased">
							<xsl:copy-of select="*[descendant::error != '']"/>
						</validation>
					</xsl:when>
					<xsl:when test="@type = 'missingFields'">
						<validation type="missingFields">
							<xsl:copy-of select="error"/>
							<xsl:copy-of select="*[descendant::error != '']"/>
						</validation>
					</xsl:when>
					<xsl:when test="@type = 'formDefFieldName'">
						<validation type="formDefFieldName">
							<xsl:copy-of select="*[descendant::error != '']"/>
						</validation>
					</xsl:when>
					<xsl:when test="@type = 'duplicateFormDefField'">
						<validation type="duplicateFormDefField">
							<xsl:copy-of select="*"/>
						</validation>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</validations>
	</xsl:template>
</xsl:stylesheet>
