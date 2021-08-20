<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="../common/usersession.jsp"%>
<%!
	//환경설정 메뉴 (10개)
	String subTitles[] = {"개인서명 관리","회사서명 관리", "메일자동분류", "메일함관리", "그룹관리", "대표메일관리", "메일자동삭제", "메일포워딩 설정", "메일 가져오기", "POP3 가져오기"};
	String subTitleNames[] = {"개인서명 등록화면","회사서명 등록화면","메일자동분류 등록화면","모든 메일함 관리화면", "개인 그룹관리화면", "회사 대표메일 관리화면", "메일 자동삭제 설정 화면",  "메일 포워딩 설정화면", "EML 형식메일 가져오기", "POP3 가져오기"};
%>

<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<TITLE><fmt:message key="main.option"/>&nbsp;<!-- 환경설정 --></TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>

<%-- <script src="<%= scriptPath %>/common.js"></script> --%>
<SCRIPT LANGUAGE="JavaScript">
<!--
function goActionForm()
    {
    	var objList = document.getElementById("goAction");
    	var cmd = objList.options[objList.selectedIndex].value;
    	if(cmd==0) return;
    	switch(eval(cmd)){
    		case 1:	//개인서명
        		document.mainForm.action = "./mail_signature.jsp";
        		break;
        	case 2:	//회사서명
        		document.mainForm.action = "./mail_companysignature.jsp";
        		break;
        	case 3:	//메일 자동분류
        		document.mainForm.action = "./mail_rules.jsp";
        		break;
        	case 4:	//편지함 관리
        		document.mainForm.action = "./mail_mailboxes.jsp";
        		break;
        	case 5:	// 그룹관리
        		document.mainForm.action = "./mail_grouplist.jsp";
        		break;
        	case 6:	//대표메일관리
        		document.mainForm.action = "./mail_representationlist.jsp";
        		break;	
        	case 7:	//메일자동삭제
        		document.mainForm.action = "./mail_autodelete.jsp";
        		break;
        	case 8:	//포워딩설정
        		document.mainForm.action = "./mail_forwarding.jsp";
        		break;
        	case 9:	//메일가져오기
        		document.mainForm.action = "./mail_uploader_form.jsp";
        		break;
        	case 10:	//POP3 가져오기
        		document.mainForm.action = "./mail_pop3support.jsp";
        		break;
        }
		document.mainForm.method = "get" ; 
		document.mainForm.submit() ;
    }
    
 function goSpam(){
 	var url = "/mail/mail_spamlist.jsp";
 	OpenWindow( url, "", "350" , "450" );
 }
//-->
</SCRIPT>
<style>
ul.topList { width:100%; margin:0 1px 0 24px;height: auto;overflow:hidden;}
ul.topList li { width:32%; float:left; background:url("http://<%=request.getServerName() %>/common/images/title_arr.gif") 0 3px no-repeat; padding-top:0px; padding-left:10px; margin-bottom:45px; color:#666; font-family:Tahoma, 돋움;    height: 30px; }
ul.topList h4 { font-size:11px; font-family:Tahoma, 돋움; margin-top:0px; margin-bottom:4px;}
ul.topList p { clear:both; width:84%; margin: 5px 0 10px 0; }

body {margin:0px; overflow-y:hidden; }
.div-view {width:94%; height:expression(document.body.clientHeight-20); overflow:auto; overflow-x:hidden;background:#fff;height:84vh;    padding: 3%;}
.div-view table{width:100% !important;}
.div-view table font{color:#266fb5 !important;padding-left:20px;}
</style>
<script>
//Div 목록 사이즈 재조정
function div_resize() {
	var objDiv = document.getElementById("viewList");
	var objTbl = document.getElementById("viewTable");
	var objPg = document.getElementById("viewPage");

	//objDiv.style.width = document.body.clientWidth - 40;
	//objDiv.style.width = document.body.clientWidth + 40;
   	//objDiv.style.height = document.body.clientHeight - 146 ;
   	
   	objDiv.style.height = document.body.clientHeight - 20;
}
</script>
</head>
<body style="overflow:auto;">

<form name="mainForm" method="get" onsubmit="return false;">
<input type="hidden" name="cmd" value="">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="mail.option"/>&nbsp;&gt;&nbsp;<fmt:message key="mail.import.pop3"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>
<!-- List Title -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td></td></tr></table>

<div id="viewList" class="div-view" onpropertychange="div_resize();">
<table width="100%" border="0" cellspacing="0" cellpadding="0" >
	<tr> 
		<td valign="top"> 
			<font style="font-size:13px;color:blue;"><b><fmt:message key="mail.set.deault"/>&nbsp;<!-- 기본설정 --></b></font>
				<!-- 임시적으로 환경설정 들어왔을때 네임택을 만들도록 한다.-->
				<table width="900"><tr height="3"><td></td></tr><tr height="2" bgcolor="#F0F0F0"><td></td></tr><tr height="10"><td></td></tr></table>
				<ul class="topList">
				<li>
					<a href="mail_signature.jsp" class=2depth ><b><fmt:message key="mail.set.sign.mng"/>&nbsp;<!-- 개인서명관리 --></b></a>
					<p style="white-space: normal;"><fmt:message key="mail.sub.sign.mng"/>&nbsp;<!-- 메일전송시 하단에 함께 표시되는 서명을 작성하여 보낼 수 있습니다. --></p>
				</li>
				<li>
					<a href="mail_rules.jsp" class=2depth ><b><fmt:message key="mail.set.autocategory"/>&nbsp;<!-- 메일자동분류 --></b></a>
					<p><fmt:message key="mail.sub.autocategory"/>&nbsp;<!-- 메일이 올 때 특정편지함으로 자동이동 할 수 있습니다 --></p>
				</li>
				<li>
					<a href="mail_mailboxes.jsp" class=2depth ><b><fmt:message key="mail.mailbox.mng"/>&nbsp;<!-- 메일함관리 --></b></a>
					<p><fmt:message key="mail.sub.autocategory"/>&nbsp;<!-- 메일함의 추가/이름 및 순서변경을 할 수 있습니다. --></p>
				</li>
				<%	if (loginuser.securityId != 0) { %>
				<li>
					<a href="mail_grouplist.jsp?gubun=P" class=2depth ><b>개인<fmt:message key="mail.set.group"/>&nbsp;<!-- 그룹관리 --></b></a>
					<p><fmt:message key="mail.sub.group"/>&nbsp;<!-- 메일 발송시 개인 그룹를 만들어 사용 할수 있습니다. --></p>
				</li>
				<%	} %>
<!-- 														<li> -->
<%-- 															<a href="mail_autodelete.jsp" class=2depth ><b><fmt:message key="mail.set.autodelete"/>&nbsp;<!-- 메일자동삭제 --></b></a> --%>
<%-- 															<p><fmt:message key="mail.sub.autodelete"/>&nbsp;<!-- 메일함의 편지를 자동삭제 할 수 있습니다. --></p> --%>
<!-- 														</li> -->
				<%	if (loginuser.securityId != 0) { %>
				<li>
					<a href="mail_forwarding.jsp" class=2depth ><b><fmt:message key="mail.set.fowarding"/>&nbsp;<!-- 메일포워딩설정 --></b></a>
					<p><fmt:message key="mail.sub.forwarding"/>&nbsp;<!-- 수신된 메일을 포워딩 할 수 있습니다. --></p>
				</li>
				<%	} %>
				<%if(loginuser.securityId >=9){ //관리자권한 %>
				<li>
					<a href="mail_representationlist.jsp" class=2depth ><b><fmt:message key="mail.set.mainmail"/>&nbsp;<!-- 대표메일설정 --></b></a>
					<p><fmt:message key="mail.sub.mainmain"/>&nbsp;<!-- 회사 대표메일 계정을 설정할 수 있습니다. --></p>
				</li>
				<li>
					<a href="mail_grouplist.jsp?gubun=S" class=2depth ><b><fmt:message key="mail.set.group.shared"/>&nbsp;<!-- 공용그룹관리 --></b></a>
					<p><fmt:message key="mail.sub.group.shared"/>&nbsp;<!-- 메일 발송시 공용 그룹를 만들어 사용 할수 있습니다. --></p>
				</li>
<!-- 														<li> -->
<!-- 															<a href="mail_paperlist.jsp" class=2depth ><b>편지지 관리&nbsp;회사서명관리</b></a> -->
<!-- 															<p>메일 편지지를 관리합니다.&nbsp;메일 편지지를 관리합니다.</p> -->
<!-- 														</li> -->
				<%}else{ //일반사용자%>
<!-- 				<li> -->
<%-- 					<a href="mail_representationlist.jsp" class=2depth ><b><fmt:message key="mail.set.mainmail.inquiry"/>&nbsp;<!-- 대표메일조회 --></b></a> --%>
<%-- 					<p><fmt:message key="mail.sub.mainmain"/>&nbsp;<!-- 회사 대표메일 계정을 설정할 수 있습니다. --></p> --%>
<!-- 				</li> -->
				<%} %>
				
				<li>
					<a href="javascript:goSpam();" class=2depth ><b><fmt:message key="mail.spamSetting"/>&nbsp;<!-- 스팸설정 --></b></a>
					<p><fmt:message key="mail.sub.goup"/>&nbsp;<!-- 스팸을 설정 할 수 있다. --></p>
				</li>
				</ul>
		</td>
	</tr>
	<tr>
		<td>
			<font style="font-size:13px;color:blue;"><b><fmt:message key="mail.set.oupmail"/>&nbsp;<!-- 외부메일설정 --></b></font>
			<table width="100%"><tr height="3"><td></td></tr><tr height="2" bgcolor="#F0F0F0"><td></td></tr><tr height="10"><td></td></tr></table>
				<ul class="topList">
				<li>
					<a href="mail_pop3support.jsp" class=2depth ><b><fmt:message key="mail.set.oupPOPmail"/>&nbsp;<!-- 외부(POP_메일설정 --></b></a>
					<p><fmt:message key="mail.sub.outPopmail"/>&nbsp;<!-- 네이버,다음,야후등 타메일을 확인할 수 있습니다. --></p>
				</li>
				<li>
					<a href="mail_uploader_form.jsp" class=2depth ><b><fmt:message key="mail.set.out.insert"/>&nbsp;<!-- 외부메일 등록하기 --></b></a>
					<p><fmt:message key="mail.sub.out.insert"/>&nbsp;<!-- EML(MIME)형식으로 된 파일을 메일함에 넣을 수 있습니다. --></p>
				</li>
				</ul>
		</td>
	</tr>											
</table>
</div>

</form>
</body>
</fmt:bundle>
</html>
