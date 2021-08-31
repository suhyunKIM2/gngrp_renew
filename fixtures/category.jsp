<%@ page contentType="text/html;charset=utf-8"%>
<%@ page errorPage="/error.jsp"%>
<%@ page import="nek.fixtures.*"%>
<%@ page import="java.util.*"%>
<%@ page import="net.sf.json.*"%>
<%@ page import="nek.common.*,nek.common.util.Convert"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
	request.setCharacterEncoding("utf-8");
%>
<%@ include file="/common/usersession.jsp"%>

<%


int logLevel = 0; //접속자 레벨설정
boolean isAdmin = false;
if (loginuser.securityId > 8)	{ isAdmin = true;	logLevel = 3; } //전체 관리자

if(logLevel < 2) response.sendRedirect("./grant_error.jsp"); //전체관리자가 아닐경우 페이지 이동하기


String cmd = request.getParameter("cmd");
if ( cmd == null ) cmd = "insert";

java.util.Date today = new java.util.Date();
java.text.SimpleDateFormat format_today = new java.text.SimpleDateFormat("yyyy-MM-dd");
java.text.SimpleDateFormat format_fullToday = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

FixturesCategoryItem item = null;
ArrayList<FixturesCategoryItem> categoryList = null;
FixturesCategoryList categoryDoc = null;
try
{
	categoryDoc = new FixturesCategoryList();
	categoryDoc.getDBConnection();

	categoryList = categoryDoc.getCategoryListFixtures();
}
finally
{
	if (categoryDoc != null) categoryDoc.freeDBConnection();
}

%>

<!DOCTYPE html>
<HTML>
<HEAD>

<TITLE></TITLE>
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.jqgrid.css" /> -->
<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.multiselect.css" /> -->
<link rel="stylesheet" href="/common/css/style.css">
<style type="text/css">
label {
	margin: 0px 3px 0px 12px;cursor: auto;
}

/* #search_dataGrid .ui-pg-div {display: none;} /* jqgrid search hidden */ */
/* #dataGridPager {height: 30px;} /* jqgrid pager height */ */
/* .ui-jqgrid .ui-pg-selbox {	height: 23px; line-height: 23px;} /* jqgrid pager select height */ */
</style>
<script src="/common/jquery/js/jquery-1.6.4.min.js" type="text/javascript"></script>
<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js" type="text/javascript"></script>
<script src="/common/jquery/plugins/modaldialogs.js" type="text/javascript"></script>
<script src="/common/jquery/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<!-- <script src="/common/jquery/plugins/jquery.jqGrid.min.js" type="text/javascript"></script> -->
<!-- <script src="/common/jquery/plugins/ui.multiselect.js" type="text/javascript"></script> -->
<script src="/common/scripts/common.js"></script>


<script type="text/javascript">
	function goSubmit(cmd)
	{
		var saveStr = "<%=msglang.getString("c.save") %>";
		var chaStr = "<%=msglang.getString("c.change") %>";
		var delStr = "<%=msglang.getString("c.delete") %>";
		
		var frm = document.submitForm;
		switch(cmd)
		{
		case "insert_category" :
			if(frm.categoryName.value == "") return;
			if(!confirm(saveStr)) return;
			frm.cmd.value = "insert_category";
			frm.method = "post";
			frm.action = "./control_category.jsp";
			
			break;
		case "update_category":
			if(frm.categoryName.value == "") return;
			if(!confirm(chaStr)) return;
			frm.cmd.value = "update_category";
			frm.method = "post";
			frm.action = "./control_category.jsp";
			break;
		case "delete_category":
			if(frm.categoryName.value == "") return;
			if(!confirm(delStr)) return;
			frm.cmd.value = "delete_category";
			frm.method = "post";
			frm.action = "./control_category.jsp";
			break;
		default:
			break;
		}
		frm.submit();
	}
	
	
	function selCategory(cName,cId)
	{
		$('input[name=categoryName]').val(cName);
		$('input[name=categoryId]').val(cId);
		document.getElementById('saveBtn').style.display = "none";
		document.getElementById('updateBtn').style.display = "";
		document.getElementById('deleteBtn').style.display = "";
	}
	
	
</script>
<style>
.td_le1{height:60px;}
#categoryName{height:29px;}
.save_btn{height: 30px;line-height: 30px;width: 13%;background: #266fb5;color: #fff;border: 1px solid #266fb5;}
.save_btn:hover{background: #266fb5;color: #fff;}
.delete_btn{background:#999;border-color:#999;}
.delete_btn:hover{background:#999;}
</style>

</HEAD>
<BODY>
<form id="submitForm" name="submitForm" autocomplete="off" method="get" action="" enctype="multipart/form-data">
<input type="hidden" name="cmd" id="cmd" value="">
<input type="hidden" name="categoryId" id="categoryId" value="">
<!-- List Title -->	
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- <tr>  -->
<%-- 	<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_schedule.jpg" width="27" height="27"></td> --%>
<!-- 		<td class="SubTitle"><b>비품분류</b></td> -->
<!-- 		<td valign="bottom" width="250" align="right">  -->
<!-- 			<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 				<tr> -->
<!-- 					<td valign="top" class="SubLocation">비품관리 &gt; <b>비품분류</b></td> -->
<!-- 				</tr> -->
<!-- 			</table> -->
<!-- 		</td> -->
<!-- 	</tr> -->
<!-- </table> -->

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <b>
			<%=msglang.getString("src.category.set") /* 비품분류 */ %>
		</b> </span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
<!-- List Title -->	
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="3"> -->
<!-- <tr>  -->
<%-- 	<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td> --%>
<!-- 		<td bgcolor="eaeaea"></td> -->
<!-- </tr> -->
<!-- </table> -->

<div class="space">&nbsp;</div>
<div class="space">&nbsp;</div>
<%-- <table id="saveBtn" border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn01.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn01.src='<%=imagePath %>/btn2_left.jpg'" style="float:left; margin:0 10px 10px; 10px;"> --%>
<!-- <tr> -->
<%-- 	<td width="23"><img id="btnIma01" name="ch_btn01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<!-- 	<td background="../common/images/blue/btn1_bg.jpg"><span class="btntext" style="line-height:20px;">&nbsp;<a href="javascript:goSubmit('insert_category')">저장</a></span></td> -->
<!-- 	<td width="3"><img src="../common/images/blue/btn1_right.jpg" width="3" height="22"></td> -->
<!-- </tr> -->
<!-- </table> -->

<%-- <table id="updateBtn" border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn02.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn02.src='<%=imagePath %>/btn2_left.jpg'" style="float:left; margin:0 5px 0 0px; display: none;"> --%>
<!-- <tr> -->
<%-- 	<td width="23"><img id="btnIma02" name="ch_btn02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<!-- 	<td background="../common/images/blue/btn1_bg.jpg"><span class="btntext" style="line-height:20px;">&nbsp;<a href="javascript:goSubmit('update_category')">편집</a></span></td> -->
<!-- 	<td width="3"><img src="../common/images/blue/btn1_right.jpg" width="3" height="22"></td> -->
<!-- </tr> -->
<!-- </table> -->

<%-- <table id="deleteBtn" border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn03.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn03.src='<%=imagePath %>/btn2_left.jpg'" style="float:left; margin:0 5px 0 0px; display: none;"> --%>
<!-- <tr> -->
<%-- 	<td width="23"><img id="btnIma03" name="ch_btn03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<!-- 	<td background="../common/images/blue/btn1_bg.jpg"><span class="btntext" style="line-height:20px;">&nbsp;<a href="javascript:goSubmit('delete_category')">삭제</a></span></td> -->
<!-- 	<td width="3"><img src="../common/images/blue/btn1_right.jpg" width="3" height="22"></td> -->
<!-- </tr> -->
<!-- </table> -->


<div class="space">&nbsp;</div>
<div class="space">&nbsp;</div>

<div style="width:98.8%;margin:0 auto 1%;">
    <!-- 	<a href="#" onclick="window.location.reload( true );"><label>:: 새 일정 구분 등록 ::</label></a> -->
    <a onclick="javascript:window.location.reload( true );" class="button white medium ">
    <img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.newDoc") %> <%=msglang.getString("src.cat") %></a>
</div>
<%for(int i=0; i<categoryList.size();i++)
  {
    item = (FixturesCategoryItem)categoryList.get(i);
  %>
<div style="float: left; width: 200px; clear: left; padding:  0 0 0 10px; ">

<table width="100%" cellspacing=0 cellpadding=0  style="border:1px solid #90B9CB; background-color:#EDF2F5;">

	
<tr >
	<td class="td_le1" >
		<a href="javascript:selCategory('<%=item.getCategoryName() %>','<%=item.getCategoryId() %>')"><%=item.getCategoryName() %></a>
	</td>
</tr>
	<%} %>
</table>
</div>

<div style="float: left;padding-left:5px; width: 55%;">
<table width="100%" cellspacing=0 cellpadding=0  style="border:1px solid #90B9CB; padding:2 2 2 4; background-color:#EDF2F5;">
<tr>
	<td class="td_le1" NOWRAP><%=msglang.getString("t.subject") %></td> 
	<td class="td_le2" NOWRAP>
		<input type="text" name="categoryName" id="categoryName" value="" size="30"/>&nbsp;
		<a onclick="javascript:goSubmit('insert_category');" id="saveBtn" class="button white medium save_btn">
		<!--<img src="../common/images/bb02.gif" border="0">--> <%=msglang.getString("t.save") %> </a>
		<a onclick="javascript:goSubmit('update_category');" id="updateBtn" class="button white medium save_btn" style="display:none;" >
		<!--<img src="../common/images/bb02.gif" border="0">--> <%=msglang.getString("t.modify") %> </a>
		<a onclick="javascript:goSubmit('delete_category');" id="deleteBtn" class="button white medium save_btn delete_btn" style="display:none;" >
		<!--<img src="../common/images/bb02.gif" border="0">--> <%=msglang.getString("t.delete") %> </a>
		<input type="text" style="display: none;" />
	</td>
</tr>
</table>
</div>

</form>
</BODY>

</HTML>