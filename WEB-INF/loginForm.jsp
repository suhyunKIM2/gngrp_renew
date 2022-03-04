<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko">

<head>
<%
int port = request.getServerPort();
String baseURL = request.getScheme() + "://" + request.getServerName() + (port != 80 ? ":" + Integer.toString(port) : "") + request.getContextPath();

String serverName = request.getServerName();
String logoText = " ";
%>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Keywords" content="GaramSystem"  />
<meta name="description" content="NEK Java Groupware V3" />
<meta name="author" content="Garam System" />
<meta name="classification" content="Garam System" />
<meta name="nationality" content="korean" />
<meta name="content-language" content="kr" />
<meta name="Copyright" content="Copyright (c) 2011. By Garam System. All rights reserved." />
<title><%=logoText %>GroupWare System</title>
<!-- <script type="text/javascript" src="../share/js/login.js"></script> -->
<link rel="stylesheet" type="text/css" href="/common/images/login/login.css">
<link rel="stylesheet" type="text/css" href="/common/images/login/base.css">

<style>
.error{color: #ff0000;font-style:italic;}

</style>
<c:if test="${message != null && message != '' }">
<script type="text/javascript">
	alert("<c:out value='${message}' />");
</script>
</c:if>

<%@ include file="common/include.jquery.jsp"%>
<%@ include file="common/include.jquery.form.jsp"%>
<%@ include file="common/include.common.jsp"%>

<link rel="stylesheet" type="text/css" href="/common/jquery/plugins/jReject/css/jquery.reject.css">
<script type="text/javascript" src="/common/jquery/plugins/jReject/js/jquery.reject.js"></script>

<script type="text/javascript">

$(document).ready(function(){
	//https 적용 시에만 하기 --운영시 주석 해제
	/* if (document.location.protocol == 'http:') {
        document.location.href = document.location.href.replace('http:', 'https:');
        } */
	/*
	$.reject({
			reject: {
				all:false,
				msie:false, msie5: true, msie6: true, msie7:true, msie8:true, msie9:true // Covers MSIE 5-6 (Blocked by default)
				//unknown: true // Everything else
				
				//safari: true, // Apple Safari
				//chrome: true, // Google Chrome
				//firefox: true, // Mozilla Firefox
				//msie: true, // Microsoft Internet Explorer
				//opera: true, // Opera
				//konqueror: true, // Konqueror (Linux)
				//unknown: true // Everything else
			}
		}); // Customized Browsers
	*/
});


/*   var validator = null;
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
});  

function validateForm()
{
	
	var pwd = document.getElementsByName("pwd");
	if(pwd[0].value == "")
	{
		alert("ㅁㅁㅁ");
		return false;
	}
	
//	var isValid = validator.form();
//	if(!isValid) validator.focusInvalid();

//	return isValid;
} */




function validateForm()
{
	var id = document.getElementsByName("id");
	var pwd = document.getElementsByName("pwd");
	var checkid = document.getElementsByName("checkid");
	
	if(id[0].value == "")
	{
		alert("로그인ID를 입력해 주십시요");
		id[0].focus();
		return false;
	}else if(pwd[0].value == "")
	{
		alert("비밀번호를 입력해 주십시요");
		pwd[0].focus();
		return false;
	}
	
	saveid();
	
}

function setCookie (name, value, expires) {
	  document.cookie = name + "=" + escape (value) +
	    "; path=/; expires=" + expires.toGMTString();
	}

function getCookie(Name) {
  var search = Name + "="
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
  var expdate = new Date();
  // 기본적으로 30일동안 기억하게 함. 일수를 조절하려면 * 30에서 숫자를 조절하면 됨
  if (checksaveid[0].checked)
    expdate.setTime(expdate.getTime() + 1000 * 3600 * 24 * 30); // 30일
  else
    expdate.setTime(expdate.getTime() - 1); // 쿠키 삭제조건
  setCookie("saveid", id[0].value, expdate);
}
function getid() {
  var checksaveid = document.getElementsByName("checksaveid");
  var id = document.getElementsByName("id");
  var pwd = document.getElementsByName("pwd");
  
  checksaveid[0].checked = ((id[0].value = getCookie("saveid")) != "");
  (checksaveid[0].checked == true) ? pwd[0].focus() : id[0].focus();
}

</script>
<style>
.login { position: relative; width: 100%; height: 443px; background: url(/common/images/login/bg_login_garam.gif) no-repeat; }
#footmenu { position: absolute; left: 33px; top: 350px; width: 740px; height: 14px;font-weight:normal;  }
#authorinfo { position: absolute; left: 50px; top: 380px; width: 600px; height: 90px; color:#858585;font-size:11px;font-weight:normal; line-height:110%; }
.toplogotxt { font-size:26px; }
.toplogodec { font-size:14px; letter-spacing: -0.1em; }
#authorinfo,#copyright{position:relative;}/*비밀번호 창 가림현상 수정 적용 220304적용*/
</style>

<link rel='stylesheet' type='text/css' href='../common/css/login.css'><!----2021리뉴얼추가---->
</head>
<body onLoad="getid();">
<form:form method="POST" commandName="loginForm" action="login.htm" onsubmit="return validateForm();">
<form:hidden path="redirectURL" />
<form:hidden path="loginType" value="0" />
<!---리뉴얼 로그인창--->
<div class="container_login">
    <div class="login_img"><img src="../common/images/icon/img_01.png"></div>
    <div class="login_img login_img_text"><img src="../common/images/icon/logo.png"><img src="../common/images/icon/logo_1.png"></div>
    <div class="container_login_input">
        <form:input path="id" value=""  tabindex="1" placeholder="아이디" />
        <form:password  value="" path="pwd" tabindex="2" placeholder="비밀번호"/>
        <div><input type="checkbox" name="checksaveid" onclick="saveid()" tabindex="3" style="width:14px; height:12px;margin-right:4px; top:0;"/><span style="vertical-align: middle;">아이디 저장</span></div>
        <div class="login_btn" ><input type="image" src="../common/images/icon/login_btn.jpg" alt="로그인" class="image" style="width:100%;" tabindex="4" />Login</div>
        <c:if test="${loginForm.forceLogin }">
            <div>
                <td colspane="2"><form:checkbox path="forceLogin" />다른곳에서 로그인해 있습니다.<br /> 다른 로그인을 강제종료하고 로그인 하시겠습니까?</td>
            </div>
        </c:if>
        <div>
            아이디와 비밀번호를 입력란에 입력하시고 로그인 버튼을 눌러주세요.<br/>
            <span style="color: #4641D9">아이디와 비밀번호가 노출되지 않게 주의하시기 바랍니다.</span>
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





        <div id="globalmenu">
            <ul style="display:none;">
                <li class="first"></li>
                <li><a href="#">고객센터</a></li>
                <li class="last"><a href="#">장애신고</a></li>
            </ul>
        </div>	
</form>
    <!-- << form(login) -->	
	


</form:form>
</body>
</html>