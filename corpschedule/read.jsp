<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="nek.corpschedule.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*, nek.common.util.Convert" %>
<%@ page import="java.text.SimpleDateFormat" %>
<% 	request.setCharacterEncoding("utf-8"); %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/common/usersession.jsp"%>

<%
java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd");

String cssPath = "/common/css";
String imgCssPath = "/common/css/blue";
String imagePath = "/common/images/blue";
String scriptPath = "/common/scripts";

boolean isAdmin = loginuser.securityId >= 9;
boolean isManager = false;

CorpScheduleDao dao = null;
dao = new CorpScheduleDao();
try {
	dao.getDBConnection();
	isManager = dao.isCorpScheduleManager(loginuser.uid);
} catch(Exception e) {
	System.out.println("corpschedule/manager.jsp : " + e.getMessage());
} finally { if (dao != null) dao.freeDBConnection(); }

CorpScheduleItem item = null;
CorpScheduleDoc doc = null;
ArrayList listDatas = null;
String docid = request.getParameter("docid");

try
{
	doc = new CorpScheduleDoc(loginuser, item);
	doc.getDBConnection();
	
	listDatas = doc.getCorpScheduleDoc(docid, loginuser.locale); 
//	System.out.println( listDatas.size() );
	item = (CorpScheduleItem)listDatas.get(0);
	
}
finally
{
	if (doc != null) doc.freeDBConnection();
}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<HEAD>

<TITLE>회사일정</TITLE>

<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />

<script src="/common/jquery/js/jquery-1.6.4.min.js" type="text/javascript"></script>
<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js" type="text/javascript"></script>
<script src="/common/jquery/plugins/modaldialogs.js" type="text/javascript"></script>

<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/css/validate.css" />
<script src="/common/jquery/plugins/jquery.validate.js" type="text/javascript"></script>
<script src="/common/jquery/plugins/chili-1.7.pack.js" type="text/javascript"></script>

<link rel="stylesheet" href="/common/css/style.css">
<script src="/common/scripts/common.js" ></script>

<script>
	$(document).ready(function(){
		setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
	});
	/* validate check - jquery */
	function validCheck() {
		var chk = $("#submitForm").validate({
			rules: {
				subject: "required",
				crateDept: {
					required: true,
					number: true,
					minlength: 10
				},
				email: {
					required: true,
					email: true,
					minlength: 5
				}
			},
			messages: {
				subject2: {
					required: "<fmt:message key='sch.getvalue'/>",
					minlength: jQuery.format("<fmt:message key='sch.insert.min.0'/>")
					//제목 2 값을 입력해 주십시오
					//최소{0}자 이상 입력해 주십시오.
				},
				email: {
					required: "<fmt:message key='sch.getEmail'/>",
					minlength: "<fmt:message key='sch.badEmail'/>"
					//e-mail 주소를 입력해 주십시오.
					//e-mail 주소 형식이 맞지 않습니다. 정확히 입력하십시오.
				}
			},			
			focusInvalid: true
		});
		return $("#submitForm").validate().form();
	}

	function docSubmit(){
		if( !validCheck() ) {
			ModalDialog({'t':'<b><fmt:message key="sch.Field.input.error"/> !</b>', 'c':'<fmt:message key="sch.fild.no"/>',
			'w':'250', 'h':'150', 'r':false, 'b':{'OK':function(){$(this).dialog('close');}} });
			//필드 입력 오류 !//필드 중 값이 입력되지 않았거나,\r\n잘못 입력된 값이 있습니다.
			return false;
		}

		//alert('기타 검증 ...');
		//return;
		
		var form = document.submitForm;
				
		//if( FieldNullCheck(form.subject, "제목", "TEXT") == false ) return false;
        if (isEmpty("subject")) 
        {
        	 alert("<fmt:message key='sch.enter.title'/>");
             //제목을 입력해 주세요
            form.subject.focus();
            return ; 
        }

		form.content.value = geteditordata() ;

		if (!confirm("<fmt:message key='c.save'/>")) return false;//저장 하시겠습니까?
		form.cmd.value = "1";
		form.method = "POST";
		form.action ="./control.jsp";
		return;

		//게시시간끝
		
		if (null != document.all.Uploader)
		{
			var uploader = document.all.Uploader;

			/*
			//새로 첨부된 파일이 있으면 업로더를 통해서 Submit
			if (uploader.NewFileCount > 0)
			{
				uploader.Submit(form);

				var location = uploader.Location;
				if (location == "") {
					document.write(uploader.Response);
				} else {
					document.location = location;
				}
				return false;
			}
			*/
			if (uploader.Submit(form)) {
				var loc = uploader.Location;
				if (loc == "") {
					//document.write(uploader.Response);
					//새창 열었을때 response 값이 필요없다. 바로 window 닫아준다.
					try{
            	    parent.opener.location.reload();
            	    }catch(ex){
					window.close();
					}
					window.close();
				} else {
					document.location.href = loc;
				}
			}
			return false;

		}
		return true;
	}

	function goSubmit(cmd,docId)
	{
		var frm = document.submitForm;
		switch(cmd)
		{
			case "list":
				frm.method = "post";
				frm.action = "./list.jsp";
				break;
				
			case "save" :
				
				if( !validCheck() ) {
					ModalDialog({'t':'<b><fmt:message key="sch.Field.input.error"/> !</b>', 'c':'<fmt:message key="sch.fild.no"/>',
					'w':'250', 'h':'150', 'r':false, 'b':{'OK':function(){$(this).dialog('close');}} });
					//필드 입력 오류 !//필드 중 값이 입력되지 않았거나,\r\n잘못 입력된 값이 있습니다.
					return false;
				}

				//alert('기타 검증 ...');
				//return;
				
				//if(!docSubmit()) return;
				frm.cmd.value = "1";
				frm.method = "post";
				frm.action = "./control.jsp";
				break;
				
			case "post":
				if(!docSubmit()) return;
				break;
			case "close":c.unsaveClose
				if(confirm("<fmt:message key='c.unsaveClose'/>")){
				//현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.
					window.close();
				}
				return;
				break;
		}
		frm.submit();
	}

	function setNoticeChk(){
		var chk = document.submitForm.noticeflag;
		var timeObj = document.getElementById("timediv");
		if(chk.checked){
			timeObj.style.display = "";
		}else{
			timeObj.style.display = "none";
		}
	}
	function openDeptSelector(sVal)
	{
		var returnValue = window.showModalDialog("../../common/department_selector.jsp?openmode=1&onlydept=1","","dialogWidth:280px;dialogHeight:450px;center:yes;help:0;status:0;scroll:0");
		if (returnValue != null)
		{
			var frm = document.submitForm;
			var arrayVal = returnValue.split(":");
			
			var createDept = document.getElementsByName("createDept")[0];
			var createDeptId = document.getElementsByName("createDeptId")[0];
			
			createDept.value = arrayVal[0];
			createDeptId.value= arrayVal[1];
		}
	}
</script>

</HEAD>

<script>
function openDialog( args ) {
	/*
	var editor = document.getElementById("Wec");
	var up = document.getElementById("Uploader");
	//var dn = document.getElementById("Downloader");
	editor.style.display = "none";
	up.style.display = "none";
	*/
	
	$( "#dialog" ).dialog({
		dialogClass: 'alert',
		title: args,
		resizable: false,
		show: "blind",
		hide: "blind",
		open: function() {
			//$('Wec').style.display = "none"
		},
		beforeClose: function() {
		    //$('Wec').style.display = "";
		}
	});
}

function openModal( args ) {
	$( "#dialog:ui-dialog" ).dialog( "destroy" );
	
	$( "#dialog-message" ).dialog({
		dialogClass: 'alert',
		title: args,
		closeOnEscape: true,
		resizable: false,
		modal: true,
		buttons: {
			확인: function() {
				alert( 'true' );
				$( this ).dialog( "close" );
			}
		}
	});
}

function openConfirm( args ) {
	$( "#dialog:ui-dialog" ).dialog( "destroy" );

	$( "#dialog-confirm" ).dialog({
		title: args,
		resizable: false,
		height:250,
		modal: true,
		buttons: {
			취소: function() {
				alert( 'false' );
				$( this ).dialog( "close" );
			},
			"확인": function() {
				alert( 'true' );
				$( this ).dialog( "close" );
			}
		}
	});
}

function viewStart() {
	document.getElementById("lblStart").style.display = "block";
}
        
//종료일 텍스트박스 클릭시 종료일 아이프레임을 보이게 합니다. 
function viewEnd() {
	//document.getElementById("lblEnd").style.display = "block";
}
        
//시작일,종료일 텍스트 박스 이외 다른 행동시 아이프레임을 안보이게 숨깁니다. 
function OffLayer() {
	selectobj = event.srcElement.id;
	if (selectobj != "datepicker" ) {
		document.getElementById("lblStart").style.display = "none"
		//document.getElementById("lblEnd").style.display = "none"
	}
}

function CloseWin(){
	window.parent.$("#hidFld").val('1');
	window.parent.$("#modalDiv").dialog('close');
	return false;
}
 
function closeDialog() {
	parent.$("#modalDiv").dialog("close");
}

function edit() {
	
	var url = "./form.jsp?cmd=edit&docid=<%=docid%>";
	
	window.name = 'modal';
	document.submitForm.target='modal';
	
	document.submitForm.action = url;
	document.submitForm.docid.value = "<%=docid%>";
	document.submitForm.cmd.value = "edit";
	document.submitForm.submit();
	
	//self.location = url;
}
function deldoc() {
	var msg = "<fmt:message key="t.company"/> <fmt:message key='sch.delete.schedule'/>     ";
	if ( !confirm(msg) ) return;
	
	window.name = 'modal';
	document.submitForm.target='modal';
	
	var frm = document.submitForm;
	frm.cmd.value = "3";
	frm.method = "post";
	frm.action = "./control.jsp";
	frm.submit();
	//parent.$("#modalDiv").dialog("close");
}
</script>

<body>

<form id="submitForm" name="submitForm" autocomplete="off" method="get" action="" enctype="multipart/form-data" >
	<input type="hidden" name="cmd" value="">
	<input type="hidden" name="pg" value="">
	<input type="hidden" name="bbsid" value="">
	<input type="hidden" name="docid" value="<%=item.getDocId()%>">
	<!--input type="hidden" name="categoryid" value=""-->
	<input type="hidden" name="searchtype" value="">
	<input type="hidden" name="searchtext" value="">
	<input type="hidden" name="opentype" value="">
	<input type="hidden" name="command" value="newpost">
	<input type="hidden" name="endhmtc" value="">
	<input type="hidden" name="deptid" value="">
	<input type="hidden" name="createDeptId" value="">
	<input type="hidden" name="storageDeptId" value="">

<!--  Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/title_doc.gif); height:33px; border: 1px solid #CCC;;">
<tr height="26">
<td width="200" align=left style="padding-left:10px; ">
	<img src="/common/images/icons/icon_inquiry.jpg" border="0" align="absmiddle">
	<span class="ltitle">Company Schedule</span>
</td>
<td width="*" align="right" style="padding-right:10px;">
	<img src="../common/images/pp.gif" border="0" align="absmiddle">	
<a href="javascript:ShowUserInfo('<%=item.getUserId() %>');" class="maninfo">
	<%=item.getNname() %></a> ( <%=formatter.format(item.getCreateDate().getTime()) %> )
</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<!--  수행버튼  -->	
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="35">
<td width="10"><img src="../common/images/bar_left.gif" border="0"></td>
<td width="*" background="../common/images/bar_bg.gif" style="padding-left:5px;" align=left>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<!-- 
	<td width="300">
	<img src="../common/images/po01.gif" border="0" align="absmiddle" style="margin-bottom:3px;">수정이력 &nbsp;&nbsp;
	<img src="../common/images/po02.gif" border="0" align="absmiddle" style="margin-bottom:3px;"> 조회이력 &nbsp;&nbsp;
	<img src="../common/images/po03.gif" border="0" align="absmiddle" style="margin-bottom:3px;"> 파일다운이력
	</td>
	 -->
	<td width="*" align="right">
		<!-- <button onclick="javascript:goSubmit('save','');" class="button gray medium">
		<img src="../common/images/bb02.gif" border="0"> 저장 </button>
		 -->
		<%	if (item.getUserId().equals(loginuser.uid) || isAdmin || isManager) { %>
		<a onclick="javascript:edit(); " class="button white medium">
		<img src="/common/images/bb02.gif" border="0"> <fmt:message key="t.modify"/>&nbsp;<!-- 수정 --></a>
		
		<a onclick="deldoc()" class="button white medium">
		<img src="/common/images/bb02.gif" border="0"> <fmt:message key="t.delete"/>&nbsp;<!-- 삭제 --></a>
		<%	} %>
		<a onclick="javascript:closeDoc();" class="button white medium">
		<img src="/common/images/bb02.gif" border="0"> <fmt:message key="t.close"/>&nbsp;<!-- 닫기 --></a>

	</td>
	</tr>
	</table>

	</td>
	<td width="10"><img src="../common/images/bar_right.gif" border="0"></td>
	</tr>
	</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="4">
<td></td>
</tr>
</table>

<!-- 전체 문서 넓이 : 100% -->
<div class="space"></div>
<div class="hr_line">&nbsp;</div>

<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<colgroup>
		<col width="100">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><fmt:message key="t.division"/><%-- 구분 --%></td>
		<td class="td_le2"><%=item.getsTitle() %></td>
	</tr>
	<tr>
		<td class="td_le1"><fmt:message key="sch.central"/><%-- 본부 --%></td>
		<td class="td_le2"><%=item.getDpname() %></td>
	</tr>
	<tr>
		<td class="td_le1"><fmt:message key="t.subject"/><%-- 제목 --%></td>
		<td class="td_le2"><%=item.getSubject() %></td>
	</tr>
	<tr>
		<td class="td_le1"><fmt:message key="mail.contents"/><%-- 내용 --%></td>
		<td class="td_le2"><%=item.getContents() %></td>
	</tr>
	<tr>
		<td class="td_le1"><fmt:message key="t.schedule"/><%-- 일정 --%></td>
		<td class="td_le2"><%=item.getStartdate() %> ~ <%=item.getEnddate() %></td>
	</tr>
</table>

</form>
</body>
</fmt:bundle>
</html>