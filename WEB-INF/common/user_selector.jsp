<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.common.MessageHelper" %>
<%
	String formname = request.getParameter("formname");
	String target = request.getParameter("target");
	String dpname = request.getParameter("dpname");

	if ("".equals(target) || target == null) target = "self";

	if ("opener".equals(target)) target = "top.opener";		//opener가 존재한다면 top.opener로
	else if("self".equals(target)) target = "document";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><spring:message code="t.members" text="부서원 정보" /></title>
<style>
	td		{font-family:Tahoma, 돋움; font-size:9pt;}

	a:link 		{ font-family:Tahoma, 돋움; font-size:9pt; font-weight:normal; color:#000000; text-decoration:none;}
	a:visited 	{ font-family:Tahoma, 돋움; font-size:9pt; font-weight:normal; color:#000000; text-decoration:none;}
	a:hover		{ font-family:Tahoma, 돋움; font-size:9pt; font-weight:normal; color:#800000; text-decoration:underline;}
	a:Active 	{ font-family:Tahoma, 돋움; font-size:9pt; font-weight:normal; color:#000000; text-decoration:none;}

	.head_le	  {color:000000; text-align:left; 	font-style:normal; background-color:#EFEFEF;  font-weight:bold; line-height:28px;}
	.head_ce	  {color:000000; text-align:center; font-style:normal; background-color:#EFEFEF;  font-weight:bold; line-height:28px;}
	.head_ri	  {color:000000; text-align:right;	font-style:normal; background-color:#EFEFEF;  font-weight:bold; line-height:28px;}

	.td_le	{font-color:#000080; text-align:left; 	font-style:normal; line-height:24px;}
	.td_ce	{font-color:#000080; text-align:center; font-style:normal; line-height:24px;}
	.td_ri	{font-color:#000080; text-align:right;	font-style:normal; line-height:24px;}

	.tblspace01	{height:1px; width:100%;}
	.tblspace02	{height:2px; width:100%;}
	.tblspace03	{height:3px; width:100%;}
	.tblspace05 {height:5px; width:100%;}
	.tblspace07 {height:7px; width:100%;}
	.tblspace09 {height:9px; width:100%;}
</style>
<script language="javascript">
	function setUserInfo(sUid, sUpname, sNname, sEmailid)
	{
		var targetForm;
		var returnVal = sUid + "|" + sUpname + "|" + sNname + "|" + sEmailid + "|" + "<%=dpname%>";

		if (window.dialogArguments && window.dialogArguments != null /*IE전용*/)
		{
			window.returnValue = returnVal;
			window.close();
		}

		if (<%=target%> == null) return;
		targetForm = eval("<%=target%>.<%=formname%>");
		if (targetForm == null) return;
		/*if (targetForm.uid != null) targetForm.uid.value = sUid;
		if (targetForm.upname != null) targetForm.upname.value = sUpname;
		if (targetForm.nname != null) targetForm.nname.value = sNname;
		if (targetForm.emailid != null) targetForm.emailid.value = sEmailid;
		if (targetForm.userinfo != null) targetForm.userinfo.value = returnVal;
		if (targetForm.dpname != null) targetForm.dpname.value = "<%=dpname%>";
		if (targetForm.uid != null) targetForm.uid.focus();*/
		if (targetForm.userId != null) targetForm.userId.value = sUid;
		if (targetForm.upName != null) targetForm.upName.value = sUpname;
		if (targetForm.nName != null) targetForm.nName.value = sNname;
		if (targetForm.emailId != null) targetForm.emailId.value = sEmailid;
		if (targetForm.userinfo != null) targetForm.userinfo.value = returnVal;
		if (targetForm.dpName != null) targetForm.dpName.value = "<%=dpname%>";
		if (targetForm.userId != null) targetForm.userId.focus();

	}
</script>
</head>
<body>
<form name="submitForm">
	<table   cellpadding="0" cellspacing="0" border="0" width="100%">
	<colgroup>
		<col width="60">
		<col width="1">
		<col width="*">
	</colgroup>
	<tr height=2 bgcolor="406bce"><td colspan=3></td></tr>
	<tr height=1 bgcolor="415fa4"><td colspan=3></td></tr>
		<tr>
			<td class="head_ce" nowrap><spring:message code="t.gradeName" text="직위" /></td>
			<td nowrap class="head_ce"><img src=../common/images/i_li_headline.gif></td>
			<td class="head_ce" nowrap><spring:message code="t.name" text="성명" /></td>
		</tr>
		<c:forEach var="user" items="${users }" >
		<tr height=1 bgcolor="dfdfdf"><td colspan=3></td></tr>
		<tr>
			<td class="td_ce"><c:out value="${user.userPosition.upName}" /></td>
			<td nowrap></td>
			<td class="td_ce">
				<a href="javascript:setUserInfo('<c:out value="${user.userId}" />','<c:out value="${user.userPosition.upName }" />','<c:out value="${user.nName}" />','<c:out value="${user.loginId }" />');"><c:out value="${user.nName}" /></a>
			</td>
		</tr>
		</c:forEach>
		<c:if test="${fn:length(users) == 0}">
			<%
				String title = MessageHelper.getMessage("t.members", null, "부서원 정보");
				String noDocExist = MessageHelper.getMessage("i.noDocExist", new String[]{title}, "{0}가 존재하지 않습니다");
			%>
			<tr><td colspan='5'><%=noDocExist %></td></tr>
		</c:if>
		<tr height=1 bgcolor="dfdfdf"><td colspan=3></td></tr>
	</table>
</form>
</body>
</html>