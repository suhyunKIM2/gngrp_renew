<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
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
    String sUid = loginuser.uid;

    String sNo = ApprUtil.nullCheck(request.getParameter("no")) ; //결재선 수정 ApprDocCode.APPR_NUM_1, 결재선 선택 ApprDocCode.APPR_NUM_2
    String sLineId = ApprUtil.nullCheck(request.getParameter("lineid")) ; //결재선 번호
    String sDefaultLineId = ApprUtil.nullCheck(request.getParameter("defaultlineid")) ; //결재선 번호

    ArrayList arrList = new ArrayList() ;
    ArrayList formList = new ArrayList() ;
    ApprLineHDInfo applineHDInfo = new ApprLineHDInfo() ;
    ApprLine lineObj = null ;
	//결재양식 호출
    ApprForm apprObj = null ;
   try
    {
        lineObj = new ApprLine() ;

        //결재선번호가 없다면 기본 결재선을 가져오라.
        sDefaultLineId = lineObj.ApprLineDefaultSelect(sUid) ;
        if ( sLineId.equals("")){
            sLineId = sDefaultLineId ;
        }

        //결재선정보를 가져와라. //기본결재선도 없다면 실행을 하지 마라.
        if (!sLineId.equals("")) {
            arrList = lineObj.ApprLineDTListSelect( sUid, sLineId) ;
            applineHDInfo = lineObj.ApprLineHDApprNo(sUid, sLineId) ;
        }
        
		//결재양식 호출
       	apprObj = new ApprForm() ;
		formList = apprObj.ApprFormList();
        	

    }catch(Exception e){
        Debug.println (e) ;
    } finally {
        lineObj.freeConnecDB() ;
        apprObj.freeConnecDB() ;
    }

%>
<html>
<head>
<TITLE>결재선</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/list.css">
<!-- script -->
<script src="<%= sJsScriptPath %>/common.js"></script>
<script src="./appr_table.js"></script>

<link rel=STYLESHEET type="text/css" href="/common/css/style.css">
<SCRIPT LANGUAGE="JavaScript">
<!--
 //도움말
SetHelpIndex("appr_line") ;
var SWIDTH = "615"  ; 
var SHEIGHT = "486" ; 
function doNewOpen()
{
    var returnval = OpenModal( "appr_lineedit.jsp" , null , SWIDTH , SHEIGHT)  ;
    //var returnval = window.showModalDialog("appr_lineedit.jsp", null,  "dialogHeight: 800px; dialogWidth: 600px;") ;
//alert(returnval) ;
    if ((returnval != null) && (returnval != "") ) {
        parent.leftfrm.location.href ="./appr_line_l.jsp?lineid="+returnval+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
        parent.rightfrm.location.href ="./appr_line_r.jsp?lineid="+returnval+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
    }
}

function doEditOpen(sLineId)
{
    //결재선을 선택했는지 확인하자.

//    if(mainForm.lineid.value == "")
    if(sLineId == "")
    {
        alert("선택한 결재선이 없습니다.") ;
        return ;
    }

    var returnval = OpenModal( "appr_lineedit.jsp?apprid="+sLineId , null , SWIDTH , SHEIGHT)  ;
    //var returnval = window.showModalDialog("appr_lineedit.jsp?apprid="+sLineId ,null ,  "dialogHeight: 800px; dialogWidth: 600px;") ;
    if ((returnval != null) && (returnval != "") ) {
        parent.rightfrm.location.reload();
        //doReload() ;
    }
}
 //화면수정이 일어 났다면 재 로드해야 한다.
function doReload()
{
    var slineid = document.mainForm.lineid.value ;

    parent.leftfrm.location.href ="./appr_line_l.jsp?lineid="+slineid+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
    parent.rightfrm.location.href ="./appr_line_r.jsp?lineid="+slineid+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
}

function doDelete()
{    
    if (document.mainForm.lineid.value == "" )
    {
        alert("삭제 할 결재선을 선택하십시오");
        return ;
    }
    if (!confirm("삭제 하시겠습니까?")) return ;
//자료가 없다면 어떻게 할래

    document.mainForm.cmd.value = "<%= ApprDocCode.APPR_DELETE %>" ;
    document.mainForm.action = "./appr_linecontrol.jsp"  ;
    document.mainForm.method = "post" ;
    document.mainForm.submit() ;

}

function setStdLine()
{
    if (document.mainForm.lineid.value == "" )
    {
        alert("기본 결재선을 선택하십시오");
        return ;
    }
    if (!confirm("기본 결재선으로 등록하시겠습니까?")) return ;
//자료가 없다면 어떻게 할래
    document.mainForm.cmd.value = "<%= ApprDocCode.APPR_DEFAULT_LINE %>" ;
    document.mainForm.action = "./appr_linecontrol.jsp"  ;
    document.mainForm.method = "post" ;
    document.mainForm.submit() ;
}

//--------------------------------------------------------------------------------------------------------
function doSubmit()
{

    //open한 곳으로 값을 넘겨라.    //루프를 돌아라.

    var typenm, dname, uname, nname, uid, apprtype, returnVal,udName ;
    //var tbl = this.sharetbl ;
    //var idx = mainForm.apprtypename.length ;
    var returnVal = "" ;
    var idx = document.getElementsByName("apprtypename").length;

    var typenmobj =document.getElementsByName("apprtypename") ; // 결재유형명
    var dnameobj = document.getElementsByName("dname") ; // 부서명
    var unameobj = document.getElementsByName("uname") ; // 직위명
    var nnameobj = document.getElementsByName("nname") ; // 이름명
    var udNameobj = document.getElementsByName("udname") ; // 직책명
    var uidobj = document.getElementsByName("appruid") ; // UID
    var apprtypeobj = document.getElementsByName("apprtype") ; // 결재유형

    for(var i = 0 ; i < idx ; i++)
    {
        typenm = typenmobj[i].value ; // 결재유형명
        dname = dnameobj[i].value ; // 부서명
        uname = unameobj[i].value ; // 직위명
        nname = nnameobj[i].value ; // 이름명
        udName = udNameobj[i].value;	//직책명
        uid = uidobj[i].value ; // UID
        apprtype = apprtypeobj[i].value ; // 결재유형

        returnVal = returnVal + "<%= ApprDocCode.APPR_GUBUN %>" + typenm+ "|" + dname+ "|" + uname+ "|" + nname + "|" + uid + "|" + apprtype + "|" + udName ;
    }

//alert(returnVal) ;
    if (returnVal == "" )  //결재자 없이 종료하는 경우
    {
        if (!confirm("결재자가 없습니다. \n\n종료 하시겠습니까?")) return ;
    }
//     window.returnValue = returnVal;
//     document.mainForm.method = "post" ;
//     window.close();
    if (parent.opener) parent.opener.returnValue = returnVal;
    parent.returnValue = returnVal;
    parent.close();
}
function doClose()
{
//     window.returnValue = "" ;
//     window.close();
	if (parent.opener) parent.opener.returnValue = "";
	parent.close();
}
//-->
</SCRIPT>
</head>
<body  style="margin-left:3pt;margin-top:5pt; padding-top:0; background-image:none;">
<form NAME="mainForm" METHOD="post" action="./appr_linecontrol.jsp" target = "hidfrm" onsubmit="return false;">

<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
	    <td width = "5">&nbsp;</td>
	    <td>
    	    <table width="100%" cellspacing="0" cellpadding="0" border="0" >
	            <tr>
    	            <td width="95" class="td_le1" align="left"><%=msglang.getString("appr.aplinesubj") %><!-- 결재라인 제목-->&nbsp;<font color="red">*</font></td>
        	        <td class="td_le2"><%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck(applineHDInfo.getApprLineNm())) %></td>
	            </tr>
    	        <tr>
					<td class="td_le1" align="left"><%=msglang.getString("appr.aplinedetail") %><!-- 결재라인 설명-->&nbsp;</td>
					<td class="td_le2" align="left">
						<%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck(applineHDInfo.getApprLineDes())) %>
	                </td>
				</tr>
				<tr>
					<td class="td_le1" align="left"><%=msglang.getString("appr.aplineform") %><!-- 결재양식명-->&nbsp;</td>
					<td class="td_le2" align="left">
	            	<%
	            	if ( (sLineId != null) &&( !sLineId.equals("")) ) {
	            		String formName = "";
	            		int formSize = formList.size() ;
					    if(formSize > 0 )
					    {
					        String sFormId = "" ;
					        ApprFormInfo apprformInfo = null ;
						    for(int i = 0; i < formSize; i++){			// for문을 돌면서 해당 데이터만 화면에 뿌린다.
						        apprformInfo = (ApprFormInfo)formList.get(i);
					            sFormId = ApprUtil.nullCheck(apprformInfo.getFormID()) ;
	            	
	            				if(sFormId.equals(applineHDInfo.getFormId())){
	            					formName = apprformInfo.getSubject();
	            				}
						    }
					    }
	            	%>
	            	<font color="black"><B><%=formName %></B></font>
	            	<%} %>
					</td>
				</tr>
				<tr height="7"><td colspan="2"></td></tr>
			</table>
			<div style="height:200px;width:100%;overflow-y:auto;border:1px;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" >
				<colgroup>
				<col width="7%">
				<col width="14%">
				<col width="24%">
				<col width="16%">
				<col width="*">
				</colgroup>
				<tr>
					<td width="7%" class="td_ce1"><%=msglang.getString("appr.aplinesubj") %><!-- 순서--></td>
					<td width="13%" class="td_ce1"><%=msglang.getString("appr.aplinesubj") %><!-- 결재형태--></td>
					<td width="35%" class="td_ce1"><%=msglang.getString("t.dpName")%><!-- 부서 --></td>
					<td width="20%" class="td_ce1"><%=msglang.getString("t.upName")%><!-- 직위 --></td>
					<td width="*" class="td_ce1"><%=msglang.getString("t.name") %><!-- 성명 --></td>
				</tr>
			<%
				int iSize = arrList.size() ;
			    if(iSize > 0 )
			    {
			        ApprLineDTInfo arrlinedtInfo = null ;
			        String sShape = "" ;
			        String sTemp = "" ;
			
				    for(int i = 0; i < iSize ; i++){			// for문을 돌면서 해당 데이터만 화면에 뿌린다.
				         arrlinedtInfo = (ApprLineDTInfo)arrList.get(i);
			
			             //결재형태 설정
			             sTemp = ApprUtil.nullCheck(arrlinedtInfo.getApprType()) ;
			
			             sShape = ApprUtil.getApprTypeHan(sTemp) ;
			%>
				<tr height="25px">
					<td class="td_ce2" nowrap>[<%= (i+1) %>]</td>
					<td class="td_ce2" nowrap><%= sShape %>&nbsp;</td>
					<td class="td_ce2" nowrap><%= ApprUtil.nullCheck(arrlinedtInfo.getDname()) %>&nbsp;</td>
	                <td class="td_ce2" nowrap><%= ApprUtil.nullCheck(arrlinedtInfo.getUname()) %>&nbsp;</td>
					<td class="td_ce2" nowrap  style="line-height:12px;" ><%= ApprUtil.nullCheck(arrlinedtInfo.getNname()) %>&nbsp;
	                <input type="hidden" name="appruid" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getApprPersonUID()) %>" >
	                <input type="hidden" name="apprtype" value= "<%= sTemp %>" >
	                <input type="hidden" name="lineseq" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getApprSeq()) %>" >
	                <input type="hidden" name="lineIds" value= "<%= sLineId %>" >
	                <input type="hidden" name="dname" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getDname()) %>" >
	                <input type="hidden" name="uname" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getUname()) %>" >
	                <input type="hidden" name="nname" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getNname()) %>" >
	                <input type="hidden" name="apprtypename" value= "<%= sShape %>" >
	                <input type="hidden" name="udname" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getUdname()) %>" >
	                </td>
				</tr>
			<%
			        }
			    } else {// for
			%>
			     <tr>
					<td class="td_ce2" align=center  nowrap colspan="5"><%=msglang.getString("appr.aplineselect") %><!-- 좌측의 결재선을 선택하십시오.--></td>
				</tr>
			<%
				}
			%>
 			</table>
			</div>
		</td>
	</tr>
</table>

<table><tr height="1" bgcolor="#B6B5B6"><td ></td></tr></table>

<table width="100%">
	<tr height="3"><td></td></tr>
	<tr>
		<td align="center" valign="absmiddle" ><font color="#4d4d4d">(<%=msglang.getString("appr.aplinecmt") %><!-- 위에서 아래로 순차적으로 결재가 진행됩니다.-->)</font></td>
	</tr>
</table>

<table><tr><td class="tblspace09"></td></tr></table>

<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr height="5" bgcolor="#E7E7E7" align="center">
		<td>
		<a onclick="javascript:doSubmit();" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.ok") %> </a>
		&nbsp;&nbsp;
		<a onclick="javascript:doClose();" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.close") %> </a>
<!-- 			<a href="javascript:doSubmit();"> -->
<%-- 				<img src="<%= sImagePath %>/btn_ok.gif" alt="확인" border=0 > --%>
<!-- 			</a>&nbsp;&nbsp; -->
<!-- 			<a href="javascript:doClose();"> -->
<%-- 				<img src="<%= sImagePath %>/btn_cancel.gif" alt="닫기" border=0 > --%>
<!-- 			</a> -->
		</td>
	</tr>
</table>
<!-- 보기 수행버튼 끝 -->

<input type="hidden" name="cmd" value= "" >
<input type="hidden" name="no" value= "<%= sNo %>" >
<input type="hidden" name="lineid" value= "<%= sLineId %>" >
<input type="hidden" name="defaultlineid" value="<%= sDefaultLineId %>" >

</form>
</body>
</html>


<% if (!sDefaultLineId.equals("")) { %>
<SCRIPT LANGUAGE="JavaScript">
<!--
//기본결재라인번호 설정
if ( parent.leftfrm.document.mainForm.defaultlineid != null ) {
    parent.leftfrm.document.mainForm.defaultlineid.value = "<%= sDefaultLineId %>" ;
}
//-->
</SCRIPT>
<% } %>