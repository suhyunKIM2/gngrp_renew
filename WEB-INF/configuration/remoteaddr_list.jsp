<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.web.RemoteAddrHelper" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>IP접근허용관리</title>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>
<%@ include file="../common/include.common.jsp"%>
</head>
<script>
function goDel(ip){
	$("input[name=cmd]").val("D");
	$("input[name=addr]").val(ip);
	document.cmdForm.submit();
}

function goAdd(){
	$("input[name=cmd]").val("A");
	document.cmdForm.submit();
}
function goService(cmd){
	$("input[name=cmd]").val(cmd);
	document.cmdForm.submit();
}
</script>
<body>
<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td style="padding-left:5px;">
			<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> IP접근허용관리 </span>
		</td>
	</tr>
</table>
<!-- List Title -->

<%
String filterIsOn = (String)request.getAttribute("filterIsOn");

RemoteAddrHelper.RemoteAddr[] localSubAddrs = (RemoteAddrHelper.RemoteAddr[])request.getAttribute("localSubIP4");
RemoteAddrHelper.RemoteAddr[] allowedIP4s = (RemoteAddrHelper.RemoteAddr[])request.getAttribute("allowedIP4");
RemoteAddrHelper.RemoteAddr[] allowedMACs = (RemoteAddrHelper.RemoteAddr[])request.getAttribute("allowedMAC");
%>

<table width="800" cellspacing="0" cellpadding="0" border="0" style="margin-left:5px;">
	<tr height="30">
		<td><img src="../common/images/i_body.gif" align="absmiddle" style="vertical-align:middle;"><B>허용 IP 상태</B></td>
	</tr>
</table>
<table width="800" cellspacing="0" cellpadding="0" border="0" style="margin-left:5px;">
	<colgroup>
		<col width="15%">
		<col width="30%">
		<col width="55%">
	</colgroup>
	<tr>
		<td class="td_le1">IP접근허용</td>
<% if ("1".equals(filterIsOn)){ %>
		<td class="td_le2">동작중</td>
		<td class="td_le2">
			<input type="button" value="START" onclick="goService('ON');" disabled="disabled">
			<input type="button" value="STOP" onclick="goService('OFF');" style="font-weight: bold;">
		</td>
<% } else { %>
		<td class="td_le2">중지됨</td>
		<td class="td_le2">
			<input type="button" value="START" onclick="goService('ON');" style="font-weight: bold;">
			<input type="button" value="STOP" onclick="goService('OFF');" disabled="disabled">
		</td>
<% } %>
	</tr>
</table>
<br>

<table width="800" cellspacing="0" cellpadding="0" border="0" style="margin-left:5px;">
	<tr height="30">
		<td><img src="../common/images/i_body.gif" align="absmiddle" style="vertical-align:middle;"><B>허용 IP 등록</B></td>
	</tr>
</table>

<form name="cmdForm" action="/configuration/remoteaddr_list.htm" method="POST">
	<input type="hidden" name="cmd" value="">
	<table width="800" cellspacing="0" cellpadding="0" border="0" style="margin-left:5px;">
		<colgroup>
			<col width="15%">
			<col width="30%">
			<col width="15%">
			<col width="30%">
			<col width="10%">
		</colgroup>
		<tr>
			<td class="td_le1">허용 IP</td>
			<td class="td_le2"><input type="text" name="addr" style="width:90%"></td>
			<td class="td_le1">설명</td>
			<td class="td_le2"><input type="text" name="descr" style="width:90%"></td>
			<td class="td_le2"><input type="submit" value="등록" onclick="goAdd();"></td>
		</tr>
	</table>
</form>
<br>

<table width="800" cellspacing="0" cellpadding="0" border="0" style="margin-left:5px;">
	<tr height="30">
		<td><img src="../common/images/i_body.gif" align="absmiddle" style="vertical-align:middle;"><B>허용 IP 목록</B> (※ IP접근허용 동작시 목록에 해당하는 IP만 접속할 수 있습니다.)</td>
	</tr>
</table>
<table width="800" cellspacing="0" cellpadding="0" border="0" style="margin-left:5px;">
	<colgroup>
		<col width="30%">
		<col width="60%">
		<col width="10%">
	</colgroup>
	<tr>
		<td class="td_le1">IP(MAC)</td>
		<td class="td_le1">설명</td>
		<td class="td_le1"></td>
	</tr>
<%
	if (localSubAddrs != null) {
		for(int i=0; i<localSubAddrs.length; i++){
	// 		out.print(localSubAddrs[i].getAddr() + "<br>");
%>
	<tr>
		<td class="td_le2"><%=localSubAddrs[i].getAddr() %></td>
		<td class="td_le2"></td>
		<td class="td_le2">Default</td>
	</tr>
<%
		}
	}
%>
<%
	for(RemoteAddrHelper.RemoteAddr remoteAddr:allowedIP4s){
// 		String type = remoteAddr.getAddr().substring(remoteAddr.getAddr().indexOf("/")+1, remoteAddr.getAddr().length());
// 		String hostIp = remoteAddr.getAddr().substring(0, remoteAddr.getAddr().indexOf("/")); 
%>
	<tr>
		<td class="td_le2"><%=remoteAddr.getAddr() %></td>
		<td class="td_le2"><%=remoteAddr.getDescr() %></td>
		<td class="td_le2"><input type="button" value="삭제" onclick="goDel('<%=remoteAddr.getAddr()%>')"></td>
	</tr>
<%
	}
%>
<!-- MAC 주소 목록 -->
<%
	for(RemoteAddrHelper.RemoteAddr remoteAddr:allowedMACs){
// 		String type = remoteAddr.getAddr().substring(remoteAddr.getAddr().indexOf("/")+1, remoteAddr.getAddr().length());
// 		String hostIp = remoteAddr.getAddr().substring(0, remoteAddr.getAddr().indexOf("/")); 
%>
	<tr>
		<td class="td_le2"><%=remoteAddr.getAddr() %></td>
		<td class="td_le2"><%=remoteAddr.getDescr() %></td>
		<td class="td_le2"><input type="button" value="삭제" onclick="goDel('<%=remoteAddr.getAddr()%>')"></td>
	</tr>
<%
	}
%>
</table>

</body>
</html>