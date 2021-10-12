<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek3.domain.notification.*" %>
<%!
	private String readableFileSize(long size) {
		if (size <= 0) return "0";
		final String[] units = new String[] { "B", "KB", "MB", "GB", "TB" };
		int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
		return new DecimalFormat("#,##0.00").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
	}
%>
<%
	SimpleDateFormat dtformat = new SimpleDateFormat("yyyy-MM-dd HH:mm aa");
	Notes notes = (Notes)request.getAttribute("notes");

	String notiTosValue = "";
	
	String searchKey = request.getParameter("searchKey");
	String searchValue = request.getParameter("searchValue");
	String boxId = request.getParameter("boxId");
	String noteType = request.getParameter("noteType");
	
	if(searchKey == null) searchKey = "";
	if(searchValue == null) searchValue = "";
	if(boxId == null) boxId = "1";
	if(noteType == null) noteType = "0";
	

	Map recipients = notes.getDepartmentRecipients();
	if (recipients != null) {
		Iterator iter = recipients.values().iterator();
		while (iter.hasNext()) {
			Address address = (Address)iter.next();
			if (!notiTosValue.equals("")) notiTosValue += ", ";
			notiTosValue += HtmlEncoder.encode(address.toDisplayString());
		}
	}
	recipients = notes.getPersonRecipients();
	if (recipients != null) {
		Iterator iter = recipients.values().iterator();
		while (iter.hasNext()) {
			UserAddress user = (UserAddress)iter.next();
			if (!notiTosValue.equals("")) notiTosValue += ", ";
			notiTosValue += HtmlEncoder.encode(user.toDisplayString());
		}
	}
	

	String notiAttachValue = "";

	String homePath = "http://" + request.getServerName();
	String baseURL = homePath;
	if (!baseURL.endsWith("/")) {
		baseURL += "/";
	}
	baseURL += "notification/notification_dn_attachment.jsp?fileid=";
	
	if (notes.getNoteAttachs() != null && notes.getNoteAttachs().size() > 0) {
		StringBuffer attachFiles = new StringBuffer();
		Iterator iter = notes.getNoteAttachs().iterator();
		int count = 0;
		while (iter.hasNext()) {
			NoteAttachments attachment = (NoteAttachments)iter.next();
			String fileName = attachment.getFileName();
			if (count != 0) notiAttachValue += "<br>";
			notiAttachValue += "<a href=\""+baseURL+attachment.getId().getServerName()+"\" data-ajax=\"false\" title=\""+fileName+"\">"
					+fileName+"</a> <span>("+readableFileSize(attachment.getFileSize())+")</span>";
			count++;
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Garam Mobile Demo</title>	
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
</head>
<body>

<div data-role="page" id="page-list">
	<div data-role="header" data-position="fixed" data-theme="b">
		<h2>Mobile Groupware</h2>
		<a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">Home</a>
		<a href="/mobile/nav.jsp" data-icon="search" data-rel="dialog" data-transition="fade" data-iconpos="right">Menu</a>
	</div>
	
	<div data-role="content" style="padding:5px;">
		<p style="font-size:18px;"><b><%=notes.getSubject() %></b></p>
		<hr/>
		<p style="font-size:14px;">
			<img align="absmiddle" src="/common/images/icon-send-user.png"/> <fmt:message key="t.outgoing"/><!-- 발신 --> : 
			<%=HtmlEncoder.encode(notes.getSender().toDisplayString()) %>&nbsp;
			<%=dtformat.format(notes.getCreated()) %>
		</p>
		
		<div data-role="collapsible" data-theme="c" data-content-theme="d" data-mini="true">
		    <h4><fmt:message key="mail.sendto"/><!-- 수신 --></h4>
		    <p style="font-size:14px;">
			<img align="absmiddle" src="/common/images/icon-users.png"/> 
			<%=notiTosValue %></p>
		</div>

		<div data-role="collapsible" data-theme="c" data-content-theme="d" data-mini="true">
			<h4><fmt:message key="t.attached"/><!-- 첨부 --></h4>
		    <p style="font-size:14px;">
			<%=notiAttachValue %></p>
		</div>
		
		<hr/>
		<div class="ui-corner-all" style="/* border:1px solid #aaa; width:760px; */">
		<%=notes.getBody() %>
		</div>
	</div>

	<div data-role="footer" data-position="fixed" class="footer-docs ui-bar" data-theme="b">
		<!-- 		<a href="javascript:history.back()" data-ajax='false' data-icon="arrow-l">Back</a> -->
		<a href="javascript:location.href='/mobile/notification/list.jsp?boxId=<%=boxId %>&noteType=<%=noteType %>&searchKey=<%=searchKey %>&searchValue=<%=searchValue %>'" data-ajax='false' data-icon="arrow-l">Back</a>
		<a href="javascript:location.reload()" data-ajax='false' data-icon="refresh">Reload</a>
		<a href="/mobile/logout.jsp" data-ajax='false' data-rel="dialog" data-icon="delete" data-iconpos="right" style="float:right;">Logout</a>
	</div>
</div>
<style>
dt {padding:0px; margin:0px;}
.ui-btn-left, .ui-btn-right, .ui-input-clear, .ui-btn-inline, .ui-grid-a .ui-btn, .ui-grid-b .ui-btn, .ui-grid-c .ui-btn, .ui-grid-d .ui-btn, .ui-grid-e .ui-btn, .ui-grid-solo .ui-btn {
margin-right: 2px;
margin-left: 2px;
}
.ui-navbar li .ui-btn {text-align:left;}
</style>
</body>
</html>