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
	   	url: "/configuration/menuname_list_json.htm?pCode=" + $('select[name=pCode]').val(),
		datatype: "json",
		width: '100%',
	   	colNames:['<spring:message code="none" text="메뉴명" />',
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
		cellurl : '/configuration/menuname_save.htm',
		beforeSubmitCell: function(rowid, cellname, value, iRow, iCol) {
			return {"mcode":rowid, "cellName":cellname, "cellValue":value};
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
	var stringUrl = "/configuration/menuname_list_json.htm?pCode=" + $('select[name=pCode]').val();
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
				<spring:message code="none" text="메뉴명 관리" />
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
			
			<select name="pCode" onchange="searchReload()">
				<option value="">전체보기</option>
				<c:forEach var="pcode" items="${topCodeList}">
				<option value="${pcode.mCode}">${pcode.codeName}</option>
				</c:forEach>
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