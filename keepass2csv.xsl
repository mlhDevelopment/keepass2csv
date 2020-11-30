<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="utf-8" />
	<xsl:variable name="cometa">"</xsl:variable>

	<xsl:template match="/">
		<!-- Header Row -->
		<xsl:text>Title,UserName,Password,Url,Notes&#10;</xsl:text>
		<xsl:apply-templates select="/KeePassFile/Root/Group" />
	</xsl:template>

	<!-- These groups will be ignored -->
	<xsl:template match="Group[Name='Recycle Bin']" />

	<xsl:template match="Group">
		<xsl:param name="parent" select="'/'" />
		<xsl:variable name="current" select="concat($parent, Name)" />

		<!-- list password entries -->
		<xsl:apply-templates select="Entry">
			<xsl:with-param name="group" select="$current" />
		</xsl:apply-templates>

		<!-- list entries of subgroups recursively -->
		<xsl:apply-templates select="Group">
			<xsl:with-param name="parent" select="concat($current, '/')" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Entry">
		<xsl:param name="group" />

		<!-- pack Notes and multi-line custom fields into notes field -->
		<xsl:variable name="notes">
			<xsl:if test="String[Key='Notes']/Value!=''">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="String[Key='Notes']/Value" />
					<xsl:with-param name="replace" select="$cometa" />
					<xsl:with-param name="by" select="concat($cometa,$cometa)" />
				</xsl:call-template>
			</xsl:if>
			<xsl:text>From KeePass conversion, Group: </xsl:text>
			<xsl:value-of select="$group" />
			<xsl:text>, Icon: </xsl:text>
			<xsl:call-template name="iconName">
				<xsl:with-param name="iconId" select="IconID" />
			</xsl:call-template>
		</xsl:variable>

        <!-- Escape Double quotes in password field -->
		<xsl:variable name="password">
			<xsl:if test="String[Key='Password']/Value!=''">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="String[Key='Password']/Value" />
					<xsl:with-param name="replace" select="$cometa" />
					<xsl:with-param name="by" select="concat($cometa,$cometa)" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

       <!-- Escape Double quotes in URL field (yes, someone put quotes in that field too)-->
		<xsl:variable name="url">
			<xsl:if test="String[Key='URL']/Value!=''">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="String[Key='URL']/Value" />
					<xsl:with-param name="replace" select="$cometa" />
					<xsl:with-param name="by" select="concat($cometa,$cometa)" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

       <!-- Populate Title field with username if empty-->
		<xsl:variable name="title">
		   <xsl:choose>
              <xsl:when test="String[Key='Title']/Value=''">
                 <xsl:value-of select="String[Key='UserName']/Value"/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:value-of select="String[Key='Title']/Value"/>
              </xsl:otherwise>
           </xsl:choose>
		</xsl:variable>
			
		<!-- put CSV fields: Title, UserName, Password, Group, URL, Notes -->
		<xsl:text>"</xsl:text>
		<xsl:value-of select="$title" />
		<xsl:text>","</xsl:text>
		<xsl:value-of select="String[Key='UserName']/Value" />
		<xsl:text>","</xsl:text>
		<xsl:value-of select="$password" />
		<xsl:text>","</xsl:text>
		<xsl:value-of select="$url" />
		<xsl:text>","</xsl:text>
		<xsl:value-of select="$notes" />
		<xsl:text>"&#10;</xsl:text>
	</xsl:template>

	<!-- replace $pattern in $subject with $replace -->
	<xsl:template name="replace">
		<xsl:param name="subject" />
		<xsl:param name="pattern" />
		<xsl:param name="replace" />
		<xsl:choose>
			<xsl:when test="contains($subject, $pattern)">
				<xsl:value-of
					select="concat(substring-before($subject, $pattern), $replace)" />
				<xsl:call-template name="replace">
					<xsl:with-param name="subject"
						select="substring-after($subject, $pattern)" />
					<xsl:with-param name="pattern" select="$pattern" />
					<xsl:with-param name="replace" select="$replace" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$subject" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="string-replace-all">
		<xsl:param name="text" />
		<xsl:param name="replace" />
		<xsl:param name="by" />
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)" />
				<xsl:value-of select="$by" />
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text"
						select="substring-after($text,$replace)" />
					<xsl:with-param name="replace" select="$replace" />
					<xsl:with-param name="by" select="$by" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="iconName">
		<xsl:param name="iconId" />
		<xsl:choose>
			<xsl:when test="$iconId=0">Default Key</xsl:when>
			<xsl:when test="$iconId=43">Trash Bin</xsl:when>
			<xsl:when test="$iconId=45">Red X</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$iconId" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>