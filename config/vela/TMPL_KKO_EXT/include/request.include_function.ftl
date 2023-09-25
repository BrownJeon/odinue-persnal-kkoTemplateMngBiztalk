<#-- ���� ���� include -->
<#include "config.include_variable.ftl"/>

<#--
�Լ����
	- commonFunction_getClientInfo: DB���� ��ȸ�� �߽�������Ű������ ���ؼ� ������ �ʿ��� ���� ����
	- commonFunction_writeFileQueue4one : ����ť�� 1�� �����ϴ� �Լ�
	- commonFunction_writeFileQueue4N : ����ť�� �ٰ� �����ϴ� �Լ�
	- commonFunction_error2writeFileQ : ����ť�� ������ ���� �Լ�
		- innerFunction_flattenFileQueueData : ����ť�� ������ ���� �����ϴ� �Լ�
	- commonFunction_requestGet4ResultList : biz���� GET��û �� ������� ��� �Ľ� �Լ�
		- innerFunction_requestGetResponseMap : biz���� GET��û �Լ�
	- commonFunction_requestGet4ResultMap : biz���� GET��û �� ������� �ܰ� �Ľ� �Լ�
	- commonFunction_getRequestHeaderMap : HTTP��û�� ���� ������� �����ϴ� �Լ�
	- commonFunction_getCreateTemplateUrl : ������������ ���ø���� API url üũ
	- commonFunction_requestTokenInfo : ��ū ��û �Լ�
	- commonFunction_parseCreateTemplatePayloadMap : ���ø���� �����ٵ� �Ľ�
		- innerFunction_getParseImagePayloadMap : �̹������ø� ��û���� �Ľ� (only v2 API�� ��û)
			- innerFunction_uploadImage : �̹������ε� ��û
		- innerFunction_createTemplateId : custTmpltId ���� �Լ�(����/���� 25�� �̳�)
	- commonFunction_kko2dbSync: biz���� ����ȭó�� �Լ�
		- innerFunction_formIdInfoDetail2DB: ���̽���ID �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó��
		- innerFunction_commonTemplateInfoDetail2DB : �������ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó��
		- innerFunction_kkoTemplateInfoDetail2DB : ����/���δ�� ���ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó��
		- innerFunction_rcsBrandIdSimple2DB : �귣��ID ��ȸ�� ���� ���� ������ DBó��
		- innerFunction_chatbotIdDetail2DB : ê��ID ��ȸ�� ���� ���� ������ DBó��
-->
<#--  ���뼺�� ���ؼ� SQL������ DBMS ���� ������ ������� �ʵ��� �Ѵ�.  -->

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>


<#--  �߽�������Ű���� ����  -->
<#function commonFunction_getClientInfo _profileKeyInfo _authInfo>
    <#local profileKey = _profileKeyInfo["PROFILE_KEY"]!""/>

    <#return {  
		"clientId": _authInfo.clientId!""
		, "clientSecret": _authInfo.clientSecret!""
    }/>

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

<#--  ����ť�� �ٰ� �����ϴ� �Լ�  -->
<#function commonFunction_writeFileQueue4N _fq _bodyMap _procName _targetFileQueueName>
    <#--return(1: ó��, -9:�ý��� ����)-->
    <#local clear = 1/>
    <#local systemExit = -9/>

    <#if !_bodyMap?has_content>
	    <#local r = m1.log("[FQ][WRITE][ERROR] ó������ ����. ", "ERROR")/>
	    <#local r = m1.log(_bodyMap, "ERROR")/>

        <#return systemExit/>
    </#if>

    <#local rsByteSequence = innerFunction_flattenFileQueueData(_bodyMap, _procName, _targetFileQueueName)/>

	<#local fret = _fq.writeN(_targetFileQueueName, 0, [rsByteSequence])/>
    <#if (fret == 0)>
        <#local r = m1.log("[FQ][WRITE][SUCC] ����ť ���� �Ϸ�. @�߼ۼ��������ĺ���=[${_bodyMap.TM_SEQ}]", "INFO")/>
    	<#local r = m1.log(header, "DEBUG")/>
        <#local r = m1.log(rsByteSequence, "DEBUG")/>

        <#local r = _fq.readCommit()/>

        <#return clear/>

    <#else>
        <#local r = m1.log("[FQ][WRITE][ERR] ����ť ���� ����. ���μ�������... r=[${fret}]","FATAL")/>

        <#local r = _fq.readRollback()/>

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


<#-- biz���� GET��û �Լ� -->
<#function innerFunction_requestGetResponseMap _token _requestUrl>
	<#if !_requestUrl?has_content>
		<#local r = m1.log("[BIZ][REQ][ERR] ��ûURL ����. @��ûURL=[${_requestUrl}] @method=[GET]", "ERROR")/>

		<#return []/>
	</#if>

	<#local r = m1.log("[BIZ][REQ][START] biz���� ��ûó�� ����. @method=[GET]", "INFO")/>
	<#local r = m1.log("@��ûURL=[${_requestUrl}]", "DEBUG")/>

	<#-- ��û headerMap ���� -->
	<#assign headerMap = commonFunction_getRequestHeaderMap({})/>

	<#-- ���ø���� ��ȸ API -->
	<#local httpResponseCode=httpObj.get(_requestUrl, headerMap)!-1/>
    <#if httpResponseCode != 200>
		<#local r = m1.log("[BIZ][REQ][FAIL] biz���� ��û ����. @�����ڵ�=[${httpResponseCode}]", "ERROR")/>

		<#return {}/>
	</#if>

    <#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

    <#local responseBody = m1.parseJsonValue(httpResponseBody)/>

	<#if httpResponseCode == 200>
		<#local r = m1.log("[BIZ][REQ][SUCC] biz���� HTTP��û ����. @�����ڵ�=[${httpResponseCode}]", "DEBUG")/>
	<#else>
		<#local r = m1.log("[BIZ][REQ][ERR] biz���� HTTP��û ����. @�����ڵ�=[${httpResponseCode}]", "ERROR")/>
	</#if>

    <#return responseBody/>
</#function>

<#-- biz���� GET��û �� ������� �ܰ� �Ľ� �Լ� -->
<#function commonFunction_requestGet4ResultMap _token _requestUrl>

    <#-- biz���� GET request��û �Լ� -->
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "API_200">
        <#local requestStatus = "����"/>

		<#local apiResult = responseBody.data![]/>
        <#if apiResult?has_content>
            <#local resultMap = apiResult[0]/>

        <#else>
            <#local resultMap = {}/>
        </#if>

	<#else>
        <#local requestStatus = "����"/>
		<#local r = m1.log(responseBody, "ERROR")/>

        <#local resultMap = {}/>
	</#if>

	<#local r = m1.log("[BIZ][REQ][END] biz���� ��ûó�� �Ϸ�. @ó�����=[${requestStatus}]", "INFO")/>
	<#local r = m1.log("@��ûURL=[${_requestUrl}]", "DEBUG")/>
    <#local r = m1.log(responseBody, "DEBUG")/>

	<#return resultMap/>
</#function>

<#-- biz���� GET��û �� ������� ��� �Ľ� �Լ� -->
<#--  BIZ��û�� paginationó���� ���� ���� -->
<#function commonFunction_requestGet4ResultList _token _requestUrl>

	<#local resultList = m1.editable([])/>

    <#-- biz���� GET request��û �Լ� -->
	<#local r = m1.log("[BIZ][REQ][0] biz���� ��ûó��... @��ûURL=[${_requestUrl}]", "INFO")/>
	
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "API_200">
        <#local requestStatus = "����"/>

		<#local apiResult = responseBody.data![]/>
        <#if apiResult?has_content>
			<#list apiResult as resultMap>
            	<#local r = resultList.put(resultMap)/>
			</#list>

        </#if>

		<#-- pagination���� ���� -->
		<#local responsePage = responseBody.page!-1/>
		<#local responseTotalPage = responseBody.totalPage!-1/>

		<#local hasNext = responseBody.hasNext!false/>

		<#--  �߰� ��û������ ���� ���� üũ  -->
		<#if hasNext && (responsePage < responseTotalPage)>
			<#local requestLoopCnt = responseTotalPage - responsePage/>
			<#list 1..requestLoopCnt as cnt>

				<#local currentPage = responsePage/>

				<#--
					���ø���ȸ�� ����¡ ���ǰ�
						startDate : �˻� ���۳�¥
						endDate : �˻� ���ᳯ¥
						~~ inspectionStatus : �˼� ���� (REG:���, REQ:�ɻ��û, APR:����, REJ: �ݷ�) ~~
						kepStatus : �˼� ����(N:Not Yet ����������������, I:�˼� ������, O:OK ���, R:Reject �ݷ�)
						rows : �������� row��
						limit : �˻� ���� ��
						page : page��ȣ
				-->

				<#--  next�� �Ѿ�� ���� http:// �̱⿡ ��û�� 301���� �߻�. https:// �� �����Ͽ� ��û�ϴ� ������ URL����  -->
				<#local nextRequestUrl = _requestUrl + "?rows=100&page=${currentPage}"/>

				<#local r = m1.log("[BIZ][REQ][${cnt}] ���� ������ ��ûó��... @������ûURL=[${nextRequestUrl}]", "INFO")/>
				<#local nextResponseBody = innerFunction_requestGetResponseMap(_token, nextRequestUrl)/>
				<#local responseCode = nextResponseBody.code!""/>
				<#if responseCode == "API_200">
					<#local requestStatus = "����"/>

					<#local apiResult = nextResponseBody.data![]/>
					<#if 
						apiResult?has_content 
						&& (apiResult.kepStatus == "O" || apiResult.kepStatus == "I")
						&& (apiResult.templateStatus == "A" || apiResult.templateStatus == "R")
					>
						<#--  biz������ ���ø� �߿� �˼��Ϸ�(O), �˼���(I) ������ ���ø��� ��Ͽ� �߰�  -->
						<#list apiResult as resultMap>
							<#local r = resultList.put(resultMap)/>
						</#list>

					</#if>

					<#local nextResponsePage = nextResponseBody.page!-1/>

					<#local hasNext = nextResponseBody.hasNext!false/>
					<#if !hasNext>
						<#break/>
					</#if>

				<#else>
					<#local requestStatus = "����"/>
				</#if>

				<#local r = m1.log("[BIZ][REQ][END] ���� ������ ��ûó�� �Ϸ�. @ó�����=[${requestStatus}] @��ûURL=[${nextRequestUrl}]", "INFO")/>
			</#list>

		</#if>

	<#else>
        <#local requestStatus = "����"/>
		<#local r = m1.log(responseBody, "ERROR")/>

	</#if>

	<#local r = m1.log("[BIZ][REQ][END] biz���� ��ûó�� �Ϸ�. @ó�����=[${requestStatus}] @��ûURL=[${_requestUrl}]", "INFO")/>
    <#local r = m1.log(resultList, "DEBUG")/>

	<#return resultList/>
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
	</#if>

	<#local siteId = channelInfo.clientId!""/>
	<#local authKey = channelInfo.clientSecret!""/>
    
	<#-- �⺻ ������� ����  -->
	<#local r = m1.put(headerMap, "Content-Type", "application/json; charset=utf-8")/>
	<#local r = m1.put(headerMap, "Accept", "application/json, text/plain, */*")/>
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
	<#local r = m1.log(headerMap, "INFO")/>


    <#return headerMap/>
</#function>

<#-- ��ū ��û �Լ� -->
<#-- �޸𸮿� ��ū�� �����ϸ� ����ð��� ������ ��� �ش� ��ū�� �״�� ��� -->
<#-- �޸𸮿� ��ū������ ���ų� ����Ǿ��� ��� �ٽ� ��ū�� �߱޹޾Ƽ� �޸𸮿� ���� -->
<#-- 
	TODO. �������� ��� �������� ��� 
	�ش� ������ īī����ũ�� ��ū�߱� ����
-->
<#function commonFunction_requestTokenInfo _channelInfo>
	<#if !_channelInfo?has_content>
		<#local r = m1.log("ä������ ����...", "ERROR")/>
		<#return {
			"code": 500
		}/>
	</#if>

    <#local header = {
        "Content-Type" : "application/json; charset=utf-8",
        "Accept" : "application/json, text/plain, */*",
		"Authorization": "Basic ${_channelInfo.clientId} ${_channelInfo.clientSecret}"
    }/>

    <#local payloadMap = {}/>

	<#local payload = m1.toJsonBytes(payloadMap)?string/>
	<#local bcbytes = m1.getBytes(payload, "UTF-8")/>
	
	<#local httpResponseCode = httpObj.post("${tmplMngrUrl}/oauth/token", bcbytes, 0, bcbytes?size, header)!-1/>
	<#if httpResponseCode != 200>
		<#local r = m1.log("[BIZ][REQ][FAIL] ��ū�߱� ��û ����. @�����ڵ�=[${httpResponseCode}]", "ERROR")/>
		<#local r = m1.log(httpObj.responseData, "ERROR")/>

		<#return clear/>
	</#if>

	<#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

	<#local body=m1.parseJsonValue(httpResponseBody)/>

	<#if httpResponseCode?starts_with("API_")>
		<#local responseCode = httpResponseCode?substring(3)/>
	</#if>

    <#return {
        "code": responseCode
        , "accessToken": body.access_token!""
        , "expiresIn": body.expires_in!0
    }/>

</#function>


<#-- 
	���ø� �����ٵ� �Ľ� �Լ�
		- �ʼ����� ������ �Ľ� �� �ΰ��ɼ� �Ľ� �� �̹������ε�ó�� ������ �Ľ�
		- ��ư������ ��� BUTTON_INFO�÷��� ���� üũ�Ͽ� �Ľ�.
		
		
-->
<#function commonFunction_parseCreateTemplatePayloadMap _requestMap>
	<#if !_requestMap??>
		<#local r = m1.log("[REQ][DO][ERR] ������ �Ľ� �� �����߻�. ���Ե����� ����.", "ERROR")/>
		<#return {}/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>
	<#local templateCode = _requestMap.TEMPLATE_ID!""/>

	<#local r = m1.log("[REQ][DO] ��û���� �Ľ̽���. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "DEBUG")/>
	<#local r = m1.log(_requestMap, "DEBUG")/>

	<#local resultMap = m1.new("hash")/>

	<#-- �����ٵ� �Ľ� -->
	<#attempt>
		<#local formParam = m1.parseJsonValue(_requestMap.FORM_PARAM)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] �ʼ����� �������� ������ �Ľ��� �����߻�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {}/>
	</#attempt>

	<#--  �ʼ����� ������ �Ľ�  -->
	<#local r = m1.put(resultMap, "senderKey", _requestMap.CHANNEL_ID!"")/>
	<#local r = m1.put(resultMap, "templateCode", templateCode)/>
	<#local r = m1.put(resultMap, "templateName", _requestMap.TEMPLATE_NAME!"")/>
	<#local r = m1.put(resultMap, "templateMessageType",_requestMap.MESSAGE_TYPE!"BA")/>
	<#local r = m1.put(resultMap, "senderKeyType", "S")/>
	<#local r = m1.put(resultMap, "categoryCode", _requestMap.CATEGORY_CODE!"")/>

	<#local templateContent = formParam.templateContent!""/>
	<#if !templateContent?has_content>
		<#local r = m1.log("[REQ][DO][ERR] �ʼ��� [���ø�����] ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {}/>
	</#if>
	<#local templateEmphasizeType = formParam.templateEmphasizeType!""/>
	<#if !templateEmphasizeType?has_content>
		<#local r = m1.log("[REQ][DO][ERR] �ʼ��� [��������] ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>
		
		<#return {}/>
	<#else>
		<#local templateImageUrl = formParam.templateImageUrl!""/>
		
		<#if (templateEmphasizeType == "IMAGE" || templateEmphasizeType == "ITEM_LIST") && !templateImageUrl?has_content>
			<#--  ���ø� ���������� IMAGE / ITEM_LIST�� ��� �̹������ε�ó��  -->
			<#--  TODO. ���������� �̹������ε� ����� �̱������� ���� Ȯ���ʿ�  -->
			<#local imageParamMap = innerFunction_getParseImagePayloadMap(templateImageUrl)/>

		<#elseif templateEmphasizeType == "TEXT">
			<#local templateTitle = formParam.templateTitle!""/>
			<#if !templateTitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] ���������� 'TEXT'�ϰ�� templateTitle�� �ʼ�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
				<#local r = m1.log(formParam, "ERROR")/>

				<#return {}/>
			</#if>
			<#local templateSubtitle = formParam.templateSubtitle!""/>
			<#if !templateSubtitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] ���������� 'TEXT'�ϰ�� templateSubtitle�� �ʼ�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
				<#local r = m1.log(formParam, "ERROR")/>

				<#return {}/>
			</#if>
		<#else>

		</#if>

	</#if>

	<#list formParam as key, value>
		<#local r = m1.put(resultMap, key, value)/>
	</#list>

	<#--  ��ư���� �Ľ�  -->
	<#attempt>
		<#local buttonInfo = m1.parseJsonValue(_requestMap.BUTTON_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] ��ư���� �������� ������ �Ľ��� �����߻�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(buttonInfo, "ERROR")/>

		<#return {}/>
	</#attempt>
	<#local r = m1.put(resultMap, "buttons", buttonInfo)/>

	<#--  �ΰ��ɼ����� �Ľ�  -->
	<#attempt>
		<#local optionInfo = m1.parseJsonValue(_requestMap.OPTION_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] �ɼǳ��� �������� ������ �Ľ��� �����߻�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @��������=", "ERROR")/>
		<#local r = m1.log(optionInfo, "ERROR")/>

		<#return {}/>
	</#attempt>
	<#list optionInfo as key, value>
		<#local r = m1.put(resultMap, key, value)/>
	</#list>

	<#local r = m1.log("[REQ][DO] ������ �Ľ�ó�� �Ϸ�. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}]", "INFO")/>
	<#local r = m1.log(resultMap, "INFO")/>

	<#return resultMap/>

</#function>


<#--
	�̹������ε� �� ���� �Ľ� �Լ�
-->
<#function innerFunction_getParseImagePayloadMap _messagebaseformId _requestMap>

    <#return 1/>
</#function>


<#-- biz���� �̹������� ���ε� ��û �Լ� -->
<#function innerFunction_uploadImage _requestMap>
	

    <#return 1/>

</#function>


<#--
	1. biz���Ϳ� ����ȭó�� ���� �����ȸ
	2. ����� loop���鼭 �� ������ ���� BIZ ������ ��ȸ
	3. �󼼳�����ȸ ���� ���� ������ �Ľ�
	4. �󼼳�����ȸ ����� ���� DBó�� (insert / update)

-->
<#--
	BIZ ����ȭó�� ��ü spec
	{
		"token": ��ū���� (������ ���� ��� �ش� �ʵ� ����)
		, "sqlConn": SQL��ü
		, "query": {
			"selectQuery": ��ȸ����
			, "updateQuery": update����
			, "insertQuery": ��������
		}
		, "requestUrl": ��û ���̽�URL (ex: "${tmplMngrUrl}/brand/${brandId}/messagebase")
	}
-->
<#function commonFunction_kko2dbSync _syncType _syncParamMap>
	<#if !_syncParamMap?has_content>
		<#local r = m1.log("[BIZ][SYNC][ERR] biz���� ����ȭó�� �Ķ���� ������ ����.", "ERROR")/>

		<#return {}/>
	<#elseif 
		!_syncParamMap.sqlConn?has_content
		|| !_syncParamMap.query?has_content
		|| !_syncParamMap.requestUrl?has_content
	>
		<#local r = m1.log("[BIZ][SYNC][ERR] biz���� ����ȭó�� �Ķ���� ������ ����. @��ûŸ��=[${_syncType}]", "ERROR")/>
    	<#local r = m1.log(_syncParamMap, "DEBUG")/>

		<#return {}/>
	</#if>

	<#local requestBaseUrl = _syncParamMap.requestUrl!""/>
	<#local sqlConn = _syncParamMap.sqlConn!""/>
	<#local queryMap = _syncParamMap.query!{}/>

	<#local procMap = m1.editable({
		"insertCnt": 0
		, "updateCnt": 0
		, "passCnt": 0
		, "failCnt": 0
	})/>

	<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
	<#assign profileKeyInfoMap = m1.shareget("profileKeyInfoMap")![]/>
	<#if !profileKeyInfoMap?has_content>
		<#assign r = m1.log("[CONF][BRAND_ID][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

		<#return {
			"code": "301"
			, "message": "API-KEY���� ����"
		}/>

	<#else>
		<#list profileKeyInfoMap as profileKey, clientInfo>
			<#assign clientId = clientInfo.clientId!""/>
			<#assign clientSecret = clientInfo.clientSecret!""/>

			<#if clientId?has_content && clientSecret?has_content>
				<#assign token = _syncParamMap.token!""/>
				
				<#-- biz���Ϳ� ����ȭó�� ���� �����ȸ -->
				<#local r = m1.log("[BIZ][SYNC][REQ] biz���� ����ȭ���� ��� ��ȸ.", "DEBUG")/>

				<#local BizSearchApiResultList = commonFunction_requestGet4ResultList(token, requestBaseUrl)/>
				<#local r = m1.log(BizSearchApiResultList, "DEBUG")/>

				<#if BizSearchApiResultList?has_content>
					<#list BizSearchApiResultList as BizSearchApiResult>
						<#-- BIZ���� ��ȸ�� ���̽���ID ����� ���� �󼼳��� api��ȸ�Ͽ� DB�� ����ȭó�� -->
						<#switch _syncType?upper_case>
							<#case "PROFILE_KEY">
								<#--  �߽�������Ű ����ȭ DBó��  -->
								<#local procMap = innerFunction_formIdInfoDetail2DB(sqlConn, token, queryMap, BizSearchApiResult, requestBaseUrl, procMap)/>
								<#break>
							<#case "KKO_TMPL">
								<#--  �������ø� ����ȭ DBó��  -->
								<#local procMap = innerFunction_kkoTemplateInfoDetail2DB(sqlConn, token, queryMap, BizSearchApiResult, requestBaseUrl, procMap)/>
								<#break>
							<#default>
								<#local r = m1.log("���ǵ��� ���� DBó�� Ÿ��. @Ÿ��=[${_syncType}]", "ERROR")/>
						</#switch>
						
					</#list>
				
					<#local r = m1.log("[BIZ][SYNC][END] biz���� ����ȭó�� �Ϸ�. @����Ǽ�=[${procMap.insertCnt}] @���ŰǼ�=[${procMap.updateCnt}] @���ðǼ�=[${procMap.passCnt}] @���аǼ�=[${procMap.failCnt}] @�ѰǼ�=[${procMap.insertCnt + procMap.updateCnt + procMap.passCnt + procMap.failCnt}]", "INFO")/>

					<#return {
						"code": "200"
						, "message": "����"
					}/>

				<#else>
					<#local r = m1.log("[BIZ][SYNC][END] biz���� ����ȭó�� ���� �������� ���� ó�� ����.", "INFO")/>

					<#return {
						"code": "401"
						, "message": "biz���� ��ȸ������ ����"
					}/>

				</#if>

			<#else>
				<#assign r = m1.log("[CONF][DB][ERR] API-KEY���� ����.", "ERROR")/>
			</#if>

		</#list>
	</#if>

</#function>

<#-- �귣��ID ��ȸ�� ���� ���� �⺻������ DBó��: �󼼳����� DBó���ϴ� ���� �켱 ���� -->
<#function innerFunction_rcsBrandIdSimple2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[BRAND_ID][SYNC][ERR] api���� ���� ����. �귣��ID ���ø� ó������...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local brandId = _apiResultMap.brandId!""/>

	<#local r = m1.log("[BRAND_ID][SYNC][DB][SELECT] �귣��ID ���翩�� ��ȸ. @�귣��ID=[${brandId}]", "INFO")/>
	<#if brandId?has_content>

		<#local registerDate = _apiResultMap.registerDate!""/>
		<#if registerDate?has_content>
			<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />
		</#if>
		<#local updateDate = _apiResultMap.updateDate!""/>
		<#if updateDate?has_content>
			<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
		</#if>
		<#local approvalYmd = _apiResultMap.approvalDate!""/>
		<#if approvalYmd?has_content>
			<#local approvalYmd = m1.replaceAll(approvalYmd, "[-T:]", "")?substring(0,8) />
		</#if>

		<#local brandIdStatus = _apiResultMap.status!""/>
		<#local useYn = m1.decode(brandIdStatus, "����", "Y", "N")/>

		<#local selectBrandIdQuery = _queryMap.selectQuery>

		<#local selectFormRs = _sqlConn.query2array(selectBrandIdQuery, {
			"�귣��ID": brandId
		})/>


		<#-- �󼼳�����ȸ ����� ���� DBó�� (insert / update) -->
		<#if (selectFormRs?size == 0)>
			<#-- ���̺� ��ȸ�Ͽ� ���� ���̽��� ������ insert -->
			<#local executeQuery = _queryMap.insertQuery>
			<#local executeType = "INSERT"/>

		<#else>
			<#-- BIZ �귣��ID �԰� �������� ���� ������ update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- BIZ �󼼳�����ȸ ���� ���� ������ �Ľ� -->
		<#local rs = _sqlConn.execute(executeQuery, {
			"�귣��ID": brandId
			, "�귣���": _apiResultMap.name!""
			, "�귣��Ű": _apiResultMap.brandKey!""
			, "��뿩��": useYn
			, "�귣�����": brandIdStatus
			, "����Ͻ�": registerDate
			, "�����Ͻ�": updateDate
			, "���γ�¥": approvalYmd
		})/>

		<#if (rs >= 0)>
			<#local r = m1.log("[BRAND_ID][SYNC][DB][${executeType}][SUCC] �귣��ID ����ȭ DBó�� ����. @�귣��ID=[${brandId}]", "INFO")/>

			<#if executeType == "INSERT">
				<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
			<#elseif executeType == "UPDATE">
				<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
			</#if>

			<#local r = _sqlConn.commit()/>

		<#else>
			<#local r = m1.log("[BRAND_ID][SYNC][DB][${executeType}][FAIL] �귣��ID ����ȭ DBó�� ����. @�귣��ID=[${brandId}]", "ERROR")/>

			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[BRAND_ID][SYNC][REQ][ERR] biz���� �귣��ID ��ȸ��� ����.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- ê��ID ��ȸ�� ���� ���� ������ DBó��. DB�� �����Ͱ� ������ update, �����Ͱ� ���ٸ� insert -->
<#function innerFunction_chatbotIdDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[CHATBOT_ID][SYNC][ERR] api���� ���� ����. ê��ID ���ø� ó������...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local brandId = _apiResultMap.brandId!""/>

	<#local r = m1.log("[CHATBOT_ID][SYNC][DB][SELECT] ê��ID ���翩�� ��ȸ. @�귣��ID=[${brandId}]", "INFO")/>
	<#if brandId?has_content>

		<#assign approvalDate = m1.replaceAll(_apiResultMap.approvalDate!"", "[-T:]", "")?keep_before_last(".") />
		<#assign updateDate = m1.replaceAll(_apiResultMap.updateDate!"", "[-T:]", "")?keep_before_last(".") />
		<#assign registerDate = m1.replaceAll(_apiResultMap.registerDate!"", "[-T:]", "")?keep_before_last(".") />

		<#local selectChatbotIdQuery = _queryMap.selectQuery>

		<#local chatbotId = _apiResultMap.chatbotId!""/>

		<#local selectChatbotRs = _sqlConn.query2array(selectChatbotIdQuery, {
			"ê��ID": chatbotId
		})/>

		<#if _apiResultMap.isMainNum == true>
			<#assign isMainNum = "Y">
		<#elseif _apiResultMap.isMainNum == false>
			<#assign isMainNum = "N">
		<#else>
			<#assign isMainNum = "">
		</#if>


		<#-- �󼼳�����ȸ ����� ���� DBó�� (insert / update) -->
		<#if (selectChatbotRs?size == 0)>
			<#-- ���̺� ��ȸ�Ͽ� ���� ���̽��� ������ insert -->
			<#local executeQuery = _queryMap.insertQuery>
			<#local executeType = "INSERT"/>

		<#else>
			<#-- BIZ �귣��ID �԰� �������� ���� ������ update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- BIZ �󼼳�����ȸ ���� ���� ������ �Ľ� -->
		<#local rs = _sqlConn.execute(executeQuery, {
			"brandId" : _apiResultMap.brandId!"",
			"subNum" : _apiResultMap.subNum!"",
			"subTitle" : _apiResultMap.subTitle!"",
			"display" : _apiResultMap.display!"",
			"groupId" : _apiResultMap.groupId!"",
			"approvalDate" : approvalDate,
			"approvalResult" : _apiResultMap.approvalResult!"",
			"updateId" : _apiResultMap.updateId!"",
			"updateDate" : updateDate,
			"registerId" : _apiResultMap.registerId!"",
			"registerDate" : registerDate,
			"isMainNum" : isMainNum,
			"service" : _apiResultMap.approvalResult!"",
			"chatbotId" : chatbotId
		})/>

		<#if (rs >= 0)>
			<#local r = m1.log("[CHATBOT_ID][SYNC][DB][${executeType}][SUCC] ê��ID ����ȭ DBó�� ����. @�귣��ID=[${brandId}] @ê��ID=[${chatbotId}]", "INFO")/>

			<#if executeType == "INSERT">
				<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
			<#elseif executeType == "UPDATE">
				<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
			</#if>

			<#local r = _sqlConn.commit()/>

		<#else>
			<#local r = m1.log("[CHATBOT_ID][SYNC][DB][${executeType}][FAIL] ê��ID ����ȭ DBó�� ����. @�귣��ID=[${brandId}] @ê��ID=[${chatbotId}]", "ERROR")/>

			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[CHATBOT_ID][SYNC][REQ][ERR] biz���� ê��ID ��ȸ��� ����.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- ���̽���ID �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó�� -->
<#function innerFunction_formIdInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[FORM_ID][SYNC][ERR] api���� ���� ����. ���̽���ID ���ø� ó������...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local messagebaseformId = _apiResultMap.messagebaseformId!""/>

	<#local r = m1.log("[FORM_ID][SYNC][DB][SELECT] ���̽���ID ���翩�� ��ȸ. @���̽���ID=[${messagebaseformId}]", "INFO")/>
	<#if messagebaseformId?has_content>
		<#local selectFormIdQuery = _queryMap.selectQuery>

		<#local selectFormRs = _sqlConn.query2array(selectFormIdQuery, {
			"���̽���ID": messagebaseformId
		})/>

		<#local r = m1.log("[FORM_ID][BIZ][REQ][DETAIL][SELECT] biz���� ���̽���ID �󼼳��� ��ȸ. @���̽���ID=[${messagebaseformId}]", "INFO")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseformId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- BIZ ���̽���ID ����ȸ -->
			<#local mediaInfo = detailApiResultMap.mediaUrl![]/>
			<#if (mediaInfo?size > 0)>
				<#local mediaFileId = mediaInfo[0].fileId!""/>
				<#local mediaFileUrl = mediaInfo[0].url!""/>
			</#if>

			<#local registerDate = detailApiResultMap.registerDate!""/>
			<#if registerDate?has_content>
				<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />

			</#if>
			<#local updateDate = detailApiResultMap.updateDate!""/>
			<#if updateDate?has_content>
				<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
			</#if>

			<#-- �󼼳�����ȸ ����� ���� DBó�� (insert / update) -->
			<#if (selectFormRs?size == 0)>
				<#-- ���̺� ��ȸ�Ͽ� ���� ���̽��� ������ insert -->
				<#local executeQuery = _queryMap.insertQuery>
				<#local executeType = "INSERT"/>

			<#else>
				<#-- BIZ ���̽���ID �԰� �������� ���� ������ update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- BIZ �󼼳�����ȸ ���� ���� ������ �Ľ� -->
			<#local rs = _sqlConn.execute(executeQuery, {
				"���̽���ID": messagebaseformId
				, "���̽���": detailApiResultMap.formName!""
				, "���ø�Ÿ��": detailApiResultMap.productCode!""
				, "����": detailApiResultMap.spec!""
				, "ī��Ÿ��": detailApiResultMap.cardType!""
				, "����": detailApiResultMap.bizCondition!""
				, "�����׷�": detailApiResultMap.bizCategory!""
				, "��������": detailApiResultMap.bizService!""
				, "��������": detailApiResultMap.policyInfo!{}
				, "���̵�����": detailApiResultMap.guideInfo!{}
				, "�˼��Ķ����": detailApiResultMap.params!{}
				, "RCS�԰�": detailApiResultMap.formattedString!{}
				, "�̵������ID": mediaFileId!""
				, "�̵��URL": mediaFileUrl!""
				, "����Ͻ�": registerDate!""
				, "�����Ͻ�": updateDate!""
			})/>

			<#if (rs >= 0)>
				<#local r = m1.log("[FORM_ID][SYNC][DB][${executeType}][SUCC] ���̽���ID ����ȭ DBó�� ����. @���̽���ID=[${messagebaseformId}]", "INFO")/>

				<#if executeType == "INSERT">
					<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
				<#elseif executeType == "UPDATE">
					<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
				</#if>

				<#local r = _sqlConn.commit()/>

			<#else>
				<#local r = m1.log("[FORM_ID][SYNC][DB][${executeType}][FAIL] ���̽���ID ����ȭ DBó�� ����. @���̽���ID=[${messagebaseformId}]", "ERROR")/>

				<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

			</#if>
		<#else>
			<#local r = m1.log("[FORM_ID][SYNC][DB][FAIL] ���̽���ID ����ȭ DBó�� ����. @���̽���ID=[${messagebaseformId}]", "ERROR")/>
			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[FORM_ID][SYNC][REQ][ERR] biz���� ���̽���ID ��ȸ��� ����.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- �������ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó�� -->
<#function innerFunction_commonTemplateInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[COMMON_TMPL][SYNC][ERR] api���� ���� ����. �������ø� ���ø� ó������...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local messagebaseId = _apiResultMap.messagebaseId!""/>

	<#local r = m1.log("[COMMON_TMPL][SYNC][DB][SELECT] �������ø� ���翩�� ��ȸ. @���̽�ID=[${messagebaseId}]", "DEBUG")/>
	<#if messagebaseId?has_content>
		<#local selectFormIdQuery = _queryMap.selectQuery>

		<#local selectFormRs = _sqlConn.query2array(selectFormIdQuery, {
			"���̽�ID": messagebaseId
		})/>

		<#local r = m1.log("[COMMON_TMPL][SYNC][BIZ][REQ][DETAIL][SELECT] biz���� �������ø� �󼼳��� ��ȸ. @���̽�ID=[${messagebaseId}]", "DEBUG")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- BIZ �������ø� ����ȸ -->
			<#local mediaInfo = detailApiResultMap.mediaUrl![]/>
			<#if (mediaInfo?size > 0)>
				<#local mediaFileId = mediaInfo[0].fileId!""/>
				<#local mediaFileUrl = mediaInfo[0].url!""/>
			</#if>

			<#local registerDate = detailApiResultMap.registerDate!""/>
			<#if registerDate?has_content>
				<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />
			</#if>
			<#local updateDate = detailApiResultMap.updateDate!""/>
			<#if updateDate?has_content>
				<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
			</#if>
			<#local approvalDate = detailApiResultMap.approvalDate!""/>
			<#if approvalDate?has_content>
				<#local approvalDate = m1.replaceAll(approvalDate, "[-T:]", "")?keep_before_last(".") />
			</#if>

			<#-- �󼼳�����ȸ ����� ���� DBó�� (insert / update) -->
			<#if (selectFormRs?size == 0)>
				<#-- ���̺� ��ȸ�Ͽ� ���� ���̽��� ������ insert -->
				<#local executeQuery = _queryMap.insertQuery>
				<#local executeType = "INSERT"/>

				<#--  ���縦 ���� ������ ä��  -->
				<#local createSeqQuery>
					SELECT 
						TMPL_MNG_SEQ.nextval AS SEQ
					FROM DUAL
				</#local>
				<#local seq = _sqlConn.query2array(createSeqQuery,{})[0]["SEQ"] />

			<#else>
				<#-- BIZ �������ø� �԰� �������� ���� ������ update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- BIZ �󼼳�����ȸ ���� ���� ������ �Ľ� -->
			<#local executeParamMap = {
				"������": seq!""
				, "���̽�ID": detailApiResultMap.messagebaseId!""
				, "�귣��ID": detailApiResultMap.brandId!""
				, "���ø���ID": detailApiResultMap.messagebaseformId!""
				, "�׷�ID": detailApiResultMap.agencyId!""
				, "���̽�Ÿ��": detailApiResultMap.productCode!""
				, "���ø���": detailApiResultMap.tmpltName!""
				, "���ø�ID": "common"
				, "��������": detailApiResultMap.formattedString!{}
				, "�˼�����": detailApiResultMap.status!"parse"
				, "���ΰ������": detailApiResultMap.approvalReason!""
				, "�����": detailApiResultMap.registerId!""
				, "����Ͻ�": registerDate
				, "���±���": "4"
				, "����ڵ�": "20000000"
				, "������": detailApiResultMap.updateId!""
				, "�����Ͻ�": updateDate
				, "�����Ͻ�": approvalDate
				, "���ø���뿩��":"Y"
			}/>

			<#local isSucc = true/>

			<#local executeQueryList = executeQuery?split("#DELIM")/>
			<#list executeQueryList as executeQuery>
				<#local rs = _sqlConn.execute(executeQuery, executeParamMap)/>
				<#if (rs < 0)>
					<#local isSucc = false/>

					<#break/>
				</#if>

			</#list>


			<#if isSucc>
				<#local r = m1.log("[COMMON_TMPL][SYNC][DB][${executeType}][SUCC] �������ø� ����ȭ DBó�� ����. @���̽�ID=[${messagebaseId}]", "INFO")/>

				<#if executeType == "INSERT">
					<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
				<#elseif executeType == "UPDATE">
					<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
				</#if>

				<#local r = _sqlConn.commit()/>

			<#else>
				<#local r = m1.log("[COMMON_TMPL][SYNC][DB][${executeType}][FAIL] �������ø� ����ȭ DBó�� ����. @���̽�ID=[${messagebaseId}]", "ERROR")/>

				<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>
			</#if>
		<#else>
			<#local r = m1.log("[COMMON_TMPL][SYNC][DB][${executeType}][FAIL] �������ø� ����ȭ DBó�� ����. @���̽�ID=[${messagebaseId}]", "ERROR")/>
			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[COMMON_TMPL][SYNC][REQ][ERR] biz���� �������ø� ��ȸ��� ����.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- ����/���δ�� ���ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó�� -->
<#function innerFunction_kkoTemplateInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[RCS_TMPL][SYNC][ERR] api���� ���� ����. ����/���δ�� ���ø� ó������...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#assign approvalResult = _apiResultMap.approvalResult!""/>
	<#if 
		approvalResult == "����"
		|| approvalResult == "���δ��"
	>
		<#local messagebaseId = _apiResultMap.messagebaseId!""/>

		<#local r = m1.log("[RCS_TMPL][SYNC][DB][SELECT] ����/���δ�� ���ø� ���翩�� ��ȸ. @���̽�ID=[${messagebaseId}]", "INFO")/>
		<#if messagebaseId?has_content>
			<#local selectRcsTemplateQuery = _queryMap.selectQuery>

			<#local selectRcsTemplateRs = _sqlConn.query2array(selectRcsTemplateQuery, {
				"�귣��ID": brandId
				, "���̽�ID": messagebaseId
			})/>

			<#if (selectRcsTemplateRs?size == 0)>
				<#-- 
					biz���Ϳ��� ��ȸ�� ���̽�ID�� �������� ��ȸ�� ���� ���ø���APIȣ��
						- ���ø������ȸ API�� ��� api������ ������� formattedString�԰����� �������ִ� �̽��� ���ؼ� �̹������ø� �� api������ ������� formattedString�԰����� ����ȭ
				-->
				<#local r = m1.log("[RCS_TMPL][BIZ][REQ][DETAIL][SELECT] biz���� ����/���δ�� ���ø� �󼼳��� ��ȸ. @���̽�ID=[${messagebaseId}]", "DEBUG")/>
				<#assign detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseId}")/>
				<#if detailApiResultMap?has_content && detailApiResultMap.formattedString?has_content>
					<#assign formParam = detailApiResultMap.formattedString!{}/>
				<#else>
					<#assign formParam = {}/>
				</#if>

				<#local registerDate = detailApiResultMap.registerDate!""/>
				<#if registerDate?has_content>
					<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />
				</#if>
				<#local updateDate = detailApiResultMap.updateDate!""/>
				<#if updateDate?has_content>
					<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
				</#if>
				<#local approvalDate = detailApiResultMap.approvalDate!""/>
				<#if approvalDate?has_content>
					<#local approvalDate = m1.replaceAll(approvalDate, "[-T:]", "")?keep_before_last(".") />
				</#if>

				<#local executeQuery = _queryMap.insertQuery>
				
				<#--  ���縦 ���� ������ ä��  -->
				<#local createSeqQuery>
					SELECT 
						TMPL_MNG_SEQ.nextval AS SEQ
					FROM DUAL
				</#local>
				<#local seq = _sqlConn.query2array(createSeqQuery,{})[0]["SEQ"] />

				<#-- BIZ �󼼳�����ȸ ���� ���� ������ �Ľ� -->
				<#local executeParamMap = {
					"������": seq!""
					, "�귣��ID": brandId
					, "���̽�ID": messagebaseId
					, "���̽�Ÿ��": "tmplt"
					, "�׷�ID": detailApiResultMap.agencyId!""
					, "���ø���ID": detailApiResultMap.messagebaseformId!""
					, "���ø���": detailApiResultMap.tmpltName!""
					, "���ø�ID": messagebaseId?string?keep_after_last('-')
					, "��������": formParam
					, "�˼�����": detailApiResultMap.status!"parse"
					, "���ΰ��": detailApiResultMap.approvalResult!""
					, "���ΰ������": detailApiResultMap.approvalReason!"����"
					, "���±���": m1.decode(approvalResult, "����", "4", "3")
					, "�����": detailApiResultMap.registerId!""
					, "������": detailApiResultMap.updateId!""
					, "����Ͻ�": registerDate
					, "�����Ͻ�": approvalDate
					, "�����Ͻ�": updateDate
					, "����ڵ�": "20000000"
					, "���ø���뿩��": m1.decode(approvalResult, "����", "Y", "N")
				}/>

				<#local isSucc = true/>

				<#local executeQueryList = executeQuery?split("#DELIM")/>
				<#list executeQueryList as executeQuery>
					<#local rs = _sqlConn.execute(executeQuery, executeParamMap)/>
					<#if (rs < 0)>
						<#local isSucc = false/>

						<#break/>
					</#if>

				</#list>


				<#if isSucc>
				
					<#assign r = m1.log("[RCS_TMPL][SYNC][INSERT][SUCC] ����/���δ�� ���ø� ����ȭ DBó�� ����. @�귣��ID=[${brandId}] @���̽�ID=[${messagebaseId}]", "INFO")/>

					<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>

					<#assign r = _sqlConn.commit()/>

				<#else>
					<#assign r = m1.log("[RCS_TMPL][SYNC][INSERT][FAIL] ����/���δ�� ���ø� ����ȭ DBó�� ����. @�귣��ID=[${brandId}] @���̽�ID=[${messagebaseId}]", "ERROR")/>

					<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>
				</#if>

			<#else>
				<#assign r = m1.log("[RCS_TMPL][SYNC][INSERT][PASS] ��ϵ� ���ø����� ���� DBó�� ����. @�귣��ID=[${brandId}] @���̽�ID=[${messagebaseId}]", "INFO")/>

				<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>

			</#if>

		<#else>
			<#local r = m1.log("[RCS_TMPL][SYNC][REQ][ERR] biz���� ����/���δ�� ���ø� ��ȸ��� ����.", "ERROR")/>
			<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
		</#if>
	<#else>
		<#-- ����/���δ�Ⱑ �ƴ� ���� ��� DBó�� ���� -->
	</#if>


	<#return _procMap/>
</#function>