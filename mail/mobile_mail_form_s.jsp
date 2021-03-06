<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import='org.apache.commons.lang.StringUtils' %>
<%@ page import="org.json.*" %>
<%@ include file="../common/usersession.jsp" %>
<%
MailRepository repository = MailRepository.getInstance();
DBHandler db = new DBHandler();
Connection con = null;
boolean mailUseChk = false;
boolean appendOriginal = true;
MailEnvelope envelope = null;
MimeMessage msg = null;
String to = null;
String cc = null;
String bcc = null;
String subject = "";
String body = null;
String attachDiv = "";
int importance = 3;
HashMap<String, String> receive_map = null;
String files = null;

String messageName = StringUtils.defaultString(request.getParameter("message_name"));
String cmd = StringUtils.defaultString(request.getParameter("cmd"), "new");
String domainName = application.getInitParameter("nek.mail.domain");

if (StringUtils.isNotEmpty(uservariable.userDomain)) 
	domainName = uservariable.userDomain;

String email = loginuser.emailId + "@" + domainName;

try {
	con = db.getDbConnection();
	mailUseChk = repository.getUserMailChk(con, loginuser.uid);
	
	if (messageName.length() > 0) {
		envelope = repository.retrieve(con, loginuser.emailId, messageName, domainName);
	}

} catch (Exception e) {
	e.printStackTrace();
} finally {
	if (db != null)
		db.freeDbConnection();
}

if (mailUseChk) {
	// ?????? ?????? ????????? ????????????.
}

if (envelope == null) {
	// ?????? ??????
	to = request.getParameter("to");
} else {
	// ?????? ??????/??????/??????/????????????
	msg = envelope.getMessage();
	body = envelope.getHtmlBody();
	String msgSub = envelope.getSubject();

	if (body == null) {
		String textBody = envelope.getTextBody();
		if (textBody != null) {
			body = new StringBuffer().append("<pre style='word-wrap:break-word;'>")
					.append(HtmlEncoder.encode(textBody)).append("</pre>").toString();
		} else {
			body = "";
		}
	}

	if (body != null) {
		Collection attachments = envelope.getAttachments();
		if (attachments != null && attachments.size() > 0) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment)iter.next();
				String cid = attachment.getContentID();
				if (cid != null) {
					// ??????????????? ?????? ???????????? ?????????. 2013-02-08
					if (cid.indexOf("GARAMSYSTEM") > -1) {
						int start = body.toLowerCase().indexOf("cid:" + cid);
						if (start != -1) {
							body = new StringBuffer().append(body.substring(0, start))
								.append("/mail/mail_dn_attachment.jsp?message_name=").append(messageName)
								.append("&path=").append(attachment.getPath())
								.append(body.substring(start + cid.length() + 4)).toString();
						}
					}
				}
			}
		}
	}

	String mimeFrom = "";
	String[] fromObj = msg.getHeader("from");	
	for (int i = 0, len = fromObj.length; i < len; i++) mimeFrom += fromObj[i];

	String senders = "";
	try {
		if (mimeFrom.indexOf("=?") == -1) {
			senders = new String(MimeUtility.decodeText(mimeFrom).getBytes("ISO-8859-1"),"EUC-KR");
		} else {
	 		senders = envelope.getReplyRecipients();
		}
	} catch (Exception e) {
		e.printStackTrace();
	}

	if (cmd.equals("reply")) {
		subject = "RE: " + msgSub;
		try { to = envelope.getRecipients(Message.RecipientType.TO, email); } catch (Exception e) {}
	} else if (cmd.equals("replyall")) {
		subject = "RE: " + msgSub;
		try { to = envelope.getReplyAllRecipients(email); } catch (Exception e) {}
		try { cc = envelope.getRecipients(Message.RecipientType.CC, email); } catch (Exception e) {}
	} else if (cmd.equals("forward")) {
		subject = "FW: " + msgSub;
	} else {
		appendOriginal = false;
		subject = msgSub;
		try { to = envelope.getRecipients(null, email); } catch (Exception e) {}
		try { cc = envelope.getRecipients(Message.RecipientType.CC, email); } catch (Exception e) {}
		try { bcc = envelope.getRecipients(Message.RecipientType.BCC, email); } catch (Exception e) {}
	}

	if (envelope != null) {
		int sIdx = body.toLowerCase().indexOf("<script");
		int eIdx = 0;
		while(sIdx > -1) {
			eIdx = body.toLowerCase().indexOf("/script>");
			body = body.substring(0, sIdx -1) + body.substring(eIdx +8);
			sIdx = body.toLowerCase().indexOf("<script");
		}

		if (body.toLowerCase().indexOf("<base") > -1) {
			body = body.replaceAll("<(?i)base","<div");
		}

		int startLine = body.toLowerCase().indexOf("<img style='display:hidden'");
		if (startLine != -1) {
			String tmp = body.substring(startLine, body.length());
			int endLine = tmp.indexOf("'>");
			body = body.substring(0, startLine) + body.substring(startLine+endLine+2, body.length());
		}
		

		if (appendOriginal) {
			String strTo = "";
			try {
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
					strTo = envelope.getRecipients(null, email);
				}
			} catch(Exception e) {
				strTo = "UNKNOWN";
			}
			
			String strCc = "";
			try {
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
					strCc = envelope.getRecipients(Message.RecipientType.CC, email);
				}
			} catch(Exception e) {
				strCc = "UNKNOWN";
			}
			
			body = new StringBuffer()
					.append("<p>&nbsp;</p>\n")
					.append("<span id='fmsign'></span>")
					.append("<span id='fmcomsign'></span>")
					.append("<div>")
					.append("<div>------------------ Original Message ------------------</div>")
					.append("<div style='border-left: 2px solid black; padding-left: 5px;' id='req'>")
					.append("<div>From: ")
					.append(HtmlEncoder.encode(senders))
					.append("</div><div>To: ")
					.append(HtmlEncoder.encode(strTo))
					.append((!HtmlEncoder.encode(strCc).equals("")? "</div><div>CC: ": ""))
					.append((!HtmlEncoder.encode(strCc).equals("")? HtmlEncoder.encode(strCc): ""))
					.append("</div><div>Sent: ")
					.append(envelope.getDate().toString())
					.append("</div><div>Subject: ")
					.append(HtmlEncoder.encode(msgSub))
					.append("</div><br>")
					.append(body)
					.append("</div></div>").toString();
		}

		if (!cmd.startsWith("reply")) {
			Collection attachments = envelope.getAttachments();
			if (attachments != null) {
				Iterator iter = attachments.iterator();
				while (iter.hasNext()) {
					Attachment attachment = (Attachment)iter.next();
					String cid = attachment.getContentID();
					if (cid != null) continue;					
					files = new StringBuffer().append(attachment.getPath()).append('|')
						 .append(attachment.getFileName()).append('|')
						 .append(attachment.getSize()).append('|').toString();
				}
			}
		}

		//?????? ????????? ?????? ??????
		Collection attachments = envelope.getAttachments();
		if (attachments != null) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment)iter.next();
				String cid = attachment.getContentID();
				if (cid != null) {
					//2013-02-08 ??????????????? ?????? ???????????? ?????????.
					if (cid.indexOf("GARAMSYSTEM") > -1) {
						attachDiv += "<input type='hidden' name='imghid' value='message_name=" + envelope.getMessageName() +"&path=" + attachment.getPath() + "???" + attachment.getFileName() +"'>";
					}
				}
			}
		}

		importance = envelope.getImportance();
	}

	// ?????? ????????????
	long mailQuota = uservariable.mailBoxSize/(1024*1024);
	MailRepositorySummary mailboxSummary = null;
	
	try {
		con = db.getDbConnection();
		mailboxSummary = MailRepository.getInstance().getRepositorySize(con, loginuser.emailId, domainName);
	} catch(Exception ex) {
	} finally {
		if (con != null) { db.freeDbConnection(); }
	}
	
	double mailUsage = (double) mailboxSummary.getTotalSize();
	mailUsage = mailUsage/(1024.0*1024.0);
	int mailPercent = (int) (mailQuota == 0? 0: (100*mailUsage)/mailQuota);
	if (mailPercent > 100) {
		mailPercent = 100;
	}
}

String rf = "null";
String rt = "null";
String rc = "null";
String rb = "null";

if (envelope != null) {
	if (cmd.equals("reply")) {
	} else if (cmd.equals("replyall")) {
		rf = envelope.getRecipients(Message.RecipientType.TO, email);
		if (receive_map != null) {
			rt = receive_map.get("receive_to");
			rc = receive_map.get("receive_cc");
		}
	} else if (cmd.equals("forward")) {
	} else if (receive_map != null) {
		rt = receive_map.get("receive_to");
		rc = receive_map.get("receive_cc");
		rb = receive_map.get("receive_bcc");
    }
}
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><fmt:message key="mail.title" /></title>
<link rel="stylesheet" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
<link rel="stylesheet" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
<link rel="stylesheet" type="text/css" href="/common/jquery/plugins/token-input-facebook.css" />
<link rel="stylesheet" type="text/css" href="/mail/css/garamtagit.css">
<script src="/common/jquery/js/jquery-1.6.4.min.js"></script>
<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js"></script>
<script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
<script src="/common/jquery/plugins/jquery.ui.touch-punch.min.js"></script>
<script src="<%=scriptPath %>/common.js"></script>
<script src="./js/garamtagit.js"></script>

<script>
$(document).ready(function() {
	$('#reTo').garamtagit({ type: 0 });
	$('#reCc').garamtagit({ type: 1 });
	$('#reBcc').garamtagit({ type: 2 });

	var receive_from_str = '<%=rf %>';
	var receive_to_str = <%=rt %>;
	var receive_cc_str = <%=rc %>;
	var receive_bcc_str = <%=rb %>;

	if (receive_from_str != "null") {
		$('#reTo').garamtagit("adds", receive_from_str); 
	}
	
	if (receive_to_str != null) {
		$('#reTo').garamtagit("addo", receive_to_str);
	} else {
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
	
	$('#txtContent').html($("#body").text());

	if ($("#txtContent").find('img[id=nekrecchk]').length > 0)
		$("#txtContent").find('img[id=nekrecchk]').remove();
	
	$('.searchInput').css({"height":"2em","width":"17em","margin-left":"6px"})
	.addClass("ui-input-search ui-shadow-inset ui-btn-corner-all ui-btn-shadow ui-icon-searchfield ui-body-c");
});

var msgMoreThenOne = "<fmt:message key='mail.c.recipient.MoreThenOne'/>";	// ???????????? ?????? ?????? ????????? ?????????!
var msgSubjectRequired = "<fmt:message key='v.subject.required'/>";			// ????????? ???????????? ????????????!
var msgSendMail = "<fmt:message key='mail.c.send.mail'/>";					// ????????? ?????????????????????????

function OnClickSend() {
	document.fmMail.to.value = document.fmMail.receive_to.value;
	document.fmMail.cc.value = document.fmMail.receive_cc.value;
	document.fmMail.bcc.value = document.fmMail.receive_bcc.value;
	
	if (document.fmMail.to.value == "") {
		alert(msgMoreThenOne);
		return;
	}

	if (TrimAll(fmMail.subject.value) == "") {
		alert(msgSubjectRequired);
		fmMail.subject.focus();
		return;
	}
	
	if (!confirm(msgSendMail)) 
		return false;
	
	// ?????? ?????????
	var pgObj = document.getElementById("myid");
 	pgObj.style.display = "";

	var mailNewDoc = "Mail" + "<%=loginuser.uid %>" + <%=System.currentTimeMillis() %>;
	fmMail.maildoc.value = mailNewDoc;
	
	var tempBody = $(document.getElementById("txtContent")).html();
	tempBody = tempBody.replace(/\r\n/g, "<br>");
	tempBody = tempBody.replace(/\n/g, "<br>");
	tempBody = tempBody.replace(/\r/g, "<br>");
	fmMail.mailbody.value = tempBody;

	document.fmMail.submit();
	return false;
}

function OnClickDraft() {
	document.fmMail.to.value = document.fmMail.receive_to.value;
	document.fmMail.cc.value = document.fmMail.receive_cc.value;
	document.fmMail.bcc.value = document.fmMail.receive_bcc.value;
	
	if (document.fmMail.to.value == "") {
		alert(msgMoreThenOne);
		return;
	}

	if (TrimAll(fmMail.subject.value) == "") {
		alert(msgSubjectRequired);
		return;
	}

	var conf_tmpMsg = "<fmt:message key="c.save.temp"/>"; // ???????????? ??????????????????? 
	
	if (!confirm(conf_tmpMsg)) return;
	
	//?????????????????? ??????
	document.forms[0].cmd.value = "draft";
	
	var mailNewDoc = "Mail"  + "<%=loginuser.uid%>" + "_"+<%=System.currentTimeMillis()%>;

	var tempBody = $(document.getElementById("txtContent")).html();
	tempBody = tempBody.replace(/\r\n/g, "<br>");
	tempBody = tempBody.replace(/\n/g, "<br>");
	tempBody = tempBody.replace(/\r/g, "<br>");
	fmMail.mailbody.value = tempBody;
	
	document.fmMail.submit();
	return false;
}

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
</script>

<!----S: 2021????????? ??????------->
<link rel="stylesheet" href="/mobile/css/mobile.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_sub_page.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_mail_read.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_mail_form_s.css"/>
<script src="/mobile/js/sw_file_add.js"></script>

<script>
    $(document).ready(function(){
        
        
        $('#burger-check').click(function(){
            $('.menu_bg').show(); 
            $('.sub_ham_page').css('display','block'); 
            $('.sidebar_menu').show().animate({
                right:0
            });
            $('.ham_pc_footer_div').show().animate({
                bottom:0,right:0
            });
        });
        $('.close_btn>a').click(function(){
            $('.menu_bg').hide(); 
            $('.sidebar_menu').animate({
                right: '-' + 100 + '%'
                       },function(){
            $('.sidebar_menu').hide(); 
            }); 
            $('.ham_pc_footer_div').animate({
                right: '-' + 100 + '%',
                bottom:'-' + 100 + '%'
                       },function(){
            $('.ham_pc_footer_div').hide(); 
            }); 
        });
         
        $('.blindcopyto_span').toggle(
            function(){ $('.blindcopyto_span').text("?????????"); 
                        $('.blindcopyto_box').css('display','block');
                },

            function(){$('.blindcopyto_span').text("??????????????????"); 
                       $('.blindcopyto_box').css('display','none');
        
               });

        
});
</script>

<script>
    $('body').delegate('.nav-search', 'pageshow', function( e ) {
        $('.ui-input-text').attr("autofocus", true)
    });			
</script>

<!----E: 2021????????? ??????------->
<!----S: 2022????????? ??????------->
<link rel="stylesheet" href="/mobile/css/mobile_top.css"/>
<script src="/mobile/js/mobile_top.js"></script>
<!----E: 2022????????? ??????------->
</head>


<body>

<div data-role="page" id="page-list">

    <div class="main_contents_top">
    <div class="menu_bg"></div>
    <div class="sidebar_menu">
         <div class="home_icon_div">
            <ul>
            <li onClick="location.href='/'">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2017.11 1996.25" style="width:15px;height:15px;margin-right:1px;"><defs><style>.cls-1{fill:#fff;}</style></defs><g id="icon_2" data-name="icon2"><g id="icon_2" data-name="icon_2"><path class="cls-1" d="M209.3,912.32V1948.74c0,25.75,14.26,47.51,31.14,47.51h571.9V1363.3h392.44v633h571.89c16.88,0,31.14-21.76,31.14-47.51V912.32L1008.56,352.68Z"/><path class="cls-1" d="M1984.23,666.28h0L1057.63,17.42l-.39-.32A76.54,76.54,0,0,0,1010.72,0l-2.21,0-2,0A76.55,76.55,0,0,0,959.88,17.1l-1.62,1.22-925.37,648a77.28,77.28,0,0,0-19,107.48l51.32,73.31a77,77,0,0,0,100.39,23.36,78.88,78.88,0,0,0,7.1-4.41l835.81-585.24L1844.36,866a79.7,79.7,0,0,0,7.14,4.37,77.06,77.06,0,0,0,100.36-23.32l51.32-73.31A77.26,77.26,0,0,0,1984.23,666.28Z"/></g></g></svg>
            </li>
            <li><div class="close_btn"><a href="#"><img src="/common/images/icon/logout.png" height="25"></a></div></li>
            </ul>
        </div>
         <div class="ham_user_name"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>???</b></div>
         <div class="logout_btn" onClick="location.href='/logout.jsp'">????????????</div>
         <div class="menu_wrap">
             <div data-role="page" class="type-home sub_ham_page" id="page-home" style="position:relative;clear: both;z-index: 1;background: #fff;">
                 <div class="nav_div">
                 <div data-role="content" style="border-top:9px solid #f5f5f5;margin-top:1%;">   
                 <ul  class="ham">
                    <li class="ham_li">
                        <span>????????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mail/mobile_mail_form_s.jsp'">????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=1&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=2&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=3&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=4&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/notification/list.jsp?boxId=1&noteType=0'">????????????<b class="link_arrow">></b></li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>????????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=240'">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=340'">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=640'">?????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=820'">?????????<b class="link_arrow">></b></li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>????????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/addressbook/user.jsp'">
                                ???????????????<b class="link_arrow">></b>
                            </li>
                            <li onClick="location.href='/mobile/addressbook/list.jsp'">
                                ????????? ??????<b class="link_arrow">></b>
                            </li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>?????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000004'">
                                ?????????<b class="link_arrow">></b>
                            </li>
                            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000000'">
                                ????????????<b class="link_arrow">></b>
                            </li>
                        </ul>
                    </li>

                    <!--<li data-filtertext="????????????">
                        <a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">????????????</a>
                    </li>
                    <li data-filtertext="<%=msglang.getString("main.E-mail") /* ???????????? */ %> <%=msglang.getString("mail.InBox") /* ??????????????? */ %>">
                        <a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("main.E-mail") /* ??????????????? */ %></a>
                    </li>
                    <li data-filtertext="">
                        <a href="appr/list.jsp?menu=240" data-ajax="false">????????????</a>
                    </li>-->
                </ul>
                </div>
                <div class="footer_pc_ver ham_pc_footer_div" onClick="location.href='/jpolite/index.jsp'" style="position:fixed;;background:#f5f5f5;width:80%;right:0;bottom:-100%;">
                    <img src="/common/images/m_icon/13.png"> PC???????????? ??????
                </div>
                </div>
             </div>
         </div>
    </div>

     <h1 class="left_logo">
         <a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">
            <img src="/common/images/icon/2_logo.png" height="29" border="0" >
        </a>
     </h1>
    <div class="right_menu" >
        <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
     </div>
</div>

	
	<div data-role="content" class="bbs_mobile_form">
	
	<form name="fmMail" id="fmMail" method="post" action="mail_send.jsp" enctype="multipart/form-data" onsubmit="return false;">
		<input type="hidden" name="cmd" value="<%=cmd%>">
		<input type="hidden" name="to" value="<%=HtmlEncoder.encode(to)%>">
		<input type="hidden" name="cc" value="<%=HtmlEncoder.encode(cc)%>">
		<input type="hidden" name="bcc" value="<%=HtmlEncoder.encode(bcc)%>">
		<input type="hidden" name="message_name" value="<%=messageName%>">
		<input type="hidden" name="reserved_dt" value="">
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
			<label for="reTo" class="left_label"><b><fmt:message key="mail.sendto"/><!-- ???????????? --></b></label>
			<div class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_to" id="reTo" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="reCc" class="left_label"><b><fmt:message key="mail.copyto"/><!-- ????????? --></b></label>
			<div class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_cc" id="reCc" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="reBcc" class="left_label"><b><fmt:message key="mail.blindcopyto"/><!-- ??????????????? --></b></label>
			<div class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_bcc" id="reBcc" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
        <div class="fileUploadSectionWrapper">
            <label for="filehidden"><b><fmt:message key="t.attached"/></b></label>
            <!-- ???????????? -->
            <div class="fileUploadSection file_btn">			
                <div class="fileUpWrapper">				
                    <div id="fileUpBtnWrapper" class="fileUpBtnWrapper" style="position:relative;">				 								
                        <%-- input??? id??? ?????? ????????? ???????????? ??????(????????? ????????? ?????????) --%>				
                        <input id="file" onchange="makeUploadElem(this)" class='file' type="file" name="upFile[]" style="width: 94px;position: absolute;right:0px;top:0px; opacity:0; filter: alpha(opacity=0);cursor: pointer;outline:none;" / >					 				
                        <span class="fileUp">+ ????????????</span>
                     </div>
                </div>
            </div>		
            <!-- ????????????/?????? -->
            <div class="fieldcontain_box">
            <div class="addAttachFileSection">
                <ul class="attachFileList">
                </ul>
            </div>	
            </div>
        </div>

        
        <!--
            <div class="file_btn">
                <input id="file" onchange="makeUploadElem(this)" class='file' type="file" name="upFile[]" style="position: absolute;right:0px;top:0px; opacity:0; filter: alpha(opacity=0);cursor: pointer;outline:none;" / >
                <span class="fileUp">+ ?????? ??????</span>
            </div>
            <div class="fieldcontain_box">
                <input type="file" name="file[]" size="50" class="input_write" />
        
             ????????? ????????? ??????. 
            <div id="sw_file_add_form"></div>    
            </div>-->
          
            
			<!--<input data-mini="true" name="filehidden" id="filehidden" style="display: none;">
			<input type="file" name="file1" value="" data-mini="true" style="line-height: 2em;margin-left:13.5%;padding:0;">
			<input type="file" name="file2" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">
			<input type="file" name="file3" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">
			<input type="file" name="file4" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">
			<input type="file" name="file5" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">-->
		</div>
		<div data-role="fieldcontain" class="mail_subject">
			<label for="subject" class="left_label"><b><fmt:message key="mail.subject"/></b></label>
			<input data-mini="true" type="text" name="subject" id="subject" value="<%=subject %>">
		</div>
		<div data-role="fieldcontain" style="padding-bottom: 0;">
            <div class="mailbody_name"><b><fmt:message key="t.content"/><!-- ?????? --></b></div>
			<textarea data-mini="true" cols="40" rows="8" name="mailbody" id="mailbody" style="display: none;"></textarea>
			<div data-role="content" contenteditable="true" id="txtContent" 
				 class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="margin-bottom: 0;"></div>
		</div>
        <div class="che_ui_box">
            <ul>
                <li><b><fmt:message key="t.option"/><!-- ?????? --></b></li>
                <li style="display: none;">
				    <input data-mini="true" type="checkbox" name="saveaftersent" id="saveaftersent" checked="checked">
				    <label for="saveaftersent"><fmt:message key="mail.save.afterSend"/></label>
			    </li>
                <li><input data-mini="true" type="checkbox" name="chkreceipt" id="chkreceipt" checked="checked">
			    <label for="chkreceipt"><fmt:message key="mail.received.check"/></label></li>
                <li><input data-mini="true" type="checkbox" name="importance" id="importance">
			    <label for="importance"><fmt:message key="t.hot"/></label></li>
            </ul>
        </div>
		<div data-role="fieldcontain" class="save_btn_box">
		    <a onclick="OnClickDraft()" href="#" data-mini="true" data-role="button" data-icon="check" data-theme="c" data-inline="true" class="btn_save"><fmt:message key="mail.btn.save"/></a>
            <a onclick="OnClickSend()" href="#" data-mini="true" data-role="button" data-icon="check" data-theme="b" data-inline="true" class="btn_send"><fmt:message key="mail.btn.send"/></a>
		</div>
	</form>
	</div>

	
	<div id="body" style="width:0px;height:0px;display:none;font-size:0px;"><%= (envelope != null) ? HtmlEncoder.encode(body) : ""%></div>
</div>

<script type="text/javascript">
function ParseRecipient(strText) {
	var objAddress = null;
	var strPersonal = "";
	var strAddress = "";

	if (strText.indexOf('@') > -1) {
		//strText??? ????????? ????????? ??????
		var nIndex1 = strText.indexOf('"');
		if (nIndex1 > -1) {
			//????????????
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
			//????????????
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
				//??? ????????? ????????????????????? ????????? ?????? (admin@nekjava.kmsmap.com)
				objAddress = new Object();
				objAddress.personal = "";
				objAddress.address = strText;
			} else {
				//personal part only, --> ??????
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
</script>
</body>
</fmt:bundle>
</html>