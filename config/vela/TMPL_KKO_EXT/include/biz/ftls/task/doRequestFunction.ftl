<#--
    �Լ����
        - taskDoRequestFunction_getCreateTemplateUrl: ���ø���Ͽ�û URL ���� �Լ�
        - taskDoRequestFunction_parseRequestData: �����弾�� ��û���� �Ľ� �Լ�
            - innerFunction_parseCreateTemplatePayloadMap : ���ø���� �����ٵ� �Ľ�
		    - innerFunction_uploadImage : �̹������ε� ��û
        - taskDoRequestFunction_parseResponseData: �����弾�Ϳ��� ������� ������ �Ľ� �Լ�
-->

<#--  ���ø���Ͽ�û URL ���� �Լ�  -->
<#function taskDoRequestFunction_getCreateTemplateUrl>

    <#--  API������ �и��Ǿ� ���� �ʾƼ� �������� URL����  -->
    <#local tmplMngrUrl = m1.shareget("tmplMngrUrl")!""/>
    <#local createTemplateUrl = "${tmplMngrUrl}/template/create"/>

    <#return createTemplateUrl/>
</#function>

<#--  �����弾�� ��û���� �Ľ� �Լ�  -->
<#function taskDoRequestFunction_parseRequestData _seqLocal _rcvBody>

    <#if _rcvBody?size == 0>
        <#local r = m1.log("[REQ][DO][ERR] ���� ��ȯ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {
            "code": "701"
            , "message": "���� ��ȯ����."
        }/>
    </#if>

    <#local senderKey = _rcvBody.CHANNEL_ID!""/>
    <#if !senderKey?has_content>
        <#local r = m1.log("[REQ][DO][ERR] ���� �� �߽�������Ű ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {
            "code": "702"
            , "message": "���� �� �߽�������Ű ����."
        }/>
    </#if>

    <#local formParam = m1.parseJsonValue(_rcvBody.FORM_PARAM!"{}")/>
    <#if !formParam?has_content>
        <#local r = m1.log("[REQ][DO][ERR] �ʼ���û ���� ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {
            "code": "703"
            , "message": "�ʼ���û ���� ����."
        }/>
    </#if>

    <#-- �˼���û payload ���� -->
    <#-- ��û���� �Ľ� ���н� ��ó�� -->
    <#local createPayloadResponseMap = innerFunction_parseCreateTemplatePayloadMap(_rcvBody)/>
    <#local createPayloadResponseCode = createPayloadResponseMap.code/>
    <#if createPayloadResponseCode != "200">
        <#return {
            "code": createPayloadResponseCode
            , "message": createPayloadResponseMap.message
        }/>
    </#if>
    <#local payloadMap = createPayloadResponseMap.payload/>

    <#-- �˼���û header ���� -->
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

<#--  �����弾�Ϳ��� ������� ������ �Ľ� �Լ�  -->
<#--
    ����
{
    "code": "200",
    "data": {
        "senderKey": "d556109269a3158ee278ca371662efeffb081b93",
        "senderKeyType": "S",
        "templateCode": "ODI010001",
        "templateName": "���ø�����׽�Ʈ001",
        "templateContent": "[�����]���� �׽�Ʈ(test)\\r\\n��������������",
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

    ����
{
    "code": "504",
    "message": "�ϳ��� �߽������ʿ� ������ ���ø��ڵ带 �ߺ��ؼ� ����� �� �����ϴ�."
}

-->
<#function taskDoRequestFunction_parseResponseData _seqLocal _payloadMap, _httpResponseBody>
    <#local templateCreateResponseJson = m1.editable(m1.parseJsonValue(_httpResponseBody)!{})/>

    <#local templateCreateResCode = templateCreateResponseJson.code!-999/>

    <#local messagebaseId = ""/>

    <#if templateCreateResCode != "200">
        <#local templateCreateResMessage = templateCreateResponseJson.message!"��Ÿ����"/>

        <#local r = m1.log("[REQ][DO][REQUEST][FAIL] ���ø��˼� ��û ����. @SEQ=[${_seqLocal}] @�˼�����ڵ�=[${templateCreateResCode}]", "ERROR")/>
        <#local r = m1.log(templateCreateResponseJson, "ERROR")/>
    <#else>
        <#local templateCreateResMessage = "����"/>
        <#local templateCode = templateCreateResponseJson.data.templateCode!""/>

        <#local r = m1.log("[REQ][DO][REQUEST][SUCC] ���ø��˼� ��û ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @�˼�����ڵ�=[${templateCreateResCode}]", "INFO")/>
        <#local r = m1.log(templateCreateResponseJson, "DEBUG")/>

    </#if>

    <#local r = templateCreateResponseJson.put("message", templateCreateResMessage)/>

    <#local r = m1.put(_payloadMap, "TM_SEQ", _seqLocal)/>
    <#local r = m1.put(_payloadMap, "apiResult", templateCreateResponseJson)/>

    <#return _payloadMap/>
</#function>



<#-- 
	���ø� �����ٵ� �Ľ� �Լ�
		- �ʼ����� ������ �Ľ� �� �ΰ��ɼ� �Ľ� �� �̹������ε�ó�� ������ �Ľ�
		- ��ư������ ��� BUTTON_INFO�÷��� ���� üũ�Ͽ� �Ľ�.
		
-->
<#function innerFunction_parseCreateTemplatePayloadMap _requestMap>
	<#if !_requestMap??>
		<#local r = m1.log("[REQ][DO][ERR] ������ �Ľ� �� �����߻�. ���Ե����� ����.", "ERROR")/>

		<#return {
			"code": "710"
			, "message": "������ �Ľ� �� �����߻�. ���Ե����� ����."
		}/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>
	<#local templateCode = _requestMap.TEMPLATE_ID!""/>
	<#local senderKey = _requestMap.CHANNEL_ID!""/>

	<#local r = m1.log("[REQ][DO] ��û���� �Ľ̽���. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "DEBUG")/>
	<#local r = m1.log(_requestMap, "DEBUG")/>

	<#local resultMap = m1.new("hash")/>

	<#-- �����ٵ� �Ľ� -->
	<#attempt>
		<#local formParam = m1.parseJsonValue(_requestMap.FORM_PARAM)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] �ʼ����� �������� ������ �Ľ��� �����߻�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {
			"code": "711"
			, "message": "�ʼ����� �������� ������ �Ľ��� �����߻�."
		}/>
	</#attempt>

	<#--  ��ư���� �Ľ�  -->
	<#attempt>
		<#local buttonInfo = m1.parseJsonValue(_requestMap.BUTTON_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] ��ư���� �������� ������ �Ľ��� �����߻�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(buttonInfo, "ERROR")/>

		<#return {
			"code": "712"
			, "message": "��ư���� �������� ������ �Ľ��� �����߻�."
		}/>
	</#attempt>

	<#--  �ΰ��ɼ����� �Ľ�  -->
	<#attempt>
		<#--  ������ ������ ���� editable��ü�� ����  -->
		<#local optionInfo = m1.parseJsonValue(_requestMap.OPTION_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] �ɼǳ��� �������� ������ �Ľ��� �����߻�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(optionInfo, "ERROR")/>

		<#return {
			"code": "713"
			, "message": "�ɼǳ��� �������� ������ �Ľ��� �����߻�."
		}/>
	</#attempt>

	<#--  �ʼ����� ������ �Ľ�  -->
	<#local r = m1.put(resultMap, "senderKey", senderKey)/>
	<#local r = m1.put(resultMap, "templateCode", templateCode)/>
	<#local r = m1.put(resultMap, "templateName", _requestMap.TEMPLATE_NAME!"")/>
	<#local r = m1.put(resultMap, "templateMessageType",_requestMap.MESSAGE_TYPE!"BA")/>
	<#local r = m1.put(resultMap, "senderKeyType", "S")/>
	<#local r = m1.put(resultMap, "categoryCode", _requestMap.CATEGORY_CODE!"")/>

	<#local templateContent = formParam.templateContent!""/>
	<#if !templateContent?has_content>
		<#local r = m1.log("[REQ][DO][ERR] �ʼ��� [���ø�����] ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {
			"code": "714"
			, "message": "�ʼ��� [���ø�����] ����."
		}/>
	</#if>
	<#local templateEmphasizeType = formParam.templateEmphasizeType!""/>
	<#if !templateEmphasizeType?has_content>
		<#local r = m1.log("[REQ][DO][ERR] �ʼ��� [��������] ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>
		
		<#return {
			"code": "715"
			, "message": "�ʼ��� [��������] ����."
		}/>
	<#else>
		<#local templateImageUrl = optionInfo.templateImageUrl!""/>
		
		<#if 
			(templateEmphasizeType == "IMAGE" && (templateImageUrl?has_content || templateImageUrl != "")) 
			|| templateEmphasizeType == "ITEM_LIST"
		>
			<#--  ���ø� ���������� IMAGE / ITEM_LIST�� ��� �̹������ε�ó��  -->

			<#if templateImageUrl?has_content>
				<#--  �̹������ε�  -->
				<#local r = m1.log("[REQ][DO][UPLOAD] �̹��� ���ε� ó�� ��û. @�̹���PATH=[${templateImageUrl}]", "INFO")/>
				<#local uploadResultMap = innerFunction_uploadImage("${tmplMngrUrl}/v1/image/alimtalk/template", senderKey, templateImageUrl)/>

				<#local uploadResultCode = uploadResultMap.code!"">
				<#if uploadResultCode == "0000">
					<#local uploadImageUrl = uploadResultMap.uploadImageUrl!"">
					<#local r = m1.log("[REQ][DO][IMG] �̹������ε� ����. @SEQ=[${_seqLocal}] @�̹���URL=[${uploadImageUrl}]", "INFO")/>

					<#local optionInfo += {
						"templateImageUrl": uploadImageUrl
					}/>
				<#else>
					<#local message = uploadResultMap.message!"">
					<#local r = m1.log("[REQ][DO][IMG] �̹������ε� ����. @SEQ=[${_seqLocal}] @����ڵ�=[${uploadResultCode}] @������=[${message}]", "INFO")/>


					<#return {
						"code": "716"
						, "message": "�̹������ε� ����. [${message}]"
					}/>
				</#if>
			</#if>

			<#-- �����۸���Ʈ������ ���̶���Ʈ������ �̹������ε�� �̹������ε� ó�� -->
			<#if 
				templateEmphasizeType == "ITEM_LIST"
				&& optionInfo.templateItemHighlight?? 
				&& (optionInfo.templateItemHighlight.imageUrl?? && optionInfo.templateItemHighlight.imageUrl != "")
			>
				<#local highlightImageUrl = optionInfo.templateItemHighlight.imageUrl/>
				<#local r = m1.log("[{TASKNAME}][UPLOAD] ����� �̹��� ���ε� ó�� ��û. @�̹���PATH=[${highlightImageUrl}]", "INFO")/>

				<#local highlightUploadImageResponseMap = innerFunction_uploadImage("${tmplMngrUrl}/v1/image/alimtalk/itemHighlight", senderKey, highlightImageUrl)/>
				<#local highlightUploadImageResCode = highlightUploadImageResponseMap.code/>
				<#local highlightUploadImageResMessage = highlightUploadImageResponseMap.message/>
				<#local highlightUploadImageUrl = highlightUploadImageResponseMap.uploadImageUrl/>

				<#if highlightImageUrl?? && highlightUploadImageResCode == "0000">
					<#local r = m1.log("[{TASKNAME}][UPLOAD][SUCC] ������̹��� ���ε� ����. @�����ڵ�=[${highlightUploadImageResCode}] @���ε��̹���URL=[${highlightUploadImageUrl}] @����޽���=[${highlightUploadImageResMessage}]", "INFO")/>
					
					<#local templateItemHighlightMap = optionInfo.templateItemHighlight/>
					<#local templateItemHighlightMap += {
						"imageUrl": highlightUploadImageUrl
					}/>

					<#local optionInfo += {
						"templateItemHighlight": templateItemHighlightMap
					}/>

				<#else>
					<#local r = m1.log("[{TASKNAME}][UPLOAD][FAIL] ������̹��� ���ε� ����. @�����ڵ�=[${highlightUploadImageResCode}] @�̹������ϰ��=[${highlightImageUrl!''}] @����޽���=[${highlightUploadImageResMessage}]", "ERROR")/>

					<#-- �̹������ε� ����ó��  -->
					<#return {
						"code": highlightUploadImageResCode
						, "message": highlightUploadImageResMessage!"������̹��� ���ε� ����"
					}/>
				</#if>

			</#if>


		<#elseif templateEmphasizeType == "TEXT">
			<#local templateTitle = optionInfo.templateTitle!""/>
			<#if !templateTitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] ���������� 'TEXT'�ϰ�� templateTitle�� �ʼ�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
				<#local r = m1.log(optionInfo, "ERROR")/>

				<#return {
					"code": "717"
					, "message": "���������� 'TEXT'�ϰ�� templateTitle�� �ʼ�."
				}/>
			</#if>
			<#local templateSubtitle = optionInfo.templateSubtitle!""/>
			<#if !templateSubtitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] ���������� 'TEXT'�ϰ�� templateSubtitle�� �ʼ�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
				<#local r = m1.log(optionInfo, "ERROR")/>

				<#return {
					"code": "718"
					, "message": "���������� 'TEXT'�ϰ�� templateSubtitle�� �ʼ�."
				}/>
			</#if>
		<#else>

		</#if>

	</#if>

	<#--  �����ٵ�  -->
	<#list formParam as key, value>
		<#local r = m1.put(resultMap, key, value)/>
	</#list>

	<#--  ��ư����  -->
	<#list buttonInfo as key, value>
		<#--  
			value�� array�����̸� �� �迭�� �ε����� json�����̶�� �ش� ���� stringfy�Ͽ� �־���  
			- editable��ü�� ����� ��� http��û�� Ÿ�Կ� ���� UnsupportedOperationException(Operation supported only on TemplateHashModelEx) �߻�.
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

	<#--  �ɼ�����  -->
	<#list optionInfo as key, value>
		<#--  �ɼ������� API��û�� ��ü���·� ��û�Ҷ� stringfy�Ͽ� ��û�ؾ��ϴ� �̽��� ���ؼ� value�� üũ�Ͽ� json������ ��쿡�� stringfy�ؼ� �־���  -->
		<#if value?is_hash && value?is_hash_ex>
			<#local valueStr = m1.toJsonBytes(value)?string/>
		<#else>
			<#local valueStr = value/>

		</#if>
		<#local r = m1.put(resultMap, key, valueStr)/>
	</#list>

	<#local r = m1.log("[REQ][DO] ������ �Ľ�ó�� �Ϸ�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}]", "INFO")/>
	<#local r = m1.log(resultMap, "DEBUG")/>

	<#return {
		"code": "200"
		, "message": "����"
		, "payload": resultMap	
	}/>

</#function>

<#-- biz���� �̹������� ���ε� ��û �Լ� -->
<#--
	�̹����� �� �����۸���Ʈ�� �̹������ε�: /v1/image/alimtalk/template
		- ���� ������ : ���� 500px �̻�, ����:���� ���� 2:1
		- �������� �� ũ�� : jpg, png / �ִ� 500KB
	�����۸���Ʈ�� ���̶���Ʈ �̹������ε�: /v1/image/alimtalk/itemHighlight
		- ���� ������ : ���� 108px �̻�, ����:���� ������ 1:1
		- �������� �� ũ�� : jpg, png / �ִ� 500KB.
-->
<#function innerFunction_uploadImage _requestUploadFileUrl _senderKey _imagePath>

	<#if !_requestUploadFileUrl?? && !_imagePath??>
		<#local r = m1.log("[${TASKNAME}][UPLOAD][ERR] �̹������ε� �Ķ���Ϳ���. �Ķ���Ͱ��� ����. @���ε��ûURL=[${_requestUploadFileUrl!''}] @�̹������=[${_imagePath!''}]", "ERROR") />

		<#return {
			"code": "720"
			, "message": "[M1] �̹������ε� �Ķ���Ϳ���."
		}/>
	</#if>

	<#local channelList = m1.shareget("channelList")/>
	<#local channelInfo = channelList[_senderKey]!{}/>
	<#if !channelInfo?has_content>
		<#local r = m1.log("[ERR] �߽�������Ű�� ���εǴ� �������� ����. @��������=", "ERROR")/>
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

	<#local r = m1.log("[REQ][UPLOAD][IMG] �̹������ε� ��û. @��ûURL=[${_requestUploadFileUrl}] @�̹������=[${_imagePath}]", "DEBUG")/>

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
		<#local imageUploadResMessage = "����"/>
		<#local r = m1.log("[REQ][UPLOAD][IMG] �̹������ε� ����.", "INFO")/>

		<#return {
			"code": imageUploadResCode
			, "message": imageUploadResMessage
			, "uploadImageUrl": uploadImageUrl
			, "uploadImageName": templateImageName
		}/>
	<#else>
		<#local imageUploadResMessage = imageUploadResponseJson.message!"����"/>
		<#local r = m1.log("[REQ][UPLOAD][IMG] �̹������ε� ����. @����ڵ�=[${imageUploadResCode}] @�������=[${imageUploadResMessage}]", "ERROR")/>

		<#return {
			"code": "720"
			, "message": "�̹������ε� ����. [${imageUploadResMessage}]"
		}/>
	</#if>

</#function>
