<%@ page contentType="text/xml;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.dbpool.*" %>

<%@ include file="../common/usersession.jsp" %>
<%
	request.setCharacterEncoding("utf-8");

	String passWd = request.getParameter("password");
	String uid = request.getParameter("uid");
	if(uid==null||uid.equals("")) uid ="";
	int result = 0;

	PasswordMgr PasswordMgr = new PasswordMgr(loginuser);
	Connection pconn = null;
	DBHandler db = new DBHandler();
	
	try{
		pconn = db.getDbConnection();
		
		result = PasswordMgr.getPassValue(pconn, passWd, uid);//직전패스워드 체

	} finally {
		db.freeDbConnection();
	}

	
	//response.resetBuffer();
	response.setContentType("text/xml");
%>
<%
	out.println(result);
%>