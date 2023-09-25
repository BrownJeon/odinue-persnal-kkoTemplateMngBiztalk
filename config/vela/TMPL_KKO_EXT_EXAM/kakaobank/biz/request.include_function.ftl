<#-- ���� ���� include -->
<#include "config.include_variable.ftl"/>

<#--
�Լ����
	- commonFunction_writeFileQueue4one : ����ť�� 1�� �����ϴ� �Լ�
	- commonFunction_writeFileQueue4N : ����ť�� �ٰ� �����ϴ� �Լ�
	- commonFunction_error2writeFileQ : ����ť�� ������ ���� �Լ�
		- innerFunction_flattenFileQueueData : ����ť�� ������ ���� �����ϴ� �Լ�
	- commonFunction_requestGet4ResultList : RBC���� GET��û �� ������� ��� �Ľ� �Լ�
		- innerFunction_requestGetResponseMap : RBC���� GET��û �Լ�
	- commonFunction_requestGet4ResultMap : RBC���� GET��û �� ������� �ܰ� �Ľ� �Լ�
	- commonFunction_getRequestHeaderMap : HTTP��û�� ���� ������� �����ϴ� �Լ�
	- commonFunction_getCreateTemplateUrl : ������������ ���ø���� API url üũ
	- commonFunction_requestTokenInfo : ��ū ��û �Լ�
	- commonFunction_parseCreateTemplatePayloadMap : ���ø���� �����ٵ� �Ľ�
		- innerFunction_getParseImagePayloadMap : �̹������ø� ��û���� �Ľ� (only v2 API�� ��û)
			- innerFunction_uploadImage : �̹������ε� ��û
		- innerFunction_createTemplateId : custTmpltId ���� �Լ�(����/���� 25�� �̳�)
	- commonFunction_rbc2dbSync: RBC ����ȭó�� �Լ�
		- innerFunction_formIdInfoDetail2DB: ���̽���ID �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó��
		- innerFunction_commonTemplateInfoDetail2DB : �������ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó��
		- innerFunction_rcsTemplateInfoDetail2DB : ����/���δ�� ���ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó��
		- innerFunction_rcsBrandIdSimple2DB : �귣��ID ��ȸ�� ���� ���� ������ DBó��
		- innerFunction_chatbotIdDetail2DB : ê��ID ��ȸ�� ���� ���� ������ DBó��
-->
<#--  ���뼺�� ���ؼ� SQL������ DBMS ���� ������ ������� �ʵ��� �Ѵ�.  -->

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>


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


<#-- RBC���� GET��û �� ������� �ܰ� �Ľ� �Լ� -->
<#function commonFunction_requestGet4ResultMap _token _requestUrl>

    <#-- RBC���� GET request��û �Լ� -->
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "20000000">
        <#local requestStatus = "����"/>

		<#local apiResult = responseBody.result![]/>
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

	<#local r = m1.log("[RBC][REQ][END] RBC���� ��ûó�� �Ϸ�. @ó�����=[${requestStatus}]", "INFO")/>
	<#local r = m1.log("@��ûURL=[${_requestUrl}]", "DEBUG")/>
    <#local r = m1.log(responseBody, "DEBUG")/>

	<#return resultMap/>
</#function>

<#-- RBC���� GET��û �Լ� -->
<#function innerFunction_requestGetResponseMap _token _requestUrl>
	<#if !_requestUrl?has_content>
		<#local r = m1.log("[RBC][REQ][ERR] ��ûURL ����. @��ûURL=[${_requestUrl}] @method=[GET]", "ERROR")/>

		<#return []/>
	</#if>

	<#local r = m1.log("[RBC][REQ][START] RBC���� ��ûó�� ����. @method=[GET]", "INFO")/>
	<#local r = m1.log("@��ûURL=[${_requestUrl}]", "DEBUG")/>

	<#-- ��û headerMap ���� -->
	<#assign headerMap = commonFunction_getRequestHeaderMap(_token, {})/>

	<#-- ���ø���� ��ȸ API -->
	<#local httpResponseCode=httpObj.get(_requestUrl, headerMap)!-1/>
    <#if httpResponseCode != 200>
		<#local r = m1.log("[RBC][REQ][FAIL] RBC���� ��û ����. @�����ڵ�=[${httpResponseCode}]", "ERROR")/>

		<#return {}/>
	</#if>

    <#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

    <#local responseBody = m1.parseJsonValue(httpResponseBody)/>

	<#if httpResponseCode == 200>
		<#local r = m1.log("[RBC][REQ][SUCC] RBC���� HTTP��û ����. @�����ڵ�=[${httpResponseCode}]", "DEBUG")/>
	<#else>
		<#local r = m1.log("[RBC][REQ][ERR] RBC���� HTTP��û ����. @�����ڵ�=[${httpResponseCode}]", "ERROR")/>
	</#if>

    <#return responseBody/>
</#function>


<#-- RBC���� GET��û �� ������� ��� �Ľ� �Լ� -->
<#--  RBC��û�� paginationó���� ���� ���� -->
<#function commonFunction_requestGet4ResultList _token _requestUrl>

	<#local resultList = m1.editable([])/>

    <#-- RBC���� GET request��û �Լ� -->
	<#local r = m1.log("[RBC][REQ][0] RBC���� ��ûó��... @��ûURL=[${_requestUrl}]", "INFO")/>
	
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "20000000">
        <#local requestStatus = "����"/>

		<#local apiResult = responseBody.result![]/>
        <#if apiResult?has_content>
			<#list apiResult as resultMap>
            	<#local r = resultList.put(resultMap)/>
			</#list>

        </#if>

		<#-- ���� ��û�����Ͱ� �ִ��� �Ǵ��� �� �ִ� utl -->
		<#local requestLinks = responseBody.links!{}/>
		<#local nextRequestUrl = requestLinks.next!""/>

		<#local pagination = responseBody.pagination!{}/>
		<#local pageOffset = pagination.offset!0/>
		<#local pageTotal = pagination.total!0/>
		<#local pageLimit = pagination.limit!0/>

		<#--  �߰� ��û������ ���� ���� üũ  -->
		<#if nextRequestUrl?has_content && (pageLimit + pageOffset < pageTotal)>
			<#local requestLoopCnt = ((pageTotal - (pageOffset + pageLimit)) / pageLimit)?ceiling/>
			<#list 1..requestLoopCnt as cnt>

				<#local nextOffSet = 0/>

				<#--  next�� �Ѿ�� ���� http:// �̱⿡ ��û�� 301���� �߻�. https:// �� �����Ͽ� ��û�ϴ� ������ URL����  -->
				<#local nextRequestUrl = nextRequestUrl?replace("http://", "https://")/>
				<#--  <#local nextRequestUrl = "${_requestUrl}&offset=${nextOffSet}"/>  -->

				<#local r = m1.log("[RBC][REQ][${cnt}] ���� ������ ��ûó��... @������ûURL=[${nextRequestUrl}]", "INFO")/>
				<#local nextResponseBody = innerFunction_requestGetResponseMap(_token, nextRequestUrl)/>
				<#local responseCode = nextResponseBody.code!""/>
				<#if responseCode == "20000000">
					<#local requestStatus = "����"/>

					<#local apiResult = nextResponseBody.result![]/>
					<#if apiResult?has_content>
						<#list apiResult as resultMap>
							<#local r = resultList.put(resultMap)/>
						</#list>

					</#if>

					<#local nextRequestLinks = nextResponseBody.links!{}/>
					<#local nextRequestUrl = nextRequestLinks.next!""/>

					<#if !nextRequestUrl?has_content>
						<#break/>
					</#if>

				<#else>
					<#local requestStatus = "����"/>
				</#if>

				<#local r = m1.log("[RBC][REQ][END] ���� ������ ��ûó�� �Ϸ�. @ó�����=[${requestStatus}] @��ûURL=[${nextRequestUrl}]", "INFO")/>
			</#list>

		</#if>

	<#else>
        <#local requestStatus = "����"/>
		<#local r = m1.log(responseBody, "ERROR")/>

	</#if>

	<#local r = m1.log("[RBC][REQ][END] RBC���� ��ûó�� �Ϸ�. @ó�����=[${requestStatus}] @��ûURL=[${_requestUrl}]", "INFO")/>
    <#local r = m1.log(resultList, "DEBUG")/>

	<#return resultList/>
</#function>


<#-- HTTP��û�� ���� ������� ���� �Լ� -->
<#function commonFunction_getRequestHeaderMap _token _extraParamMap>

    <#-- �⺻ ������� ����  -->
    <#local headerMap = m1.editable({
        "Content-Type" : "application/json; charset=utf-8",
        "Accept" : "application/json, text/plain, */*",
        "Authorization" : "Bearer ${_token}"
    })/>

    <#-- �߰��Ǵ� ���� �߰� ���� -->
    <#list _extraParamMap as extField, extValue>
        <#if extField?has_content && extValue?has_content>
            <#local r = headerMap.put(extField, extValue)/>
        <#else>
            <#local r = m1.log("[ERR] �߰����� �� ����. @extField=[${extField}] @extValue=[${extValue}]", "ERROR")/>
        </#if>
    </#list>

    <#return headerMap/>
</#function>


<#-- ��ū ��û �Լ� -->
<#-- �޸𸮿� ��ū�� �����ϸ� ����ð��� ������ ��� �ش� ��ū�� �״�� ��� -->
<#-- �޸𸮿� ��ū������ ���ų� ����Ǿ��� ��� �ٽ� ��ū�� �߱޹޾Ƽ� �޸𸮿� ���� -->
<#function commonFunction_requestTokenInfo _channelInfo>
	<#if !_channelInfo?has_content>
		<#local r = m1.log("ä������ ����...", "ERROR")/>
		<#return {
			"code": 500
		}/>
	</#if>

    <#local header = {
        "Content-Type" : "application/json; charset=utf-8",
        "Accept" : "application/json, text/plain, */*"
    }/>

    <#local payloadMap = {
        "clientId" : _channelInfo.clientId
        , "clientSecret" : _channelInfo.clientSecret
    }/>

	<#local payload = m1.toJsonBytes(payloadMap)?string/>
	<#local bcbytes = m1.getBytes(payload, "UTF-8")/>
	
	<#local httpResponseCode = httpObj.post("${tmplMngrUrl}/token", bcbytes, 0, bcbytes?size, header)!-1/>
	<#if httpResponseCode != 200>
		<#local r = m1.log("[RBC][REQ][FAIL] ��ū�߱� ��û ����. @�����ڵ�=[${httpResponseCode}]", "ERROR")/>
		<#local r = m1.log(httpObj.responseData, "ERROR")/>

		<#return clear/>
	</#if>

	<#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

	<#local body=m1.parseJsonValue(httpResponseBody)/>

    <#return {
        "code": httpResponseCode
        , "accessToken": body.accessToken!""
        , "expiresIn": body.expiresIn!"0"
    }/>

</#function>


<#-- 
	���ø���� ��û URL���� �Լ� 
		- �̹������ø�: v2 api�� �׻� ���
		- ������ ���ø��� ��� apiVersion�� ������ �Ǵ��Ͽ� url�� �Ǵ�
-->
<#function commonFunction_getCreateTemplateUrl _messagebaseformId _brandId _apiVersion>
	<#if 
		_messagebaseformId == "ITHIMS"
		|| _messagebaseformId == "ITHIMV"
		|| _messagebaseformId == "ITTBNV"
		|| _messagebaseformId == "ITTBNH"
		|| _messagebaseformId == "ITSNSS"
		|| _messagebaseformId == "ITSNSH"
		|| _messagebaseformId == "ITHITS"
		|| _messagebaseformId == "ITHITV"
	>
		<#-- �̹������ø��� ��� v2 api�θ� ��û -->
		<#assign createTemplateUrl = "${tmplMngrUrl}/brand/${_brandId}/v2/messagebase"/>
	<#else>
		<#-- desc,cell���ø��� ��� ������ api������ ���� ���ø���� url���� -->
		<#if _apiVersion == "v2">
			<#assign createTemplateUrl = "${tmplMngrUrl}/brand/${_brandId}/v2/messagebase"/>
			
		<#else>
			<#assign createTemplateUrl = "${tmplMngrUrl}/brand/${_brandId}/messagebase"/>
		</#if>
	</#if>

	<#return createTemplateUrl/>
</#function>



<#--  
	������ custTmpltId �� ����: ����ð� 14�ڸ� + uuid 10�ڸ�
	����/���� 25�� �̳��� �����ؾ���.
-->
<#function innerFunction_createTemplateId>
	<#local ymdhmss=m1.now()?string("yyyyMMddHHmmss")/>

	<#local extUuid = m1.uuid()?replace("-","")[1..10]/>

	<#return ymdhmss + extUuid/>

</#function>


<#-- 
	description/cell ���ø� �����ٵ� �Ľ� �Լ�
		- API������ üũ�Ͽ� �����԰��� �Ľ�
		- �̹������ø�: v2������ �����԰����� �Ľ�
		
		���ø���� API v1
			- v1�� ��� �̹������ø������ �������̱⿡ �̹������ø� ��Ͽ�û�� v2������ ���ø������ ���
			- ���ø���Ͽ� �ʿ��� ���������� formattedString�� �԰ݿ� ���߾� �߼��ؾ� ��
			- ���� RCS���ø� ���ȭ���� ����Ǿ� �ִ� ������ ��� ������(v1)�� �����Ͼ��ϹǷ� formattedString���� �Ѿ�� ���������� ����Ͽ� ������ �Ľ��ϴ� �۾��� �ʿ�
		���ø���� API v2 
			- �̹������ø� ��Ͽ�û�� �ش� API�� �Բ� ���
			- body������ ���ø���Ͽ� �ʿ��� ������ �Ľ�
-->
<#function commonFunction_parseCreateTemplatePayloadMap _requestMap _apiVersion>
	<#if !_requestMap??>
		<#local r = m1.log("[REQ][DO][ERR] ������ �Ľ� �� �����߻�. ���Ե����� ����.", "ERROR")/>
		<#return {}/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>
	<#local messagebaseformId = _requestMap.MESSAGEBASE_FORM_ID!""/>

	<#local resultMap = m1.editable({})/>

	<#if _apiVersion == "v1">

		<#-- �����ٵ� �Ľ� -->
		<#attempt>
			<#local formattedStringMap = m1.parseJsonValue(_requestMap.FORM_PARAM)!{}/>
		<#recover>
			<#local r = m1.log("[REQ][DO][ERR] �������� ������ �Ľ��� �����߻�. @��������=[${m1.toJsonBytes(_requestMap.FORM_PARAM!{})?string}]", "ERROR")/>
			<#local r = m1.log(.error, "ERROR")/>

			<#return {}/>
		</#attempt>

		<#-- TODO. custTmpltId(templateId) �� �Է¿��� �����ʿ�  -->
		<#local regMessagebasesMap = {
			"brandId": _requestMap.CHANNEL_ID!""
			, "messagebaseformId": messagebaseformId
			, "agencyId": _requestMap.AGENCY_ID!""
			, "tmpltName": _requestMap.TEMPLATE_NAME!""
			, "custTmpltId": innerFunction_createTemplateId()
			, "formattedString": formattedStringMap
		}/>

		<#local r = resultMap.put("regMessagebases", [regMessagebasesMap])/>

	<#else>
		<#-- v2���� ���ø� �����ٵ� �Ľ� -->

		<#-- ���� �������� �Ľ� -->
		<#-- TODO. custTmpltId(templateId) �� �Է¿��� �����ʿ�  -->
		<#local r = resultMap.merge({
			"brandId": _requestMap.CHANNEL_ID!""
			, "messagebaseformId": messagebaseformId
			, "agencyId": _requestMap.AGENCY_ID!""
			, "tmpltName": _requestMap.TEMPLATE_NAME!""
			, "custTmpltId": innerFunction_createTemplateId()
		}, "true")/>

		<#if 
			messagebaseformId == "ITHIMS"
			|| messagebaseformId == "ITHIMV"
			|| messagebaseformId == "ITHITS"
			|| messagebaseformId == "ITHITV"
			|| messagebaseformId == "ITTBNV"
			|| messagebaseformId == "ITTBNH"
			|| messagebaseformId == "ITSNSS"
			|| messagebaseformId == "ITSNSH"
		>
			<#--
				�̹��� ���ø�
					"ITHIMS": "�̹���-Ÿ�̺v������_������"
					"ITHIMV": "�̹���-Ÿ�̺v������_������"
					"ITHITS": "�̹���������_������"
					"ITHITV": "�̹���������_������"
				�����
					"ITTBNV": "�ӳ�����_������"
					"ITTBNH": "�ӳ�����_������"
				SNS
					"ITSNSS": "SNS��_�ϴܹ�ư��"
					"ITSNSH": "SNS��_�߰���ư��"
			-->
			<#local r = m1.log("[REQ][DO][DATA] ���ø� �������� �Ľ̽���. @SEQ=[${_seqLocal}] @���ø�ID=[${_requestMap.TEMPLATE_ID!''}] @���ø���ID=[${messagebaseformId}]", "INFO")/>
			<#local r = m1.log(_requestMap, "DEBUG")/>

			<#-- �����ٵ� ����ó�� -->
			<#local imagePayloadMap = innerFunction_getParseImagePayloadMap(messagebaseformId, _requestMap)/>
			<#if imagePayloadMap?has_content>
				<#local r = resultMap.put("body", imagePayloadMap)/>

			<#else>
				<#local r = m1.log("[REQ][DO][DATA][ERR] �̹������ø� ��û���� �Ľ� ����. @SEQ=[${_seqLocal}]", "ERROR")/>

				<#return {}/>
			</#if>

		<#else>
			<#-- 
				Ÿ��Ʋ ������
					"FF003D": "���(Description)"
					"GG001D": "ȸ������(Description)"
					"FF005D": "����(Description)"
					"FF004D": "���(Description)"
					"GG003D": "�ȳ�(Description)"
					"CC003D": "���(Description)"
					"CC002D": "�ֹ�(Description)"
					"CC001D": "���(Description)"
					"FF002D": "�Ա�(Description)"
					"GG002D": "����(Description)"
					"EE001D": "����(Description)"
					"FF001D": "����(Description)"
					"FF003C": "���(Cell)"
					"GG001C": "ȸ������(Cell)"
					"FF005C": "����(Cell)"
					"FF004C": "���(Cell)"
					"GG003C": "�ȳ�(Cell)"
					"CC003C": "���(Cell)"
					"CC002C": "�ֹ�(Cell)"
					"CC001C": "���(Cell)"
					"FF002C": "�Ա�(Cell)"
					"GG002C": "����(Cell)"
					"EE001C": "����(Cell)"
					"FF001C": "����(Cell)"
				Ÿ��Ʋ ������
					"TATA001D": "Ÿ��Ʋ������(Description)"
					"TATA001C": "Ÿ��Ʋ������(Cell)"
			-->
			<#local r = m1.log("[REQ][DO][DATA] ���ø� �������� �Ľ̽���. @SEQ=[${_seqLocal}] @���ø�ID=[${_requestMap.TEMPLATE_ID!''}] @���ø���ID=[${messagebaseformId}]", "INFO")/>
			<#local r = m1.log(_requestMap, "DEBUG")/>

			<#-- �������� ����ó�� -->
			<#attempt>
				<#local r = resultMap.put("body", m1.parseJsonValue(_requestMap.REQ_FORM_PARAM)![])/>
			<#recover>
				<#local r = m1.log("[REQ][DO][ERR] �������� ������ �Ľ��� �����߻�. @��������=[${m1.toJsonBytes(_requestMap.REQ_FORM_PARAM![])?string}]", "ERROR")/>
				<#local r = m1.log(.error, "ERROR")/>

				<#return {}/>
			</#attempt>

			<#-- ��ư���� ����ó�� -->
			<#local parameterButtonList = m1.parseJsonValue(_requestMap.BUTTON_INFO![])![]/>
			<#if parameterButtonList?has_content>
				<#attempt>
					<#local r = resultMap.put("buttons", parameterButtonList)/>
				<#recover>
					<#local r = m1.log("[REQ][DO][ERR] ��ư���� ������ �Ľ��� �����߻�. @��ư����=[${m1.toJsonBytes(_requestMap.BUTTON_INFO!{})?string}]", "ERROR")/>
					<#local r = m1.log(.error, "ERROR")/>

					<#return {}/>
				</#attempt>
			</#if>

		</#if>
	</#if>

	<#local r = m1.log("[REQ][DO] ������ �Ľ�ó�� �Ϸ�. @SEQ=[${_seqLocal}] @���ø�ID=[${_requestMap.TEMPLATE_ID!''}]", "INFO")/>
	<#local r = m1.log(resultMap, "DEBUG")/>

	<#return resultMap/>

</#function>


<#--
	�̹������ø� �����ٵ� �Ľ� �Լ�
		�̹���������
			"ITHIMS": "�̹���-Ÿ�̺v������_������" (900x900)
			"ITHIMV": "�̹���-Ÿ�̺v������_������" (900x1200)
			"ITHITS": "�̹���������_������" (900x900)
			"ITHITV": "�̹���������_������" (900x1200)
		�����
			"ITTBNV": "�ӳ�����_������" (����:900x560, ������:300x300)
			"ITTBNH": "�ӳ�����_������" (����:900x560, ������:300x300)
		SNS
			"ITSNSS": "SNS��_�ϴܹ�ư��" (900x900)
			"ITSNSH": "SNS��_�߰���ư��" (900x560)
-->
<#function innerFunction_getParseImagePayloadMap _messagebaseformId _requestMap>
	<#local msgFormIdMapper = {
		"ITHIMS": "Ÿ�̺v������_������"
		, "ITHIMV": "Ÿ�̺v������_������"
		, "ITHITS": "�̹���������_������"
		, "ITHITV": "�̹���������_������"
		, "ITTBNV": "�ӳ�����_������"
		, "ITTBNH": "�ӳ�����_������"
		, "ITSNSS": "SNS��_�ϴܹ�ư��"
		, "ITSNSH": "SNS��_�߰���ư��"
	}/>

	<#local imgPathInfo = _requestMap.IMAGE_PATH_INFO!{}/>
	<#if !imgPathInfo?has_content>
		<#local r = m1.log("[REQ][DO][DATA][ERR] �̹������ø� ����� ���ؼ��� �̹��������� �ʼ��Դϴ�. @��û����=[${m1.toJsonBytes(_requestMap)}]", "ERROR")/>

		<#return []/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>

	<#local r = m1.log("[REQ][DO][DATA][${msgFormIdMapper[_messagebaseformId]}] �̹������ø� �������� �Ľ̽���. @SEQ=[${_seqLocal}] @���ø�ID=[${_requestMap.TEMPLATE_ID!''}] @���ø���ID=[${_messagebaseformId}]", "INFO")/>
	<#local r = m1.log(_requestMap, "DEBUG")/>

	<#local bodyPayloadArr = m1.parseJsonValue("[]")/>

	<#-- ��û���� ���� �߰� -->
	<#local formParamList = m1.parseJsonValue(_requestMap.REQ_FORM_PARAM!"[]")![]/>
	<#list formParamList as value>
		<#local r = m1.arrayAdd(bodyPayloadArr, value)/>
	</#list>

	<#-- �̹������ε� ��û �� ���ε��� �̹������� �߰� -->
	<#local imageInfoList = innerFunction_uploadImage(_requestMap)/>
	<#list imageInfoList as value>
		<#local r = m1.arrayAdd(bodyPayloadArr, value)/>
	</#list>

	<#local r = m1.log(bodyPayloadArr, "DEBUG")/>

    <#return bodyPayloadArr/>
</#function>


<#-- RBC���� �̹������� ���ε� ��û �Լ� -->
<#function innerFunction_uploadImage _requestMap>
	<#local imgPathInfo = m1.parseJsonValue(_requestMap.IMAGE_PATH_INFO!"{}")/>
	<#if !imgPathInfo?has_content>
		<#local r = m1.log("[ERR] �̹������� ����.", "ERROR")/>

		<#return {
			"code": "79999"	
		}/>
	</#if>

	<#local brandId = _requestMap.CHANNEL_ID!""/>

	<#local token = (m1.shareget(brandId)).accessToken!""/>
	<#local brandKey = (brandInfoMap[brandId]!{}).brandKey!""/>

	<#local resultUploadList = m1.parseJsonValue("[]")/>

	<#list imgPathInfo as key,filePath>
		<#-- �̹����������� �߿�  -->
		<#if 
			key?has_content
			|| key == "media"
			|| key?starts_with("subMedia")
		>
			<#if !filePath?starts_with("maapfile")>
				<#-- �˼���û header ���� -->

				<#assign boundary = httpObj.getBoundary() />

				<#assign headerMap = commonFunction_getRequestHeaderMap(token, {
					"Content-Type" : "multipart/form-data; boundary=${boundary}",
					"X-RCS-Brandkey": brandKey,
					"brandId": brandId,
					"charsetName": "UTF-8"
				})/>

				<#local fileList = [filePath]/>

				<#local r = m1.log("[IMG][UPD] �̹������� ���ε�. @�귣��ID=[${brandId}] @���ε�����=[${filePath}]", "INFO")/>

				<#local httpResponseCode = httpObj.uploadImage("${tmplMngrUrl}/brand/${brandId}/v2/messagebase/file", headerMap, {}, fileList)!-1/>
				<#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>
				<#local r = m1.log(httpResponseBody, "DEBUG")/>

				<#local responseBody = m1.parseJsonValue(httpResponseBody)/>
				
				<#if httpResponseCode != 200>
					<#local r = m1.log("[IMG][UPD][FAIL] �̹������� ���ε� ����. @�귣��ID=[${brandId}] @���ε�����=[${filePath}]", "ERROR")/>
					
					<#local uploadMap = responseBody.error!{}/>

					<#--  TODO. �̹������п� ���� ����ó�� ���� �߰�  -->

					<#local r = m1.log(uploadMap, "ERROR")/>

				<#else>
					<#local r = m1.log("[IMG][UPD][SUCC] �̹������� ���ε� ����. @�귣��ID=[${brandId}] @���ε�����=[${filePath}]", "INFO")/>
					
					<#local uploadMap = responseBody.result![]/>

					<#local r = m1.log(uploadMap, "DEBUG")/>
					<#if (uploadMap?size > 0)>
						<#local resultMap = {
							"param": key
							, "value": "maapfile://" + uploadMap[0].fileId!""
						}/>

						<#local r = m1.arrayAdd(resultUploadList, resultMap)/>

					</#if>

					<#local r = m1.log(resultMap, "DEBUG")/>
				</#if>
			<#elseif filePath?starts_with("maapfile")>
				<#-- �̹�������ID ������ ��� �״�� ��� -->
				<#local r = m1.log("[IMG][UPD] �̹�������ID �����̹Ƿ� ��� �״�� ���. @�귣��ID=[${brandId}] @���ε�����=[${filePath}]", "INFO")/>

				<#local resultMap = {
					"param": key
					, "value": filePath
				}/>

				<#local r = m1.arrayAdd(resultUploadList, resultMap)/>
			</#if>
		</#if>
	</#list>

    <#return resultUploadList/>

</#function>


<#--
	1. rbc���Ϳ� ����ȭó�� ���� �����ȸ
	2. ����� loop���鼭 �� ������ ���� rbc ������ ��ȸ
	3. �󼼳�����ȸ ���� ���� ������ �Ľ�
	4. �󼼳�����ȸ ����� ���� DBó�� (insert / update)

-->
<#--
	RBC ����ȭó�� ��ü spec
	{
		"token": ��ū����
		, "sqlConn": SQL��ü
		, "query": {
			"selectQuery": ��ȸ����
			, "updateQuery": update����
			, "insertQuery": ��������
		}
		, "requestUrl": ��û ���̽�URL (ex: "${tmplMngrUrl}/brand/${brandId}/messagebase")
	}
-->
<#function commonFunction_rbc2dbSync _syncType _syncParamMap>
	<#if !_syncParamMap?has_content>
		<#local r = m1.log("[RBC][SYNC][ERR] RBC���� ����ȭó�� �Ķ���� ������ ����.", "ERROR")/>

		<#return {}/>
	<#elseif 
		!_syncParamMap.sqlConn?has_content
		|| !_syncParamMap.query?has_content
		|| !_syncParamMap.requestUrl?has_content
	>
		<#local r = m1.log("[RBC][SYNC][ERR] RBC���� ����ȭó�� �Ķ���� ������ ����. @��ûŸ��=[${_syncType}]", "ERROR")/>
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
	<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
	<#if !clientInfoList?has_content>
		<#assign r = m1.log("[CONF][BRAND_ID][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

		<#return {
			"code": "301"
			, "message": "API-KEY���� ����"
		}/>

	<#else>
		<#list clientInfoList as clientInfo>
			<#assign clientId = clientInfo.clientId!""/>
			<#assign clientSecret = clientInfo.clientSecret!""/>

			<#if clientId?has_content && clientSecret?has_content>
				<#assign tokenInfo = commonFunction_requestTokenInfo({
					"clientId": clientId
					, "clientSecret": clientSecret
				})/>

				<#assign token = tokenInfo.accessToken!""/>
				<#if !token?has_content>
					<#assign r = m1.log("[ERR] ��ū���� ����. @��ū����=[${m1.toJsonBytes(tokenInfo)}]", "ERROR")/>

				<#else>
					<#-- rbc���Ϳ� ����ȭó�� ���� �����ȸ -->
					<#local r = m1.log("[RBC][SYNC][REQ] RBC���� ����ȭ���� ��� ��ȸ.", "DEBUG")/>

					<#local rbcSearchApiResultList = commonFunction_requestGet4ResultList(token, requestBaseUrl)/>
					<#local r = m1.log(rbcSearchApiResultList, "DEBUG")/>

					<#if rbcSearchApiResultList?has_content>
						<#list rbcSearchApiResultList as rbcSearchApiResult>
							<#-- RBC���� ��ȸ�� ���̽���ID ����� ���� �󼼳��� api��ȸ�Ͽ� DB�� ����ȭó�� -->
							<#switch _syncType?upper_case>
								<#case "FORM_ID">
									<#--  ���̽���ID ����ȭ DBó��  -->
									<#local procMap = innerFunction_formIdInfoDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "COMMON_TMPL">
									<#--  �������ø� ����ȭ DBó��  -->
									<#local procMap = innerFunction_commonTemplateInfoDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "RCS_TMPL">
									<#--  �������ø� ����ȭ DBó��  -->
									<#local procMap = innerFunction_rcsTemplateInfoDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "BRAND_ID">
									<#--  �귣��ID ����ȭ DBó��  -->
									<#local procMap = innerFunction_rcsBrandIdSimple2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "CHATBOT_ID">
									<#--  ê��ID ����ȭ DBó��  -->
									<#local procMap = innerFunction_chatbotIdDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#default>
									<#local r = m1.log("���ǵ��� ���� DBó�� Ÿ��. @Ÿ��=[${_syncType}]", "ERROR")/>
							</#switch>
							
						</#list>
					
						<#local r = m1.log("[RBC][SYNC][END] RBC���� ����ȭó�� �Ϸ�. @����Ǽ�=[${procMap.insertCnt}] @���ŰǼ�=[${procMap.updateCnt}] @���ðǼ�=[${procMap.passCnt}] @���аǼ�=[${procMap.failCnt}] @�ѰǼ�=[${procMap.insertCnt + procMap.updateCnt + procMap.passCnt + procMap.failCnt}]", "INFO")/>

						<#return {
							"code": "200"
							, "message": "����"
						}/>

					<#else>
						<#local r = m1.log("[RBC][SYNC][END] RBC���� ����ȭó�� ���� �������� ���� ó�� ����.", "INFO")/>

						<#return {
							"code": "401"
							, "message": "RBC���� ��ȸ������ ����"
						}/>

					</#if>

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
			<#-- RBC �귣��ID �԰� �������� ���� ������ update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- RBC �󼼳�����ȸ ���� ���� ������ �Ľ� -->
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
		<#local r = m1.log("[BRAND_ID][SYNC][REQ][ERR] RBC���� �귣��ID ��ȸ��� ����.", "ERROR")/>
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
			<#-- RBC �귣��ID �԰� �������� ���� ������ update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- RBC �󼼳�����ȸ ���� ���� ������ �Ľ� -->
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
		<#local r = m1.log("[CHATBOT_ID][SYNC][REQ][ERR] RBC���� ê��ID ��ȸ��� ����.", "ERROR")/>
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

		<#local r = m1.log("[FORM_ID][RBC][REQ][DETAIL][SELECT] RBC���� ���̽���ID �󼼳��� ��ȸ. @���̽���ID=[${messagebaseformId}]", "INFO")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseformId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- RBC ���̽���ID ����ȸ -->
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
				<#-- RBC ���̽���ID �԰� �������� ���� ������ update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- RBC �󼼳�����ȸ ���� ���� ������ �Ľ� -->
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
		<#local r = m1.log("[FORM_ID][SYNC][REQ][ERR] RBC���� ���̽���ID ��ȸ��� ����.", "ERROR")/>
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

		<#local r = m1.log("[COMMON_TMPL][SYNC][RBC][REQ][DETAIL][SELECT] RBC���� �������ø� �󼼳��� ��ȸ. @���̽�ID=[${messagebaseId}]", "DEBUG")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- RBC �������ø� ����ȸ -->
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
				<#-- RBC �������ø� �԰� �������� ���� ������ update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- RBC �󼼳�����ȸ ���� ���� ������ �Ľ� -->
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
		<#local r = m1.log("[COMMON_TMPL][SYNC][REQ][ERR] RBC���� �������ø� ��ȸ��� ����.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- ����/���δ�� ���ø� �󼼳����� ��ȸ�Ͽ� ��ȸ��� DBó�� -->
<#function innerFunction_rcsTemplateInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
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
					RBC���Ϳ��� ��ȸ�� ���̽�ID�� �������� ��ȸ�� ���� ���ø���APIȣ��
						- ���ø������ȸ API�� ��� api������ ������� formattedString�԰����� �������ִ� �̽��� ���ؼ� �̹������ø� �� api������ ������� formattedString�԰����� ����ȭ
				-->
				<#local r = m1.log("[RCS_TMPL][RBC][REQ][DETAIL][SELECT] RBC���� ����/���δ�� ���ø� �󼼳��� ��ȸ. @���̽�ID=[${messagebaseId}]", "DEBUG")/>
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

				<#-- RBC �󼼳�����ȸ ���� ���� ������ �Ľ� -->
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
			<#local r = m1.log("[RCS_TMPL][SYNC][REQ][ERR] RBC���� ����/���δ�� ���ø� ��ȸ��� ����.", "ERROR")/>
			<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
		</#if>
	<#else>
		<#-- ����/���δ�Ⱑ �ƴ� ���� ��� DBó�� ���� -->
	</#if>


	<#return _procMap/>
</#function>