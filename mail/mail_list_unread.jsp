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
<%!

	private MailRepository repository = MailRepository.getInstance();//new MailRepository();

	private static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	private static HashMap SEARCH_FIELDS = new HashMap();
	static {
		SEARCH_FIELDS.put("subject", new String[] { "subject" });
		SEARCH_FIELDS.put("from", new String[] { "fromname", "sender" });
		SEARCH_FIELDS.put("all", new String[] { "subject", "fromname", "sender" });
		SEARCH_FIELDS.put("recieve", new String[] { "displayto" });
		SEARCH_FIELDS.put("all-rec", new String[] { "subject", "displayto" });
	}
	private static String[] builtInMailboxes  = {
		"",
		"읽지않은 메일",
		"보낸 편지함",
		"임시 보관함",
		"휴지통",
		"Pending",
		"예약함" //,	"HOT"	//Added By Kim Do Young for 디토소프트
	};
%>
<%@ include file="../common/usersession.jsp" %>
<%
	request.setCharacterEncoding("utf-8");
	
	String mainBoxID = request.getParameter("codekey");
	if(mainBoxID==null) mainBoxID = "";

	//parameters -------------------------------------------------------
	ParameterParser pp = new ParameterParser(request);
	String cmd			= pp.getStringParameter("cmd", "list");
	int mailboxID		= pp.getIntParameter("box", Mailbox.INBOX);
	String searchText	= pp.getStringParameter("searchtext", "");
	String searchType	= pp.getStringParameter("searchtype", "");
	int pageNo			= pp.getIntParameter("pg", 1);
	String searchReadType = pp.getStringParameter("searchreadtype", "all");

	//검색인 경우 검색 조건 설정 -------------------------------------------
	SearchConstraint constraint = null;
	if (searchText != "" && searchType != "") {
		String[] searchFields = (String[])SEARCH_FIELDS.get(searchType);
		if (searchFields != null) {
			constraint = new SearchConstraint();
			constraint.setSearchText(searchText);
			constraint.setSearchFields(searchFields);
		}
	}else if (searchReadType != "") {
		
	}

	//DB 작업 --------------------------------------------------------------------
	ListPage listPage = null;
	Mailboxes mailboxes_rec = null;
	Mailboxes mailboxes_send = null;

	DBHandler db = new DBHandler();
	Connection con = null;
	
	try {
		con = db.getDbConnection();
		
		String domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
		//개인편지함 가져오기--------------------------------------------------------
		mailboxes_rec = repository.getCustomMailboxes(con, loginuser.emailId, 1, domainName);	//받은편지함
		mailboxes_send = repository.getCustomMailboxes(con, loginuser.emailId, 2, domainName);	//보낸편지함
		//목록 가져오기--------------------------------------------------------------
		listPage = repository.unReadlist(con, loginuser.emailId, mailboxID, pageNo, uservariable.listPPage, constraint, domainName);

	} finally {
		if (con != null) {
			db.freeDbConnection();
		}
	} //END DB 작업


	//현재 메일함의 이름 구하기 ----------------------------------------------
	String mailboxName = "" ;
    String NavMailBoxName = "읽지않은 메일" ; 
    String NavCenterName = "편지 읽기" ; 
	if (Mailbox.isCustomMailbox(mailboxID)) {
		Mailbox box1 = mailboxes_rec.get(mailboxID);
		Mailbox box2 = mailboxes_send.get(mailboxID);
		if (box1 != null) {
			NavMailBoxName = box1.getName();
            mailboxName = builtInMailboxes[1];
		}else if (box2 != null) {
			NavMailBoxName = box2.getName();
            mailboxName = builtInMailboxes[1];
		}
	} else {
		mailboxName = builtInMailboxes[mailboxID];
        if (mailboxID != 1 ) {                    
            NavCenterName = "편지함" ; 
            NavMailBoxName = mailboxName ; 
        }
	}
%>
<html>
<head>
<title>메일 목록</title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script language="javascript">
	SetHelpIndex("mail_list");
</script>
<script language="javascript">
function OnClickCheckReceipt(messageName) {
	window.showModalDialog("mail_receiptstatus.jsp?message_name=" + messageName,"","dialogHeight: 300px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
}

function OnClickDelete() {
	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		alert("삭제할 문서가 없습니다!");
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
		alert("삭제할 문서를 선택하세요!");
		return;
	}

	if (confirm("삭제하시겠습니까?")) {

		fmMailList.action = "mail_delete.jsp";
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
		alert("재발신 할 문서를 선택해주십시오.");
		return;
	}
	if(totCnt >1){
		alert("재발신 할 문서는 1개만 선택하세요!");
		return;
	}
	
	var url = "./mail_form.jsp?message_name=" + mailId;
	OpenWindow( url, "", "850" , "610" );
}

function OnClickMove() {
	var targetMailbox = fmMailList.target.value;
	if (targetMailbox == "title" || targetMailbox == "division") {
		alert("이동할 편지함을 선택하세요!");
		return;
	}

	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		alert("이동할 문서가 없습니다!");
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
		alert("검색어를 입력하세요!");
		fmMailList.searchtext.focus();
		return;
	}

	fmMailList.method = "post";
	fmMailList.pg.value = 1;
	fmMailList.action = "./mail_list.jsp";
	fmMailList.submit();
}

function OnClickEdit(message_name) {
/*
	document.fmMailList.action = "./mail_form.jsp";
	document.fmMailList.method = "post";
	document.fmMailList.message_name.value = message_name;
	document.fmMailList.submit();
	*/
	var url = "./mail_form.jsp?message_name=" + message_name;
	//OpenWindowNoScr( url, "", "755" , "610" );
	OpenWindow( url, "", "850" , "610" );
}


function OnClickOpen(message_name, importance) {
	/*
	document.fmMailList.action = "./mail_read.jsp";
	document.fmMailList.method = "post";
	document.fmMailList.message_name.value = message_name;
	document.fmMailList.submit();
	*/
	
	var readChk = document.getElementById("mchk_"+message_name);	//안읽은 편지 읽음표시
	var boldObj = document.getElementById("bl_"+message_name);	//제목강조 제거

	<%if(mailboxID != Mailbox.OUTBOX) {%>
		if(readChk.src.indexOf("close")>-1){
			readChk.src = "../common/images/btn_mailopen.gif";
			boldObj.innerHTML = boldObj.innerText;
		}
	<%}%>
	
	var url = "./mail_read.jsp?message_name=" + message_name + "&box=<%=mailboxID %>&importance=" + importance;
	//OpenWindowNoScr( url, "", "755" , "610" );
	OpenWindow( url, "", "900" , "610" );
}


function OnClickOpenNewWin(messageName) {
	var WinWidth = 900 ; 
	var WinHeight = 500 ; 
	var winleft = (screen.width - WinWidth) / 2;
	var wintop = (screen.height - WinHeight) / 2;
	var UrlStr = "./mail_read.jsp?front=&message_name=" + messageName ;
	var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
}

function goSubmit(cmd){
	if(cmd=="NEW"){
		//document.location.href = "./mail_form.jsp";
		var url = "./mail_form.jsp";
		OpenWindowNoScr( url, "", "800" , "650" );
		//targetWin = OpenWindowNoScr( url, "", "800" , "650" );
	}else if("list"){
		//document.location.href = "mail_list.jsp";
		fmMailList.action = "mail_list.jsp";
		fmMailList.method = "POST";
		fmMailList.submit();
	}
}

function goMail(url){
	OpenWindowNoScr( url, "", "755" , "610" );
}

function OnMailCancel(msgID, nekMsgId) {
	if (confirm("정말 발송된 메일을 취소하시겠습니까?")) {

		fmMailList.action = "mail_cancel.jsp";
		fmMailList.ctype.value = "1";
		fmMailList.message_name.value = msgID;
		fmMailList.nekmsgid.value = nekMsgId;
		fmMailList.method = "post";
		fmMailList.submit();
	}
}

</script>
</head>
<body>

<form name="fmMailList" method="POST" action="mail_list.jsp" onsubmit="return false;">
	<!-- hidden field -->
	<input type="hidden" name="box" value="<%=mailboxID%>">
	<input type="hidden" name="pg" value="<%=pageNo%>">
	<input type="hidden" name="message_name" value="">
	<input type="hidden" name="ctype" value="">
	<input type="hidden" name="nekmsgid" value="">
	<input type="hidden" name="codekey" value="<%=mainBoxID %>">
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
		<tr> 
			<td width="6"> 
				<table width="6" border="0" cellspacing="0" cellpadding="0" height="100%">
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_left_top.jpg"></td>
					</tr>
					<tr> 
						<td background="<%=imagePath %>/box_left_bg.jpg">&nbsp;</td>
					</tr>
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_left_bottom.jpg"></td>
					</tr>
				</table>
			</td>
			<td valign="top"> 
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
					<tr> 
						<td height="6" background="<%=imagePath %>/box_center_top_left.jpg" align="right"><img src="<%=imagePath %>/box_top_right.jpg" width="4" height="6"></td>
					</tr>
					<tr> 
						<td bgcolor="#FFFFFF" valign="top">
						
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="11">&nbsp; </td>
									<td valign="top"> 
										<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
											<tr> 
												<td height="44"> 
												<!-- 타이틀 시작 -->
													<table width="100%" border="0" cellspacing="0" cellpadding="0" height="44">
														<tr> 
															<td height="11"></td>
														</tr>
														<tr> 
															<td height="27"> 
																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
																	<tr> 
																		<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_email.jpg" width="27" height="27"></td>
																		<td class="SubTitle"><%=mailboxName%></td>
																		<td valign="bottom" width="250" align="right"> 
																			<table border="0" cellspacing="0" cellpadding="0" height="17">
																				<tr> 
																					<td valign="top" class="SubLocation">전자메일 &gt; <b><%=NavMailBoxName%></b></td>
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
												</td>
											</tr>
											<tr> 
												<td valign="top"> 
													<table width="100%" border="0" cellspacing="0" cellpadding="0">
														<tr> 
															<td height="10"></td>
														</tr>
														<tr> 
															<td> 
																<!-- 수행 버튼  시작 -->
																<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
																	<tr> 
																		<td width="72"> 
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="goSubmit('NEW');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr> 
																					<td width="23"><img name="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;새메일</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<td width="60"> 
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="OnClickDelete()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr> 
																					<td width="23"><img name="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;삭제</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<%
																			if (mailboxID == Mailbox.TRASH) {
																		%>
																		<td width="108"> 
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickClearTrash()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr> 
																					<td width="23"><img name="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;휴지통비우기</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<%
																			}
																		%>
																		<td width="158" valign="middle">
																			<span style="position:relative;top:0px"> 
																			<select name="target" class="ListMenu">
																				<option value="title" selected>-----편지함 선택----- 
																				<%
																					StringBuffer selBoxBuf = new StringBuffer();
																					if (mailboxID != Mailbox.INBOX) {
																						selBoxBuf.append("<option value='" + Mailbox.INBOX + "'>받은편지함</option>");
																					}
																					//if (mailboxID != Mailbox.HOT) {
																					//	selBoxBuf.append("<option value='" + Mailbox.HOT + "'>HOT</option>");
																					//}
																					if (mailboxID != Mailbox.DRAFT) {
																						selBoxBuf.append("<option value='" + Mailbox.DRAFT + "'>임시보관함</option>");
																					}
																					if (mailboxID != Mailbox.TRASH) {
																						selBoxBuf.append("<option value='" + Mailbox.TRASH + "'>휴지통</option>");
																					}
												
																					selBoxBuf.append("<option value='division'>-----개인편지함-----");
												
																					Iterator mailbox_iter1 = mailboxes_rec.iterator();
																					Iterator mailbox_iter2 = mailboxes_send.iterator();
												
																					int selectBox = 0;
																					while (mailbox_iter1.hasNext()) {
																						Mailbox mailbox = (Mailbox)mailbox_iter1.next();
												
																						//받은편지함에서 보낸편지함으로 이동은 안된다!!!
												
																						if(mailbox.getID()==mailboxID){
												
																							selectBox = mailbox.getMainBoxId();
												
																						}else if(mailboxID==1){
												
																							selectBox = 1;
												
																						}else if(mailboxID==2){
												
																							selectBox = 2;
												
																						}
												
												
																						if (mailboxID != mailbox.getID()) {
												
																							if(selectBox==1){	//받은편지함이면 보낸편지함으로 이동은 막는
												
																								if(mailbox.getMainBoxId()==2) continue;
												
																							}
												
																							selBoxBuf.append("<option value='" + mailbox.getID() + "'>" 
																								+ mailbox.getName()+ "</option>");
																						}
																					}
																					
																					//selBoxBuf.append("<option value='division'>-----보낸편지함-----");
																					
																					while (mailbox_iter2.hasNext()) {
																						Mailbox mailbox = (Mailbox)mailbox_iter2.next();
												
																						//받은편지함에서 보낸편지함으로 이동은 안된다!!!
												
																						if(mailbox.getID()==mailboxID){
												
																							selectBox = mailbox.getMainBoxId();
												
																						}else if(mailboxID==1){
												
																							selectBox = 1;
												
																						}else if(mailboxID==2){
												
																							selectBox = 2;
												
																						}
												
												
																						if (mailboxID != mailbox.getID()) {
												
																							if(selectBox==1){	//받은편지함이면 보낸편지함으로 이동은 막는
												
																								if(mailbox.getMainBoxId()==2) continue;
												
																							}
												
																							selBoxBuf.append("<option value='" + mailbox.getID() + "'>" 
																								+ mailbox.getName()+ "</option>");
																						}
																					}
												
																					String selBoxes = selBoxBuf.toString();
																					out.println(selBoxes);
																				%>
																			</select>
																			</span>
																		</td>
																		<td width="88"> 
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="OnClickMove();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma03','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr> 
																					<td width="23"><img name="btnIma03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;폴더 이동</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<%if(mailboxID==Mailbox.OUTBOX){ %>
																		<td width="72"> 
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="reMailSend();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma04','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr> 
																					<td width="23"><img name="btnIma04" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;재발신</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<%} %>
																		<td>&nbsp;</td>
																		<td width="*" class="DocuNo" align="right">
																			<img src="<%=imagePath %>/icon_docu.jpg" width="14" height="16">
																			<div style="position:relative;bottom:3px;display:inline;">총문서수:<b><%=listPage.getTotalCount()%></b></div>
																		</td>
																	</tr>
																</table>
																<!-- 수행 버튼  끝 -->
															</td>
														</tr>
														<tr> 
															<td height="10"></td>
														</tr>
														<tr> 
															<td> 
																<div id="viewList" class="div-view" onpropertychange="div_resize();">
																<table width="100%" border="0" cellspacing="0" cellpadding="0">
																	<tr> 
																		<td height="30" valign="top"> 
																			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29" background="<%=imagePath %>/titlebar_bg.jpg">
																				<tr> 
																					<td width="5" background="<%=imagePath %>/titlebar_left.jpg"></td>
																					<td align="center">
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
																							<colgroup>
																								<col width="25">
																								<col width="1">
																								<col width="150">
																								<col width="1">
																								<col width="*">
																								<col width="1">
																								<col width="140">
																								<col width="1">
																								<col width="35">
																								<col width="1">
																								<col width="50">
																								<%if (mailboxID == Mailbox.OUTBOX) { %>
																								<col width="1">
																								<col width="70">
																								<%} %>
																							</colgroup>
																							<tr>
																								<td align="center"><img src="../common/images/btn_checkbox.gif" onClick="OnClickToggleAllSelect()" style="cursor: hand"></td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">
																								<%
																									if (mailboxID == Mailbox.OUTBOX || 
																										mailboxID == Mailbox.DRAFT ||
																										mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {
																										out.println("수신인");
																									} else {
																										out.println("발신인");
																									}
																								%>
																								</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">제목</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText"><%=(mailboxID == Mailbox.RESERVED) ? "예약일시" : "날짜"%></td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">첨부</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">크기</td>
																								<%if (mailboxID == Mailbox.OUTBOX) { %>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">발송취소</td>
																								<%} %>
																							</tr>
																						</table>
																					</td>
																					<td width="5" background="<%=imagePath %>/titlebar_right.jpg"></td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																	<tr> 
																		<td> 
																			<!-- DATA 목록 그리기 -->
																			<%
																				if (listPage.getTotalCount() > 0) {
																					Iterator iter = listPage.iterator();
																					boolean alternating = false;
																					while (iter.hasNext()) {
																						MessageLineItem item = (MessageLineItem)iter.next();
																			%>
																			<table width="100%" border="0" cellspacing="0" cellpadding="0">
																				<tr> 
																					<td width="5"></td>
																					<td> 
																						<table width="100%" height="25" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px;" id="viewTable">
																							<tr height='25' <%=(alternating) ? "bgcolor='f9f9f9'" : ""%>> 
																								<td>
																									<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tblfix">
																										<colgroup>
																											<col width="20">
																											<col width="1">
																											<col width="160">
																											<col width="1">
																											<col width="20">
																											<col width="20">
																											<!-- <col width="20"> -->
																											<col width="*">
																											<col width="1">
																											<col width="140">
																											<col width="1">
																											<col width="35">
																											<col width="1">
																											<col width="50">
																											<%if (mailboxID == Mailbox.OUTBOX) { %>
																											<col width="1">
																											<col width="70">
																											<%} %>
																										</colgroup>
																										<tr> 
																											<td align="center">
																												<input type="checkbox" name="mailid" value="<%=item.getMessageName()%>">
																											</td>
																											<td align="center"></td>
																											<td align="center" class="SubText">
																										<%
																											if (mailboxID == Mailbox.OUTBOX || 
																												mailboxID == Mailbox.DRAFT ||
																												mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {
																												out.print(Convert.cropByte(item.getDisplayTo(), 20, "..."));
																											} else {
																												//발신자에 quoted-printable 인코딩인지 확인
																												StringTokenizer st = new StringTokenizer(item.getFromName(), "?");
																												String tmpStr = "";
																												String enType = "";
																												String fromName= "";
																												int count = 0;
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
																													//out.print(fromName);
																												}else{
																													fromName = HtmlEncoder.encode(item.getFromName());
																												}
																												out.print(new StringBuffer()
																												.append("<a href='javascript:goMail(\"mail_form.jsp?cmd=reply&message_name=")
																												.append(item.getMessageName())
																												.append("\");'>")
																												.append(fromName)
																												.append("</a>").toString());
																											}
																										%>
																											</td>
																											<td align="center"></td>
																											<td align="center" class="SubText">
																										<%
																											int importance = item.getImportance();
																											if (importance == 1) { 
																												out.println("<img src='../common/images/btn_Priority_high.gif' border='0'>");
																											} else if (importance == 5) {
																												out.println("<img src='../common/images/btn_Priority_low.gif' border='0'>");
																											}
																										%>
																											</td>
																											<td align="center" class="SubText">
																										<%
																											if (mailboxID == Mailbox.DRAFT ||
																												mailboxID == Mailbox.RESERVED) {
																												out.println("<img src='../common/images/btn_draft.gif' border='0'>");						
																											} else {
																												if (item.isRead()) {
																													if (mailboxID == Mailbox.OUTBOX) {
																														out.println("<a href=javascript:OnClickCheckReceipt('" + item.getMessageName() + 
																														"')><img id='mchk_" + item.getMessageName() + "' src='../common/images/btn_mailopen.gif' border='0'></a>");
																													} else { 
																														out.println("<img id='mchk_" + item.getMessageName() + "' src='../common/images/btn_mailopen.gif' border='0'>");
																													}
																												} else {
																													out.println("<img id='mchk_" + item.getMessageName() + "' src='../common/images/btn_mailclose.gif' border='0'>");
																												}
																											}
																										%>
																											</td>
																											<!-- 
																											<td align="center" class="SubText">
																												<a href="javascript:OnClickOpenNewWin('<%=item.getMessageName()%>')">
																												<img src="../common/images/btn_listdot.gif" border="0" title="새창으로 열기">
																												</a>
																											</td>
																											 -->
																											<td align="left" class="SubText">
																										<%
																											String subject = item.getSubject();
																											if (subject == null || subject.trim().length() < 1) {
																												subject = "제목없음";
																											} else {
																												subject = HtmlEncoder.encode(subject);
																											}
																											if (mailboxID == Mailbox.DRAFT ||
																												mailboxID == Mailbox.RESERVED) {
																												out.print(
																													new StringBuffer()
																														.append("<a href=\"javascript:OnClickEdit('")
																														.append(item.getMessageName())
																														.append("')\">")
																														.append(nek.common.util.Convert.cropByte(subject, 70, "..."))
																														.append("</a>")
																														.toString()
																													);
																											} else {
																												
																												out.print(
																													new StringBuffer()
																														.append("<a href=\"javascript:OnClickOpen('")
																														.append(item.getMessageName())
																														.append("','"+importance+"')\">" + ((item.isRead()) ? "" : "<span id='bl_"+item.getMessageName()+"'><B>"))
																														.append(nek.common.util.Convert.cropByte(subject, 70, "..."))
																														.append(((item.isRead()) ? "" : "</B></span>")+ "</a>")
																														.toString()
																													);
																											}
																										%>
																											</td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=format.format(item.getDate())%></td>
																											<td align="center"></td>
																											<td align="center">
																										<%
																											if (item.hasAttachment()) {
																												out.println("<img src='../common/images/icons/icon_attach.gif'>");											
																											}
																										%>
																											</td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=FileSizeFormatter.format(item.getSize())%>&nbsp;</td>
																											<%if (mailboxID == Mailbox.OUTBOX) { %>
																											<td align="center"></td>
																											<td align="center" class="SubText">
																												<%
																													if(item.getNekMsgID()==null||item.getNekMsgID().equals("")){
																														out.print("-");	
																													}else{
																														if(item.isRead()){
																															out.print("-");	
																														}else{
																															if(item.getCancelFlag()==1){
																																out.print("<b>취소</b>");	
																															}else{
																												%>
																												<input type="button" value="취소" onClick="javascript:OnMailCancel('<%=item.getMessageName() %>', '<%=item.getNekMsgID() %>');">
																												<%
																															}
																														}
																													}
																												%>
																											<%} %>
																											</td>
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
																					alternating = !alternating;
																					}
																				} else {
																					out.println("<table width='100%' style='height:expression(document.body.clientHeight-220);' border='0' cellspacing='0' cellpadding='0'><tr>"
																						+ "<td width='5'></td><td>"+StringUtil.getNODocExistMsg()
																						+ "</td><td width='5'></td></tr></table>"); 
																				}
																			%>
																		</td>
																	</tr>
																	<tr> 
																		<td height="15"></td>
																	</tr>
																</table>
																</div>
																<!-- 페이지 / 검색 -->
																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="36" id="viewPage">
																	<tr>
																		<td bgcolor="90b3d2" align="center" valign="middle">
																			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="30">
																				<tr>
																					<td width="3"></td>
																					<td bgcolor="ebf0f8"> 
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;">
																							<tr>
																								<td width="15">&nbsp;</td>
																								<td width="*" class="PageNo">
																									<%
																									String paraStr = new StringBuffer()
																										.append("box=")
																										.append(mailboxID)
																										.append("&searchtext=")
																										.append(java.net.URLEncoder.encode(searchText, "utf-8"))
																										.append("&searchtype=")
																										.append(searchType)
																										.append("&codekey=")
																										.append(mainBoxID)
																										.toString();
																									%>
																									<jsp:include page="../common/page_numbering.jsp" flush="true">
																										<jsp:param name="totalcount" value="<%=listPage.getTotalCount()%>"/>
																										<jsp:param name="pg" value="<%=listPage.getPageNo()%>"/>
																										<jsp:param name="linkurl" value="mail_list.jsp"/>
																										<jsp:param name="paramstring" value="<%=paraStr %>"/>
																										<jsp:param name="linktype" value="1"/> 
																										<jsp:param name="listppage" value="<%=uservariable.listPPage%>"/>
																										<jsp:param name="blockppage" value="<%=uservariable.blockPPage%>"/>
																									</jsp:include>
																								</td>
																								<td width="1">&nbsp;</td>
																								<td width="460" align="right"> 
																									<table border="0" cellspacing="0" cellpadding="0">
																										<tr>
																											<td width="97">
																												<select class="read" name="searchreadtype" style="width:92px;">
																													<option value="all" <%=("all".equals(searchReadType)) ? "selected" : ""%>>전체문서</option>
																													<option value="unread" <%=("unread".equals(searchReadType)) ? "selected" : ""%>>읽지않은 메일</option>
																													<option value="read" <%=("read".equals(searchReadType)) ? "selected" : ""%>>읽은 메일</option>
																												</select>
																											</td>
																											<td width="215">
																												<select class="read" name="searchtype" style="width:92px;">
																													<%if(mailboxID==2 || mailboxID==3 || mailboxID==6){%>
																													<option value="all-rec" <%=("all".equals(searchType)) ? "selected" : ""%>>전체검색</option>
																													<%}else{%>
																													<option value="all" <%=("all".equals(searchType)) ? "selected" : ""%>>전체검색</option>
																													<%}%>
																													<option value="subject" <%=("subject".equals(searchType)) ? "selected" : ""%>>제목</option>
																													<%if(mailboxID==2 || mailboxID==3 || mailboxID==6){%>
																													<option value="recieve" <%=("from".equals(searchType)) ? "selected" : ""%>>수신인</option>
																													<%}else{%>
																													<option value="from" <%=("from".equals(searchType)) ? "selected" : ""%>>발신인</option>
																													<%}%>
																												</select>
																												<input name="searchtext" class="fld_other" value="<%=searchText%>" size="18" class="input01" class="read" onkeyPress="if(window.event.keyCode == 13){OnClickSearch(); return false;}">
																											</td>
																											<td width="60">
																												<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickSearch();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma04','','<%=imagePath %>/btn2_left.jpg',1)">
																													<tr>
																														<td width="23"><img name="btnIma04" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																														<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;검색</span></td>
																														<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																													</tr>
																												</table>
																											</td>
																											<%if(!searchType.equals("")&&!searchText.equals("")){ %>
																											<td width="83">
																												<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('list');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma05','','<%=imagePath %>/btn2_left.jpg',1)">
																													<tr>
																														<td width="23"><img name="btnIma05" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																														<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;검색삭제</span></td>
																														<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																													</tr>
																												</table>
																											</td>
																											<%} %>
																										</tr>
																									</table>
																								</td>
																								<td width="5">&nbsp;</td>
																							</tr>
																						</table>
																					</td>
																					<td width="3"></td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																</table>
																<!-- 페이지 / 검색 끝 -->
															</td>
															<td width="11">&nbsp;</td>
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
						<td height="6" align="right" background="<%=imagePath %>/box_center_bottom_left.jpg"><img src="<%=imagePath %>/box_bottom_right.jpg" width="4" height="6"></td>
					</tr>
				</table>
			</td>
			<td width="6"> 
				<table width="6" border="0" cellspacing="0" cellpadding="0" height="100%">
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_right_top.jpg"></td>
					</tr>
					<tr> 
						<td background="<%=imagePath %>/box_right_bg.jpg">&nbsp;</td>
					</tr>
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_right_bottom.jpg"></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
	</form>
		
	</body>
</html>	