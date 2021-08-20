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
    String sUid = loginuser.uid ;


    int iMenuId = ApprMenuId.ID_430_NUM_INT ;

    String sNo = ApprUtil.nullCheck(request.getParameter("no")) ; //결재선 수정 ApprDocCode.APPR_NUM_1, 결재선 선택 ApprDocCode.APPR_NUM_2
    String sLineId = ApprUtil.nullCheck(request.getParameter("lineid")) ; //등록시 결재선 번호

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
<html>
<head>
<TITLE>결재선</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/list.css">
<!-- script -->
<script src="<%= sJsScriptPath %>/common.js"></script>
<SCRIPT LANGUAGE="JavaScript">
<!--
 //도움말
SetHelpIndex("appr_line") ;

function oneSelect()
{
    var index = document.mainForm.linehdname.selectedIndex ;

    if (index < 0 ){  return ;  }
    document.mainForm.lineid.value = document.mainForm.linehdname[index].value ;
    //alert(document.mainForm.lineid.value) ;
    document.mainForm.submit() ;

}
//-->
</SCRIPT>
</head>
<body style=" margin:0px; padding:3px; padding-top:7px; background-image:none;">
<form NAME="mainForm" METHOD="get" action="./appr_line_r.jsp" target = "rightfrm" onsubmit="return false;">
<input type="hidden" name="cmd" value= "" >
<input type="hidden" name="no" value= "<%= sNo %>" >
<input type="hidden" name="lineid" >
<input type="hidden" name="defaultlineid" >
<table width="100%" height="425" cellspacing="0" cellpadding="0" border="0">
<tr height=28>
    <td class="td_le1" valign=top style="padding-right:0px; text-align:center; "><%=msglang.getString("appr.aplinelist") %><!-- 결재선 리스트-->
	</td>
</tr>
<tr>
    <td valign=top class="td_le2" style="padding-right:0px; background:#E4E4E4;">
        <!-- <select name="linehdname" multiple style="width:90%; height: 100%;" OnDblClick="javascript:oneSelect();"> -->
        <select name="linehdname" multiple style="width:98%; height:100%;" Onchange="javascript:oneSelect();">
<%
    int iSize = arrList.size() ;
    if(iSize > 0 )
    {
        ApprLineHDInfo apprlinehdInfo = null ;
	    for(int i = 0; i < iSize; i++){			// for문을 돌면서 해당 데이터만 화면에 뿌린다.
	        apprlinehdInfo = (ApprLineHDInfo)arrList.get(i);
            //등록등 결재선 번호를 입력받으면 해당 결재선을 보여주고 그렇지 않다면 기본 결재선을 보여주어라.
            if(sLineId.equals("")){
%>
            <option value="<%= ApprUtil.nullCheck(apprlinehdInfo.getApprLineNo()) %>" <% if (apprlinehdInfo.getLineDefault().equals(ApprDocCode.APPR_SETTING_T)) out.write("selected"); %>><%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck(apprlinehdInfo.getApprLineNm())) %></option>
<%          } else { %>
            <option value="<%= ApprUtil.nullCheck(apprlinehdInfo.getApprLineNo()) %>" <% if (apprlinehdInfo.getApprLineNo().equals(sLineId)) out.write("selected"); %>><%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck(apprlinehdInfo.getApprLineNm())) %></option>
<%
            }
        }
    }
%>
        </select>
    </td>
</table>

</form>
</body>
</html>
