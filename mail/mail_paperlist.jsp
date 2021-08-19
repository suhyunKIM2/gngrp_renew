<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.addressbook.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="nek.mail.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%!
	private MailRepository repository = MailRepository.getInstance();
	private static HashMap SEARCH_FIELDS = new HashMap();
	static {
		SEARCH_FIELDS.put("subject", new String[] { "title" });
		SEARCH_FIELDS.put("description", new String[] { "description" });
		SEARCH_FIELDS.put("all", new String[] { "subject", "description" });
	}
%>
<%@ include file="../common/usersession.jsp" %>
<%
	request.setCharacterEncoding("utf-8");
 
	ParameterParser pp = new ParameterParser(request);
	String cmd			= pp.getStringParameter("cmd", "list");
	String searchType	= pp.getStringParameter("searchtype", "");
	String searchText	= pp.getStringParameter("searchtext", "");
	String qsearch		= pp.getStringParameter("qsearch", "");
	int pageNo			= pp.getIntParameter("pg", 1);

	String queryString = new StringBuffer()
		.append("&searchtext=")
		.append(java.net.URLEncoder.encode(searchText, "utf-8"))
		.append("&searchtype=")
		.append(searchType)
		.toString();

	DBHandler db = null;
	Connection con = null;	

// 	ListFilter filter = null;
// 	String[] searchFields = (String[])SEARCH_FIELDS.get(searchType);
// 	if (searchFields != null && searchText.length() > 0) {
// 		filter = new ListFilter(searchText, searchFields);
// 	}

	ListPage listPage = null;
	try {
		db = new DBHandler();
		con = db.getDbConnection();
		
		listPage = repository.getMailPaper(con, pageNo, uservariable.listPPage);
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<title>편지지 관리&nbsp;<!-- 편지지 관리 --></title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/style.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">

<script src="<%= scriptPath %>/common.js"></script>
<script src="<%= scriptPath %>/xmlhttp.vbs" language="vbscript"></script>

<link type="text/css" href="/common/css/styledButton.css" rel="stylesheet" />

<script language="javascript">
<!--
function goNewDoc(){
	var url = "./mail_paper_form.jsp";
	OpenWindow( url, "", "755" , "610" );
}

function OnClickToggleAllSelect() {
	var items = document.getElementsByName("delid");
	if (items != null && items.length > 0) {
		var checked = !items[0].checked;
		for (var i = 0; i < items.length; i++) {
			items[i].checked = checked;
		}
	}
}

function OnClickDelete() {
	var ids = document.getElementsByName("delid");
	if (ids == null || ids.length < 1) {
		return;
	}

	var present = false;
	for (var i = 0; i < ids.length; i++) {
		if (ids[i].checked) {
			present = true;
			break;
		}
	}

	if (!present) {
		alert("<fmt:message key='mail.c.delete.group'/>");	//삭제할 그룹을 선택하세요!
		return;
	}

	if (confirm("<fmt:message key='c.delete'/>")) {	//삭제 하시겠습니까?
		fmRG.cmd.value = "alldelete";
		fmRG.method = "POST";
		fmRG.submit();
	}
}
		
function OnSearchTextKeyPress() {
	if (window.event.keyCode == 13) {
		return OnClickSearch();
	}
}

function OnClickSearch() {
	var searchText = document.fmRG.searchtext.value;
	if (searchText == "") {
		alert("<fmt:message key='v.query.required'/>");//검색어를 입력하여 주십시요!
		document.fmRG.searchtext.select();
		document.fmRG.searchtext.focus();
		return false;
	}

	document.fmRG.method = "get";
	document.fmRG.pg.value = 1;
	document.fmRG.action = "mail_grouplist.jsp";
	document.fmRG.submit();
}

function OnClickOpenRecipientGroup(docId) {
	var url = "./mail_paper_form.jsp?docid="+docId;
	OpenWindow( url, "", "755" , "610" );
}

//-->
</script>
<style>
body {margin:5px; margin-left:10px; margin-top:2px; overflow-y:hidden; }
a, td, input, select {font-size:10pt; font-family:돋움,Tahoma; }
input {cursor:hand; }

a:link { color:black; text-decoration:none;  }
a:hover {text-decoration:underline; color:#316ac5}
a:visited { color:#616161; text-decoration:none;  }


.mail_list_t {border:1px solid #A1B5FE; background-image:url('../common/images/top_bg.jpg');}
.mail_list_td {border:1px solid white; border-width:0px 0px 1px 1px; }

.mail_list{border-collapse:collapse; border:1px solid #E8E8E8; border-width:1px 1px 0px 1px;}
.mail_list tr {height:25px; }
.mail_list td {font-size:10pt; font-family:돋움,Tahoma; border:1px solid #E8E8E8; 
				border-width:0px 0px 1px 0px; padding:2px; padding-top:2px; cursor:default;}

.col   {background-image:url('../common/images/column_bg.gif'); color:gray; text-align:center; padding:0px; font-weight:bold; padding:0px; padding-left:2px;  }
.col_p {background-image:url('../common/images/column_bg.gif'); color:#E8E8E8; padding:0px; }

.space {line-height:3px;}

/* 추가분 */
.PageNo { font-family: "돋움"; font-size: 10pt;  text-decoration: none; letter-spacing:3px; padding-bottom:3px; }

.PageNo a{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:5px;}
.PageNo a:visited{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:5px; }
.PageNo a:hover {font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; color:#528BA0; text-decoration:none; height:20px; width:20px; padding-left:5px; }

/* 추가분 */
.PageNo1 {}
.PageNo1 a{ font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; border:1px solid #EBF0F8; 
			background-color:#FFFFFF; text-decoration:none; color:#528BA0;
			padding:2px 3px 3px 3px;}
.PageNo1 a:visited{ font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #EBF0F8; font-weight:bold; background-color:#FFFFFF; 
text-decoration:none; color:#528BA0; padding:2px 3px 3px 3px;}
.PageNo1 a:hover { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px;}
.PageNo1 a:active { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px;}

.PageNo span{width:2px; height:15px; color:#528BA0;}
.div-view {width:expression( document.body.clientWidth); height:expression(document.body.clientHeight-156); overflow:auto; overflow-x:hidden;}
</style>
</head>
<body>
<form name="fmRG" method="post" action="mail_papercontrol.jsp" onsubmit="return false;">
	<input type="hidden" name="cmd" value="">
	<input type="hidden" name="docid" value="">
	<input type="hidden" name="ctype" value="1">
	<input type="hidden" name="pg" value="<%=pageNo%>">

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-mail.png" />편지지 관리</span>
	</td>
	<td width="40%" align="right" style="padding-right:5px;">
	</td>
</tr>
</table>

<!-- table 간 공백 -->
<div class=space>&nbsp;</div>

<!-- 수행 버튼  시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
	<tr> 
		<td width="300"> 
			<a href="#" class="btn btn-icon" onclick="goNewDoc();">
				<span><span class="icon-mail-pencil"></span>새문서&nbsp;<!-- 새문서 -->
			</span></a>&nbsp;
			<a href="#" class="btn btn-icon" onclick="OnClickDelete();">
				<span><span class="icon-delete"></span>삭제&nbsp;<!-- 삭제 -->
			</span></a>
		</td>
		<td>&nbsp;</td>
		<td width="300" class="DocuNo" align="right">
		</td>
	</tr>
</table>

<!-- table 간 공백 -->
<div class=space>&nbsp;</div>

<script>
function goList() {
	var obj = event.srcElement;
	var idx = obj.selectedIndex;
	var	url = "/addressbook/addressbook_p_list.jsp?acid=ALL&menuid=MENU07010201&codekey=null";
	
	if( idx == 0 ) {
	} else if ( idx == 1) {
		return;
	} else if ( idx == 2) {
		return;
	} else if ( idx == 3) {
		return;
	} else if ( idx == 4) {
		return;
	} else if ( idx == 5) {
		url = "/mail/mail_grouplist.jsp";
	}
	self.location = url;
}
</script>

<div id="viewList" class="div-view" style="width:100%; " onpropertychanges="div_resize();">
<table width=100% cellspacing=0 cellpadding=0 border=0 class=mail_list id="mail_list" style="table-layout:fixed; ">
	<colgroup>
		<col width="26">
		<col width="250">
		<col width="3">
		<col width="*">
	<!--
		<col width="3">
		<col width="*">
	-->
	</colgroup>
	<tr style="height:23px;">
		<td class=col><img src="../common/images/btn_checkbox.gif" align=absmiddle hidefocus=true onClick="OnClickToggleAllSelect()"></td>
		<td class=col>편지지명&nbsp;<!-- 편지지명 --></td>
		<td class=col_p><img src="/common/images/h_pipe.gif" width="1" height="10"></td>
		<td class=col><fmt:message key="t.descript"/>&nbsp;<!-- 설명 --></td>
	</tr>

	<!-- 본문 DATA 목록 -->
	<%
		if (listPage.size() > 0) {
			boolean alternating = false;
			Iterator iter = listPage.iterator();
			while (iter.hasNext()) {
				MailPaperInfo item = (MailPaperInfo)iter.next();
	%>

	<tr height='25' <%=(alternating ? "bgcolor='#f5f5f5'" : StringUtil.EMPTY)%>>
		<td nowrap>
			<input type="checkbox" name="delid" value="<%=item.getDocId() %>">
		</td>
		<td class="SubText">
			<a href="javascript:OnClickOpenRecipientGroup('<%=item.getDocId()%>')">
				<%=HtmlEncoder.encode(item.getSubject())%>
			</a>
		</td>
		<td align="center"></td>
		<td align="centers" class="SubText">
			<%=HtmlEncoder.encode(item.getDescript())%>
		</td>
	<!-- 
		<td align="center"></td>
		<td align="centers" class="SubText">&nbsp;</td>
	 -->
	</tr>

	<%
			alternating = !alternating;
		    }
	    } else {
	    	String NODoc_autodelete = "문서가 존재하지 않습니다!";
	    	if(loginuser.locale.equals("en")){NODoc_autodelete = "Document does not exist!";}
			out.println("<table width='100%' style='height:expression(document.body.clientHeight-220);' border='0' cellspacing='0' cellpadding='0'><tr>"
					+ "<td width='5'></td><td>"+StringUtil.getNODocExistMsg(200, NODoc_autodelete)
					+ "</td><td width='5'></td></tr></table>"); 
		}
	%>																			
</table>
<!-- 본문 DATA 끝-->
</div>


<!-- table 간 공백 -->
<div class=space>&nbsp;</div>

<table width="100%" border="0" cellspacing="0" cellpadding="0" height="30" style="top:expression(document.body.clientHeight-38);">
	<tr>
		<td bgcolor="ebf0f8" style="border:1px solid #90b3d2; border-widths:1px 0px 0px 0px;"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;">
				<tr>
					<td width="15">&nbsp;</td>
					<td width="*" class="PageNo">
						<jsp:include page="../common/page_numbering.jsp" flush="true">
							<jsp:param name="totalcount" value="<%=listPage.getTotalCount()%>"/>
							<jsp:param name="pg" value="<%=listPage.getPageNo()%>"/>
							<jsp:param name="linkurl" value="mail_grouplist.jsp"/>
							<jsp:param name="paramstring" value="<%=queryString%>"/>
							<jsp:param name="linktype" value="1"/> 
							<jsp:param name="listppage" value="<%=uservariable.listPPage%>"/>
							<jsp:param name="blockppage" value="<%=uservariable.blockPPage%>"/>
						</jsp:include>
					</td>
					<td width="1">&nbsp;</td>
					<td width="290" align="right"> 
					</td>
					<td width="5">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</td>
</tr>
</table>

</body>
<script language="javascript">
	SetHelpIndex("");
</script>
</fmt:bundle>
</html>

<script>
function t_set_refresh() {
	var tbl = document.getElementById( "mail_list" );
	var tr = tbl.rows;
	for( var i=0; i< tr.length; i++ ) {
		if ( i%2 ) {
			tr[i].style.backgroundColor = "#FFFFFF";
		} else {
			tr[i].style.backgroundColor = "#F9F9F9";
		}
	}
}

function t_set( args ) {
	var tbl = document.getElementById( "mail_list" );
	var tr = tbl.rows;
	for( var i=0; i< tr.length; i++ ) {
		if ( i%2 ) {
			tr[i].style.backgroundColor = "#FFFFFF";
		} else {
			tr[i].style.backgroundColor = "#F9F9F9";
		}
		
		tr[i].onmouseover = function () {
			if ( this.cells[0].childNodes[0].tagName == "INPUT" ) {
				var chk = this.cells[0].childNodes[0];
				if ( chk.checked ) {
					return;
				}
			}
			this.style.backgroundColor = "#EEEEF4";
		}

		if ( i%2 ) {
			tr[i].onmouseout = function () {
				if ( this.cells[0].childNodes[0].tagName == "INPUT" ) {
					var chk = this.cells[0].childNodes[0];
					if ( chk.checked ) {
						return;
					}
				}

				this.style.backgroundColor = "#FFFFFF";
			}
		} else {
			tr[i].onmouseout = function () {
				if ( this.cells[0].childNodes[0].tagName == "INPUT" ) {
					var chk = this.cells[0].childNodes[0];
					if ( chk.checked ) {
						return;
					}
				}

				this.style.backgroundColor = "#F9F9F9";
			}
		}
	}
}

t_set();
</script>
