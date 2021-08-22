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
    String sUid = loginuser.uid;
    String sDpId = loginuser.dpId ;

//    String sType = ApprUtil.nullCheck(request.getParameter("cmd")) ; //조회, 수정, 삭제 선택
    String sLineId = ApprUtil.nullCheck(request.getParameter("apprid")) ; //결재선 번호
    String pop = ApprUtil.nullCheck(request.getParameter("pop")) ;
//sLineId = "2" ;

    ArrayList arrList = new ArrayList() ; 
    ArrayList formList = new ArrayList() ;
    ApprLineHDInfo applineHDInfo = new ApprLineHDInfo() ; 
	//결재양식 호출
    ApprForm apprObj = null ;
    try{
    	apprObj = new ApprForm() ;
        formList = apprObj.ApprFormList();
    }catch(Exception e){
        Debug.println (e) ;
    }finally{
    	apprObj.freeConnecDB() ;
    }
    
    if ( (sLineId != null) &&( !sLineId.equals("")) )    
    {
        ApprLine lineObj = null ;
        
        try
        {
            lineObj = new ApprLine() ; 

            applineHDInfo = lineObj.ApprLineHDApprNo(sUid, sLineId) ; //hd의 정보를 가져와라
            arrList = lineObj.ApprLineDTListSelect(sUid, sLineId) ;        
        }catch(Exception e){
            Debug.println (e) ;
        } finally {
            lineObj.freeConnecDB() ;
        }
    }

%>
<!DOCTYPE HTML>
<html>
<head>
<base target="_self">
<title>결재선</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" type="text/css" href="<%= sCssPath %>/popup.css">
<link rel="stylesheet" type="text/css" href="<%= imgCssPath %>">
<!-- script -->
<script src="./appr_table.js"></script>
<style>
/* select {height:20px; paddin-left:2px; } */
</style>
<SCRIPT LANGUAGE="JavaScript">
<!--

window.code = '_CHILDWINDOW_APPR1005';

 //도움말
SetHelpIndex("appr_lineedit") ;

function doSubmit()
{        
    if( isEmpty("linetitle"))         
    {
        alert("<%=msglang.getString("appr.input.apline.title") /* 결재선 제목을 입력하십시오. */ %>") ; 
        mainForm.linetitle.focus() ; 
        return ; 
    }

    //테이블에 결재 형태가 선택되었는지 검사
    if (numapprperson( "apprtype")) {
        alert("<%=msglang.getString("appr.select.apline.type") /* 결재 형태를 선택하십시오. */ %>") ; 
        return  ;
    }

//결재자를 선택했는지 검사해라.
    var idx = document.getElementById("sharetbl").rows.length; //this.sharetbl.rows.length ;
    if ( idx < 1 ) {
        alert("<%=msglang.getString("appr.approver.select") /* 결재자를 선택하십시오. */ %>"); 
        return ; 
    }
    
    if(!chkApprPerson()) return;
    
    document.mainForm.cmd.value = "<%= ApprDocCode.APPR_EDIT %>" ;
    //mainForm.target = "hidfrm" ; 
    document.mainForm.method = "post" ; 
    document.mainForm.submit() ; 
    //open한 곳으로 값을 넘겨라.

}

function chkApprPerson(){
	var apprUid = document.getElementsByName("appruid");
    var apprType = document.getElementsByName("apprtype");
    
    var sApprNO = 0;	//일반결재자 수
	var sApprHelpNO = 0;	//합의 결재자 수
	for (var i = 0; i < apprType.length; i++) {
		var sType = apprType[i].options[apprType[i].selectedIndex].value;
		if(sType=="H"){
			sApprHelpNO++;
		}else{
			sApprNO++;
		}
    }
   	if(sApprNO>7){
    	alert("<%=msglang.getString("appr.general.over") /* 일반 결재자는 */ %> " 
    		+ "7<%=msglang.getString("appr.cannat.over") /* 명을 넘을 수 없습니다. */ %>");
    	return false;
    }
   	
    if(sApprHelpNO>9){
    	alert("<%=msglang.getString("appr.agreed.over") /* 합의 결재자는 */ %> "
    		+ "9<%=msglang.getString("appr.cannat.over") /* 명을 넘을 수 없습니다. */ %>");
    	return false;
    }
    
    return true;
}

function tblInsert()
{
    var arrVal = document.mainForm.orgadata.value.split(":") ;
    if (arrVal.length < 2) return;
    var sNname = arrVal[0] ; // 사용자명
    var sUID = arrVal[1] ;  //UID
    var sUpNm = arrVal[2] ;  //직위명
    var sDpNm = arrVal[3] ;   //부서명
    
    if(sUID=="<%=sUid %>"){
		alert("<%=msglang.getString("appr.select.self.no") /* 자신은 선택 할 수 없습니다. */ %>");
		return;
	}
    
    var apprUid = document.getElementsByName("appruid");
    var apprType = document.getElementsByName("apprtype");
    
    var sApprNO = 0;	//일반결재자 수
	var sApprHelpNO = 0;	//합의 결재자 수
	for (var i = 0; i < apprType.length; i++) {
		var sType = apprType[i].options[apprType[i].selectedIndex].value;
		if(sType=="H"){
			sApprHelpNO++;
		}else{
			sApprNO++;
		}
    }
   	if(sApprNO>6){
    	alert("<%=msglang.getString("appr.general.over") /* 일반 결재자는 */ %> " 
       		+ "7<%=msglang.getString("appr.cannat.over") /* 명을 넘을 수 없습니다. */ %>");
    	return;
    }
    
    if(sApprHelpNO>9){
    	alert("<%=msglang.getString("appr.agreed.over") /* 합의 결재자는 */ %> "
       		+ "9<%=msglang.getString("appr.cannat.over") /* 명을 넘을 수 없습니다. */ %>");
    	return;
    }

    //중복 appruid검사        
    if(checkapprperson("appruid", sUID) ) {
        //alert("결재자가 존재합니다.") ; 
        return ;
    }
    

    var tbl = document.getElementById("sharetbl"); //this.sharetbl ;
    var idx = tbl.rows.length ;
    var newTR = tbl.insertRow(idx) ;
    newTR.id = "user_" + sUID;
    
    newTR.setAttribute("checked",false);

    //row 추가
    var newCell = newTR.insertCell(0);
    newCell.align = "center" ;
    newCell.className = "td3" ;
    newCell.innerHTML = "<Select name=\"apprtype\" style='width:65'><option value=\"<%= ApprDocCode.APPR_DOC_CODE_APPR%>\" selected>&nbsp;&nbsp;<%= ApprDocCode.APPR_DOC_CODE_A_HAN %>&nbsp;&nbsp;</option><option value=\"<%= ApprDocCode.APPR_DOC_CODE_HAN %>\">&nbsp;&nbsp;<%= ApprDocCode.APPR_DOC_CODE_H_HAN %>&nbsp;&nbsp;</option></select>" ;
    
    newCell = newTR.insertCell(1);
    newCell.align = "center" ;
    newCell.className = "td3" ;
    newCell.innerHTML = sDpNm ;
    
    newCell = newTR.insertCell(2);
    //tbl.rows(idx).insertCell(2);
    newCell.align = "center" ;
    newCell.className = "td3" ;
    newCell.innerHTML = sUpNm ;
    
    newCell = newTR.insertCell(3);
    //tbl.rows(idx).insertCell(3);
    newCell.align = "center" ;
    newCell.className = "td3" ;
    //tbl.rows(idx).cells(3).innerText = mainForm.nname.value;
    newCell.innerHTML = sNname +"<input type='hidden' name='appruid' value='"+sUID+"'><input type='hidden' name='lineseq'>";        

    
//     var newCell = newTr.insertCell(1);
//     tbl.rows(idx).cells(1).align = "center" ;
//     tbl.rows(idx).cells(1).className = "td3" ;
//     tbl.rows(idx).cells(1).innerText = sDpNm ;
//     tbl.rows(idx).insertCell(2);
//     tbl.rows(idx).cells(2).align = "center" ;
//     tbl.rows(idx).cells(2).className = "td3" ;
//     tbl.rows(idx).cells(2).innerText = sUpNm ;
//     tbl.rows(idx).insertCell(3);
//     tbl.rows(idx).cells(3).align = "center" ;
//     tbl.rows(idx).cells(3).className = "td3" ;
}

function doClose() {
// 	parent.closeDhtmlModalWindow();
	self.close();
}

//-->
</SCRIPT>
<style type="text/css">
.ui-autocomplete-loading {
	background: white url('/common/images/ui-anim_basic_16x16.gif') right
		center no-repeat;
}
.ui-autocomplete {
	max-height: 300px;
	overflow-y: auto;
	/* prevent horizontal scrollbar */
	overflow-x: auto;
}
.ui-autocomplete a {
	white-space: nowrap;
}
* html .ui-autocomplete {
	height: 300px;
}
</style>
<script type="text/javascript">
$(document).ready(function() {

	$("input[name=search]").autocomplete({
		//"/common/findrecipients2.htm?onlyuser=" + onlyuser + "&onlydept=" + onlydept + "&dpid=" + $('select[name=addressBookList]').val()
		source: function(request, response) {
			var self = this;
			var elem = $(this.element);
			$.ajax({
				url: "/common/findrecipients2.htm",
				dataType: "json",
				data: {
					term: request.term,
					onlyuser: 1,
					onlydept: 0,
					rangetype: $('#partdiv').contents().find('select[name=range]').val()
				},
				success: function(datas) {
					elem.removeClass("ui-autocomplete-loading");
					var msg = "<%=msglang.getString("c.not.result")/*에 대한 검색결과가 없습니다.*/%>";
					if (datas.length == 0) {
						alert("\"" + elem.val() + "\" "+msg);
					} else if (datas.length == 1) {
						elem.val("");

						var data = datas[0].id;						
						var nekDatas = new Array();
						nekDatas.push(data.username);
						nekDatas.push(data.userid);
						nekDatas.push(data.upname);
						nekDatas.push(data.dpname);
						nekDatas.push(data.dpid);
						nekDatas.push(data.udName);
						
						$("input[name=orgadata]").val(nekDatas.join(":"));
						tblInsert();
					} else {
						response(datas);
					}
				}
			});
		},
		autoFocus: false,
		minLength: Number.MAX_VALUE,
		delay: 10,
		select: function(event, ui) { 
			$(event.target).val("");
//			alert(JSON.stringify(ui.item));

			var data = ui.item.id;					
			var nekDatas = new Array();
			nekDatas.push(data.username);
			nekDatas.push(data.userid);
			nekDatas.push(data.upname);
			nekDatas.push(data.dpname);
			nekDatas.push(data.dpid);
			nekDatas.push(data.udName);
			
			$("input[name=orgadata]").val(nekDatas.join(":"));
			tblInsert();
			
// 			var objAddress = new Object();
// 			objAddress.type = ORGUNIT_TYPE_USER;
// 			objAddress.name = data.username;
// 			objAddress.id = data.userid;
// 			objAddress.position = data.upname;
// 			objAddress.department = data.dpname;
// 			objAddress.duty = data.udName;
			
// 			var objapprtype = getApprType("apprtype") ;
// 			objAddress.apprtype = objapprtype.apprtype  ; //결재형태
// 			objAddress.apprname = objapprtype.apprname ; //결재형태명
// 			AddRecipient(objAddress, false);
			
			return false;
		},
		open: function(event, ui) {
			$( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
		},
		close: function(event, ui) {
			$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
		}
	});

	$("input[name=search]").bind("keydown.autocomplete",function( event ){
		if (event.keyCode == $.ui.keyCode.ENTER) {
			$(this).autocomplete('option', 'minLength', 1);
			$(this).autocomplete('search', $(this).val());
			$(this).autocomplete('option', 'minLength', Number.MAX_VALUE);
			event.preventDefault();
		}
	});
	
	$("#searchBtn").click(function() {
		$("input[name=search]").autocomplete('option', 'minLength', 1);
	    $("input[name=search]").autocomplete('search', $('input[name=search]').val());
		$("input[name=search]").autocomplete('option', 'minLength', Number.MAX_VALUE);
	});
	
	$('#search').focus();
});
</script>

</head>
<body style="padding:0; margin:0;">
<form NAME="mainForm" id="mainForm" METHOD="post" action="./appr_linecontrol.jsp" onsubmit="return false;">
<input type="hidden" name="cmd" value= ""  >
<input type="hidden" name="lineid" value= "<%= sLineId %>" >
<input type="hidden" name="uid" >
<input type="hidden" name="dpname" value= ""   >
<input type="hidden" name="upname" value= ""  >
<input type="hidden" name="nname" value= ""  >
<input type="hidden" name="pop" value= "<%=pop %>"  >
<input type="hidden" id="orgadata" name="orgadata" onFocus="tblInsert();">

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="60%" style="padding-left:5px; padding-top:5px; ">
			<span class="ltitle">
				<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />
				<b><%=msglang.getString("appr.aplinemng") %></b>
			</span>
		</td>
		<td width="40%" align="right" style="padding:0 20px 0 0;"></td>
	</tr>
</table>

<table><tr><td class="tblspace09"></td></tr></table>

<table width="600" cellspacing="0" cellpadding="0" border="0">	
<tr>
    <td width="200" valign="top">
        <iframe name="deptname" src="../common/department_selector.jsp?openmode=2&isadmin=0&expand=1&expandid=<%= sDpId %>&onlydept=0&onlyuser=1&winname=parent&conname=mainForm"  width="100%" height="400px" id="partdiv" scrolling="no" topmargin='0' leftmargin='0' frameborder='0'></iframe>
    </td>
    <td width="5">&nbsp;</td>
    <td width="390" valign="top">
    	<div style="padding: 0px 0px 5px 0px;">
			<input type="text" id="search" name="search" style="width:270px; margin:1px 0px 1px 5px; padding:4px; 5px; border:1px solid #aaaaaa;" class="ui-corner-all" />
			<span id="searchBtn" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.search") /* 검색 */ %> </span>
    	</div>
    	
        <table width="390"  cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;">
        	<colgroup>
	        	<col width="95">
	        	<col width="*">
        	</colgroup>
            <tr>
                <td class="td_le1"><%=msglang.getString("appr.aplinesubj") %><!-- 결재라인 제목-->&nbsp;<font color="red">*</font></td>
                <td class="td_le2"><input type="text" name="linetitle" value="<%= ApprUtil.nullCheck(applineHDInfo.getApprLineNm()) %>" size="39" maxlength="255"></td>
            </tr>
            <tr>
            	<td class="td_le1" ><%=msglang.getString("appr.aplinedetail") %><!-- 결재라인 설명-->&nbsp;</td>
                <td class="td_le2"><textarea name="linetitlenote" cols="38" rows="2" style="width:95%;"><%= ApprUtil.nullCheck(applineHDInfo.getApprLineDes()) %></textarea></td>
            </tr>
            <tr style="display:none;">
            	<td class="td_le1" align="left"><%=msglang.getString("appr.aplineform") %><!-- 결재양식명-->&nbsp;</td>
            	<td class="td_le1" align="left" valign="absmiddle">
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
            	<%
            	}else{
            	%>
            		<select name="formid" onChange="" style="width:200; padding:0px;">
            			<option value="0">------------ <%=msglang.getString("sch.select.please") %><!-- 선택하세요--> ----------</option>
            		<%
					int formSize = formList.size() ;
				    if(formSize > 0 )
				    {
				        String sFormId = "" ;
				        ApprFormInfo apprformInfo = null ;
					    for(int i = 0; i < formSize; i++){			// for문을 돌면서 해당 데이터만 화면에 뿌린다.
					         apprformInfo = (ApprFormInfo)formList.get(i);
				             sFormId = ApprUtil.nullCheck(apprformInfo.getFormID()) ;
					%>
					<option value="<%=sFormId%>" ><%=ApprUtil.nullCheck(apprformInfo.getSubject())%></option>
					<%
					    }
					}
					%>
            		</select>
            	<%} %>
            	</td>
            </tr>
            <tr height="7"><td colspan="2"></td></tr>
        </table>
        <table width="355" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;">
            <tr>
                <td width="70" class="td1"><%=msglang.getString("t.type") %><!-- 결재형태--></td>
                <td width="100" class="td1"><%=msglang.getString("t.dpName") %><!-- 부서--></td>
                <td width="70" class="td1"><%=msglang.getString("t.upName") %><!-- 직위--></td>
                <td width="115" class="td1"><%=msglang.getString("t.name") %><!-- 성명--></td>
            </tr>
        </table>
        <div style="height:180px;width:365;overflow-y:scroll;border:0px;">
        <table width="350" id="sharetbl" onclick="selectRow(this);" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;border-collapse:collapse;">  
        <colgroup>    
            <col width="70">
            <col width="100">
            <col width="70">
            <col width="115">    
        </colgroup>
        <%
            int iSize = arrList.size() ;
            if(iSize > 0 )
            {
                ApprLineDTInfo arrlinedtInfo = null ;
                String sShape = "" ;
                String sTemp = "" ;

                for(int i = 0; i < iSize; i++){         // for문을 돌면서 해당 데이터만 화면에 뿌린다.
                     arrlinedtInfo = (ApprLineDTInfo)arrList.get(i);

                     //결재형태 설정
                     sShape = ApprUtil.nullCheck(arrlinedtInfo.getApprType()) ;
                     sTemp  = sShape ;

                     sTemp = ApprUtil.getApprTypeHan(sTemp ) ;
        %>
            <tr id = "user_<%= arrlinedtInfo.getApprPersonUID() %>">
                <td class="td3" nowrap>
                    <select name="apprtype" style='width:62px;' >                
                        <option value="<%= ApprDocCode.APPR_DOC_CODE_APPR %>" <% if(sShape.equals(ApprDocCode.APPR_DOC_CODE_APPR)) out.println("selected"); %> >&nbsp;&nbsp;<%= ApprDocCode.APPR_DOC_CODE_A_HAN %>&nbsp;&nbsp;</option>
                        <option value="<%= ApprDocCode.APPR_DOC_CODE_HAN %>"<% if(sShape.equals(ApprDocCode.APPR_DOC_CODE_HAN)) out.println("selected"); %> >&nbsp;&nbsp;<%= ApprDocCode.APPR_DOC_CODE_H_HAN %>&nbsp;&nbsp;</option>
                    </select>
                </td>
                <td class="td3" nowrap><%= ApprUtil.nullCheck(arrlinedtInfo.getDname()) %></td>
                <td class="td3" nowrap><%= ApprUtil.nullCheck(arrlinedtInfo.getUname()) %></td>
                <td class="td3" nowrap><%= ApprUtil.nullCheck(arrlinedtInfo.getNname()) %>
                    <input type="hidden" name="appruid" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getApprPersonUID()) %>" >                    
                    <input type="hidden" name="lineseq" value= "<%= ApprUtil.nullCheck(arrlinedtInfo.getApprSeq()) %>" >
                </td>
            </tr>            
        <%
                }
            } 
        %>
        </table>
        </div>
        <table width="355" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;">
            <tr height="1" bgcolor="#B6B5B6"><td colspan="2"></td></tr>
            <tr height="5" align="center" >
                <td class="td02" align="center" width="200">
                    <a href="javascript:LineItemUp();"><img src="<%= sImagePath %>/i_address_top.gif" border=0 ></a>&nbsp;&nbsp;
                    <a href="javascript:LineItemDown();"><img src="<%= sImagePath %>/i_address_down.gif" border=0 ></a>
                </td>
                <td  class="td02" align="left" width="155">
                	<a onclick="javascript:tblDelete();" class="button white medium">
					<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.delete") %> </a>
<!--                     <a href="javascript:tblDelete();"> -->
<%--                     <img src="<%= sImagePath %>/act_approvadelete_off.gif" alt="결재자 삭제" border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)"></a>             --%>
                <td>
            </tr>     
        </table>
    </td>
</tr>
</table>

<table><tr><td class="tblspace03"></td></tr></table>

<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;">
	<tr height="30" bgcolor="#E7E7E7" align="center">
		<td>
			<a onclick="javascript:doSubmit();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.save") %> </a>
			<a onclick="javascript:doClose();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.close") %> </a>
<%--             <a href="#"><img src="<%= sImagePath %>/act_save_off.gif" onclick="javascript:doSubmit();" onmouseover="btn_on(this)" onmouseout="btn_off(this)" border="0" align="absmiddle"></a>&nbsp; --%>
<%--             <a href="#"><img src="<%= sImagePath %>/act_close_off.gif" onclick="javascript:doClose();" onmouseover="btn_on(this)" onmouseout="btn_off(this)" border="0" align="absmiddle"></a> --%>
        </td>
	</tr>
</table>
<!-- 보기 수행버튼 끝 -->

<iframe name="hidfrm" id="hidfrm" frameborder="0" width="0" height="0" src="./appr_linecontrol.jsp" style="display:none;"></iframe>

</form>
</body>
</html>