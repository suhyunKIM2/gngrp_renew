<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="nek.diary.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>

<html>
<head>
<title>퇴직임직원</title>

</head>

<frameset rows="110,*" frameborder="no" border="0" framespacing="0" cols="*"> 
  <frame name="tt" src="./retireuser_select_t.jsp" scrolling="no" noresize >
  <frame name="dd" src="./retireuser_select_d.jsp" scrolling="yes" noresize >  
</frameset>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html> 
 