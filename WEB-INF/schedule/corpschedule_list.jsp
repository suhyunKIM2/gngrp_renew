<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="nek3.common.UserConfig" %>
<%
	UserConfig userConfig = (UserConfig) request.getAttribute("userConfig");
	boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
	boolean isCorpScheduleManager = (Boolean) request.getAttribute("isCorpScheduleManager");
%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="main.Company.Schedule" text="회사일정" /></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.jqgrid.jsp"%>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<script type="text/javascript">
var grid = null;
var listPPage = ${userConfig.listPPage};

$(document).ready(function() {
	grid = $("#dataGrid");
	grid.jqGrid({
	    scroll: true,
	   	url:"/schedule/corpschedule_list_json.htm",
		datatype: "json",
		width: "100%",
		height:"100%",
	   	colNames:["<spring:message code='t.division' text='구분' />",
	   	          "<spring:message code='sch.Type' text='유형' />",
	   	          "<spring:message code='t.subject' text='제목' />",
	   	          "<spring:message code='sch.Strat.Date' text='시작일시' />",
	   	          "<spring:message code='sch.End.Date' text='종료일시' />",
	   	          "<spring:message code='t.writer' text='작성자명' />",
	   	          "<spring:message code='t.createDate' text='작성일자' />"],
	   	colModel:[
			{name:"dept_.dpName",index:"dept_.dpName", width:60, align:"center" },
	   		{name:"scheCategory_.title",index:"scheCategory_.title", width:80, align:"center"},
	   		{name:"subject",index:"subject", width:250, align:"left", formatter: subjectFormatter},
	   		{name:"startdate",index:"startdate", width:80, align:"center"},
	   		{name:"enddate",index:"enddate", width:80, align:"center"},
	   		{name:"user_.nName",index:"user_.nName", width:70, align:"center"},
	   		{name:"createdate",index:"createdate", width:100}
		],	
		rowNum: listPPage,
		rowList: [10,20,30,50],
	   	mtype: "GET",
		prmNames: {search: null, nd: null, rows: "rowCnt", page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: "createdate",
	    sortorder: "desc",
	    scroll: false,
		loadError: function(xhr,st,err) {
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
	
	$("#resetSearch").hide();

	jQuery("input[name='searchValue']").bind("keypress", function(event) {
		if (event.keyCode === jQuery.ui.keyCode.ENTER) {
			gridReload();
			event.preventDefault();
		}
	});
});

function subjectFormatter(cellvalue, options, rowObject) {
	return '<a href="javascript:openDoc(\''+options.rowId+'\')">'+cellvalue+'</a>';
}

function gridReload(){
	var searchKey = $("#searchKey").val();
	var searchValue = encodeURI($("#searchValue").val(), "UTF-8");
	var reqUrl = "/schedule/corpschedule_list_json.htm?searchKey="+searchKey+"&searchValue="+searchValue;
	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
	if (searchValue != "") $("#resetSearch").show(); else $("#resetSearch").hide();
}

function openDoc(docid) {
	var url = "/schedule/corpschedule_read.htm?docid="+docid;
	var title = "<spring:message code='main.Company.Schedule' text='회사일정' />";
	
	OpenWindow(url, title, 500, 320);
	
	//ModalDialog({'t':'일정 정보 조회', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false, 'd':false, 'r':false });
	
	//parent.dhtmlwindow.open(
	//		url, "iframe", url, title, 
	//		"width=500px,height=260px,resize=1,scrolling=1,center=1", "recal"
	//);
}

function newDoc() {
	var url = "/schedule/corpschedule_form.htm";
	var title = "<spring:message code='main.Company.Schedule' text='회사일정' />";
	
	OpenWindow(url, title, 500, 320);
	
	//ModalDialog({'t':'일정 정보 등록', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':true, 'esc':false, 'd':false, 'r':false });
	
	//parent.dhtmlwindow.open(
	//		url, "iframe", url, title, 
	//		"width=500px,height=260px,resize=1,scrolling=1,center=1", "recal"
	//);
}
</script>
<style>
.ui-jqgrid tr.jqgrow td{text-align: center;}
</style>
</head>
<body>

<!-- Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="60%" style="padding-left:5px; padding-top:5px; ">
			<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
				<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
				<spring:message code="main.Schedule" text="일정관리" /> &gt;
				<spring:message code="sch.Company.schedules" text="회사일정" /> &gt; 
				<spring:message code="sch.List" text="리스트" /> 
			</span>
		</td>
		<td width="40%" align="right"></td>
	</tr>
</table>
<!-- Title -->

<!-- Button -->
<table width=100% border="0" cellspacing="0" cellpadding="0" style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
		<c:if test="${isAdmin or isCorpScheduleManager}">
			<div onclick="newDoc()" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="sch.Schedule.Registration" text="일정등록" /></div>
		</c:if>
		</td>
		<td width="700" class="DocuNo" align="right" style="padding-right:5px;">
			<select name="searchKey" id="searchKey">
				<option value="subject"><spring:message code="t.subject" text="제목" /></option>
				<option value="user_.nName"><spring:message code="t.writer" text="작성자" /></option>
			</select>
			<input type="text" name="searchValue" id="searchValue" value="" style="width:100px;" />
			<a onclick="gridReload();" class="button gray medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색" /></a>
			<a onclick="location.reload()" id="resetSearch" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거" /></a>
		</td>
	</tr>
</table>
<!-- Button -->

<!-- List -->
<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>
<!-- List -->

</body>
</html>