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
<%@ page import="javax.mail.*" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="javax.mail.internet.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>		
					

<%!
	private MailRepository repository = MailRepository.getInstance(); //new MailRepository();

	private static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	private static HashMap SEARCH_FIELDS = new HashMap();
	static {
		SEARCH_FIELDS.put("subject", new String[] { "subject" });
		SEARCH_FIELDS.put("from", new String[] { "fromname", "sender" });
		SEARCH_FIELDS.put("all", new String[] { "subject", "fromname", "sender" });
		SEARCH_FIELDS.put("recieve", new String[] { "displayto" });
		SEARCH_FIELDS.put("all-rec", new String[] { "subject", "displayto" });
	}
/*
	private static String[] builtInMailboxes  = {
		"",
		"받은 편지함",
		"보낸 편지함",
		"임시 보관함",
		"지운편지함",
		"Pending",
		"예약함" //,	"HOT"	//Added By Kim Do Young for 디토소프트
	};
*/
	private static String[] builtInMailboxes  = {
		"",
		"받은편지함",
		"보낸편지함",
		"임시보관함",
		"지운편지함",
		"Pending",
		"예약편지함", //,	"HOT"	//Added By Kim Do Young for 디토소프트
		"스팸편지함"
	};
%>
<%@ include file="../common/usersession.jsp" %>

<%
	//협력업체 권한 체크
	if (loginuser.securityId < 1){
		out.print("<script language='javascript'>alert('사용권한이 없습니다.');history.back();</script>");
		out.close();
		return;
	}
	request.setCharacterEncoding("utf-8");
	
	String mainBoxID = request.getParameter("codekey");
	if(mainBoxID==null) mainBoxID = "";
	String unReadChk = request.getParameter("unread");
	if(unReadChk==null) unReadChk = "";

	//parameters -------------------------------------------------------
	ParameterParser pp = new ParameterParser(request);
	String cmd			= pp.getStringParameter("cmd", "list");
	int mailboxID		= pp.getIntParameter("box", Mailbox.INBOX);
	String searchText	= pp.getStringParameter("searchtext", "");
	String searchType	= pp.getStringParameter("searchtype", "");
	int pageNo			= pp.getIntParameter("pg", 1);

	//검색인 경우 검색 조건 설정 -------------------------------------------
	SearchConstraint constraint = null;
	if (searchText != "" && searchType != "") {
		String[] searchFields = (String[])SEARCH_FIELDS.get(searchType);
		if (searchFields != null) {
			constraint = new SearchConstraint();
			constraint.setSearchText(searchText);
			constraint.setSearchFields(searchFields);
		}
	}

	//DB 작업 --------------------------------------------------------------------
	ListPage listPage = null;
	Mailboxes mailboxes_rec = null;
	Mailboxes mailboxes_send = null;
	int iUnReadCnt = 0;

	DBHandler db = new DBHandler();
	Connection con = null;
	
    String[] sortLists = null;
    ConfigItem cfItem = null;
    Hashtable cfHash = null;
    List<OrganizationItem> archiveUserList = null;	//저널링 설정된 사용자 목록
	try {
		con = db.getDbConnection();
		
		//도메인 주소를 가져오자.
		cfHash = ConfigTool.getConfigs(con);
		
	    cfItem = ConfigTool.getConfigValue(con, application.getInitParameter("CONF.DOMAIN"));
	    String domainName = cfItem.cfValue;
		//개인편지함 가져오기--------------------------------------------------------
		mailboxes_rec = repository.getCustomMailboxes(con, loginuser.emailId, 1, domainName);	//받은편지함
		mailboxes_send = repository.getCustomMailboxes(con, loginuser.emailId, 2, domainName);	//보낸편지함

		archiveUserList = repository.getArchiveUserList(con);
	} finally {
		if (con != null) {
			db.freeDbConnection();
		}
	} //END DB 작업

	

	//현재 메일함의 이름 구하기 ----------------------------------------------
    String NavMailBoxName = "전체메일함" ;
%>
<%
	// 폴더 이동시 선택 OPTION 문자열 ---------------------------------------------
	StringBuffer selBoxBuf = new StringBuffer();
	int selectBox = 0; // 선택된 메일 MainBoxId(1:받은편지함/2:보낸편지함)
	
	Iterator mailbox_temp1 = mailboxes_rec.iterator();
	Iterator mailbox_temp2 = mailboxes_send.iterator();
	switch(mailboxID) {
		case 1 : selectBox = 1; break;
		case 2 : selectBox = 2; break;
	}
	while (mailbox_temp1.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_temp1.next(); 
		if (mailboxID==mailbox.getID()) selectBox = mailbox.getMainBoxId();
	}
	while (mailbox_temp2.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_temp2.next();
		if (mailboxID == mailbox.getID()) selectBox = mailbox.getMainBoxId();
	}

	if (mailboxID != Mailbox.INBOX && selectBox == Mailbox.INBOX) {
		selBoxBuf.append("<option value='" + Mailbox.INBOX + "'>받은편지함</option>");
	}
	//if (mailboxID != Mailbox.HOT) {
	//	selBoxBuf.append("<option value='" + Mailbox.HOT + "'>HOT</option>");
	//}
	//if (mailboxID != Mailbox.DRAFT && mailboxID != Mailbox.INBOX) {
	//	selBoxBuf.append("<option value='" + Mailbox.DRAFT + "'>임시보관함</option>");
	//}
	if (mailboxID != Mailbox.TRASH) {
		selBoxBuf.append("<option value='" + Mailbox.TRASH + "'>휴지통</option>");
	}	
// 	selBoxBuf.append("<option value='division'>-----개인편지함-----</option>");
	
	
	Iterator mailbox_iter1 = mailboxes_rec.iterator();
	Iterator mailbox_iter2 = mailboxes_send.iterator();
	int iter1 = 0;
	while (mailbox_iter1.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_iter1.next();
		//받은편지함에서 보낸편지함으로 이동은 안된다!!!
// 		if(mailbox.getID()==mailboxID){
// 			selectBox = mailbox.getMainBoxId();
// 		}else if(mailboxID==1){
// 			selectBox = 1;
// 		}else if(mailboxID==2){
// 			selectBox = 2;
// 		}
		if (mailboxID != mailbox.getID()) {
			if(selectBox==1){	//받은편지함이면 보낸편지함으로 이동은 막는
				if(mailbox.getMainBoxId()==2) continue;
			} else if (selectBox==2){ 
				if(mailbox.getMainBoxId()==1) continue;
			}
			if (iter1 == 0) {
// 				selBoxBuf.append("<optgroup label='받은 개인편지함'>");
				selBoxBuf.append("<option value='division'>-----받은 개인편지함-----</option>");
			}
			selBoxBuf.append("<option value='" + mailbox.getID() + "'>"
				+ mailbox.getName()+ "</option>");
			iter1++;
		}
	}
// 	if (iter1 != 0) selBoxBuf.append("</optgroup>");
	//selBoxBuf.append("<option value='division'>-----보낸편지함-----");
	int iter2 = 0;
	while (mailbox_iter2.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_iter2.next();
		//받은편지함에서 보낸편지함으로 이동은 안된다!!!
// 		if(mailbox.getID()==mailboxID){
// 			selectBox = mailbox.getMainBoxId();
// 		}else if(mailboxID==1){
// 			selectBox = 1;
// 		}else if(mailboxID==2){
// 			selectBox = 2;
// 		}
		if (mailboxID != mailbox.getID()) {
			if(selectBox==1){	//받은편지함이면 보낸편지함으로 이동은 막는
				if(mailbox.getMainBoxId()==2) continue;
			} else if (selectBox==2){ 
				if(mailbox.getMainBoxId()==1) continue;
			}
			if (iter2 == 0) {
// 				selBoxBuf.append("<optgroup label='보낸 개인편지함'>");
				selBoxBuf.append("<option value='division'>-----보낸 개인편지함-----</option>");
			}
			selBoxBuf.append("<option value='" + mailbox.getID() + "'>"
				+ mailbox.getName()+ "</option>");
			iter2++;
		}
	}
// 	if (iter2 != 0) selBoxBuf.append("</optgroup>");
	String selBoxes = selBoxBuf.toString();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<title><fmt:message key="mail.list"/>&nbsp;<!-- 메일목록 --></title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">
<%-- <link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css"> --%>
<script src="<%=scriptPath %>/common.js"></script>
<script src="<%=scriptPath %>/list.js"></script>
<script src="<%=scriptPath %>/xmlhttp.vbs" language="vbscript"></script>


<script language="javascript">
	//SetHelpIndex("mail_list");
</script>

<script src="/common/scripts/common.js" ></script>

<!-- jquery grid -->
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.jqgrid.css"  />
<link rel="stylesheet" href="/common/css/style.css">

<link type="text/css" href="/common/css/styledButton.css" rel="stylesheet" />

<script src="/common/jquery/js/jquery-1.6.4.min.js"  type="text/javascript"></script>
<script src="/common/jquery/js/i18n/grid.locale-en.js"  type="text/javascript"></script>
<script src="/common/jquery/plugins/jquery.jqGrid.min.js" type="text/javascript"></script>
<!-- jquery grid -->

<script src="/common/jquery/plugins/jquery.validate.js"  type="text/javascript"></script>
<script src="/common/jquery/plugins/modaldialogs.js"  type="text/javascript"></script>

<!-- datepicker -->
<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js" type="text/javascript"></script>

<!-- jquery : qTip -->
<!-- <script src="/common/jquery/plugins/jquery.qtip.min.js" type="text/javascript"></script> -->

<!-- gtip2 -->
<link rel="stylesheet" type="text/css" media="screen" href="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.css" />
<script src="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.js" type="text/javascript"></script>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<style type="text/css"> 
	#search_dataGrid .ui-pg-div { display: none; }					/* jqgrid search hidden */
	#dataGridPager { height: 30px; }								/* jqgrid pager height */
	.ui-jqgrid .ui-pg-selbox { height: 23px; line-height: 23px; }	/* jqgrid pager select height */

.jqgrid-header { 
    background:#FF9C00 url('/common/jquery/css/redmond/images/ui-bg_gloss-wave_55_5c9ccc_500x100.png') repeat-x scroll 50% 50%;
    border:1px solid #4297D7;
    color:#FF0000;
    font-weight:bold;
  }

/* .ui-jqgrid .ui-jqgrid-htable th {height:26px;padding: 3px 5px 0 3px;} */
.ui-jqgrid .ui-jqgrid-htable th {height:26px;padding: 3px 0px 0px 4px;}

	/* 미리보기 */
	.p { width:15px; border:1px solid #A1B5FE; border-collapse:collapse; background-color:#FFFFFF;}
	.p td { line-height:15px; border:1px solid #A1B5FE; cursor:hand; }
	.p_sel { width:15px; border:2px solid #A1B5FE; border-collapse:collapse; background-color:#D7E4F5;}
	.p_sel td {line-height:15px; border:2px solid #A1B5FE; cursor:hand; }
</style>

<script language="javascript">
var winx = 0;
var winy = 0;

/* 리스트 첨부 조회 */
function dShowAttach( docId ) {
	winx = window.event.x-265;
	winy = window.event.y-40;
	var url = "./get_attach_info.jsp?message_name=" + docId  + "&box=<%=mailboxID %>";
	
	xmlhttpRequest( "GET", url , "afterShowAttach" ) ;
}

/* 리스트 첨부 조회 */
function ShowAttach( docId ) {
	winx = window.event.x-265;
	winy = window.event.y-40;
	var url = "./get_attach_info.jsp?message_name=" + docId  + "&box=<%=mailboxID %>";
	
	//xmlhttpRequest( "GET", url , "afterShowAttach" ) ;
	
	ajaxRequest("GET", "", url, showAttachCompleted);
}

function showAttachCompleted(data, textStatus, jqXHR) {
	wid = 250 ;
	hei = 105;

	ModalDialog({'t':'다운로드', 'lp':winy, 'tp':winx, 'w':350, 'h':170, 'm':'html', 'c':data, 'modal':false, 'd':false, 'r':false });
}

/* 메일 팝업 액션 */ 
function OnClickAction(cmd) {
	switch(cmd){
		case "read" : 
			OnClickOpenNewWin(fmMailList.message_name.value);
			break;
		case "reply" :
			var url = "./mail_form.jsp?message_name=" + fmMailList.message_name.value + "&cmd=" +cmd;
			OpenWindow( url, "", "850" , "620" );
			break;
		case "forward" :
			var url = "./mail_form.jsp?message_name=" + fmMailList.message_name.value + "&cmd=" +cmd;
			OpenWindow( url, "", "850" , "620" );
			break;
		case "search" :
			fmMailList.searchtext.value = fmMailList.fromaddress.value;
			fmMailList.searchtype.value= "from";
			fmMailList.method = "post";
			fmMailList.pg.value = 1;
			fmMailList.action = "./mail_archive_list.jsp";
			//fmMailList.submit();
			gridReload();
			break;
		case "addressbook_s" :
			//var url = "/addressbook/addressbook_s_form.jsp?acid=ALL&name=" + encodeURI(fmMailList.fromname.value) + "&email=" + fmMailList.fromaddress.value;
			var url = "/addressbook/form.htm?name=" + encodeURI(fmMailList.fromname.value) + "&email=" + encodeURI(fmMailList.fromaddress.value);
			OpenWindow( url, "", "755" , "610" );
			break;
		case "spam" :
			var url = "./mail_spam_pop.jsp?message_name=" + fmMailList.message_name.value + "&email=" + encodeURI(fmMailList.fromaddress.value);
			OpenWindow( url, "", "300" , "200" );
			break;
		case "rule" :
			var url = "./mail_rule_popup.jsp?sendaddr=" + encodeURI(fmMailList.fromaddress.value);
			OpenWindow( url, "", "700" , "160" );
			break;
	}
}

function onShowSender(message_name, fromName, email) {
	
	return;
	
	var statusStr ;
	oPopup = window.createPopup();
	var oPopupBody = oPopup.document.body;
	oPopupBody.innerHTML = document.all.val.innerHTML ;

	//해당 메일 ID / 발신자 히든으로 셋팅
	document.fmMailList.message_name.value = message_name;
	document.fmMailList.fromname.value = fromName;
	document.fmMailList.fromaddress.value = email;

	winx = window.event.x+15;
	winy = window.event.y-12;

	wid = 190 ;
	hei = 190;

//	x = window.event.x-265;
//	y = window.event.y-40;
	oPopup.show(winx, winy, wid, hei , document.body);
}


function OnClickCheckReceipt(messageName) {
	window.showModalDialog("mail_receiptstatus.jsp?message_name=" + messageName,"","dialogHeight: 300px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
}

function OnClickDelete() {
	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		alert("<fmt:message key='mail.c.notDoc.delete'/>");//삭제할 문서가 없습니다!
		return;
	}

	var selected = false;
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			break;
		}
	}

	if (!selected) {
		alert("<fmt:message key='c.del.select.required'/>");//삭제할 문서를 선택하세요!
		return;
	}

	var conf_delMsg = "<fmt:message key='c.delete'/>";//삭제 하시겠습니까?
	var box = getUrlVar("box");
	if (box == 4) 
		conf_delMsg = "주의하십시오 ! \n지운편지함에서 삭제 시 메일이 완전히 삭제됩니다.\n삭제하시겠습니까 ?"; // 한국어 전용

	
	if (confirm(conf_delMsg)) {

		fmMailList.action = "mail_delete.jsp";
		fmMailList.ctype.value = "1";
		fmMailList.method = "post";
		fmMailList.submit();
	}
}

function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}

function getUrlVar(name) {
	return getUrlVars()[name];
}

function OnSpamDelete() {
	var msgs = document.getElementsByName("mailid");

	var selected = false;
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			break;
		}
	}

	if (!selected) {
		alert("<fmt:message key='mail.c.select.mail'/>");//메일을 선택해 주십시오.
		return;
	}

	if (confirm("<fmt:message key='mail.c.select.unblock'/>")) {
		fmMailList.action = "mail_spam_delete.jsp";
		fmMailList.ctype.value = "1";
		fmMailList.method = "post";
		fmMailList.submit();
	}
}

function OnClickClearTrash() {
	if (confirm("<fmt:message key='mail.c.delete.all.trash'/>")) { //휴지통 내의 모든 문서를 삭제합니다. 계속하시겠습니까?
		fmMailList.action = "/mail/mail_cleartrash.jsp";
		fmMailList.method = "post";
		fmMailList.submit();
	}
}

function reMailSend(){
	var msgs = document.getElementsByName("mailid");
	var selected = false;
	var totCnt = 0;
	var mailId = "";
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			mailId = msgs[i].value;
			totCnt = totCnt + 1;
		}
	}

	if (!selected) {
		alert("<fmt:message key='mail.c.select.redial'/>");//재발신 할 문서를 선택해주십시오.
		return;
	}
	if(totCnt >1){
		alert("<fmt:message key='mail.c.selectOne.redial'/>!");//재발신 할 문서는 1개만 선택하세요!
		return;
	}
	
	var url = "./mail_form.jsp?message_name=" + mailId;
	OpenWindow( url, "", "850" , "620" );
}
function OnClickPop3() {
	self.location = "/mail/mail_pop3support.jsp";
}

//메일 복구
function OnClickRestore(){
	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		return;
	}

	var selected = false;
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			break;
		}
	}

	if (!selected) {
		alert("복구할 메일을 선택하세요!");
		return;
	}
	
	if(confirm("메일을 복구하시겠습니까? ")){
		fmMailList.action = "mail_restore.jsp";
		fmMailList.ctype.value = "1";
		fmMailList.method = "post";
		fmMailList.submit();	
	}
}

function OnClickMove() {
	var targetMailbox = fmMailList.targetFolder.value;
	if (targetMailbox == "title" || targetMailbox == "division") {
		alert("<fmt:message key='mail.c.select.mailbox.move'/>");//이동할 편지함을 선택하세요!
		return;
	}

	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		return;
	}

	var selected = false;
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			break;
		}
	}

	if (!selected) {
		alert("이동할 문서를 선택하세요!");
		return;
	}
	fmMailList.action = "mail_move.jsp";
	fmMailList.ctype.value = "1";
	fmMailList.method = "post";
	fmMailList.submit();
}

function OnClickToggleAllSelect() {
	var items = document.getElementsByName("mailid");
	if (items != null && items.length > 0) {
		var checked = !items[0].checked;
		for (var i = 0; i < items.length; i++) {
			items[i].checked = checked;
		}
	}
}

function OnClickSearch() {
	var searchtext = fmMailList.searchtext.value;

	if (searchtext == "") {
		alert("<fmt:message key='v.query.required'/>");//검색어를 입력하여 주십시요!
		fmMailList.searchtext.focus();
		return;
	}

	fmMailList.method = "post";
	fmMailList.pg.value = 1;
	fmMailList.action = "./mail_archive_list.jsp";
	fmMailList.submit();
}

function OnClickEdit(message_name) {
	var url = "./mail_form.jsp?message_name=" + message_name;
	//OpenWindowNoScr( url, "", "755" , "610" );
	OpenWindow( url, "", "850" , "620" );
}


function OnClickOpen(message_name, importance, userName, mailDir) {
	var readChk = document.getElementById("mchk_"+message_name);	//안읽은 편지 읽음표시
	var boldObj = document.getElementById("bl_"+message_name);	//제목강조 제거

// 	var fr_list = parent.document.getElementById("fr_list");
// 	var fr_right = parent.document.getElementById("fr_preview_right");
// 	var fr_bottom = parent.document.getElementById("fr_preview_bottom");

	var url = "/mail/mail_archive_read.jsp?message_name=" + message_name + "&box=<%=mailboxID %>&importance=" + importance + "&username=" + userName + "&maildir=" + mailDir;
	var urlRB = "/mail/mail_view.jsp?message_name=" + message_name + "&box=<%=mailboxID %>&importance=" + importance + "&username=" + userName;

	//var objWin = OpenLayer(url, "Mail", winWidth, winHeight,isWindowOpen);	//opt는 top, current
	OpenWindow( url, "", "850" , "650" );
}


function OnClickOpenNewWin(messageName) {
	var WinWidth = 850 ; 
	var WinHeight = 620 ; 
	var winleft = (screen.width - WinWidth) / 2;
	var wintop = (screen.height - WinHeight) / 2;
	var UrlStr = "./mail_archive_read.jsp?front=&message_name=" + messageName ;
	var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
}

function OnClickSave(){
	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		alert("<fmt:message key='mail.c.notDoc.selected'/>");//선택된 문서가 없습니다!
		return;
	}

	var selected = false;
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			break;
		}
	}

	if (!selected) {
		alert("<fmt:message key='mail.c.select.doc'/>");//문서를 선택하세요!
		return;
	}
	
	fmMailList.action = "mail_backup_select.jsp";
	fmMailList.method = "POST";
	fmMailList.submit();
}

function goSubmit(cmd){
	if(cmd=="NEW"){
		//document.location.href = "./mail_form.jsp";
		var url = "./mail_form.jsp";
		OpenWindow( url, "", "850" , "620" );
		//targetWin = OpenWindowNoScr( url, "", "800" , "650" );
	}else if("list"){
		//document.location.href = "mail_list.jsp";
		fmMailList.searchtext.value= "";
		fmMailList.searchtype.value= "";
		fmMailList.action = "mail_archive_list.jsp";
		fmMailList.method = "POST";
		fmMailList.submit();
	}
}

function goMail(url){
	OpenWindowNoScr( url, "", "800" , "620" );
}

function OnMailCancel(msgID, nekMsgId) {
	if (confirm("<fmt:message key='정말 발송된 메일을 취소하시겠습니까?=Are you sure you want to cancel the mail was really sent?'/>")) {//정말 발송된 메일을 취소하시겠습니까?

		fmMailList.action = "mail_cancel.jsp";
		fmMailList.ctype.value = "1";
		fmMailList.message_name.value = msgID;
		fmMailList.nekmsgid.value = nekMsgId;
		fmMailList.method = "post";
		fmMailList.submit();
	}
}

function div_resize() {
	var objDiv = document.getElementById("viewList");
	var objTbl = document.getElementById("viewTable");
	var objPg = document.getElementById("viewPage");

	//objDiv.style.width = document.body.clientWidth - 30;
   	objDiv.style.height = document.body.clientHeight - 110 ;
}

function chkBg() {
	var chkbox = window.event.srcElement;
	var tr = chkbox.parentElement.parentElement;
	if ( chkbox.checked ) {
		tr.style.backgroundColor = "#D5E2F5";
	} else {
		tr.style.backgroundColor = "#EEEEF4";
	}
}

function goSpam(){
	var url = "/mail/mail_spamlist.jsp";
	OpenWindow( url, "", "350" , "450" );
}

function showDetailSearch(){
	var deSearch = document.getElementById("detail_search");
	if(deSearch.style.display==""){
		deSearch.style.display = "none";
	}else{
		deSearch.style.display = "";
	}
}

function onClickcr(){
	var frm = document.fmMailList;
	
	document.getElementsByName("sel_period")[0].selectedIndex = 6;
}

function validCheck(){
	var frm = document.fmMailList;
	
	var startDate = document.getElementsByName("startDate")[0];
	var endDate = document.getElementsByName("endDate")[0];
	var sel_period = document.getElementsByName("sel_period")[0];

	var sType = sel_period.options[sel_period.selectedIndex].value;
	
	//var sType = frm.sel_period.options[frm.sel_period.selectedIndex].value;
	if(sType!=0){	//전체가 아니면 날짜 체크함.
		if(startDate.value==""){
			alert("시작일자를 선택해주세요");
			startDate.focus();
			return false;
		}
		if(endDate.value==""){
			alert("종료일자를 선택해주세요");
			endDate.focus();
			return false;
		}
		if(startDate.value>endDate.value){
			alert("기간선택이 올바르지 않습니다");
			return false;
		}
	}
	return true;
}

//상세검색 기간 콤보
function setDatePeriod(){
	var frm = document.fmMailList;
	var newDt = new Date();
	var befDate = "";
	var nowDate = converDateString(newDt);
	
	var sel_period = document.getElementsByName("sel_period")[0];
	
	var sType = sel_period.options[sel_period.selectedIndex].value;
	if(sType==1){	//1주일
		newDt.setDate( newDt.getDate() - 7 );
		befDate = converDateString(newDt);
	}else if(sType==2){	//1개월
		newDt.setMonth( newDt.getMonth() - 1 );
		befDate = converDateString(newDt);
	}else if(sType==3){	//3개월
		newDt.setMonth( newDt.getMonth() - 3 );
		befDate = converDateString(newDt);
	}else if(sType==4){	//6개월
		newDt.setMonth( newDt.getMonth() - 6 );
		befDate = converDateString(newDt);
	}else if(sType==5){	//1년
		newDt.setFullYear( newDt.getFullYear() - 1 );
		befDate = converDateString(newDt);
	}else if(sType==0){	//전체
		berDate = "";
		nowDate = "";
	}
	
	if(sType!=99){
		document.getElementsByName("startDate")[0].value= befDate;
		document.getElementsByName("endDate")[0].value= nowDate;
	}
}

function converDateString(dt){
	return dt.getFullYear() + "-" + addZero(eval(dt.getMonth()+1)) + "-" + addZero(dt.getDate());
}

function addZero(i){
	var rtn = i + 100;
	return rtn.toString().substring(1,3);
}


//상세검색 메일함 - 전체인 경우만  필터 제공(휴지통/스팸함)
function setChangeMailbox(){
	var frm = document.fmMailList;
	var sel_mailbox = document.getElementsByName("sel_mailbox")[0];
	var mailBoxId = sel_mailbox.options[sel_mailbox.selectedIndex].value;
	if(mailBoxId==0){
		jQuery("input[name='rdo_srch']").each(function(i) {
			jQuery(this).attr('disabled', false);
		});
	}else{
		jQuery("input[name='rdo_srch']").each(function(i) {
			jQuery(this).attr('disabled', true);
		});
	}
}
</script>

<!-- jqgrid 추가 -->
<script type="text/javascript">
	var mailboxID = "<%=mailboxID %>";
	var unread = "<%=unReadChk%>";
	var codekey = "<%=mainBoxID %>";
	
	// 배열에 값이 있으면 넣지 않고 반환, 있으면 넣고 반환.001 LSH
	Array.prototype.checkPush = function(args) {
		var check = true;
		for(var i in this) if (this[i] == args) { check = false; continue; }
		if (check) this.push(args);
		return this;
	};
	
	$(document).ready(function(){
		if(navigator.userAgent.indexOf('Firefox') >= 0){			//파이어폭스 window.event 사용
			(function(){
				var events = ["mousedown", "mouseover", "mouseout", "mousemove", "mousedrag", "click", "dblclick"];
				for (var i = 0; i < events.length; i++){
					window.addEventListener(events[i], function(e){
						window.event = e;
					}, true);
				}
			}());
		};
		
		$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	
		$('input[id=startDate], input[id=endDate]').datepicker({
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

		var grid = $("#dataGrid");
		$("#dataGrid").jqGrid({        
		    scroll: true,
		   	url:"./data/mail_archive_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey,
			datatype: "json",
			width: '100%',
			height:'100%',
		   	colNames:['<img src="../common/images/btn_checkbox.gif" onClick="OnClickToggleAllSelect()" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<fmt:message key="mail.sender"/>', /*발신인*/
		   				'<fmt:message key="mail.recipient"/>', /*수신인*/
		   				'Email ID',
		   				'<img src="../common/images/icon-flag.png" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<img src="../common/images/icons/icon_attach.gif" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<img src="../common/images/icon-mail.png" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<fmt:message key="mail.subject"/><!-- 제목 -->',
		   				<%=(mailboxID == Mailbox.RESERVED) ? "'예약일시'" : "'날짜'"%>,'<fmt:message key="mail.size"/><!-- 크기 -->'],
		   	colModel:[
		  	   	{name:'checkbox',index:'checkbox', width:15, align:"center", sortable: false},
		   		{name:'fromname',index:'fromname', width:60, align:"left"},
		   		{name:'displayto',index:'displayto', width:100, align:"left"},
		   		{name:'user_name',index:'user_name', width:80, align:"center"},
		   		{name:'importance',index:'importance', width:12, align:"center", padding:"0px;"},
				{name:'hasattachment',index:'hasattachment', width:12, align:"center"},
		   		{name:'isread',index:'isread', width:12, align:"center"},
		   		{name:'subject',index:'subject', width:200, align:"left"},
		   		{name:<%=(mailboxID == Mailbox.RESERVED) ? "'reserved'" : "'created'" %>,
		   				index:<%=(mailboxID == Mailbox.RESERVED) ? "'reserved'" : "'created'" %>, width:80, align:"left"},
		   		{name:'mailsize',index:'mailsize', width:50, align:"right"}
			],	
		   	rowNum: <%=uservariable.listPPage %>,
		   	rowList: [10,20,30].checkPush(<%=uservariable.listPPage %>).sort(),
		   	mtype: "GET",
			prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
		   	pager: '#dataGridPager',
		    viewrecords: true,
		    sortname: 'created',
		    sortorder: 'desc',
		    scroll:false,
		    
		    pginput: true,	/* page number set */
		    gridview:true,	/* page number set */
		    
// 		    multiselect: function(id) {
// 		    	if ( event.srcElement.tagName == "B" ) {
// 	    			if ( chk[id-1].checked ) {
// 	    				chk[id-1].checked = false;
// 	    			} else {
// 	    				chk[id-1].checked = true;
// 	    			}
// 	    			alert('test');
// 	    		}
// 		    },
			multiselect:true, //10.05 일 김정국 수정.
		    onSelectRow: function(id){	//1~...
		    	var chk = document.getElementsByName("mailid");
		    	var isChecked = $("#jqg_dataGrid_" + id).attr('checked');
	    		chk[id-1].checked = isChecked;
	    		
	    		// link click ... checkbox check pass //10.05 일 김정국 수정.
	    		if ( event.srcElement.tagName == "B" || event.srcElement.tagName == "FONT" ) {
	    			if ( $("#jqg_dataGrid_" + id).attr('checked') ) {
		    			$("#jqg_dataGrid_" + id).attr('checked',false);
		    			chk[id-1].checked = false;
	    			} else {
	    				$("#jqg_dataGrid_" + id).attr('checked',true);
		    			chk[id-1].checked = true;
	    			}
	    		}
		    },
			loadError:function(xhr,st,err) { $("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText); },
		    loadComplete: function() {
		    	
		    	/* jqGrid PageNumbering Trick */
		    	var i, myPageRefresh = function(e) {
		            var newPage = $(e.target).text();
		            grid.trigger("reloadGrid",[{page:newPage}]);
		            e.preventDefault();
		        };
		        
		    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
		        jqGridNumbering( grid, this, i, myPageRefresh );

		        $('tr', this).each(function(key, item) {
			      	$($('td:eq(2)',item)).qtip({
							content: document.getElementById("val").innerHTML,
							style: {width:200,padding:0,background:'#fff',color:'#FFF','font-size':'11px',
							textAlign: 'left',
							border: {width:1,radius:1,color:'#72a9d3'},
							//tip: 'botttomLeft',
							
							name: 'dark' // Inherit the rest of the attributes from the preset dark style
						},

						position: {
							//target: 'mouse',
							my: 'left center', // ...at the center of the viewport
							at: 'right center',
						
							corner: {target:'topMiddle', tooltip:'bottomLeft'},
							adjust: {
								screen: true
							}
						},
						hide: {when:'mouseout', fixed:true, delay:100},
						show: {
							when: { target: false, event: 'mouseover' },
							delay: 100,
							solo: false,
							ready: false
						},
						events: {
							show: function(event, api) {
								var mails = document.getElementsByName("mailinfo");
						      	if($($('td:eq(2)',item))){
						      		if(mails[key-1]){
						      			var tmp = mails[key-1].value.split('／');;
						      			document.fmMailList.message_name.value = tmp[0];
						      			document.fmMailList.fromname.value = tmp[1];
						      			document.fmMailList.fromaddress.value = tmp[2];
						      		}
						      	}
							}
						}
// 						api: {
// 							onShow: function() {
// 								alert();
// 								var mails = document.getElementsByName("mailinfo");
// 						      	if($($('td:eq(2)',item))){
// 						      		if(mails[key-1]){
// 						      			var tmp = mails[key-1].value.split('／');;
// 						      			document.fmMailList.message_name.value = tmp[0];
// 						      			document.fmMailList.fromname.value = tmp[1];
// 						      			document.fmMailList.fromaddress.value = tmp[2];
// 						      		}
// 						      	}
// 							}
// 						}
					}
			      	);
			      	
		        });
		        
		    	$('#totalCnt').html($('#dataGrid').jqGrid('getGridParam','records')); 
		    }
		});
		
		$("#dataGrid").jqGrid('hideCol','checkbox');	//10.05 일 김정국 수정.
		$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:true,edit:false,add:false,del:false});
		
		/* listResize */
		gridResize("dataGrid");
				
		$("#cb_dataGrid").click( function() {
			var chk = document.getElementsByName("mailid");
			for( var i=0; i < chk.length; i++ ) {
    			chk[i].checked = $("#jqg_dataGrid_" + (i+1) ).attr('checked');
			}
		} );
		
		$("#resetSearch").hide();
		
		//$('select[name=searchtype] > option[value="<%=searchType %>"]').attr("selected","true");
		
		//상세검색 적용
		$('#btn_detail_search').qtip(
		{
			id: 'modal', // Since we're only creating one modal, give it an ID so we can style it
			content: {
				text: $('#detail_search'),
				title: {
					text: 'Mail Search',
					button: true
				}
			},
			position: {
				my: 'top right', // ...at the center of the viewport
				at: 'bottom right'
				//target: $(window)
				
			},
			show: {
				target: $('#btn_detail_search'),
				event: 'click', // Show it on click...
				solo: false // ...and hide all other tooltips...
				//modal: true // ...and make it modal
			},
			hide: true,
			style: 'qtip-light qtip-rounded',
			classes: 'ui-tooltip-bootstrap'
		});
	});
	
	function gridReload(){
		var searchtype = $("input[name=searchtype]").val();
		var selDomain = $("select[name=selDomain]").val();
		var selEmail = $("select[name=selEmail]").val();
		var boxType = $("select[name=boxType]").val();
		var searchtext = encodeURI($("input[name=searchtext]").val(), "UTF-8");
		var reqUrl = "./data/mail_archive_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey 
				   + "&searchtype=" + searchtype + "&searchtext=" + searchtext + "&sel_domain=" + selDomain + "&selemail=" + selEmail + "&boxtype=" + boxType;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		if (searchtext != "") $("#resetSearch").show(); else $("#resetSearch").hide();
	}
	
	function goSearch(){
		
		if(!validCheck()) return;
		
		//수발신 검색
		var sel_receiver = $("select[name=sel_receiver]").val();
		var ipt_receiver = encodeURI($("input[name=ipt_receiver]").val(), "UTF-8");
		//본문검색
		var sel_content = $("select[name=sel_content]").val();
		var ipt_content = encodeURI($("input[name=ipt_content]").val(), "UTF-8");
		//메일함 검색
// 		var sel_mailbox = $("select[name=sel_mailbox]").val();
// 		var rdo_srch = $("input[@name=rdo_srch]:checked").val();
// 		if(sel_mailbox!=0) rdo_srch = "";
		//검색기간
		var sel_period = $("select[name=sel_period]").val();
		var startdate = $("input[name=startDate]").val();
		var enddate = $("input[name=endDate]").val();
		
		var reqUrl = "./data/mail_archive_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey 
				   + "&sel_receiver=" + sel_receiver + "&ipt_receiver=" + ipt_receiver
				   + "&sel_content=" + sel_content + "&ipt_content=" + ipt_content
// 				   + "&sel_mailbox=" + sel_mailbox + "&rdo_srch=" + rdo_srch
				   + "&sel_period=" + sel_period + "&startdate=" + startdate
				   + "&enddate=" + enddate;
		
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
// 		if (searchtext != "") $("#resetSearch").show(); else $("#resetSearch").hide();
	}
</script>
<!-- jqgrid 추가 -->

</head>
<body style="overflow:hidden; ">

<form name="fmMailList" method="POST" action="mail_archive_list.jsp" onsubmit="return false;">
	<!-- hidden field -->
	<input type="hidden" name="box" value="<%=mailboxID%>">
	<input type="hidden" name="pg" value="<%=pageNo%>">
	<input type="hidden" name="message_name" value="">
	<input type="hidden" name="ctype" value="">
	<input type="hidden" name="nekmsgid" value="">
	<input type="hidden" name="codekey" value="<%=mainBoxID %>">
	<input type="hidden" name="unread" value="<%=unReadChk %>">
	<input type="hidden" name="fromname" value="">
	<input type="hidden" name="fromaddress" value="">
	<input type="hidden" name="archive" value="archive">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="20%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-mail.png" />
	<%=NavMailBoxName%></span>
</td>
<td width="*" align="right" style="padding-right:5px;">
	<label for="ipt_query">사람검색 : </label>
	<select name="selEmail" class="fld_200" onchange="gridReload();">
		<option value="">전체 사용자</option>
	<%
	if(archiveUserList!=null){
		for(OrganizationItem item : archiveUserList){	
	%>
		<option value="<%=item.emailId %>" ><%=(item.itemTitle + "/" + item.upName + "/" + item.pItemTitle) %></option>
	<%
		}
	}
	%>
	</select>
	<!-- 편지함 구분 -->
	<label for="ipt_query">편지함 : </label>
	<select name="boxType" class="fld_200" onchange="gridReload();">
		<option value="">전체편지함</option>
		<option value="1">받은편지함</option>
		<option value="2">보낸편지함</option>
	</select>
	<!-- 도메인 검색 -->
	<select name="selDomain" class="fld_200">
	<%
		cfItem = (ConfigItem)cfHash.get(application.getInitParameter("CONF.DOMAIN"));
	%>
		<option value="<%=cfItem.cfValue%>" ><%=cfItem.cfValue%></option>
	<%
		cfItem = (ConfigItem)cfHash.get(application.getInitParameter("CONF.MULTIDOMAIN"));
		String str = "";
		StringTokenizer token = new StringTokenizer(cfItem.cfValue, ",");
		if(token.countTokens()>0){
			while(token.hasMoreTokens()){
				str= token.nextToken();
	%>
		<option value="<%=str%>"><%=str%></option>
	<%
			}
		}
	%>
			
	</select>

	<input type="hidden" name="searchtype" value="all">
	<input name="searchtext" class="fld_other" value="<%=searchText%>" onkeyPress="if (window.event.keyCode == 13) { gridReload(); return false; }" />
	
	<a href="#" class="btn btn-icon" onclick="gridReload();">
		<span><span class="icon-search"></span><fmt:message key='mail.seach'/>
	</span></a>&nbsp;
	<a href="#" id="resetSearch" onclick="location.reload();" class="btn-red btn-icon" style="display:none;">
		<span><span class="icon-search"></span><fmt:message key="t.search.del"/><!-- 검색제거 -->
	</span></a>&nbsp;
<!-- 	<a id="btn_detail_search" href="#" onclicks="showDetailSearch();" class="btn btn-icon"> -->
<!-- 		<span><span class="icon-search"></span>상세검색&nbsp;검색제거 -->
<!-- 	</span></a> --> 
	<a id="btn_detail_search" href="#" onclicks="showDetailSearch();" class="btn-blue btn-icon">
		<span><span class="icon-search"></span>상세검색&nbsp;
	</span></a>
	</td>
</tr>
</table>

<style>
/* Add some nice box-shadow-ness to the modal tooltip */
#qtip-modal{
	width: 550px;
 
	-moz-box-shadow: 0 0 10px 1px rgba(0,0,0,.5);
	-webkit-box-shadow: 0 0 10px 1px rgba(0,0,0,.5);
	box-shadow: 0 0 10px 1px rgba(0,0,0,.5);
}
 
#qtip-modal .qtip-content{
	padding: 10px;
}
.qtip {max-width:850px;}
</style>

<!-- <div id="demo-modal"> -->
<div id="detail_search" style="display:none; border-bottom:1px solid #00FFFF;">
	<table>
		<colgroup>
			<col width="10">
			<col width="*">
			<col width="80">
		</colgroup>
		<tr>
			<td rowspan="3">&nbsp;</td>
			<td>
				<label for="ipt_query">사람검색 : </label>
				<select class="read" name="sel_receiver" align="absmiddle" style="width:110px;">
						<option value='all_rec'><fmt:message key="mail.search.entire"/>&nbsp;<!-- 전체검색 --></option>
						<option value='from'><fmt:message key="mail.sender"/>&nbsp;<!-- 발신인 --></option>
						<option value='recieve'><fmt:message key="mail.recipient"/>&nbsp;<!-- 수신인 --></option>
						<option value='ref'>수신+참조&nbsp;<!-- 수신인 --></option>
				</select>
				<input type="text" name="ipt_receiver" maxlength="100" style="ime-mode:active;height:15px;padding:1px 0 0 3px;border:1px solid #abadb3;line-height:15px">
				<br />
				<label for="ipt_query">내용검색 : </label> 
				<select name="sel_content" align="absmiddle" style="width:110px;">
					<option value="all_body" selected="selected">제목+본문</option>
					<option value="subject">제목</option>
					<option value="body">본문</option>
<!-- 					<option value="4">첨부파일</option> -->
<!-- 					<option value="5">전체</option> -->
				</select>
				<input type="text" name="ipt_content" maxlength="100" style="ime-mode:active;height:15px;padding:1px 0 0 3px;border:1px solid #abadb3;line-height:15px">
				<!-- <span class="ment">(첨부파일/첨부본문 포함)</span> -->
			</td>
			<td rowspan="3" valign="top">
				<a href="#" class="btn btn-icon" onclick="goSearch();">
				<span><span class="icon-search"></span><fmt:message key='mail.seach'/>
				</span></a>
			</td>
		</tr>
		<tr>
			<td>
<!-- 				<label for="ipt_query">폴더선택 : </label> -->
<!-- 				<select name="sel_mailbox" onchange="setChangeMailbox()" style="width:110px;" align="absmiddle"> -->
<!-- 					<option value="0">전체메일함</option> -->
<%-- 					<option value="1" <%=(mailboxID==1 ? "selected" : "") %>>받은편지함</option> --%>
<%-- 					<% --%>
<!-- 					Iterator recMailboxs = mailboxes_rec.iterator(); -->
<!-- 					//Iterator mailbox_iter2 = mailboxes_send.iterator(); -->
<!-- 					while (recMailboxs.hasNext()) { -->
<!-- 						Mailbox mailbox = (Mailbox)recMailboxs.next(); -->
<!-- 						boolean isSelected = false; -->
<!-- 						if(mailbox.getID()==mailboxID){ -->
<!-- 							isSelected = true; -->
<!-- 						} -->
<!-- 						out.println("<option value='" + mailbox.getID() + "' " + (isSelected ? "selected" : "") +">"  -->
<!-- 								+ mailbox.getName()+ "</option>"); -->
<!-- 					} -->
<!-- 					%> -->
<%-- 					<option value="2" <%=(mailboxID==2 ? "selected" : "") %>>보낸편지함</option> --%>
<%-- 					<option value="7" <%=(mailboxID==7 ? "selected" : "") %>>스팸편지함</option> --%>
<%-- 					<option value="3" <%=(mailboxID==3 ? "selected" : "") %>>임시보관함</option> --%>
<%-- 					<option value="6" <%=(mailboxID==6 ? "selected" : "") %>>예약편지함</option> --%>
<%-- 					<option value="4" <%=(mailboxID==4 ? "selected" : "") %>>지운편지함</option> --%>
<!-- 				</select> -->
<!-- 				<label>지운편지함/스팸편지함 : </label> -->
<!-- 				<input type="radio" name="rdo_srch" value="exceptTrash" style="margin:5px 0px 0px 0px;" disabled="true" checked><label>제외</label> -->
<!-- 				<input type="radio" name="rdo_srch" value="includeTrash" style="margin:5px 0px 0px 0px;" disabled="true"><label >포함</label> -->
<!-- 				<br /> -->
				<label>기간지정 : </label>
				<select name="sel_period" onchange="setDatePeriod()" style="width:110px;">
				<option value="0" selected>전체</option>
				<option value="1">1 주일</option>
				<option value="2">1 개월</option>
				<option value="3">3 개월</option>
				<option value="4">6 개월</option>
				<option value="5">1 년</option>
				<option value="99">직접입력</option>
				</select>
				<input id="startDate" name="startDate" type="text" title="시작일" Style="width:60px;height:15px;padding:1px 0 0 3px;border:1px solid #abadb3;line-height:15px" maxlength="30" onclick="onClickcr();" readonly>
				<span> - </span>
				<input id="endDate" name="endDate" type="text" title="종료일" Style="width:60px;height:15px;padding:1px 0 0 3px;border:1px solid #abadb3;line-height:15px" maxlength="30" onclick="onClickcr();" readonly>
			</td>
		</tr>
	</table>
</div>
<!-- </div> -->

	<!-- List Button -->
	<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
		<tr>
			<td width="*">&nbsp;
				<a href="#" class="btn btn-icon" onclick="OnClickRestore();">
					<span><span class="icon-mail-move"></span><fmt:message key="mail.restore"/>&nbsp;<!-- 메일 복구 -->
				</span></a>
				
				<a href="#" class="btn btn-icon" onclick="OnClickDelete();">
					<span><span class="icon-delete"></span><fmt:message key="mail.delete"/>&nbsp;<!-- 삭제 -->
				</span></a>
				
				<a href="#" class="btn btn-icon" onclick="OnClickSave();">
					<span><span class="icon-mail-download"></span><fmt:message key="mail.storage.pc"/>&nbsp;<!-- PC 보관 -->
				</span></a>
			</td>
			<td width="*">&nbsp;</td>
		</tr>
	</table>
	<!-- List Button -->

	<!-- List -->
	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<span id="errorDisplayer" style="color:red"></span>
	<!-- List -->
	
	<div id=val style="display:none;">
		<div id=test style="width:100%; height:190px; borders:2px solid #A1B5FE; overflow:auto;">
			<table width=100% height=100% cellspacing=0 cellpadding=0 border=0 style="border-collapse:collapse; borders:1px solid white;table-layout:fixed;" oncontextmenu="return false" ondragstart="return false"  >
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('read');" style="color:black; text-decoration:none; "><fmt:message key="mail.read"/>&nbsp;<!-- 메일읽기 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovesr="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('reply');" style="color:black; text-decoration:none; "><fmt:message key="mail.reply.sender"/>&nbsp;<!-- 발신인에게 회신 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('forward');" style="color:black; text-decoration:none; "><fmt:message key="mail.forwarding"/>&nbsp;<!-- 메일전달 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/vwicn008.gif' align=absmiddle>
						<a href="javascript:OnClickAction('search');" style="color:black; text-decoration:none; padding-left:2px;"><fmt:message key="mail.search.sender"/>&nbsp;<!-- 발신인의 메일 검색 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/admin_icon_7.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('addressbook_s');" style="color:black; text-decoration:none; "><fmt:message key="mail.add.sender"/>&nbsp;<!-- 발신인을 주소록에 추가 --></a>
					</td>
				</tr>
				<%if(mailboxID!=Mailbox.SPAM){ %>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/email_icon_1.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('spam');" style="color:black; text-decoration:none; "><fmt:message key="mail.spam.sender"/>&nbsp;<!-- 발신인을 스팸으로 등록 --></a>
					</td>
				</tr>
				<%} %>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding:3px; padding-top:6px; padding-right:5px; vertical-align:top; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_4.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('rule');" style="color:black; text-decoration:none;"><fmt:message key="mail.auto.classification"/>&nbsp;<!-- 자동분류 설정 --></a>
					</td>
				</tr>
			</table>
		</div>
	</div>
</form>
</fmt:bundle>
</body>
</html>	