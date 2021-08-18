<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.login.*" %>
<%@ page import="nek.configuration.UserWrite" %>

<% request.setCharacterEncoding("UTF-8"); %>

<%

    boolean bExit = false ; 

    LoginUser loginuser = new LoginUser() ; 
    loginuser.securityId = 9 ; 

	String loginid = request.getParameter("loginid");
    if ((loginid == null ) || ("".equals(loginid)) ) loginid = "" ; 
    
	if ( !"".equals(loginid))
	{
        UserWrite userwrite = null ; 
        try{
            userwrite = new UserWrite(loginuser);
            userwrite.getDBConnection();

            bExit = userwrite.getIsLoginIdExist(loginid) ; 

        }catch (Exception ex){
            
        } finally {
            userwrite.freeDBConnection();
        }

	}
%>
<HTML>
<HEAD>
<TITLE>중복검사</TITLE>
<link rel="stylesheet" href="../common/css/blue/blue.css" type="text/css">
<link rel="stylesheet" href="./css/popup.css" type="text/css">
<script src="../common/scripts/common.js"></script>
<script>


	function goSubmit(){
		if (isEmpty("loginid")) 
		{
            alert("로그인 ID를 입력하십시오"); 
            document.submitForm.loginid.focus() ; 
            return ; 
		}
		if(document.submitForm.loginid.value.length<4||document.submitForm.loginid.value.length>12){
			alert("로그인ID는 4자리이상 12자리이하가 되어야 합니다."); 
            document.submitForm.loginid.focus() ; 
            return ; 
		}

		submitForm.submit();
	}


    function goOK()
    {
<%  if (!(loginid.equals("")) && (!bExit)) {  %>
		var returnVal =  "<%= loginid %>"+"|"  ;
        var returnVal = returnVal  + "T"  ;
    	window.returnValue = returnVal ;
<%  } else { %>
    	window.returnValue =  "|"  ;
<%  } %>
		window.close();
    }



</script>

</HEAD>
<body TEXT="000000" BGCOLOR="FFFFFF" STYLE="border:1 solid #D4D0C8" LINK="0000FF" ALINK="FF60AF" VLINK="000000">
<form name="submitForm" method="GET" action="./user_idcheck.jsp">

<!-- 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34">
	<tr> 
		<td height="27"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
				<tr> 
					<td width="35"><img src="../common/images/blue/sub_img/sub_title_board.jpg" width="27" height="27"></td>
					<td class="SubTitle">로그인 ID 중복검사</td>
					<td valign="bottom" width="*" align="right"> 
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
					<td width="200" bgcolor="eaeaea"><img src="../common/images/blue/sub_img/sub_title_line.jpg" width="200" height="3"></td>
					<td bgcolor="eaeaea"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 타이틀 끝 -->

<table><tr><td class=tblspace03></td></tr></table>

<!-- 검색 -->
<TABLE WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0>
	<TR>
		<TD align=center>
			검색 로그인 ID&nbsp;<INPUT type="text" NAME="loginid" VALUE="<%= loginid %>" SIZE=18  onkeyPress="if(window.event.keyCode == 13){goSubmit();return false;}">&nbsp;
			<a href="javascript:goSubmit();" >
			<img src=../common/images/act_search_off.gif align=absmiddle border=0 name="image4"></a>
		</TD>
	</TR>
</TABLE>
<!-- 3D Line -->
<TABLE WIDTH="100%" HEIGHT=2 BORDER=0 CELLSPACING=0 CELLPADDING=0  BGCOLOR=D4D0C8  style="padding:5px;">
	<TR>
		<TD VALIGN=middle BACKGROUND ="../common/images/pop_bg_line.gif"></TD>
	</TR>
</TABLE>

<TABLE width=100% height="50" border=0 CELLSPACING=0 CELLPADDING=3 BGCOLOR="FFFFFF" STYLE="table-layout:fixed; ">
	<tr>
		<td style="width:100%;height:100%;" nowrap style="text-valign:middle; padding-left:20px;text-align:center;">
            <FONT size="3" COLOR="#6600FF">
			<% if (loginid.equals("")) {  %>
			    중복 검사 할 로그인 ID를 입력하십시오. <br> 
			<% } else if (bExit) { %>
			        이미 존재하는 ID입니다. <br>
			        다시 검색 하십시오.
			<% } else {  %>
			      사용가능합니다. <br> 
			<%  } %>
            </FONT>
		</td>
	<tr>
</TABLE>

<table width=100% BGCOLOR=D4D0c8><tr height="3px"><td></td></tr></table><!-- 여백 삽입 -->
<!-- 3D Line -->
<TABLE WIDTH="100%" HEIGHT=1 BORDER=0 CELLSPACING=0 CELLPADDING=0  BGCOLOR=D4D0C8  style="padding:5px;">
	<TR>
		<TD VALIGN=middle BACKGROUND ="../common/images/pop_bg_line.gif"></TD>
	</TR>
</TABLE>
<!-- 확인 버튼 -->
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr align="center">
		<td>
          <a href="#"><img src="../common/images/btn_ok.gif" border="0" align="absmiddle" onclick="javascript:goOK();"></a>&nbsp;          

        </td>
	</tr>
</table>
<TABLE WIDTH="100%" HEIGHT=1 BORDER=0 CELLSPACING=0 CELLPADDING=0  BGCOLOR=D4D0C8  style="padding:5px;">
	<TR>
		<TD VALIGN=middle BACKGROUND ="../common/images/pop_bg_line.gif"></TD>
	</TR>
</TABLE>
</TD>
</TR>
</TABLE>

</FORM>

</BODY>
</HTML>