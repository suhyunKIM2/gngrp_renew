<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String loginId = request.getParameter("loginId") ;    
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>로그인ID 중복검사</title>
</head>
<body style="margin:0;padding:0;">
<iframe style="width:100%;height:100%:border:0px;" src="<c:url value="/configuration/loginId_check.htm" />?loginId=<%=loginId %>"></iframe>
</body>
</html>