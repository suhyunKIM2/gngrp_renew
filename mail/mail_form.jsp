<%@page import="org.apache.commons.lang.StringUtils"%>
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
<%@ page import="org.json.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.select.Elements" %>
<%@ page import="org.jsoup.nodes.Element" %>
<%@ page import="org.jsoup.nodes.Document" %>

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
	String sCmd 		= pp.getStringParameter("scmd", "");
	String reSend		= pp.getStringParameter("reSend", "");	//재발신시 서명제거하기위한 FLAG
	String mailto	= pp.getStringParameter("mailto", "");	//주소록정보에서 메일작성 선택시 받는사람 자동입력 2016-03-29 대현

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
	HashMap<String, String> receive_map = null;
	
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
    boolean isNotFile = false;
    boolean isReceive = false;
	try {
		con = db.getDbConnection();
		
		cfItem = ConfigTool.getConfigValue(con, application.getInitParameter("CONF.HOME_PATH"));
		homePath = cfItem.cfValue;
		if (!homePath.endsWith("/")) homePath += "/";


		
		cfItem = ConfigTool.getUserConfigValue(con, loginuser.uid, "ISMAILRECEIVE");
		isReceive = Boolean.parseBoolean(cfItem.cfValue);

		if (messageName.length() > 0) {
			envelope = repository.retrieve(con, loginuser.emailId, messageName, domainName);

			if (envelope.getNek_msgid() != null && !envelope.getNek_msgid().equals(""))
				receive_map = repository.getRecipientsMail(con, envelope.getNek_msgid());
		}
		signature = repository.getSignature(con, loginuser.uid);
		comsignature = repository.getComSignature(con);
		//메일 사용 여부 체크
		mailUseChk = repository.getUserMailChk(con, loginuser.uid);
		
		//편지지 목록
		//paperList = repository.getPaperlist(con);
	} catch (java.io.FileNotFoundException e) {
		isNotFile = true;
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}
	
	if(isNotFile){
		String message = msglang.getString("mail.not.original");	/*원본 파일이 존재하지 않습니다.*/
		out.print("<script src=\"/common/scripts/parent_reload.js\"></script>");
		out.print("<script>alert('"+message+"');closeWindow();</script>");	
		return;
	}
	
	//메일 사용 권한이 없다면 작성하지 못하도록 한다.
	if (mailUseChk){
		String message = msglang.getString("mail.nohave.write");	/*작성할 권한이 없습니다.*/
		out.print("<script src=\"/common/scripts/parent_reload.js\"></script>");
		out.print("<script language='javascript'>alert('"+message+"');");
		out.print("try { closeWindow(); } catch(ex) { window.open('', '_self', '').close(); }");
		out.print("</script>");
		//out.close();
		return;
	}

	SimpleDateFormat format_today = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	String logString = format_today.format(new java.util.Date());
// 	if (!"new".equals(cmd)) {
// 		System.out.println("["+logString+"]  FORM - ");
// 		System.out.println("["+logString+"]  FORM - cmd: " + cmd);
// 		System.out.println("["+logString+"]  FORM - user-agent: " + request.getHeader("user-agent"));
// 		System.out.println("["+logString+"]  FORM - Sender: " + loginuser.nName + "/" + loginuser.upName + "/" + loginuser.dpName + "/" + loginuser.uid + " ("+email+")");
// 		System.out.println("["+logString+"]  FORM - message_name: " + envelope.getNek_msgid());
// 	}
	
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
						Document doc = Jsoup.parse(body);
						Elements row = doc.select("img[src=cid:" + cid + "]");
						String chStr = "/mail/mail_dn_attachment.jsp?message_name=" + messageName + "&path=" + attachment.getPath();
						for(Element row2 : row){
							row2.attr("src", chStr);
						} 
						body = doc.html();
						//2013-02-08 가람시스템 본문 이미지만 제외함.
// 						if(cid.indexOf("GARAMSYSTEM")==-1){
							// TODO 정규표현을 이용하는 방안을 함 생각해보자 
// 							int start = body.indexOf("cid:" + cid);
// 							if (start == -1) {
// 								start = body.indexOf("CID:" + cid);
// 							}
// 							if (start != -1) {
// 								body = new StringBuffer()
// 									.append(body.substring(0, start))
// 									.append("/mail/mail_dn_attachment.jsp?message_name=")
// 									.append(messageName)
// 									.append("&path=")
// 									.append(attachment.getPath())
// 									.append(body.substring(start + cid.length() + 4))
// 									.toString();
// 							}
// 						}
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
// 			senders = FromToString(mimeFrom, envelope.getReplyRecipients());
			senders = envelope.getRecipients(Message.RecipientType.TO, email);
		}catch(Exception e){}


// 		if (!"new".equals(cmd)) {
// 			System.out.println("["+logString+"]  FORM - Subject: " + msgSub);
// 		}
		
		if (cmd.equals("reply")) {
			//subject = "RE: " + msg.getSubject();
			subject = "RE: " + msgSub ;
			//to = envelope.getReplyRecipients();
			//to = senders;
			try{
// 				to = envelope.getRecipients(Message.RecipientType.TO);
				to = envelope.getRecipients(Message.RecipientType.TO, email);
				if (to != null) to = to.replaceAll("\'", "");
			}catch(Exception e){
				to = envelope.getRecipients(Message.RecipientType.TO);
				if (to != null) to = to.replaceAll("\'", "");
			}
		} else if (cmd.equals("replyall")) {
			//subject = "RE: " + msg.getSubject();
			subject = "RE: " + msgSub ;
			try{
				to = envelope.getReplyAllRecipients(email);
				if (to != null) to = to.replaceAll("\'", "");
			}catch(Exception e){}
			try{
				cc = envelope.getRecipients(Message.RecipientType.CC, email);
				if (cc != null) cc = cc.replaceAll("\'", "");
			}catch(Exception e){
				cc = envelope.getRecipients(Message.RecipientType.CC);
				if (cc != null) cc = cc.replaceAll("\'", "");
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
			
			if(body.indexOf("<base")>-1){
				body = body.replaceAll("<base","<div");
			}
			
			if(body.indexOf("<BASE")>-1){
				body = body.replaceAll("<BASE","<div");
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

				if (receive_map != null && receive_map.get("receive_to") != null) {
					try {
						JSONArray ja = new JSONArray(receive_map.get("receive_to"));
						for(int i = 0, len = ja.length(); i < len; i++) {
							JSONObject jo = ja.getJSONObject(i);
							if (i != 0) strTo += ", ";
							strTo += jo.getString("toDisplay");
						}
					} catch (JSONException e) {
						e.printStackTrace();
					}
				} else {
					strTo = envelope.getRecipients(Message.RecipientType.TO);
					strTo = envelope.getRecipients(null, email);
					if (strTo != null) strTo = strTo.replaceAll("\'", "");
				}
				
			}catch(Exception e){
				strTo = "UNKNOWN";
			}
			String strCc = "";
			try{

				if (receive_map != null && receive_map.get("receive_cc") != null) {
					try {
						JSONArray ja = new JSONArray(receive_map.get("receive_cc"));
						for(int i = 0, len = ja.length(); i < len; i++) {
							JSONObject jo = ja.getJSONObject(i);
							if (i != 0) strCc += ", ";
							strCc += jo.getString("toDisplay");
						}
					} catch (JSONException e) {
						e.printStackTrace();
					}
				} else {
					strCc = envelope.getRecipients(Message.RecipientType.CC);
					strCc = envelope.getRecipients(Message.RecipientType.CC, email);
					if (strCc != null) strCc = strCc.replaceAll("\'", "");
				}
			}catch(Exception e){
				strCc = envelope.getRecipients(Message.RecipientType.CC, email);
				if (strCc != null) strCc = strCc.replaceAll("\'", "");
			}
			body = new StringBuffer()
					.append("<p><br><br></p>\n<span id='fmsign'></span><span id='fmcomsign'></span><div><hr><div>------------------ Original Message ------------------</div>"
						+ "<div id='req'>"
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
		
		Collection attachments = envelope.getAttachments();
		if (attachments != null) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment)iter.next();
				String cid = attachment.getContentID();
				//일부 확장자는 표시되도록 함(예외인경우)
				String fileExt = "";
				String fileName = attachment.getFileName();
				if(fileName.lastIndexOf(".")>-1){
					fileExt = fileName.substring(fileName.lastIndexOf(".")+1, fileName.length());
				}
				if (!cmd.startsWith("reply")) {	//전달인경우
					
				}else{	//회신인경우
					if (cid != null) {		//이미지만 보여준다.
						String[] passList = new String[]{"docx","doc","pptx","ppt","xlsx","xls","pdf","hwp"};
						boolean isCheck = false;
						for(String item : passList) {
							if (item.equals(fileExt)) {
								isCheck = true;
							}
						}
						if(isCheck){
							continue;
						}
					}else{
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
		
		//본문 이미지 별도 처리
		attachments = envelope.getAttachments();
		if (attachments != null) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment)iter.next();
				String cid = attachment.getContentID();
				if (cid != null) {	
					//2013-02-08 가람시스템 본문 이미지만 제외함.
// 					if(cid.indexOf("GARAMSYSTEM")>-1){
						attachDiv  += "<input type='hidden' name='imghid' value='message_name=" + envelope.getMessageName() +"&path=" + attachment.getPath() + "／" + attachment.getFileName() +"'>";
// 					}
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
// 	if(paperList !=null){
// 		selectPaper = "<select id='selPaper' style='width:150px;' onchange='setMailPaper()'><option value=''>편지지 선택</option>";
// 		for(int a=0;a<paperList.size();a++){
// 			MailPaperInfo item = (MailPaperInfo)paperList.get(a);
// 			selectPaper += "<option value='" + item.getDocId() + "'>" + item.getSubject() + "</option>";
// 		}
// 		selectPaper += "</select>";
// 	}
	
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
<title><fmt:message key="mail.title" /></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" type="text/css" href="<%=imgCssPath %>">
<script src='/common/libs/json-js/json2.js' type="text/javascript"></script>
<script src="./js/garamtagit.js"></script>
<style>
.mouseOut { background: #708090; color: #FFFAFA; }
.mouseOver { background: #FFFAFA; color: #000000; }
.ui-autocomplete-loading { background: white url('/common/images/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete { max-height: 300px; overflow: auto; }
.ui-autocomplete li { white-space: nowrap; }
* html .ui-autocomplete { height: 300px; }
.blue { color: blue; font-weight: bold; }
ul.autocompleteTag { list-style-type: none; margin: 0; padding: 0; }
ul.autocompleteTag li { display: inline-block; }
</style>
<script language="javascript">
var strDomain = "<%=application.getInitParameter("nek.mail.domain")%>";
<%	if (!uservariable.userDomain.equals("")) { %>
strDomain = "<%=uservariable.userDomain%>";
<%	} %>

//개인서명 적용여부 체크
function OnPersonSign(){
	var form = document.forms[0];
	var obj;
	<%if(isIE){%>
	var webEdit = document.getElementById("twe");
	obj = webEdit.GetDOM();
	<%}else{%>
	var ifrm = document.getElementById("tx_canvas_wysiwyg");
	if(ifrm!=null){
		var y = (ifrm.contentWindow || ifrm.contentDocument);
		obj = y.document;
	}else{
		obj = document;
	}
	<%} %>

	var dissignaturetxt = $("#dissignature").text() || "";
// 	if (dissignaturetxt.indexOf("</P>") == -1) { dissignaturetxt = $("#dissignature").html(); }
	
	//서명 체크
	if( $("input:checkbox[name=chkPerSign]").is(":checked")) {
		if($(obj).find("span[id=fmsign]").length<1){	//서명태그가 삭제된경우
			var tmp = $(obj).find("span:contains('-- Original Message --')");
			if(tmp.length==0){
				tmp = $(obj).find("p:contains('-- Original Message --')");
			}
			
			try{
				$(tmp).before($('<span id="fmsign">' + dissignaturetxt + '</span>' ) );
			}catch(e){
				var str = tmp.html();
				tmp.html("<br><span id='fmsign'>" + dissignaturetxt + "</span></P><p>" + str);
			}
		}else{
			$(obj).find("span[id=fmsign]").html(dissignaturetxt);
		}
	}else{
		$(obj).find("span[id=fmsign]").html("");
	}
}

function bodyParse() {
	
}

function OnClickSend() {
	//수신자중 (To) 체크 -------------------------------------------------
	var nToCount = 0;
	document.fmMail.to.value = document.fmMail.receive_to.value || "";
	document.fmMail.cc.value = document.fmMail.receive_cc.value || "";
	document.fmMail.bcc.value = document.fmMail.receive_bcc.value || "";
		
	if (document.fmMail.to.value == "") {
		alert("<fmt:message key='mail.c.recipient.MoreThenOne'/>");//수신자가 한명 이상 있어야 합니다!
		return;
	}
	
	if (document.fmMail.to.value.indexOf(";") > -1) {
		alert("<fmt:message key='mail.no.semicolon'/>");	//수신자 주소에 세미콜론(;)을 사용할 수 없습니다.
		return;
	}
	
	if (document.fmMail.cc.value.indexOf(";") > -1) {
		alert("<fmt:message key='mail.no.semicolon'/>");	//수신자 주소에 세미콜론(;)을 사용할 수 없습니다.
		return;
	}
	
	if (document.fmMail.bcc.value.indexOf(";") > -1) {
		alert("<fmt:message key='mail.no.semicolon'/>");	//수신자 주소에 세미콜론(;)을 사용할 수 없습니다.
		return;
	}

	if (TrimAll(fmMail.subject.value) == "") {
		alert("<fmt:message key='v.subject.required'/>");	//제목을 입력하여 주십시요!
		fmMail.subject.focus();
		return;
	}		

	//Recipients 달기 ---------------------------------------------------
	
	if (document.fmMail.chkreceipt.checked) {
		document.fmMail.saveaftersent.checked = true;
	}

	if (document.fmMail.reserved.checked)
	{
		var reservedDate = GetJavaScriptDate(document.fmMail.reserved_date.value);
		var hour = document.fmMail.reserved_hour.selectedIndex;
		var min = document.fmMail.reserved_min.selectedIndex * 10;

		reservedDate.setHours(hour);
		reservedDate.setMinutes(min);
		reservedDate.setSeconds(0);
		reservedDate.setMilliseconds(0);

		if (reservedDate < new Date())
		{
			alert("<fmt:message key='mail.reservation.notbo.earlier'/>"); //예약일시는 현재 시각보다 이전일 수 없습니다!
			return;
		}
		document.fmMail.reserved_dt.value = reservedDate.getTime();
	}
	
	if(!confirm("<fmt:message key='mail.c.send.mail'/>")) return false;//메일을 발송하시겠습니까?
	
	//진행 상태바
	var pgObj = document.getElementById("myid");
	pgObj.style.zIndex = "9999";
 	pgObj.style.display = "";

	var mailNewDoc = "Mail"  + "<%=loginuser.uid%>"+<%=System.currentTimeMillis()%>;
	fmMail.maildoc.value = mailNewDoc;
	
	//bodyParse();
	
	// 아래 부분을 정리 함.
	$("#dspbody").html( geteditordata() );

	$("#dspbody").find('span[id=fmsign]').removeAttr("id");
	$("#dspbody").find('div[id=fmsign]').removeAttr("id");
	$("#dspbody").find('span[id=fmcomsign]').removeAttr("id");
	
	
	//본문
	<%if(isIE){%>
//		document.getElementById("dspbody").innerHTML = document.getElementById("twe").HtmlValue;
		
//		$("#dspbody").find('span[id=fmsign]').removeAttr("id");
//		$("#dspbody").find('div[id=fmsign]').removeAttr("id");
//		$("#dspbody").find('span[id=fmcomsign]').removeAttr("id");
		
		// tagfree 마임값 추출 용
		document.getElementById("twe").HtmlValue = $("#dspbody").html();
		fmMail.mailbody.value = document.getElementById("twe").MimeValue() || '';
		fmMail.browser.value = "IE";
	<%}else{%>
//		setEditorForm();
		
//		document.getElementById("dspbody").innerHTML = document.getElementById("txtContent").value;
		
//		$("#dspbody").html( geteditordata() );
		//$("#dspbody").find('span[id=fmsign]').removeAttr("id");
		//$("#dspbody").find('div[id=fmsign]').removeAttr("id");
		//$("#dspbody").find('span[id=fmcomsign]').removeAttr("id");
		
		fmMail.mailbody.value = $("#dspbody").html() || '';
	<%}%>

	//fmMail.mailbodysave.value = document.getElementById("twe").BodyValue; /* document.all.Wec.Value; */
	//fmMail.mailbody.value = document.getElementById("twe").MimeValue();/* document.all.Wec.MIMEValue */

	var uploader = document.getElementById("Uploader");
	if (uploader){
		if (uploader.Submit(fmMail)) {
			var loc = uploader.Location;
			if (loc == "") {
				//document.write(uploader.Response);
				//새창 열었을때 response 값이 필요없다. 바로 window 닫아준다.
				try{
					parent.opener.location.reload();
				}catch(ex){
					window.close();
				}
				window.close();
			} else {
				document.location.href = loc;
			}
		}
	}else{
		$(window).unbind("beforeunload");
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
	}
	
	return false;
}

//메일본문 에디터 설정 건 - override 메일용
function SetEditorData(objEditor, contentId) {
	var dspBody = document.getElementById("dspbody");

// 	var strMailBody = $("#dspbody").text(); //본문내용
	//var strSignature = $("#dissignature").text(); //개인서명 : html 그대로 들어가야 함. 주석처리 2014.09.03 jkkim
	
// 	$("#dspbody").html(strMailBody); //본문내용
	//$("#dissignature").html(strSignature);		//html 그대로 들어가야 함. 주석처리 2014.09.03 jkkim
	
	var bodyData = "";
		
	var expData = $("#expData").html();	//외부 문서 본문 로드 - 연결
	if (expData == null) expData = "";

	$("#dspbody").find('img[id=nekrecchk]').remove();
	
	<%if (envelope == null) { %>	
		<%if(!isIE){%>
			//bodyData = $("#dspbody").html() + expData + "<BODY><P>&nbsp;</P>\n<div id='fmsign'>" + $("#dissignature").html() + "</div>" ;
			bodyData = $("#dspbody").html() + expData + "<P>&nbsp;</P><br><div id='fmsign'>" + $("#dissignature").text() + "</div>" ;

		<%} %>
	<%} else { %>
		<%if(!isIE){%>
			bodyData = decodeEntities($("#dspbody").html()) || '';
		<%} %>
		<%if(!(mailboxID==3 || !reSend.equals("")) ){%><%-- 임시저장인경우 서명을 제외한다. --%>
			setTimeout( function() {
				$("#chkPerSign").attr("checked", "checked");
				//$("#chkPerSign").click();
				OnPersonSign();
			}, 1000);
		<%} %>
	<%} %>

	if( bodyData == "" ) return;
	
	if( getEditorName() == "twe" ) {
		objEditor.HtmlValue = bodyData;
	} else if( getEditorName() == "xfree" ) {
		objEditor.setHtmlValue( bodyData );
	} else {
		objEditor.modify({ content: bodyData });
	}
}

//firefox 
function decodeEntities(encodedString) {
	var textArea = document.createElement('textarea');
	textArea.innerHTML = encodedString;
	return textArea.value;
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
    if (document.fmMail.reserved.checked){
        if (!confirm("<fmt:message key='mail.tmp.cancel.save'/>")) return ;////임시저장시에는 예약발송을 해제해야합니다 \n\n해제후 계속 진행하시겠습니까?
        document.fmMail.reserved.checked = false ; 
    }
	//수신자중 (To) 체크 -------------------------------------------------
	var nToCount = 0;
	document.fmMail.to.value = document.fmMail.receive_to.value;
	document.fmMail.cc.value = document.fmMail.receive_cc.value;
	document.fmMail.bcc.value = document.fmMail.receive_bcc.value;
	
// 	if (document.fmMail.to.value == "") {
// 		alert("<fmt:message key='mail.c.recipient.MoreThenOne'/>");//수신자가 한명 이상 있어야 합니다!
// 		return;
// 	}

	if(TrimAll(fmMail.subject.value) == "") {
		fmMail.subject.value = "<fmt:message key='mail.subject.untitled'/>";	//제목없음
// 		alert("<fmt:message key='v.subject.required'/>"); //제목을 입력하여 주십시요!
// 		return;
	}

	var conf_tmpMsg = "<fmt:message key='c.save.temp'/>"; //임시저장 하시겠습니까?
	if (!confirm(conf_tmpMsg)) return;
	
	//임시저장임을 알림
	document.forms[0].cmd.value = "draft";
	
	var mailNewDoc = "Mail"  + "<%=loginuser.uid%>" + "_"+<%=System.currentTimeMillis()%>;

	//본문
	<%if(isIE){%>
	fmMail.mailbody.value = document.getElementById("twe").MimeValue() || '';
	fmMail.browser.value = "IE";
	<%}else{%>
	//setEditorForm();
	
	//fmMail.mailbody.value = document.getElementById("txtContent").value || '';
	fmMail.mailbody.value = geteditordata() || '';
	<%}%>

	
	//새로 첨부된 파일이 있으면 업로더를 통해서 Submit
	var uploader = document.getElementById("Uploader");
	if (uploader){		
		if (uploader.Submit(fmMail)) {
			var loc = uploader.Location;
			if (loc == "") {
				//document.write(uploader.Response);
				//새창 열었을때 response 값이 필요없다. 바로 window 닫아준다.
				parent.opener.location.reload();
				window.close();
			} else {
				document.location.href = loc;
			}
		}
	}else{
		if ($('.template-upload') && $('.template-upload').length > 0) {
			document.fmMail.action = "/upload";
			document.fmMail.isfiles.value = "1";
			document.fmMail.fileuploadstartconfirm.value = "0";
			$('.fileupload-buttonbar').find('.start').click();
//				$('button[type=submit]').click();
			return;
		} else { 
			$(window).unbind("beforeunload");
			document.fmMail.submit();
		}
	}
	opener.top.resetLeftCount("3", 1, 0, 'draft');
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
		} else if (objAddress.depttype == "share_group") {
			strAddress += "G:" + objAddress.id + ":" + objAddress.name;
		}
	}else{
		strAddress += "\"";
		if (objAddress.personal == null || objAddress.personal == "") {
			strAddress += objAddress.address;
		} else {
			strAddress += objAddress.personal;
			strAddress = strAddress.replace(/,/g, ""); 
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
		} else if (objAddress.depttype == "share_group") {
			strDisplay += "\"";
			strDisplay += objAddress.name;
			strDisplay += "\"";
		}
	}else{	
		strDisplay += ""; //"\"";
		if (objAddress.personal == null || objAddress.personal == "") {
			strDisplay += objAddress.address;
		} else {
			strDisplay += objAddress.personal;
			strDisplay = strDisplay.replace(/,/g, ""); 
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
/* 
function OnClickAddressBook(nType) {
	var ret = window.showModalDialog("mail_ab.jsp?nType="+nType, objRecipients,"dialogHeight: 430px; dialogWidth: 650px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
	
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
					personal = personal.replace(/,/g, ""); 
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
					personal = personal.replace(/,/g, ""); 
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
 */

function OnClickReserved() {
	var nowDate = new Date();	
	var newDate = new Date(nowDate.getTime()+(60*60*1000));
	
	if (document.fmMail.reserved.checked) {
		document.fmMail.reserved_date.disabled = false;
		document.fmMail.reserved_hour.disabled = false;
		document.fmMail.reserved_min.disabled = false;

		$("input[name=reserved_date]").val(newDate.toDateString());
		$("select[name=reserved_hour]").val(newDate.getHours().lpad());
		$("select[name=reserved_min]").val("00");
	} else {
		document.fmMail.reserved_date.disabled = true;
		document.fmMail.reserved_hour.disabled = true;
		document.fmMail.reserved_min.disabled = true;

		$("input[name=reserved_date]").val(newDate.toDateString());
		$("select[name=reserved_hour]").val("00");
		$("select[name=reserved_min]").val("00");
	}
}

function OnClickList() {
/*
	document.fmMail.method = "get";
	document.fmMail.action = "mail_list.jsp";
	document.fmMail.submit();
*/
	if(confirm("<fmt:message key='c.unsaveClose'/>")){ ////현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.
		//window.close();
		closeDoc();
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


var arrDocs = new Array();

//window.showModalDialog Version
function OnClickDmsAttachModal() {
	var winwidth = "600";
	var winheight = "400";
	var url = "/dms/attachList.htm";
	var opt = "status:no;scroll:no;center:yes;help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px";
	
	returnValue = window.showModalDialog(url, window, opt);
	if (returnValue != null) {
		arrDocs = new Array();
		for(var i = 0; i < returnValue.length; i++) {
			arrDocs.push(returnValue[i]);
		}
		setDmsAttachInfo(arrDocs);
	}
}

//dhtmlmodal Version
function OnClickDmsAttach() {
	var url = "/dms/attachList.htm";
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_DMS1002", "iframe", url, "<fmt:message key="main.E-mail"/>", 
		"width=600px,height=400px,resize=0,scrolling=1,center=1", "recal"
	);
}

//(window.showModalDialog Version)
function OnClickAddressBookModal(nType) {
	var url = "mail_ab.jsp?nType=" + nType;
	var opt = "dialogHeight: 430px; dialogWidth: 650px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no";
	var ret = window.showModalDialog(url, objRecipients, opt);
	setRecipients(ret);
}

//(dhtmlmodal Version)
function OnClickAddressBook(nType) { 
	var url = "mail_ab.jsp?nType=" + nType;
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_MAIL1001", "iframe", url, "<fmt:message key='mail.email'/>",	/*전자메일*/ 
		"width=650px,height=430px,resize=0,scrolling=1,center=1", "recal"
	);
}

function getDmsAttachInfo() {
	return arrDocs;
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
	    
	    		
	    delBtn = '<button onclick="deleteDmsInfo(\'' + dmsDoc.docId + '\', \'' + dmsDoc.fileNo +'\')" '
	    		+ 'class="btn btn-warning ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" '
	    		+ 'aria-disabled="false"><span class="ui-button-icon-primary ui-icon ui-icon-cancel"></span>'
	    		+ '<span class="ui-button-text"><i class="icon-ban-circle icon-white"></i><span>Cancel</span></span></button>';
	    
	    var fileSizeNumber = 0;
	    try { fileSizeNumber = parseInt(dmsDoc.fileSize); } catch (e) {}
	    
	    //row 추가
	    var newCell = null;

	    newCell = newTR.insertCell(0);
	    newCell.className = "delete";
// 	    newCell.align = "center" ;
// 	    newCell.style.height = "23px";
// 	    newCell.style.textAlign = "right";
	    newCell.innerHTML = "";
	    
	    newCell = newTR.insertCell(1);
	    newCell.className = "name";
	    newCell.innerHTML = dmsDoc.fileName + hidStr;
	    
	    newCell = newTR.insertCell(2);
	    newCell.className = "size";
	    newCell.innerHTML = formatFileSize(fileSizeNumber);
	    
	    newCell = newTR.insertCell(3);
	    newCell.className = "cancel";
	    newCell.innerHTML = delBtn ;
	}
}

function formatFileSize(bytes) {
    if (typeof bytes !== 'number') {
        return '';
    }
    if (bytes >= 1000000000) {
        return (bytes / 1000000000).toFixed(2) + ' GB';
    }
    if (bytes >= 1000000) {
        return (bytes / 1000000).toFixed(2) + ' MB';
    }
    return (bytes / 1000).toFixed(2) + ' KB';
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
<%-- 
<!-- 나모웨에디터 로딩 이후 함수 수행  -->
<SCRIPT language="Javascript" FOR="Wec" EVENT="OnInitCompleted()">
	if(<%=mailPercent%>==100){
		alert("메일용량이 초과되었습니다.");
		location.href= history.back();
	}
	document.fmMail.edit_recipient.focus();
	editor_init();
</SCRIPT>
 --%>
	<!-- 프리태그 로딩 이후 함수 수행 -->
<script language="JScript" FOR="twe" EVENT="OnControlInit">
	if (<%=mailPercent%> == 100) {
		alert("<fmt:message key='mail.capacity'/>");	/*메일용량이 초과 되었습니다.*/
		location.href= history.back();
	}

	//본문 -----------------------------------------
	var dspBody = document.getElementById("dspbody");
	
	var strMailBody = dspBody.innerText; //본문내용
	var strSignature = document.getElementById("dissignature").innerText; //개인서명
// 	document.getElementById("dissignature").innerHTML = strSignature; //개인서명
	//	dspBody.innerHTML = strMailBody; //본문내용
	
	var expData = document.getElementById("expData").innerHTML;	//외부 문서 본문 로드 - 연결
	if (expData == null) expData = "";
	
	<%	if (envelope == null) { %>
		document.getElementById("Wec").BodyValue = dspBody.innerHTML + "<br>" + expData + "<BODY><br><span id='fmsign'>" + strSignature + "</span>";
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
					personal = personal.replace(/,/g, ""); 
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
	//datePicker가 ActiveX 에디터에 가려지는 현상을 iFrame 추가해서 가려지지 않도록 구현함.
	function actView(id, type){
		setTimeout(function() {		
	        $("#"+id).before("<iframe id='hideFrame' frameborder='0' scrolling='no' style='filter:alpha(opacity=0); position:absolute; "
                + "left: " + $("#ui-datepicker-div").css("left") + ";"
                + "top: " + $("#ui-datepicker-div").css("top") + ";"
                + "width: " + $("#ui-datepicker-div").outerWidth(true) + "px;"
                + "height: " + $("#ui-datepicker-div").outerHeight(true) + "px;'></iframe>");
	        if(type == "change")  actHide(); 
	    }, 50);
	}
	//iFrame 숨김
	function actHide(){
		$("#hideFrame").remove();
	}

	$(document).ready(function() {

		if (<%=mailPercent%> < 100) {
			$(window).bind("beforeunload", function(event) {
				var msg = new Array();
					msg.push("<fmt:message key='mail.writing.letter'/>");	/*현재 편지를 작성중에 있습니다.*/
					msg.push("<fmt:message key='mail.refresh.lost'/>");	/*새로고침 또는 페이지를 벗어날 경우 내용이 사라집니다.*/
					msg.push("<fmt:message key='mail.tosave.window'/>");	/*저장하려면 메시지 창을 닫은 후 저장버튼을 클릭하세요.*/
				return msg.join("\n\n") + "\n";	
			});
		}

		if (!isiPad()) ActionButtonCopy();
		
		pageScroll();	// page Scroll을 위해 사용. 2013-08-31
		
<%--		
		$("#reTo").tokenInput("/mail/address_mail_json.jsp?addressbook=1&users=1&mail_autocomplete=1&mail_form=1",
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
    					personal = personal.replace(/,/g, "");
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
		
		$("#reCc").tokenInput("/mail/address_mail_json.jsp?addressbook=1&users=1&mail_autocomplete=1&mail_form=1",
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
    					personal = personal.replace(/,/g, "");
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
		/* old
		.tokenInput("/mail/autocomplete_json.jsp",
		{
			queryParam : "names",
		*/
		$("#reBcc").tokenInput("/mail/address_mail_json.jsp?addressbook=1&users=1&mail_autocomplete=1&mail_form=1",
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
    					personal = personal.replace(/,/g, "");
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
--%>

		$('#reTo').garamtagit({ type: 0 });
		$('#reCc').garamtagit({ type: 1 });
		$('#reBcc').garamtagit({ type: 2 });
		

<%
		String rf = "null";
		String rt = "null";
		String rc = "null";
		String rb = "null";
		
		if (envelope != null) {
			if (cmd.equals("reply")) {
			} else if (cmd.equals("replyall")) {
				//전체 회신시 저장한 값을 사용하지 않음.
				
				//rf = envelope.getRecipients(Message.RecipientType.TO, email);
				//rf = envelope.getReplyAllRecipients(email).replaceAll("\'", "").replaceAll("\r", "").replaceAll("\n", "");
				if (receive_map != null) { 
					//rt = receive_map.get("receive_to");
					//rc = receive_map.get("receive_cc");
				}
			} else if (cmd.equals("forward")) {
			} else if (receive_map != null) {
				rt = receive_map.get("receive_to");
				rc = receive_map.get("receive_cc");
				rb = receive_map.get("receive_bcc");
	        }
		}
%>
		var receive_from_str = '<%=rf %>';
		var receive_to_str = <%=StringUtils.defaultIfEmpty(rt, "null") %>;
		var receive_cc_str = <%=StringUtils.defaultIfEmpty(rc, "null") %>;
		var receive_bcc_str = <%=StringUtils.defaultIfEmpty(rb, "null") %>;
		var mailto = '<%=mailto%>';

		// 전체회신시 자신의 이메일은 제외한다.
		if ("replyall" == "<%=cmd %>") {
			if (receive_to_str != null) {
		    	for(var i = 0, len = receive_to_str.length; i < len; i++) {
		    		var obj = receive_to_str[i];
		    		if (obj != null && obj.address == '<%=email %>') {
		    			receive_to_str.splice(i, 1);
		    		}
		    	}
	    	}
		}
		
		if (receive_from_str != "null") {
			$('#reTo').garamtagit("adds", receive_from_str); 
		}
		
		if (receive_to_str != null) {
			$('#reTo').garamtagit("addo", receive_to_str);
		} else {
			if(mailto != null && mailto != ""){
				var m = mailto.split(",");
				fmMail.to.value = "\""+m[1]+"\" <"+m[0]+">";
			}
			$('#reTo').garamtagit("adds", fmMail.to.value);
		}
		
		if (receive_cc_str != null) {
			$('#reCc').garamtagit("addo", receive_cc_str);
		} else {
			$('#reCc').garamtagit("adds", fmMail.cc.value);
		}
		
		if (receive_bcc_str != null) {
			$('#reBcc').garamtagit("addo", receive_bcc_str);
		} else {
			$('#reBcc').garamtagit("adds", fmMail.bcc.value);
		}
		

		if (<%=mailPercent%> == 100) {
			alert("<fmt:message key='mail.capacity'/>");	/*메일용량이 초과 되었습니다.*/
			closeDoc();
		}
	
		
		
		
		<%if(!isIE){%>
		//본문 -----------------------------------------
		var dspBody = document.getElementById("dspbody");
		
		//var strMailBody = dspBody.innerText; //본문내용
		var strMailBody = $("#dspbody").text(); //본문내용
		
		//var strMailBody = $("dspbody").text(tmp1); //본문내용
		//alert( strMailBody );
		//var strSignature = document.getElementById("dissignature").innerText; //개인서명
		var strSignature = $("#dissignature").text(); //개인서명
		
		//document.getElementById("dissignature").innerHTML = strSignature; //개인서명
// 		$("#dissignature").html( strSignature);
		
		//document.getElementById("dspbody").innerHTML = strMailBody; //본문내용
		var strMailBody = $("#dspbody").html(strMailBody); //본문내용
		
		//var expData = document.getElementById("expData").innerHTML;	//외부 문서 본문 로드 - 연결
		var expData = $("#expData").html();	//외부 문서 본문 로드 - 연결
		if (expData == null) expData = "";
		
		$("#dspbody").find('img[id=nekrecchk]').remove();
		<%}%>
		
		<%	if (envelope == null) { %>	
			<%if(!isIE){%>
		//Editor.modify({
// 			"content": dspBody.innerHTML + expData + "<BODY><P>&nbsp;</P>\n<div id='fmsign'>" + document.getElementById("dissignature").innerHTML + "</div>" /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
		//	"content": $("#dspBody").html() + expData + "<BODY><P>&nbsp;</P>\n<div id='fmsign'>" + $("#dissignature").html() + "</div>" /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
		//});
		//xfe.setHtmlValue( $("#dspBody").html() + expData + "<BODY><P>&nbsp;</P>\n<div id='fmsign'>" + $("#dissignature").html() + "</div>" );
			<%} %>
		<%	} else { %>
			<%if(!isIE){%>
			//Editor.modify({
// 				"content": dspBody.innerHTML /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
			//	"content": $("#dspBody").html() /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
			//});
			//xfe.setHtmlValue( $("#dspBody").html() );
			<%} %>
			
			<%if(!(mailboxID==3 || !reSend.equals("")) ){%><%-- 임시저장인경우 서명을 제외한다. --%>
			setTimeout( function() {
				$("#chkPerSign").attr("checked", "checked");
//	 			$("#chkPerSign").click();
				//OnPersonSign();
			}, 1000);
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
			
			onChangeMonthYear: function (year, month, inst) {  
		 		actView(inst.id, "change");
	        },
			beforeShow: function(input, inst) {
				actView(inst.id, "before");
			},
			onClose: function(dateText, inst) {
				actHide();
			},
			onSelect: function (dateText, inst) {  
				actHide();
	        }
		});
		
	});
	
	function ActionButtonCopy() {
		var btnHtml = "<div id='ActionButtonBottom' style='float:right; margin-top:3px;'>" + $("#ActionButton").html() + "</div>";
		var apcmt = $(document.body).append( btnHtml );
	}
	
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

	/*
    function setEditorForm() {
		if(document.getElementById("txtContent")) return;
		var formGenerator = Editor.getForm();
		var content = Editor.getContent();
		
		formGenerator.createField(
				tx.textarea({
					'name': "tx_content", // 본문 내용을 필드를 생성하여 값을 할당하는 부분
					'id': "txtContent",
					'style': { 'display': "none" }
				}, content)
		);
	}
	*/

	Date.prototype.toDateString = function() { d = this.getFullYear() + '-' + (this.getMonth()+1).lpad() + '-' + this.getDate().lpad(); return d; };
	Date.prototype.toTimeString = function() { t = this.getHours().lpad() + ':' + this.getMinutes().lpad() + ':' + this.getSeconds().lpad(); return t; };
	Date.prototype.toString = function() { s = this.toDateString() + ' ' + this.toTimeString(); return s; };
	Number.prototype.lpad = function(l) { l = l || 2; n = this + ''; while(n.length < l) n = '0' +n; return n; };
	
	function autoTempSave() {
		var mailbody = "";
		var tmpCmd = $('input[name=cmd]').val();
		<%	if (isIE) { %>
		$('input[name=browser]').val("IE");
		mailbody = document.getElementById("twe").MimeValue() || '';
		<%	} else { %>
		//setEditorForm();
		//mailbody = document.getElementById("txtContent").value || '';
		mailbody = geteditordata() || '';
		<%	} %>
		$('input[name=mailbody]').val(mailbody);
		$('input[name=cmd]').val("draft");
		$('input[name=to]').val($('input[name=receive_to]').val());
		$('input[name=cc]').val($('input[name=receive_cc]').val());
		$('input[name=bcc]').val($('input[name=receive_bcc]').val());
		var serializeData = $("#fmMail").serialize();
		
		$('input[name=cmd]').val(tmpCmd);
		
	 	$.ajax({ 
	 		  type: 'post'
	 		, url: './mail_send_auto_temp_save.jsp'
	 		, data: serializeData
	 		, beforeSend: function() { 
	 			$('#autoTempSaveMsg').html("<fmt:message key='mail.auto.save'/>");	/*자동 임시 저장중..*/ 
	 		}
	 		, complete: function() { }
	 		, success: function(data, status, xhr) { 
	 			$('input[name=message_name]').val($.trim(data));
	 			$('#autoTempSaveMsg').html("<fmt:message key='mail.auto.save.completion'/>"+"("+new Date().toString()+")");	/*자동 임시저장 완료*/ 
	 		}
	 		, error: function(xhr, status, error) { 
	 			$('#autoTempSaveMsg').html("<fmt:message key='mail.auto.save.failure'/>"+"(" + status + " " + xhr.status + " : " + error + ")");	/*자동 임시저장 실패*/ 
	 		}
	 	});
	}
	
	var autoIntervId = setInterval(autoTempSave, (10 * 60 * 1000));		// 10분마다 자동 임시 저장(반복).
	
	function selfOpenClose() {
		// 현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.
		if (confirm("<fmt:message key='c.unsaveClose'/>")) { 
			window.open('', '_self', '').close();
			return;
		}
	}
	</script>
<jsp:include page="/common/progress.jsp" flush="true">
    <jsp:param name="ctype" value="1"/>
</jsp:include>
</head>
<body style="margin:5px;">

<div id="pageScroll" class="wrapper">

<form name="fmMail" id="fmMail" method="post" action="mail_send.jsp" enctype="multipart/form-data" onsubmit="return false;" onkeyPress="if (event.keyCode==13){return false;}">
	<input type="hidden" name="cmd" value="<%=cmd%>">
	<input type="hidden" name="box" value="<%=mailboxID%>">
	<input type="hidden" name="pg" value="<%=pageNo%>">
	<input type="hidden" name="searchtext" value="<%=searchText%>">
	<input type="hidden" name="searchtype" value="<%=searchType%>">
	<input type="hidden" name="to" value="<%=HtmlEncoder.encode(to)%>">
	<input type="hidden" name="cc" value="<%=HtmlEncoder.encode(cc)%>">
	<input type="hidden" name="bcc" value="<%=HtmlEncoder.encode(bcc)%>">
	<input type="hidden" name="mailbody" value="">
	<input type="hidden" name="message_name" value="<%=messageName%>">
	<input type="hidden" name="reserved_dt" value="">
	<input type="hidden" name="mailbodysave" value="">
	<input type="hidden" name="maildoc" value="">
	<input type="hidden" name="browser" value="">
	<input type="hidden" name="filepath" value="mail"><!-- HTML5 uploadpath -->
	<input type="hidden" name="isfiles" value=""><!-- HTML5 upload check -->
	<input type="hidden" name="isdms" value="">
	<%=attachDiv %>
	<!-- 회신일경우 -->
	<%	if ( messageName.length() > 0 || cmd.equals("reply") || cmd.equals("replyall") ) { %>
	<input type="hidden" name="reply_userName" value="<%=loginuser.emailId %>">
	<input type="hidden" name="reply_messageName" value="<%=messageName %>">
	<input type="hidden" name="reply_domainName" value="<%=domainName %>">
	<%	} %>

<!-- 타이틀 시작 -->

			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="32">
				<tr height="29"> 
					<td width="33"><img src="<%=imagePath %>/sub_img/sub_title_email.jpg" width="27" height="27"></td>
					<td width="150" class="SubTitle" style="font-family:tahoma; font-size:11pt; letter-spacing:0px;"><fmt:message key="mail.title" /><!-- 메일작성--></td>
					
					<td svalign="bottom" width="*" align="right">
<!-- 						<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 							<tr>  -->
<!-- 								<td valign="top" class="SubLocation"> -->
<!-- 									<img src="../common/images/man_info.gif" border=0 align=absmiddle> -->
<%-- 									<a href="javascript:ShowUserInfo('<%=loginuser.uid %>');" class="maninfo"> --%>
<%-- 									<%=loginuser.nName %> / <%=loginuser.dpName %></a> ( <%=format_fullToday.format(today) %> ) --%>
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 						</table> -->
						<span style="display: inline-block;" id="autoTempSaveMsg"></span>
						<span id="ActionButton">
							<a href="#" class="btn btn-icon" onclick="javascript:OnClickSend();">
								<span><span class="icon-mail-send"></span><fmt:message key="mail.btn.send"/><!-- 발송-->
							</span></a>
							<a href="#" class="btn btn-icon" onclick="javascript:OnClickDraft();">
								<span><span class="icon-save"></span><fmt:message key="mail.btn.save"/><!-- 임시저장 -->
							</span></a>
							<a href="#" class="btn btn-icon" onclick="OnClickDmsAttach();">
								<span><span class="icon-save"></span><fmt:message key="mail.edms.attach"/><!-- EDMS 첨부 -->
							</span></a>
							<a href="#" class="btn btn-icon" onclick="javascript:<% if ("NEKIM".equals(sCmd)) { out.print("selfOpenClose()"); } else { out.print("OnClickList()"); } %>;">
								<span><span class="icon-close"></span><fmt:message key="mail.btn.close"/><!-- 닫기 -->
							</span></a>
						</span>
<!-- 						<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 							<tr>  -->
<%-- 								<td valign="top" class="SubLocation"><%= ApprUtil.getNavigation(iMenuId, ma)%></td> --%>
<%-- 								<td align="right" width="15"><img src="<%=imagePath %>/sub_img/sub_title_location_icon.jpg" width="10" height="10"></td> --%>
<!-- 							</tr> -->
<!-- 						</table> -->
					</td>
				</tr>
				<tr height="3">
					<td colspan="3" bgcolor="#eaeaea" style="line-height:0px;"><img align="absmiddle" src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td>
				</tr>
			</table>
<!-- 		</td> -->
<!-- 	</tr> -->
<!-- 	<tr>  -->
<!-- 		<td height="3"></td> -->
<!-- 	</tr> -->
<!-- 	<tr>  -->
<!-- 		<td height="3">  -->
<!-- 			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3"> -->
<!-- 				<tr>  -->
<%-- 					<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td> --%>
<!-- 					<td bgcolor="eaeaea"></td> -->
<!-- 				</tr> -->
<!-- 			</table> -->
<!-- 		</td> -->
<!-- 	</tr> -->
<!-- </table> -->

<!-- 타이틀 끝 -->


<!-- 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" style="display:none;">
	<tr> 
		<td height="27"> 
		
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
				<tr> 
					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_email.jpg" width="27" height="27"></td>
					<td width="100" class="SubTitle" style="font-family:tahoma; font-size:11pt; letter-spacing:0px;"><fmt:message key="mail.title" /><!-- 메일작성--></td>
					<td valign="bottom" width="*" align="right">

						<div style="display: inline-block;" id="autoTempSaveMsg"></div>
						
<!-- 						<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 							<tr>  -->
<!-- 								<td valign="top" class="SubLocation"> -->
<!-- 									<img src="../common/images/man_info.gif" border=0 align=absmiddle> -->
<%-- 									<a href="javascript:ShowUserInfo('<%=loginuser.uid %>');" class="maninfo"> --%>
<%-- 									<%=loginuser.nName %> / <%=loginuser.dpName %></a> ( <%=format_fullToday.format(today) %> ) --%>
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 						</table> -->
						<a href="#" class="btn btn-icon" onclick="javascript:OnClickSend();">
							<span><span class="icon-mail-send"></span><fmt:message key="mail.btn.send"/><!-- 발송-->
						</span></a>
						<a href="#" class="btn btn-icon" onclick="javascript:OnClickDraft();">
							<span><span class="icon-save"></span><fmt:message key="mail.btn.save"/><!-- 임시저장 -->
						</span></a>
						<a href="#" class="btn btn-icon" onclick="OnClickDmsAttach();">
							<span><span class="icon-save"></span><fmt:message key="mail.edms.attach"/><!-- EDMS 첨부 -->
						</span></a>
						<a href="#" class="btn btn-icon" onclick="javascript:<% if ("NEKIM".equals(sCmd)) { out.print("selfOpenClose()"); } else { out.print("OnClickList()"); } %>;">
							<span><span class="icon-close"></span><fmt:message key="mail.btn.close"/><!-- 닫기 -->
						</span></a>
						
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="display:none; position:relative;top:1px">
				<tr> 
					<td width="*">&nbsp;</td>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickSend();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<fmt:message key="mail.btn.send"/>&nbsp;<!-- 발송 --></span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="1">&nbsp;</td>
					<td width="85"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickDraft();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<fmt:message key="mail.btn.save"/>&nbsp;<!-- 임시저장 --></span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="1">&nbsp;</td>
					<td width="80"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickList()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma03','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<fmt:message key="mail.btn.close"/>&nbsp;<!-- 닫기 --></span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
					</td>
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
					<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td>
					<td bgcolor="eaeaea"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 타이틀 끝 -->

<table><tr><td class=tblspace03></td></tr></table>
			
<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td align="right"> 

		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->

			<!-- 메일 발송 옵션 -->
			<%
				if (envelope == null) {
			%>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td>
						<input type="checkbox" name="saveaftersent" checked style="display:none;">
						<%-- <fmt:message key="mail.save.afterSend"/>&nbsp;<!-- 발송후 저장 -->&nbsp;|&nbsp; <!-- 발송후 저장이 기본설정으로 변경 2013-08-02 --> --%>
						
						<input type="checkbox" name="chkreceipt" onclick="OnClickCheckReceipt()" <%=(isReceive) ? "checked" : "" %>><fmt:message key="mail.received.check"/>&nbsp;<!-- 수신확인 -->&nbsp;|&nbsp;	
						<%--<input type="hidden" name="chkreceipt"> <!-- 2015.04.01 주석처리, 2016.01.25 다시 주석 -->--%>
							
						<input type="checkbox" name="importance" <%=(importance == 1) ? "checked" : ""%>><font color="red"><fmt:message key="sch.Importance"/><!-- 중요도--></font>&nbsp;
<!-- 						|&nbsp; -->
<%-- 						<input type="checkbox" name="chkPerSign" onclick="OnPersonSign()" <% if (envelope == null) { %>checked="checked"<% } %>>Signature&nbsp;		 --%>
						<!--
						<img src="../common/images/vwicn150.gif" border=0>중요도 : 
						<select name="importance">		
							<option value="1">높음
							<option value="3" selected>보통
							<option value="5">낮음
						</select>	
						-->
					</td>
					<td align="right">
						<input type="checkbox" name="reserved" onclick="OnClickReserved()"><fmt:message key="mail.reservation"/>&nbsp;<!-- 예약 -->
						<!-- <input type="radio" name="rtype" value="0" checked /> 한번
						<input type="radio" name="rtype" value="1" onclick="repeatReservation()" /> 반복 -->
						<input type="text" name="reserved_date" id="reserved_date" style="width:75px;" maxlength="30" readonly="true" disabled="true" value="<%=format.format(new java.util.Date())%>">
<%-- 						<input type="text" name="reserved_date" onfocus="ShowDatePicker()" onclick="ShowDatePicker()" readonly="true" disabled="true" value="<%=format.format(new java.util.Date())%>" style="width:80px"> --%>
						<select name="reserved_hour" disabled="true">
							<option value="00">00<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="01">01<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="02">02<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="03">03<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="04">04<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="05">05<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="06">06<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="07">07<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="08">08<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="09">09<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="10">10<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="11">11<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="12">12<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="13">13<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="14">14<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="15">15<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="16">16<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="17">17<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="18">18<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="19">19<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="20">20<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="21">21<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="22">22<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="23">23<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
						</select>
						<select name="reserved_min" disabled="true">
							<option value="00">00<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="10">10<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="20">20<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="30">30<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="40">40<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="50">50<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
						</select>
					</td>
				</tr>
			</table>
			
			<%
				} else {
			%>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td>
<!--
                        신규작성, 회신 상관없이 무조건 수신확인과 발송후저장은 check되도록 설정
                        <input type="checkbox" name="saveaftersent" <%//=(envelope != null && envelope.saveAfterSent()) ? "checked" : ""%>>발송후 저장&nbsp;|&nbsp;
						<input type="checkbox" name="chkreceipt" <%//=(envelope != null && envelope.checkReceipt()) ? "checked" : ""%> onclick="OnClickCheckReceipt()">수신확인&nbsp;|&nbsp;	
-->
						<input type="checkbox" name="saveaftersent" checked style="display:none;">
						<%-- <fmt:message key="mail.save.afterSend"/>&nbsp;<!-- 발송후 저장 -->&nbsp;|&nbsp; <!-- 발송후 저장이 기본설정으로 변경 2013-08-02 --> --%> 
						
						<input type="checkbox" name="chkreceipt" onclick="OnClickCheckReceipt()" <%=(isReceive) ? "checked" : "" %>><fmt:message key="mail.received.check"/>&nbsp;<!-- 수신확인 -->&nbsp;|&nbsp;	
						<input type="checkbox" name="importance" <%=(importance == 1) ? "checked" : ""%>><font color="red"><fmt:message key="sch.Importance"/></font>&nbsp;
						<%if(mailboxID!=Mailbox.DRAFT){ %>
						|&nbsp;<input type="checkbox" name="chkPerSign" id="chkPerSign" onclick="OnPersonSign()"><fmt:message key="mail.sign"/>&nbsp;
						<%} %>
<%-- 						|&nbsp;<input type="checkbox" name="chkComSign" onclick="OnCompanySign()"><fmt:message key="mail.company.sign"/>&nbsp;<!-- 회사서명 --> --%>
						<!--
						<img src="../common/images/vwicn150.gif" border=0>중요도 : 
						<select name="importance">		
							<option value="1" <%=(importance==1) ? "selected" : ""%>>높음
							<option value="3" <%=(importance==3) ? "selected" : ""%>>보통
							<option value="5" <%=(importance==5) ? "selected" : ""%>>낮음
						</select>	
						-->
						<!--
						&nbsp;|&nbsp;
						<a href="javascript:fnSecurSentence();">
							<img src="../common/images/i_secuSentence.gif" border=0>보안문구 삽입
						</a>
						-->
					</td>
					<td align="right">
						<% 
							if (envelope.getMailboxID() == Mailbox.RESERVED) {
							Calendar calendar = Calendar.getInstance();
							java.util.Date reserved = envelope.getReserved();
							calendar.setTime(reserved);
							int hour = calendar.get(Calendar.HOUR_OF_DAY);
							int min = calendar.get(Calendar.MINUTE);

						%>

						<input type="checkbox" name="reserved" <%=(envelope != null && envelope.getMailboxID() == Mailbox.RESERVED)? "checked": ""%>" onclick="OnClickReserved()"><fmt:message key="mail.scheduled.sransmis"/>&nbsp;<!-- 예약발송 -->
<%-- 						<input type="text" name="reserved_date" onfocus="ShowDatePicker()" onclick="ShowDatePicker()" readonly="true" value="<%=format.format(reserved)%>" style="width:80px"> --%>
						<input type="text" name="reserved_date" id="reserved_date" Style="width:75px;" maxlength="30" readonly="true" disabled="true" value="<%=format.format(new java.util.Date())%>">
						<select name="reserved_hour">
							<option value="01" <%=(hour == 1) ? "selected" : ""%>>01<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="02" <%=(hour == 2) ? "selected" : ""%>>02<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="03" <%=(hour == 3) ? "selected" : ""%>>03<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="04" <%=(hour == 4) ? "selected" : ""%>>04<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="05" <%=(hour == 5) ? "selected" : ""%>>05<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="06" <%=(hour == 6) ? "selected" : ""%>>06<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="07" <%=(hour == 7) ? "selected" : ""%>>07<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="08" <%=(hour == 8) ? "selected" : ""%>>08<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="09" <%=(hour == 9) ? "selected" : ""%>>09<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="10" <%=(hour == 10) ? "selected" : ""%>>10<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="11" <%=(hour == 11) ? "selected" : ""%>>11<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="12" <%=(hour == 12) ? "selected" : ""%>>12<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="13" <%=(hour == 13) ? "selected" : ""%>>13<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="14" <%=(hour == 14) ? "selected" : ""%>>14<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="15" <%=(hour == 15) ? "selected" : ""%>>15<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="16" <%=(hour == 16) ? "selected" : ""%>>16<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="17" <%=(hour == 17) ? "selected" : ""%>>17<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="18" <%=(hour == 18) ? "selected" : ""%>>18<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="19" <%=(hour == 19) ? "selected" : ""%>>19<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="20" <%=(hour == 20) ? "selected" : ""%>>20<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="21" <%=(hour == 21) ? "selected" : ""%>>21<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="22" <%=(hour == 22) ? "selected" : ""%>>22<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="23" <%=(hour == 23) ? "selected" : ""%>>23<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="24" <%=(hour == 24) ? "selected" : ""%>>24<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
						</select>
						<select name="reserved_min">
							<option value="00" <%=(min == 0) ? "selected" : ""%>>00<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="10" <%=(min == 10) ? "selected" : ""%>>10<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="20" <%=(min == 20) ? "selected" : ""%>>20<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="30" <%=(min == 30) ? "selected" : ""%>>30<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="40" <%=(min == 40) ? "selected" : ""%>>40<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="50" <%=(min == 50) ? "selected" : ""%>>50<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
						</select>
						<%
							} else {
						%>
						<input type="checkbox" name="reserved" onclick="OnClickReserved()"><fmt:message key="mail.scheduled.sransmis"/>&nbsp;<!-- 예약발송 -->
<%-- 						<input type="text" name="reserved_date" readonly="true"onfocus="ShowDatePicker()" onclick="ShowDatePicker()" disabled="true" value="<%=format.format(new java.util.Date())%>" style="width:80px"> --%>
						<input type="text" name="reserved_date" id="reserved_date" Style="width:75px;" maxlength="30" readonly="true" disabled="true" value="<%=format.format(new java.util.Date())%>">
						<select name="reserved_hour" disabled="true">
							<option value="00">00<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="01">01<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="02">02<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="03">03<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="04">04<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="05">05<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="06">06<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="07">07<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="08">08<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="09">09<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="10">10<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="11">11<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="12">12<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="13">13<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="14">14<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="15">15<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="16">16<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="17">17<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="18">18<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="19">19<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="20">20<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="21">21<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="22">22<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
							<option value="23">23<fmt:message key="mail.time.hour"/>&nbsp;<!-- 시 --></option>
						</select>
						<select name="reserved_min" disabled="true">
							<option value="00">00<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="10">10<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="20">20<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="30">30<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="40">40<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
							<option value="50">50<fmt:message key="mail.time.minute"/>&nbsp;<!-- 분 --></option>
						</select>
						<%
							}
						%>
					</td>
				</tr>
			</table>
			<%
				}
			%>
			
<table><tr><td class=tblspace09></td></tr></table>

<!-- <div style="width:100%;height:expression(document.body.clientHeight-88);overflow:auto;"> -->
			<table width="100%" cellspacing=0 cellpadding=0 style="table-layout:fixed;">
				<tr>
					<td width="15%" class="td_le1" nowrap style="width:120px; text-align:left;"><!-- 수신 -->
<!-- 						&nbsp;<a onclick="javascript:OnClickAddressBook();" class="button white medium"> -->
<!-- 						<img src="../common/images/bb02.gif" border="0"> 받는사람 </a> -->
						&nbsp;<a href="#" class="minibutton btn-download" onclick="javascript:OnClickAddressBook(0);">
							<span><span class="icon-users"></span><fmt:message key="mail.sendto"/><!-- 받는사람 -->
						</span></a>
<%-- 						<table width="80" border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickAddressBook();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)"> --%>
<!-- 							<tr> -->
<%-- 								<td width="23"><img id="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<%-- 								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<fmt:message key="t.recipients"/>&nbsp;<!-- 주소록 --></span></td> --%>
<%-- 								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td> --%>
<!-- 							</tr> -->
<!-- 						</table> -->
					</td>
					<td width="*" class="td_le2" style="paddings:2px;">
						<input type="text" id="reTo" name="receive_to" style="z-index:100px">
					</td>					
				</tr>
				<tr>
					<td class="td_le1" style="text-align:left;">
<!-- 						&nbsp;<a onclick="javascript:OnClickAddressBook();" class="button white medium"> -->
<!-- 						<img src="../common/images/bb02.gif" border="0"> 참 조 인 </a> -->
						&nbsp;<a href="#" class="minibutton btn-download" onclick="javascript:OnClickAddressBook(1);">
							<span><span class="icon-users"></span><fmt:message key="mail.copyto"/><!-- 참조인 -->
						</span></a><span onclick="expandBC();" title="<fmt:message key='mail.bcc.add'/>" style="cursor:pointer; float:right; position:relative; top:4px; left:-5px; "><img src="/common/images/icon-navigation-270.png"></span>
					</td>
					<td class="td_le2" style="paddings:2px;">
						<input type="text" id="reCc" name="receive_cc">
					</td>
				</tr>
				<tr id="BC" style="display:none;">
					<td class="td_le1" style="text-align:left;">
					&nbsp;<a href="#" class="minibutton btn-download" onclick="javascript:OnClickAddressBook(2);">
							<span><span class="icon-users"></span><fmt:message key="mail.blindcopyto"/><!-- 비밀참조인 --></span></a>
					</td>
					<td class="td_le2" style="paddings:2px;">
						<input type="text" id="reBcc" name="receive_bcc">
					</td>
				</tr>
<!-- 				<tr> -->
<%-- 					<td width="15%" class="td_le1"><fmt:message key="mail.subject"/>&nbsp;<!-- 제목 --> <!-- <span class="readme"><b>*</b> --></span></td> --%>
<%-- 					<td width="*" class="td_le2" nowrap><input name="subject" style="width:100%;ime-mode:active;" value="<%=HtmlEncoder.encode(subject)%>"></td> --%>
<!-- 				</tr> -->
			</table>

			<table class=tblspace05><tr><td></td></tr></table>

			<table width="100%" cellspacing=0 cellpadding=0 style="table-layout:fixed;">
				<tr>
					<td width="15%" class="td_le1" style="width:120px; text-align:left;">&nbsp;&nbsp;<fmt:message key="mail.subject"/>&nbsp;<!-- 제목 --> <!-- <span class="readme"><b>*</b> --></span></td>
					<td width="*" class="td_le2" nowrap><input type="text" name="subject" style="width:100%;ime-mode:active;" value="<%=HtmlEncoder.encode(subject)%>"></td>
				</tr>
			</table>
			
			<table class=tblspace05><tr><td></td></tr></table>
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="15%" class="td_le1" style="width:120px; text-align:left; background:#ddecf7;">&nbsp;&nbsp;<fmt:message key="t.attachfile"/><!-- 첨부 --></td>
					<td width="*" class="td_le2"><input type="radio" name="bigfile" value="F" checked><fmt:message key="mail.attachments.general"/>&nbsp;<!-- 일반첨부 --><!-- 일반첨부 -->
					 <input type="radio" name="bigfile" value="T"><fmt:message key="mail.attachments.large"/>&nbsp;<!-- 대용량 첨부 -->
					 <font color="blue"><b>※ <fmt:message key="mail.attachments.large.20mb"/> </b></font>&nbsp;<!-- ※첨부 파일 크기가 20MB 이상인 경우 자동으로 대용량으로 발송됩니다. -->
					 
					 			<%if(isIE){ %>
<!-- 			<table><tr><td class=tblspace09></td></tr></table> -->
			<%
				String jspPage = new StringBuffer()
							.append("../common/attachup_control_mail.jsp?attachfiles=")
							.append(java.net.URLEncoder.encode(files.toString(), "utf-8"))
							.append("&actionurl=")
							.append(java.net.URLEncoder.encode(homePath + "mail/mail_send.jsp"))
							.toString();
			%>
			<div id="idfile">
			<jsp:include page="<%=jspPage%>" flush="true">
				<jsp:param name="maxfilesize" value="<%=uservariable.sendMailSize%>"/>
				<jsp:param name="maxfilecount" value="-1"/>
			</jsp:include>
			</div>
			<%}else{ %>
			<%
			String baseURL = homePath;//application.getInitParameter("CONF.HOME_PATH");
			if (!baseURL.endsWith("/")){
				baseURL += "/";
			}
			baseURL += "mail/mail_dn_attachment.jsp?message_name=";
			baseURL += messageName;
			baseURL += "&path=";
			%>
			<jsp:include page="/WEB-INF/common/file_upload_control.jsp" flush="true">
				<jsp:param name="attachfiles" value="<%=files.toString()%>"/>
				<jsp:param name="actionURL" value="/mail/mail_send.jsp"/>
				<jsp:param name="baseURL" value="<%=baseURL%>"/>
			</jsp:include>
			<%} %>
			
			<div id="objDms" style="width:100%;display:none;" class="upload">
				<table id="dmstbl" width="100%" border="0" cellspacing="0" cellpadding="0" class="table table-striped" style="margin-bottom: 4px;">
					<thead>
						<tr class="fade">
							<th width="25" class="row fileupload-buttonbar">
								<input type="checkbox" class="toggle">
							</th>
							<th>EDMS Attach Files</th>
							<th width="90">Size</th>
							<th width="95">Button</th>
						</tr>
					</thead>
					<tbody class="files"></tbody>
				</table>
				
				<%-- 
				<table id="dmstbl" width="100%" border="0" cellspacing="0" cellpadding="0" >
					<tr>
						<td width="*" class="td_le1" style="width:540px; text-align:center; font-weight:normal; height:23px;">&nbsp;&nbsp;EDMS Attach Files</td>
						<td width="100" class="td_le1" style="text-align:center; width:100px; font-weight:normal; height:23px;">&nbsp;&nbsp;Size</td>
						<td width="100" class="td_le1" style="text-align:center; width:100px; font-weight:normal; height:23px;">&nbsp;&nbsp;Button</td>
					</tr>
				</table>
				 --%>
			</div>

					</td>
				</tr>
			</table>
			
<!-- 			<div id="objDms" style="width:100%;display:none;"> -->
<!-- 				<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;"> -->
<!-- 				<tr> -->
<!-- 					<td width="15%" class="td_le1" style="text-align:left;">문서관리</td> -->
<!-- 					<td width="*"> -->
<!-- 						<table id="dmstbl" width="100%" border="0" cellspacing="0" cellpadding="0" > -->
<!-- 							<tr> -->
<!-- 								<td width="*" class="td_le1" style="text-align:center;">&nbsp;&nbsp;Attach Files</td> -->
<!-- 								<td width="15%" class="td_le1" style="text-align:center;">&nbsp;&nbsp;Size</td> -->
<!-- 								<td width="10%" class="td_le1" style="text-align:center;">&nbsp;&nbsp;Button</td> -->
<!-- 							</tr> -->
<!-- 						</table> -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 				</table> -->
<!-- 			</div> -->

<%-- mail body --%>
			<div contenteditable="true" style="display:none" id="dspbody">
			<%//= (envelope != null) ? HtmlEncoder.encode(body) : ""%>
			<%= (envelope != null) ? HtmlEncoder.encode(body) : ""%>
			</div>

<!-- 			<div style="display:none" id="dissignature"> -->
			<textarea id="dissignature" style="display:none">
			<% 
				if (signature.isEnabled()) {
// 					out.println(HtmlEncoder.encode(signature.getSignature()));
					out.println(signature.getSignature());
				}
			%>
<!-- 			</div> -->
			</textarea>

			<!-- 외부 문서 본문 DATA -->
			<div style="display:none" id="expData">
			<%=expData%>
			</div>
			
			<table><tr><td class=tblspace05></td></tr></table>
			<!-- IE ActiveX -->
			<%if(isIE){ %>
			<!-- 나모 웹에디터 삽입 -->
<!-- 			<Script src="/common/active-x/namo7/NamoWec7.js"></Script> -->
			<!-- 나모 웹에디터 끝 -->
			<!-- 태그프리 에디터 적용 -->
			<Script src="/common/scripts/tweditor.js"></Script>
			<%}else{ %>
			<div>
				<jsp:include page="/WEB-INF/common/daum_editor_control.jsp" flush="true" />
				
			</div>
			<%} %>
			
			<table><tr><td class=tblspace09></td></tr></table>

<!-- </div> -->

		</form>
<!-- 		<script language="javascript"> -->
<!-- 			SetHelpIndex("mail_write"); -->
<!-- 		</script> -->
		<style>
.ui-widget { font-family: Verdana,Arial,sans-serif; font-size: 12px;}
.ui-button-text-icon-primary .ui-button-text, .ui-button-text-icons .ui-button-text { padding:1px 10px 1px 22px; }
}
.ui-button {margin:0.1em;}
#fileresult {font-size:12px;}
#fileresult th {font-size:12px; text-align:center; font-weight:normal;}

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

<!--  mail의 경우 스타일 관련해 하단으로 옮김 : 2013-08-04 김정국 -->
<link type="text/css" href="/common/css/styledButton.css" rel="stylesheet" />

</div>
</body>
</fmt:bundle>
</html>
<%
// 	if (!"new".equals(cmd)) {
// 		System.out.println("["+logString+"]  FORM OPEN Success ");
// 	}
%>