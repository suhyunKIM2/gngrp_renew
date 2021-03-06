<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="nek.common.login.LoginUser"%>
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="../common/usersession.jsp" %>
<%!
	private MailRepository repository = MailRepository.getInstance();
	private POP3Manager pop3Manager = POP3Manager.getInstance();
	private SimpleDateFormat dtformat = new SimpleDateFormat("yyyyMMddHHmmssSSS");
	private POP3Entry dummy = new POP3Entry("", "", 110, "", "", 1, false);
	private boolean overFlag = false;

	private void beginProcess(String uid, String pop3ID) 
	throws SQLException {
		DBHandler db = new DBHandler();
		Connection con = null;
		try {
			con = db.getDbConnection();
			pop3Manager.beginProcess(con, uid, pop3ID);
		} catch(Exception e){
			e.printStackTrace();
		} finally {
			if (con != null) {
				db.freeDbConnection();
			}
		}
	}

	private void endProcess(String uid, String pop3ID) 
	throws SQLException {
		DBHandler db = new DBHandler();
		Connection con = null;
		try {
			con = db.getDbConnection();
			pop3Manager.endProcess(con, uid, pop3ID);
		} catch(Exception e){
			e.printStackTrace();
		} finally {
			if (con != null) {
				db.freeDbConnection();
			}
		}
	}
	
	private int getPOP3MaxCount() 
			throws SQLException {
		DBHandler db = new DBHandler();
		Connection con = null;
		int totalCount = 0;
		try {
			con = db.getDbConnection();
			totalCount = pop3Manager.getMaxProcess(con);
		} catch(Exception e){
			e.printStackTrace();
		} finally {
			if (con != null) {
				db.freeDbConnection();
			}
		}
		return totalCount;
	}
	
	private boolean isPOP3Process(String uid, String pop3ID) 
	throws SQLException {
		DBHandler db = new DBHandler();
		Connection con = null;
		boolean procFlag = false;
		try {
			con = db.getDbConnection();
			procFlag = pop3Manager.isProcess(con, uid, pop3ID);
		} catch(Exception e){
			e.printStackTrace();
		} finally {
			if (con != null) {
				db.freeDbConnection();
			}
		}
		return procFlag;
	}
	
	private void deletePOP3Entry(String uid, String pop3ID) 
	throws SQLException {
		DBHandler db = new DBHandler();
		Connection con = null;
		try {
			con = db.getDbConnection();
			pop3Manager.deleteEntry(con, uid, pop3ID);
		} catch(Exception e){
			System.out.println(e);
		}finally {
			if (con != null) {
				db.freeDbConnection();
			}
		}
	}

	private void createPOP3Entry(String uid, POP3Entry entry) 
	throws SQLException {
		DBHandler db = new DBHandler();
		Connection con = null;
		try {
			con = db.getDbConnection();
			pop3Manager.createEntry(con, uid, entry);
		} catch(Exception e){
			System.out.println(e);
		} finally {
			if (con != null) {
				db.freeDbConnection();
			}
		}
	}
	
	private void updatePOP3Entry(String uid, POP3Entry entry, String pop3ID) 
			throws SQLException {
				DBHandler db = new DBHandler();
				Connection con = null;
				try {
					con = db.getDbConnection();
					pop3Manager.updateEntry(con, uid, entry, pop3ID);
				} catch(Exception e){
					System.out.println(e);
				} finally {
					if (con != null) {
						db.freeDbConnection();
					}
				}
			}

	private int getPOP3TotalCount(String emailID, String uid, String host, int port, 
		String user, String password, String domainName, String pop3ID) 
	throws Exception {
		javax.mail.Store store = null;
		javax.mail.Folder folder = null;

		int totalCount = 0;
		try{
			Properties props = System.getProperties();
			javax.mail.Session mailSession = javax.mail.Session.getDefaultInstance(props);
			store = mailSession.getStore("pop3");
			
			store.connect(host, 110, user, password);
			folder = store.getFolder("INBOX");
			folder.open(javax.mail.Folder.READ_ONLY);

			totalCount = folder.getMessageCount();
		}catch(Exception ex){
			System.out.println(ex);
		} finally {
			if (folder != null && folder.isOpen()) {
				folder.close(true);
			}
			if (store != null && store.isConnected()) {
				store.close();
			}
		}

		return totalCount;
	}
	
	private java.util.Date getPOP3LastInfo(String uid, String host, String domainName, String pop3ID) 
		throws Exception {
			DBHandler db = new DBHandler();
			Connection con = null;

			java.util.Date lastPop3Date = null;
			try {
				con = db.getDbConnection();
				
				//pop3??????????????? ????????? ??????
				lastPop3Date = repository.getPOP3ReadDate(con, uid, pop3ID, host, domainName);

			}catch(Exception ex){
				System.out.println(ex);
			} finally {
				if (db != null) try {db.freeDbConnection(); } catch (Exception ex) {}
			}

			return lastPop3Date;
		}
	
	
	private void importPOP3(String emailID, String uid, String host, int port, 
			String user, String password, int start, int mailbox, boolean del_original, String domainName, long mailQuota, String pop3ID, int totalCount, java.util.Date lastPop3Date) 
		throws Exception {
			
			boolean isOver = false;

			javax.mail.Store store = null;
			javax.mail.Folder folder = null;
			int iEnd = start+9;		//10??? ????????? ????????????.
			
			if((iEnd-1) >= totalCount){		//?????????????????? ???????????? ????????? ?????????????????? ????????????
				isOver =true;
				iEnd = totalCount;
			}
// 			System.out.println("start : " + start +  " = " + "end : " + iEnd);
			try {
				Properties props = System.getProperties();
				javax.mail.Session mailSession = javax.mail.Session.getDefaultInstance(props);
				store = mailSession.getStore("pop3");
				
				store.connect(host, 110, user, password);
				folder = store.getFolder("INBOX");
				folder.open(javax.mail.Folder.READ_WRITE);

				Message[] msgs = folder.getMessages(start, iEnd);

				String messageName = new StringBuffer()
						.append("Mail")
						.append(uid)
						.append(host)
						.append(System.currentTimeMillis())
						.toString();
					
				//pop3??????????????? ????????? ??????
				java.util.Date oldDate = null;
				for (int i = 0; i < msgs.length; i++) {
					MimeMessage msg = (MimeMessage)msgs[i];
					
					if (msg == null)
					{
						break;
					}
					java.util.Date created = msg.getReceivedDate();
					if(lastPop3Date!=null){
						long lastDate = lastPop3Date.getTime();
						long createDate = 0;
						if(created != null) createDate = created.getTime();
						
						if(createDate<=lastDate){
							continue;
						}
					}
					
					if (created == null) {
						created = msg.getSentDate();
					}
					if (created != null) oldDate = created;
					/*
					if (created == null) {
						created = new java.util.Date();
					}
					*/
					
					MailEnvelope envelope = new MailEnvelope(msg, (created != null) ? created : (oldDate==null)? new java.util.Date() : oldDate );
					envelope.setRead(true);
					envelope.setMessageName(
						new StringBuffer()
							.append(messageName)
							.append("-")
							.append(i)
							.toString());
					
					int errNum = 0;
						
					DBHandler db = new DBHandler();
					Connection con = null;
					try{
						con = db.getDbConnection();
						long mailTotalSize = (long)repository.getRepositoryTotalSize(con, emailID, domainName);
						if(mailQuota < mailTotalSize){
							System.out.println(emailID + "??????????????? ?????????????????????.");
							overFlag = true;
							break;
						}
						
						repository.pop3Store(con, emailID, mailbox, envelope, "", domainName);
						
						if(created != null){
							repository.updatePOP3ReadDate(con, uid, pop3ID, host, domainName, created);
						}
					}catch(Exception ex){
						System.out.println(user+" "+host+" : " + msg.getSubject() + " : " +ex);
						errNum = 1;
					}finally{
						if (db != null) try {db.freeDbConnection(); } catch (Exception ex) {}
					}
					
					if (del_original) {
						totalCount--;
						msg.setFlag(Flags.Flag.DELETED, true); 
					}
				}

			}catch(Exception ex){
				System.out.println(ex);
			} finally {
				if (folder != null && folder.isOpen()) {
					folder.close(true);
				}
				if (store != null && store.isConnected()) {
					store.close();
				}
			}

			if(!isOver&&!overFlag){	//????????? ??????????????? ?????????????????????????????? ??????
				importPOP3(emailID, uid,
						host, port, user, password, iEnd+1, mailbox, del_original, domainName, mailQuota, pop3ID, totalCount, lastPop3Date);
			}
			
		}
%>
<%
	request.setCharacterEncoding("utf-8");

	String host		= "";
	int port		= 110;
	String user		= "";
	String password	= "";
	int start		= 1;
	int count		= 1;
	int mailboxID	= Mailbox.INBOX;
	boolean del_original = false;
	String result	= msglang.getString("t.no.data");		//????????????

	if(loginuser.locale.equals("en")){result = "No Infomation";}
	
	String cmd = request.getParameter("cmd");
	String domainName = application.getInitParameter("nek.mail.domain");
	if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
	long mailQuota = uservariable.mailBoxSize;	//???????????? ????????? ??????

	if (cmd != null) {

		if (cmd.equals("delete")) {
			String pop3ID = request.getParameter("pop3id");
			if (pop3ID != null) {
				deletePOP3Entry(loginuser.uid, pop3ID);
			}
			response.sendRedirect("mail_pop3support.jsp");
			return;

		} else if (cmd.equals("new")) {
			host		= request.getParameter("host");
			port		= Integer.parseInt(request.getParameter("port"));
			user		= request.getParameter("user");
			password	= request.getParameter("password");
			mailboxID	= Integer.parseInt(request.getParameter("mailbox"));
			del_original = request.getParameter("del_original") != null;
			
			String pop3ID = request.getParameter("pop3id");
			if (StringUtils.isNotBlank(pop3ID)) {
				updatePOP3Entry(loginuser.uid, 
					new POP3Entry(dtformat.format(new java.util.Date()), host, port, user,  password,  mailboxID, del_original), pop3ID);
			}else{
				if (StringUtils.isNotBlank(host) && StringUtils.isNotBlank(user)) {
					createPOP3Entry(loginuser.uid, 
						new POP3Entry(dtformat.format(new java.util.Date()), host, port, user,  password,  mailboxID, del_original));
				}
			}
			
			response.sendRedirect("mail_pop3support.jsp");
			return;

		} else if (cmd.equals("import")) {
			String pop3ID = request.getParameter("pop3id");
			host		= request.getParameter("host");
			port		= Integer.parseInt(request.getParameter("port"));
			user		= request.getParameter("user");
			password	= request.getParameter("password");
// 			start		= Integer.parseInt(request.getParameter("start"));
// 			count		= Integer.parseInt(request.getParameter("count"));
			mailboxID	= Integer.parseInt(request.getParameter("mailbox"));
			del_original = request.getParameter("del_original") != null;

			boolean isProcess = isPOP3Process(loginuser.uid, pop3ID);
			int iMaxPop3 = getPOP3MaxCount();	//?????? ???????????? POP3 ???????????? ??? ??????
			if(iMaxPop3>10){	//???????????? ?????? 1GB????????? 10??? 
				result = "<div style='color:blue'>?????? ???????????? ??????????????? ????????????.\n????????? ?????? ?????????????????????.</div>";
			}else if (!isProcess) {
				int totalCount = 0;
				try {
					beginProcess(loginuser.uid, pop3ID);
					
					//POP3 ??? ??????
					int pop3Count =getPOP3TotalCount(loginuser.emailId, loginuser.uid, host, port, user, password, domainName, pop3ID);
					
					//POP3 ????????? ????????? ??????
					java.util.Date lastPop3Date = getPOP3LastInfo(loginuser.uid, host, domainName, pop3ID);
					
					if (pop3Count > 0) {
						importPOP3(loginuser.emailId, loginuser.uid,
								host, port, user, password, 1, mailboxID, del_original, domainName, mailQuota, pop3ID, pop3Count, lastPop3Date);
					}
					
				} catch (Exception ex) {
				result = new StringBuffer()
					.append("<div style='color:red'>")
					.append(ex.getMessage())
					.append("</div>")
					.toString();
					totalCount = -1;
				} finally {
					endProcess(loginuser.uid, pop3ID); 
				}
	
				if (totalCount >= 0) {
				result = new StringBuffer()
					.append("<div style='color:blue'>[")
					.append(host)
					.append("]??? ")
					.append(totalCount)
					.append("?????? ????????? ????????????.</div>")
					.toString();
				}
			} else {
				result = "<div style='color:blue'>["+host+"] ??????????????? ?????? ????????? ?????????.</div>";
			}
		}
	}

	Collection entries = null;
	Mailboxes mailboxes = null;
	DBHandler db = new DBHandler();
	Connection con = null;
	
	try {
		con = db.getDbConnection();
		entries = pop3Manager.getEntries(con, loginuser.uid);
		mailboxes = repository.getCustomMailboxes(con, loginuser.emailId, domainName);
	} finally {
		if (con != null) {
			db.freeDbConnection();
		}
	}
%>

<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<title><fmt:message key="mail.import.pop3"/>&nbsp;<!-- ????????????(POP3)???????????? --></title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">

<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>

<style type="text/css">
.br_tit_v {font-size:9pt; color:#cc6600;}
a.br_tit_v:link {font-size:9pt; color:#cc6600; text-decoration:none;}
a.br_tit_v:visited {font-size:9pt; color:#cc6600; text-decoration:none;}
a.br_tit_v:hover {font-size:9pt; color:#cc6600; text-decoration:underline;}

.e_tr { height: 24px; }z
</style>
<!-- <script src="../common/scripts/common.js"></script> -->
<script language="javascript">
<!--
function OnClickDelete(server, pop3ID) {
	if (confirm("'" + server + "'<fmt:message key='c.delete'/>")) {//?????? ???????????????????
		document.fmPOP3.cmd.value = "delete";
		document.fmPOP3.pop3id.value = pop3ID;
		document.fmPOP3.submit();
	}
}

function OnClickCreate() {
	if (TrimAll(fmPOP3.host.value) == "") {
		alert("<fmt:message key='mail.c.enter.serverName'/>");//?????? POP3 ???????????? ???????????????!
		fmPOP3.host.focus();
		return;
	}

	var strPort = TrimAll(fmPOP3.port.value);
	if (strPort == "") {
		alert("<fmt:message key='mail.c.enter.serverport'/>");//?????? POP3 ?????? ??????????????? ???????????????!
		fmPOP3.port.focus();
		return;
	}

	if (isNaN(parseInt(fmPOP3.port.value))) {
		alert("'" + strPort + "'<fmt:message key='mail.c.stratNumber.wrong'/>");//???(???) ????????? ?????????????????????!
		fmPOP3.port.focus();
		return;
	}

	if (TrimAll(fmPOP3.user.value) == "") {
		alert("<fmt:message key='mail.c.enter.userid'/>");//?????? POP3 ????????? ID??? ???????????????!
		fmPOP3.user.focus();
		return;
	}	

	fmPOP3.cmd.value = "new";
	fmPOP3.submit();
}

function OnClickImport(pop3Id, strHost, strPort, strUser, strPass, mailboxid, delflag) {
	var flag = isProcess(pop3Id);
    if (flag == "false") {
		fmPOP3.pop3id.value = pop3Id;
		fmPOP3.host.value = strHost;
		fmPOP3.port.value = strPort;
		fmPOP3.user.value = strUser;
		fmPOP3.password.value=strPass;
		fmPOP3.mailbox.value = mailboxid;
		if(delflag){
			fmPOP3.del_original.checked = true;
		}else{
			fmPOP3.del_original.checked = false;
		}
		if (fmPOP3.del_original.checked) {
			if (!confirm("<fmt:message key='mail.c.delete.original'/>")) {//?????? ????????? ????????? ??? ?????? ????????? ???????????????. ?????? ???????????????????
				return;
			}
		} else {
			if (!confirm("<fmt:message key='mail.c.exe.import'/>")) {//?????? POP3 ?????? ??????????????? ?????? ?????????????????????????
				return;
			}
		}
		
		//?????? ?????????
// 		var pgObj = document.getElementById("myid");
// 	 	pgObj.style.display = "";
		
		fmPOP3.cmd.value = "import";
		fmPOP3.submit();
    } else if (flag == "true") {
        alert("?????? ??????????????? ??????????????????.");
    }
}

function OnClickSelect(pop3Id, strHost, strPort, strUser, strPass, mailboxid, delflag) {
	fmPOP3.pop3id.value = pop3Id;
	fmPOP3.host.value = strHost;
	fmPOP3.port.value = strPort;
	fmPOP3.user.value = strUser;
	fmPOP3.password.value=strPass;
	
	fmPOP3.mailbox.value = mailboxid;
	if(delflag){
		fmPOP3.del_original.checked = true;
	}else{
		fmPOP3.del_original.checked = false;
	}
}

function CheckKeyCode() {
	// ?????? ???????????? ??????[0~9]???, BackSpace??? ??????????????? ?????????.
	//alert( event.keyCode );
	if ( !( /* dot */ event.keyCode == 46 || event.keyCode == 8 || event.keyCode ==13 || (event.keyCode >= 48 && event.keyCode <= 57) ) ) {
			return false;
	}
}

function isProcess(pop3Id) {
    var result = "";
	$.ajax({
		url : '/mail/mail_pop3process.jsp',
		async : false,
		type : 'post',
		datatype: 'text',
		data : { "pop3ID" : pop3Id },
		beforeSend : function() {},
		complete : function() {},
		success : function(data) {
		    result = $.trim(data);
		}
	});
	return result;
}

function onload(){
	if($("#resultTxt").text()=="????????????"){
	}else{
		alert($("#resultTxt").text());
	}
}
//-->
</script>
</head>
<body onLoad="onload();">

<style>
body {margin:0px; overflow-y:hidden; }
</style>

<form name="fmPOP3" method="POST" action="mail_pop3support.jsp" onsubmit="return false;">
<!-- hidden field -->
<input type="hidden" name="cmd" value="<%=(cmd == null) ? "" : cmd%>">
<input type="hidden" name="pop3id" value="">

<!-- ?????? ????????? -->
<%-- <jsp:include page="/common/progress.jsp" flush="true"> --%>
<%--     <jsp:param name="ctype" value="2"/> --%>
<%-- </jsp:include> --%>

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="mail.option"/>&nbsp;&gt;&nbsp;<fmt:message key="mail.import.pop3"/></span>
</td>
<td width="40%" align="right">
<!-- n ?????? ???????????? ????????? ????????????. -->
</td>
</tr>
</table>
<!-- List Title -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="8"><td></td></tr></table>
<div style="width:90%;margin:auto;">	
<div id="viewList" class="div-view" onpropertychange="div_resize();">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
	<tr> 
		<td height="30" valign="top"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29" background="<%=imagePath %>/titlebar_bg.jpg">
				<tr> 
					<!--<td width="5" background="<%=imagePath %>/titlebar_left.jpg"></td>-->
					<td align="center" style="    background: #eee;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
							<colgroup>
								<col width="*">
								<col width="1">
								<col width="200">
								<col width="1">
								<col width="100">
								<col width="1">
								<col width="100">
								<col width="1">
								<col width="100">
							</colgroup>
							<tr>
								<td align="center" class="SubTitleText"><fmt:message key="mail.pop3.server.address"/>&nbsp;<!-- POP3???????????? --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText">POP3 ID</td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="t.choice"/>&nbsp;<!-- ?????? --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="t.delete"/>&nbsp;<!-- ?????? --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText">????????????</td>
							</tr>
						</table>
					</td>
					<!--<td width="5" background="<%=imagePath %>/titlebar_right.jpg"></td>-->
				</tr>
			</table>
		</td>
	</tr>
	<tr> 
		<td> 
			<!-- ?????? DATA ?????? -->
			<%
				if (entries != null && !entries.isEmpty()) {
					Iterator piter = entries.iterator();
					boolean alternating = true;
					while (piter.hasNext()) {
						POP3Entry entry = (POP3Entry)piter.next();
						alternating = !alternating;
			%>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr> 
					<td width="5"></td>
					<td> 
						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
							<tr> 
								<td height='25' <%=(alternating ? "bgcolor='#f5f5f5'" : StringUtil.EMPTY)%>>
									<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tblfix">
										<colgroup>
											<col width="*">
											<col width="1">
											<col width="200">
											<col width="1">
											<col width="100">
											<col width="1">
											<col width="100">
											<col width="1">
											<col width="100">
										</colgroup>
										<tr> 
											<td align="center" class="SubText"><%=entry.getServer()%></td>
											<td align="center"></td>
											<td align="center" class="SubText"><%=entry.getUserID()%></td>
											<td align="center"></td>
											<td align="center" class="SubText"><a href="javascript:OnClickSelect('<%=entry.getEntryID()%>' ,'<%=entry.getHost()%>', '<%=entry.getPort()%>', '<%=entry.getUserID()%>' , '<%=entry.getPassword() %>', '<%=entry.getMailboxID() %>', <%=entry.getDeleteOriginal() %>) " class="br_tit_v">[??????]</a></td>
											<td align="center"></td>
											<td align="center" class="SubText"><a href="javascript:OnClickDelete('<%=entry.getServer()%>', '<%=entry.getEntryID()%>')" class="br_tit_v">[??????]</a></td>
											<td align="center"></td>
											<td align="center" class="SubText"><a href="javascript:OnClickImport('<%=entry.getEntryID()%>' ,'<%=entry.getHost()%>', '<%=entry.getPort()%>', '<%=entry.getUserID()%>' , '<%=entry.getPassword() %>', '<%=entry.getMailboxID() %>', <%=entry.getDeleteOriginal() %>)" class="br_tit_v">[??????]</a></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr> 
								<td height="1" bgcolor="c3c3c3"></td>
							</tr>
						</table>
					</td>
					<td width="5"></td>
				</tr>
			</table>
			<%
				    }
			    } else {
			    	String NODoc_autodelete = msglang.getString("v.not.pop.list"); 		//????????? ?????? POP3 ????????? ????????????.
			    	if(loginuser.locale.equals("en")){NODoc_autodelete = "Created external POP3 does not have a list!";}
					out.println("<table width='100%' style='height:expression(document.body.clientHeight-420);' border='0' cellspacing='0' cellpadding='0'><tr>"
							+ "<td width='5'></td><td>"+StringUtil.getNODocExistMsg(NODoc_autodelete)
							+ "</td><td width='5'></td></tr></table>"); 
				}
			%>
	<!-- ?????? DATA ???-->
		</td>
	</tr>
	<tr> 
		<td height="15"></td>
	</tr>
</table>
<table><tr><td class="tblspace03"></td></tr></table>
<!-- ????????? / ?????? -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed">
	<tr>
		<td width=11><img src="../common/images/comment_le_top.gif"></td>
		<td width="*" height=10 background="../common/images/comment_top_bg.gif"></td>
		<td width=11><img src="../common/images/comment_ri_top.gif"></td>
	</tr>
	<tr>
		<td width=11 background="../common/images/comment_le_bg.gif"></td>
		<td width="*">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr class="e_tr">
					<td width="120">&nbsp;<fmt:message key="mail.pop3.server"/>&nbsp;<!-- POP3 ?????? --> <font color="red"><b>*</b></font></td>
					<td width="150">
						<input type="text" name="host" style="width:150px" value="<%=host%>"> 
					</td>									
					<td width="120">&nbsp;<fmt:message key="mail.font"/>&nbsp;<!-- ?????? --> <font color="red"><b>*</b></font></td>
					<td width="150">
						<input type="text" name="port" style="width:50px" value="<%=port%>"> 
					</td>		
					<td width="*" align="center" rowspan="5">
						<a href="javascript:OnClickCreate();">
<%-- 							[<fmt:message key="mail.server.save"/>&nbsp;<!-- ?????? ?????? -->] --%>
							[?????? ??????]
						</a><br>
						<a href="mail_pop3support.jsp">
							[Reset]
						</a>
					</td>
				</tr>
				<tr class="e_tr">
					<td>&nbsp;POP3 ID <font color="red"><b>*</b></font></td>
					<td>
						<input type="text" name="user" style="width:150px" value="<%=user%>"> 
					</td>									
					<td>&nbsp;<fmt:message key="mail.password"/>&nbsp;<!-- ???????????? --> <font color="red"><b>*</b></font></td>
					<td>
						<input type="password" name="password" style="width:150px" value="<%=password%>"> 
					</td>		
				</tr>
				<tr class="e_tr">
					<td>&nbsp;<fmt:message key="mail.mailbox.store"/>&nbsp;<!-- ????????? ????????? --> <font color="red"><b>*</b></font></td>
					<td>
						<select name="mailbox" style="width: 150px">
							<option value="<%=Mailbox.INBOX%>" <%=(mailboxID == Mailbox.INBOX) ? "selected" : ""%>><fmt:message key="mail.InBox"/>&nbsp;<!-- ??????????????? --></option>
						<%
							Iterator mailbox_iter = mailboxes.iterator();
							while (mailbox_iter.hasNext()) {
								Mailbox mailbox = (Mailbox)mailbox_iter.next();
								if(mailbox.getMainBoxId()==2) continue;
								//if (mailboxID != mailbox.getID()) {
									out.println("<option value='" + mailbox.getID() + "'" + (mailboxID == mailbox.getID() ? " selected " : "") + ">" 
										+ mailbox.getName()+ "</option>");
								//}
							}
						%>
						</select>
					</td>			
					<td colspan="2"><input type="checkbox" name="del_original"><fmt:message key="mail.delete.import"/>&nbsp;<!-- ????????? ?????? ?????? ?????? --></td>
				</tr>
			</table>
		</td>
		<td width=11 background=../common/images/comment_ri_bg.gif></td>
	</tr>
	<tr>
		<td><img src=../common/images/comment_le_down.gif></td>
		<td width="*" height=10 background=../common/images/comment_down_bg.gif></td>
		<td><img src=../common/images/comment_ri_down.gif></td>
	</tr>
</table>	
<table><tr><td class="tblspace03"></td></tr></table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>* <fmt:message key="mail.default.port"/>&nbsp;<!-- POP3 ????????? ?????? ????????? 110???????????? --></td>
	</tr>
	<tr class="e_tr">
		<td><div id="resultTxt" style="display:none;"><%=result%></div></td>
	</tr>
<!-- 	<tr> -->
<%-- 		<td>* <fmt:message key="mailil.number.date.maybe.not"/>&nbsp;<!-- POP3 ????????? ?????? ????????? ?????? ???????????? ???????????? ????????????.(???????????? ??????) --></td> --%>
<!-- 	</tr> -->
</table>
<!-- ????????? / ?????? ??? -->
</div>	
</div>
</form>
<script language="javascript">
	SetHelpIndex("mail_pop3support");
</script>
</body>
</fmt:bundle>
</html>	