<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><spring:message code="t.userInfo" text="사용자 정보" /></title>
<style>
td {font-size:9pt;}
</style>
</head>
<body text="000000" bgcolor="ffffff" style="margin:1px;">
<!-- 전체 div 사이즈 353px 임 -->
<!-- 타이틀 바 사이즈 -->
<table width=100% cellspacing=0 cellpadding=0 border=0 style="border:1px solid #ADADAD;">
<tr height=26>
<td width=* background="../common/images/etc_infor_ti_bg.gif">
	<font color="#5a7f10" style="font-size:9pt"><b>&nbsp;&nbsp;<c:out value="${user.nName}"/></b></font>
	</td>
<td width=20 align=center background="../common/images/etc_infor_ti_bg.gif">
<!-- <a href="#" onClick="parent.HideUserInfo()"><img src="../common/images/close.gif" border=0></A>  -->
</td>
</tr>
</table>
<table border="0" style="font-size:9pt; width:100%;" cellspacing=0 cellpadding=0>
	<tr>
		<td valign="middle" align=center width=110>
<!-- 		<img id='userphoto'  SRC="../userdata/photos/${user.userId }" BORDER=0 width="100" height="120"  -->
<!-- 		onerror="this.src='../common/images/photo_user_default.gif';"> -->
		<img id='userphoto'  SRC="/userdata/photos/${user.userId }" BORDER=0 width="100" height="120" 
		onerror="this.src='../common/images/photo_user_default.gif';">
		</td>
		<td valign="center">
			<table id=Info width=99% border=0 cellpadding=0 cellspacing=0>
				<tr height=22>
					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.dpName" text="소 속" /> : <c:out value="${user.department.dpName}" /></td>
				</tr>
				<tr><td background="../common/images/etc_infor_vline.gif" height=1></td></tr>
				<tr height=22>
					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.userPosition" text="직급"  /> : <c:out value="${user.userPosition.upName }" /></td>
				</tr>
				<tr><td background="../common/images/etc_infor_vline.gif" height=1></td></tr>
				<tr height=22>
					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.mainJob" text="담당업무 " /> : <c:out value="${user.mainJob }" /></td>
				</tr>
				<tr><td background="../common/images/etc_infor_vline.gif" height=1></td></tr>
				<tr height=22>
					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.tel" text="Tel." /> : <c:out value="${user.telNo }" /></td>
				</tr>
				<tr><td background="../common/images/etc_infor_vline.gif" height=1></td></tr>
				<tr height=22>
					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.cellTel" text="핸드폰번호" /> : <c:out value="${user.cellTel}" /></td>
				</tr>
				<tr><td background="../common/images/etc_infor_vline.gif" height=1></td></tr>
				<tr height=22>
<%-- 					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.email" text="Email" /> : <a href="#" onClick="parent.mailsender('<c:out value="${user.loginId}" />');"><c:out value="${user.loginId}@${userConfig.mailDomain }" /></a></td> --%>
					<td>&nbsp;<img src="../common/images/etc_infor_dot.gif" border=0>&nbsp;<spring:message code="t.email" text="Email" /> : <a href="mailto:<c:out value="${user.userName}" />@<c:out value="${mailDomain }" />"><c:out value="${user.userName}" />@<c:out value="${mailDomain }" /></a></td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
</body>
</html>
