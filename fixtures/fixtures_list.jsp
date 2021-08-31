<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="nek.fixtures.FixturesList" %>
<%@ page import="nek.fixtures.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/common/usersession.jsp"%>

<!-- 비품목록 조회 페이지 -->

<%
	// 카테고리
	ArrayList<FixturesCategoryItem> clist = null;
	FixturesCategoryList categoryDoc = null;
	try{
		categoryDoc = new FixturesCategoryList();
		categoryDoc.getDBConnection();
		clist = categoryDoc.getCategoryListFixtures();
	} finally { if (categoryDoc != null) categoryDoc.freeDBConnection(); }
	
	// 관리자 
	int manageLevel = 0;	 			//부서 비품관리자
	boolean isAdmin = false; 			//전체 관리자
	FixturesGrantList grant_doc = null;
	try {
		grant_doc = new FixturesGrantList(loginuser);
		grant_doc.getDBConnection();
		ArrayList<FixturesGrantItem> listDatas = grant_doc.getFixturesGrant(loginuser.uid);
		manageLevel = listDatas.get(0).getManageLevel();
	} catch(Exception e) {
	} finally { if (grant_doc != null) grant_doc.freeDBConnection(); }
	if (loginuser.securityId > 8) { isAdmin = true;	manageLevel = 3; }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>비품목록</title>
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.jqgrid.css"  />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.multiselect.css"  />
	<link rel="stylesheet" href="/common/css/style.css">
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
		
		$(document).ready(function() {
			$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	
			$("img").attr("align", "absmiddle");
			$("#viewList").attr("onpropertychanges", "div_resize()");
			
			console.log($('input[name=category]:checked').val());
			
			$("#dataGrid").jqGrid({
			    scroll: true,
			   	url:"/fixtures/data/list_json.jsp?category=" + $('input[name=category]:checked').val(),
				datatype: "json",
				width: '100%',
				height:'100%',
				colNames:[
						  '비품분류',
				          '<fmt:message key="book.model"/>',
				          '<fmt:message key="book.department"/>',
				          '<fmt:message key="book.representatives"/>',
				          '<fmt:message key="poll.state"/>',
				          '<fmt:message key="poll.state"/>'	//대여상태
				],
				//colNames:['비품분류','모델명','관리부서','담당자','상태'],
				colModel:[						
					{name:'categoryId',index:'categoryId', width:100, align:"center"},					
					{name:'modelName',index:'modelName', width:250, align:"left"},
					{name:'manageDeptName',index:'manageDeptName', width:80, align:"center"},
					{name:'manageUserName',index:'manageUserName', width:80, align:"center"},
					{name:'state',index:'state', width:80, align:"center"},
					{name:'reqState',index:'reqState', width:80, align:"center"}
				],
				rowNum: "${userConfig.listPPage}",
			   	mtype: "GET",
				prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType" },  
			   	pager: '#dataGridPager',
			    viewrecords: true,
			    sortname: 'categoryId desc, modelName',
			    sortorder: 'asc',
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
			$('#dataGrid').hideCol('state');	//비품상태 항목 숨김
			/* listResize */
			gridResize("dataGrid", 131);

			$(".buttonset").buttonset();
		});
		
		//비품분류 라벨선택
		function search() {
			var reqUrl = "/fixtures/data/list_json.jsp?category=" + $('input[name=category]:checked').val();
			$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		}
		//비품조회 (조회 전용 페이지)
		function openDoc(docId) {									
			var url = "/fixtures/fixtures_read.jsp?docId="+docId;
			OpenWindow(url, "fixtures", "800", "450");
		}
		//새비품 등록 (관리자용)
		function newDoc() {									
			var url = "/fixtures/form.jsp";
			OpenWindow(url, "fixtures", "800", "450");
		}
		//예약등록 (비품목록 팝업)
		function newBooking(){									
			var url = "/fixtures/list.jsp";
			OpenWindow(url, "비품목록", "800", "420");
		}
		
	</script>
    
</head>
<body>
	<!-- Title Start -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="35%" style="padding-left:5px; padding-top:5px; ">
				<span class="ltitle">
					<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />
					비품목록
				</span>
			</td>
			<td width="65%" align="right">
				<div class="buttonset" style="float: right;margin-left:6px;margin-right:6px;">
					<%	for(int i = 0, len = clist.size(); i < len; i++) {
							FixturesCategoryItem citem = (FixturesCategoryItem)clist.get(i);
							out.println("<input type=\"radio\" name=\"category\" id=\"cat"+(i+1)+"\" onclick=\"search();\" value=\""+citem.getCategoryId()+"\" />");
							out.println("<label for=\"cat"+(i+1)+"\">"+citem.getCategoryName(loginuser.locale)+"</label>");
						}
					%>
				</div>
				<div class="buttonset" style="float: right;margin-left:6px;margin-right:6px;">
					<input type="radio" name="category" id="cat0" onclick="search();" value="" checked="checked" />
					<label for="cat0"><fmt:message key="poll.view.all"/><!-- 전체보기 --></label>
				</div>
			</td>
		</tr>
	</table>
	<!-- Title End -->

	<!-- List Button and Search -->									
	<table width=100% border="0" cellspacing="0" cellpadding="0" style="height:30px; margin: 3px 0 0 0; ">									
		<tr>			
			<td align="left">
				<%if(isAdmin){ //관리자 전용권한%>
				<a onclick="javascript:newDoc(); return false;" class="button white medium">						
				<img src="../common/images/bb01.gif" border="0"> 새비품 </a>
				<%} %>
				<a onclick="javascript:newBooking(); return false;" class="button white medium">						
				<img src="../common/images/bb01.gif" border="0"> 예약등록</a>
			</td>					
		</tr>
	</table>
	<!-- List Button and Search -->

	<div class="space"></div>		
								
	<!-- List -->
	<div id="viewList" class="div-view">
		<table id="dataGrid"></table>
		<div id="dataGridPager"></div>
		<span id="errorDisplayer" style="color:red"></span>
	</div>
	<!-- List -->
</body>
</fmt:bundle>
</html>
