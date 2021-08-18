<%@ page contentType="text/html;charset=utf-8" %>
<% request.setCharacterEncoding("utf-8");%>
<%
	session.invalidate();
    //session.setAttribute("LOGOUT_REASON", "BY_USER");

    //java.util.Hashtable loginSession = (java.util.Hashtable)application.getAttribute("loginSession");
    
	response.sendRedirect("./");
%>