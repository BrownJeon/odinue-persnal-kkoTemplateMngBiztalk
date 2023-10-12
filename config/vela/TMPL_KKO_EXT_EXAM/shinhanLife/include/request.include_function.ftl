<#-- ���� ���� include -->
<#include "config.include_variable.ftl"/>

<#--
�Լ����
	- commonFunction_getProfileKeyInfoMap: �������� ���̺��� �����͸� ��ȸ�Ͽ� �߽����������� �����ϴ� �Լ�
	- commonFunction_getTokenInfo4Memory: biz���Ϳ��� �߱޹��� ��ū������ �޸𸮿� ����ϴ� �Լ�
	- commonFunction_requestTokenInfo: ä�������� �޾Ƽ� biz���Ϳ� ��ū�߱޹޴� �Լ�
	- commonFunction_templateSync2Database: ���ø�����ȭ ó�� �Լ�
	- commonFunction_writeFileQueue4one : ����ť�� 1�� �����ϴ� �Լ�
	- commonFunction_error2writeFileQ : ����ť�� ������ ���� �Լ�
		- innerFunction_flattenFileQueueData : ����ť�� ������ ���� �����ϴ� �Լ�
	- commonFunction_requestGet4ResultList : biz���� GET��û �� ������� ��� �Ľ� �Լ�
		- innerFunction_requestGetResponseMap : biz���� GET��û �Լ�
	- commonFunction_requestHttp4ResultMap : biz���� ��û �� ������� ��ȯ���ִ� �Լ�
		- innerFunction_inputValidation: �Լ� ���ڰ��� ���� ��üũ �Լ�
	- commonFunction_getRequestHeaderMap : HTTP��û�� ���� ������� �����ϴ� �Լ�

-->
<#--  ���뼺�� ���ؼ� SQL������ DBMS ���� ������ ������� �ʵ��� �Ѵ�.  -->

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>


<#--  �������� ���̺��� �����͸� ��ȸ�Ͽ� �߽����������� ����  -->
<#function commonFunction_getProfileKeyInfoMap _sqlConn>

    <#--  �߽����������� ��ȸ ����  -->
    <#local selecProfileKeyInfoQuery = m1.shareget("selecProfileKeyInfoQuery")!""/>

    <#local profileKeyInfoMap = m1.editable({})/>

    <#--  �߽������������� ��ȸ�Ͽ� ������ �ʿ��� ���� ����  -->
    <#local r = m1.log("[INIT][CHANNEL_ID] �߽����������� DB��ȸ.", "INFO")/>

    <#local profileKeyInfoRs = _sqlConn.query2array(selecProfileKeyInfoQuery, {})/>
    <#if (profileKeyInfoRs?size > 0)>
        <#list profileKeyInfoRs as profileKeyInfo>
            <#if !profileKeyInfo?has_content>
                <#local r = m1.log("[INIT][CHANNEL_ID][ERR] ��ȸ�� ������ ����.", "ERROR")/>
            </#if>
            
            <#local profileKey = profileKeyInfo["CHANNEL_ID"]/>
            <#local clientId = profileKeyInfo["AUTH_ID"]/>
            <#local clientSecret = profileKeyInfo["AUTH_KEY"]/>

            <#local expireYn = profileKeyInfo["EXPIRE_YN"]!"N"/>
            <#if expireYn?has_content && expireYn?upper_case == "Y">
                <#local r = m1.log("[INIT][CHANNEL_ID][EXPIRED] ���ܻ����� �߽�������Ű. @�߽�������Ű=[${profileKey}]", "INFO")/>
                <#break/>
            </#if>

            <#local rejectYn = profileKeyInfo["REJECT_YN"]!"N"/>
            <#if  rejectYn?has_content && rejectYn?upper_case == "Y">
                <#local r = m1.log("[INIT][CHANNEL_ID][REJECT] �޸������ �߽�������Ű. @�߽�������Ű=[${profileKey}]", "INFO")/>
                <#break/>
            </#if>

            <#--  �߽�������Ű���� ����  -->
            <#local r = profileKeyInfoMap.put(profileKey, {
                "clientId": clientId
                , "clientSecret": clientSecret
            })/>

        </#list>
        <#local r = m1.log("[INIT][CHANNEL_ID] �߽����������� ���� �Ϸ�. ", "INFO")/>

    <#else>
        <#local r = m1.log("[INIT][CHANNEL_ID] DB�� �߽����������� ����. properties���Ͽ� ������ ���������� �߽����������� ����....", "INFO")/>

        <#local channelListString = m1props.getProperty("templateManage.api.channelList", "")?trim/>

        <#if channelListString != "">
            <#local channelInfoList = channelListString?split(",")/>
            <#list channelInfoList as channelString>
                <#local r = m1.log("[INIT] properties���� ���� �ε�. @ä�θ��=[${channelString}]","INFO")/>
                <#local channelInfo = channelString?split("*^*")/>

                <#local profileKey = channelInfo[0]!""/>
                <#if profileKey != "">
                    <#local r = profileKeyInfoMap.put(profileKey, {
                            "clientId": channelInfo[1]!"",
                            "clientSecret": channelInfo[2]!""
                        }
                    )/>
                </#if>

            </#list>

            <#local r = m1.log("[INIT][CHANNEL_ID] properties������ ���� �߽����������� ���� �Ϸ�.", "INFO")/>
        <#else>
            <#local r = m1.log("[INIT][ERR] properties���� ���� ����.", "INFO")/>

        </#if>

    </#if>
    <#local r = m1.log(profileKeyInfoMap, "DEBUG")/>

	<#local r = _sqlConn.close(profileKeyInfoRs)/>

    <#return profileKeyInfoMap/> 
	
</#function>


<#--  
	biz���Ϳ��� �߱޹��� ��ū������ �޸𸮿� ����ϴ� �Լ�
	parameter
		- channelList: {
			�߽�������Ű: {
				"clientId": ��������
				, "clientSecret": ����Ű
			}
		}
	return
		- {
			"code": ����ڵ�
			, "message": �������
		}
-->
<#function commonFunction_getTokenInfo4Memory channelList>
	<#--  �������� ��� ��ū�� ������� �ʰ� ������ �߱޹��� ���������� ����Ͽ� api��û���� ���� ��ū�߱� ���ʿ�  -->
	<#local result = {
		"code": "600"
		, "message": "������ �Լ�"
	}/>

	<#return result/>
</#function>

<#--
	ä�������� �޾Ƽ� biz���Ϳ� ��ū�߱޹޴� �Լ�
	parameter
		- channelList: {
			"clientId": ��������
			, "clientSecret": ����Ű
		}
	return
		- {
			"code": ����ڵ�
			, "message": �������
			, "data": {
				"accessToken": ��ū����
				, "expiredIn": ����ð�
			}
		}
-->
<#function commonFunction_requestTokenInfo channelInfo>
	<#--  �������� ��� ��ū�� ������� �ʰ� ������ �߱޹��� ���������� ����Ͽ� api��û���� ���� ��ū�߱� ���ʿ�  -->
	<#local result = {
		"code": "600"
		, "message": "������ �Լ�"
	}/>

	<#return result/>

</#function>

<#--  
	���ø�����ȭ �Լ�  
		- biz������ ���ø������� ��ȸ�Ͽ� DBó���ϴ� �Լ�
	parameter
		- channelList: 
	return
		- {
			"code": ����ڵ�
			, "message": �������
		}
-->
<#function commonFunction_templateSync2Database>
    <#--  �������� ��� ���ø���� ��ȸ�� �Ұ��Ͽ� �����弾�Ϳ� ��ϵǾ� �ִ� ���ø��� ��ȸ�� �� ��� ����ȭ��� ������  -->
	<#local result = {
		"code": "600"
		, "message": "������ �Լ�"
	}/>

	<#return result/>
</#function>


<#-- ����ť�� 1�� �����ϴ� �Լ� -->
<#function commonFunction_writeFileQueue4one _fq _bodyMap _procName _targetFileQueueName>
    <#--return(1: ó��, -1: ��õ�, -9:�ý��� ����)-->
    <#local clear = 1/>
    <#local retry = -1/>
    <#local systemExit = -9/>

    <#if !_bodyMap?has_content>
	    <#local r = m1.log("[FQ][WRITE][ERROR] ó������ ����. ", "ERROR")/>
	    <#local r = m1.log(_bodyMap, "ERROR")/>

        <#return systemExit/>
    </#if>

    <#local rsByteSequence = innerFunction_flattenFileQueueData(_bodyMap, _procName, _targetFileQueueName)/>

	<#local fret = _fq.write1(_targetFileQueueName, 0, rsByteSequence)/>
    <#if (fret == 0)>
        <#local r = m1.log("[FQ][WRITE][SUCC] ����ť ���� �Ϸ�. @�߼ۼ��������ĺ���=[${_bodyMap.TM_SEQ}]", "INFO")/>
    	<#local r = m1.log(header, "DEBUG")/>
        <#local r = m1.log(bytes, "DEBUG")/>

        <#return clear/>

    <#else>
        <#local r = m1.log("[FQ][WRITE][ERR] ����ť ���� ����. ���μ�������... r=[${fret}]","FATAL")/>

        <#return systemExit/>
    </#if>
</#function>


<#-- ����ť�� ������ ���� �Լ� -->
<#function commonFunction_error2writeFileQ _fq _seqLocal _errorCode _errorMsg _procName _targetFileQueueName>
    <#--return(1: ó��, -1: ��õ�, -9:�ý��� ����)-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

    <#-- ����ó��  -->
    <#local fail_bodyMap = {
        "TM_SEQ": _seqLocal
        , "apiResult": {
            "error": {
                "code": _errorCode,
                "message": _errorMsg
            }
        }
    }/>

    <#local rsByteSequence = innerFunction_flattenFileQueueData(fail_bodyMap, _procName, _targetFileQueueName)/>

    <#local fret = _fq.write1(_targetFileQueueName, 0, rsByteSequence)/>
    <#if fret == 0>
        <#local r = m1.log("[FQ][WRITE][SUCC] ����ť ���� �Ϸ�. @�߼ۼ��������ĺ���=[${_seqLocal}]", "INFO")/>
    	<#local r = m1.log(header, "DEBUG")/>
        <#local r = m1.log(bytes, "DEBUG")/>

        <#return clear/>

    <#else>
        <#local r = m1.log("[FQ][WRITE][ERR] ����ť ���� ����. ���μ�������... r=[${fret}]","FATAL")/>

        <#return systemExit/>
    </#if>
</#function>


<#-- ����ť�� ������ ���� �����ϴ� �Լ� -->
<#function innerFunction_flattenFileQueueData _dataMap _procName _targetFileQueueName>
	<#local bytes=m1.toJsonBytes(_dataMap)/>

	<#local r = m1.log("[FQ][FLAT][START] ����ť �������� ó�� ����.", "INFO")/>

	<#local _seqLocal = _dataMap.TM_SEQ/>

	<#local header = {
		"�߼ۼ��������ĺ���": _seqLocal,
		"������������":"",
		"��������":"20",
		"�������α׷�����":_procName,
		"�ŷ�����":"",
		"�����Ͻ�":ymdhms,
		"�����ڵ�":"00",
		"�Ҵ�߼۰��ĺ���":_targetFileQueueName,
		"����":"",
		"������������":bytes?size
	} />

	<#local resultBs=m1.new("bytes",100+bytes?size)/>

	<#local r=m1.flatten(header,"FWXHEADER",resultBs)/>
	<#local r=m1.arraycopy(bytes, 0, resultBs, 100, bytes?size)/>

	<#local r = m1.log("[FQ][FLAT][SUCC] ����ť �������� ó���Ϸ�. @�߼ۼ��������ĺ���=[${_seqLocal}]", "INFO")/>
	<#local r = m1.log(header, "DEBUG")/>
	<#local r = m1.log(_dataMap, "DEBUG")/>

	<#return resultBs/>
</#function>

<#--  �Լ� ���ڰ��� ���� ��üũ �Լ�  -->
<#function innerFunction_inputValidation _checkParamMap>

	<#list _checkParamMap as field, value>
		<#if
			((value?is_hash || value?is_hash_ex) && !value?has_content )
			|| 
			(value?is_string && value == "")
		>
			<#local r = m1.log("[BIZ][REQ][ERR] ${field} ����. @${field}=[${m1.toJsonBytes(value)}]", "ERROR")/>

			<#return {
				"code": "750"
				, "message": "${field} ����."
			}/>
		</#if>

	</#list>

	<#return {
		"code": "200"
		, "message": "����"
	}/>
</#function>

<#--  biz���� POST��û �Լ�  -->
<#function commonFunction_requestHttp4ResultMap _requestUrl _methodType _headerMap _urlParamMap _payloadMap _uploadFileMap>
	<#--  http��û�� �ʼ����� ���� ���ڰ� üũ �Լ�  -->
	<#local validationData =   innerFunction_inputValidation({
		"��ûURL": _requestUrl
		, "��ûmethod": _methodType
		, "��û���": _headerMap
		, "��û�ٵ�": _payloadMap
	})/>
	<#local validationCode = validationData.code!"999"/>

	<#if validationCode != "200">
		<#local validationMsg = validationData.message!"��Ÿ����"/>
		<#return {
			"code": validationCode
			, "message": validationMsg
		}/>
	<#else>
	</#if>

	<#--
		�������� ��� POST�޼��� ��û
		- body�κ��� ��� urlEncoding���� parameter�� �����ؾ� ���������� ó�� ��.
	-->
	<#assign httpResponse = httpRequest.requestHttp(_requestUrl, "POST", _headerMap, _urlParamMap, _payloadMap, _uploadFileMap, false)/>

	<#assign responseCode = httpResponse.getResponseCode()/>
	<#assign succBody = httpResponse.getBody()/>
	<#assign errBody = ttpResponse.getErrorBody()/>

	<#if responseCode != 200 && errBody != "">
		<#assign httpResponseBody = errBody/>
	<#else>
		<#assign httpResponseBody = succBody/>
	</#if>

	<#return {
		"code": "200"
		, "message": "����"
		, "data": httpResponseBody
	}/>

</#function>


<#-- HTTP��û�� ���� ������� ���� �Լ� -->
<#function commonFunction_getRequestHeaderMap _senderKey _extraParamMap>

	<#local r = m1.log("[REQ][DO] ��û���� ������� �Ľ̽���. @�߽�������Ű=[${_senderKey}]", "DEBUG")/>

	<#local headerMap = m1.new("hash")/>

	<#local channelList = m1.shareget("channelList")/>
	<#local channelInfo = channelList[_senderKey]!{}/>
	<#if !channelInfo?has_content>
		<#local r = m1.log("[ERR] �߽�������Ű�� ���εǴ� �������� ����. @��������=", "ERROR")/>
		<#local r = m1.log(channelList, "ERROR")/>

		<#return {
			"code": "719"
			, "message": "�߽�������Ű�� ���εǴ� �������� ����."
		}/>
	</#if>

	<#local siteId = channelInfo.clientId!""/>
	<#local authKey = channelInfo.clientSecret!""/>
    
	<#-- �⺻ ������� ����  -->
	<#--  
		�������� ��� body�� ���� �־ ��û�� ����� Content-Type ����
		- application/x-www-form-urlencoded
		- multipart/form-data
	-->
	<#local r = m1.put(headerMap, "Content-Type", "application/x-www-form-urlencoded; charset=utf-8")/>
	<#local r = m1.put(headerMap, "Accept", "application/json, */*")/>
	<#local r = m1.put(headerMap, "siteid", siteId)/>
	<#local r = m1.put(headerMap, "auth_key", authKey)/>

    <#-- �߰��Ǵ� ���� �߰� ���� -->
    <#list _extraParamMap as extField, extValue>
        <#if extField?has_content && extValue?has_content>
			<#local r = m1.put(headerMap, extField, extValue)/>
        <#else>
            <#local r = m1.log("[ERR] �߰����� �� ����. @extField=[${extField}] @extValue=[${extValue}]", "ERROR")/>
        </#if>
    </#list>

	<#local r = m1.log("[REQ][DO] ��û���� ������� �Ľ̿Ϸ�. @�߽�������Ű=[${_senderKey}]", "INFO")/>
	<#local r = m1.log(headerMap, "DEBUG")/>

    <#return {
		"code": "200"
		, "message": "����"
		, "header": headerMap	
	}/>
</#function>


<#-- 
	���ø� �����ٵ� �Ľ� �Լ�
		- �ʼ����� ������ �Ľ� �� �ΰ��ɼ� �Ľ� �� �̹������ε�ó�� ������ �Ľ�
		- ��ư������ ��� BUTTON_INFO�÷��� ���� üũ�Ͽ� �Ľ�.
		
-->
<#function __commonFunction_parseCreateTemplatePayloadMap _requestMap>
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
<#function __innerFunction_uploadImage _requestUploadFileUrl _senderKey _imagePath>

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
