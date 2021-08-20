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
<!DOCTYPE html>
<html>
<head>
<title>결재선</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" type="text/css" href="<%= sCssPath %>/list.css">
<script src="./appr_table.js"></script>
<script language="javascript">
<!--
 //도움말
SetHelpIndex("appr_line") ;
var SWIDTH = "615"  ; 
var SHEIGHT = "486" ; 



//(window.showModalDialog Version)
function doNewOpenModal() {
    var returnval = OpenModal( "appr_lineedit_d.jsp" , null , SWIDTH , SHEIGHT)  ;
    //var returnval = window.showModalDialog("appr_lineedit.jsp", null,  "dialogHeight: 800px; dialogWidth: 600px;") ;
	//alert(returnval) ;
	if (returnval == undefined) returnval = window.returnValue;
    if ((returnval != null) && (returnval != "") ) {
        parent.leftfrm.location.href ="./appr_line_l.jsp?lineid="+returnval+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
        parent.rightfrm.location.href ="./appr_line_r.jsp?lineid="+returnval+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
    }
}

//(dhtmlmodal Version)
function doNewOpenDhtmlModal() {
	var url = "appr_lineedit_d.jsp";
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_APPR1005", "iframe", url, "<%=msglang.getString("main.Approval") /* 전자결재 */ %>", 
		"width="+SWIDTH+"px,height="+SHEIGHT+"px,resize=0,scrolling=1,center=1", "recal"
	);
}

function doNewOpen() {
	OpenWindow("appr_lineedit_d.jsp?pop=1" , "<%=msglang.getString("main.Approval") /* 전자결재 */ %>", SWIDTH, SHEIGHT);
}

function setLine(returnval) {
    if ((returnval != null) && (returnval != "") ) {
        parent.leftfrm.location.href ="./appr_line_l.jsp?lineid="+returnval+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
        parent.rightfrm.location.href ="./appr_line_r.jsp?lineid="+returnval+"&no="+"<%= ApprDocCode.APPR_NUM_1 %>" ;
    }
}


// (window.showModalDialog Version)
function doEditOpenModal(sLineId) {
    //결재선을 선택했는지 확인하자.
// 	if (mainForm.lineid.value == "")
    if (sLineId == "") {
        alert("<%=msglang.getString("appr.not.select.apline") /* 선택한 결재선이 없습니다. */ %>") ;
        return ;
    }
    
	var url = "appr_lineedit_d.jsp?apprid="+sLineId;
    var returnval = OpenModal( url , null , SWIDTH , SHEIGHT)  ;
 //   var returnval = window.showModalDialog("appr_lineedit.jsp?apprid="+sLineId ,null ,  "dialogHeight: 486px; dialogWidth: 615px;") ;
    if ((returnval != null) && (returnval != "") ) {
        parent.rightfrm.location.reload();
        //doReload() ;
    }
}

//(dhtmlmodal Version)
function doEditOpenDhtmlModal(sLineId) {
    if (sLineId == "") {
        alert("<%=msglang.getString("appr.not.select.apline") /* 선택한 결재선이 없습니다. */ %>") ;
        return ;
    }
    
	var url = "appr_lineedit_d.jsp?apprid="+sLineId;
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_APPR1005", "iframe", url, "<%=msglang.getString("main.Approval") /* 전자결재 */ %>", 
		"width="+SWIDTH+"px,height="+SHEIGHT+"px,resize=0,scrolling=1,center=1", "recal"
	);
}

function doEditOpen(sLineId) {
    if (sLineId == "") {
        alert("<%=msglang.getString("appr.not.select.apline") /* 선택한 결재선이 없습니다. */ %>") ;
        return ;
    }
	OpenWindow("appr_lineedit_d.jsp?pop=1&apprid="+sLineId, "<%=msglang.getString("main.Approval") /* 전자결재 */ %>", SWIDTH, SHEIGHT);
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
        alert("<%=msglang.getString("appr.select.apline.delete") /* 삭제 할 결재선을 선택하십시오. */ %>");
        return ;
    }
    if (!confirm("<%=msglang.getString("c.delete") /* 삭제 하시겠습니까? */ %>")) return ;
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
        alert("<%=msglang.getString("appr.select.apline.default") /* 기본 결재선을 선택하십시오. */ %>");
        return ;
    }
    if (!confirm("<%=msglang.getString("appr.register.apline.default") /* 기본 결재선으로 등록하시겠습니까? */ %>")) return ;
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

    var typenm, dname, uname, nname, uid, apprtype, returnVal, udName ;
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
        uid = uidobj[i].value ; // UID
        udName = udNameobj[i].value;	//직책명
        apprtype = apprtypeobj[i].value ; // 결재유형

        returnVal = returnVal + "<%= ApprDocCode.APPR_GUBUN %>" + typenm+ "|" + dname+ "|" + uname+ "|" + nname + "|" + uid + "|" + apprtype + "|" + udName ;
    }

//alert(returnVal) ;
    if (returnVal == "" )  //결재자 없이 종료하는 경우
    {
        if (!confirm("<%=msglang.getString("appr.not.approver") /* 결재자가 없습니다. */ %>\n\n"
        		+ "<%=msglang.getString("c.quit") /* 종료 하시겠습니까? */ %>")) 
        	return ;
    }
    
    if (parent.opener) parent.opener.returnValue = returnVal;
    parent.returnValue = returnVal;
    parent.close();
    
//     window.returnValue = returnVal;
//     document.mainForm.method = "post" ;
//     self.close();
}
function doClose()
{
    window.returnValue = "" ;
    window.close();
}
//-->
</SCRIPT>
<style>
.td_le1{padding-left:10px;}
</style>
</head>
<body  style="margin-left:3pt;margin-top:5pt; padding-top:0; background-image:none;">
<form NAME="mainForm" METHOD="post" action="./appr_linecontrol.jsp" target = "hidfrm" onsubmit="return false;">
<div>
<table width="80%" cellspacing="0" cellpadding="0" border="0">
	<tr>
	    <td width = "5">&nbsp;</td>
	    <td>
    	    <table width="100%" cellspacing="0" cellpadding="0" border="0" >
	            <tr>
    	            <td width="95" class="td_le1" align="left"><%=msglang.getString("appr.aplinesubj") %>&nbsp;<font color="red">*</font></td>
        	        <td class="td_le2"><%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck(applineHDInfo.getApprLineNm())) %></td>
	            </tr>
    	        <tr>
					<td class="td_le1" align="left"><%=msglang.getString("appr.aplinedetail") %>&nbsp;</td>
					<td class="td_le2" align="left">
						<%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck(applineHDInfo.getApprLineDes())) %>
	                </td>
				</tr>
				<tr>
					<td class="td_le1" align="left"><%=msglang.getString("appr.aplineform") %>&nbsp;</td>
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
			<div style="height:64vh;width:100%;overflow-y:auto;border:1px;">
			<table width="100%" cellspacing="0" cellpadding="0" border="0" >
				<tr>
					<td width="30" class="td_ce1"><%=msglang.getString("t.order") %></td>
					<td width="60" class="td_ce1"><%=msglang.getString("t.type") %></td>
					<td width="100" class="td_ce1"><%=msglang.getString("t.dpName") %></td>
					<td width="70" class="td_ce1"><%=msglang.getString("t.upName") %></td>
					<td width="*" class="td_ce1"><%=msglang.getString("t.name") %></td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:-1;">
				<colgroup>
				<col width="30">
				<col width="60">
				<col width="100">
				<col width="70">
				<col width="*">
				</colgroup>
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
					<td class="td_ce2" align=center  nowrap colspan="5"><%=msglang.getString("appr.aplineselect") %></td>
				</tr>
			<%
				}
			%>
 			</table>
			</div>
		</td>
	</tr>
</table>

<table width="80%" ><tr height="1" bgcolor="#B6B5B6"><td ></td></tr></table>

<table width="80%" >
	<tr height="3"><td></td></tr>
	<tr>
		<td align="center" valign="absmiddle" ><font color="#4d4d4d">(<%=msglang.getString("appr.aplinecmt") %>)</font></td>
	</tr>
</table>

<table><tr><td class="tblspace09"></td></tr></table>

<!---수행버튼 --->
<table width="80%" cellspacing="0" cellpadding="0" border="0">
	<tr height="5" bgcolor="#E7E7E7" align="center">
		<td>
	<%
	    if(sNo.equals(ApprDocCode.APPR_NUM_1))  //결재선 수정, 신규
	    {
	%>
		<a href="javascript:doNewOpen();" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("appr.erp.new") %> </a>
		<a href="javascript:doEditOpen('<%= sLineId %>');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.modify") %> </a>
		<a href="javascript:doDelete();" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.delete") %> </a>
<!-- 			<a href="javascript:doNewOpen();"> -->
<%-- 				<img src="<%= sImagePath %>/act_record_off.gif" alt="등록" border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a>&nbsp; --%>
<%-- 			<a href="javascript:doEditOpen('<%= sLineId %>');"> --%>
<%-- 				<img src="<%= sImagePath %>/act_edit_off.gif" alt="수정" border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a>&nbsp; --%>
<!-- 			<a href="javascript:doDelete();"> -->
<%-- 				<img src="<%= sImagePath %>/act_delete_off.gif" alt="삭제" border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a> --%>
			<!-- 
			<a href="javascript:setStdLine();">
				<img src="<%= sImagePath %>/act_appstandardline_off.gif" alt="기본결재선지정" border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a>
			-->
	<%
	    } else if(sNo.equals(ApprDocCode.APPR_NUM_2)) { //결재선 선택
	%>
			<a href="javascript:doSubmit();">
				<img src="<%= sImagePath %>/btn_ok.gif" alt="확인" border=0 >
			</a>&nbsp;&nbsp;
			<a href="javascript:doClose();">
				<img src="<%= sImagePath %>/btn_cancel.gif" alt="닫기" border=0 >
			</a>
	<%
	    }
	%>
		</td>
	</tr>
</table>
</div>
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