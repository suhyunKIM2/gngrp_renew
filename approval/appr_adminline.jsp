<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="nek.approval.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%
    //String sUid = loginuser.uid ;  //
    String sNo = ApprUtil.setnullvalue(request.getParameter("no"), ApprDocCode.APPR_NUM_1) ;    
    
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>결재선선택</title>
</head>


<%
    if(sNo.equals(ApprDocCode.APPR_NUM_1))  //결재선 수정, 신규
    {
%>
<frameset rows="50,*" scrolling="no" noresize border="0"  cols="*">
<%
    } else if(sNo.equals(ApprDocCode.APPR_NUM_2)) { //결재선 선택
%>
<frameset rows="40,*" scrolling="no" noresize border="0"  cols="*">
<%
    }
%>
    <frame name="topfrm" src="./appr_adminline_t.jsp?no=<%= sNo %>"  scrolling="no" noresize>    
<frameset cols="250, *,0" rows="*, 0" scrolling="no" noresize border="0"  >
    <frame name="leftfrm" src="./appr_adminline_l.jsp?no=<%= sNo %>"  scrolling="no" noresize> <!-- scrolling="no" noresize -->
    <frame name="rightfrm" src="./appr_adminline_r.jsp?no=<%= sNo %>"  scrolling="no" noresize>    
    <frame name="hidfrm" src="">
</frameset>
    <!-- <frame name="downfrm" src="./appr_line_d.jsp?no=<%= sNo %>"  scrolling="no" noresize>     -->
</frameset>    

<noframes>
    <body bgcolor="#FFFFFF">
    </body>
</noframes>
</html>