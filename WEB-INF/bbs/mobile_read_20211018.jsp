<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek3.domain.bbs.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek.common.util.Convert"%>
<%!
	private String readableFileSize(long size) {
		if (size <= 0) return "0";
		final String[] units = new String[] { "B", "KB", "MB", "GB", "TB" };
		int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
		return new DecimalFormat("#,##0.00").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
	}
%>
<%
Bbs bbs = (Bbs)request.getAttribute("bbs");
BbsMaster bbsMaster = (BbsMaster)request.getAttribute("bbsMaster");

String bbsAttachValue = "";
String baseURL = "http://" + request.getServerName() + "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo=";
String searchKey = request.getParameter("searchKey");
String searchValue = request.getParameter("searchValue");
String bbsId = request.getParameter("bbsId");
String bbsNm = request.getParameter("menuName");
if(searchKey == null) searchKey = "";
if(searchValue == null) searchValue = "";

List<BbsFile> files = bbs.getFiles();
for(int i = 0; i < files.size(); i++) {
	BbsFile file = files.get(i);
	String fileName = file.getFileName();
	if (i != 0) bbsAttachValue += "<br>";
	bbsAttachValue += "<a href=\""+baseURL+file.getId().getFileNo()+"\" data-ajax=\"false\" title=\""+fileName+"\">"
			+fileName+"</a> <span>("+readableFileSize(file.getFileSize())+")</span>";
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
<script type="text/javascript">
$("#page-list").live("pageshow", function(e) {
	$("#bbsContent").find("a").attr("data-ajax", "false");
});
</script>
</head>

<body>
<div data-role="page" id="page-list">
	<div data-role="header" data-position="fixed" data-theme="b">
		<h2>Mobile Groupware</h2>
		<a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">Home</a>
		<a href="/mobile/nav.jsp" data-icon="search" data-rel="dialog" data-transition="fade" data-iconpos="right">Menu</a>
	</div>
	
	<div data-role="content" style="padding:5px;">
		<p style="font-size:18px;"><b><c:out value="${bbs.subject}" /></b></p>
		<hr/>
		<p style="font-size:14px;">
			<img align="absmiddle" src="/common/images/icon-clock-arrow.png"/> 
			<spring:message code="t.posting.period" text="게시기간"/> : 
			<c:out value="${bbs.openDate}" /> ~ <c:out value="${bbs.closeDate}" />
		</p>

		<div data-role="collapsible" data-theme="c" data-content-theme="d" data-mini="true">
			<h4><fmt:message key="t.attached"/><!-- 첨부 --></h4>
		    <p style="font-size:14px;">
			<%=bbsAttachValue %></p>
		</div>
		
		<hr/>
		<div id="bbsContent" class="ui-corner-all" style="/* border:1px solid #aaa; width:760px; */">
		${bbs.content}
		</div>
	</div>

	<div data-role="footer" data-position="fixed" class="footer-docs ui-bar" data-theme="b">
		<!-- 		<a href="javascript:history.back()" data-ajax='false' data-icon="arrow-l">Back</a> -->
		<a href="javascript:location.href='/mobile/bbs/list.jsp?bbsId=<%=bbsId %>&bbsNm=<%=bbsNm %>&searchKey=<%=searchKey %>&searchValue=<%=searchValue %>'" data-ajax='false' data-icon="arrow-l">Back</a>
		<a href="javascript:location.reload()" data-ajax='false' data-icon="refresh">Reload</a>
		<a href="/mobile/logout.jsp" data-ajax='false' data-rel="dialog" data-icon="delete" data-iconpos="right" style="float:right;">Logout</a>
	</div>
</div>

</body>
</html>