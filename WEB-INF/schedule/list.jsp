<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page errorPage="/error.jsp" %>
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
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title><spring:message code="main.Schedule" />&nbsp;<!-- 일정관리 --> <spring:message code="sch.List"/>&nbsp;<!-- 리스트 --></title>
	
	<%@ include file="../common/include.jquery.jsp"%>
	<%@ include file="../common/include.jqgrid.jsp"%>
	
	<%@ include file="../common/include.common.jsp"%>
	<%@ include file="../common/include.script.map.jsp" %>
	<link rel="stylesheet" href="/common/css/style.css">
	<script type="text/javascript">
		$.jgrid.no_legacy_api = true;
		$.jgrid.useJSON = true;
		
		$(document).ready(function(){
			$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
		
			$("#dataGrid").jqGrid({        
			    scroll: true,
			   	url:"./list_json.htm",
				datatype: "json",
				width: '100%',
// 				height:'100%',
			   	//colNames:['구분','유형','제목','시작일시','종료일시','작성자명','작성일자'],
			   	colNames:['<spring:message code="t.division"/>',
			   	          '<spring:message code="sch.Type"/>',
			   	          '<spring:message code="t.subject"/>',
			   	          '<spring:message code="sch.Strat.Date"/>',
			   	          '<spring:message code="sch.End.Date"/>',
			   	          '<spring:message code="t.writer"/>',
			   	          '<spring:message code="t.createDate"/>'],
			   	colModel:[
			   		{name:'gubun',index:'gubun', width:70, align:"center"},
			   		{name:'title',index:'title', width:70, align:"center"},
			   		{name:'subject',index:'subject', width:300, align:"left"},
			   		{name:'startdate',index:'startdate', width:80, align:"center"},
			   		{name:'enddate',index:'enddate', width:80, align:"center"},
			   		{name:'nName',index:'nName', width:70, align:"center"},
			   		{name:'createdate',index:'createdate', width:80, align:"center"}
				],	
			   	rowNum: ${userConfig.listPPage},
			   	mtype: "GET",
				prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
			   	pager: '#dataGridPager',
			    viewrecords: true,
			    sortname: 'createdate',
			    sortorder: 'desc',
			    scroll:false,
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
			
			$("#resetSearch").hide();
		});
	
		function gridReload(){
			var searchKey = $("#searchKey").val();
			var searchValue = encodeURI($("#searchValue").val(), "UTF-8");
			var reqUrl = "./list_json.htm?searchKey="+searchKey+"&searchValue="+searchValue;

			$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
			if (searchValue != "") $("#resetSearch").show(); else $("#resetSearch").hide();
		}
		
		function openDoc( docid ) {
			var url = "/schedule/read.htm?docId=" + docid ;
			OpenWindow(url, "Sche", "800", "350");
			//ModalDialog({'t':'일정 정보 조회', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false, 'd':false, 'r':false });
			
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "Schedule", 
// 					"width=800px,height=300px,resize=1,scrolling=1,center=1", "recal"
// 			);
		}
		
		function newDoc() {
			var url = "/schedule/form.htm" ;
			OpenWindow(url, "Sche", "800", "350");
			
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "Schedule", 
// 					"width=800px,height=400px,resize=1,scrolling=1,center=1", "recal"
// 			);
			//ModalDialog({'t':'일정 정보 등록', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':true, 'esc':false, 'd':false, 'r':false });
		}
	</script>
<style>
.ui-jqgrid tr.jqgrow td{text-align: center;}
</style>    
</head>

<body style="overflow:hidden;">
<form:form commandName="search" autocomplete="off" onsubmit="return false;">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
		<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
		<spring:message code="sch.Calendar"/><%-- 일정관리 > --%>
		<spring:message code="sch.Individuals.a.shared.calendar"/><%-- 개인-공유일정 --%> 
		<spring:message code="sch.List"/><!-- 리스트 --> 
	</span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

	<!-- List Button -->
	<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
		<tr>
			<td width="*" style="padding-left:3px;">
				<div onclick="newDoc()" class="button gray medium">
				<img src="../common/images/bb01.gif" border="0"> <spring:message code="sch.Schedule.Registration"/>&nbsp;<!-- 일정등록 --> </div>
			</td>
			<td width="400" class="DocuNo" align="right" style="padding-right:5px; ">
				<%
				//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
				String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
				%>
				<form:select path="searchKey">
					<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" text="제목"/></option>
					<option value="nName" <%= setSelectedOption("nName",searchKey) %>><spring:message code="t.name" text="이름"/></option>
				</form:select>
				<form:input style="width:100px;" path="searchValue" />
							
<!-- 				<img src="/common/images/btn_search.gif" id="submitButton" align="absmiddle" onclick="gridReload()" alt="검색" /> -->
				<a onclick="gridReload();" class="button gray medium">
				<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.search"/>&nbsp;<!-- 검색 --></a>
				
				<a onclick="location.reload()" id="resetSearch" class="button white medium">
				<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del"/>&nbsp;<!-- 검색제거 --> </a>
			</td>
		</tr>
	</table>
	<!-- List Button -->

	<!-- List -->
	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<span id="errorDisplayer" style="color:red"></span>
	<!-- List -->

</form:form>
</body>
</html>