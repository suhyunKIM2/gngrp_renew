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
	// 메일 작성 권한이 없습니다.
}

if (envelope == null) {
	// 메일 작성
	to = request.getParameter("to");
} else {
	// 메일 수정/전달/회신/전체회신
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
					// 가람시스템 본문 이미지만 제외함. 2013-02-08
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

		//본문 이미지 별도 처리
		Collection attachments = envelope.getAttachments();
		if (attachments != null) {
			Iterator iter = attachments.iterator();
			while (iter.hasNext()) {
				Attachment attachment = (Attachment)iter.next();
				String cid = attachment.getContentID();
				if (cid != null) {
					//2013-02-08 가람시스템 본문 이미지만 제외함.
					if (cid.indexOf("GARAMSYSTEM") > -1) {
						attachDiv += "<input type='hidden' name='imghid' value='message_name=" + envelope.getMessageName() +"&path=" + attachment.getPath() + "／" + attachment.getFileName() +"'>";
					}
				}
			}
		}

		importance = envelope.getImportance();
	}

	// 메일 용량체크
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
<script src="/common/jquery/js/jquery-1.8.0.min.js"></script><!--2021리뉴얼 추가-->

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

var msgMoreThenOne = "<fmt:message key='mail.c.recipient.MoreThenOne'/>";	// 수신자가 한명 이상 있어야 합니다!
var msgSubjectRequired = "<fmt:message key='v.subject.required'/>";			// 제목을 입력하여 주십시요!
var msgSendMail = "<fmt:message key='mail.c.send.mail'/>";					// 메일을 발송하시겠습니까?

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
	
	// 진행 상태바
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

	var conf_tmpMsg = "<fmt:message key="c.save.temp"/>"; // 임시저장 하시겠습니까? 
	
	if (!confirm(conf_tmpMsg)) return;
	
	//임시저장임을 알림
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
<style>
body, div {
    font-size: 100%;
}
.ui-content{height:auto;border-top: 1px solid #eee;}
.ui-widget .ui-widget{font-size:9pt;}
.ui-icon-close{
        background-image: url(/common/jquery/mobile/1.2.0/images/icons-18-white.png) !important;
        background-size: auto;
        background-position: 9.5% 50% !important;
}
.ui-field-contain .ui-input-search {
    width: 97% !important;
    margin: 0 1.5% !important;
    border-radius: 0;
    border-color: #ddd;
    padding: 0 2%;
}
ul.autocompleteTag li{width:100%;padding: 0;border: 0;}
.ui-content{background:#fff;}
.ui-corner-all{border:0;}
.left_label{float:left;}
.ui-mini{width:75%;float:right;padding-top:0 !important;margin-top: 0;}
.ui-field-contain{border:0;font-size: 13px;}
label.ui-input-text{float:left;font-size: 13px;height: 35px;line-height: 35px;}
input.ui-input-text{width:87%;float: right;border: 1px solid #ccc;border-radius: 0;height: 36px;padding: 0 0 0 2%;font-size: 13px;}
.ui-menu .ui-menu-item a{white-space: pre-line;}
.ui-autocomplete{top:125px !important;width:66.3%;right:5.7%;border:1px solid #999;border-top:0;border-radius: 0;left:auto !important;}
.blue{color:#266fb5;}
input[name="autocomplete_check"]{vertical-align:top; }
.fieldcontain_box{clear: both;display: block;width:99.6%; border:1px solid #ccc;overflow: auto;height:50px;}
.file_btn{float:right;background:#266fb5;padding:1% 4%;font-size:13px;margin-bottom: 7px;}
.file_btn a{color:#fff !important;text-decoration: none;}
#txtContent{float:none;width: 95%;padding:5% 2.2% !important;border:1px solid #ccc;border-radius:0;font-size: 13px;border-top:0;min-height: calc(100vh - 500px);max-height: calc(100vh - 500px);overflow:auto;}

div.fileUploadSection div.fileUpWrapper div.uploadPathDiv{float:left;line-height:23px;height:25px;width:70%;border:1px solid #ccc;}

/*파일 추가 삭제*/
div.addAttachFileSection{float:left;width:100%;margin:5px 0 0 0;}
div.addAttachFileSection ul.attachFileList{float:left;list-style-type:none;padding:0;margin:0;width:100%;word-break:break-all;word-wrap:break-word;whilte-space:pre-wrap;}
div.addAttachFileSection ul.attachFileList li{border:0;padding:0;text-align:left;}
div.addAttachFileSection ul.attachFileList li span.removeAttach{border:1px solid #ccc;line-height:25px;padding:0 7px 0 7px;margin:0 4px 0 4px;}
div.addAttachFileSection ul.attachFileList li span.attachFileName{vertical-align:middle;line-height:25px;}
span.fileUp{font-size:13px;color:#fff;font-weight: 600;}

div#viewLoading {text-align:center;padding-top:120px;filter:alpha(opacity=60);opacity: alpha*0.6;background-color:#fff;color:#bcbfc4;}
div#viewLoading div.progressTitle{text-align:left;border:2px solid #111111;border-bottom:1px solid #111111;padding:15px 0 15px 0;width:99.2%;}
div#viewLoading div.progressTitle span{padding-left:3px;padding-bottom:5px;}
div#viewLoading div.progressWrapper{border:1px solid #111111;width:99.2%;text-align:center;}
div#viewLoading div.progressWrapper div.progresspercent{background-color:#1a1a1a;height:40px;border:1px solid #000000;}
div#viewLoading div.progressWrapper div.progresspercent span.percentwrapper{line-height:38px;}
div#viewLoading div.progressWrapper div.progresspercent span.percentwrapper span.pgbar{display:block;float:left;background-color:#fecf23;width:90%;}
div#viewLoading div.progressWrapper div.progresspercent span.percentwrapper span.pgpercent{position:absolute;left:30%;right:30%;color:#c0c0c0;}
div#viewLoading div.progressWrapper div.progresspercent span.percentwrapper span.pgpercent strong{font-weight:bold;}
div#viewLoading div.progressfilereadsize{margin:0 0 5px 0;height:40px;border:1px solid #111111;}
div#viewLoading div.progressfilereadsize span{line-height:40px;}
div#viewLoading div.progressfilereadsize span.divider strong{font-weight:400;}
div#viewLoading div.progressSpeed{margin:0 0 5px 0;height:40px;border:1px solid #111111;text-align:center;}
div#viewLoading div.progressSpeed span.kbps{line-height:40px;}
div#viewLoading div.progressSpeed span.kbps strong{font-weight:400;}

.pgbarbgcolor{background-color:#fecf23;}
.fileUp_0{display:none;}
.mailbody_name{width:100%;height:30px;line-height: 30px;background:#ccc;text-align: center;}
.che_ui_box{border:1px solid #ccc;border-top:0;padding:0 2.2%;width:95%;}
.che_ui_box ul li{border-bottom:0;display: inline-block;vertical-align: middle;}
.che_ui_box ul li label{background:none;border:0;width:auto;float:none;margin:0;}
.che_ui_box ul li input{margin:0;top: 10px;}
.save_btn_box{height:auto;overflow:hidden;}
.save_btn_box a{display:inline-block;float:none;width:auto;border: 0;border-radius: 0;}
.save_btn_box .btn_save{background:#e7e7e7;padding: 3% 11% !important;}
.save_btn_box .btn_send{background:#266fb5;padding: 3% 13% !important;}
.save_btn_box a .ui-icon{background: none !important;box-shadow: none;}
.save_btn_box a.ui-mini.ui-btn-icon-left .ui-btn-inner{padding:0;border: 0;}
.save_btn_box a.btn_send.ui-mini.ui-btn-icon-left .ui-btn-inner{color:#fff;}
.ui-field-contain:last-child{text-align: center;}
.none_hidden {display:none !important;}
@media all and (max-width:320px) {
.che_ui_box ul li input{top:4px;}
}
</style>
<!----E: 2021리뉴얼 추가------->
<script language='javascript' type='text/javascript'>
            // 라인을 늘일 변수
            var uf = '';
            // sw_file_add_form div에 input 태그를 추가하는 함수
            function sw_file_add(size, ext) {
                // 최초 sw_file_add_form에 추가하고 다음부터는 sw_file_add_form1, 2, 3, 4, ... 로 계속 추가가 된다.
                // 물론 그에 맞는 div도 계속 생성한다. 차후에 추가한 div를 제거하는 것도 필요하다.
                eval('sw_file_add_form' + uf).innerHTML += "<input type=file name=file[] size='" + size + "' " + ext + "><div id='sw_file_add_form" + (uf+1) + "'></div>";
                uf++;
            }
        </script>
</head>

<script type="text/javascript">
//input file의 인덱스번호로 쓰임(전역변수)
var fileIndex = 0;	


//업로드 파일 지정
var makeUploadElem = function(fileElemObj){
	fileIndex++;	//global var	
	var addAttachFileSectionElem = $("div").filter(".addAttachFileSection");
	var attachFileListElem = $(addAttachFileSectionElem).find("ul");	
	
	var targetElem=$("div#fileUpBtnWrapper");
	var fileElem=$("<input id='file"+fileIndex+"' class='file' type='file' value='' data-mini='true' name='file"+fileIndex+"' style='position: absolute;right:0px;top:0px; opacity:0; filter: alpha(opacity=0);cursor: pointer;outline:none;'/>");
	//var fileUpBtnElem = $("<span class='fileUp' style='font-size:0;'>&nbsp;파일</span>");
	
	$(fileElem).change(function(){
		makeUploadElem(this);	//recursive				
	});
	
	$(targetElem).append(fileElem);
	//$(targetElem).append(fileUpBtnElem);
	$(fileElemObj).hide();	
	
	//파일 목록 추가 / 삭제
	var fileElemObjVal = $(fileElemObj).val();	
	$(attachFileListElem).append(
		"<li>" +			
			"<span class='removeAttach' onClick='deleteFileList(this,"+fileIndex+");'>x</span>" +
			"<span class='attachFileName'>"+fileElemObjVal+"</span>" +
		"</li>"
	);			
	
	//$("div#debug").text($("div.fileUploadSection").html());
};
//업로드 파일 리스트 삭제
var deleteFileList = function(fileListElem,fileElemIndex){
	//기본으로 마크업된 input file의 인덱스 번호가 0으로 시작되는데
	//전역변수로 증가 시킨 상태이므로 -1을 시켜서 인덱스 번호를 맞춰준다.
	var fileElemIdx = fileElemIndex - 1;
	var fileUpBtnWrapElem = $("div").filter("#fileUpBtnWrapper");
	
	$(fileUpBtnWrapElem).find("input:file").filter("input[name=file"+fileElemIdx+"]").remove();	
	$(fileListElem).parent().remove();
	
	//$("div#debug").text($("div.fileUploadSection").html());
};

//전송이 완료되거나 실패시에도 input file과 li를 모두삭제 시켜주고
//전역변수로 사용된 인덱스를 초기화 시켜준다.
var deleteFileListAndFileElems = function(){
	var fileUploadSectionElem = $("div").filter(".fileUpWrapper");
	var addAttachFileSectionElem = $("div").filter(".addAttachFileSection").find("ul");
	$(fileUploadSectionElem).children().remove();
	$(addAttachFileSectionElem).children().remove();
	fileIndex = 0;
};
</script>
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

	
	<div data-role="content">
	
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
			<label for="reTo" class="left_label"><b><fmt:message key="mail.sendto"/><!-- 받는사람 --></b></label>
			<div class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_to" id="reTo" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="reCc" class="left_label"><b><fmt:message key="mail.copyto"/><!-- 참조인 --></b></label>
			<div class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_cc" id="reCc" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
			<label for="reBcc" class="left_label"><b><fmt:message key="mail.blindcopyto"/><!-- 비밀참조인 --></b></label>
			<div class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="padding:4px 3px 3px 3px;">
				<input data-mini="true" type="text" name="receive_bcc" id="reBcc" value="">
			</div>
		</div>
		<div data-role="fieldcontain">
        <div class="fileUploadSectionWrapper">
            <label for="filehidden"><b><fmt:message key="t.attached"/></b></label>
            <!-- 첨부파일 -->
            <div class="fileUploadSection file_btn">			
                <div class="fileUpWrapper">				
                    <div id="fileUpBtnWrapper" class="fileUpBtnWrapper" style="position:relative;">				 								
                        <%-- input의 id명 뒤의 숫자를 변경하지 말것(인덱스 번호로 사용됨) --%>				
                        <input id="file" onchange="makeUploadElem(this)" class='file' type="file" name="upFile[]" style="position: absolute;right:0px;top:0px; opacity:0; filter: alpha(opacity=0);cursor: pointer;outline:none;" / >					 				
                        <span class="fileUp">+ 파일추가</span>
                     </div>
                </div>
            </div>		
            <!-- 첨부추가/제거 -->
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
                <span class="fileUp">+ 파일 추가</span>
            </div>
            <div class="fieldcontain_box">
                <input type="file" name="file[]" size="50" class="input_write" />
        
             여기에 추가가 된다. 
            <div id="sw_file_add_form"></div>    
            </div>-->
          
            
			<!--<input data-mini="true" name="filehidden" id="filehidden" style="display: none;">
			<input type="file" name="file1" value="" data-mini="true" style="line-height: 2em;margin-left:13.5%;padding:0;">
			<input type="file" name="file2" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">
			<input type="file" name="file3" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">
			<input type="file" name="file4" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">
			<input type="file" name="file5" value="" data-mini="true" style="display: block;width: 78%; margin-left: 22%;line-height: 2em;">-->
		</div>
		<div data-role="fieldcontain">
			<label for="subject" class="left_label"><b><fmt:message key="mail.subject"/></b></label>
			<input data-mini="true" type="text" name="subject" id="subject" value="<%=subject %>">
		</div>
		<div data-role="fieldcontain" style="padding-bottom: 0;">
            <div class="mailbody_name"><b><fmt:message key="t.content"/><!-- 본문 --></b></div>
			<textarea data-mini="true" cols="40" rows="8" name="mailbody" id="mailbody" style="display: none;"></textarea>
			<div data-role="content" contenteditable="true" id="txtContent" 
				 class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="margin-bottom: 0;"></div>
		</div>
        <div class="che_ui_box">
            <ul>
                <li><b><fmt:message key="t.option"/><!-- 옵션 --></b></li>
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
</script>
</body>
</fmt:bundle>
</html>