<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="nek.corpschedule.*" %>
<%@ include file="/common/usersession.jsp"%>
<%	
	boolean isAdmin = loginuser.securityId >= 9;
	boolean isManager = false;
	
	CorpScheduleDao dao = null;
	dao = new CorpScheduleDao();
	try {
		dao.getDBConnection();
		isManager = dao.isCorpScheduleManager(loginuser.uid);
	} catch(Exception e) {
		System.out.println("corpschedule/manager.jsp : " + e.getMessage());
	} finally { if (dao != null) dao.freeDBConnection(); }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
	<title><fmt:message key="main.Company.Schedule"/>&nbsp;<!-- 회사일정 --> - <fmt:message key="sch.List"/>&nbsp;<!-- 리스트 --></title>
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
			   	url:"./data/list_json.jsp",
				datatype: "json",
				width: '100%',
				height:'100%',
			   	//colNames:['구분','유형','제목','시작일시','종료일시','작성자명','작성일자'],
			   	colNames:['<fmt:message key="t.division"/>',
			   	          '<fmt:message key="sch.Type"/>',
			   	          '<fmt:message key="t.subject"/>',
			   	          '<fmt:message key="sch.Strat.Date"/>',
			   	          '<fmt:message key="sch.End.Date"/>',
			   	          '<fmt:message key="t.writer"/>',
			   	          '<fmt:message key="t.createDate"/>'],
			   	colModel:[
					{name:'stype',index:'stype', width:60, align:"center" },
			   		{name:'d.dpname',index:'d.dpname', width:80, align:"center"},
			   		{name:'subject',index:'subject', width:250, align:"left", formatter: subjectFormatter},
			   		{name:'startdate',index:'startdate', width:80, align:"center"},
			   		{name:'enddate',index:'enddate', width:80, align:"center"},
			   		{name:'u.nname',index:'u.nname', width:70, align:"center"},
			   		{name:'createdate',index:'createdate', width:100}
				],	
				rowNum: ${userConfig.listPPage},
			   	//rowList: [10,20,30],
			   	mtype: "GET",
				prmNames: {search: null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
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

		function subjectFormatter(cellvalue, options, rowObject) {
			return '<a href="javascript:openDoc('+options.rowId+')">'+cellvalue+'</a>';
		}
		
		function gridReload(){
			var searchKey = $("#searchKey").val();
			var searchVal = encodeURI($("#searchVal").val(), "UTF-8");
			var reqUrl = "./data/list_json.jsp?searchKey="+searchKey+"&searchVal="+searchVal;
			$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
			if (searchVal != "") $("#resetSearch").show(); else $("#resetSearch").hide();
		}

		function openDoc(docid) {
			var url = "/corpschedule/read.jsp?docid=" + docid ;
			OpenWindow(url, "Corpschedule", "800", "350");
			//ModalDialog({'t':'일정 정보 조회', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false, 'd':false, 'r':false });
			
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "Corp Schedule", 
// 					"width=500px,height=260px,resize=1,scrolling=1,center=1", "recal"
// 			);
		}
		
		function newDoc() {
			var url = "/corpschedule/form.jsp" ;
			OpenWindow(url, "Corpschedule", "800", "350");
			//ModalDialog({'t':'일정 정보 등록', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':true, 'esc':false, 'd':false, 'r':false });
			
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "Corp Schedule", 
// 					"width=500px,height=260px,resize=1,scrolling=1,center=1", "recal"
// 			);
		}
	</script>
</head>
<body style="overflow:hidden;">
<form id="submitForm" name="submitForm" autocomplete="off" method="get" action="" >

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
		<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
		<fmt:message key="main.Schedule"/>&nbsp;<!-- 일정관리 -->&gt;
		<fmt:message key="sch.Company.schedules"/>&nbsp;<!-- 회사일정 -->&gt; 
		<fmt:message key="sch.List"/><!-- 리스트 --> 
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
			<%	if (isAdmin || isManager) { %>
				<div onclick="newDoc()" class="button gray medium">
				<img src="../common/images/bb01.gif" border="0"> <fmt:message key="sch.Schedule.Registration"/>&nbsp;<!-- 일정등록 --></div>
			<%	} %>
			</td>
			<td width="700" class="DocuNo" align="right" style="padding-right:5px; ">
				<select name="searchKey" id="searchKey">
					<option value="subject"><fmt:message key="t.subject"/>&nbsp;<!-- 제목 --></option>
					<option value="u.nname"><fmt:message key="t.writer"/>&nbsp;<!-- 작성자 --></option>
				</select>
				<input type="text" name="searchVal" id="searchVal" value="" style="width:100px" />
<!-- 				<img src="/common/images/btn_search.gif" id="submitButton" align="absmiddle" onclick="gridReload()" alt="검색" /> -->
				<a onclick="gridReload();" class="button gray medium">
				<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search"/>&nbsp;<!-- 검색 --> </a>
				<a onclick="location.reload()" id="resetSearch" class="button white medium">
				<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search.del"/>&nbsp;<!-- 검색제거 --> </a>
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
</fmt:bundle>
</html>