<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
	private final static long DAY_TIME = 86400000;

	private String setSelectedOption(int i1, int i2)
	{
		String selectStr = "";
		if (i1 == i2) selectStr = "selected";
		return selectStr;
	}

	private String setSelectedOption(String str1, String str2)
	{
		String selectStr = "";
		if (str1.equals(str2)) selectStr = "selected";
		return selectStr;
	}

	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String[] viewType = {"0"};

%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>
<!-- 
<style>
.td_le2 { color:#000000; border:1px solid #90B9CB; padding:2 2 2 4; background-color:#ffffff; line-height:17pt; text-align:left;}
.td_ce1 { color:#30546A; border:1px solid #90B9CB; padding:2 2 2 4; background-color:#EDF2F5; line-height:17pt; text-align:center;}
.td_ce2 { color:#000000; border:1px solid #90B9CB; padding:2 2 2 4; background-color:#ffffff; line-height:17pt; text-align:center;}
</style>
 -->
 
<script language="javascript">
	//SetHelpIndex("bbs_managertransfer");
</script>
<script type="text/javascript">
	function findBbses(auto){
		var bbsId = $("#srcBbsMasterId").val();
		var searchKey = $("#searchKey").val();
		var searchValue = encodeURI($("#searchValue").val(),"UTF-8");
		
		if ($.trim(bbsId) == "" && !auto) alert("<spring:message code='i.selected.original.board' text='원본게시판을 선택해 주세요.'/>");
		if ($.trim(bbsId) == ""){
			$("#srcBbsMasterId").focus();
			return false;
		}
		/*
		if ($.trim(searchKey) != "" && $.trim(searchValue) == "") {
			alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			$("#searchValue").focus();
			return false;
		} else {
			$("#searchValue").val("");
		}
		*/
		var reqUrl = "<c:url value="/bbs/list_data.htm?bbsId=" />" + bbsId + "&searchKey=" + searchKey + "&searchValue=" + searchValue;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1,datatype:'json'}).trigger("reloadGrid");
		$("#bbsId").val(bbsId);
		return true;
	}
	
	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin , docId){
		var frm = document.getElementById("search");
		
		switch(cmd){
			case "view":
				frm.method = "GET";
				frm.action = "read.htm";
				frm.docId.value = docId;
				break;
			case "transfer":
				frm.method = "POST";
				frm.action = "transfer_mgr_save.htm";
				if(!transferValidation()) return;
				frm.docIds.value = $("#dataGrid").jqGrid('getGridParam','selarrrow');
				break;
			default:
				return;
				break;
		}

		if(isNewWin == "true"){
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
		} else {	//self
			frm.target = "_self";
			if(cmd == "view"){
				frm.useNewWin.value = false;
				frm.useLayerPopup.value = true;
				var formData = $("#search").serialize();
				var url = frm.action + "?" + formData;
				OpenWindow(url, '<c:out value="${bbsMaster.title}" />', "790", "610");
//				var a = parent.ModalDialog({'t':'<c:out value="${bbsMaster.title}" />', 'w':800, 'h':600, 'm':'iframe', 'u':url});
// 				parent.dhtmlwindow.open(
// 					url, "iframe", url, '<c:out value="${bbsMaster.title}" />', 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 				);
				return;
			}
		}
		frm.submit();
	}

	var winx = 0;
	var winy = 0;
	function ShowAttach(bbsId, docId ) {
		winx = window.event.x-265;
		winy = window.event.y-40;
		var url = "<c:url value="/bbs/download_attach_info.htm?bbsId=" />" + bbsId + "&docId=" + docId;
		ajaxRequest("GET", "", url, showAttachCompleted);
	}

	function showAttachCompleted(data, textStatus, jqXHR) {
		wid = 250 ;
		hei = 105;
		//oPopup is declared in common.js
		if(window.createPopup){
			oPopup = window.createPopup();
			var oPopupBody = oPopup.document.body;
			oPopupBody.innerHTML = data ;
			oPopup.show(winx, winy, wid, hei , document.body);
		} else {
			var features = "height=" + hei + ",width=" + wid + ",left=" + winx + ",top=" + winy + 
				",titlebar=no,menubar=no,scrollbars=no,status=no,location=no"
			oPopup = window.open("about:blank", "oPopup", features);
			oPopup.document.body.innerHTML = data;
		}
	}

	function attach_down(bbsId, docId, fileNo) {
		location.href =  "<c:url value="/bbs/download.htm?" />" + "bbsId=" + bbsId + "&docId=" + docId + "&fileNo=" + fileNo;   
	}
</script>

<script type="text/javascript">
$(document).ready(function(){
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/bbs/list_data.htm" />?bbsId=<c:out value="${search.bbsId}" />",
		datatype: "local",
		width: '100%',
		height:'100%',
		
	   	colNames:[
		          'No',
		          '<spring:message code="t.subject" />',					//제목
		          '<spring:message code="t.posting.period" />',		//게시기간
		          '<spring:message code="t.createDate" />',			//작성일
		          '<spring:message code="t.writer" />',					//작성자
		          '<spring:message code="t.attached" />',				//첨부파일
		          '<spring:message code="t.readCnt" />'					//조회
		],
	   	colModel:[
	  			{name:'docSeq',index:'docSeq', width:30, align:"right", hidden:true},
		   		{name:'subject',index:'subject', width:450},
		   		{name:'period',index:'period', width:150, align:"center", sortable:false},
		   		{name:'createDate',index:'createDate', width:120, align:"center"},
		   		{name:'writer_.nName',index:'writer_.nName', width:60, align:"center"},
		   		{name:'fileCnt',index:'fileCnt', width:30, align:"center"},
		   		{name:'readCnt',index:'readCnt', width:30, align:"right"},
		],
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'createDate',
	    sortorder: 'desc',
	    multiselect: true,    
	    scroll:false,
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data){
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            $("#dataGrid").trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	    }
	});
	
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-135);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-135);
	}).trigger('resize');		
});

</script>

<script language="javascript">

	//인수인계입력 항목 Validation
	function transferValidation() {
		var frm = document.getElementById("search");
		var srcBbsMasterId = $("#srcBbsMasterId").val();
		var tgtBbsMasterId = $("#tgtBbsMasterId").val();
		var transferAll = document.getElementsByName("transferAll")[0].checked;
		if ($.trim(srcBbsMasterId) == ""){
			alert("<spring:message code='i.selected.move.board' text='원본게시판을 선택해 주세요.'/>");
			return false;
		}
		if ($.trim(tgtBbsMasterId) == ""){
			alert("<spring:message code='i.selected.original.board' text='이동할 게시판을 선택해 주세요'/>");
			return false;
		}
		if($.trim(srcBbsMasterId) == $.trim(tgtBbsMasterId)){
			alert("<spring:message code='i.original.board.selected.board' text='원본게시판과 이동할 게시판이 같습니다.'/>");
			return false;
		}
		if(!transferAll) {
			if(!IsCheckedItemExist()){
				alert("<spring:message code='mail.c.notDoc.selected' text='선택된 문서가 없습니다'/>");
				return false;
			} else {
				return confirm("<spring:message code='c.selected.document.move' text='선택된 문서를 이동 하시겠습니까?'/>");
			}
		} else {
			return confirm("<spring:message code='c.original.board.all.move' text='원본게시판의 모든 문서를 이동할 게시판으로 이동 하시겠습니까?'/>");
		}
	}

	function OnToggleSelect(checked){
		var s = $("#dataGrid").jqGrid('getGridParam','selarrrow');
	}

	function IsCheckedItemExist(){
		var s = $("#dataGrid").jqGrid('getGridParam','selarrrow');
		return s != "";
	}
	
	function resetBbsId(){
		$("#bbsId").val("");
		findBbses(true);
	}

</script>
<style>
.ui-widget-content{margin-top:20px;}
</style>
</head>
<!-- 
<style>
body {margin:5px; margin-left:10px; margin-top:2px; overflow-y:hidden; }
a, td, input, select {font-size:10pt; font-family:돋움,Tahoma; }
input {cursor:hand; }

a:link { color:black; text-decoration:none;  }
a:hover {text-decoration:underline; color:#316ac5}
a:visited { color:#616161; text-decoration:none;  }
</style>
 -->
<body>
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="docIds" />
	<form:hidden path="docId" />
	<form:hidden path="bbsId" />
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />
	
<!-- List Title -->
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%" style="height:30px;"> -->
<!-- <tr> -->
<!-- <td width="60%"><img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
<!-- 	<span class="ltitle"> 게시판 통합 -->
<!-- 	<!-- -->
<!-- 		<span><b></b>&nbsp;-&nbsp; -->
<%-- 		<span class="doc_num" onclick="self.location.reload();" title="<spring:message code='t.reload' text='새로고침' />"></span> --%>
<%-- 		<spring:message code='lp.totalCount' arguments='${fn:length(bbsMasters)}' text='{0}개의 문서가 있습니다' /> --%>
<!-- 	 --> 
<!-- 	</span> -->
<!-- </td> -->
<!-- <td width="40%" align="right">  -->
<!-- ※ 이동할 게시판을 선택한 후 이동을 누르시면 이동됩니다. -->
<!-- </td> -->
<!-- </tr> -->
<!-- </table> -->

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code='t.bbs.combine' text='게시판통합'/> </span>
	</td>
	<td width="40%" align="right">
※ <spring:message code='i.selected.move.board.move' text='이동할 게시판을 선택한 후 이동을 클릭하면 이동이 됩니다.'/>
	</td>
	</tr>
</table>
<!-- List Title -->

<!-- List Button -->
<!-- 
<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
			<button onclick="javascript:goSubmit('new','true', '');" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> 게시판 등록 </button>
		</td>
		<td width="400" class="DocuNo" align="right" style="">
			&nbsp;	
		</td>
	</tr>
</table>
-->
<!-- List Button -->

<!-- table 간 공백 -->
<div class=space>&nbsp;</div>

<table width="100%" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;">
	<colgroup>
		<col width="30%">
		<col width="5%">
		<col width="20%">
		<col width="15%">
		<col width="*">
	</colgroup>
<!-- 	<tr> -->
<!-- 		<td class="td_ce1">원본 게시판</td> -->
<!-- 		<td class="td_ce1">&nbsp;</td> -->
<!-- 		<td class="td_ce1">이동 게시판</td> -->
<!-- 		<td class="td_ce1">&nbsp;</td> -->
<!-- 		<td class="td_ce1">&nbsp;</td> -->
<!-- 	</tr> -->
	<tr>
	    <td nowrap  class="td_ce2">
			<%
			String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
			%>
	    	<form:select path="srcBbsMasterId" onchange="resetBbsId();">
	    		<option value="">--<spring:message code="i.manage.board.selected" text="관리할 게시판을 선택 하십시오" />-- </option>
	    		<c:forEach var="bbsMaster" items="${bbsMasters}">
	    		<option value="${bbsMaster.bbsId }">
	    			<c:if test="${bbsMaster.topCode != null}" ><c:out value="${bbsMaster.topCode.codeName}" />&gt;</c:if>
	    			<c:out value="${bbsMaster.title }" />
	    		</option>
	    		</c:forEach>
	    	</form:select>
			<form:select path="searchKey">
				<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option>
				<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option>
				<option value="content" <%= setSelectedOption("content",searchKey) %>><spring:message code="t.content" text="내용" /></option>
			</form:select>
			<form:input style="width:100px;" path="searchValue" />

			<a onclick="javascript:findBbses();" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.search" text="검색" /> </a>
	    	
	    </td>
	    <td class="td_ce2" align=center><img src="/common/images/bu_finish.gif" border="0"></td>
		<td nowrap class="td_ce2">
	    	<form:select path="tgtBbsMasterId">
	    		<option value="">--<spring:message code="i.moved.board.selected" text="이동시킬 게시판을 선택 하십시오" />-- </option>
	    		<c:forEach var="bbsMaster" items="${bbsMasters}">
	    		<option value="${bbsMaster.bbsId }">
	    			<c:if test="${bbsMaster.topCode != null}" ><c:out value="${bbsMaster.topCode.codeName}" />&gt;</c:if>
	    			<c:out value="${bbsMaster.title }" />
	    		</option>
	    		</c:forEach>
	    	</form:select>
	    </td>
		<td nowrap  class="td_ce2">
			<form:checkbox path="transferAll" /> <spring:message code="t.bbs.all.selected" text="게시판 전체선택" />
	    </td>
		<td nowrap  class="td_ce2">
			<a onclick="javascript:goSubmit('transfer','false', '');" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.move" text="게시물 이동" /> </a>
	    </td>
	</tr>
</table>
																
<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<!-- <div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
<span id="errorDisplayer" style="color:red"></span>

		</td>
	</tr>
</table>
</form:form>

</body>
</html>
