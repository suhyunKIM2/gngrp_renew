<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.approval.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
%>
<%

    // "<>UID |결재형태코드"
    String sarrType = ApprUtil.nullCheck(request.getParameter("apprtype")) ; //
    String sLineFormID = ApprUtil.nullCheck(request.getParameter("formid")) ; //
    sLineFormID = "";	//만호요청 양식 결재선 사용안함.


%>
<!DOCTYPE HTML>
<html>
<head>
<title>결재선저장</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" type="text/css" href="<%= sCssPath %>/popup.css">
<link rel="stylesheet" type="text/css" href="<%= imgCssPath %>">
<script language="javascript">
<!--
function doSubmit()
{
	if ($.trim($('input[name=linetitle]').val()) == "") {
		alert('<%=msglang.getString("appr.input.title") /* 결재라인 제목은 필수 입력값입니다. */ %>');
		return;
	}
    document.mainForm.method = "post" ; 
    document.mainForm.submit() ; 
}

function doClose() 
{
    window.close() ; 
}
//-->
</script>
</head>

<body style="margin:0;overflow:hidden;">
<form name="mainForm" method="post" action="./appr_linecontrol.jsp">
<input type="hidden" name="cmd" value= "<%= ApprDocCode.APPR_EDIT %>" >
<input type="hidden" name="formid" value= "<%= sLineFormID %>" >
<input type="hidden" name="pop" value="1">
<!-- 타이틀 시작 -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /><b> <%=msglang.getString("appr.save.apline") /* 결재라인 저장 */ %> </b></span>
</td>
<td width="40%" align="right">
</td>
</tr>
</table>
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="34"> -->
<!-- 	<tr>  -->
<!-- 		<td height="27">  -->
<!-- 			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- 				<tr> -->
<%-- 					<td width="35"><img src="<%=imagePath %>/blue/sub_img/sub_title_approval.jpg" width="27" height="27"></td> --%>
<!-- 					<td class="SubTitle">결재선 저장</td> -->
<!-- 					<td valign="bottom" width="*" align="right">  -->
<!-- 					</td> -->
<!-- 				</tr> -->
<!-- 			</table> -->
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
<table width="515" cellspacing="0" cellpadding="0" border="0">
	<tr height="10"><td colspan="2"></td></tr>
	<tr>
		<td width="150" class="td_le1" style="width:150px;">
			<%=msglang.getString("appr.title.apline") /* 결재라인 제목 */ %> <font color="red">*</font>
<%
    StringTokenizer stApprPer = new StringTokenizer(sarrType, ApprDocCode.APPR_GUBUN);
    StringTokenizer stApprUIDType = null ;
    String sApprPersons = "" ; 
    String sApprUID = "" ; 
    String sApprType = "" ; 
    while (stApprPer.hasMoreTokens())
    {
        sApprPersons = stApprPer.nextToken() ;//결재자

        stApprUIDType = new StringTokenizer(sApprPersons, "|");  //UID | 결재 유형
        sApprUID  = stApprUIDType.nextToken() ;
        sApprType = stApprUIDType.nextToken() ;

%>
<input type="hidden" name="appruid" value="<%= sApprUID %>" >
<input type="hidden" name="apprtype" value="<%= sApprType %>" >
<input type="hidden" name="lineseq"  >
<%
    }
%>
		</td>
		<td class="td_le2">
			<input type="text" name="linetitle" value="" maxlength="255" style="width: 98%;"></td>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><%=msglang.getString("appr.description.apline") /* 결재라인 설명 */ %></td>
		<td class="td_le2">
			<textarea name="linetitlenote" style="width: 98%; height: 38px;"></textarea>  
		</td>
	</tr>
<tr height="7"><td colspan="2"></td></tr>
</table>
<!---수행버튼 --->
<table width="515" cellspacing="0" cellpadding="0" border="0">
	<tr height="5" bgcolor="#E7E7E7" align="center">
		<td>
			<span onclick="doSubmit()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.save") /* 저장 */ %> </span>
			<span onclick="doClose()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.close") /* 닫기 */ %> </span>
        </td>
	</tr>
</table>
<!-- 보기 수행버튼 끝 -->
</form>
</BODY>
</HTML>
