<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
<%@ page import="org.json.*" %>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="sun.misc.BASE64Decoder" %>
<%@ page import="org.apache.commons.codec.net.QuotedPrintableCodec" %>

<%@ include file="../common/usersession.jsp" %>
<%!
	private String readableFileSize(long size) {
		if (size <= 0) return "0";
		final String[] units = new String[] { "B", "KB", "MB", "GB", "TB" };
		int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
		return new DecimalFormat("#,##0.00").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
	}
%>
<%
	boolean isNotFile = false;
	Connection con = null;
	
	MailRepository repository = MailRepository.getInstance();
	String homePath = "http://" + request.getServerName();
	String domainName = (uservariable.userDomain.equals("")) ? application
			.getInitParameter("nek.mail.domain") : uservariable.userDomain;

	ParameterParser pp = new ParameterParser(request);
	String message_name = pp.getStringParameter("message_name", "");
	int mailboxID = pp.getIntParameter("box", Mailbox.INBOX);
	int unReadID = pp.getIntParameter("unread", 0);
	
	String searchKey = request.getParameter("searchtype");
	String searchValue = request.getParameter("searchtext");
	if(searchKey == null) searchKey = "";
	if(searchValue == null) searchValue = "";
	
	
	MailEnvelope envelope = null;
	HashMap<String, String> receive_map = null;
	
	DBHandler db = new DBHandler();
	try {
		con = db.getDbConnection();
		envelope = repository.retrieve(con, loginuser.emailId, message_name, domainName);
	
		if (envelope != null)
			mailboxID = envelope.getMailboxID();
	
		if (!StringUtils.isEmpty(envelope.getNek_msgid()))
			receive_map = repository.getRecipientsMail(con, envelope.getNek_msgid());
	
		if (!envelope.isRead()) {
			int mainBoxID = repository.getSendBoxCheck(con, mailboxID, domainName);
			if (mainBoxID != Mailbox.OUTBOX) { // 보낸편지함 제외
				repository.markRead(con, loginuser.emailId, new String[] { message_name }, true,
						domainName);
			}
		}
	} catch (java.io.FileNotFoundException e) {
		isNotFile = true;
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}
	
	if (isNotFile) {
		String notExisEmail = msglang.getString("e.notExisEmail"); // 메일 파일이 존재하지 않습니다.
		out.print("<script src=\"/common/scripts/parent_reload.js\"></script>");
		out.print("<script>alert('"+notExisEmail+"');closeWindow();</script>");
		return;
	}
	
	MimeMessage msg = envelope.getMessage();
	Address[] froms = null;
	String errMsg = "";
	try {
		froms = msg.getFrom();
		froms = envelope.getNEKRecipients(msg, "From");
	} catch (Exception ex) {
		errMsg = "UNKNOWN";
	}
	Address[] tos = null;
	try {
		tos = msg.getRecipients(Message.RecipientType.TO);
		tos = envelope.getNEKRecipients(msg, "To");
	} catch (Exception ex) {
		tos = envelope.getNEKRecipients(msg, "To");
	}
	Address[] ccs = null;
	try {
		ccs = msg.getRecipients(Message.RecipientType.CC);
		ccs = envelope.getNEKRecipients(msg, "Cc");
	} catch (Exception ex) {
		ccs = envelope.getNEKRecipients(msg, "Cc");
	}
	List<String> errCc = envelope.getErrCc();
	
	String mailDateLable = (mailboxID == Mailbox.OUTBOX)? msglang.getString("mail.received.when"): msglang.getString("mail.date.sent");
	String mailDateValue = envelope.getCreatedTime();

	String mailFromsValue = "";
	
	if (froms != null) {
		InternetAddress from = (InternetAddress) froms[0];
		if (from.getPersonal() != null) {
			StringTokenizer st = new StringTokenizer(from.getPersonal(), "?");
			String tmpStr = "";
			String enType = "";
			int count = 0;
			while (st.hasMoreTokens()) {
				String tmp = st.nextToken();
				switch(count) {
					case 2: enType = tmp; break;
					case 3: tmpStr = tmp; break;
				}
				count++;
			}
			if (enType.equals("Q")) {
				QuotedPrintableCodec qp = new QuotedPrintableCodec();
				String fromName = StringUtils.defaultIfEmpty(qp.decode(tmpStr), "");
				mailFromsValue += fromName + " " + from.getAddress();
			} else {
				mailFromsValue += HtmlEncoder.encode(from.toUnicodeString());
			}
		} else {
			mailFromsValue += HtmlEncoder.encode(from.toUnicodeString());
		}
	} else {
		mailFromsValue += "알수없음";
	}

	
	String mailTosValue = "";

	if (tos != null) {
		if (receive_map != null && receive_map.get("receive_to") != null) {
			try {
				JSONArray ja = new JSONArray(receive_map.get("receive_to"));
				for(int i = 0, len = ja.length(); i < len; i++) {
					JSONObject jo = ja.getJSONObject(i);
					if (i != 0) mailTosValue += ", ";
					mailTosValue += HtmlEncoder.encode(jo.getString("toDisplay"));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		} else {
			try {
				for (int i = 0; i < tos.length; i++) {
					InternetAddress to = (InternetAddress)tos[i];
					if (i != 0) mailTosValue += ", ";
					mailTosValue += HtmlEncoder.encode(to.toUnicodeString());
				}
			} catch (Exception e) {
				System.out.println("ERROR message_name: " + message_name);
				System.out.println("ERROR mailboxID: " + mailboxID);
				throw new Exception(e);
			}
		}
	}

	String mailCcsValue = "";

	if (ccs != null) {
		if (receive_map != null && receive_map.get("receive_cc") != null) {
			try {
				JSONArray ja = new JSONArray(receive_map.get("receive_cc"));
				for(int i = 0, len = ja.length(); i < len; i++) {
					JSONObject jo = ja.getJSONObject(i);
					if (i != 0) mailCcsValue += ", ";
					mailCcsValue += HtmlEncoder.encode(jo.getString("toDisplay"));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		} else {
			try {
				for(int i = 0; i < ccs.length; i++) {
					InternetAddress cc = (InternetAddress) ccs[i];
					if (i != 0) mailCcsValue += ", ";
					mailCcsValue += HtmlEncoder.encode(cc.toUnicodeString());
				}
			} catch (Exception e) {
				System.out.println("ERROR message_name: " + message_name);
				System.out.println("ERROR mailboxID: " + mailboxID);
				throw new Exception(e);
			}
		}
	}

	
	String mailBccsValue = "";

	Address[] bccs = msg.getRecipients(Message.RecipientType.BCC);
	if (bccs != null) {
		if (receive_map != null && receive_map.get("receive_bcc") != null) {
			try {
				JSONArray ja = new JSONArray(receive_map.get("receive_bcc"));
				for(int i = 0, len = ja.length(); i < len; i++) {
					JSONObject jo = ja.getJSONObject(i);
					if (i != 0) mailBccsValue += ", ";
					mailBccsValue += HtmlEncoder.encode(jo.getString("toDisplay"));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		} else {
			try {
				for (int i = 0; i < bccs.length; i++) {
					InternetAddress bcc = (InternetAddress)bccs[i];
					if (i != 0) mailBccsValue += ", ";
					mailBccsValue += HtmlEncoder.encode(bcc.toUnicodeString());
				}
			} catch (Exception e) {
				System.out.println("ERROR message_name: " + message_name);
				System.out.println("ERROR mailboxID: " + mailboxID);
				throw new Exception(e);
			}
		}
	}

	String mailBodyValue = "";

	Collection attachments = envelope.getAttachments();
	String htmlBody = envelope.getHtmlBody();
	if (htmlBody != null) {
		if (attachments != null && attachments.size() > 0) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment) iter.next();
				String cid = attachment.getContentID();
				if (cid != null) {
					int start = htmlBody.indexOf("cid:" + cid);
					if (start == -1) {
						start = htmlBody.indexOf("CID:" + cid);
					}
					if (start != -1) {
						htmlBody = new StringBuffer().append(htmlBody.substring(0, start))
								.append("/mail/mail_dn_attachment.jsp?message_name=")
								.append(message_name).append("&path=").append(attachment.getPath())
								.append(htmlBody.substring(start + cid.length() + 4)).toString();
					}
				}
			}

		}
		if (htmlBody != null) {
			int sIdx = htmlBody.indexOf("<script");
			int eIdx = 0;
			if (sIdx < 0)
				sIdx = htmlBody.indexOf("<SCRIPT");
			while (sIdx > -1) {
				eIdx = htmlBody.indexOf("/script>");
				if (eIdx < 0)
					eIdx = htmlBody.indexOf("/SCRIPT>");
				htmlBody = htmlBody.substring(0, sIdx - 1) + htmlBody.substring(eIdx + 8);
				sIdx = htmlBody.indexOf("<script");
				if (sIdx < 0)
					sIdx = htmlBody.indexOf("<SCRIPT");
			}

			if (htmlBody.indexOf("$_RCPT_$") > -1) {
				htmlBody = htmlBody.substring(0, htmlBody.indexOf("$_RCPT_$")) + loginuser.emailId + "@"
						+ domainName
						+ htmlBody.substring(htmlBody.indexOf("$_RCPT_$") + 8, htmlBody.length());
			}
			
			if (htmlBody.indexOf("&amp;") > -1) {
				htmlBody = htmlBody.substring(0, htmlBody.indexOf("&amp;")) + "&"
						+ htmlBody.substring(htmlBody.indexOf("&amp;") + 5, htmlBody.length());
			}

			if (mailboxID == 2) {
				Document doc = Jsoup.parse(htmlBody); // JSOUP HTML 사용
														// 2012-12-04
				doc.select("#nekrecchk").remove();
				htmlBody = doc.html();
			}
			
			if (htmlBody.indexOf("<PRE>") > -1) {
				htmlBody = htmlBody.replaceAll("<PRE>", "<PRE style='word-wrap:break-word;'>");
			}

			if (htmlBody.indexOf("<base") > -1) {
				htmlBody = htmlBody.replaceAll("<base", "<div");
			}

			if (htmlBody.indexOf("<BASE") > -1) {
				htmlBody = htmlBody.replaceAll("<BASE", "<div");
			}
		}
		mailBodyValue = "<div style='word-break:break-all;'>" + htmlBody + "</div>";
	} else {
		String textBody = envelope.getTextBody();
		if (textBody != null) {
			textBody = textBody.replaceAll("<", "&lt;");
			textBody = textBody.replaceAll(">", "&gt;");
			mailBodyValue = "<pre style='word-wrap:break-word;'>" + textBody + "</pre>";
		}
	}

	String mailAttachValue = "";
	String baseURL = homePath;
	if (!baseURL.endsWith("/")) {
		baseURL += "/";
	}
	baseURL += "mail/mail_dn_attachment.jsp?message_name=" + message_name + "&path=";
	
	if (attachments != null && attachments.size() > 0) {
		StringBuffer attachmentBuf = new StringBuffer();
		Iterator iter = attachments.iterator();
		int count = 0;
		while (iter.hasNext()) {
			Attachment attachment = (Attachment) iter.next();
			String cid = attachment.getContentID();
			if (cid != null) {
				// 2013-02-08 가람시스템 본문 이미지만 제외함.
				if (cid.indexOf("GARAMSYSTEM") > -1) {
					continue;
				}
			}
			String fileName = attachment.getFileName();
			fileName = fileName.replace("\"", "");
			fileName = fileName.replace("|", "");
			
			if (count != 0) mailAttachValue += "<br>";
			mailAttachValue += "<a href=\""+baseURL+attachment.getPath()+"\" data-ajax=\"false\" title=\""+fileName+"\">"
							+fileName+"</a> <span>("+readableFileSize(attachment.getSize())+")</span>";
			count++;
		}
	}
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
	<title></title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Garam Mobile Demo</title>	
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
   
    <script type="text/javascript">
		var mailid = "<%=message_name %>";
    	var boxid = "<%=mailboxID %>";
    	var boxnm = "";
		var unread = "";

    	$("#page-list").live("pageshow", function(e) {
    		boxnm = $.urlParam("boxnm") || "";
    		unread = $.urlParam("unread") || "";
    		$("#mailBodyValue").find("a").attr("data-ajax", "false");
    	});
    	
    	$.urlParam = function(name){
    	    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
    	    if (!results) return "";
    	    return decodeURI(results[1]) || 0;
    	}
    	
    	function deleteMail() {
    		$.ajax({
    			type: "POST",
    			url: "/mail/mail_delete.jsp?box=" + boxid + "&mailid=" + mailid,
    			error: function(request, status, error) {
    				alert("code : " + request.status + " \r\nMessage : " + request.responseText);
    			},
    			success : function(response, status, request) {
   		    		location.href = "/mobile/mail/list.jsp?box=" + boxid + "&boxnm=" + boxnm + "&unread=" + unread;
    			}
    	  	});
    	}
    </script>
        <!----S: 2021리뉴얼 추가------->
<link rel="stylesheet" href="/mobile/css/mobile.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_sub_page.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_mail_read.css"/>
<script>
    $(document).ready(function(){
 
        $('#burger-check').on('click', function(){
            $('.menu_bg').show(); 
            $('.sub_ham_page').css('display','block'); 
            $('.sidebar_menu').show().animate({
                right:0
            });
            $('.ham_pc_footer_div').show().animate({
                bottom:0,right:0
            });
        });
        $('.close_btn>a').on('click', function(){
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
            function(){ $('.blindcopyto_span').text("닫기▲"); 
                        $('.blindcopyto_box').css('display','block');
                },

            function(){$('.blindcopyto_span').text("비밀참조인▼"); 
                       $('.blindcopyto_box').css('display','none');
        
               });

        
});
</script>

<script>
    $('body').delegate('.nav-search', 'pageshow', function( e ) {
        $('.ui-input-text').attr("autofocus", true)
    });			
</script>
<!----E: 2021리뉴얼 추가------->
</head>
<body>
<div data-role="page" id="page-list">
    <div class="main_contents_top">
    <div class="menu_bg"></div>
    <div class="sidebar_menu">
         <div class="close_btn">
            <a href="#">닫기 <img src="/common/images/m_icon/15.png"></a>
         </div>
         <div class="ham_user_name"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b></div>
         <div class="logout_btn" onClick="location.href='/logout.jsp'">로그아웃</div>
         <div class="menu_wrap">
             <div data-role="page" class="type-home sub_ham_page" id="page-home" style="position:relative;clear: both;z-index: 1;background: #fff;">
                 <div class="nav_div">
                 <div data-role="content">   
                 <ul data-role="listview" data-theme="a" data-divider-theme="a" data-filter="true" data-filter-theme="a" data-filter-placeholder="Search menu...">
                     <li data-filtertext="편지작성">
                        <a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">편지작성</a>
                    </li>
			        <li data-filtertext="<%=msglang.getString("main.E-mail") /* 전자메일 */ %> <%=msglang.getString("mail.InBox") /* 받은편지함 */ %>">
                        <a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("main.E-mail") /* 받은편지함 */ %></a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/appr/list.jsp?menu=240" data-ajax="false">전자결재</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/notification/list.jsp?boxId=1&noteType=0" data-ajax="false">사내쪽지</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000004" data-ajax="false">게시판</a>
                    </li>
                    <!--<li data-filtertext="">
                        <a href="" data-ajax="false">업무지원</a>
                    </li>-->
                    <li data-filtertext="">
                        <a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false">공지사항</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/addressbook/user.jsp" data-ajax="false">임직원정보</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/addressbook/list.jsp" data-ajax="false">주소록관리</a>
                    </li>
                </ul>
                </div>
                <div class="footer_pc_ver ham_pc_footer_div" onClick="location.href='/jpolite/index.jsp'" style="position:fixed;;background:#f5f5f5;width:80%;right:0;bottom:-100%;">
                    <img src="/common/images/m_icon/13.png"> PC버전으로 보기
                </div>
                </div>
             </div>
         </div>
    </div>

     <h1 class="left_logo">
         <a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">
            <img src="/common/images/icon/logo.png" height="29" border="0" >
        </a>
     </h1>
    <div class="right_menu" >
        <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
     </div>
</div>
	<div data-role="content" style="padding:5px;" class="ui-content_mail">
	    <div data-role="navbar" data-iconpos="left">
			<ul>
				<li><a href="/mail/mobile_mail_form_s.jsp?cmd=reply&message_name=<%=message_name %>" data-role="button" data-mini="true" data-inline="true" data-icon="arrow-r" data-theme="a" data-ajax="false"><fmt:message key="mail.reply"/><!-- 회신 --></a></li>
				<li><a href="/mail/mobile_mail_form_s.jsp?cmd=replyall&message_name=<%=message_name %>" data-role="button" data-mini="true" data-inline="true" data-icon="arrow-r" data-theme="a" data-ajax="false"><fmt:message key="mail.reply.all"/><!-- 전체회신 --></a></li>
				<li><a href="/mail/mobile_mail_form_s.jsp?cmd=forward&message_name=<%=message_name %>" data-role="button" data-mini="true" data-inline="true" data-icon="forward" data-theme="a" data-ajax="false"><fmt:message key="mail.convey"/><!-- 전달 --></a></li>
				<li><a href="javascript:deleteMail();" data-role="button" data-mini="true" data-inline="true" data-icon="delete" data-theme="a" data-ajax="false"><fmt:message key="t.delete"/><!-- 삭제 --></a></li>
			</ul>
		</div>
        <div class="date_text"><%=mailDateValue %></div>
		<p style="font-size:18px;" class="mail_title p_line"><b><%=HtmlEncoder.encode(envelope.getSubject())%></b></p>
		<hr/>
		<p style="font-size:14px;" class="p_line">
			<b><fmt:message key="t.outgoing"/><!-- 발신 -->  </b>
			<span class="span_left"><%=mailFromsValue %></span>
		</p>
        
        <p style="font-size:14px;" class="p_line">
			<b><fmt:message key="mail.sendto"/><!-- 수신 --></b> 
			<span class="span_left"><%=mailTosValue %></span>
		</p>
		
        <p style="font-size:14px;" class="p_line">
			<b><fmt:message key="mail.copyto"/><!-- 참조 --><br><span class="blindcopyto_span"><fmt:message key="mail.blindcopyto"/>▼<!-- 비밀참조 --></span></b> 
			<span class="span_left"><%=mailCcsValue %></span>
        </p>
        <p style="font-size:14px;" class="blindcopyto_box p_line">
			<span class="span_left"><%=mailBccsValue %></span>
        </p>
        
        <p style="font-size:14px;" class="file_box">
            <b><fmt:message key="t.attached"/><!-- 첨부 --></b> 
			<span class="span_left"><%=mailAttachValue %></span>
        </p>
  
		<hr/>
		<%-- <div class="ui-corner-all" style="/* border:1px solid #aaa; width:760px; */"></div> --%>
		
        <div id="mailBodyValue"><%=mailBodyValue %></div>

		
	</div>
    </div>


<style>
dt {padding:0px; margin:0px;}
.ui-btn-left, .ui-btn-right, .ui-input-clear, .ui-btn-inline, .ui-grid-a .ui-btn, .ui-grid-b .ui-btn, .ui-grid-c .ui-btn, .ui-grid-d .ui-btn, .ui-grid-e .ui-btn, .ui-grid-solo .ui-btn {
margin-right: 2px;
margin-left: 2px;
}
</style>
</body>
</fmt:bundle>
</html>