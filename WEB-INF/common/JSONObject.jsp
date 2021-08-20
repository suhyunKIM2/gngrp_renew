<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="net.sf.json.*"%>
<%@ include file="/common/usersession.jsp" %>
<%
	JSONObject jsonData = ((JSONObject)request.getAttribute("jsonData"));
	out.println(jsonData);
%>