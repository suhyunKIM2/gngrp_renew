<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	int port = request.getServerPort();
	String baseURL = request.getScheme() + "://" + request.getServerName() + (port != 80 ? ":" + Integer.toString(port) : "") + request.getContextPath();

	String serverName = request.getServerName();
	String logoText = " ";
	String logoImg = "";
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv='cache-control' content='no-cache'> 
<meta http-equiv='pragma' content='no-cache'> 
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title><%=logoText %>Group Mobile</title>
<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
<script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
<script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
<style>
.error{color: #ff0000;font-style:italic;}
</style>
<c:if test="${message != null && message != '' }">
<script type="text/javascript">
	alert("<c:out value='${message}' />");
</script>
</c:if>

<script type="text/javascript">
$(document).ready(function(){
	$('.ui-body-c').removeClass('ui-body-c');
});

/* var validator = null;
$(document).ready(function(){
	validator = $("#loginForm").validate({
		rules:{
			"id":{
				required:true
			},
			"pwd":{
				required:true
			}
		},
		messages:{
			"id":{
				required:"<spring:message code='v.loginId.required' text='로그인ID를 입력하십시요' />"
			},
			"pwd":{
				required:"<spring:message code='v.password.required' text='비밀번호를 입력하십시요' />"
			}
		},
		focusInvalid:true
	});
}); */

/* function validateForm(){
var isValid = validator.form();
if(!isValid) validator.focusInvalid();
return isValid;
} */


function setCookie (name, value, expires) {
	  document.cookie = name + "=" + escape (value) +
	    "; path=/; expires=" + expires.toGMTString();
	}

function getCookie(Name) {
var search = Name + "=";
if (document.cookie.length > 0) { // 쿠키가 설정되어 있다면
  offset = document.cookie.indexOf(search)
  if (offset != -1) { // 쿠키가 존재하면
    offset += search.length;
    // set index of beginning of value
    end = document.cookie.indexOf(";", offset);
    // 쿠키 값의 마지막 위치 인덱스 번호 설정
    if (end == -1)
      end = document.cookie.length
    return unescape(document.cookie.substring(offset, end));
  }
}
return "";
}

function saveid() 
{
  var checksaveid = document.getElementsByName("checksaveid");
  var id = document.getElementsByName("id");
  var pwd = document.getElementsByName("pwd");
  var expdate = new Date();
  // 기본적으로 30일동안 기억하게 함. 일수를 조절하려면 * 30에서 숫자를 조절하면 됨
  if (checksaveid[0].checked)
    expdate.setTime(expdate.getTime() + 1000 * 3600 * 24 * 30); // 30일
  else
    expdate.setTime(expdate.getTime() - 1); // 쿠키 삭제조건
  setCookie("saveid", id[0].value, expdate);
  setCookie("savepwd", pwd[0].value, expdate);
}
function getid() {
  var checksaveid = document.getElementsByName("checksaveid");
  var id = document.getElementsByName("id");
  var pwd = document.getElementsByName("pwd");
  
  checksaveid[0].checked = ((id[0].value = getCookie("saveid")) != "");
  checksaveid[0].checked = ((pwd[0].value = getCookie("savepwd")) != "");
  (checksaveid[0].checked == true) ? pwd[0].focus() : id[0].focus();
}


</script>
<style>
select,input,button,a,label,li,div{ -webkit-tap-highlight-color:transparent;text-shadow:none !important;box-shadow: none !important;}
.container_login{width:82%;margin:25% auto;text-align: center;height: calc(100vh - 25%);}
.login { position: relative; width: 100%; height: 443px; background: url(/common/images/login/bg_login_garam.gif) no-repeat; }
#footmenu { position: absolute; left: 33px; top: 350px; width: 740px; height: 14px;font-weight:normal;  }
#authorinfo { position: absolute; left: 50px; top: 380px; width: 600px; height: 90px; color:#858585;font-size:11px;font-weight:normal; line-height:110%; }
.toplogotxt { font-size:26px; }
.toplogodec { font-size:14px; letter-spacing: -0.1em; }
input.ui-input-text{background:#fff;height:50px;line-height: 50px;border-radius: 0;}
.login_img img{width:33%;}
.login_btn{font-size:0;margin-top: 4%;}
input[name="checksaveid"]{margin:0;position: relative;left:0;float: left;top: 6px !important;}
.container_login_input{text-align:left;}
</style>
</head>
<body onLoad="getid()">

<div data-role="page" class="ui-page ui-body-a" style="background:#fff;color: #000;">

<form:form method="POST" commandName="loginForm" action="login.htm" onsubmit="return validateForm();">
<form:hidden path="redirectURL" value="/mobile/index.jsp" />
<form:hidden path="loginType" value="0" />


<div id="jqm-homeheader" classs="ui-body-e" style="text-align:center;">
	<h1 id="jqm-logo"><img src="/userdata/logo<%=logoImg %>" width="271" height="29" style="width:271px;height:29px;" alt="Garamsystem Mobile V1"></h1>
	<p><strong>Welcome ! <%=logoText %>Mobile Groupware</strong><br/>그룹웨어에 접속하신 것을 ㅇㅇ환영합니다.</p>

	<div class="intro " style="padding-left:10px; padding-right:10px;">
	<!-- 보다 향상된 서비스를 제공하기 위해<br/>노력하겠습니다.<br/><br/> -->
	그룹웨어 사용자  아이디 및<br/>비밀번호를 입력해 주십시오.<br/>&nbsp;
	</div>
</div>

<div classs="ui-body-a">
<table width=100% border="0" style="margin:1px; margin-lefts:30px; margin-tops:10px;">
<tr>
<td width=110 align=right><strong><h5>아이디</h5></strong></td>
<td width=* align=center><form:input path="id" cssStyle="width:80%;" style="padding:2px; " value="" tabindex="1" /></td>
<td width=100 align=left rowspan=2>
<a href="#" onclick="saveid(),loginForm.submit();" data-role="button" data-theme="b" data-inline="true" tabindex="4"  >Login</a>
<!-- &nbsp;<input type="image" src="common/images/login/btn_login.gif" alt="로그인" class="image" tabindex="3" />-->
</td>
</tr>
<tr>
<td align=right><strong><h5>비밀번호</h5></strong></td>
<td align=center><form:password cssStyle="width:80%;" style="padding:2px;" path="pwd" tabindex="2" /></td>
<!-- <td>&nbsp;</td> -->
</tr>
<%-- 
<tr>
<td align=right><strong>Locale</strong></td>
<td colspan=2 align=center style="padding-left:50px; padding-right:50px;"><form:select path="lang" tabindex="5">
	<form:option value="ko">한국어</form:option>
	<form:option value="en">English</form:option>
	<form:option value="jp">日本語</form:option>
	</form:select></td>
</tr>
 --%>
<tr>
<td colspan=3 align="center">
<div><input type="checkbox" name="checksaveid" onclick="saveid()" tabindex="3" />아이디 패스워드 저장
</div>
</td>
</tr>

</table>
</div>

<c:if test="${loginForm.forceLogin }">
<div>
	<form:checkbox path="forceLogin" />다른곳에서 로그인해 있습니다.<br /> 다른 로그인을 강제종료하고 로그인 하시겠습니까?
</div>
</c:if>




</form:form>

<!--/container-->
</div>

</body>
</html>


