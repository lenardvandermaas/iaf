<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:validations="http://nn.nl/xsl/validations">
	<xsl:param name="FormDef0"/>
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:key name="fieldvalidations" match="Field" use="@name"/>
	<xsl:variable name="FormDef1" select="document('FormDef.xml')"/>
	<xsl:variable name="FormDef">
		<xsl:choose>
			<xsl:when test="$FormDef0">
				<xsl:copy-of select="$FormDef0"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$FormDef1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	
	<!-- FIX THIS VIJFPROEF AND ELFPROEF SO IT RETURNS THE CORRECT ERRORS. MAKE IT SO THAT THE FORMDEF WILL BE BLAMED THE LEAST POSSIBLE-->
	
	<xsl:template match="/">
		<validations>
		<FormDef>
			<xsl:copy-of select="$FormDef"/>
		</FormDef>
			<validation type="inputBased">
				<xsl:apply-templates select="*"/>
			</validation>
			<validation type="missingFields">
				<xsl:variable name="missingInputFieldsError">
					<xsl:choose>
						<xsl:when test="count(formulier) &gt; 0">
							<xsl:if test="count(formulier/veld) = 0">
								<error>No 'veld' elements could be found element 'formulier' in the provided input</error>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<error>No 'formulier' element could be found in the provided input</error>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:copy-of select="$missingInputFieldsError"/>
				<xsl:choose>
					<xsl:when test="count($FormDef/Fields) &gt; 0">
						<xsl:choose>
							<xsl:when test="count($FormDef/Fields/Field) &gt; 0">
								<xsl:choose>
									<xsl:when test="count($FormDef/Fields/Field[@name != '']) &gt; 0">
										<xsl:apply-templates select="$FormDef/Fields/Field[@name != '']">
											<xsl:with-param name="inputRaw" select="formulier/veld"/> 
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<error>No 'Field' elements with value for attribute 'name' specified could be found in the element 'Fields' in the provided FormDefenition</error>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<error>No 'Field' elements could be found in element 'Fields' in the provided FormDefenition</error>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<error>No 'Fields' element could be found in the provided FormDefenition</error>
					</xsl:otherwise>
				</xsl:choose>
			</validation>
			<validation type="formDefFieldName">
				<xsl:for-each select="$FormDef/Fields/Field">
					<Field>
						<xsl:copy-of select="."/>
						<xsl:if test="not(@name != '')">
							<error>No value was specified for mandatory attribute 'name'</error>
						</xsl:if>
					</Field>
				</xsl:for-each>
			</validation>
			<validation type="duplicateFormDefField">
				<xsl:if test="count($FormDef/Fields) &gt; 0">
					<xsl:if test="count($FormDef/Fields/Field[@name != '']) &gt; 0">
						<xsl:variable name="listWithName" select="$FormDef/Fields/Field[@name != '']"/>
						<xsl:copy-of select="validations:findFormDefDuplicates($listWithName, $listWithName[1]/@name, '')"/>
					</xsl:if>
				</xsl:if>
			</validation>
		</validations>
	</xsl:template>
	
	
	
	
	
	<xsl:function name="validations:findFormDefDuplicates">
		<xsl:param name="currentList"/>
		<xsl:param name="currentName" as="xs:string"/>
		<xsl:param name="currentError"/>
		<xsl:variable name="resultError">
			<xsl:copy-of select="$currentError"/>
			<xsl:choose>
				<xsl:when test="count($currentList[@name = $currentName]) &gt; 1">
					<error>
						<xsl:copy-of select="$currentList[@name = $currentName]"/>
					</error>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="resultList" select="$currentList[@name != $currentName]"/>
		<xsl:sequence select="
			if(count($resultList) &gt; 0) then (
				validations:findFormDefDuplicates($resultList, $resultList[1]/@name, $resultError)
			) else (
				$resultError
			)"/>
	</xsl:function>
	
	
	
	
	
	<xsl:template match="Field">
		<xsl:param name="inputRaw"/>
		<xsl:variable name="name" select="@name"/>
		<xsl:variable name="mandatory" select="@mandatory"/>
		<pair>
			<xsl:choose>
				<xsl:when test="count($inputRaw[@naam = $name]) &gt; 0 or @mandatory = 'false'">
					<xsl:copy-of select="."/>
					<xsl:copy-of select="$inputRaw[@naam = $name]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
					<error>
						<xsl:value-of select="concat('No element ''Veld'' with attribute ''naam'' with value ''', $name, ''' could be found in the provided input, while it is declared mandatory in the FormDefenition')"/>
					</error>
				</xsl:otherwise>
			</xsl:choose>
		</pair>
	</xsl:template>
	
	
	
	
	
	<xsl:template match="veld">
		<field>
			<xsl:variable name="fieldname">
				<xsl:choose>
					<xsl:when test="@naam != ''">
						<xsl:value-of select="@naam"/>
					</xsl:when>
					<xsl:otherwise>
						<error>
							<xsl:value-of select="validations:errorMessage(1, '', 4, 'naam', 1, 'veld', 1, '')"/>
						</error>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="value">
				<xsl:value-of select="."/>
			</xsl:variable>
			<name>
				<xsl:copy-of select="$fieldname"/>
			</name>
			<value>
				<xsl:copy-of select="$value"/>
			</value>
			<xsl:if test="not($fieldname/error)">
				<xsl:choose>
					<xsl:when test="key('fieldvalidations', $fieldname, $FormDef)">
						<xsl:for-each select="key('fieldvalidations', $fieldname, $FormDef)">
							<xsl:variable name="mandatory">
								<xsl:choose>
									<xsl:when test="@mandatory != ''">
										<xsl:value-of select="@mandatory"/>
									</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<madatory>
								<xsl:value-of select="$mandatory"/>
							</madatory>
							<xsl:choose>
								<xsl:when test="$value != ''">
									<xsl:choose>
										<xsl:when test="count(Rule) != 0">
											<xsl:for-each select="Rule">
												<rule>
													<xsl:choose>
														<xsl:when test="@vType != ''">
															<xsl:variable name="vType" select="@vType"/>
															<vType>
																<xsl:value-of select="$vType"/>
															</vType>
															<xsl:choose>
																<xsl:when test="$vType='aavContractNumber'">
																	<validation>
																		<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:aavContractNumber($value))"/>
																	</validation>
																</xsl:when>
																<xsl:when test="$vType='elfproef'">
																	<xsl:choose>
																		<xsl:when test="@weights != ''">
																			<xsl:variable name="weights" select="@weights"/>
																			<weights>
																				<xsl:value-of select="$weights"/>
																			</weights>
																			<xsl:choose>
																				<xsl:when test="@expectedInputLength != ''">
																					<xsl:variable name="expectedInputLength" select="@expectedInputLength"/>
																					<validation>
																						<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:elfproef($value, $weights, $expectedInputLength))"/>
																					</validation>
																				</xsl:when>
																				<xsl:otherwise>
																					<validation>
																						<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:elfproef($value, $weights))"/>
																					</validation>
																				</xsl:otherwise>
																			</xsl:choose>
																		</xsl:when>
																		<xsl:otherwise>
																			<validation>
																				<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:elfproef($value))"/>
																			</validation>
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:when test="$vType='vijfproef'">
																	<xsl:choose>
																		<xsl:when test="@weights != ''">
																			<xsl:variable name="weights" select="@weights"/>
																			<weights>
																				<xsl:value-of select="$weights"/>
																			</weights>
																			<validation>
																				<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:vijfproef($value, $weights))"/>
																			</validation>
																		</xsl:when>
																		<xsl:otherwise>
																			<validation>
																				<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:vijfproef($value))"/>
																			</validation>
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:when test="$vType='negenproef'">
																	<xsl:choose>
																		<xsl:when test="@expectedResult != ''">
																			<xsl:variable name="expectedResult" select="@expectedResult"/>
																			<expectedResult>
																				<xsl:value-of select="$expectedResult"/>
																			</expectedResult>
																			<validation>
																				<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:negenproef($value, $expectedResult))"/>
																			</validation>
																		</xsl:when>
																		<xsl:otherwise>
																			<validation>
																				<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:negenproef($value))"/>
																			</validation>
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:when test="$vType='iban'">
																	<validation>
																		<xsl:copy-of select="validations:returnAsErrorOrTrue(validations:iban($value))"/>
																	</validation>
																</xsl:when>
																<xsl:when test="$vType='regex'">
																	<xsl:choose>
																		<xsl:when test="@regex != ''">
																			<xsl:variable name="regex" select="@regex"/>
																			<regex>
																				<xsl:value-of select="$regex"/>
																			</regex>
																			<validation>
																				<xsl:choose>
																					<xsl:when test="matches($value, $regex)">true</xsl:when>
																					<xsl:otherwise>
																						<error>provided input value doesn't match regex specified by FormDefenition</error>
																					</xsl:otherwise>
																				</xsl:choose>
																			</validation>
																		</xsl:when>
																		<xsl:otherwise>
																			<regex>
																				<error>
																					<xsl:value-of select="validations:errorMessage(1, '', 4, 'regex', 1, 'Rule', 5, '')"/>
																				</error>
																			</regex>
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:when test="$vType='multipleOption'">
																	<xsl:choose>
																		<xsl:when test="Options != ''">
																			<xsl:choose>
																				<xsl:when test="Options/Option != ''">
																					<xsl:copy-of select="Options"/>
																					<validation>
																						<xsl:choose>
																							<xsl:when test="Options/Option[text() = $value] != ''">true</xsl:when>
																							<xsl:otherwise>
																								<error>provided input value doesn't match any of the options specified by FormDefenition</error>
																							</xsl:otherwise>
																						</xsl:choose>
																					</validation>
																				</xsl:when>
																				<xsl:otherwise>
																					<Options>
																						<error>
																							<xsl:value-of select="validations:errorMessage(3, 'Option', 6, 'Options', 2, 'Rule', 5, '')"/>
																						</error>
																					</Options>
																				</xsl:otherwise>
																			</xsl:choose>
																		</xsl:when>
																		<xsl:otherwise>
																			<Options>
																				<error>
																					<xsl:value-of select="validations:errorMessage(3, 'Options', 6, 'Rule', 0, '', 5, '')"/>
																				</error>
																			</Options>
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:when test="$vType='date'">
																	<xsl:choose>
																		<xsl:when test="@operator != ''">
																			<xsl:variable name="operator" select="@operator"/>
																			<operator>
																				<xsl:value-of select="$operator"/>
																			</operator>
																			<xsl:variable name="dateInput" select="validations:dateFormat($value)"/>
																			<xsl:choose>
																				<xsl:when test="$dateInput castable as xs:date">
																					<xsl:variable name="date" as="xs:date" select="($dateInput) cast as xs:date"/>
																					<validation>
																						<xsl:choose>
																							<xsl:when test="$operator='equalTo'">
																								<xsl:choose>
																									<xsl:when test="$date = current-date()">true</xsl:when>
																									<xsl:otherwise>
																										<error>provided input value is not equal to current date</error>
																									</xsl:otherwise>
																								</xsl:choose>
																							</xsl:when>
																							<xsl:when test="$operator='lessThan'">
																								<xsl:choose>
																									<xsl:when test="$date &lt; current-date()">true</xsl:when>
																									<xsl:otherwise>
																										<error>provided input value is not smaller than current date</error>
																									</xsl:otherwise>
																								</xsl:choose>
																							</xsl:when>
																							<xsl:when test="$operator='greaterThan'">
																								<xsl:choose>
																									<xsl:when test="$date &gt; current-date()">true</xsl:when>
																									<xsl:otherwise>
																										<error>provided input value is not greater than current date</error>
																									</xsl:otherwise>
																								</xsl:choose>
																							</xsl:when>
																							<xsl:when test="$operator='lessThanEqualTo'">
																								<xsl:choose>
																									<xsl:when test="$date &lt;= current-date()">true</xsl:when>
																									<xsl:otherwise>
																										<error>provided input value is not less than or equal to current date</error>
																									</xsl:otherwise>
																								</xsl:choose>
																							</xsl:when>
																							<xsl:when test="$operator='greaterThanEqualTo'">
																								<xsl:choose>
																									<xsl:when test="$date &gt;= current-date()">true</xsl:when>
																									<xsl:otherwise>
																										<error>provided input value is not greater than or equal to current date</error>
																									</xsl:otherwise>
																								</xsl:choose>
																							</xsl:when>
																							<xsl:otherwise>
																								<error>The provided operator could not be found. Fix this issue in the provided FormDefenition</error>
																							</xsl:otherwise>
																					</xsl:choose> 
																					</validation>
																				</xsl:when>
																				<xsl:otherwise>
																					<validation>
																						<error>The provided input value could not be parsed to a date. please use format 'yyyy-mm-dd' or 'dd-mm-yyyy' and use one of the following separators '-_/.: '</error>
																					</validation>
																				</xsl:otherwise>
																			</xsl:choose>
																		</xsl:when>
																		<xsl:otherwise>
																			<operator>
																				<error>
																					<xsl:value-of select="validations:errorMessage(1, '', 4, 'operator', 1, 'Rule', 5, '')"/>
																				</error>
																			</operator>
																		</xsl:otherwise>
																	</xsl:choose>
																</xsl:when>
																<xsl:otherwise>
																	<validation>
																		<error>The provided value for attribute vType could not be found in the list of validationTypes. Fix this issue in the provided FormDefenition</error>
																	</validation>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:otherwise>
															<vType>
																<error>
																	<xsl:value-of select="validations:errorMessage(1, '', 4, 'vType', 1, 'Field', 5, '')"/>
																</error>
															</vType>
														</xsl:otherwise>
													</xsl:choose>
												</rule>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<validation>true</validation>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<validation>
										<xsl:choose>
											<xsl:when test="$mandatory = 'false'">true</xsl:when>
											<xsl:otherwise>
												<error>
													<xsl:value-of select="concat('No value was specified for mandatory field: ''', $fieldname, '''')"/>
												</error>
											</xsl:otherwise>
										</xsl:choose>
									</validation>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<error><xsl:value-of select="concat('No element ''Field'', with attribute ''name'' with value ''', $fieldname, ''', could be found in the provided FormDefenition')"/></error>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</field>
	</xsl:template>
	
	
	
	
	
	<xsl:function name="validations:returnAsErrorOrTrue">
		<xsl:param name="input"/>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$input = 'true'">true</xsl:when>
				<xsl:otherwise>
					<error>
						<xsl:value-of select="$input"/>
					</error>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="$result"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:iban">
		<xsl:param name="pIBAN" as="xs:string"/>
		<xsl:variable name="numberText" select="
			codepoints-to-string(
				for $n in string-to-codepoints(
					concat(
						substring($pIBAN, 5),
						substring($pIBAN, 1, 4)
					)
				) return (
					if ($n > 64) then (
						string-to-codepoints(
							string($n - 55)
						)
					) else $n
				)
			)"/>
		<xsl:sequence select="
			if(matches($numberText, '^[0-9]{22,24}$')) then (
				if(xs:integer($numberText) mod 97 eq 1) then (
					'true'
				) else (
					'provided input value did not pass the validation'
				)
			) else (
				'provided input value is not in the correct format'
			)"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:aavContractNumber">
		<xsl:param name="number" as="xs:string"/>
		<xsl:variable name="length" as="xs:integer" select="string-length($number)"/>
		<xsl:sequence select="
			if(matches($number, '^[0-9]*$')) then (
				xs:string(
					if($length = 8) then (
						if(substring($number, 1, 1) != '9') then (
							validations:vijfproef($number)
						) else 'Input number has a lenght of 8, but the first digit is 9, which means that this is not a correct number'
					) else if ($length &lt;= 10) then (
						if($length &gt; 0) then (
							validations:elfproef($number)
						) else 'The input string was too short. String with min 1 digits expected'
					) else 'The input string was too long. String with max 10 digits expected'
				)
			) else 'Input number is not in the correct format. String with digits only expected'"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:elfproef" as="xs:string">
		<xsl:param name="inputString" as="xs:string"/>
		<xsl:sequence select="validations:elfproef($inputString, '1,2,3,4,5,6,7,8,9,10', '-1')"/>
	</xsl:function>
	<xsl:function name="validations:elfproef" as="xs:string">
		<xsl:param name="inputString" as="xs:string"/>
		<xsl:param name="weightString" as="xs:string"/>
		<xsl:sequence select="validations:elfproef($inputString, $weightString, '-1')"/>
	</xsl:function>
	<xsl:function name="validations:elfproef" as="xs:string">
		<xsl:param name="inputString" as="xs:string"/>
		<xsl:param name="weightString" as="xs:string"/>
		<xsl:param name="expectedInputLength" as="xs:string"/>
		<xsl:variable name="inputNumber" as="xs:string" select="replace($inputString, '[^0-9]', '')"/>
		<xsl:variable name="length" as="xs:integer" select="string-length($inputNumber)"/>
		<xsl:variable name="inputDigits" as="xs:string" select="
			if($length &lt;= 10) then (
				substring(
					concat(
						'000000000',
						$inputNumber
					),
					$length
				)
			) else '0000000001'"/>
		<xsl:variable name="weightListOrg" select="tokenize($weightString, ',')"/>
		<xsl:variable name="weightStringPrefixed" select="
			if(count($weightListOrg) &lt; 10) then (
				concat(
					substring(
						'0,0,0,0,0,0,0,0,0,',
						1,
						2 * (10 - count($weightListOrg))
					),
					$weightString
				)
			) else $weightString"/>
		<xsl:variable name="weightList" select="tokenize($weightStringPrefixed, ',')"/>
		<xsl:variable name="error">
			<xsl:copy-of select="
			if($length &lt; 1) then (
				concat('The input string ''', $inputString, ''' is too short. Expected string with min 1 digits (regex: ''^\d{1,10}'').')
			) else if($length &gt; 10) then (
				concat('The input string ''', $inputString, ''' is too long. Expected string with max 10 digits (regex: ''^\d{1,10}'').')
			) else if(count($weightList) &lt; 10) then (
				concat('The weight list ''', $weightString, ''' is too short. Expected string with an amount of numbers that matches the input number''s length, separated with a '','' (regex: ''^-?[1-9]\d*(,-?[1-9]\d*){0,9}$''). Fix this in the provided FormDefenition')
			) else if(count($weightList) &gt; 10) then (
				concat('The weight list ''', $weightString, ''' is too long. Expected string with an amount of numbers that matches the input number''s length, separated with a '','' (regex: ''^-?[1-9]\d*(,-?[1-9]\d*){0,9}$''). Fix this in the provided FormDefenition')
			) else if(not(matches($weightString, '^-?[1-9]\d*(,-?[1-9]\d*){0,9}$'))) then (
				concat('The format of the weight list ''', $weightString, ''' is incorrect. Expected string with an amount of numbers that matches the input number''s length, separated with a '','' (regex: ''^-?[1-9]\d*(,-?[1-9]\d*){0,9}$''). Fix this in the provided FormDefenition')
			) else if(not($expectedInputLength castable as xs:integer)) then (
				concat('The format of the expectedInputLength ''', $expectedInputLength, ''' is incorrect. Expected string containing a number only (indicate negative numbers with a ''-'')')
			) else if($length &lt; xs:integer($expectedInputLength) and $expectedInputLength != '-1') then (
				concat('The input string ''', $inputString ,''' was too short. Expected string with exactly ', $expectedInputLength, ' digits')
			) else if($length &gt; xs:integer($expectedInputLength) and $expectedInputLength != '-1') then (
				concat('The input string ''', $inputString ,''' was too long, Expected string with exactly ', $expectedInputLength, ' digits')
			) else ''"/>
		</xsl:variable>
		<xsl:variable name="resultBool" as="xs:boolean" select="
			if($error != '') then (
				false()
			) else (
				(
					xs:integer(substring($inputDigits, 1, 1)) * xs:integer($weightList[1]) +
					xs:integer(substring($inputDigits, 2, 1)) * xs:integer($weightList[2]) +
					xs:integer(substring($inputDigits, 3, 1)) * xs:integer($weightList[3]) +
					xs:integer(substring($inputDigits, 4, 1)) * xs:integer($weightList[4]) +
					xs:integer(substring($inputDigits, 5, 1)) * xs:integer($weightList[5]) +
					xs:integer(substring($inputDigits, 6, 1)) * xs:integer($weightList[6]) +
					xs:integer(substring($inputDigits, 7, 1)) * xs:integer($weightList[7]) +
					xs:integer(substring($inputDigits, 8, 1)) * xs:integer($weightList[8]) +
					xs:integer(substring($inputDigits, 9, 1)) * xs:integer($weightList[9]) +
					xs:integer(substring($inputDigits, 10, 1)) * xs:integer($weightList[10])
				) mod 11 eq 0
			)"/>
		<xsl:sequence select="
			if($error != '') then ($error) else (
				if($resultBool) then ('true') else (
					'provided input value did not pass the validation'
				)
			)"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:vijfproef" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:sequence select="validations:vijfproef($input, '7,1,3,7,1,3,7,1')"/>
	</xsl:function>
	<xsl:function name="validations:vijfproef" as="xs:string">
		<xsl:param name="inputString" as="xs:string"/>
		<xsl:param name="weightString" as="xs:string"/>
		<xsl:variable name="weightList" select="tokenize($weightString, ',')"/>
		<xsl:variable name="inputNumber" as="xs:string" select="replace($inputString, '[^0-9]', '')"/>
		<xsl:variable name="length" as="xs:integer" select="string-length($inputNumber)"/>
		<xsl:variable name="inputDigits" as="xs:string" select="
			if($length = 8) then (
				$inputNumber
			) else '00000001'"/>
		<xsl:variable name="errorMessages">
			<errors>
				<error><xsl:value-of select="concat('The input string ''', $inputString, ''' is too long. Expected string with exactly 8 digits (regex: '';^\d{8}'';).')"/></error>
				<error><xsl:value-of select="concat('The input string ''', $inputString, ''' is too short. Expected string with exactly 8 digits (regex: '';^\d{8}'';).')"/></error>
				<error><xsl:value-of select="concat('The weight list ''', $weightString, ''' is too short. Expected string with 8 numbers separated with a '';,''; (regex: '';^-?[1-9]\d*?(,-?[1-9]\d*){7}$'';). Fix this in the provided FormDefenition')"/></error>
				<error><xsl:value-of select="concat('The weight list ''', $weightString, ''' is too long. Expected string with 8 numbers separated with a '';,''; (regex: '';^-?[1-9]\d*?(,-?[1-9]\d*){7}$'';). Fix this in the provided FormDefenition')"/></error>
				<error><xsl:value-of select="concat('The format of the weight list string ''', $weightString, ''' is incorrect. Expected string with 8 numbers separated with a '';,''; (regex: '';^-?[1-9]\d*?(,-?[1-9]\d*){7}$'';). Fix this in the provided FormDefenition')"/></error>
			</errors>
		</xsl:variable>
		<xsl:variable name="error">
			<xsl:copy-of select="
			if($length &gt; 8) then (
				$errorMessages/errors/error[1]
			) else if(count($weightList) &lt; 8) then (
				$errorMessages/errors/error[2]
			) else if(count($weightList) &gt; 8) then (
				$errorMessages/errors/error[3]
			) else if(not(matches($weightString, '^-?[1-9]\d*?(,-?[1-9]\d*){7}$'))) then (
				$errorMessages/errors/error[4]
			) else ''"/>
		</xsl:variable>
		<xsl:variable name='resultBool' as="xs:boolean" select="	
			if($error != '') then (
				false()
			) else (
				(
					xs:integer(substring($inputDigits, 1, 1)) * xs:integer(substring($weightList, 1, 1)) +
					xs:integer(substring($inputDigits, 2, 1)) * xs:integer(substring($weightList, 2, 1)) +
					xs:integer(substring($inputDigits, 3, 1)) * xs:integer(substring($weightList, 3, 1)) +
					xs:integer(substring($inputDigits, 4, 1)) * xs:integer(substring($weightList, 4, 1)) +
					xs:integer(substring($inputDigits, 5, 1)) * xs:integer(substring($weightList, 5, 1)) +
					xs:integer(substring($inputDigits, 6, 1)) * xs:integer(substring($weightList, 6, 1)) +
					xs:integer(substring($inputDigits, 7, 1)) * xs:integer(substring($weightList, 7, 1)) +
					xs:integer(substring($inputDigits, 8, 1)) * xs:integer(substring($weightList, 8, 1))
				) mod 5 eq 0
			)"/>
		<xsl:sequence select="	
			if($error != '') then ($error) else (
				if($resultBool) then ('true') else (
					'provided input value did not pass the validation'
				)
			)"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:negenproef" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:sequence select="validations:negenproef($input, '0')"/>
	</xsl:function>
	<xsl:function name="validations:negenproef" as="xs:string">
		<xsl:param name="inputString" as="xs:string"/>
		<xsl:param name="expectedResult" as="xs:string"/>
		<xsl:variable name="inputNumber" as="xs:string" select="replace($inputString, '[^0-9]', '')"/>
		<xsl:sequence select="
			if($inputNumber castable as xs:integer) then (
				if($expectedResult castable as xs:integer) then (
					xs:string(
						if(validations:negenproefCalculator($inputNumber) mod 9 = xs:integer($expectedResult)) then ('true') else (
							'provided input value did not pass the validation'
						)
					)
				) else if($expectedResult = '') then (
					'The provided value for parameter expectedResult is empty'
				) else (
					concat('The provided value ''', $expectedResult , ''' for parameter expectedResult is not castable as integer')
				)
			) else if($inputString = '') then (
				'The provided input value is empty'
			) else (
				concat('The provided input value ''', $inputString , ''' contains no digits')
			)"/>
	</xsl:function>
	<xsl:function name="validations:negenproefCalculator" as="xs:integer">
		<xsl:param name="inputString" as="xs:string"/>
		<xsl:sequence select="
			if(
				sum(
					for $s in string-to-codepoints($inputString) return (
						xs:integer(codepoints-to-string($s))
					)
				) &gt; 9
			) then (
				validations:negenproefCalculator(
					xs:string(
						sum(
							for $s in string-to-codepoints($inputString) return (
								xs:integer(codepoints-to-string($s))
							)
						)
					)
				)
			) else (
				sum(
					for $s in string-to-codepoints($inputString) return (
						xs:integer(codepoints-to-string($s))
					)
				)
			)
		"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:errorMessage">
		<!-- Error type index:
		1. No value was specified for
		2. No ... was specified for-->
		<xsl:param name="errorSourceType" as="xs:integer"/>
		<xsl:param name="errorSourceName" as="xs:string"/>
		<!-- Source type index:
		1. element
		2. attribute
		3. mandatory element
		4. mandatory attribute -->
		<xsl:param name="sourceType" as="xs:integer"/>
		<xsl:param name="sourceName" as="xs:string"/>
		
		<!-- Optional. Specify this if the user should know what the sources parent node is 
		1. of the element
		2. in the element -->
		<xsl:param name="parentType" as="xs:integer"/>
		<xsl:param name="parentName" as="xs:string"/>
		
		<!-- Optional. Specify this if the user should know what the sources context is 
		1. in the provided input
		2. in the provided file -->
		<xsl:param name="contextType" as="xs:integer"/>
		<xsl:param name="contextName" as="xs:string"/>
		
		<xsl:variable name="errorSourceTypeList">
			<opt>No value was specified</opt>
			<opt><xsl:value-of select="concat('Element ''', $errorSourceName, ''' is not specified')"/></opt>
			<opt><xsl:value-of select="concat('Mandatory element ''', $errorSourceName, ''' is not specified')"/></opt>
		</xsl:variable>
		<xsl:variable name="sourceTypeList">
			<opt> for element</opt>
			<opt> for attribute</opt>
			<opt> for mandatory element</opt>
			<opt> for mandatory attribute</opt>
			<opt> of the element</opt>
			<opt> in the element</opt>
		</xsl:variable>
		<xsl:variable name="parentTypeList">
			<opt> of the element</opt>
			<opt> in the element</opt>
		</xsl:variable>
		<xsl:variable name="contextTypeList">
			<opt> in the provided input</opt>
			<opt> of the provided input</opt>
			<opt> in the provided file</opt>
			<opt> on the provided file</opt>
			<opt> in the provided FormDefenition</opt>
			<opt> of the provided FormDefenition</opt>
		</xsl:variable>
		
		<xsl:sequence select="
			concat(
				$errorSourceTypeList/opt[position() = $errorSourceType],
				(if($sourceType > 0) then (
					concat(
						$sourceTypeList/opt[position() = $sourceType],
						(if($sourceName != '') then concat(' ''', $sourceName, '''') else '')
					)
				) else ''),
				(if($parentType > 0) then (
					concat(
						$parentTypeList/opt[position() = $parentType],
						(if($parentName!= '') then concat(' ''', $parentName, '''') else '')
					)
				) else ''),
				(if($contextType > 0) then (
					concat(
						$contextTypeList/opt[position() = $contextType],
						(if($contextName != '') then concat(' ''', $contextName, '''') else '')
					)
				) else '')
			)"/>
	</xsl:function>
	
	
	
	
	
	<xsl:function name="validations:dateFormat" as="xs:string">
		<xsl:param name="dateInput" as="xs:string"/>
		<xsl:sequence select="
			if(matches($dateInput, '^\d{4}[_/.: ](0?[1-9]|1[0-2])[_/.: ](0?[1-9]|([1-2]\d|3[01]))$')) then (
				concat(substring($dateInput, 1, 4), '-', substring($dateInput, 6, 2), '-', substring($dateInput, 9, 2))
			) else if(matches($dateInput, '^(0?[1-9]|([1-2]\d|3[01]))[-_/.: ](0?[1-9]|1[0-2])[-_/.: ]\d{4}$')) then (
				concat(substring($dateInput, 7, 4), '-', substring($dateInput, 4, 2), '-', substring($dateInput, 1, 2))
			) else $dateInput
		"/>
	</xsl:function>
</xsl:stylesheet>
