<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.bbs.*" %>
<%@ page import="nek.common.login.LoginUser" %>
<%@ include file="../common/usersession.jsp"%>
<% 	request.setCharacterEncoding("utf-8"); %>
<%!
	private int getMenuCode(String menuCode){
		if ("MENU01".equals(menuCode)) return 1;		//전자메일
		else if ("MENU02".equals(menuCode)) return 2;	//전자결재
		else if ("MENU03".equals(menuCode)) return 3;	//문서관리
		else if ("MENU04".equals(menuCode)) return 4;	//일정관리
		else if ("MENU05".equals(menuCode)) return 5;	//게시판
		else if ("MENU06".equals(menuCode)) return 6;	//커뮤니티
		else if ("MENU07".equals(menuCode)) return 7;	//업무지원
		else if ("MENU08".equals(menuCode)) return 8;	//환경설정
		else if ("MENU09".equals(menuCode)) return 9;	//관리자
		
		return 0;
	}
%>
<%
	String menuCode = request.getParameter("menucode");
	String expandId = request.getParameter("expandid");
	String index = request.getParameter("index");
	String mode = request.getParameter("mode");
	String bbsCode = request.getParameter("bbsid");
	if (expandId == null) expandId = "";
	String initURL = "";
	String mainURL = "";
	
	int menuNum = getMenuCode(menuCode);
	switch(menuNum){
		case 1 :	//전자메일
			//initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode=" + expandId;
			initURL = "/mail/mail_left.jsp";
			if(expandId.equals("MENU0103")){
				mainURL = "../notification/notification_list.jsp";
			}else{
				mainURL = "../mail/mail_list.jsp";
			}
			break;
		case 2 : 	//전자결재
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			mainURL = "../approval/appr_inglist.jsp?menu=240&no=";
			break;
		case 3 : 	//문서관리
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			mainURL = "../dms/dms_list.jsp?mode=alllist";
			break;
		case 4 : 	//일정관리
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			mainURL = "../schedule/schedule_a_month_list.jsp";
			break;
		case 5 : 	//게시판
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			if(bbsCode==null) bbsCode ="bbs00000000000000";
			mainURL = "../bbs/list.htm?bbsId=" + bbsCode;
			break;
		case 6 : 	//커뮤니티
			BBSUserTool userTool = new BBSUserTool(loginuser);
			BBSTitleItem bbsTitle = null;
			ArrayList bbsTitles = null;
			String bbsId = "";
			try
			{
				userTool.getDBConnection();
				bbsTitles = userTool.getBBSTitles();
				for(int i=0; i<bbsTitles.size(); i++)
				{
					bbsTitle = (BBSTitleItem)bbsTitles.get(i);
					bbsId = bbsTitle.bbsId;
				}
			}
			finally
			{
				userTool.freeDBConnection();
			}
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			if(bbsId.equals("")){
				mainURL = "../community/NoCommunity.jsp";
			}else{
				mainURL = "../bbs/list.htm?bbsId="+ bbsId;
			}
		
			break;
		case 7 : 	//업무지원
			//initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			//if(bbsCode==null) bbsCode ="bbs00000000000002";
			//mainURL = "../bbs/bbs_list.jsp?bbsid=" + bbsCode;
			//break;
			userTool = new BBSUserTool(loginuser);
			bbsTitle = null;
			bbsTitles = null;
			bbsId = "";
			try
			{
				userTool.getDBConnection();
				bbsTitles = userTool.getBBSTitles();
				for(int i=0; i<bbsTitles.size(); i++)
				{
					bbsTitle = (BBSTitleItem)bbsTitles.get(i);
					bbsId = bbsTitle.bbsId;
				}
			}
			finally
			{
				userTool.freeDBConnection();
			}
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			if(bbsId.equals("")){
				mainURL = "../community/NoCommunity.jsp";
			}else{
				mainURL = "../bbs/bbs_list.jsp?bbsid="+ bbsId;
			}
			break;
		case 8 : 	//환경설정
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			mainURL = "/common/self_edit.jsp";
			break;
		case 9 : 	//관리자
			initURL = "/common/menuleft.jsp?menucode="+ menuCode +"&submenucode="+ expandId;
			mainURL = "../configuration/environment.jsp";
			break;
		default :
			mainURL = "#";
			break;
	}
	
%>
<html>
<head>
<title>커뮤니티</title>
</head>

<frameset cols="212,*" border="0">
    <frame src="<%=initURL%>" name="left" noresize scrolling="no" marginwidth="0" marginheight="0">
    <frameset id="fs_list" rows="100%,0,0,0" cols=100%>
		<frame id="fr_list" src="<%=mainURL %>" name="main"  scrolling="auto" marginwidth="0" marginheight="0" frameborder=0>
		<frame id="fr_preview_right" src="" name="fr_preview_right" frameborder=0 marginwidth="0" marginheight="0">
		<frame id="fr_preview_bottom" src="" name="fr_preview_bottom" frameborder=0 marginwidth="0" marginheight="0">
		<frame id="" src="" name="hidd" frameborder=0 marginwidth="0" marginheight="0">
	</frameset>
	<noframes>
    <body bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
    <p>이 페이지를 보려면, 프레임을 볼 수 있는 브라우저가 필요합니다.</p>
    </body>
    </noframes>
</frameset>

</html>