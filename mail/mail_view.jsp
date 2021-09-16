<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.io.*" %>
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
<%!
	private MailRepository repository = MailRepository.getInstance();
%>
<%@ include file="../common/usersession.jsp" %>
<%
	//System.setProperty("mail.mime.decodetext.strict", "false");
	request.setCharacterEncoding("utf-8");

	String message_name = request.getParameter("message_name");
	String sCmd = request.getParameter("scmd");
	if(sCmd == null) sCmd = "";
	if (message_name == null) {
		response.sendRedirect("mail_list.jsp");
		return;
	}

	ParameterParser pp = new ParameterParser(request);

	//parameters -------------------------------------------------------------
	boolean isFront		= request.getParameter("front") != null;
	int importance		 = pp.getIntParameter("importance", 0);
	String searchType	= request.getParameter("searchtype");
	String searchText	= pp.getStringParameter("searchtext", "");
	int mailboxID		= pp.getIntParameter("box", Mailbox.INBOX);
	int pageNo			= pp.getIntParameter("pg", 1);

	//DB에서 문서 읽어오기
	DBHandler db = new DBHandler();
	Connection con = null;
	MailEnvelope envelope = null;
	Mailboxes mailboxes_rec = null;
	Mailboxes mailboxes_send = null;
	int mainBoxID = 0;	//메일함 최상위 ID
	
	ConfigItem cfItem = null;
	String homePath = null;
	ArrayList plist = null;
	ArrayList nlist = null;

    String domainName = "";
	try {
		con = db.getDbConnection();
		domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
		
		envelope = repository.retrieve(con, loginuser.emailId, message_name, domainName);
		if (envelope != null) {
			mailboxID = envelope.getMailboxID();
		}
		mailboxes_rec = repository.getCustomMailboxes(con, loginuser.emailId, 1, domainName);	//받은편지함
		mailboxes_send = repository.getCustomMailboxes(con, loginuser.emailId, 2, domainName);	//보낸편지함
		plist = repository.getPrevList(con, loginuser.emailId, mailboxID, message_name, domainName);
		nlist = repository.getNextList(con, loginuser.emailId, mailboxID, message_name, domainName);

		cfItem = ConfigTool.getConfigValue(con, application.getInitParameter("CONF.HOME_PATH"));
		homePath = cfItem.cfValue;
		//if (!homePath.endsWith(File.separator)) homePath += File.separator;

		mainBoxID = repository.getSendBoxCheck(con, mailboxID, domainName);
		
		if (!envelope.isRead()) {
			String[] message_names = new String[1];
			message_names[0] = message_name;

			//보낸편지함 제외
			if (mainBoxID != Mailbox.OUTBOX) {
				repository.markRead(con, loginuser.emailId, message_names, true, domainName);
			}
		}
        
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}

	MimeMessage msg = envelope.getMessage();
	Address[] froms = msg.getFrom();
	Address[] tos = msg.getRecipients(Message.RecipientType.TO);
	Address[] ccs = msg.getRecipients(Message.RecipientType.CC);

	String selBoxes = "";
%>
<%@page import="sun.misc.BASE64Decoder"%>
<html>
<head>
<link rel="STYLESHEET" type="text/css" href="<%= cssPath %>/view.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script src="<%=scriptPath %>/webprint.js"></script>
<script language="javascript">
function OnClickDelete() {
	if (confirm("삭제하시겠습니까?")) {
		fmMail.method = "post";
		fmMail.ctype.value = "2";
		fmMail.action = "mail_delete.jsp";
		fmMail.submit();
	}
}

function OnClickMarkUnread() {
	fmMail.action = "mail_markunread.jsp";
	fmMail.method = "post";
	fmMail.submit();
}

function OnClickImportance() {
	fmMail.action = "mail_markimportance.jsp";
	fmMail.method = "post";
	fmMail.submit();
}

function OnClickList() {
	fmMail.method = "get";
	fmMail.action = "mail_list.jsp";
	fmMail.submit();
}

function OnClickForm(cmd) {
	fmMail.method = "get";
	fmMail.action = "mail_form.jsp";
	fmMail.cmd.value = cmd;
	fmMail.submit();
}

function OnClickMove() {
	var targetMailbox = fmMail.target.value;
	if (targetMailbox == "title" || targetMailbox == "division") {
		alert("이동할 편지함을 선택하세요!");
		return;
	}

	fmMail.action = "mail_move.jsp";
	fmMail.submit();
}

function OnClickSetSpam() {
}

function OnToggleShowRecipients() {
	var objElem = document.getElementById("recipient_btn");
	if (to_container.style.display == "none") {
		to_container.style.display = "";
		cc_container.style.display = "";
		bcc_container.style.display = "";
		objElem.innerHTML = "<img src='../common/images/icon_collapse.gif' border='0' align='absmiddle'>&nbsp;수신인 숨기기";
	} else {
		to_container.style.display = "none";
		cc_container.style.display = "none";
		bcc_container.style.display = "none";
		objElem.innerHTML = "<img src='../common/images/icon_expand.gif' border='0' align='absmiddle'>&nbsp;수신인 보기";
	}
}

function goReflash(){
/*
	var tmp = document.location.href;
	if(tmp.indexOf("scmd=")>-1){
		if(tmp.indexOf("scmd=NEKIM")>-1){
			for(var i=0;i<document.links.length;i++){
				document.links[i].style.color = "000000";
				document.links[i].style.textDecoration = "none";
				document.links[i].style.cursor = "default";
				document.links[i].hideFocus = true;
				document.links[i].href = "#";
			}
		}
	}
	*/
	<%if(mailboxID==Mailbox.INBOX){%>
	try {
		//opener.parent.left.location.reload();
		//var if_left = opener.parent.document.getElementById("if_left");
		//if (if_left) if_left.src = if_left.src;
		opener.parent.showMailMenu();
	}
	catch(err) {
	}
	<%}%>
}

function goAddress(name, email){
	var sUrl = "./mail_select_addressbook.jsp";
	var returnval = window.showModalDialog(sUrl, "", "dialogHeight: 200px; dialogWidth: 250px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");

	if (returnval != null) {
		if(returnval =="private"){
			document.location.href = "../addressbook/addressbook_p_form.jsp?name=" +encodeURI(name) +"&email=" + encodeURI(email);
		}else if(returnval =="public"){
			document.location.href = "../addressbook/addressbook_s_form.jsp?name=" +encodeURI(name) +"&email=" + encodeURI(email);
		}
	}
}

function windowClose(){
	top.window.opener = top;
	top.window.open('','_parent', '');
	top.window.close();
}

function goMailRule(){
	<%
	String sendAddr = "";
	if (froms != null) {
		InternetAddress from = (InternetAddress)froms[0];
		sendAddr = from.getAddress();
	}
	%>
	var url = "./mail_rule_popup.jsp?sendaddr=<%=sendAddr%>";
	OpenWindow( url, "", "450" , "160" );
}

</script>
</head>
<body onload="goReflash();" style="background-image:''">
<form name="fmMail" method="post" action="mail_delete.jsp" onsubmit="return false;">
	<!-- hidden field -->
	<input type="hidden" name="cmd" value="">
	<input type="hidden" name="box" value="<%=mailboxID%>">
	<input type="hidden" name="pg" value="<%=pageNo%>">
	<input type="hidden" name="searchtext" value="<%=searchText%>">
	<input type="hidden" name="searchtype" value="<%=searchType%>">
	<input type="hidden" name="message_name" value="<%=message_name%>">
	<input type="hidden" name="mailid" value="<%=message_name%>">
	<input type="hidden" name="ctype" value="">
	<input type="hidden" name="subject" value="">
	<input type="hidden" name="body" value="">
	
			<table width="100%" cellspacing="0" cellpadding="0" border="0" id=btntbl>
				<tr>
					<%if(!sCmd.equals("NEKIM")){ %>
					<td>
						<a id="recipient_btn" href="javascript:OnToggleShowRecipients();">
							<img src="../common/images/icon_expand.gif" border=0 align=absmiddle>&nbsp;수신인 보이기
						</a>
					</td>
					<%} %>
				</tr>
			</table>
			<table><tr><td class=tblspace03></td></tr>
			
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tr>
					<td width="15%" class="td_le1" nowrap>발 신</td>
					<td width="*" class="td_le2" nowrap>
					<%
						if (froms != null) {
							InternetAddress from = (InternetAddress)froms[0];
							//발신자에 quoted-printable 인코딩인지 확인
							String tmpStr = "";
							String enType = "";
							String fromName= "";
							int count = 0;
							if(from.getPersonal() !=null){
								StringTokenizer st = new StringTokenizer(from.getPersonal(), "?");
								while(st.hasMoreTokens()){
									String tmp = st.nextToken();
									if(count==2){	//인코딩 타입 Q : quoted-printable / B : Base64
										enType = tmp;
									}else if(count==3){
										tmpStr = tmp;
									}
									count++;
								}
								if(enType.equals("Q")){
									org.apache.commons.codec.net.QuotedPrintableCodec qp = new org.apache.commons.codec.net.QuotedPrintableCodec();
									fromName = qp.decode(tmpStr);
									out.print(fromName + " " + from.getAddress());
								}else{
									fromName = from.getPersonal();
									out.print(HtmlEncoder.encode(from.toUnicodeString()));
								}
							}else{
								fromName = from.getPersonal();
								out.print(HtmlEncoder.encode(from.toUnicodeString()));
							}
							/*
							out.print("&nbsp;<a href='../addressbook/addressbook_p_form.jsp?name=");
							String personal = from.getPersonal();
							if (personal != null) {
								out.print(java.net.URLEncoder.encode(personal, "utf-8"));
							}
							out.print("&email=");
							out.print(java.net.URLEncoder.encode(from.getAddress(), "utf-8"));
							*/
							out.print("&nbsp;&nbsp;&nbsp;&nbsp;");
						}
						java.util.Date received = msg.getReceivedDate();
						if (received == null) {
							received = msg.getSentDate();
						}
						if (received != null) {
							out.println(DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG)
												  .format(received));
						}

					%>
					<!--
					&nbsp;&nbsp;<a href="javascript:alert('데모버젼에서는 현 기능을 사용할 수가 없습니다.');" target="_self"><image src="/images/etc_infor_character.gif" border=0>&nbsp;주소록에 추가</a> -->
					</td>
				</tr>
				<tr id="to_container" style="display:none;">
					<td class="td_le1" nowrap>수 신</td>
					<td class="td_le2" nowrap>
						<div style="line-height:1.5em">
					<%
						if (tos != null) {
							for (int i = 0; i < tos.length; i++) {
								InternetAddress to = (InternetAddress)tos[i];
								out.print(HtmlEncoder.encode(to.toUnicodeString()));
								/*
								out.print("&nbsp;<a href='../addressbook/addressbook_p_form.jsp?name=");
								String personal = to.getPersonal();
								if (personal != null) {
									out.print(java.net.URLEncoder.encode(personal, "utf-8"));
								}
								out.print("&email=");
								out.print(java.net.URLEncoder.encode(to.getAddress(), "utf-8"));
								*/
								out.print("<br>");
							}
						}
					%>
						</div>
					</td>
				</tr>
				<tr id="cc_container" style="display:none;">
					<td class=td_le1 nowrap>참 조</td>
					<td class=td_le2 nowrap>
						<div style="line-height:1.5em">
					<%
						if (ccs != null) {
							for (int i = 0; i < ccs.length; i++) {
								InternetAddress cc = (InternetAddress)ccs[i];
								out.print(HtmlEncoder.encode(cc.toUnicodeString()));
								/*
								out.print("&nbsp;<a href='../addressbook/addressbook_p_form.jsp?name=");
								String personal = cc.getPersonal();
								if (personal != null) {
									out.print(java.net.URLEncoder.encode(personal, "utf-8"));
								}
								out.print("&email=");
								out.print(java.net.URLEncoder.encode(cc.getAddress(), "utf-8"));
								*/
								out.print("<br>");
							}
						}
					%>					
						</div>
					</td>
				</tr>
				<tr id="bcc_container" style="display:none;">
					<td class=td_le1 nowrap>비밀참조</td>
					<td class=td_le2 nowrap>
						<div style="line-height:1.5em">
					<%
						Address[] bccs = msg.getRecipients(Message.RecipientType.BCC);
						if (bccs != null) {
							for (int i = 0; i < bccs.length; i++) {
								InternetAddress bcc = (InternetAddress)bccs[i];
								out.print(HtmlEncoder.encode(bcc.toUnicodeString()));
								/*
								out.print("&nbsp;<a href='../addressbook/addressbook_p_form.jsp?name=");
								String personal = bcc.getPersonal();
								if (personal != null) {
									out.print(java.net.URLEncoder.encode(personal, "utf-8"));
								}
								out.print("&email=");
								out.print(java.net.URLEncoder.encode(bcc.getAddress(), "utf-8"));
								*/
								out.print("<br>");
							}
						}
					%>					
						</div>
					</td>
				</tr>
				<tr>
					<td class="td_le1">제 목</td>
					<td class="td_le2"><div style="word-break:break-all"><%=HtmlEncoder.encode(msg.getSubject())%></div></td>
				</tr>
			</table>
			
			<table><tr><td class=tblspace09></td></tr></table>
			
			<table width="100%" height="180" style="table-layout:fixed;" border="0" cellspacing="1" cellpadding="0" bgcolor="90B9CB">
				<tr>
					<td class="content" bgcolor="ffffff" valign="top" width="100%">
					<% 
						Collection attachments = envelope.getAttachments();
						String htmlBody = envelope.getHtmlBody();
						if (htmlBody != null) {
							//process inlined images
							if (attachments != null && attachments.size() > 0) {

								Iterator iter = attachments.iterator();
								while (iter.hasNext()) {
									Attachment attachment = (Attachment)iter.next();
									String cid = attachment.getContentID();
									
									if (cid != null) {	
										// TODO 정규표현을 이용하는 방안을 함 생각해보자 
										int start = htmlBody.indexOf("cid:" + cid);
										if (start == -1) {
											start = htmlBody.indexOf("CID:" + cid);
										}
										if (start != -1) {
											htmlBody = new StringBuffer()
												.append(htmlBody.substring(0, start))
												.append("mail_dn_attachment.jsp?message_name=")
												.append(message_name)
												.append("&path=")
												.append(attachment.getPath())
												.append(htmlBody.substring(start + cid.length() + 4))
												.toString();
										}
									}
								}

							}
							if (htmlBody != null) {
								int sIdx = htmlBody.indexOf("<script");
								int eIdx = 0;
								if (sIdx <0) sIdx = htmlBody.indexOf("<SCRIPT");
								while(sIdx > -1)
								{
									eIdx = htmlBody.indexOf("/script>");
									if (eIdx < 0) eIdx = htmlBody.indexOf("/SCRIPT>");
									htmlBody = htmlBody.substring(0, sIdx - 1) + htmlBody.substring(eIdx + 8);
									sIdx = htmlBody.indexOf("<script");
									if (sIdx < 0) sIdx = htmlBody.indexOf("<SCRIPT");
								}
								
								if(htmlBody.indexOf("$_RCPT_$")>-1){
									htmlBody = htmlBody.substring(0, htmlBody.indexOf("$_RCPT_$"))
											+ loginuser.emailId+"@"+domainName +htmlBody.substring(htmlBody.indexOf("$_RCPT_$")+8, htmlBody.length());
								}
								if(htmlBody.indexOf("&amp;")>-1){
									htmlBody = htmlBody.substring(0, htmlBody.indexOf("&amp;"))
											+"&" + htmlBody.substring(htmlBody.indexOf("&amp;")+5, htmlBody.length());
								}
								
								if(mailboxID==2){
									if(htmlBody.indexOf("<img style='display:hidden'")!=-1){
										String tmp = htmlBody;
										int startLine = tmp.indexOf("<img style='display:hidden'");
										tmp = tmp.substring(startLine, tmp.length());
										int endLine = tmp.indexOf("'>");
										htmlBody = htmlBody.substring(0, startLine) + htmlBody.substring(startLine+endLine+2,htmlBody.length());
									}
								}
								if(htmlBody.indexOf("<PRE>")>-1){
									htmlBody = htmlBody.replaceAll("<PRE>","<PRE style='word-wrap:break-word;'>");
								}
							}
							out.print("<div style='word-break:break-all;'>" + htmlBody + "</div>");
						} else {
							String textBody = envelope.getTextBody();
							if (textBody != null) {
								out.print("<pre>" + textBody + "</pre>");
							}
						}
					%>				
					</td>
				</tr>
			</table>
			<table><tr><td class="tblspace09"></td></tr></table>
			<%
				if (attachments != null && attachments.size() > 0) {									
					StringBuffer attachmentBuf = new StringBuffer();
					Iterator iter = attachments.iterator();
					while (iter.hasNext()) {
						Attachment attachment = (Attachment)iter.next();
								
						//for download control
						attachmentBuf.append(attachment.getPath());
						attachmentBuf.append('|');
						attachmentBuf.append(attachment.getFileName());
						attachmentBuf.append('|');
						attachmentBuf.append("" + attachment.getSize());
						attachmentBuf.append('|');
					}
					
					String baseURL = homePath;//application.getInitParameter("CONF.HOME_PATH");
					if (!baseURL.endsWith("/")){
						baseURL += "/";
					}
					baseURL += "mail/mail_dn_attachment.jsp?message_name=";
					baseURL += message_name;
					baseURL += "&path=";
			%>
			<%
					String pageUrl = new StringBuffer()
								.append("../common/attachdown_control.jsp?attachfiles=")
								.append(java.net.URLEncoder.encode(attachmentBuf.toString(), "utf-8"))
								.append("&baseurl=")
								.append(java.net.URLEncoder.encode(baseURL, "utf-8"))
								.toString();
			%>
					<jsp:include page="<%=pageUrl%>" flush="true"/>
                    <table><tr><td class=tblspace09></td></tr></table>
			<%
				}
			%>
		</form>
	</body>
</html>
<script language="javascript">
	SetHelpIndex("mail_read");
</script>
