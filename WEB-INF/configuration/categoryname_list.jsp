<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Insert title here</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.jqgrid.jsp" %>
<%@ include file="/WEB-INF/common/include.dhtmlwindow.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<script type="text/javascript">
$(document).ready(function() {	
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({
	    scroll: true,
	   	url: "/configuration/categoryname_list_json.htm?topCategory=" + $('select[name=topCategory]').val(),
		datatype: "json",
		width: '100%',
	   	colNames:['<spring:message code="t.menuname" text="메뉴명" />',
	   	          '<spring:message code="none" text="메뉴명 (한글)" />',
	   	          '<spring:message code="none" text="메뉴명 (English)" />',
	   	          '<spring:message code="none" text="메뉴명 (中文)" />',
	   	          '<spring:message code="none" text="메뉴명 (日本語)" />'],
	   	colModel:[
	   		{name:'codeName',index:'codeName', width:100, align:"left", sortable:false},
	   		{name:'codeNameKo',index:'codeNameKo', width:100, align:"left", editable:true, edittype:'text', sortable:false},
	   		{name:'codeNameEn',index:'codeNameEn', width:100, align:"left", editable:true, edittype:'text', sortable:false},
	   		{name:'codeNameZh',index:'codeNameZh', width:100, align:"left", editable:true, edittype:'text', sortable:false},
	   		{name:'codeNameJa',index:'codeNameJa', width:100, align:"left", editable:true, edittype:'text', sortable:false}
		],
	   	rowNum: 500,
// 	   	rowList: [5,10,15,20,25,30,35,40,45,50],
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'visitDate',
	    sortorder: 'desc',
	    scroll: false,
		cellEdit : true,
		cellsubmit : 'remote',
		cellurl : '/configuration/categoryname_save.htm',
		beforeSubmitCell: function(rowid, cellname, value, iRow, iCol) {
			return {"topCategory":$('select[name=topCategory]').val(), "cateCode":rowid, "cellName":cellname, "cellValue":value};
		},
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

function searchReload() {
	var stringUrl = "/configuration/categoryname_list_json.htm?topCategory=" + $('select[name=topCategory]').val();
	$("#dataGrid").jqGrid('setGridParam',{url:stringUrl,page:1}).trigger("reloadGrid");
}
</script>
<style>
.ui-jqgrid .ui-jqgrid-htable th div{text-align: left;}
</style>
</head>
<body style="overflow: hidden;">
<form name="visitSearchForm" id="visitSearchForm" method="post" onsubmit="searchReload(); return false;">
<!-- List Title Start -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="40%" style="padding-left:5px; padding-top:2px; ">
			<span class="ltitle" style="font-size:14px; font-family:dotum; font-weight:bold; float:left;">
				<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" border="0" />
				<spring:message code="t.category.name.manage" text="카테고리명 관리" />
			</span>
		</td>
		<td width="*" align="right" style="font-size:9pt;">
		</td>
	</tr>
</table>
<!-- List Title End -->

<!-- List Button Start -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
			
			<select name="topCategory" onchange="searchReload()">
				<option value="appr"><spring:message code="main.Approval" text="전자결재" /> &gt; <spring:message code="main.Complete" text="결재종결문서" /></option>
				<option value="sche"><spring:message code="sch.Datebook" text="일정관리" /> &gt; <spring:message code="sch.Some.kind.common" text="공용일정종류" /></option>
				<option value="addr"><spring:message code="main.Business.Card" text="주소록관리" /> &gt; <spring:message code="addr.category.share" text="공용분류" /></option>
				<option value="fixt"><spring:message code="book.manage" text="대여관리" /> &gt; <spring:message code="src.category.set" text="비품분류" /></option>
				<option value="dms"><spring:message code="t.doc.management" text="문서관리" /> &gt; <spring:message code="document.Open.Box" text="공용문서함" /></option>
				<option value="bbs"><spring:message code="main.Board" text="게시판" /> &gt; <spring:message code="t.bbs.kind" text="게시판종류" /></option>
				<option value="bbscode"><spring:message code="main.Board" text="게시판" /> &gt; <spring:message code="t.bbs.category" text="게시판분류" /></option>
				<option value="preserveperiod"><spring:message code="t.common" text="공통" /> &gt; <spring:message code="t.preserve.period" text="보존기간" /></option>
			</select>

		</td>
		<td width="5" align="right" style="padding-right:5px;">
		</td>
	</tr>
</table>
<!-- List Button End -->
</form>

<!-- List Start -->
<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>
<!-- List End -->
</body>
</html>