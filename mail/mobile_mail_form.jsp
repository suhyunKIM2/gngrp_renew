<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%!
	private MailRepository repository = MailRepository.getInstance();

	private static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
	
	//오늘 날짜 선언부분 시작
	java.util.Date today = new java.util.Date();
	java.text.SimpleDateFormat format_fullToday = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	
	public String FromToString(String str, String sender) {
		try {
			if (str.indexOf( "=?" ) == -1) {
				str = MimeUtility.decodeText(str);
		        str = new String(str.getBytes("ISO-8859-1"),"EUC-KR");
		     }else {
		    	  return sender;
		     }
		}
		catch (Exception e) {
		}
		finally {
		}
		return str ;
	}
%>
<%@ include file="../common/usersession.jsp"%>
<% 
	request.setCharacterEncoding("utf-8");
	String email = "";						// 2012-03-26 loginuser.email 사용않함. 대체 

	if (!uservariable.userDomain.equals("")) {
		email = loginuser.emailId + "@" + uservariable.userDomain;
	} else {
		email = loginuser.emailId + "@" + application.getInitParameter("nek.mail.domain");
	}
	
	//OS 버전 확인
	String userAgent = request.getHeader("User-Agent");
	boolean isIE = nek.common.util.Convert.isIE(request);
	isIE = false;	//20121207 웹에디터 쓰지 않음
	boolean selEditor = false;
	if (userAgent == null || 
		userAgent.indexOf("Windows 95") > 0 ||
		userAgent.indexOf("Windows 98") > 0)
	{
		selEditor = true;
	}

	ParameterParser pp = new ParameterParser(request);

	String cmd			= pp.getStringParameter("cmd", "new");
	int pageNo			= pp.getIntParameter("pg", 1);
	int mailboxID		= pp.getIntParameter("box", Mailbox.INBOX);
	String searchText	= pp.getStringParameter("searchtext", "");
	String searchType	= pp.getStringParameter("searchtype", "");

	MailEnvelope envelope = null;
	MimeMessage msg = null;
	Signature signature = null;
	Signature comsignature = null;
	String to = null;
	String cc = null;// cc = new StringBuffer();
	String bcc = null;//StringBuffer bcc = new StringBuffer();
	String subject = "";
	StringBuffer files = new StringBuffer();
	String body = "";
	int importance = 3;
	boolean mailUseChk = false;	//메일 사용여부
	String messageName = null;
	String attachDiv = "";
	ArrayList paperList = null;	//편지지목록
	String selectPaper = "";	//편지지 select
	
	String expData = request.getParameter("expdata");
	if(expData == null){
		expData = "";
	}	
	messageName = request.getParameter("message_name");
	if (messageName == null) {
		messageName = "";
	}

	ConfigItem cfItem = null;
	String homePath= null;

	//MailRepository repository = null;
	DBHandler db = new DBHandler();
	Connection con = null;
	
    String domainName = application.getInitParameter("nek.mail.domain");
    if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
	try {
		con = db.getDbConnection();
		
		cfItem = ConfigTool.getConfigValue(con, application.getInitParameter("CONF.HOME_PATH"));
		homePath = cfItem.cfValue;
		if (!homePath.endsWith("/")) homePath += "/";

		if (messageName.length() > 0) {
			envelope = repository.retrieve(con, loginuser.emailId, messageName, domainName);
		}
		signature = repository.getSignature(con, loginuser.uid);
		comsignature = repository.getComSignature(con);
		//메일 사용 여부 체크
		mailUseChk = repository.getUserMailChk(con, loginuser.uid);
		
		//편지지 목록
		paperList = repository.getPaperlist(con);
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}
	
	//메일 사용 권한이 없다면 작성하지 못하도록 한다.
	if (mailUseChk){
		out.print("<script language='javascript'>alert('메일 작성 권한이 없습니다.');top.window.opener = top;	top.window.open('','_parent', '');top.window.close();</script>");
		//out.close();
		return;
	}

	if (envelope == null) {
		//새로 작성
		to = request.getParameter("to");

	} else {
		//수정,답변,회신
		msg = envelope.getMessage();

		try{
			body = envelope.getHtmlBody();
		}catch(Exception ex) {
			System.out.println("mail_form_html : " + ex); 
		}
		
		if (body == null) {
			String textBody = envelope.getTextBody();
			if (textBody == null) {
				body = "";
			} else {
				textBody = textBody.replaceAll("<","&lt;");
				textBody = textBody.replaceAll(">","&gt;");
				body = new StringBuffer()
							.append("<pre style='word-wrap:break-word;'>")
							.append(textBody)
							.append("</pre>").toString();
			}
		}
		
		if (body != null) {
			//process inlined images
			Collection attachments = envelope.getAttachments();
			if (attachments != null && attachments.size() > 0) {

				Iterator iter = attachments.iterator();
				while (iter.hasNext()) {
					Attachment attachment = (Attachment)iter.next();
					String cid = attachment.getContentID();
					
					if (cid != null) {	
						//2013-02-08 가람시스템 본문 이미지만 제외함.
						if(cid.indexOf("GARAMSYSTEM")>-1){
							// TODO 정규표현을 이용하는 방안을 함 생각해보자 
							int start = body.indexOf("cid:" + cid);
							if (start == -1) {
								start = body.indexOf("CID:" + cid);
							}
							if (start != -1) {
								body = new StringBuffer()
									.append(body.substring(0, start))
									.append("/mail/mail_dn_attachment.jsp?message_name=")
									.append(messageName)
									.append("&path=")
									.append(attachment.getPath())
									.append(body.substring(start + cid.length() + 4))
									.toString();
							}
						}
					}
				}
			}
		}

		boolean appendOriginal = true;

		//제목
		String msgSub = envelope.getSubject();
		//발신자
		String[] fromObj = msg.getHeader("from");
		String mimeFrom = "";
		for ( int a=0; a < fromObj.length; a++ ) mimeFrom += fromObj[a];
		String senders = "";
		try{
			senders = FromToString(mimeFrom, envelope.getReplyRecipients());
		}catch(Exception e){}
		if (cmd.equals("reply")) {
			//subject = "RE: " + msg.getSubject();
			subject = "RE: " + msgSub ;
			//to = envelope.getReplyRecipients();
			//to = senders;
			try{
				to = envelope.getRecipients(Message.RecipientType.TO, email);
			}catch(Exception e){}
		} else if (cmd.equals("replyall")) {
			//subject = "RE: " + msg.getSubject();
			subject = "RE: " + msgSub ;
			try{
				to = envelope.getReplyAllRecipients(email);
			}catch(Exception e){}
			try{
				cc = envelope.getRecipients(Message.RecipientType.CC);
			}catch(Exception e){
				cc = envelope.getRecipients(Message.RecipientType.CC, email);
			}
		} else if (cmd.equals("forward")) {
			//subject = "FW: " + msg.getSubject();
			subject = "FW: " + msgSub ;
		} else {
			//maybe editing draft
			appendOriginal = false;
			subject = msgSub ;
			//subject = msg.getSubject();
			try{
				to = envelope.getRecipients(null, email);
			}catch(Exception e){}
			try{
				cc = envelope.getRecipients(Message.RecipientType.CC, email);
			}catch(Exception e){}
			try{
				bcc = envelope.getRecipients(Message.RecipientType.BCC, email);
			}catch(Exception e){}
		}

		if(envelope != null){
			int sIdx = body.indexOf("<script");
			int eIdx = 0;
			//if (sIdx <0) sIdx = body.indexOf("<SCRIPT");
			while(sIdx > -1)
			{
				eIdx = body.indexOf("/script>");
				//System.out.println(sIdx + " " + eIdx);
				//if (eIdx < 0) eIdx = body.indexOf("/SCRIPT>");
				//System.out.println(body.substring(sIdx - 1, eIdx+8));
				body = body.substring(0, sIdx - 1) + body.substring(eIdx + 8);
				sIdx = body.indexOf("<script");
				//if (sIdx < 0) sIdx = body.indexOf("<SCRIPT");
			}
			
			if(body.indexOf("<img style='display:hidden'")!=-1){
				String tmp = body;
				int startLine = tmp.indexOf("<img style='display:hidden'");
				tmp = tmp.substring(startLine, tmp.length());
				int endLine = tmp.indexOf("'>");
				body = body.substring(0, startLine) + body.substring(startLine+endLine+2,body.length());
			}
		}
		
		if (appendOriginal) {
			String strTo = "";
			try{
				strTo = envelope.getRecipients(Message.RecipientType.TO);
			}catch(Exception e){
				strTo = "UNKNOWN";
			}
			String strCc = "";
			try{
				strCc = envelope.getRecipients(Message.RecipientType.CC);
			}catch(Exception e){
				strCc = envelope.getRecipients(Message.RecipientType.CC, email);
			}
			body = new StringBuffer()
					.append("<br><br><br><br><br><span id='fmsign'></span><span id='fmcomsign'></span><div style='font-size: 9pt'><div>------------------ Original Message ------------------</div>"
						+ "<div style='border-left: 2px solid black; padding-left: 5px;' id='req'>"
						+ "<div>From: ")
					//.append(HtmlEncoder.encode(envelope.getReplyRecipients()))
					.append(HtmlEncoder.encode(senders))
					.append("</div><div>To: ")
					.append(HtmlEncoder.encode(strTo))
					.append((!HtmlEncoder.encode(strCc).equals("") ? "</div><div>CC: " : ""))
					.append((!HtmlEncoder.encode(strCc).equals("") ? HtmlEncoder.encode(strCc): ""))
					.append("</div><div>Sent: ")
					.append(envelope.getDate().toString())
					.append("</div><div>Subject: ")
					//.append(HtmlEncoder.encode(msg.getSubject()))
					.append(HtmlEncoder.encode(msgSub))
					.append("</div><br>")
					.append(body)
					.append("</div></div>").toString();

		}

		//attachments --------------------------------------------------
		if (!cmd.startsWith("reply")) {
			Collection attachments = envelope.getAttachments();
			if (attachments != null) {
				Iterator iter = attachments.iterator();
				while (iter.hasNext()) {
					Attachment attachment = (Attachment)iter.next();
					String cid = attachment.getContentID();
					if (cid != null) {	
						//2013-02-08 가람시스템 본문 이미지만 제외함.
						if(cid.indexOf("GARAMSYSTEM")>-1){
							continue;
						}
					}
					
					files.append(attachment.getPath())
						 .append('|')
						 .append(attachment.getFileName())
						 .append('|')
						 .append(attachment.getSize())
						 .append('|');
				}
			}
		}
		
		//본문 이미지 별도 처리
		Collection attachments = envelope.getAttachments();
		if (attachments != null) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment)iter.next();
				String cid = attachment.getContentID();
				if (cid != null) {	
					//2013-02-08 가람시스템 본문 이미지만 제외함.
					if(cid.indexOf("GARAMSYSTEM")>-1){
						attachDiv  += "<input type='hidden' name='imghid' value='message_name=" + envelope.getMessageName() +"&path=" + attachment.getPath() + "／" + attachment.getFileName() +"'>";
					}
				}
			}
		}
		
		
		importance = envelope.getImportance();
		//saveAfterSent = envelope.saveAfterSent();
	}
	
	//메일 용량체크
	long mailQuota = uservariable.mailBoxSize/(1024*1024);
	MailRepositorySummary mailboxSummary  =  null;
	try{
		con = db.getDbConnection();
		mailboxSummary  =  MailRepository.getInstance().getRepositorySize(con, loginuser.emailId, domainName);
	}catch(Exception ex){}
	finally{
		if (con != null) { db.freeDbConnection(); }
	}
	double mailUsage = (double)mailboxSummary.getTotalSize();
	mailUsage = mailUsage/(1024.0*1024.0);
	int mailPercent = (int)(mailQuota == 0 ? 0 : (100* mailUsage)/mailQuota);
	if (mailPercent > 100) {
		mailPercent = 100;
	}
	
	//편지지 작성
	if(paperList !=null){
		selectPaper = "<select id='selPaper' style='width:150px;' onchange='setMailPaper()'><option value=''>편지지 선택</option>";
		for(int a=0;a<paperList.size();a++){
			MailPaperInfo item = (MailPaperInfo)paperList.get(a);
			selectPaper += "<option value='" + item.getDocId() + "'>" + item.getSubject() + "</option>";
		}
		selectPaper += "</select>";
	}
	
	// TEST 하기 위해 삽입 LSH
	int port = request.getServerPort();
	homePath = request.getScheme() + "://" + request.getServerName() + (port != 80 ? ":" + Integer.toString(port) : "") + request.getContextPath();
	if (!homePath.endsWith("/")) homePath += "/";
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><fmt:message key="mail.title" /></title>
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
	<link rel="stylesheet" type="text/css" href="/common/jquery/plugins/token-input-facebook.css" />
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
	<script type="text/javascript" src="/common/jquery/plugins/jquery.tokeninput.js"></script>
	<script src="<%=scriptPath %>/common.js"></script>
	<style type="text/css">	
		div.token-input-dropdown-facebook {
			z-index: 99999;
		    border-top: 1px solid rgb(204, 204, 204);
			max-height: 300px;
			overflow-y: auto;
			/* prevent horizontal scrollbar */
			overflow-x: auto;
		}
		.token-input-dropdown-facebook li {
			white-space: nowrap;
		}
		* html div.token-input-dropdown-facebook {
			height: 300px;
		}
	</style>
	<script language="javascript">
	
	var strDomain = "<%=domainName %>";
	
	//개인서명 적용여부 체크
	function OnPersonSign(){
		var form = document.forms[0];
		var webEdit;
		<%if(isIE){%>
		webEdit = document.getElementById("twe").HtmlValue; 
		<%}else{%>
		webEdit = Editor.getContent(); 
		<%} %>
		
		if(form.chkPerSign.checked){
			document.getElementById("dspbody").innerHTML = webEdit;
			var str = document.getElementById("dspbody").getElementsByTagName("SPAN");
			var trSize = str.length;
			var chkVal = false;
			var finalChk = false;
			var fCnt = 0;
			var count = 0;
			for(var i=0;i<trSize;i++){
				if(str[i].id=="fmsign"){
					if(webEdit.indexOf("id=req")>-1){	//내부사용자가 보낸 메일인지 체크
						if(!(webEdit.indexOf("fmsign")>webEdit.indexOf("id=req"))){	//ID값이 지워졌을때
							str[i].innerHTML = document.getElementById("dissignature").innerHTML;
							chkVal=true;
						}else{
							finalChk = true;
							fCnt = i;
						}
					}else{	//초기값이 정상적인 상태일때
						if(count==0){
							str[i].innerHTML = document.getElementById("dissignature").innerHTML;
							chkVal=true;
						}
					}
					count++;
				}
			}
			if(finalChk){
				str[fCnt].innerHTML = document.getElementById("dissignature").innerHTML;
				chkVal=true;
			}
	
			if(chkVal){
				<%if(isIE){%>
				document.getElementById("twe").HtmlValue = document.getElementById("dspbody").innerHTML;			
				<%}else{%>
				Editor.modify({
					"content": document.getElementById("dspbody").innerHTML
				});
				<%}%>
			}else{
				<%if(isIE){%>
				document.getElementById("twe").HtmlValue = webEdit + "<span id='fmsign'>" + document.getElementById("dissignature").innerHTML + "</SPAN>";			
				<%}else{%>
				Editor.modify({
					"content": webEdit + "<span id='fmsign'>" + document.getElementById("dissignature").innerHTML + "</SPAN>"
				});
				<%}%>
			}
		}else{
			document.getElementById("dspbody").innerHTML = webEdit;
			var str = document.getElementById("dspbody").getElementsByTagName("SPAN");
			var trSize = str.length;
			var finalChk = false;
			var chkVal = false;
			var fCnt = 0;
			var count = 0;
			for(var i=0;i<trSize;i++){
				if(str[i].id=="fmsign"){
					if(webEdit.indexOf("id=req")>-1){	//내부사용자가 보낸 메일인지 체크
						if(!(webEdit.indexOf("fmsign")>webEdit.indexOf("id=req"))){	//ID값이 지워졌을때
							if(count==0){
								str[i].innerHTML = "";
								chkVal=true;
							}
						}else{
							finalChk = true;
							fCnt = i;
						}
					}else{
						if(i==0){
							str[i].innerHTML = "";
							chkVal=true;
						}
					}
					count++;
				}
			}
			if(finalChk){
				str[fCnt].innerHTML = "";
				chkVal=true;
			}
	
			if(chkVal){
				<%if(isIE){%>
				document.getElementById("twe").HtmlValue = document.getElementById("dspbody").innerHTML;			
				<%}else{%>
				Editor.modify({
					"content": document.getElementById("dspbody").innerHTML
				});
				<%}%>
			}
		}
	}
	
	function OnClickSend() {
		//수신자중 (To) 체크 -------------------------------------------------
		var nToCount = 0;
		document.fmMail.to.value = document.fmMail.receive_to.value;
		document.fmMail.cc.value = document.fmMail.receive_cc.value;
		document.fmMail.bcc.value = document.fmMail.receive_bcc.value;
		
		if (document.fmMail.to.value == "") {
			alert("<fmt:message key='mail.c.recipient.MoreThenOne'/>");//수신자가 한명 이상 있어야 합니다!
			return;
		}
	
		if (TrimAll(fmMail.subject.value) == "") {
			alert("<fmt:message key='v.subject.required'/>");//제목을 입력하여 주십시요!
			fmMail.subject.focus();
			return;
		}		
	
		//Recipients 달기 ---------------------------------------------------
		
		if (document.fmMail.chkreceipt.checked) {
			document.fmMail.saveaftersent.checked = true;
		}
	
// 		if (document.fmMail.reserved.checked)
// 		{
// 			var reservedDate = GetJavaScriptDate(document.fmMail.reserved_date.value);
// 			var hour = document.fmMail.reserved_hour.selectedIndex;
// 			var min = document.fmMail.reserved_min.selectedIndex * 10;
	
// 			reservedDate.setHours(hour);
// 			reservedDate.setMinutes(min);
// 			reservedDate.setSeconds(0);
// 			reservedDate.setMilliseconds(0);
	
// 			if (reservedDate < new Date())
// 			{
// 				alert("<fmt:message key='mail.reservation.notbo.earlier'/>"); //예약일시는 현재 시각보다 이전일 수 없습니다!
// 				return;
// 			}
// 			document.fmMail.reserved_dt.value = reservedDate.getTime();
// 		}
		
		if(!confirm("<fmt:message key='mail.c.send.mail'/>")) return false;//메일을 발송하시겠습니까?
		
		//진행 상태바
		var pgObj = document.getElementById("myid");
	 	pgObj.style.display = "";
	
		var mailNewDoc = "Mail"  + "<%=loginuser.uid%>"+<%=System.currentTimeMillis()%>;
		fmMail.maildoc.value = mailNewDoc;
		
		var tempBody = document.getElementById("txtContent").value;
		tempBody = tempBody.replace(/\r\n/g, "<br>");
		tempBody = tempBody.replace(/\n/g, "<br>");
		tempBody = tempBody.replace(/\r/g, "<br>");
		fmMail.mailbody.value = tempBody;
		
		//fmMail.mailbodysave.value = document.getElementById("twe").BodyValue; /* document.all.Wec.Value; */
		//fmMail.mailbody.value = document.getElementById("twe").MimeValue();/* document.all.Wec.MIMEValue */
<%--
			if ($('.template-upload') && $('.template-upload').length > 0) {
				document.fmMail.action = "/upload";
				document.fmMail.isfiles.value = "1";
				document.fmMail.fileuploadstartconfirm.value = "0";
				$('.fileupload-buttonbar').find('.start').click();
	//				$('button[type=submit]').click();
				return;
			} else { 
				document.fmMail.submit();
			}
--%>
			document.fmMail.submit();
		
		return false;
	}
	
	function GetJavaScriptDate(strDate)
	{
		if (strDate == null || strDate.length == 0)
		{
			return null;
		}
		return ParseDateString(strDate);
	}
	
	function ParseDateString(strDate)
	{
		var objArray = strDate.split("-");
	    
	//	return new Date(parseInt(objArray[0]), parseInt(objArray[1]) - 1, parseInt(objArray[2]));
		return new Date(eval(objArray[0]), eval(objArray[1]) - 1, eval(objArray[2]));
	}
	
	function OnClickDraft() {
// 	    if (document.fmMail.reserved.checked){
// 	        if (!confirm("<fmt:message key='mail.tmp.cancel.save'/>")) return ;////임시저장시에는 예약발송을 해제해야합니다 \n\n해제후 계속 진행하시겠습니까?
// 	        document.fmMail.reserved.checked = false ; 
// 	    }
		//수신자중 (To) 체크 -------------------------------------------------
		var nToCount = 0;
		document.fmMail.to.value = document.fmMail.receive_to.value;
		document.fmMail.cc.value = document.fmMail.receive_cc.value;
		document.fmMail.bcc.value = document.fmMail.receive_bcc.value;
		
		if (document.fmMail.to.value == "") {
			alert("<fmt:message key='mail.c.recipient.MoreThenOne'/>");//수신자가 한명 이상 있어야 합니다!
			return;
		}
	
		if(TrimAll(fmMail.subject.value) == "") {
			alert("<fmt:message key='v.subject.required'/>");//제목을 입력하여 주십시요!
			return;
		}
	
		var conf_tmpMsg = "임시저장 하시겠습니까?"; // 한국어 전용
		if (!confirm(conf_tmpMsg)) return;
		
		//임시저장임을 알림
		document.forms[0].cmd.value = "draft";
		
		var mailNewDoc = "Mail"  + "<%=loginuser.uid%>" + "_"+<%=System.currentTimeMillis()%>;

		var tempBody = document.getElementById("txtContent").value;
		tempBody = tempBody.replace(/\r\n/g, "<br>");
		tempBody = tempBody.replace(/\n/g, "<br>");
		tempBody = tempBody.replace(/\r/g, "<br>");
		fmMail.mailbody.value = tempBody;
		
		document.fmMail.submit();
		return false;
	}
	
	function OnClickRemoveRecipients() {
		var objList = fmMail.select_recipients;
		var bRefresh = false;
		for (var i = objList.options.length - 1; i >= 0; i--) {
			if (objList.options[i].selected) {
				RemoveRecipient(objList.options[i].value);
				bRefresh = true;
			}
		}
	
		if (bRefresh) {
			RefreshRecipientsList();
		}
	
	}
	
	function RemoveRecipient(strAddress) {
		var objNewRecipients = new Array();
		var strAddressLower = strAddress.toLowerCase();
		var nIndex = -1;
		for (var i = 0; i < objRecipients.length; i++) {
			if (strAddressLower != AddressToString(objRecipients[i]).toLowerCase()) {
				objNewRecipients.push(objRecipients[i]);
			}
		}
		objRecipients = objNewRecipients;
	}
	
	
	function OnClickAddRecipients() {
		var strText = fmMail.edit_recipient.value;
		if (TrimAll(strText).length == 0) {
			alert("<fmt:message key='mail.recipient.address'/>");
			fmMail.edit_recipient.focus();
			return;
		}
	
		AddRecipients(strText, false);
	
		fmMail.edit_recipient.select();
	}
	
	function AddRecipients(strRecipients, bSilent) {
	
		// 2012-03-13 LSH
		strRecipients.replace(/\"[^\"]*\"/g, function(str) { 
			strRecipients = strRecipients.replace(str, str.replace(/,/g, " ")); 
		});
		var strSegments = strRecipients.split(',');
		var strSegmentsTrimmed = new Array();
		for (var i = 0; i < strSegments.length; i++) {
			var strSegment = TrimAll(strSegments[i]);
			if (strSegment.length > 0) {
				strSegmentsTrimmed.push(strSegment);
			}
		}
	
		var keywords = new Array();
	
		for (var i = 0; i < strSegmentsTrimmed.length; i++) {
			var objAddress = ParseRecipient(strSegmentsTrimmed[i]);
			if (objAddress == null && !bSilent) {
				alert("'" + strSegmentsTrimmed[i] + "'<fmt:message key='mail.wrong.mail'/>");//는(은) 잘못된 메일주소입니다!
			} else {
				if (objAddress.address == "") {
					keywords.push(strSegmentsTrimmed[i]);
				} else {
					AddRecipient(objAddress, bSilent);
				}
				
			}
		}
	
		if (keywords.length > 0) {
			SearchRecipients(keywords);
		}
	}
	
	function SearchRecipients(keywords) {
		var param = "";
		for (var i = 0; i < keywords.length; i++) {
			if(i==0){
				param += "keyword=";
			}else{
				param += "&keyword=";
			}
			param += encodeURI(keywords[i]);
		}
	
		var objXmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		objXmlHttp.open("POST", "mail_findrecipients.jsp?" + param, false, "", "");
		//objXmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		objXmlHttp.send();
	
		if (objXmlHttp.status != 200) {
			var msg = "<fmt:message key='c.search.error'/>["; //검색 중 오류가 발생하였습니다!\r\n
			msg += objXmlHttp.status;
			msg += "] ";
			msg += objXmlHttp.statusText;
			alert(msg);
			return;
		}
	
		var objXml = objXmlHttp.responseXML;
		if (objXml == null) {
			alert("<fmt:message key='c.search.error'/>");//검색 중 오류가 발생하였습니다!
			return;
		}
	
		var objMultis = new Array();
		var results = objXml.selectNodes("//search-result");
		for (var i = 0; i < results.length; i++) {
			var objElems = results[i].childNodes;//results[i].selectNodes("./recipient");
			if (objElems.length == 0) {
				//검색 결과 없음
			} else if (objElems.length == 1) {
				//한명
				var objElem = objElems[0];
				var name = "";
				var email = "";
				var nodeName = objElem.nodeName;
	
				if ("ou" == nodeName) {
					var type = objElem.getAttribute("type");
					if ("user" == type) {
						name = objElem.getAttribute("name");
						email = "\"" + name + "\" <" + objElem.getAttribute("emailid") + "@" + strDomain + ">";
					} else if ("department" == type) {
					}
				} else if ("contact" == nodeName) {
					name = objElem.getAttribute("name");
					email = objElem.getAttribute("email");
				}
	
				if (email != null && email.length > 0) {
					var objAddress = null;
					objAddress = ParseRecipient(email);
					if (objAddress != null) {
						if  (objAddress.personal == null || objAddress.personal == "") {
							objAddress.personal = name;
						}
						objAddress.type = GetCurrentRecipientType();
						AddRecipient(objAddress, false);
					}
				}
			} else {
				//여러명
				objMultis.push(results[i]);
			}
		}
		if (objMultis.length > 0) {
			var ret = window.showModalDialog("mail_selectrecipients.jsp", objMultis, 
				"dialogHeight: 300px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; scroll: no;");
	
			if (ret != null) {
				for (var i = 0; i < ret.length; i++) {
					AddRecipient(ret[i], true);
				}
			}
		}
	}
	
	function OnInputRecipientKeyDown() {
		var objEvent = window.event;
		if (objEvent.keyCode == 13/*\r*/) {
			if(tbIndex!=undefined) return;
			var bRet = OnClickAddRecipients();
			objEvent.returnValue = false;
			return bRet;
		}
	}
	
	
	/*
		IN: Object : mail address object
	*/
	
	
	var objRecipients = new Array();
	
	function AddRecipient(objAddress, bSilent) {
		//이미 선택된 메일주소인 확인
		var strAddressLower = objAddress.address.toLowerCase();
		//메일 유효성 체크
		var em = strAddressLower.match(/^[_\-\.0-9a-zA-Z]{2,}@[-.0-9a-zA-z]{2,}\.[a-zA-Z]{2,4}$/);
		if(!em){
			alert("'" + AddressToString(objAddress) + "'<fmt:message key='mail.wrong.mail'/>");////는(은) 잘못된 메일주소입니다!
			return;
		}
		for (var i = 0; i < objRecipients.length; i++) {
			var strAddress1 = objRecipients[i].address.toLowerCase();
			if (strAddressLower == strAddress1) {
				if (!bSilent) {
					alert(AddressToString(objAddress) + "<fmt:message key='mail.already.have'/>");//는(은) 이미 있습니다!
				}
				return;
			}		
		}
		objRecipients.push(objAddress);
		objRecipients.sort(SortAddress);
	
		RefreshRecipientsList();
	}
	
	
	function RefreshRecipientsList() {
		var objList = document.fmMail.select_recipients;
		while (objList.options.length > 0) {
			objList.options.remove(0);
		}
	
		for (var i = 0; i < objRecipients.length; i++) {
			var objRecipient = objRecipients[i];
				
			var objOption = document.createElement("OPTION");
			objOption.text = AddressToDisplayString(objRecipient);
			objOption.value = AddressToString(objRecipient);
			objList.options.add(objOption);
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////
	/*
	function Address() {
		//properties
		this.personal = "";
		this.address = "";
		this.type = 0;	//To
	
		//methods
		this.toDisplayString = AddressToDisplayString;
		this.toString = AddressToString;
	}
	*/
	
	function AddressToString(objAddress) {
		var strAddress = "";
	
		if (objAddress.depttype != undefined) {
			if (objAddress.depttype == "department") {
				strAddress += "D:" + objAddress.id + ":" + objAddress.name +":"+objAddress.includeSub;
			}
		}else{
			strAddress += "\"";
			if (objAddress.personal == null || objAddress.personal == "") {
				strAddress += objAddress.address;
			} else {
				strAddress += objAddress.personal;
			}
			strAddress += "\" <";
			strAddress += objAddress.address;
			strAddress += ">";
		}
		return strAddress;
	}
	
	function AddressToDisplayString(objAddress) {
		var strDisplay = "";
	// 	if (objAddress.type == 1)	{
	// 		strDisplay += "[<fmt:message key='mail.CC'/>]         ";		//[참조]
	// 	} else if (objAddress.type == 2) {
	// 		strDisplay += "[<fmt:message key='mail.BCC'/>]   ";			//[비밀참조]
	// 	} else {
	// 		strDisplay += "[<fmt:message key='t.recipients'/>]  ";		//[수신]
	// 	}
	
		if (objAddress.depttype != undefined) {
			if (objAddress.depttype == "department") {
				strDisplay += "\"";
				strDisplay += objAddress.name;
				if (objAddress.includeSub) {
					strDisplay += "[+]";
				} else {
					strDisplay += "[-]";
				}
				strDisplay += "\"";
			}
		}else{	
			strDisplay += ""; //"\"";
			if (objAddress.personal == null || objAddress.personal == "") {
				strDisplay += objAddress.address;
			} else {
				strDisplay += objAddress.personal;
			}
			//strDisplay += "\" <";
			strDisplay += " <";
			strDisplay += objAddress.address;
			strDisplay += ">";
	
		}
		return strDisplay;
	}
	
	
	function SortAddress(objAddress1, objAddress2)
	{
		var strAddress1 = "";
		var strAddress2 = "";
	
		strAddress1 += objAddress1.type;
		strAddress1 += ":";
		strAddress1 += objAddress1.personal;
		strAddress1 += objAddress1.address;
	
		strAddress2 += objAddress2.type;
		strAddress2 += ":";
		strAddress2 += objAddress2.personal;
		strAddress2 += objAddress2.address;
	
		return strAddress1.localeCompare(strAddress2);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*
		IN: ["kdh" <test@nekjava.kmsmap.com>]
			["kdh"]
			[kdh]
			[test@nekjava.kmsmap.com]
			[<test@nekjava.kmsmap.com>]
		RET: Object, if valid.
			 null, if invalid
	
	*/
	function ParseRecipient(strText) {
		var objAddress = null;
		var strPersonal = "";
		var strAddress = "";
	
		if (strText.indexOf('@') > -1) {
			//strText가 이메일 주소로 가정
			var nIndex1 = strText.indexOf('"');
			if (nIndex1 > -1) {
				//이름분리
				var nIndex2 = strText.indexOf('"', nIndex1 + 1);
				if (nIndex2 > nIndex1) {
					strPersonal = strText.substring(nIndex1 + 1, nIndex2);
					strPersonal = TrimAll(strPersonal);
				} else {
					//invalid
					return null;
				}
			}
			
			nIndex1 = strText.indexOf('<');
			if (nIndex1 > -1) {
				//이름분리
				var nIndex2 = strText.indexOf('>', nIndex1 + 1);
				if (nIndex2 > nIndex1) {
					strAddress = strText.substring(nIndex1 + 1, nIndex2);
					strAddress = TrimAll(strAddress);
				} else {
					//invalid 
					return null;
				}
			}
	
			if (strAddress == "") {
				if (strPersonal == "") {
					//이 경우는 메일주소부분만 입력한 경우 (admin@nekjava.kmsmap.com)
					objAddress = new Object();
					objAddress.personal = "";
					objAddress.address = strText;
				} else {
					//personal part only, --> 검색
					objAddress = new Object();
					objAddress.personal = strPersonal;
					objAddress.address = "";
				}
			} else {
				objAddress = new Object();
				objAddress.address = strAddress;
				if (strPersonal == "") {
					objAddress.personal = strAddress;
				} else {
					objAddress.personal = strPersonal;
				}
	
				//return objAddress;
			}				
		} else {
			//personal part only,
			objAddress = new Object();
			objAddress.personal = strPersonal;
			objAddress.address = "";
		}
	
	// 	objAddress.type = GetCurrentRecipientType();
		return objAddress;
	}
	
	
	/*
		IN: none
		RET: string 0: "To", 1: "CC", 2: "BCC"
	*/
	function GetCurrentRecipientType() {
		var types = document.fmMail.recipient_type;
		if (types[1].checked) {
			return 1;	//CC
		}
		else if (types[2].checked) {
			return 2; //BCC
		}
		return 0;	//To
	}
	
	function OnClickCheckReceipt() {
		if (document.fmMail.chkreceipt.checked) {
			document.fmMail.saveaftersent.checked = true;
		}
	}
	
	function OnClickAddressBook() {
		var ret = window.showModalDialog("mail_ab.jsp", objRecipients,"dialogHeight: 430px; dialogWidth: 650px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
		
		if (ret != null) {
			//이전 주소록 데이터 삭제
			var rowCnt = objRecipients.length;
			var oldObjRecipients = objRecipients;
			for (var i = 0; i < rowCnt; i++) {
				var objAddress = oldObjRecipients[i];
				var strAddress = "";
				var personal = "";
				
				if (objAddress.depttype == "department") {
					if(objAddress.type=="0"){	//수신
						$("#reTo").tokenInput("remove", {id: AddressToString(objAddress), name: AddressToDisplayString(objAddress)});
					}else if(objAddress.type=="1"){	//참조	
						$("#reCc").tokenInput("remove", {id: AddressToString(objAddress), name: AddressToDisplayString(objAddress)});
					}else if(objAddress.type=="2"){	//비밀참조
						$("#reBcc").tokenInput("remove", {id: AddressToString(objAddress), name: AddressToDisplayString(objAddress)});
					}
				}else{
					if (objAddress.personal == null || objAddress.personal == "") {
						personal += objAddress.address;
					} else {
						personal += objAddress.personal;
					}
					if(personal!=objAddress.address){
						strAddress = personal + " " + objAddress.address;
					}else{
						strAddress = objAddress.address;
					}
					if(objAddress.type=="0"){	//수신
						$("#reTo").tokenInput("remove", {name: strAddress});
					}else if(objAddress.type=="1"){	//참조	
						$("#reCc").tokenInput("remove", {name: strAddress});
					}else if(objAddress.type=="2"){	//비밀참조
						$("#reBcc").tokenInput("remove", {name: strAddress});
					}
				}
			}
			
			objRecipients = new Array();
			for (var i = 0; i < ret.length; i++) {
				objRecipients.push(ret[i]);
			}
			
			for (var i = 0; i < objRecipients.length; i++) {
				var objAddress = objRecipients[i];
				var strAddress = "";
				var personal = "";
				
				if (objAddress.depttype == "department") {
					if(objAddress.type=="0"){	//수신
						$("#reTo").tokenInput("add", {id: AddressToString(objAddress), name: AddressToDisplayString(objAddress)});
					}else if(objAddress.type=="1"){	//참조	
						$("#reCc").tokenInput("add", {id: AddressToString(objAddress), name: AddressToDisplayString(objAddress)});
					}else if(objAddress.type=="2"){	//비밀참조
						$("#reBcc").tokenInput("add", {id: AddressToString(objAddress), name: AddressToDisplayString(objAddress)});
					}
				}else{
					if (objAddress.personal == null || objAddress.personal == "") {
						personal += objAddress.address;
					} else {
						personal += objAddress.personal;
					}
					if(personal!=objAddress.address){
						strAddress = personal + " " + objAddress.address;
						personal = "\"" + personal + "\" <" + objAddress.address + ">";
					}else{
						strAddress = objAddress.address;
						personal = "\"" + objAddress.address + "\" <" + objAddress.address + ">";
					}
					if(objAddress.type=="0"){	//수신
						$("#reTo").tokenInput("add", {id: personal, name: strAddress});
					}else if(objAddress.type=="1"){	//참조	
						$("#reCc").tokenInput("add", {id: personal, name: strAddress});
					}else if(objAddress.type=="2"){	//비밀참조
						$("#reBcc").tokenInput("add", {id: personal, name: strAddress});
					}
				}
			}
			
	// 		RefreshRecipientsList();
		}
	}
	
	function OnClickReserved() {
		if (document.fmMail.reserved.checked) {
			document.fmMail.reserved_date.disabled = false;
			document.fmMail.reserved_hour.disabled = false;
			document.fmMail.reserved_min.disabled = false;
		} else {
			document.fmMail.reserved_date.disabled = true;
			document.fmMail.reserved_hour.disabled = true;
			document.fmMail.reserved_min.disabled = true;
		}
	}
	
	function OnClickList() {
	/*
		document.fmMail.method = "get";
		document.fmMail.action = "mail_list.jsp";
		document.fmMail.submit();
	*/
		if(confirm("<fmt:message key='c.unsaveClose'/>")){ ////현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.
			window.close();
			return;
		}
	}
	
	function repeatReservation() {
		var retval = window.showModalDialog("mail_repeat.jsp",
				"","dialogWidth:400px;dialogHeight:250px;center:yes;help:0;status:0;scroll:yes");
		if (retval != null) {
		}
	}
	
	function expandBC() {
		var bc = document.getElementById("BC");
		if ( bc.style.display == "") {
			bc.style.display = "none";
		} else {
			bc.style.display = "";
		}
	}
	
	var arrDocs = new Array() ;
	function OnClickDmsAttach(){
		var winwidth = "600";
		var winheight = "500";
	
		var url = "/dms/attachList.htm";
		
		var args = new Object();
	    args.window = window;
		returnValue = window.showModalDialog( url , args ,
						 "status:no;scroll:no;center:yes;help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px");
	
		if (returnValue != null)
		{
			arrDocs = new Array();
			for (var i = 0; i < returnValue.length; i++) {
				arrDocs.push(returnValue[i]);
			}
			setDmsAttachInfo(arrDocs) ;
			
		}
	}
	
	function setDmsAttachInfo(arrDocs){
		var dmsObj = document.getElementById("objDms");
		if(arrDocs.length>0){
			dmsObj.style.display = "";
			document.fmMail.isdms.value = "true";
		}else{
			dmsObj.style.display = "none";
			document.fmMail.isdms.value = "";
			return;
		}
		//테이블 Row Data 생성
		deleteTableRow();
		for (var i = 0; i < arrDocs.length; i++) {
			var dmsDoc = arrDocs[i];
			
			var tbl = document.getElementById("dmstbl"); //this.sharetbl ;
			var idx = tbl.rows.length ;
			
			var newTR = tbl.insertRow(idx) ;
			newTR.id = "dms_" + dmsDoc.docId;
			
		    newTR.setAttribute("checked",false);
	
		    //hidden
		    var hidStr = "<input type='hidden' name='dmsfiles' value='"
		    		+ dmsDoc.docId + "／" +  dmsDoc.fileSaveName + "／" + dmsDoc.fileName + "／" + dmsDoc.fileSize +"'>";
		    //delete button
		    var delBtn = "<input type='button' value='Delete' onclick=\"deleteDmsInfo('"
		    		+ dmsDoc.docId + "', '" + dmsDoc.fileNo +"');\" >";
		    
		    //row 추가
		    var newCell = newTR.insertCell(0);
		    newCell.align = "center" ;
		    newCell.className = "td_le2" ;
		    newCell.style.height = "23px";
		    newCell.innerHTML = dmsDoc.fileName + hidStr ;
		    
		    newCell = newTR.insertCell(1);
		    newCell.align = "center" ;
		    newCell.className = "td_le2" ;
		    newCell.style.height = "23px";
		    newCell.style.textAlign = "right";
		    newCell.innerHTML = dmsDoc.fileSize ;
		    
		    newCell = newTR.insertCell(2);
		    //tbl.rows(idx).insertCell(2);
		    newCell.align = "center" ;
		    newCell.className = "td_le2" ;
		    newCell.style.textAlign = "center";
		    newCell.style.height = "23px";
		    newCell.innerHTML = delBtn ;
		}
	}
	
	function deleteTableRow(){
		var tbl = document.getElementById("dmstbl"); //this.sharetbl ;
		var idx = tbl.rows.length;
		for (var i = idx-1; i > 0; i--) {
			tbl.deleteRow(i) ;
		}
	}
	
	function deleteDmsInfo(docId, fileNo){
		arrNewDms = new Array();
		for (var i = 0; i < arrDocs.length; i++) {
			var dmsInfo = arrDocs[i];
			var a = dmsInfo.docId + "" + dmsInfo.fileNo;
			var b = docId + "" + fileNo;
			if(a!=b){
				arrNewDms.push(arrDocs[i]);
			}
		}
		arrDocs = arrNewDms;
		
		setDmsAttachInfo(arrDocs) ;
	}
	</script>
	<script language="JScript" FOR="twe" EVENT="OnControlInit">
		if (<%=mailPercent%> == 100) {
			alert("메일용량이 초과되었습니다.");
			location.href= history.back();
		}
	
		//본문 -----------------------------------------
		var dspBody = document.getElementById("dspbody");
		
		var strMailBody = dspBody.innerText; //본문내용
		var strSignature = document.getElementById("dissignature").innerText; //개인서명
		document.getElementById("dissignature").innerHTML = strSignature; //개인서명
		//	dspBody.innerHTML = strMailBody; //본문내용
		
		var expData = document.getElementById("expData").innerHTML;	//외부 문서 본문 로드 - 연결
		if (expData == null) expData = "";
		
		<%	if (envelope == null) { %>
			document.getElementById("twe").HtmlValue = dspBody.innerHTML + "<br>" + expData + "<BODY><span id='fmsign'>" + document.getElementById("dissignature").innerHTML + "</span>";
		<%	} else { %>
			document.getElementById("twe").HtmlValue = dspBody.innerHTML;// + est;
		<%	} %>
		document.getElementById("twe").HtmlValue = document.getElementById("twe").HtmlValue.replace(/<?xml/gi, '<xml'); 
			
		//cc ------------------------------------------
		//AddRecipients(fmMail.cc.value, true);
		//to ------------------------------------------
		//AddRecipients(fmMail.to.value, true);
		
		//메일 수신체크 태그 제거
		var editorDom = twe.GetDOM();
	// 	var editorDom = document.getElementById("Wec").CreateDom();	//나모
		if( editorDom.images != null && editorDom.images.length > 0 )
		{
			for( ix=0 ; ix < editorDom.images.length ; ix++ )
			{
				//alert( "ImageID" + ix + " : " + editorDom.images[ix].src);
				if(editorDom.images[ix].id=="nekrecchk"){
					//alert(ix + " : " + editorDom.images[ix].id);
					var hatImage = editorDom.getElementById("nekrecchk");
					var imgParent = hatImage.parentNode;
					imgParent.removeChild(hatImage);
				}
			}
		}
	</script>
	<script type="text/javascript">
	
	function getData(strRecipients){
		var data = new Array();
		// 2012-03-13 LSH
		strRecipients.replace(/\"[^\"]*\"/g, function(str) { 
			strRecipients = strRecipients.replace(str, str.replace(/,/g, " ")); 
		});
		var strSegments = strRecipients.split(',');
		var strSegmentsTrimmed = new Array();
		for (var i = 0; i < strSegments.length; i++) {
			var strSegment = TrimAll(strSegments[i]);
			if (strSegment.length > 0) {
				strSegmentsTrimmed.push(strSegment);
			}
		}

		var keywords = new Array();

		for (var i = 0; i < strSegmentsTrimmed.length; i++) {
			var objAddress = ParseRecipient(strSegmentsTrimmed[i]);
			if (objAddress == null) {
				alert("'" + strSegmentsTrimmed[i] + "'<fmt:message key='mail.wrong.mail'/>");//는(은) 잘못된 메일주소입니다!
			} else {
				var strAddress = "";
				var personal = "";
				if (objAddress.personal == null || objAddress.personal == "") {
					personal += objAddress.address;
				} else {
					personal += objAddress.personal;
				}
				if(personal!=objAddress.address){
					strAddress = personal + " " + objAddress.address;
					personal = "\"" + personal + "\" <" + objAddress.address + ">";
				}else{
					strAddress = objAddress.address;
					personal = "\"" + objAddress.address + "\" <" + objAddress.address + ">";
				}
				
				data.push ({id: personal, name : strAddress });
			}
		}
		return data;
	}
	
	$().ready(function() {		
		$("#reTo").tokenInput("/mail/address_mail_json_t.jsp?addressbook=1&users=1&mail_autocomplete=1&mail_form=1&mail_representation=1",
		{
			queryParam : "searchValue",
			hintText: "Enter Name Here",
	        noResultsText: "No Results Found",
	        searchingText: "Loading...",
			theme: "facebook",
			animateDropdown: false,
            onAdd: function (item) {
//          	alert("Added " + item.name);
			},
            onDelete: function (item) {
             	var arr = new Array();
        		for (var i = 0; i < objRecipients.length; i++) {
        			var objAddress = objRecipients[i];
        			var strAddress = "";
    				var personal = "";
    				if (objAddress.personal == null || objAddress.personal == "") {
    					personal += objAddress.address;
    				} else {
    					personal += objAddress.personal;
    				}
    				if(personal!=objAddress.address){
    					strAddress = personal + " " + objAddress.address;
    				}else{
    					strAddress = objAddress.address;
    				}
        			if(strAddress==item.name) continue;
        			arr.push(objRecipients[i]);
        		}
        		objRecipients = new Array();
        		for (var i = 0; i < arr.length; i++) {
        			objRecipients.push(arr[i]);
        		}
//          	alert("Deleted " + item.name);
            },
            onResult: function (results) {
            	$.each(results, function (index, value) {
                	var recNm = value.name;
    				if(value.name == "") recNm = value.value; 
    				var id = "\"" + recNm + "\" <" + value.value+">";
                	value.id = id;
                	value.name = value.search;
                });
                return results;
			}, 
            prePopulate: getData(fmMail.to.value),
	        preventDuplicates: false
		});
		
		$("#reCc").tokenInput("/mail/address_mail_json_t.jsp?addressbook=1&users=1&mail_autocomplete=1&mail_form=1&mail_representation=1",
		{
			queryParam : "searchValue",
			hintText: "Enter Name Here",
	        noResultsText: "No Results Found",
	        searchingText: "Loading...",
			theme: "facebook",
			animateDropdown: false,
            onAdd: function (item) {
//           	alert("Added " + item.name);
			},
            onDelete: function (item) {
            	var arr = new Array();
        		for (var i = 0; i < objRecipients.length; i++) {
        			var objAddress = objRecipients[i];
        			var strAddress = "";
    				var personal = "";
    				if (objAddress.personal == null || objAddress.personal == "") {
    					personal += objAddress.address;
    				} else {
    					personal += objAddress.personal;
    				}
    				if(personal!=objAddress.address){
    					strAddress = personal + " " + objAddress.address;
    				}else{
    					strAddress = objAddress.address;
    				}
        			if(strAddress==item.name) continue;
        			arr.push(objRecipients[i]);
        		}
        		objRecipients = new Array();
        		for (var i = 0; i < arr.length; i++) {
        			objRecipients.push(arr[i]);
        		}
//           	alert("Deleted " + item.name);
            },
            onResult: function (results) {
            	$.each(results, function (index, value) {
                	var recNm = value.name;
    				if(value.name == "") recNm = value.value; 
    				var id = "\"" + recNm + "\" <" + value.value+">";
                	value.id = id;
                	value.name = value.search;
                });
                return results;
			}, 
            prePopulate: getData(fmMail.cc.value),
	        preventDuplicates: false
		});
		
		$("#reBcc").tokenInput("/mail/address_mail_json_t.jsp?addressbook=1&users=1&mail_autocomplete=1&mail_form=1&mail_representation=1",
		{
			queryParam : "searchValue",
			hintText: "Enter Name Here",
	        noResultsText: "No Results Found",
	        searchingText: "Loading...",
			theme: "facebook",
			animateDropdown: false,
            onAdd: function (item) {
//           		alert("Added " + item.name);
			},
            onDelete: function (item) {
            	var arr = new Array();
        		for (var i = 0; i < objRecipients.length; i++) {
        			var objAddress = objRecipients[i];
        			var strAddress = "";
    				var personal = "";
    				if (objAddress.personal == null || objAddress.personal == "") {
    					personal += objAddress.address;
    				} else {
    					personal += objAddress.personal;
    				}
    				if(personal!=objAddress.address){
    					strAddress = personal + " " + objAddress.address;
    				}else{
    					strAddress = objAddress.address;
    				}
        			if(strAddress==item.name) continue;
        			arr.push(objRecipients[i]);
        		}
        		objRecipients = new Array();
        		for (var i = 0; i < arr.length; i++) {
        			objRecipients.push(arr[i]);
        		}
//           		alert("Deleted " + item.name);
            },
            onResult: function (results) {
            	$.each(results, function (index, value) {
                	var recNm = value.name;
    				if(value.name == "") recNm = value.value; 
    				var id = "\"" + recNm + "\" <" + value.value+">";
                	value.id = id;
                	value.name = value.search;
                });
                return results;
			}, 
            prePopulate: getData(fmMail.bcc.value),
	        preventDuplicates: false
		}); 

		if (<%=mailPercent%> == 100) {
			alert("메일용량이 초과되었습니다.");
			location.href= history.back();
		}
		document.getElementById("mailbody").value("dkjfdkjf");
	
		<%if(!isIE){%>
		//본문 -----------------------------------------
		var dspBody = document.getElementById("dspbody");
		
		var strMailBody = dspBody.innerText; //본문내용
		var strSignature = document.getElementById("dissignature").innerText; //개인서명
		
		document.getElementById("dissignature").innerHTML = strSignature; //개인서명
	//	document.getElementById("dspbody").innerHTML = strMailBody; //본문내용
		
	
		var expData = document.getElementById("expData").innerHTML;	//외부 문서 본문 로드 - 연결
		if (expData == null) expData = "";
		
		$("#dspbody").find('img[id=nekrecchk]').remove();
		<%}%>
		
		<%	if (envelope == null) { %>	
			<%if(!isIE){%>
		Editor.modify({
			"content": dspBody.innerHTML + "<br>" + expData + "<BODY><span id='fmpaper'></span><span id='fmsign'>" + document.getElementById("dissignature").innerHTML + "</span>" /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
		});
			<%} %>
		<%	} else { %>
			<%if(!isIE){%>
			Editor.modify({
				"content": dspBody.innerHTML /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
			});
			<%} %>
		<%	} %>
	
		$('#reserved_date').datepicker({
			showAnim: "slide",
			showOptions: {
				origin: ["top", "left"] 
			},
			monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
			dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
			dateFormat: 'yy-mm-dd',
			buttonText: 'Calendar',
			prevText: '이전달',
			nextText: '다음달',
			//showOn: 'both',
			altField: "#alternate",
			altFormat: "DD, d MM, yy",
			changeMonth: true,
			changeYear: true,
			showOtherMonths: true,
			selectOtherMonths: true,
			
			beforeShow: function() {
			}
		});
		
	});
	
	function setMailPaper(){
		var selObj = document.getElementById("selPaper");
		var docId = selObj.options[selObj.selectedIndex].value;
		if(docId==""){
			document.getElementById("dspbody").innerHTML = Editor.getContent();;
			$("#dspbody").find('span[id=fmpaper]').html("");
			
			Editor.modify({
				"content": document.getElementById("dspbody").innerHTML
			});
			return;
		}
		$.ajax({
			url: "./mail_paper_data.jsp?docid=" + docId,
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
 		    	var result = $.trim(data);

				document.getElementById("dspbody").innerHTML = Editor.getContent();
				$("#dspbody").find('span[id=fmpaper]').html(result);
				
				Editor.modify({
					"content": document.getElementById("dspbody").innerHTML
				});
		    }
		});
	}
	</script>
</head>
<body>
<div data-role="page" id="page-list">
	<div data-role="header" data-theme="b">
		<h2>Mobile Groupware</h2>
		<a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">Home</a>
		<a href="/mobile/nav.jsp" data-icon="search" data-rel="dialog" data-transition="fade" data-iconpos="right">Menu</a>
	</div>
	
	<div data-role="content">
	
	<form name="fmMail" id="fmMail" method="post" action="mail_send.jsp" enctype="multipart/form-data" onsubmit="return false;">
		<input type="hidden" name="cmd" value="<%=cmd%>">
		<input type="hidden" name="box" value="<%=mailboxID%>">
		<input type="hidden" name="pg" value="<%=pageNo%>">
		<input type="hidden" name="searchtext" value="<%=searchText%>">
		<input type="hidden" name="searchtype" value="<%=searchType%>">
		<input type="hidden" name="to" value="<%=HtmlEncoder.encode(to)%>">
		<input type="hidden" name="cc" value="<%=HtmlEncoder.encode(cc)%>">
		<input type="hidden" name="bcc" value="<%=HtmlEncoder.encode(bcc)%>">
		<input type="hidden" name="message_name" value="<%=messageName%>">
		<input type="hidden" name="reserved_dt" value="">
		<input type="hidden" name="mailbodysave" value="">
		<input type="hidden" name="mailbody" value="">
		<input type="hidden" name="maildoc" value="">
		<input type="hidden" name="browser" value="">
		<input type="hidden" name="filepath" value="mail"><!-- HTML5 uploadpath -->
		<input type="hidden" name="isfiles" value=""><!-- HTML5 upload check -->
		<input type="hidden" name="isdms" value="">
		<%=attachDiv %>
		<jsp:include page="/common/progress.jsp" flush="true">
		    <jsp:param name="ctype" value="1"/>
		</jsp:include>
		<div data-role="fieldcontain">
			<label for="reTo">받는사람</label>
			<div class="ui-input-text ui-shadow-inset ui-corner-all ui-btn-shadow ui-body-c" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_to" id="reTo" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="reCc">참조인</label>
			<div class="ui-input-text ui-shadow-inset ui-corner-all ui-btn-shadow ui-body-c" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_cc" id="reCc" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="reBcc">비밀참조인</label>
			<div class="ui-input-text ui-shadow-inset ui-corner-all ui-btn-shadow ui-body-c" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_bcc" id="reBcc" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="file"><fmt:message key="t.attached"/></label>
			<input data-mini="true" type="file" name="file" id="file" value="">
		</div>
		<div data-role="fieldcontain">
			<label for="subject"><fmt:message key="mail.subject"/></label>
			<input data-mini="true" type="text" name="subject" id="subject" value="">
		</div>
		<div data-role="fieldcontain">
			<label for="txtContent">본문</label>
			<textarea data-mini="true" cols="40" rows="8" name="txtContent" id="txtContent" style="height: 7em;"></textarea>
		</div>
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup">
			    <legend>옵션</legend>
			    <input data-mini="true" type="checkbox" name="saveaftersent" id="saveaftersent" checked="">
			    <label for="saveaftersent"><fmt:message key="mail.save.afterSend"/></label>
			    <input data-mini="true" type="checkbox" name="chkreceipt" id="chkreceipt" checked="" onclick="OnClickCheckReceipt()">
			    <label for="chkreceipt"><fmt:message key="mail.received.check"/></label>
			    <input data-mini="true" type="checkbox" name="importance" id="importance">
			    <label for="importance"><fmt:message key="t.hot"/></label>
			</fieldset>
		</div>
		<div data-role="fieldcontain">
		    <a onclick="OnClickSend()" href="#" data-mini="true" data-role="button" data-icon="check" data-theme="b" data-inline="true"><fmt:message key="mail.btn.send"/></a>
		    <a onclick="OnClickDraft()" href="#" data-mini="true" data-role="button" data-icon="check" data-theme="c" data-inline="true"><fmt:message key="mail.btn.save"/></a>
		</div>
	</form>
	</div>

	<div data-role="footer" class="footer-docs ui-bar" data-theme="b">
		<a href="javascript:history.back()" data-ajax='false' data-icon="arrow-l">Back</a>
		<a href="javascript:location.reload()" data-ajax='false' data-icon="refresh">Reload</a>
		<a href="/mobile/logout.jsp" data-ajax='false' data-rel="dialog" data-icon="delete" data-iconpos="right" style="float:right;">Logout</a>
	</div>
</div>
</body>
</fmt:bundle>
</html>
