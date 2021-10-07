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
<title><spring:message code="t.xxx" text="로그인세션" /></title>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/list.css">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>

<script language="javascript">
//	SetHelpIndex("admin_loginlist");
</script>
<script type="text/javascript">
	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin){
		var frm = document.getElementById("search");
		switch(cmd){
			case "del":
				if(!IsCheckedItemExist()){
					alert("<spring:message code='t.not.select.data' text='선택된 데이타가 없습니다.' />");
					return false;
				}
				if (!confirm("<spring:message code='c.close' text='삭제 하시겠습니까?' />")){
					return false;
				}
				frm.method = "POST";
				frm.action = "./loginsession_delete.htm";
				frm.sessionIds.value = $("#dataGrid").jqGrid('getGridParam','selarrrow');
				break;
		}
		if(isNewWin == "true"){
			frm.useNewWin.value = true;
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.target = winName;
		} else {
			frm.useNewWin.value = false;
			frm.target = "_self";
		}
		frm.submit();
	}
	
	function IsCheckedItemExist(){
		var s = $("#dataGrid").jqGrid('getGridParam','selarrrow');
		return s != "";
	}

</script>
<script type="text/javascript">
$(document).ready(function(){
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/configuration/loginsession_list_data.htm" />",
		datatype: "json",
		width: 1000,
	   	colNames:[
			'<spring:message code='main.login.date' text="Log-in 일시" />',"Log-in ID"+"/"+'<spring:message code='main.means' text="방법" />', 
			'<spring:message code='t.name' text="이름" />'+"/"+'<spring:message code='t.dpName' text="부서" />','<spring:message code='t.sercurityLevel' text="보안등급" />',
  			'IP '+ '<spring:message code='addr.address' text="주소"/>','<spring:message code='main.browser.type' text="브라우저유형" />'
	   	],
	   	colModel:[
	   		{name:'loginTime',index:'loginTime', width:200, align:"center"},
	   		{name:'loginId',index:'loginId', width:200, align:"center"},
	   		{name:'userName',index:'userName', width:280, align:"center"},
	   		{name:'securityName',index:'securityName', width:200, align:"center"},
	   		{name:'hostIp',index:'hostIp', width:200, align:"center"},
	   		{name:'agentType',index:'agentType', width:200, align:"center"}
		],	
		rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: "loginTime",
	    sortorder: 'desc',
	    multiselect: true,    
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	});
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-130);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-130);
	}).trigger('resize');	

	
});

</script>
<style>
.ui-jqgrid .ui-jqgrid-btable, .ui-jqgrid .ui-pg-table{table-layout: fixed !important;display: table;}
.ui-th-ltr, .ui-jqgrid .ui-jqgrid-htable th.ui-th-ltr {
    padding-left: 29.5px;
}
#dataGrid_cb{padding-left:0;}
#dataGrid tr td:last-child{white-space: pre-line;line-height: normal;text-align: left !important;padding-left: 0 !important;padding-right: 1%;}
</style>
</head>

<body>
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="sessionIds" />
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />

<!-- List Title -->
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%" style="height:30px;"> -->
<!-- <tr> -->
<!-- <td width="60%"><img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
<!-- 	<span class="ltitle"> 로그인 세션</span> -->
<!-- </td> -->
<!-- <td width="40%" align="right"> -->
<!-- </td> -->
<!-- </tr> -->
<!-- </table> -->

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="main.login.session"/>&nbsp;<!-- 로그인 세션 --> </span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
<!-- List Title -->

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
			<button onclick="javascript:goSubmit('del','');" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <fmt:message key="main.login.del"/>&nbsp;<!-- 로그인제거 --> </button>
		</td>
		<td width="400" class="DocuNo" align="right" style="">&nbsp;
				
		</td>
	</tr>
</table>
<!-- List Button -->

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>

</form:form>	
</BODY>
</HTML>