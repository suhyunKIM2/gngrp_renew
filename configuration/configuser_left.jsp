<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.bbs.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="nek.common.login.LoginUser" %>
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
	if (expandId == null || "".equals(expandId)) expandId = "selfinfo";		//개인환경설정

%>

<html>
<head>
<title>사용자 환경설정 메뉴</title>
<link rel=STYLESHEET type=text/css href=../common/css/left.css>
<script language="javascript">
<!--
	function gotoURL(urlID)
	{
		var url;
		switch(urlID)
		{
			case "selfinfo":
				url = "../common/self_edit.jsp";
				break;
            case "<%=  ApprMenuId.ID_410_NUM %>" :	//서명등록
                url = "<%=  ApprMenuId.ID_410_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_420_NUM %>" :	//결재비밀번호
                url = "<%=  ApprMenuId.ID_420_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_430_NUM %>" :	//결재선
                url = "<%=  ApprMenuId.ID_430_URL %>" ;
                break;
            case "<%=  ApprMenuId.ID_440_NUM %>" :	//부재설정
                url = "<%=  ApprMenuId.ID_440_URL %>" ;
                break;
            case "mail_settings":					//대표 - 편지서명
            	url = "../mail/mail_signature.jsp";
            	break;
            case "mail_signature":
            	url = "../mail/mail_signature.jsp";
            	break;
            case "mail_rules":
            	url = "../mail/mail_rules.jsp";
            	break;
            case "mail_mailboxes":
            	url = "../mail/mail_mailboxes.jsp";
            	break;

            case "mail_grouplist":
            	url = "../mail/mail_grouplist.jsp";
            	break;
            case "mail_pop3support":
            	url = "../mail/mail_pop3support.jsp";
            	break;
            case "mail_representationlist":
            	url = "../mail/mail_representationlist.jsp";
            	break;

            case "schedule":						//대표 - 일정분류
            	url = "../schedule/schedule_p_category.jsp";
            	break;
			case "oMenu_1000" :
				url = "../schedule/schedule_p_category.jsp" ; //일정분류
				break;
			case "myfavorite" :
				url = "../support/myfavorite_mgr.jsp";
				break;
			case "mypage" :
				url = "../support/mypage.jsp";
				break;
			default:
				url = "";
				break;
		}
		var obj = document.all[urlID];
		if (obj != null && obj.style.display == "none") obj.style.display = "";
//		collapseTree(urlID);

		if (parent.main != null && url != "") parent.main.location.href = url;
	}

	function collapseTree(layerId)
	{
		str=new Array("mail_settings", <%=ApprMenuId.ID_440_NUM%>, "schedule");
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
      <td colspan="2"><img src="../common/images/left_ti_configuration.gif"></td>
    </tr>
 	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('selfinfo')" class=1depth>개인정보</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
	<% if (loginuser.securityId > 0){%>
	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('mail_settings')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('mail_settings')" class=1depth>전자메일</a>
		</td>
	</tr>
	<tr id="mail_settings" style="display:<%=collapseTree(expandId, "mail_settings")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_signature')" class=2depth>서명 관리</a>
					</td>
				</tr>
				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_rules')" class=2depth>자동 분류</a>
					</td>
				</tr>
				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_mailboxes')" class=2depth>편지함 관리</a>
					</td>
				</tr>

				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_grouplist')" class=2depth>그룹 관리</a>
					</td>
				</tr>
				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_pop3support')" class=2depth>POP3 가져오기</a>
					</td>
				</tr>
				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="../addressbook/addressbook_excel_form.jsp"  target="main" class=2depth>Outlook 주소록 가져오기</a>
					</td>
				</tr>
				<%if(loginuser.securityId >=9){ %>
				<tr>
					<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('mail_representationlist')" class=2depth>대표메일 보기</a>
					</td>
				</tr>
				<%} %>

            </table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
 	<tr>
		<td width="30" class=img><a href="javascript:collapseTree('<%=  ApprMenuId.ID_440_NUM %>')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('<%=  ApprMenuId.ID_440_NUM %>')" class=1depth><%=  ApprMenuId.ID_000_HNM %></a>
		</td>
	</tr>
	<tr id="<%=  ApprMenuId.ID_440_NUM %>" style="display:<%=collapseTree(expandId, ApprMenuId.ID_440_NUM)%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_410_NUM %>')" class=2depth><%=  ApprMenuId.ID_410_HNM %></a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_420_NUM %>')" class=2depth><%=  ApprMenuId.ID_420_HNM %></a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_430_NUM %>')" class=2depth><%=  ApprMenuId.ID_430_HNM %></a>
					</td>
				</tr>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('<%=  ApprMenuId.ID_440_NUM %>')" class=2depth><%=  ApprMenuId.ID_440_HNM %></a>
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
		<td width="30" class=img><a href="javascript:collapseTree('schedule')"><img src="../common/images/leftmenu_dot_off.gif" border="0"></a></td>
		<td width="154" class="menu">
			<a href="javascript:collapseTree('schedule')" class=1depth>일정관리</a>
		</td>
	</tr>
	<tr id="schedule" style="display:<%=collapseTree(expandId, "schedule")%>">
		<td width=184 colspan=2 background=../common/images/left_sub_inbg.gif>
			<table width=184 cellpadding=0 cellspacing=0 border=0>
				<tr>
	    			<td width=33 class=img><img src=../common/images/left_sub_menu.gif></td>
					<td class=sub background=../common/images/left_menusub.gif width=151 height=19>
						<a href="javascript:gotoURL('oMenu_1000')" class=2depth>일정종류등록</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr>
<!-- 
디토소프트 요구사항 즐겨찿기 대신에 세계시간을 보여달라.
 	<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('myfavorite')" class=1depth>즐겨찾기</a>
		</td>
	</tr>
 -->
	<% if (loginuser.securityId > 0){%>
	<!--<tr>
		<td width="30" class=img><img src="../common/images/leftmenu_dot_off.gif" border="0"></td>
		<td width="154" class="menu">
			<a href="javascript:gotoURL('mypage')" class=1depth>MyPage</a>
		</td>
	</tr>
	<tr>
	  <td colspan="2"><img src="../common/images/left_endline.gif"></td>
    </tr> -->
	<%}%>
	<tr height="100%">
		<td colspan="2"></td>
	</tr>
</table>
</body>
</html>