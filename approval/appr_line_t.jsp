<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="nek.common.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
%>
<%
    String sUid = loginuser.uid ;


    int iMenuId = ApprMenuId.ID_430_NUM_INT ; 

    String sNo = ApprUtil.nullCheck(request.getParameter("no")) ; //결재선 수정 ApprDocCode.APPR_NUM_1, 결재선 선택 ApprDocCode.APPR_NUM_2
    //String sPop = ApprUtil.nullCheck(request.getParameter("pop")) ; //팦업으로 호출
    ArrayList arrList = new ArrayList() ;    
    //DB 에 갔다 오기 왜냐 임시저장데이타를 가져와야 할 것 아님감. ㅋㅋㅋ
    ApprLine lineObj = null ;
    try
    {
        lineObj = new ApprLine() ;

        arrList = lineObj.ApprLineHDListSelect( sUid) ;

    }catch(Exception e){
        Debug.println (e) ;
    } finally {
        lineObj.freeConnecDB() ;
    }
%>

<HTML>
<HEAD>
<TITLE><%=msglang.getString("appr.selectline") /* 결재선 선택 */ %></TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<!-- css -->
<%
    if(sNo.equals(ApprDocCode.APPR_NUM_1))  //결재선 수정, 신규
    {
%>
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/list.css">
<%
    } else if(sNo.equals(ApprDocCode.APPR_NUM_2)) { //결재선 선택
%>
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/popup.css">
<%
    }
%>
<link rel="stylesheet" href="/common/css/style.css">

<!-- script -->
<script src="<%= sJsScriptPath %>/common.js"></script>
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<SCRIPT LANGUAGE="JavaScript">
<!--
     //도움말
    SetHelpIndex("appr_line") ;

    function selline(lineID)
    {        
        //var obj = eval("document.all."+linetit)  ;
        //document.mainForm.linetitle.innerText =  obj.innerText ;

        document.mainForm.lineid.value =  lineID ;
        document.mainForm.method = "get" ; 
        document.mainForm.submit() ;
    }

//-->
</SCRIPT>
</head>
<body style="margin:0px;padding:0px;">
<form name="mainForm" action="./appr_line_d.jsp" method="get" target= "downfrm" onsubmit="return false;">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /><B> 
			<%//=ApprUtil.getNavigation(iMenuId)%> 
			<%=msglang.getString("main.Approval") /* 전자결재 */ %> &gt;
			<%=msglang.getString("appr.menu.config") /* 환경설정 */ %> &gt;
			<%=msglang.getString("appr.menu.line.set") /* 결재선 */ %>
		</B></span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
<input type="hidden" name="lineid" value="">
<input type="hidden" name="no" value="<%= sNo %>">
<%    if(sNo.equals(ApprDocCode.APPR_NUM_1)) {  //결재선 수정, 신규 %>
<!-- 타이틀 시작 -->
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="44"> -->
<!-- 	<tr>  -->
<!-- 		<td height="27">  -->
<!-- 			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- 				<tr>  -->
<%-- 					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_approval.jpg" width="27" height="27"></td> --%>
<%-- 					<td class="SubTitle"><%= ApprUtil.getNavigation(iMenuId)%><!-- <%= ApprUtil.getTitleText(iMenuId) %>--></td> --%>
<!-- 					<td valign="bottom" width="250" align="right">  -->
<!-- 						<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 							<tr>  -->
<%-- 								<td valign="top" class="SubLocation"><!-- <%= ApprUtil.getNavigation(iMenuId)%>--></td> --%>
<%-- 								<td align="right" width="15"><img src="<%=imagePath %>/sub_img/sub_title_location_icon.jpg" width="10" height="10"></td> --%>
<!-- 							</tr> -->
<!-- 						</table> -->
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
<%    } else if(sNo.equals(ApprDocCode.APPR_NUM_2)) { //결재선 선택  %>
<!-- 타이틀 시작 -->
<!-- <table width="100%" border="0" cellspacing="0" cellpadding="0" height="34"> -->
<!-- 	<tr>  -->
<!-- 		<td height="27">  -->
<!-- 			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- 				<tr>  -->
<!-- 					<td width="35"><img src="../common/images/blue/sub_img/sub_title_approval.jpg" width="27" height="27"></td> -->
<!-- 					<td class="SubTitle">결재선 선택</td> -->
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
<!-- 					<td width="200" bgcolor="eaeaea"><img src="../common/images/blue/sub_img/sub_title_line.jpg" width="200" height="3"></td> -->
<!-- 					<td bgcolor="eaeaea"></td> -->
<!-- 				</tr> -->
<!-- 			</table> -->
<!-- 		</td> -->
<!-- 	</tr> -->
<!-- </table> -->
<!-- 타이틀 끝 -->
<%    }  %>

</form>
</body>
</html>