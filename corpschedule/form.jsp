<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="nek.corpschedule.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*, nek.common.util.Convert" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@page import="nek3.domain.schedule.ScheCategory"%>
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

java.util.Date today = new java.util.Date();
java.text.SimpleDateFormat format_today = new java.text.SimpleDateFormat("yyyy-MM-dd");

String docid = request.getParameter("docid");
if ( docid == null ) docid = "";
String cmd = request.getParameter("cmd");
if ( cmd == null ) cmd = "insert";
String startdate = request.getParameter("startdate");
if ( startdate == null ) startdate = format_today.format(today);
String enddate = request.getParameter("enddate");
if ( enddate == null ) enddate = startdate;

CorpScheduleItem item = null;
CorpScheduleDoc doc = null;
ArrayList<CorpScheduleItem> listDatas = null;
ArrayList<DepartmentItem> deptList = null;
//String docid = request.getParameter("docid");
ArrayList<ScheCategory> cateList = null;
try
{
	doc = new CorpScheduleDoc(loginuser, item);
	doc.getDBConnection();
	
	listDatas = doc.getCorpScheduleDoc(docid, loginuser.locale); 
	deptList = doc.getCorpDeptItem();
	
	//공용분류 목록 
	cateList = doc.getScheCategory();
	
	//System.out.println( listDatas.size() );
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

<TITLE><fmt:message key="main.Company.Schedule"/>&nbsp;<!-- 회사일정 --></TITLE>

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
	/* validate check - jquery */
	function validCheck() {
		//tripUsers, purpose, area, startDate/endDate, startLoc/endLoc, trans, 
		//corp, residence, require, content, prepare, userid, crate
		
		var chk = $("#submitForm").validate({
			rules: {
				subject: "required",
				contents: "required",
				area: "required",
				//startDate: "required",
				endDate: "required",
				//startLoc: "required",
				endLoc: "required",
				corp: "required",
				
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

	function dateValidCheck() {
		var stDate = document.getElementById("startDate").value;
		var edDate = document.getElementById("endDate").value;
		var st_date = stringToDate(stDate);
		var ed_date = stringToDate(edDate);
		if (st_date.getTime() <= ed_date.getTime()) return true;
		return false;
	}
	
	function stringToDate(strDate) {
		var a = strDate.split("-");
		return new Date(a[0], a[1]-1, a[2], 0, 0, 0, 0);
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
				//alert();
				if( !validCheck() ) {
					ModalDialog({'t':'<b><fmt:message key="sch.Field.input.error"/> !</b>', 'c':'<fmt:message key="sch.fild.no"/>',
					'w':'250', 'h':'150', 'r':false, 'b':{'OK':function(){$(this).dialog('close');}} });
					//필드 입력 오류 !//필드 중 값이 입력되지 않았거나,\r\n잘못 입력된 값이 있습니다.
					return false;
				}
				if (!dateValidCheck()) { alert("일정의 시작일자가 종료일자보다 높을 수 없습니다."); return; }
				
				//alert('기타 검증 ...');
				//return;
				var msg = "<fmt:message key='c.save'/>";//저장 하시겠습니까?
				if ( !confirm(msg) ) return;
				icmd = "<%=cmd%>";				
				if ( icmd == "insert") {
					frm.cmd.value = "1";
				} else {
					frm.cmd.value = "2";
				}
				
				window.name = 'modal';
				frm.target='modal';
				
				//if(!docSubmit()) return;
				//frm.cmd.value = "1";
				frm.method = "post";
				frm.action = "./control.jsp";
				break;
				
			case "post":
				if(!docSubmit()) return;
				break;
			case "close":
				if(confirm("<fmt:message key='c.unsaveClose'/>")){
					//현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.
					closeDoc();
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

<script type="text/javascript">
$(document).ready(function () {

	$('select[name=gubun] > option[value="<%=item.getGubun() %>"]').attr("selected","true");
	$('input[name=stype]').filter('input[value="<%=item.getStype() %>"]').attr("checked","checked");

	//MaxChar 및 ModalDialog 활용할 것. - jquery폴더에 download 되어있음
	$('input[id=startDate], input[id=endDate]').datepicker({
		showAnim: "slide",
		showOptions: {
			origin: ["top", "left"] 
		},
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
		dateFormat: 'yy-mm-dd',
		buttonText: 'Calendar',
		prevText: '이전달',
		nextText: '다음달',
		//showOn: 'both',
		altField: "#alternate",
		altFormat: "DD, d MM, yy",
		changeMonth: true,
		changeYear: true,
		showOtherMonths: true,
		selectOtherMonths: true,
		onClose : function(selectedDate) {
		 //시작-종료일 비활성화
		 if (jQuery(this).attr('name') == 'startDate') {
				jQuery('input[name=endDate]').datepicker("option", "minDate", selectedDate );
			} else if (jQuery(this).attr('name') == 'endDate') {
				jQuery('input[name=startDate]').datepicker("option", "maxDate", selectedDate);
			}
		},
		
		beforeShow: function() {
		}
	});

	$( "#opendialog" ).click(function() {
		openDialog("Title Message")
	});

	$( "#openmodal" ).click(function() {
		openModal( "Title Message" );
	});	

	$( "#openmodalconfirm" ).click(function() {
		openConfirm( "Title Message" );
	});

	$('#tabs').tabs(  {
	        selected: 0,     // which tab to start on when page loads
	        select: function(e, ui) {
	            var t = $(e.target);
	
	            // alert("data is " +  t.data('load.tabs'));  // undef
	            // alert("data is " +  ui.data('load.tabs'));  // undef
	
	            // This gives a numeric index...
	            
	//            if( ui.index == 1 ) {
	 //           	alert( 'ok' );
	            	//loadGrid(ui.index);
	/*            	
	var tabs = document.getElementById("tabs-2");
	var tbl = document.getElementById("jsonmap1");
	tabs.style.width = "100%";
	tbl.style.tableLayout = "auto";
	tbl.style.width = "100%";
	tbl.style.tableLayout = "fixed";
	alert( tbl.style.width );
	*/
	 //           }
	            //alert( "selected is " + t.data('selected.tabs') )
	            // ... but it's the index of the PREVIOUSLY selected tab, not the
	            // one the user is now choosing.  
	            return true;
	
	            // eventual goal is: 
	            // ... document.location= extract-url-from(something); return false;
	        }
	});

	/*
	$('select').selectmenu({
		menuWidth: 100
	});
	*/
	
	var availableTags = [
		"ActionScript",
		"AppleScript",
		"Asp",
		"김정국",
		"김성진",
		"박동주",
		"Clojure",
		"COBOL",
		"ColdFusion",
		"Erlang",
		"Fortran",
		"Groovy",
		"Haskell",
		"Java",
		"JavaScript",
		"Lisp",
		"Perl",
		"PHP",
		"Python",
		"Ruby",
		"Scala",
		"Scheme"
	];
	
	function split( val ) {
		return val.split( /,\s*/ );
	}
	function extractLast( term ) {
		return split( term ).pop();
	}

	$( "#tags" )
		// don't navigate away from the field on tab when selecting an item
		.bind( "keydown", function( event ) {
			if ( event.keyCode === $.ui.keyCode.TAB &&
					$( this ).data( "autocomplete" ).menu.active ) {
				event.preventDefault();
			}
		})
		.autocomplete({
			width:300,
			minLength: 0,
			source: function( request, response ) {
				// delegate back to autocomplete, but extract the last term
				response( $.ui.autocomplete.filter(
					availableTags, extractLast( request.term ) ) );
			},
			focus: function() {
				// prevent value inserted on focus
				return false;
			},
			select: function( event, ui ) {
				var terms = split( this.value );
				// remove the current input
				terms.pop();
				// add the selected item
				terms.push( ui.item.value );
				// add placeholder to get the comma-and-space at the end
				terms.push( "" );
				this.value = terms.join( ", " );
				return false;
			}
		});	
	setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
});

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
 
</script>
<!-- 나모웨에디터 로딩 이후 함수 수행  -->
<SCRIPT language="Javascript" FOR="Wec" EVENT="OnInitCompleted()">
	//CSS 설정
	editor_init();
</SCRIPT>

<script language="JScript" FOR="twe" EVENT="OnLoadComplete">
    //twe.HtmlValue = "OnLoadComplete event dispatched.";
	twe.ShowMenuBar(false); 
	twe1.ShowMenuBar(false); 
	twe.ShowToolBar(3, false); 
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
<!-- 	<img src="../common/images/pp.gif" border="0" align="absmiddle"> -->	
<%-- 	<a href="javascript:ShowUserInfo('<c:out value="${user.userId}" />');" class="maninfo"> --%>
<%-- 	<c:set var="now" value="<%= new Date() %>" /> --%>
<%-- 	<c:out value="${user.nName }"/> / <c:out value="${user.department.dpName}"/></a> ( <fmt:formatDate value="${now}" pattern="yyyy-MM-dd HH:mm:ss"/> ) --%>
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
		<div onclick="goSubmit('save','')" class="button gray medium">
		<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.save"/>&nbsp;<!-- 저장 --> </div>
		<div onclick="goSubmit('close','')" class="button white medium">
		<img src="/common/images/bb02.gif" border="0"> <fmt:message key="t.close"/>&nbsp;<!-- 닫기 --></div>
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
<table width="100%" cellspacing=0 cellpadding=0 border="0">
	<colgroup>
		<col width="100">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1" NOWRAP><fmt:message key="t.division"/>&nbsp;<!-- 구분 --></td>
		<td class="td_le2">
			<select name="stype">
			<%
			for(ScheCategory sCategory : cateList) {
			%>
				<option value="<%=sCategory.getScid() %>" <%=(sCategory.getScid().equals(item.getStype()) ? "selected" : "") %>>
					<%
					String sTitle = sCategory.getTitle();
					if(loginuser.locale.equals("en")){
						sTitle = sCategory.getTitleEn();
					}else if(loginuser.locale.equals("ja")){
						sTitle = sCategory.getTitleJa();
					}else if(loginuser.locale.equals("zh")){
						sTitle = sCategory.getTitleZh();
					}
					out.print(sTitle);
					%>
				</option>
			<%} %>
			</select>
<!-- 			<input type="radio" name="stype" id="Agenda" value="1" checked style="cursor:pointer"> -->
<%-- 			<label for="Agenda" style="cursor:pointer"><fmt:message key="sch.Agenda"/>&nbsp;<!-- 안건 --></label> &nbsp; --%>
<!-- 			<input type="radio" name="stype" id="Business trip" value="2" style="cursor:pointer"> -->
<%-- 			<label for="Business trip" style="cursor:pointer"><fmt:message key="sch.Business.trip"/>&nbsp;<!-- 출장 --></label> &nbsp; --%>
<!-- 			<input type="radio" name="stype" id="Visit" value="3" style="cursor:pointer"> -->
<%-- 			<label for="Visit" style="cursor:pointer"><fmt:message key="sch.visit"/>&nbsp;<!-- 방문 --></label> &nbsp; --%>
		</td>
	</tr>
	<tr>
		<td class="td_le1" NOWRAP><fmt:message key="sch.central"/>&nbsp;<!-- 본부 --></td>
		<td class="td_le2">
			<select name="gubun" class="SELECT">
<%	for(int i = 0; i < deptList.size(); i++) {
		DepartmentItem deptItem = deptList.get(i);
		if (deptItem.dpName.toUpperCase().indexOf("[DEL]") > -1) continue;
		out.println("<option value='"+deptItem.dpId+"'>"+deptItem.dpName+"</option>");
	}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="td_le1" NOWRAP><fmt:message key="t.subject"/>&nbsp;<!-- 제목 --></td>
		<td class="td_le2" scolspans=2>
			<input type=text name="subject" id="subject" Style="width:90%;" maxlength="30" value="<%=item.getSubject()%>" />
		</td>
	</tr>
	<tr>
		<td class="td_le1" NOWRAP><fmt:message key="mail.contents"/>&nbsp;<!-- 내용 --></td>
		<td class="td_le2" scolspans=2>
<%-- 			<input type=text name="contents" id="contents" Style="width:90%;" maxlength="30" value="<%=item.getContents()%>"> --%>
			<textarea name="contents" id="contents" Style="width:90%;" maxlength="1000" value="<%=item.getContents()%>"><%=item.getContents()%></textarea>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><fmt:message key="t.schedule"/>&nbsp;<!-- 일정 --></td>
		<td class="td_le2" colspans=3>
		<%
		if ( cmd.equals("edit") ) {
			startdate = item.getStartdate();
			enddate = item.getEnddate();
		}
		%>
			<input type=text name="startDate" id="startDate" Style="width:75px;" maxlength="30" value="<%=startdate%>"> - 
			<input type=text name="endDate" id="endDate" Style="width:75px;" maxlength="30" value="<%=enddate%>">
		</td>
	</tr>
</table>


</form>
</body>
</fmt:bundle>
</html>