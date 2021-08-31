<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek3.domain.addressbook.AddrSearchItem" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><spring:message code="t.xxx" text="직원정보" /></title>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/list.css">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<script language="javascript">
//	SetHelpIndex("admin_userlist");
</script>

<style>
body {overflow:hidden; }
a, td, input, select {font-size:9pt; font-family:Gulim,Tahoma; }
input {cursor:hand; }

.space {line-height:3px;}

/* 추가분 */
.PageNo { font-family: "돋움"; font-size: 10pt;  text-decoration: none; letter-spacing:3px; padding-bottom:3px; }

.PageNo a{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px;}
.PageNo a:visited{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px; }
.PageNo a:hover {font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; color:#528BA0; text-decoration:none; height:20px; width:20px; padding-left:0px; }

/* 추가분 */
.PageNo1 {}
.PageNo1 a{ font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; border:1px solid #EBF0F8; 
			background-color:#FFFFFF; text-decoration:none; color:#6b6b6b;
			padding:2px 3px 3px 3px;}
.PageNo1 a:visited{ font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #EBF0F8; font-weight:bold; background-color:#FFFFFF; 
text-decoration:none; color:#528BA0; padding:2px 3px 3px 3px;}
.PageNo1 a:hover { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px;}
.PageNo1 a:active { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px;}

.PageNo span{width:2px; height:15px; color:#528BA0;}

/* 리스트 문서수 */
.doc_num{text-decoration:underline; font-size:8pt; cursor:hand;}

/* 미리보기 */
.p { width:15px; border:1px solid #A1B5FE; border-collapse:collapse; background-color:#FFFFFF;}
.p td { line-height:15px; border:1px solid #A1B5FE; cursor:hand; }

.p_sel { width:15px; border:2px solid #A1B5FE; border-collapse:collapse; background-color:#D7E4F5;}
.p_sel td {line-height:15px; border:2px solid #A1B5FE; cursor:hand; }

</style>

<script type="text/javascript">
	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin ,userId){
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "view":
				var url = "/common/user_read.htm?userId=" + userId ;
				OpenWindow(url, "<spring:message code='emp.info' text='임직원정보'/>", winWidth, winHeight);
// 				var objWin = OpenLayer(url, "<spring:message code='emp.info' text='임직원정보'/>", winWidth, winHeight,isWindowOpen);	//opt는 top, current
				
				//openDoc( userId );
				return;
				break;
			case "new":
				frm.action = "/account/form.htm";
				break;

		}
		//alert("DSF");
		if(isNewWin == "true"){
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
			
			var url = frm.action + "?" + formData;
			
// 			var objWin = OpenLayer(url, vtitle, winWidth, winHeight,isWindowOpen);	//opt는 top, current
			
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, vtitle, 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
			return;
		} else {	//self
			/*
			frm.useNewWin.value = false;
			frm.useLayerPopup.value = true;
			var formData = $("#search").serialize();
			var url = frm.action + "?" + formData;
			var a = parent.ModalDialog({'t':'사용자정보', 'w':800, 'h':600, 'm':'iframe', 'u':url});
			return;
			*/
			
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
			
			var url = frm.action + "?" + formData;
			
// 			var objWin = OpenLayer(url, vtitle, winWidth, winHeight,isWindowOpen);	//opt는 top, current
			
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, vtitle, 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
			return;
		}
		
		frm.submit();
	}
	
	function openDoc( userId ) {
		var url = "/common/user_read.htm?userId=" + userId ;
		OpenWindow(url, "", "800", "600");
		//ModalDialog({'t':'임직원 정보 조회', 'w':800, 'h':490, 'm':'iframe', 'u':url, 'modal':false, 'd':false, 'r':false });
		
// 		parent.dhtmlwindow.open(
// 				url, "iframe", url, "<spring:message code='emp.info' text='임직원정보'/>", 
// 				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 		);
	}
	
	//빠른검색
	function q_search(qsearch) {
		var frm = document.getElementById("search");
		frm.qsearch.value = qsearch;
		var reqUrl = "<c:url value="/common/user_list_data.htm?" />" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
	}

	function OnKeyPressSearch() {
		var key = event.keyCode;
		if( key == 13 ) findUsers();
	}
	function findUsers(){
		var searchKey = $("#searchKey").val();
		var searchValue = $("#searchValue").val();
		if($.trim(searchValue) == ""){
			alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			$("#searchValue").focus();
			return false;
		}

		if ($.trim(searchKey) == "") {
			/*
			alert("<spring:message code='v.queryType.requried' text='검색 분류를  선택하여 주십시요!' />");
			$("#searchKey").focus();
			return false;
			*/
			document.getElementById("searchKey").selectedIndex = 1;			
		}
		
		//var reqUrl = "<c:url value="/common/user_list_data.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
		var reqUrl = "<c:url value="/common/user_list_data.htm?" />" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		return true;
	}
	
	function resetUserSearch(){
		//$("#search")[0].reset();
		$("#search").each(function(){
			this.reset();
		});
		
		var reqUrl = "<c:url value="/common/user_list_data.htm" />";
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	

</script>

<script type="text/javascript">
$(document).ready(function(){
	<c:choose>
	<c:when test="${search.onSearch}">
		$("#resetSearch").show();
	</c:when>
	<c:otherwise>
		resetUserSearch();
	</c:otherwise>
	</c:choose>
	
	$("#search").submit(function(){
		return findUsers();
	});
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	   	url:"<c:url value="/common/user_list_data.htm" />",
		datatype: "json",
		width: "100%",
	   	colNames:[
   			'<spring:message code='t.name' text="이름" />',
   			'<spring:message code='t.companyName2' text="회사명" />',
   			'<spring:message code='t.dpName' text="부서" />',
   			'<spring:message code='t.udName' text="직책" />',
   			'<spring:message code='t.upName' text="직급" />',
   		   	/* '<spring:message code='emp.id' text="사번"/>', */
   		   	'<spring:message code='t.mainJob' text="주업무" />',
   		   	'<spring:message code='emp.phone.office2' text="내선번호"/>',
   		 	'<spring:message code='t.cellTel' text="Cell." />',
   		 	'<spring:message code='emp.mail.id' text="메일ID"/>'
	   	],
	   	colModel:[
	   		{name:'nName',index:'nName', width:300},
	   		{name:'addJob',index:'addJob', width:140, align:'center'},
	   		{name:'department_.dpName',index:'department_.dpName', width:140, align:'center'},
	   		{name:'userDuty_.udName',index:'userDuty_.udName',width:110, align:'center', hidden:true},
	   		{name:'userPosition_.upName',index:'userPosition_.upName', width:110, align:'center'},
	   		/* {name:'sabun',index:'sabun', width:120, align:'center'}, */
	   		{name:'mainJob',index:'mainJob', width:300},
	   		{name:'telNo',index:'telNo', width:150},
	   		{name:'cellTel',index:'cellTel', width:200, formatter: mobileFormatter},
	   		{name:'userName',index:'userName', width:300, formatter: emailFormatter}
		],	
	   	rowNum:${userConfig.listPPage},
	   	//rowList: [10,20,30],
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'nName',
	    scroll:false,
	    pginput: true,
	    gridview:true,
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete: function() {
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
	
	/* listResize */
	gridResize("dataGrid");
	
	$("input[name='searchValue']").keydown(function(event) {
		if (event.which == 13) {
			event.preventDefault();
			findUsers();
		}
	});
});

function emailFormatter(cellvalue, options, rowObject) {
	if( cellvalue == "") {
		return "";
	} else {
		return "<img align='absmiddle' src='/common/images/mail-medium.png'/><b><span style='color:#3072b3;'>" + cellvalue + "</span></b>";
	}
}

function mobileFormatter(cellvalue, options, rowObject) {
	if( cellvalue == "") {
		return "";
	} else {
		return "<img align='absmiddle' style='position:relative; top:-2px;' src='/common/images/mobile-phone-medium.png' /><b>" + cellvalue + "</b>";
	}
}
</script>

</head>

<body style="padding: 0;margin: 0;">
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="dpId" />
	<form:hidden path="pDpId" />
	<form:hidden path="userId" />
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />
	<input type="hidden" name="qsearch" value="">
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="t.worksupport" text="업무지원"/> &gt; <spring:message code="emp.info" text="임직원정보"/> </span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
	<tr>
		<td>
			<div style="width:100%; height:28px; border:1px; padding-top:6px;" class=PageNo1>
				<span style="border:1px solid #E8E8E8; padding:3px; background-color:#F4F4F4;">
				<img src="/common/images/vwicn008.gif" width="13" height="11"> <spring:message code="addr.search.quick" text="빠른검색"/></span> 
<!-- 				<img src="/common/images/blue_arrow.gif" width="13" height="11">  -->
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN1 %>');" title="ㄱ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㄱ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN2 %>');" title="ㄴ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㄴ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN3 %>');" title="ㄷ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㄷ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN4 %>');" title="ㄹ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㄹ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN5 %>');" title="ㅁ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅁ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN6 %>');" title="ㅂ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅂ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN7 %>');" title="ㅅ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅅ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN8 %>');" title="ㅇ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅇ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN9 %>');" title="ㅈ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅈ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN10 %>');" title="ㅊ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅊ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN12 %>');" title="ㅋ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅌ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN13 %>');" title="ㅌ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅍ</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN14 %>');" title="ㅎ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>" hidefocus>ㅎ</a>
				
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG1 %>');" style="font-size:10pt; font-family:Tahoma;" 
				title="<spring:message code="emp.search.AtoF" text="A에서 F사이를 포함하는 사람 검색"/>" hidefocus>A~F</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG2 %>');" style="font-size:10pt; font-family:Tahoma;"
				title="<spring:message code="emp.search.GtoJ" text="G에서 J사이를 포함하는 사람 검색"/>" hidefocus>G~J</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG3 %>');" style="font-size:10pt; font-family:Tahoma;"
				title="<spring:message code="emp.search.KtoO" text="K에서 O사이를 포함하는 사람 검색"/>" hidefocus>K~O</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG4 %>');" style="font-size:10pt; font-family:Tahoma;"
				title="<spring:message code="emp.search.PtoT" text="P에서 T사이를 포함하는 사람 검색"/>" hidefocus>P~T</a>
				<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG5 %>');" style="font-size:10pt; font-family:Tahoma;"
				title="<spring:message code="emp.search.UtoZ" text="U에서 Z사이를 포함하는 사람 검색"/>" hidefocus>U~Z</a>
			</div>
		</td>
		<td width="400" class="DocuNo" align="right" style="padding-rightㄴ:5px; ">
			<%
			//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
			String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
			%>
			<form:select path="searchKey">
				<option value="nName" <%= setSelectedOption("nName",searchKey) %>><spring:message code="t.name" text="이름"/></option>
				<option value="addJob" <%= setSelectedOption("addJob",searchKey) %>><spring:message code="t.companyName2" text="회사명"/></option>
				<option value="department_.dpName" <%= setSelectedOption("department_.dpName",searchKey) %>><spring:message code="t.dpName" text="부서"/></option>
				<%-- <option value="userPosition_.upName" <%= setSelectedOption("userPosition_.upName",searchKey) %>><spring:message code="t.upName" text="직급"/></option> --%>
				<option value="userName" <%= setSelectedOption("userName",searchKey) %>><spring:message code='emp.mail.id' text="메일ID"/></option>
			</form:select>
			<form:input path="searchValue" />
		
<!-- 			<img src="/common/images/btn_search.gif" align="absmiddle" onclick="javascript:findUsers();" alt="검색" /> -->
			<a onclick="javascript:findUsers();" class="button gray medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="search"/> </a>			
			<a onclick="javascript:resetUserSearch();" id="resetSearch" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="addr.del.search" text="검색제거"/> </a>
		</td>
	</tr>
</table>

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>
												

</form:form>
</body>
</html>
