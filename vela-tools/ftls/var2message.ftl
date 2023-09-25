

<#assign tmpl=r"당신의 이름은 ${이름}이고, 나이는 ${나이} 입니다."/>
<#assign hash={ "이름":"홍길동","나이":20}/>


 <#assign msg=m1.var2message( tmpl,hash) />
 =========
 >>>${msg}<<<<<
 =========