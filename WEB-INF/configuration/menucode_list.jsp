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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><spring:message code='main.Menu.Management' text='메뉴관리'/></title>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>
<script language="javascript">
	//SetHelpIndex("admin_userlist");
</script>
<script type="text/javascript">
	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin ,mCode){
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "edit":
				frm.action = "menucode_form.htm";
				frm.mCode.value = mCode;
				break;
			case "new":
				frm.mCode.value = "";
				frm.action = "menucode_form.htm";
				break;
			default:
				return;
				break;
		}

// 		if(isNewWin == "true"){
// 			var winName = "popup_" + popupWinCnt++;
// 			OpenWindow("about:blank", winName, "480", "500");
// 			frm.useNewWin.value = true;
// 			frm.useLayerPopup.value = false;
// 			frm.target = winName;
// 		} else {	//self
// 			frm.useNewWin.value = false;
// 			frm.useLayerPopup.value = true;
// 			var formData = $("#search").serialize();
// 			var url = frm.action + "?" + formData;
// 			var a = parent.ModalDialog({'t':'메뉴관리', 'w':500, 'h':520, 'm':'iframe', 'u':url});
// 			return;
// 		}
		var formData = $("#search").serialize();
		var url = frm.action + "?" + formData;
		OpenWindow(url, "<spring:message code='main.Menu.Management' text='메뉴관리'/>", "500", "380");
// 		parent.dhtmlwindow.open(
// 				url, "iframe", url, "<spring:message code='main.Menu.Management' text='메뉴관리'/>",
// 				"width=500px,height=380px,center=1,resize=1,scrolling=0", "recal"
// 		);
// 		frm.submit();
	}

</script>

<script type="text/javascript">
$(document).ready(function(){
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false,sortable:false});

	$("#dataGrid").jqGrid({        
	   	url:"<c:url value="/configuration/menucode_list_data.htm" />?tpCode=<c:out value="${search.tpCode}" />",
		datatype: "json",
		width: '100%',
		height:'100%',
	   	colNames:[
			'<spring:message code='t.menu.code' text='코드명칭'/>',
			'<spring:message code='t.menu.codeName' text='코드명' />',
			'<spring:message code='t.url' text='URL'/>'
		],
	   	colModel:[
	   		{name:'codeName',index:'codeName', width:130, sortable:false},
	   		{name:'mCode',index:'mCode', width:120, align:"left", sortable:false},
	   		{name:'url',index:'url', width:550, align:"left", sortable:false}
		],
	   	rowNum:999,
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: "listCount", page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pgbuttons: false,		// disable page control like next, back button
	   	pgtext: null,				// disable pager text like 'Page 0 of 10'
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'codeName',
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
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-134);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-134);
	}).trigger('resize');		
});

</script>

</head>
<body>
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="mCode" />
	<form:hidden path="pCode" />
	<form:hidden path="tpCode" />
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />

<!-- List Title -->
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%" style="height:30px;"> -->
<!-- <tr> -->
<!-- <td width="60%"><img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
<!-- 	<span class="ltitle"> 메뉴코드 관리</span> -->
<!-- </td> -->
<!-- <td width="40%" align="right"> -->
<!-- </td> -->
<!-- </tr> -->
<!-- </table> -->

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="t.menucode.manage" text="메뉴코드 관리"/> </span>
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
			<a onclick="javascript:goSubmit('new','true','');" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="addr.newDoc" text="새문서"/> </a>
		</td>
		<td width="400" class="DocuNo" align="right" style="">
			&nbsp;	
		</td>
	</tr>
</table>
<!-- List Button -->

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<!-- <div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
<span id="errorDisplayer" style="color:red"></span>

</form:form>
</body>
</html>