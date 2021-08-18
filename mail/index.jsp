<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="../common/usersession.jsp"%>
<%
	request.setCharacterEncoding("utf-8");
	String queryString = request.getQueryString();
%>
<html>
<head>
<title>제목없음</title>
</head>
<frameset cols="184,*" border="0">
    <frame src="mail_left.jsp?<%=(queryString == null) ? "" : queryString%>" name="left" noresize scrolling="no" marginwidth="0" marginheight="0">
    <frame src="about:blank" name="main" scrolling="auto" marginwidth="0" marginheight="0">
    <noframes>
    <body bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
    <p>이 페이지를 보려면, 프레임을 볼 수 있는 브라우저가 필요합니다.</p>
    </body>
    </noframes>
</frameset>

</html>
