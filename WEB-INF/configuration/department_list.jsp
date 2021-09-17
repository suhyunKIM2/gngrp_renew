<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek3.domain.Department" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
	String pDpId = request.getParameter("pdpid");
	String pDpName = request.getParameter("pdpname");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>부서정보</title>
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
<%@ include file="../common/include.common.jsp"%>

<script language="javascript">
	//SetHelpIndex("admin_organization");
</script>
<script language="javascript">
	var targetWin;
	function goSubmit(cmd, isNewWin ,dpId){
		var frm = document.getElementById("search");
		switch(cmd)
		{
			case "view":
				frm.elements["dpId"].value = dpId;
				frm.action = "./department_form.htm";
				break;
			case "new":
				frm.action = "./department_form.htm";
				break;

		}
		if (isNewWin == "true"){
			targetWin = OpenWindow( "", "targetWin", "850" , "550" );
			frm.opentype.value = "winopen";
			frm.target = "targetWin";
		}
		else{
			frm.target = "_self";
		}

		frm.submit();
	}
</script>

</HEAD>
<BODY>
<form:form commandName="search">
	<form:hidden path="searchKey" />
	<form:hidden path="searchValue" />
	<form:hidden path="dpId" />
	<form:hidden path="pDpId" />
</form:form>

<table width="520" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
<!-- 			<a href="javascript:goSubmit('new','false','');"><img src=../common/images/act_record_off.gif border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a> -->
			<a onclick="javascript:goSubmit('new','false','');" class="button white medium">
			<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="t.insert" text="등록"/></a>
		</td>
	</tr>
</table>

<table class=tblspace05><tr><td></td></tr></table>

<table  cellpadding="0" cellspacing="0" border="0" width="520">
	<!--<colgroup>
		<col width="*">
		<col width="1">
		<col width="150">
		<col width="1">
		<col width="80">
	</colgroup>-->
	<!--<tr height=2 bgcolor="406bce"><td colspan=3></td></tr>-->
	<tr height=1 bgcolor="415fa4"><td colspan=3></td></tr>
	<tr>
		<td class="head_ce"><spring:message code="emp.dept.name" text="부서명"/></td>
		<td width="1"  class="head_ce" nowrap><img src=../common/images/i_li_headline.gif></td>
		<td class="head_ce"><spring:message code="emp.dept.head" text="부서장"/></td>
		<!-- <td width="1"  class="head_ce" nowrap><img src=../common/images/i_li_headline.gif></td>
		<td class="head_ce">사용여부</td> -->
	</tr>
	<%
		List<Department> deptList = (List<Department>)request.getAttribute("childDepts");
		for(int i=0 ; i < deptList.size(); i++)
		{
			Department dept = deptList.get(i);
	%>
	<tr height=1 bgcolor="dfdfdf"><td colspan=3></td></tr>
	<tr <% if ((i % 2) == 1) out.write("bgcolor='#F5F5F5'");%>>
		<td nowrap class="td_ce"><a href="javascript:goSubmit('view','false','<%=dept.getDpId()%>');"><%=dept.getDpName()%></a></td>
		<td nowrap></td>
		<td nowrap class="td_ce">
			<a href="javascript:ShowUserInfo('<%=dept.getManager().getUserId()%>');"><%=dept.getManager().getnName()%></a>
		</td>
	</tr>
	<%
		}
		/*
		if (deptList.size() == 0){
			out.write("<tr><td colspan='3'>" + StringUtil.getNODocExistMsg("하위부서가 존재하지 않습니다") + "</td></tr>");
		}
		*/
	%>
	<tr height=1 bgcolor="dfdfdf"><td colspan=3></td></tr>

</table>
<table><tr><td class=tblspace03></td></tr></table>
<table width="520" border="0" cellspacing="0" cellpadding="0">
	<tr align="right">
		<td>
<!-- 			<a href="javascript:goSubmit('new','false','');"><img src=../common/images/act_record_off.gif border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a> -->
			<a onclick="javascript:goSubmit('new','false','');" class="button white medium">
			<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="t.insert" text="등록"/></a>
		</td>
	</tr>
</table>
</BODY>
</HTML>