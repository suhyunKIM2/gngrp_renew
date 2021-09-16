<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.bbs.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="nek.common.login.LoginUser" %>
<%@ page import="nek.common.dbpool.DBHandler" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nek.common.*" %>

<jsp:useBean id="poll" scope="page" class="nek.poll.Poll" />
<% request.setCharacterEncoding("utf-8");%>
<%@ include file="../common/usersession.jsp"%>
<%!
	String collapseTree(String expandId, String treeId)
	{
		String sResult = "none";
		if (expandId.equals(treeId)) sResult = "";
		return sResult;
	}
%>
<%
	String expandId = request.getParameter("expandid");
	if (expandId == null || "".equals(expandId)) 
	{
		expandId = "environment";
	}
	expandId = (loginuser.securityId == 9) ? expandId : "selectmenu";


	String moduleId = "";
	ArrayList modulesInfo = null;
	DBHandler db = null;
	Connection conn = null;
	try
	{
		db = new DBHandler();
		conn = db.getDbConnection();
		modulesInfo = CommonTool.getModuleInfo(conn, loginuser.uid);
		if (loginuser.securityId !=9 && modulesInfo.size() == 0)
		{
			out.write("<script language='javascript'>alert('관리권한이 없습니다');history.back();</script>");
			//out.close();
			return;
		}
		if (loginuser.securityId != 9)
		{
			expandId = (String)modulesInfo.get(0);
		}
	}
	finally
	{
		if (db != null) db.freeDbConnection();
	}

%>

<html>
<head>
<title>관리자 메뉴</title>
<link rel=STYLESHEET type=text/css href=../common/css/left.css>
<script language="javascript">
<!--
	function gotoURL(urlID)
	{
		var url;
		switch(urlID)
		{
			<% if (loginuser.securityId == 9){%>
			case "securitylevel":
				url = "./securitylevel.jsp";
				break;
			case "modulesMgr":
				url = "./modulesMgr.jsp";
				break;
			case "environment" :
				url = "./environment.jsp";
				break;
			case "organization":
				url = "./organization_tree.jsp";
				break;
			case "organization_tree":
				url = "./organization_tree.jsp";
				break;
			case "organization_user":
				url = "./user_list.jsp";
				break;
			case "organization_requestuser":
				url = "./user_request_list.jsp";
				break;
			case "positionNduty":
				url = "./positionNduty.jsp";
				break;	
			case "menucode":
				url = "./menucode_list.jsp";
				break;		
			case "mail_representation":
				url = "../mail/mail_representationlist.jsp";
				break;
            case "poll":
            	url = "../poll/poll_admin_list.jsp";
            	break;
            case "loginhistory":
            	url = "../configuration/loginhistory_list.jsp";
            	break;
			case "loginsession":
				url = "../configuration/loginsession.jsp";
				break;
			<%}%>
			case "bbs" :
				url = "../bbs/admin_list.htm";
				break;
			<%
				moduleId = "APPR";
				if (modulesInfo.contains(moduleId))
				{
			%>
			case "approval":
				url = "../approval/approval_manager.jsp";
				break;
            case "appr_<%=  ApprMenuId.ID_2000_NUM %>" :
                url = "<%=  ApprMenuId.ID_2300_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_2100_NUM %>" :	//결재함
                url = "<%=  ApprMenuId.ID_2100_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_2200_NUM %>" :	//양식함
                url = "<%=  ApprMenuId.ID_2200_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_2300_NUM %>" :	//결재서명비밀번호초기화
                url = "<%=  ApprMenuId.ID_2300_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_2400_NUM %>" :	//인수인계
                url = "<%=  ApprMenuId.ID_2400_URL %>" ;
                break;
			<%}%>
			<%
				moduleId = "SCHE";
				if (modulesInfo.contains(moduleId))
				{
			%>
			case "schedule":
				url = "../schedule/schedule_s_category.jsp";
				break;
			case "oMenu_1000" :
				url = "../schedule/schedule_s_category.jsp" ;
				break;
			case "oMenu_1100" :
				url = "../schedule/holiday_list.jsp" ;
				break;
			case "oMenu_1200" :
				url = "../schedule/schedule_s_changeowndoc.jsp" ;
				break;
			case "oMenu_1300" :
				url = "../schedule/schedule_dp_category.jsp" ;
				break;
			<%}%>
			<%
				moduleId = "ADDR";
				if (modulesInfo.contains(moduleId))
				{
			%>
			case "addressbook":
				url = "../addressbook/addressbook_s_category.jsp";
				break;
			case "aMenu_s" :
				url = "../addressbook/addressbook_s_category.jsp" ;
				break;
			case "aMenu_c" :
				url = "../addressbook/company_category.jsp" ;
				break;
			<%}%>
			<%
				moduleId = "EDMS";
				if (modulesInfo.contains(moduleId))
				{
			%>
            case "dms":
            	url = "../dms/dms_category_mgr.jsp";
            	break;
            case "dms_category":
            	url = "../dms/dms_category_mgr.jsp";
            	break;
			case "dmsmanager_list":
				url = "../dms/dms_manager_list.jsp";
				break;
			case "dmsmanager_transfer":
				url = "../dms/dms_manager_transfer.jsp";
				break;
			<%}%>
			default:
				url = "./SelectMenu.html";
				break;

		}
		var obj = document.all[urlID];
		if (obj != null && obj.style.display == "none") obj.style.display = "";
		if (parent.main != null && url != "") parent.main.location.href = url;
	}

	function collapseTree(layerId)
	{
		str=new Array("organization", <%=ApprMenuId.ID_2300_NUM%>, "dms", "schedule", "addressbook", "poll");
		for(var i=0;i<str.length;i++){
			if(document.getElementById(str[i])==null){
			}else{
			var layerObject = document.getElementById(str[i]);
			layerObject.style.display = "none";
			}
		}
		var layerObj = document.getElementById(layerId);
		if (layerObj != null)
		{
			var layerStyle = layerObj.style.display;
			if (layerStyle == "none") layerObj.style.display = "";
			else layerObj.style.display = "none";
		}
	}

//-->
</script>
</head>
<body  onload="javascript:gotoURL('<%=expandId%>')">
<table width="184" cellspacing="0" cellpadding="0" border="0"  valign="top" background="../common/images/left_bg.gif" height=100%>
	<tr>
      <td colspan="2"><img src="../common/images/left_ti_admin.gif"></td>
    </tr>
	<% if (loginuser.securityId == 9){%>
 	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('environment')" class=1depth>운영환경</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
 	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('securitylevel')" class=1depth>보안등급</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
 	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('modulesMgr')" class=1depth>모듈관리자</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
 	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('organization')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('organization')" class=1depth>조직관리</a>
		</td>
	</tr>
	<tr id="organization" style="display:<%=collapseTree(expandId, "organization")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('organization_tree')" class=2depth>조직도</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('organization_user')" class=2depth>사용자</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('organization_requestuser')" class=2depth>사용신청자</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('positionNduty')" class=2depth>직위/직책</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_representation')" class=2depth>대표 메일 관리</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
    <tr>
		<td width="30" class=img><a href="javascript:collapseTree('menucode')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('menucode')" class=1depth>MENU 관리</a>
		</td>
	</tr>
    <tr id="menucode" style="display:<%=collapseTree(expandId, "menucode")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('menucode')" class=2depth>[전체보기]</a>
					</td>
				</tr>
				<%
				MenuCodeItem menuItem = null;
				MenuMgr subMenu = null;
				ArrayList menuList = null;
				int count =0;
				try{
					subMenu = new MenuMgr(loginuser);
					subMenu.getDBConnection();
					menuList = subMenu.getMenuListInfo("TOP");
					if (menuList != null) count = menuList.size();
				}catch(Exception ex){
					System.out.print(ex);
				}finally{
					subMenu.freeDBConnection();
				}
				for(int i=0;i<count;i++){
					menuItem = (MenuCodeItem)menuList.get(i);
				%>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="./menucode_list.jsp?menucode=<%=menuItem.mCode %>&menuname=<%=menuItem.codeName %>" class=2depth target="main"><%=menuItem.codeName %></a>
					</td>
				</tr>
				<%
				}
				%>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<%}%>
	<%
		moduleId = "APPR";
		if (modulesInfo.contains(moduleId))
		{
	%>
 	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('<%=  ApprMenuId.ID_2300_NUM %>')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('<%=  ApprMenuId.ID_2300_NUM %>')" class=1depth><%=  ApprMenuId.ID_2000_HNM %></a>
		</td>
	</tr>
	<tr id="<%=  ApprMenuId.ID_2300_NUM %>" style="display:<%=collapseTree(expandId, ApprMenuId.ID_2300_NUM)%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_2100_NUM %>')" class=2depth><%=  ApprMenuId.ID_2100_HNM %></a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_2200_NUM %>')" class=2depth><%=  ApprMenuId.ID_2200_HNM %></a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_2300_NUM %>')" class=2depth><%=  ApprMenuId.ID_2300_HNM %></a>
					</td>
				</tr>
				<tr>
	    			<td width="33" class="img"><img src="../common/images/left_sub_menu.gif"></td>
					<td class="sub" background="../common/images/left_menusub.gif" width="151" height="19">
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_2400_NUM %>');" class="2depth"><%=  ApprMenuId.ID_2400_HNM %></a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<%}%>
	<%
		moduleId = "EDMS";
		if (modulesInfo.contains(moduleId))
		{
	%>

	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('dms')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('dms')" class=1depth>문서관리</a>
		</td>
	</tr>
	<tr id="dms" style="display:<%=collapseTree(expandId, "dms")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('dms_category')" class=2depth>문서분류</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('dmsmanager_list')" class=2depth>문서목록</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('dmsmanager_transfer')" class=2depth>인수인계</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<%}%>
	<%
		moduleId = "SCHE";
		if (modulesInfo.contains(moduleId))
		{
	%>

	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('schedule')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('schedule')" class=1depth>공유일정관리</a>
		</td>
	</tr>
	<tr id="schedule" style="display:<%=collapseTree(expandId, "schedule")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('oMenu_1000')" class=2depth>공유일정종류등록</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('oMenu_1100')" class=2depth>국경일관리</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('oMenu_1200')" class=2depth>공유일정 인수인계</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<%}%>
	<%
		moduleId = "ADDR";
		if (modulesInfo.contains(moduleId))
		{
	%>

 	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('addressbook')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('addressbook')" class=1depth>주소록</a>
		</td>
	</tr>
	<tr id="addressbook" style="display:<%=collapseTree(expandId, "addressbook")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('aMenu_s')" class=2depth>공용분류등록</a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('aMenu_c')" class=2depth>거래처분류등록</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<%}%>
 	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('bbs')" class=1depth>게시판관리</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<% if (loginuser.securityId == 9) {%>
 	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('poll')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('poll')" class=1depth>설문조사</a>
		</td>
	</tr>
	<tr id="poll" style="display:<%=collapseTree(expandId, "poll")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="../poll/poll_form.jsp" target="main" class=2depth>[설문등록]</a>
					</td>
				</tr>
				<%
				String user = "admin";
				ArrayList datas_year = null;
				datas_year = poll.year(user);
				Iterator iter_year = datas_year.iterator();
				HashMap data_year = null;
				while(iter_year.hasNext())
				{
					data_year = (HashMap)iter_year.next();
				%>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="../poll/poll_admin_list.jsp?year=<%=data_year.get("year")%>" target="main" class=2depth><%=data_year.get("year")%>년도</a>
					</td>
				</tr>
				<%}%>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
  	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('loginhistory')" class=1depth>접속로그</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
  	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('loginsession')" class=1depth>로그인세션정보</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<%}%>
	<tr height="100%">
		<td colspan="2"></td>
	</tr>
</table>
</body>
</html>