<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ include file="../common/usersession.jsp" %>
<%!
	private MailRepository repository = MailRepository.getInstance();//new MailRepository();
	private RuleManager ruleManager = new RuleManager();

	//각 경로 패스
    String sImagePath =  "../common/images" ; 
    String sJsScriptPath =  "../common/scripts" ;  
    String sCssPath =  "../common/css" ; 
%>
<%
	request.setCharacterEncoding("utf-8");

	String sendAddr = Convert.TextNullCheck(request.getParameter("sendaddr"));
	DBHandler db = new DBHandler();
	Connection con = null;
	//도메인명
    String domainName = application.getInitParameter("nek.mail.domain");
    if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;

	String cmd = request.getParameter("cmd");
	if (cmd != null) {
		if ( cmd.equals("new") )  {
			int priority = Integer.parseInt(request.getParameter("priority"));
			int field = Integer.parseInt(request.getParameter("field"));
				
			/* 0: 포함, 1: 일치 */
			String paramExact = request.getParameter("match");
			boolean match = (paramExact != null && paramExact.equals("1"));

			/* 0: 삭제, 아니면 해당 메일함으로 이동 */
			String paramAction = request.getParameter("action");
			int action = Rule.ACTION_MOVE;
			int target = Mailbox.TRASH;
			if (paramAction != null) {
				//휴지통으로 이동: default:
				if (paramAction.startsWith("0")) {
					action = Rule.ACTION_DELETE;
				} else {
					target = Integer.parseInt(paramAction);
				}
					 
				
				/*else if (paramAction.startsWith("0_")) {
					int index = paramAction.indexOf('_');
					if (index > 0) {
						target = Integer.parseInt(paramAction.substring(index + 1));
					}
				}
				*/
			} 

			String keywords = request.getParameter("keywords");
			if (keywords != null) {
				Rule rule = new Rule(-1, priority, field, keywords, match, action, target);
				try {
					con = db.getDbConnection();

					ruleManager.create(con, loginuser.emailId, rule, domainName);
				} finally {
					if (con != null) { db.freeDbConnection(); }
				}
			}
			
		}

		String createOk = "";
		
		try { createOk = msglang.getString("mail.filter.create.ok"); /* 자동분류에 등록되었습니다. */ } catch(Exception e) {}
		
		if ("".equals(createOk)) createOk = "자동분류에 등록되었습니다.";
		
		out.print("<script>alert('"+createOk+"');window.close();</script>");
		//response.sendRedirect("mail_rules.jsp");
		return;
	}
	
	Mailboxes mailboxes = null;
	try {
		con = db.getDbConnection();
		mailboxes = repository.getCustomMailboxes(con, loginuser.emailId, 1, domainName);	//받은편지함
	} finally {
		if (con != null) { db.freeDbConnection(); }
	}
%>
<html style="margin:0;padding:0;overflow: hidden;">
<head>
<title><%=msglang.getString("mail.autoClassification") /* 자동 분류 */ %></title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">
<%@ include file="/WEB-INF/common/include.jquery.jsp"%>
<%@ include file="/WEB-INF/common/include.common.jsp"%>
<link rel=STYLESHEET type=text/css href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script language="javascript">
<!--

function OnClickCreate() {
	var keywords = document.getElementsByName("keywords")[0].value;
	keywords = TrimAll(keywords);
	if (keywords == "") {
		alert("<%=msglang.getString("mail.filter.words") /* 필터링 할 단어를 입력하세요! */ %>");
		document.fmMailRules.keywords.focus();
		return;
	}
	document.getElementsByName("keywords")[0].value = keywords;
    document.fmMailRules.cmd.value = "new";
	document.fmMailRules.submit();
}

function Onload(){
	document.getElementsByName("keywords")[0].value = '<%=sendAddr %>';
}
//-->
</script>
</head>
<body onload="Onload();">
	<form name="fmMailRules" method="POST" action="mail_rule_popup.jsp" onsubmit="return false;">
		<!-- hidden field -->
		<input type="hidden" name="cmd" value="new">
		<!-- 타이틀 시작 -->
		<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34">
			<tr>
				<td height="27">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
						<tr>
							<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_board.jpg" width="27" height="27"></td>
							<td class="SubTitle"><%=msglang.getString("mail.autoClassification") /* 자동 분류 */ %></td>
							<td valign="bottom" width="*" align="right"></td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td height="3"></td>
			</tr>
			<tr>
				<td height="3">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3">
						<tr>
							<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200"
								height="3"
							></td>
							<td bgcolor="eaeaea"></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<!-- 타이틀 끝 -->
		<table>
			<tr>
				<td class=tblspace03></td>
			</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29"
			background="<%=imagePath %>/titlebar_bg.jpg"
		>
			<tr>
				<td width="5" background="<%=imagePath %>/titlebar_left.jpg"></td>
				<td align="center">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position: relative; top: 1px">
						<colgroup>
							<col width="40">
							<col width="1">
							<col width="170">
							<col width="1">
							<col width="*">
							<col width="1">
							<col width="150">
						</colgroup>
						<tr>
							<td width="40" align="center" class="SubTitleText"><span style="white-space:nowrap;" class="SubTitleText"><%=msglang.getString("t.priority") /* 우선순위 */ %></span></td>
							<td><img src=../common/images/i_li_headline.gif></td>
							<td width="170" align="center" class="SubTitleText"><%=msglang.getString("t.category") /* 분류 */ %></td>
							<td><img src=../common/images/i_li_headline.gif></td>
							<td align="center" class="SubTitleText"><%=msglang.getString("mail.sender") /* 발신인 */ %> <%=msglang.getString("addr.address") /* 주소 */ %></td>
							<td><img src=../common/images/i_li_headline.gif></td>
							<td width="150" align="center" class="SubTitleText"><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></td>
						</tr>
					</table>
				</td>
				<td width="5" background="<%=imagePath %>/titlebar_right.jpg"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5"></td>
				<td>
					<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position: relative; top: 1px;">
						<tr height='25'>
							<td>
								<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tblfix">
									<tr>
										<td width="40"><select name="priority" style="width: 100%">
												<option value="1">1</option>
												<option value="2">2</option>
												<option value="3">3</option>
												<option value="4">4</option>
												<option value="5">5</option>
												<option value="6">6</option>
												<option value="7">7</option>
												<option value="8">8</option>
												<option value="9">9</option>
										</select></td>
										<td width="5">&nbsp;</td>
										<td width="110"><select name="field" style="width: 100%">
												<option value="0"><%=msglang.getString("mail.subject") /* 제목 */ %></option>
												<option value="1"><%=msglang.getString("mail.sender") /* 발신인 */ %>
													<%=msglang.getString("mail.filter.name.addr") /* (이름+주소) */ %></option>
												<option value="2" selected><%=msglang.getString("mail.sender") /* 발신인 */ %>
													<%=msglang.getString("addr.address") /* 주소 */ %></option>
												<option value="3"><%=msglang.getString("mail.sender") /* 발신인 */ %>
													<%=msglang.getString("t.name") /* 이름 */ %></option>
										</select></td>
										<td width="60"><%=msglang.getString("mail.filter.is") /* 에(이/가) */ %></td>
										<td width="*"><input type="text" name="keywords" style="width: 100%"></td>
										<td width="120"><select name="match" style="width: 100%">
												<option value="0"><%=msglang.getString("mail.filter.include") /* 를(을) 포함하면 */ %></option>
												<option value="1" selected><%=msglang.getString("mail.filter.match") /* 와(과) 일치하면 */ %></option>
										</select></td>
										<td width="150"><select name="action" style="width: 100%">
												<option value="0"><%=msglang.getString("t.delete") /* 삭제 */ %></option>
												<option value="<%=Mailbox.TRASH%>"><%=msglang.getString("mail.delete.move.trash") /* 휴지통으로 이동 */ %></option>
												<%
											if (mailboxes != null) {
												Iterator iter = mailboxes.iterator();
												while (iter.hasNext()) {
													Mailbox box = (Mailbox)iter.next();
													out.println("<option value='" + box.getID() + "'>" + HtmlEncoder.encode(box.getName()) + " " + msglang.getString("mail.filter.moving") /* 이동 */ + "</option>");
												}
											}
										%>
										</select></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr valign="top">
							<td height="1" bgcolor="c3c3c3"></td>
						</tr>
					</table>
				</td>
				<td width="5"></td>
			</tr>
		</table>
		<table>
			<tr>
				<td class="tblspace05"></td>
			</tr>
		</table>
		<!---수행버튼 --->
		<table width="100%" cellspacing="0" cellpadding="0" border="0">
			<tr height="25" bgcolor="#E7E7E7" align="center">
				<td>
					<%-- 
          <a href="#"><img src="<%= sImagePath %>/btn_ok.gif" border="0" align="absmiddle" onclick="OnClickCreate();"></a>&nbsp;
          <a href="#"><img src="<%= sImagePath %>/btn_cancel.gif" border="0" align="absmiddle" onclick="window.close();"></a>
         --%>
					<div onclick="OnClickCreate()" class="button gray medium">
						<img src="../common/images/bb02.gif" border="0">
						<%=msglang.getString("t.ok") /* 확인 */ %>
					</div>
					<div onclick="window.close()" class="button white medium">
						<img src="/common/images/bb02.gif" border="0">
						<%=msglang.getString("t.cancel") /* 취소 */ %>
					</div>
				</td>
			</tr>
		</table>
		<!-- 보기 수행버튼 끝 -->
</body>
</html>	