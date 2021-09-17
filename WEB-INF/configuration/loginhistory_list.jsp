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
<title><spring:message code="main.Connection.Log" text="접속로그" /></title>

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
		frm.method = "GET";
		switch(cmd){
			case "del":
				if (!confirm("<spring:message code='c.delete' text='삭제 하시겠습니까?' />")){
					return false;
				}
				frm.action = "./loginhistory_delete.htm";
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

	function findLoginHistories(){
		var sDate = $("#sDate").val();
		var eDate = $("#eDate").val();
		if($.trim(sDate) == ""){
			alert("<spring:message code='appr.c.startdate' text='시작일을 입력해 주세요' />");
			$("#sDate").focus();
			return false;
		}

		if ($.trim(eDate) == "") {
			alert("<spring:message code='appr.c.enddate' text='종료일을 입력해 주세요.' />");
			$("#eDate").focus();
			return false;
		}
		
		var reqUrl = "<c:url value="/configuration/loginhistory_list_data.htm?" />" + "&sDate=" + sDate + "&eDate=" + eDate;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		$("#buttonArea").show();
		return true;
	}
	
	function resetLoginHistorySearch(){
		//$("#search")[0].reset();
		$("#search").each(function(){
			this.reset();
		});
		
		var reqUrl = "<c:url value="/configuration/loginhistory_list_data.htm" />";
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
		$("#buttonArea").hide();
	}
	

</script>
<script type="text/javascript">
$(document).ready(function(){
	<c:choose>
	<c:when test="${search.onSearch}">
		$("#resetSearch").show();
	</c:when>
	<c:otherwise>
		resetLoginHistorySearch();
	</c:otherwise>
	</c:choose>
	
	$("#search").submit(function(){
		return findLoginHistories();
	});
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/configuration/loginhistory_list_data.htm" />",
		datatype: "json",
		width: 1000,
	   	colNames:[
   			'<spring:message code='main.login.date' text="Log-in 일시" />',"Log-in ID"+"/"+'<spring:message code='main.means' text="방법" />', 
   			'<spring:message code='t.name' text="이름" />'+"/"+'<spring:message code='t.dpName' text="부서" />','<spring:message code='t.sercurityLevel' text="보안등급" />',
   		   	'IP '+ '<spring:message code='addr.address' text="주소"/>','<spring:message code='main.browser.type' text="브라우저유형" />'
	   	],
	   	colModel:[
	   		{name:'id.loginTime',index:'id.loginTime', width:200, align:"center"},
	   		{name:'loginId',index:'loginId', width:150, align:"center"},
	   		{name:'loginUser_.uName',index:'loginUser_.uName', width:150, align:"center"},
	   		{name:'securityLevel_.securityId',index:'securityLevel_.securityId', width:150, align:"center"},
	   		{name:'hostIp',index:'hostIp', width:150, align:"center"},
	   		{name:'agentType',index:'agentType', width:300, align:"center"}
		],	
		rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: "id.loginTime",
	    sortorder: 'desc',
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
	$("#dataGrid").setGridHeight($(window).height()-130);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-130);
	}).trigger('resize');	

	$("#sDate").datepicker({ dateFormat: 'yy-mm-dd' });
	$("#eDate").datepicker({ dateFormat: 'yy-mm-dd' });
	
});

</script>
<style>
.ui-jqgrid .ui-jqgrid-btable{table-layout: fixed !important;}
</style>
</head>

<body>


<!-- List Title -->
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%" style="height:30px;"> -->
<!-- <tr> -->
<!-- <td width="60%"><img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
<!-- 	<span class="ltitle"> 접속 로그</span> -->
<!-- </td> -->
<!-- <td width="40%" align="right"> -->
<!-- </td> -->
<!-- </tr> -->
<!-- </table> -->

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="main.Connection.Log"/>&nbsp;<!-- 접속로그 --> </span>
	</td>
	<td width="40%" align="right">
		<form:form commandName="search" onsubmit="return false;">
			<form:input path="sDate" style="width:80px;" />&nbsp;-&nbsp;
			<form:input path="eDate" style="width:80px;" />
			
			<a onclick="javascript:findLoginHistories();" class="button gray medium">
			<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search"/>&nbsp;<!-- 검색 --> </a>
			<span id="resetSearch" style="display:none;">
			<a  id="resetSearch" onclick="javascript:resetLoginHistorySearch();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search.del"/>&nbsp;<!-- 검색제거 --> </a>
			</span>
		
			<form:hidden path="useNewWin" />
			<form:hidden path="useAjaxCall" />
		</form:form>
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
<!-- List Title -->

<!-- List Button -->
<!-- 
<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
			<button onclick="javascript:goSubmit('del','');" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> 로그인제거 </button>
		</td>
		<td width="400" class="DocuNo" align="right" style="">
			&nbsp;	
		</td>
	</tr>
</table>
 -->
<!-- List Button -->


<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>

</BODY>
</HTML>