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
<!--리뉴얼 추가파일--->
<link rel="stylesheet" href="/mobile/css/m_login.css"/>
<!------//------------>
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

</head>
<body onLoad="getid()">

<div data-role="page" class="ui-page ui-body-a" style="background:#fff;color: #000;">

<form:form method="POST" commandName="loginForm" action="login.htm" onsubmit="return validateForm();">
<form:hidden path="redirectURL" value="/mobile/index.jsp" />
<form:hidden path="loginType" value="0" />
<!---리뉴얼 로그인창--->
<div class="container_login">
    <div class="login_img"><img src="../common/images/icon/img_01.png"></div>
    <div class="login_img login_img_text"><img src="../common/images/icon/2_logo.png"> <img src="../common/images/icon/logo_1.png"></div>
    <div class="container_login_input">
        <form:input path="id" value=""  tabindex="1" placeholder="아이디" />
        <form:password  value="" path="pwd" tabindex="2" placeholder="비밀번호"/>
        <div><input type="checkbox" name="checksaveid" onclick="saveid()" tabindex="3" style="width:14px; height:12px;margin-right:4px; top:0;"/><span style="vertical-align: middle;">아이디 저장</span></div>
        <div class="login_btn" onclick="saveid(),loginForm.submit();" data-role="button" data-theme="b" data-inline="true" tabindex="4" ><input type="image" src="../common/images/icon/login_btn.jpg" alt="로그인" class="image" style="width:100%;" tabindex="4" />Login</div>
        <c:if test="${loginForm.forceLogin }">
            <div>
                <td colspane="2"><form:checkbox path="forceLogin" />다른곳에서 로그인해 있습니다.<br /> 다른 로그인을 강제종료하고 로그인 하시겠습니까?</td>
            </div>
        </c:if>
        <div style="font-size: 13px;margin-top:7%;text-align:center;">
            <!--아이디와 비밀번호를 입력란에 입력하시고 <br>로그인 버튼을 눌러주세요.<br>-->
            <span style="color: #266fb4">아이디와 비밀번호가 노출되지 않게 <br>주의하시기 바랍니다.</span>
        </div>
        <div class="loginetc2" style="display:none;"><a href="#" class="button colorR">그룹웨어 사용전 준비사항</a> &nbsp; <a href="#" class="button colorB" style="display:none;">그룹웨어 사용요청</a></div>	
            <div class="loginetc3">
            </div>
            <div id="footmenu" style="display:none;">
            <ul>
            </ul>
            </div>	
            <div id="authorinfo">
            </div>
         <div id="copyright"></div>	
    </div>
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


