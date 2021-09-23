<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page errorPage="/error.jsp" %>
<%@ include file="/common/usersession.jsp"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title><spring:message code="t.bbs.category" text="게시판 분류" /></title>
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
	<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/css/base/jquery.ui.all.css" /> -->
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.jqgrid.css"  />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.multiselect.css"  />
	<link rel="stylesheet" href="/common/css/style.css">
	<style type="text/css"> 
		#search_dataGrid .ui-pg-div { display: none; }					/* jqgrid search hidden */
		#dataGridPager { height: 30px; }								/* jqgrid pager height */
		.ui-jqgrid .ui-pg-selbox { height: 23px; line-height: 23px; min-width: 30px; }	/* jqgrid pager select height */
	</style>
	 
	<script src="/common/jquery/js/jquery-1.6.4.min.js"  type="text/javascript"></script>
	<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js"  type="text/javascript"></script>
	<script src="/common/jquery/plugins/modaldialogs.js"  type="text/javascript"></script>
	<script src="/common/jquery/js/i18n/grid.locale-en.js"  type="text/javascript"></script>
	<script src="/common/jquery/plugins/jquery.jqGrid.min.js" type="text/javascript"></script>
	<script src="/common/jquery/plugins/ui.multiselect.js" type="text/javascript"></script>
	<script src="/common/scripts/common.js"></script>
	<script type="text/javascript">
		$.jgrid.no_legacy_api = true;
		$.jgrid.useJSON = true;
		
		$(document).ready(function(){
			$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
		
			$("#dataGrid").jqGrid({        
			    scroll: true,
			   	url:"./topcode_list_json.htm",
				datatype: "json",
				width: '100%',
				height:'100%',
			   	colNames:[
			   	          '<spring:message code="addr.category.name" text="분류명" />',
			   	          '<spring:message code="t.fixed.open" text="고정여부" />',
			   	          '<spring:message code="t.order" text="순서" />'
			   	],
			   	colModel:[
					{name:'codename',index:'codename', width:200, sortable: false, align:"left", formatter: codenameFormatter},
			   		{name:'isfixed',index:'isfixed', width:25, sortable: false, align:"center", formatter: isfixedFormatter},
			   		{name:'orders',index:'orders', width:25, sortable: false, align:"center"}
				],	
			   	rowNum: 999,
// 			   	rowList: [10,20,30],
			   	mtype: "GET",
// 				prmNames: {search: null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
// 			   	pager: '#dataGridPager',
			    viewrecords: true,
// 			    sortname: 'orders',
// 			    sortorder: 'asc',
			    scroll:false,
				loadError:function(xhr,st,err) {
			    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
			    }
			});

			$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
			$("#dataGrid").setGridWidth($(window).width()-0);
			$("#dataGrid").setGridHeight($(window).height()-130);
			
			$(window).bind('resize', function() {
				$("#dataGrid").setGridWidth($(window).width()+0);
				$("#dataGrid").setGridHeight($(window).height()-130);
			}).trigger('resize');
			
			$("#resetSearch").hide();
		});

		function codenameFormatter(cellvalue, options, rowObject) {
			return '<a href="/bbs/topcode_form.htm?code='+options.rowId+'">'+cellvalue+'</a>';
		}
		
		function isfixedFormatter(cellvalue, options, rowObject) {
			return (cellvalue == true)? 'O': 'X'; 
		}
		
		function gridReload(){
			var searchKey = $("#searchKey").val();
			var searchVal = encodeURI($("#searchVal").val(), "UTF-8");
			var reqUrl = "./data/list_json.jsp?searchKey="+searchKey+"&searchVal="+searchVal;
			$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
			if (searchVal != "") $("#resetSearch").show(); else $("#resetSearch").hide();
		}

		function openDoc(docid) {
			var url = "topcode_form.htm?code=" + docid ;
			OpenWindow(url, "Corpschedule", "800", "450");
			//ModalDialog({'t':'일정 정보 조회', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false, 'd':false, 'r':false });
		}
		
		function newDoc() {
			var url = "topcode_form.htm" ;
			OpenWindow(url, "Corpschedule", "800", "450");
			//ModalDialog({'t':'일정 정보 등록', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':true, 'esc':false, 'd':false, 'r':false });
		}
		
		function newDoc1() {
			location.href = "topcode_form.htm";
		}
	</script>
</head>
<body style="overflow:hidden;">
<form id="submitForm" name="submitForm" autocomplete="off" method="get" action="" >

	<!-- List Title -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="60%" style="padding-left:5px; padding-top:5px; ">
				<span class="ltitle" style="font-weight:bold;">
				<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="main.Board" text="게시판" /> &gt; <spring:message code="t.bbs.category" text="게시판 분류" /></span>
			</td>
			<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
		</tr>
	</table>
	<!-- List Title -->

	<!-- List Button -->
	<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
		<tr>
			<td width="*" style="padding-left:3px;">
				<div onclick="newDoc1()" class="button gray medium">
				<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.category.add" text="분류등록" /> </div>
			</td>
			<td width="400" class="DocuNo" align="right" style="padding-right:5px; ">
			<!-- 
				<select name="searchKey" id="searchKey">
					<option value="subject">분류명</option>
				</select>
				<input type="text" name="searchVal" id="searchVal" value="" style="width:100px" />
				<img src="/common/images/btn_search.gif" id="submitButton" align="absmiddle" onclick="gridReload()" alt="검색" />
				<button onclick="location.reload()" id="resetSearch" class="button white medium">
				<img src="../common/images/bb02.gif" border="0"> 검색제거 </button>
			 -->
			</td>
		</tr>
	</table>
	<!-- List Button -->

	<!-- List -->
	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<span id="errorDisplayer" style="color:red"></span>
	<!-- List -->

</form>
</body>
</html>