<%
	String mode = request.getParameter("mode");
	String expandId = request.getParameter("expandid");
	if (expandId == null) expandId = "";
	String menuURL = "./configuser_left.jsp?expandid=" + expandId;
	String title = "사용자환경설정";
	if (mode == null || "".equals(mode)) mode = "admin";
	if (mode.equals("admin"))
	{
		title = "관리자";
		menuURL = "./config_left.jsp?expandid=" + expandId;
	}
%>
<html>

<head>
<title><%=title%></title>
</head>

<frameset cols="184,*,0" border="0">
    <frame src="<%=menuURL%>" name="left" noresize scrolling="no" marginwidth="0" marginheight="0">
    <frame src="" name="main" scrolling="auto" marginwidth="0" marginheight="0">
    <frame src="" name="hidd" >
	<noframes>
    <body bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
    <p>이 페이지를 보려면, 프레임을 볼 수 있는 브라우저가 필요합니다.</p>
    </body>
    </noframes>
</frameset>

</html>