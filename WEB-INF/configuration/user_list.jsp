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
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<title><spring:message code="t.xxx" text="직원정보" /></title>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/list.css">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>
<style type="text/css">
#dataGrid td, th { padding-left: 0; padding-right: 0; }
#dataGrid td a { padding-left: 3px; }
</style>
<script language="javascript">
//	SetHelpIndex("admin_userlist");
</script>

<script type="text/javascript">
	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin ,userId){
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "view":
				frm.userId.value = userId;
				frm.action = "user_form.htm";
				break;
			case "new":
				frm.action = "../account/form.htm";
				break;

		}
		if(isNewWin == "true"){
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
		} else {	//self
			/*
			frm.useNewWin.value = false;
			frm.useLayerPopup.value = true;
			var formData = $("#search").serialize();
			var url = frm.action + "?" + formData;
			var a = parent.ModalDialog({'t':'사용자정보', 'w':800, 'h':600, 'm':'iframe', 'u':url});
			return;
			*/
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
		}
		
		frm.submit();
	}

	function OnKeyPressSearch() {
		var key = event.keyCode;
		if( key == 13 ) findUsers();
	}
	function findUsers(){
		var searchKey = $("#searchKey").val();
		var searchValue = $("#searchValue").val();
		if($.trim(searchValue) == ""){
			alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			$("#searchValue").focus();
			return false;
		}

		if ($.trim(searchKey) == "") {
			/*
			alert("<spring:message code='v.queryType.requried' text='검색 분류를  선택하여 주십시요!' />");
			$("#searchKey").focus();
			return false;
			*/
			document.getElementById("searchKey").selectedIndex = 1;			
		}
		
		//var reqUrl = "<c:url value="/configuration/user_list_data.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
		var reqUrl = "<c:url value="/configuration/user_list_data.htm?" />" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		return true;
	}
	
	function resetUserSearch(){
		//$("#search")[0].reset();
		$("#search").each(function(){
			this.reset();
		});
		
		var reqUrl = "<c:url value="/configuration/user_list_data.htm" />";
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	

</script>

<script type="text/javascript">
$(document).ready(function(){
	<c:choose>
	<c:when test="${search.onSearch}">
		$("#resetSearch").show();
	</c:when>
	<c:otherwise>
		resetUserSearch();
	</c:otherwise>
	</c:choose>
	
	$("#search").submit(function(){
		return findUsers();
	});
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	var grid = jQuery("#dataGrid");
	var emptyMsgDiv = jQuery("<div style='width:100%;height:100%;position:relative;'><div style='position:absolute;top:50%;margin-top:-5em;width:100%;text-align:center;'>등록된 자료가 없습니다.</div></div>");
	$("#dataGrid").jqGrid({        
	   	url:"<c:url value="/configuration/user_list_data.htm" />",
		datatype: "json",
		width: '100%',
	   	colNames:[
   			'<spring:message code='t.name' text="이름" />',
   			'<spring:message code='t.companyName2' text="회사명" />',
   			'<spring:message code='t.dpName' text="부서" />',
   			'<spring:message code='t.udName' text="직책" />',
   			'<spring:message code='t.upName' text="직급" />',
   		   	/* '<spring:message code='emp.id' text="사번"/>', */
   		   	'<spring:message code='t.mainJob' text="주업무" />',
   		 	'<spring:message code='emp.phone.office2' text="내선번호"/>',
   		 	'<spring:message code='t.cellTel' text="Cell." />',
   		 	'<spring:message code='emp.mail.id' text="메일ID"/>',
   		 	'<spring:message code='emp.mail.use' text="메일사용"/>'
	   	],
	   	colModel:[
	   		{name:'nName',index:'nName', width:150},
	   		{name:'addJob',index:'addJob', width:140, align:'center'},
	   		{name:'department_.dpName',index:'department_.dpName', width:200, align:"left"},
	   		{name:'userDuty_.udName',index:'userDuty_.udName',width:150, align:'center', hidden:true},
	   		{name:'userPosition_.upName',index:'userPosition_.upName', width:150, align:"center"},
	   		/* {name:'sabun',index:'sabun', width:200, align:"center"}, */
	   		{name:'mainJob',index:'mainJob', width:250, align:"left"},
	   		{name:'telNo',index:'telNo', width:230, align:"left"},
	   		{name:'cellTel',index:'cellTel', width:230, align:"left"},
	   		{name:'userName',index:'userName', width:200, align:"left"},
	   		{name:'mailFlag',index:'mailFlag', width:120, align:"center"}
		],	
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'userPosition_.orders',
	    scroll:false,
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data){
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            grid.trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	
            var ids = grid.jqGrid('getDataIDs');
            if (ids.length == 0) {
            	grid.hide(); emptyMsgDiv.show();
            } else {
            	grid.show(); emptyMsgDiv.hide();
            }
	    }
	});
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	$("#dataGrid").setGridWidth($(window).width()-10);
	$("#dataGrid").setGridHeight($(window).height()-159);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()-10);
		$("#dataGrid").setGridHeight($(window).height()-159);
	}).trigger('resize');

	$("input[name='searchValue']").keydown(function(event) {
		if (event.which == 13) {
			event.preventDefault();
			findUsers();
		}
	});
});

</script>

</head>

<body style="padding: 0;margin: 0;">
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="dpId" />
	<form:hidden path="pDpId" />
	<form:hidden path="userId" />
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="emp.mng.org" text="조직관리"/> &gt; <spring:message code="emp.user" text="사용자"/> </span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
	<!--<tr> 
		<td height="6" background="<%=imagePath%>/box_center_top_left.jpg" align="right"><img src="<%=imagePath%>/box_top_right.jpg" width="4" height="6"></td>
	</tr>-->
	<tr> 
		<td bgcolor="#FFFFFF" valign="top">
		
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
				<tr> 
					<!--<td width="11">&nbsp; </td>-->
					<td valign="top"> 
						<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
							<tr> 
								<td height="1"> 
								<!-- 타이틀 시작 -->
<!-- 									<table width="100%" border="0" cellspacing="0" cellpadding="0" height="44"> -->
<!-- 										<tr>  -->
<!-- 											<td height="11"></td> -->
<!-- 										</tr> -->
<!-- 										<tr>  -->
<!-- 											<td height="27">  -->
<!-- 												<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- 													<tr>  -->
<%-- 														<td width="35"><img src="<%=imagePath%>/sub_img/sub_title_admin.jpg" width="27" height="27"></td> --%>
<!-- 														<td class="SubTitle">조직관리 - 사용자</td> -->
<!-- 														<td valign="bottom" width="250" align="right">  -->
<!-- 															<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 																<tr>  -->
<!-- 																	<td valign="top" class="SubLocation">관리자 &gt; 조직관리 &gt; <b>사용자</b></td> -->
<!-- 																</tr> -->
<!-- 															</table> -->
<!-- 														</td> -->
<!-- 													</tr> -->
<!-- 												</table> -->
<!-- 											</td> -->
<!-- 										</tr> -->
<!-- 										<tr>  -->
<!-- 											<td height="3"></td> -->
<!-- 										</tr> -->
<!-- 										<tr>  -->
<!-- 											<td height="3">  -->
<!-- 												<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3"> -->
<!-- 													<tr>  -->
<%-- 														<td width="200" bgcolor="eaeaea"><img src="<%=imagePath%>/sub_img/sub_title_line.jpg" width="200" height="3"></td> --%>
<!-- 														<td bgcolor="eaeaea"></td> -->
<!-- 													</tr> -->
<!-- 												</table> -->
<!-- 											</td> -->
<!-- 										</tr> -->
<!-- 									</table> -->
									<!-- 타이틀 끝 -->
								</td>
							</tr>
							<tr> 
								<td valign="top"> 
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr> 
											<td height="10"></td>
										</tr>
										<tr> 
											<td> 
												<!-- 수행 버튼  시작 -->
												<table width="100%" border="0" cellspacing="0" cellpadding="0" style="sposition:relative;stop:1px">
													<tr> 
														<td width="60"> 
															<a onclick="javascript:goSubmit('new','true','');" class="button gray medium">
															<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="t.newDoc" text="새문서"/></a>
														</td>
														<td width="68"> 
														</td>
														<td> 
														</td>
														<td>&nbsp;</td>
														<td width="400" class="DocuNo" align="right" style="padding-rightㄴ:5px; ">
															<%
															//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
															String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
															%>
															<form:select path="searchKey">
																<option value="nName" <%= setSelectedOption("nName",searchKey) %>><spring:message code="t.name" text="이름"/></option>
																<option value="addJob" <%= setSelectedOption("addJob",searchKey) %>><spring:message code="t.companyName2" text="회사명"/></option>
																<%-- <option value="sabun" <%= setSelectedOption("sabun",searchKey) %>><spring:message code="emp.id" text="사번"/></option> --%>
																<option value="userName" <%= setSelectedOption("userName",searchKey) %>><spring:message code="emp.mail.id" text="메일ID"/></option>
																<option value="department_.dpName" <%= setSelectedOption("department_.dpName",searchKey) %>><spring:message code="t.dpName" text="부서"/></option>
																<%-- <option value="userPosition_.upName" <%= setSelectedOption("userPosition_.upName",searchKey) %>><spring:message code="t.upName" text="직급"/></option> --%>
															</form:select>
															<form:input style="width:100px;" path="searchValue" />
												
															<a onclick="javascript:findUsers();" class="button gray medium">
															<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색"/> </a>
															
															<span id="resetSearch">
															<a onclick="javascript:resetUserSearch();" class="button white medium">
															<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거"/> </a>
															</span>						
														</td>
													</tr>
												</table>
												<!-- 수행 버튼  끝 -->
											</td>
										</tr>
										<tr> 
											<td height="10"></td>
										</tr>
										<tr> 
											<td> 
												<table id="dataGrid"></table>
												<div id="dataGridPager"></div>
												<span id="errorDisplayer" style="color:red"></span>
											</td>
											<!--<td width="11">&nbsp;</td>-->
										</tr>
									</table>
								</td>
							</tr>											
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr> 
		<td height="6" align="right" background="<%=imagePath %>/box_center_bottom_left.jpg"><img src="<%=imagePath %>/box_bottom_right.jpg" width="4" height="6"></td>
	</tr>
</table>
</form:form>
</body>
</html>
