<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="../common/usersession.jsp" %>

<%
	String number = request.getParameter("viewtype");
	viewType[0] = number;
%>