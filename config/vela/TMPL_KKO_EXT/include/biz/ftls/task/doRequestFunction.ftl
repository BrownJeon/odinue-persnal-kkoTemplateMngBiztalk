<#--
    함수목록
        - taskDoRequestFunction_getCreateTemplateUrl: 템플릿등록요청 URL 정의 함수
        - taskDoRequestFunction_parseRequestData: 비즈톡센터 요청전문 파싱 함수
            - innerFunction_parseCreateTemplatePayloadMap : 템플릿등록 전문바디 파싱
		    - innerFunction_uploadImage : 이미지업로드 요청
        - taskDoRequestFunction_parseResponseData: 비즈톡센터에서 응답받은 전문을 파싱 함수
-->

<#--  템플릿등록요청 URL 정의 함수  -->
<#function taskDoRequestFunction_getCreateTemplateUrl>

    <#--  API버전이 분리되어 있지 않아서 고정으로 URL정의  -->
    <#local tmplMngrUrl = m1.shareget("tmplMngrUrl")!""/>
    <#local createTemplateUrl = "${tmplMngrUrl}/template/create"/>

    <#return createTemplateUrl/>
</#function>

<#--  비즈톡센터 요청전문 파싱 함수  -->
<#function taskDoRequestFunction_parseRequestData _seqLocal _rcvBody>

    <#if _rcvBody?size == 0>
        <#local r = m1.log("[REQ][DO][ERR] 전문 변환오류. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {
            "code": "701"
            , "message": "전문 변환오류."
        }/>
    </#if>

    <#local senderKey = _rcvBody.CHANNEL_ID!""/>
    <#if !senderKey?has_content>
        <#local r = m1.log("[REQ][DO][ERR] 전문 내 발신프로필키 없음. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {
            "code": "702"
            , "message": "전문 내 발신프로필키 없음."
        }/>
    </#if>

    <#local formParam = m1.parseJsonValue(_rcvBody.FORM_PARAM!"{}")/>
    <#if !formParam?has_content>
        <#local r = m1.log("[REQ][DO][ERR] 필수요청 전문 없음. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {
            "code": "703"
            , "message": "필수요청 전문 없음."
        }/>
    </#if>

    <#-- 검수요청 payload 정의 -->
    <#-- 요청전문 파싱 실패시 빈값처리 -->
    <#local createPayloadResponseMap = innerFunction_parseCreateTemplatePayloadMap(_rcvBody)/>
    <#local createPayloadResponseCode = createPayloadResponseMap.code/>
    <#if createPayloadResponseCode != "200">
        <#return {
            "code": createPayloadResponseCode
            , "message": createPayloadResponseMap.message
        }/>
    </#if>
    <#local payloadMap = createPayloadResponseMap.payload/>

    <#-- 검수요청 header 정의 -->
    <#local createHeaderResponseMap = commonFunction_getRequestHeaderMap(senderKey, {})/>
    <#local createHeaderResponseCode = createHeaderResponseMap.code/>

    <#if createHeaderResponseCode != "200">
        <#return {
            "code": createHeaderResponseCode
            , "message": createHeaderResponseMap.message
        }/>
    </#if>
    <#local headerMap = createHeaderResponseMap.header/>

    <#return {
        "code": "200"
        , "headerMap": headerMap
        , "payloadMap": payloadMap
    }/>

</#function>

<#--  비즈톡센터에서 응답받은 전문을 파싱 함수  -->
<#--
    성공
{
    "code": "200",
    "data": {
        "senderKey": "d556109269a3158ee278ca371662efeffb081b93",
        "senderKeyType": "S",
        "templateCode": "ODI010001",
        "templateName": "템플릿등록테스트001",
        "templateContent": "[어다인]내부 테스트(test)\\r\\n전직원공지사항",
        "inspectionStatus": "REG",
        "createdAt": "2023-09-1316:24:53",
        "modifiedAt": "",
        "status": "K",
        "buttonType": "N",
        "buttonName": "",
        "buttonUrl": "",
        "templateMessageType": "BA",
        "templateEmphasizeType": "NONE",
        "templateExtra": "",
        "templateAd": "",
        "templateTitle": "",
        "templateSubtitle": "",
        "securityFlag": "false",
        "categoryCode": "001001",
        "templateHeader": "",
        "templateImageName": "",
        "templateImageUrl": "",
        "buttons": [],
        "quickReplies": [],
        "templateItemHighlight": {},
        "templateItem": [],
        "templateRepresentLink": [],
        "commentsList": []
    }
}

    실패
{
    "code": "504",
    "message": "하나의 발신프로필에 동일한 템플릿코드를 중복해서 등록할 수 없습니다."
}

-->
<#function taskDoRequestFunction_parseResponseData _seqLocal _payloadMap, _httpResponseBody>
    <#local templateCreateResponseJson = m1.editable(m1.parseJsonValue(_httpResponseBody)!{})/>

    <#local templateCreateResCode = templateCreateResponseJson.code!-999/>

    <#local messagebaseId = ""/>

    <#if templateCreateResCode != "200">
        <#local templateCreateResMessage = templateCreateResponseJson.message!"기타오류"/>

        <#local r = m1.log("[REQ][DO][REQUEST][FAIL] 템플릿검수 요청 실패. @SEQ=[${_seqLocal}] @검수결과코드=[${templateCreateResCode}]", "ERROR")/>
        <#local r = m1.log(templateCreateResponseJson, "ERROR")/>
    <#else>
        <#local templateCreateResMessage = "성공"/>
        <#local templateCode = templateCreateResponseJson.data.templateCode!""/>

        <#local r = m1.log("[REQ][DO][REQUEST][SUCC] 템플릿검수 요청 성공. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @검수결과코드=[${templateCreateResCode}]", "INFO")/>
        <#local r = m1.log(templateCreateResponseJson, "DEBUG")/>

    </#if>

    <#local r = templateCreateResponseJson.put("message", templateCreateResMessage)/>

    <#local r = m1.put(_payloadMap, "TM_SEQ", _seqLocal)/>
    <#local r = m1.put(_payloadMap, "apiResult", templateCreateResponseJson)/>

    <#return _payloadMap/>
</#function>



<#-- 
	템플릿 전문바디 파싱 함수
		- 필수전문 데이터 파싱 후 부가옵션 파싱 및 이미지업로드처리 데이터 파싱
		- 버튼전문의 경우 BUTTON_INFO컬럼의 값을 체크하여 파싱.
		
-->
<#function innerFunction_parseCreateTemplatePayloadMap _requestMap>
	<#if !_requestMap??>
		<#local r = m1.log("[REQ][DO][ERR] 데이터 파싱 중 에러발생. 유입데이터 없음.", "ERROR")/>

		<#return {
			"code": "710"
			, "message": "데이터 파싱 중 에러발생. 유입데이터 없음."
		}/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>
	<#local templateCode = _requestMap.TEMPLATE_ID!""/>
	<#local senderKey = _requestMap.CHANNEL_ID!""/>

	<#local r = m1.log("[REQ][DO] 요청전문 파싱시작. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "DEBUG")/>
	<#local r = m1.log(_requestMap, "DEBUG")/>

	<#local resultMap = m1.new("hash")/>

	<#-- 전문바디 파싱 -->
	<#attempt>
		<#local formParam = m1.parseJsonValue(_requestMap.FORM_PARAM)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] 필수정보 전문내용 데이터 파싱중 에러발생. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {
			"code": "711"
			, "message": "필수정보 전문내용 데이터 파싱중 에러발생."
		}/>
	</#attempt>

	<#--  버튼정보 파싱  -->
	<#attempt>
		<#local buttonInfo = m1.parseJsonValue(_requestMap.BUTTON_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] 버튼정보 전문내용 데이터 파싱중 에러발생. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(buttonInfo, "ERROR")/>

		<#return {
			"code": "712"
			, "message": "버튼정보 전문내용 데이터 파싱중 에러발생."
		}/>
	</#attempt>

	<#--  부가옵션정보 파싱  -->
	<#attempt>
		<#--  데이터 수정을 위해 editable객체로 생성  -->
		<#local optionInfo = m1.parseJsonValue(_requestMap.OPTION_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] 옵션내용 전문내용 데이터 파싱중 에러발생. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(optionInfo, "ERROR")/>

		<#return {
			"code": "713"
			, "message": "옵션내용 전문내용 데이터 파싱중 에러발생."
		}/>
	</#attempt>

	<#--  필수전문 데이터 파싱  -->
	<#local r = m1.put(resultMap, "senderKey", senderKey)/>
	<#local r = m1.put(resultMap, "templateCode", templateCode)/>
	<#local r = m1.put(resultMap, "templateName", _requestMap.TEMPLATE_NAME!"")/>
	<#local r = m1.put(resultMap, "templateMessageType",_requestMap.MESSAGE_TYPE!"BA")/>
	<#local r = m1.put(resultMap, "senderKeyType", "S")/>
	<#local r = m1.put(resultMap, "categoryCode", _requestMap.CATEGORY_CODE!"")/>

	<#local templateContent = formParam.templateContent!""/>
	<#if !templateContent?has_content>
		<#local r = m1.log("[REQ][DO][ERR] 필수값 [템플릿내용] 없음. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {
			"code": "714"
			, "message": "필수값 [템플릿내용] 없음."
		}/>
	</#if>
	<#local templateEmphasizeType = formParam.templateEmphasizeType!""/>
	<#if !templateEmphasizeType?has_content>
		<#local r = m1.log("[REQ][DO][ERR] 필수값 [강조유형] 없음. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>
		
		<#return {
			"code": "715"
			, "message": "필수값 [강조유형] 없음."
		}/>
	<#else>
		<#local templateImageUrl = optionInfo.templateImageUrl!""/>
		
		<#if 
			(templateEmphasizeType == "IMAGE" && (templateImageUrl?has_content || templateImageUrl != "")) 
			|| templateEmphasizeType == "ITEM_LIST"
		>
			<#--  템플릿 강조유형이 IMAGE / ITEM_LIST일 경우 이미지업로드처리  -->

			<#if templateImageUrl?has_content>
				<#--  이미지업로드  -->
				<#local r = m1.log("[REQ][DO][UPLOAD] 이미지 업로드 처리 요청. @이미지PATH=[${templateImageUrl}]", "INFO")/>
				<#local uploadResultMap = innerFunction_uploadImage("${tmplMngrUrl}/v1/image/alimtalk/template", senderKey, templateImageUrl)/>

				<#local uploadResultCode = uploadResultMap.code!"">
				<#if uploadResultCode == "0000">
					<#local uploadImageUrl = uploadResultMap.uploadImageUrl!"">
					<#local r = m1.log("[REQ][DO][IMG] 이미지업로드 성공. @SEQ=[${_seqLocal}] @이미지URL=[${uploadImageUrl}]", "INFO")/>

					<#local optionInfo += {
						"templateImageUrl": uploadImageUrl
					}/>
				<#else>
					<#local message = uploadResultMap.message!"">
					<#local r = m1.log("[REQ][DO][IMG] 이미지업로드 실패. @SEQ=[${_seqLocal}] @결과코드=[${uploadResultCode}] @응답결과=[${message}]", "INFO")/>


					<#return {
						"code": "716"
						, "message": "이미지업로드 실패. [${message}]"
					}/>
				</#if>
			</#if>

			<#-- 아이템리스트형에서 하이라이트아이템 이미지업로드시 이미지업로드 처리 -->
			<#if 
				templateEmphasizeType == "ITEM_LIST"
				&& optionInfo.templateItemHighlight?? 
				&& (optionInfo.templateItemHighlight.imageUrl?? && optionInfo.templateItemHighlight.imageUrl != "")
			>
				<#local highlightImageUrl = optionInfo.templateItemHighlight.imageUrl/>
				<#local r = m1.log("[{TASKNAME}][UPLOAD] 썸네일 이미지 업로드 처리 요청. @이미지PATH=[${highlightImageUrl}]", "INFO")/>

				<#local highlightUploadImageResponseMap = innerFunction_uploadImage("${tmplMngrUrl}/v1/image/alimtalk/itemHighlight", senderKey, highlightImageUrl)/>
				<#local highlightUploadImageResCode = highlightUploadImageResponseMap.code/>
				<#local highlightUploadImageResMessage = highlightUploadImageResponseMap.message/>
				<#local highlightUploadImageUrl = highlightUploadImageResponseMap.uploadImageUrl/>

				<#if highlightImageUrl?? && highlightUploadImageResCode == "0000">
					<#local r = m1.log("[{TASKNAME}][UPLOAD][SUCC] 썸네일이미지 업로드 성공. @응답코드=[${highlightUploadImageResCode}] @업로드이미지URL=[${highlightUploadImageUrl}] @응답메시지=[${highlightUploadImageResMessage}]", "INFO")/>
					
					<#local templateItemHighlightMap = optionInfo.templateItemHighlight/>
					<#local templateItemHighlightMap += {
						"imageUrl": highlightUploadImageUrl
					}/>

					<#local optionInfo += {
						"templateItemHighlight": templateItemHighlightMap
					}/>

				<#else>
					<#local r = m1.log("[{TASKNAME}][UPLOAD][FAIL] 썸네일이미지 업로드 실패. @응답코드=[${highlightUploadImageResCode}] @이미지파일경로=[${highlightImageUrl!''}] @응답메시지=[${highlightUploadImageResMessage}]", "ERROR")/>

					<#-- 이미지업로드 실패처리  -->
					<#return {
						"code": highlightUploadImageResCode
						, "message": highlightUploadImageResMessage!"썸네일이미지 업로드 실패"
					}/>
				</#if>

			</#if>


		<#elseif templateEmphasizeType == "TEXT">
			<#local templateTitle = optionInfo.templateTitle!""/>
			<#if !templateTitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] 강조유형이 'TEXT'일경우 templateTitle값 필수. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
				<#local r = m1.log(optionInfo, "ERROR")/>

				<#return {
					"code": "717"
					, "message": "강조유형이 'TEXT'일경우 templateTitle값 필수."
				}/>
			</#if>
			<#local templateSubtitle = optionInfo.templateSubtitle!""/>
			<#if !templateSubtitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] 강조유형이 'TEXT'일경우 templateSubtitle값 필수. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
				<#local r = m1.log(optionInfo, "ERROR")/>

				<#return {
					"code": "718"
					, "message": "강조유형이 'TEXT'일경우 templateSubtitle값 필수."
				}/>
			</#if>
		<#else>

		</#if>

	</#if>

	<#--  전문바디  -->
	<#list formParam as key, value>
		<#local r = m1.put(resultMap, key, value)/>
	</#list>

	<#--  버튼정보  -->
	<#list buttonInfo as key, value>
		<#--  
			value가 array형식이며 각 배열의 인덱스가 json형식이라면 해당 값을 stringfy하여 넣어줌  
			- editable객체를 사용할 경우 http요청시 타입에 대한 UnsupportedOperationException(Operation supported only on TemplateHashModelEx) 발생.
		-->
		<#if value?is_enumerable>
			<#local valueArr = []/>
			<#list value as row>
				<#if row?is_hash && row?is_hash_ex>
					<#local rowStr = m1.toJsonBytes(row)?string/>
					<#local valueArr = valueArr + [rowStr]/>
				</#if>
			</#list>
		<#else>
			<#local valueArr = []/>
		</#if>
		<#local r = m1.put(resultMap, key, valueArr)/>
	</#list>

	<#--  옵션정보  -->
	<#list optionInfo as key, value>
		<#--  옵션전문에 API요청시 객체형태로 요청할때 stringfy하여 요청해야하는 이슈로 인해서 value를 체크하여 json형식의 경우에는 stringfy해서 넣어줌  -->
		<#if value?is_hash && value?is_hash_ex>
			<#local valueStr = m1.toJsonBytes(value)?string/>
		<#else>
			<#local valueStr = value/>

		</#if>
		<#local r = m1.put(resultMap, key, valueStr)/>
	</#list>

	<#local r = m1.log("[REQ][DO] 데이터 파싱처리 완료. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}]", "INFO")/>
	<#local r = m1.log(resultMap, "DEBUG")/>

	<#return {
		"code": "200"
		, "message": "성공"
		, "payload": resultMap	
	}/>

</#function>

<#-- biz센터 이미지파일 업로드 요청 함수 -->
<#--
	이미지형 및 아이템리스트형 이미지업로드: /v1/image/alimtalk/template
		- 제한 사이즈 : 가로 500px 이상, 가로:세로 비율 2:1
		- 파일형식 및 크기 : jpg, png / 최대 500KB
	아이템리스트형 하이라이트 이미지업로드: /v1/image/alimtalk/itemHighlight
		- 제한 사이즈 : 가로 108px 이상, 가로:세로 비율이 1:1
		- 파일형식 및 크기 : jpg, png / 최대 500KB.
-->
<#function innerFunction_uploadImage _requestUploadFileUrl _senderKey _imagePath>

	<#if !_requestUploadFileUrl?? && !_imagePath??>
		<#local r = m1.log("[${TASKNAME}][UPLOAD][ERR] 이미지업로드 파라미터에러. 파라미터값이 없음. @업로드요청URL=[${_requestUploadFileUrl!''}] @이미지경로=[${_imagePath!''}]", "ERROR") />

		<#return {
			"code": "720"
			, "message": "[M1] 이미지업로드 파라미터에러."
		}/>
	</#if>

	<#local channelList = m1.shareget("channelList")/>
	<#local channelInfo = channelList[_senderKey]!{}/>
	<#if !channelInfo?has_content>
		<#local r = m1.log("[ERR] 발신프로필키에 매핑되는 인증정보 없음. @계정정보=", "ERROR")/>
		<#local r = m1.log(channelList, "ERROR")/>
	</#if>

	<#local siteId = channelInfo.clientId!""/>
	<#local authKey = channelInfo.clientSecret!""/>

	<#local fileUploadHeader = {
		"Content-Type": "multipart/form-data; charset=utf-8",
		"Accept": "*/*",
		"siteid": siteId,
		"auth_key": authKey
	}/>
	
	<#local fileUploadPayloadMap = {
		"image": _imagePath
	}/>

	<#local r = m1.log("[REQ][UPLOAD][IMG] 이미지업로드 요청. @요청URL=[${_requestUploadFileUrl}] @이미지경로=[${_imagePath}]", "DEBUG")/>

	<#local imageUploadResponse = httpRequest.requestHttp(_requestUploadFileUrl, "POST", fileUploadHeader, {}, {}, fileUploadPayloadMap, true)/>
	<#local responseCode = imageUploadResponse.getResponseCode()/>
	
	<#local succBody = imageUploadResponse.getBody()/>
	<#local errBody = imageUploadResponse.getErrorBody()/>

	<#if responseCode != 200 && errBody != "">
		<#local imageUploadResponseJson = errBody/>
	<#else>
		<#local imageUploadResponseJson = succBody/>
	</#if>

	<#local imageUploadResponseJson = m1.parseJsonValue(imageUploadResponseJson)/>
	
	<#local imageUploadResCode = imageUploadResponseJson["code"]!""/>
	<#local uploadImageUrl = imageUploadResponseJson["image"]!""/>

	<#local templateImageName = _imagePath?keep_after_last("/")/>
	<#if uploadImageUrl?? && imageUploadResCode == "0000">
		<#local imageUploadResMessage = "성공"/>
		<#local r = m1.log("[REQ][UPLOAD][IMG] 이미지업로드 성공.", "INFO")/>

		<#return {
			"code": imageUploadResCode
			, "message": imageUploadResMessage
			, "uploadImageUrl": uploadImageUrl
			, "uploadImageName": templateImageName
		}/>
	<#else>
		<#local imageUploadResMessage = imageUploadResponseJson.message!"실패"/>
		<#local r = m1.log("[REQ][UPLOAD][IMG] 이미지업로드 실패. @결과코드=[${imageUploadResCode}] @결과내용=[${imageUploadResMessage}]", "ERROR")/>

		<#return {
			"code": "720"
			, "message": "이미지업로드 실패. [${imageUploadResMessage}]"
		}/>
	</#if>

</#function>
