<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Mobile Groupware</title>
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
	<script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
	<script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
	<script type="text/javascript">
	</script>
</head>
<body>
<div data-role="page">
	<div data-role="header" data-theme="e" class="ui-corner-top ui-overlay-shadow ui-header ui-bar-e" role="banner">
		<h1 class="ui-title" tabindex="0" role="heading" aria-level="1">System Log out</h1>
	</div>
	<div data-role="content" data-theme="e">
		<h3><%=msglang.getString("c.logout") /* 그룹웨어를 종료 하시겠습니까? */ %></h3>
		<a href="/logout.jsp" data-ajax='false' data-role="button" data-theme="b">Log-Out</a>       
		<a href="docs-dialogs.html" data-role="button" data-rel="back" data-theme="c">Cancel</a>    
	</div>
</div>
</body>
</html>