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
	- commonFunction_parseErrorMassgeV200 : ����ť�� ���� ������� �Ľ� �Լ� (200byte)
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

	<#local resultCode = "200"/>
	<#local resultMessage = "����"/>

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
                <#local r = m1.log("[INIT][CHANNEL_ID][EXPIRED] ���ܻ����� �߽�������Ű. @�߽�������Ű=[${profileKey}]", "ERROR")/>
				<#local resultCode = "501"/>
				<#local resultMessage = "���ܻ����� �߽�������Ű. �߽�������Ű=[${profileKey}]"/>

                <#break/>
            </#if>

            <#local rejectYn = profileKeyInfo["REJECT_YN"]!"N"/>
            <#if  rejectYn?has_content && rejectYn?upper_case == "Y">
                <#local r = m1.log("[INIT][CHANNEL_ID][REJECT] �޸������ �߽�������Ű. @�߽�������Ű=[${profileKey}]", "ERROR")/>
				<#local resultCode = "501"/>
				<#local resultMessage = "�޸������ �߽�������Ű. �߽�������Ű=[${profileKey}]"/>

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

			<#local resultCode = "501"/>
			<#local resultMessage = "properties���� ���� ����"/>

        </#if>

    </#if>
    <#local r = m1.log(profileKeyInfoMap, "DEBUG")/>

	<#local r = _sqlConn.close(profileKeyInfoRs)/>

    <#return {
		"code": resultCode
		, "message": resultMessage
		, "data": profileKeyInfoMap
	}/> 
	
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
	<#--  ��������� �÷������ ����Ͽ� 200byte���� �߶� ����  -->
    <#local fail_bodyMap = {
        "TM_SEQ": _seqLocal
        , "apiResult": {
            "error": {
                "code": _errorCode,
                "message": m1.byteLenString(_errorMsg, 200)
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
	<#assign errBody = httpResponse.getErrorBody()/>

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
