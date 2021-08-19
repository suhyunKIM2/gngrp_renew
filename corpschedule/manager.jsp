<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="nek.corpschedule.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*, nek.common.util.Convert" %>
<%@ include file="/common/usersession.jsp"%>
<%
CorpScheduleDao dao = null;								// 회사일정 DAO
ArrayList<UserItem> managerList = new ArrayList<UserItem>();

String cmd = Convert.TextNullCheck(request.getParameter("cmd"));
String newId = Convert.TextNullCheck(request.getParameter("newid"));
String oldId = Convert.TextNullCheck(request.getParameter("oldid"));

dao = new CorpScheduleDao();
try {
	dao.getDBConnection();
	if ("save".equals(cmd)) {
		dao.deleteCorpScheduleManager(oldId);
		dao.insertCorpScheduleManager(newId);
	} else if ("delete".equals(cmd)) {
		dao.deleteCorpScheduleManager(oldId);
	}
	managerList = dao.getCorpScheduleManagerList();
} catch(Exception e) {
	System.out.println("corpschedule/manager.jsp : " + e.getMessage());
} finally { if (dao != null) dao.freeDBConnection(); }
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<title>Insert title here</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<script type="text/javascript">

function htmlForm(obj) {
	var str = "";
	var userid = "";
	var usernm = "";
	
	if (obj.data.length > 0) {
		userid = obj.data[1];
		usernm = obj.data[0] + "/" + obj.data[3];
	}
	
	str = "<form id=\"submitForm\" name=\"submitForm\" method=\"get\" action=\"manager.jsp\">"
		+ "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" style=\"border-collapse:collapse;\">"
		+ "<colgroup>"
		+ "<col width=\"150px\" />"
		+ "<col width=\"*\" />"
		+ "</colgroup>"
		+ "<tr height=\"34\">"
		+ "<td width=250 class=\"td_le1\">대상</td>"
		+ "<td class=\"td_le2\">"
		+ "<input type=\"hidden\" name=\"cmd\" id=\"cmd\" value=\"\" />"
		+ "<input type=\"hidden\" name=\"oldid\" id=\"userid\" value=\""+userid+"\" />"
		+ "<input type=\"hidden\" name=\"newid\" id=\"userid\" value=\""+userid+"\" />"
		+ "<input type=\"text\" name=\"usernm\" id=\"usernm\" value=\""+usernm+"\" onclick=\"getAdminId()\">";

	if (obj.save == 1)
		str +="<a onclick=\"docSubmit('save');\" class=\"button white medium\">"
			+ "<img src=\"../common/images/bb02.gif\" border=\"0\"> <fmt:message key="t.save"/> </a>";
			
	if (obj.del == 1)
		str +="<a onclick=\"docSubmit('delete');\" class=\"button white medium\">"
			+ "<img src=\"../common/images/bb02.gif\" border=\"0\"> <fmt:message key="t.delete"/> </a>";

	if (obj.cancel == 1)
		str +="<a onclick=\"cancelManager();\" class=\"button white medium\">"
			+ "<img src=\"../common/images/bb02.gif\" border=\"0\"> <fmt:message key="t.cancel"/> </a>";
		
	str +="</td>"
		+ "</tr>" 
		+ "</table></form>";
			
		return str;
}

function createManager() {
	$("#managerFormDiv").html(htmlForm({save:1, del:0, cancel:1, data:[]}));
}

function cancelManager() {
	$("#managerFormDiv").html("");
}

function modifyManager(elem) {
	var userdata = $(elem).attr("userdata").split(":");
	$("#managerFormDiv").html(htmlForm({save:1, del:1, cancel:1, data:userdata}));
}

function docSubmit(cmd) {
	var frm = document.getElementById("submitForm");
	frm.cmd.value = cmd;
	frm.submit();
}

//(dhtmlmodal Version)
function getAdminId() {
	var url = "../common/department_selector.htm?onlyuser=1&openmode=1&funnum=10041";
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_COMM1004", "iframe", url, "회사일정관리자", 
		"width=300px,height=350px,resize=0,scrolling=1,center=1", "recal"
	);
}

function setAdminId(returnvalue) {
	var frm = document.getElementById("submitForm");
	if (returnvalue != null  && returnvalue != "") {
		var shareInfo = returnvalue.split(":");
		if (shareInfo.length == 6) {
			frm.newid.value = shareInfo[1];
			frm.usernm.value = shareInfo[0] + "/" + shareInfo[3];
		} else {
			alert("<fmt:message key="c.bbs.return" />"); // 반환값이 올바르지 않습니다
			return;
		}
	}
}
</script>
</head>
<body>

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="60%" style="padding-left:5px; padding-top:5px; ">
			<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
				<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
				<fmt:message key="sch.Calendar" />&nbsp;<!-- 일정관리 > --> 
				<fmt:message key="main.Company.Schedule" />&nbsp;<!-- 회사일정 -->
				&gt; <fmt:message key="t.administrator" />&nbsp;<!-- 관리자 -->
				설정
			</span>
		</td>
		<td width="40%" align="right"></td>
	</tr>
</table>

<table width="90%" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse; margin:10px;">
	<tr>
		<td width="30%" valign=top>
			<table width="100%" cellspacing="0" cellpadding="0" style="padding:2 2 2 4; background-color:#EDF2F5;">
				<tr height="34">
					<td class="td_le1" align="center">
					<a onclick="createManager();" class="button white medium">
					<img src="../common/images/bb02.gif" border="0"> 새 관리자 등록 </a>
					</td>
				</tr>
				<%	for(int i = 0, len = managerList.size(); i < len; i++) {
						UserItem manager = managerList.get(i);
				%>
				<tr>
					<td style="cursor:pointer; height:25px; border:1px solid #dfdfdf; background-color:#fff; line-height: 18px;padding: 0 0 0 7px;" userdata="<%=manager.nName %>:<%=manager.uid %>::<%=manager.dpName %>" onclick="modifyManager(this)">
						<%=manager.dpName %> / <%=manager.nName %> / <%=manager.upName %>
					</td>
				</tr>
				<%	} %>
			</table>
		</td>
		<td width="5"></td>
		<td width="*" valign="top">
			<div id="managerFormDiv"></div>
		</td>
	</tr>
</table>
	
</body>
</fmt:bundle>
</html>