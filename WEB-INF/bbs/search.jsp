<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.bbs.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek.common.util.Convert"%>
<%
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String locale = (String)request.getAttribute("locale");
%>
<!DOCTYPE html>
<html>
<head>
<title>게시판 목록</title>
<%@ include file="../common/include.mata.jsp" %>
<%@ include file="../common/include.common.jsp" %>
<%@ include file="../common/include.jquery.jsp" %>
<%@ include file="../common/include.jqgrid.jsp" %>

<!-- gtip2 -->
<link rel="stylesheet" type="text/css" media="screen" href="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.css" />
<script src="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.js" type="text/javascript"></script>

<script type="text/javascript">
	function OnClickToggleAllSelect() {
// 		var items = document.getElementsByName("bbsIds");
		var items = $("input[type=checkbox]");
		if (items != null && items.length > 0) {
			var checked = !items[0].checked;
			for (var i = 0; i < items.length; i++) {
				items[i].checked = checked;
			}
		}
	}
</script>
<c:if test="${fn:length(bbsMasters) > 0}">
<script type="text/javascript">

	function findBbses(){
		var bbsIds = document.getElementsByName("bbsIds");
		var selected = false;
		for (var i = 0; i < bbsIds.length; i++) {
			if (bbsIds[i].checked) {
				selected = true;
				break;
			}
		}
		
		if (!selected) {
			alert("<spring:message code='i.bbs.selected.more' text='하나 이상의 게시판을 선택해 주십시오.' />");
			return false;
		}
		
		var searchSubject = $("#subject").val();
		var searchContent = $("#content").val();
		var searchWriter = $("#writer").val();
		if($.trim(searchSubject) == "" && $.trim(searchContent) == "" && $.trim(searchWriter) == ""){
			alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			return false;
		}
		var formData = $("#search").serialize();
		var reqUrl = "<c:url value="/bbs/search_data.htm?" />" + formData;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1,datatype:'json'}).trigger("reloadGrid");
// 		$("#resetSearch").show();
		$("#resetSearch").css('display', '');
		return true;
	}
	
	function fnReset(){
		location.reload(true);
	}


	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin ,docId, bbsId){
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "view":
				if(bbsId=="workbbs"){
					frm.action = "/bbswork/read.htm";
				}else{
					frm.action = "read.htm";
				}
				frm.docId.value = docId;
				frm.bbsId.value = bbsId;
				break;
			default:
				return;
				break;
		}
		if(isNewWin == "true"){
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
		} else {	//self
			frm.useNewWin.value = false;
			frm.useLayerPopup.value = true;
			var formData = $("#search").serialize();
			var url = frm.action + "?" + formData;
			
			OpenWindow(url, "<c:out value="${bbsMaster.title}" />", "780", "500");
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "<c:out value="${bbsMaster.title}" />", 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
			//parent.ModalDialog({'t':'<c:out value="${bbsMaster.title}" />', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false });
			return;
			
			//var a = parent.ModalDialog({'t':'<c:out value="${bbsMaster.title}" />', 'w':800, 'h':600, 'm':'iframe', 'u':url, modal:false });
			//return;
		}
		frm.submit();
	}
/*
	var winx = 0;
	var winy = 0;
	function ShowAttach(bbsId, docId ) {
		winx = window.event.x-265;
		winy = window.event.y-40;
		var url = "<c:url value="/bbs/download_attach_info.htm?bbsId=" />" + bbsId + "&docId=" + docId;
		ajaxRequest("GET", "", url, showAttachCompleted);
	}

	function showAttachCompleted(data, textStatus, jqXHR) {
		wid = 250 ;
		hei = 105;
		//oPopup is declared in common.js
		if(window.createPopup){
			oPopup = window.createPopup();
			var oPopupBody = oPopup.document.body;
			oPopupBody.innerHTML = data ;
			oPopup.show(winx, winy, wid, hei , document.body);
		} else {
			var features = "height=" + hei + ",width=" + wid + ",left=" + winx + ",top=" + winy + 
				",titlebar=no,menubar=no,scrollbars=no,status=no,location=no"
			oPopup = window.open("about:blank", "oPopup", features);
			oPopup.document.body.innerHTML = data;
		}
	}

	function attach_downss(docId, fileNo) {
		location.href =  "<c:url value="/bbs/download.htm?" />" + "bbsId=${search.bbsId}&docId=" + docId + "&fileNo=" + fileNo;   
	}
	*/
	
	function attach_down(docId, fileNo, sBbsId) {
		var bbsId = "${search.bbsId}";
		if (bbsId == "") bbsId = sBbsId || "";
		location.href =  "<c:url value="/bbs/download.htm?" />" + "bbsId=" + bbsId + "&docId=" + docId + "&fileNo=" + fileNo;   
	}
	 
	function listShowAttach() {
	     // Make sure to only match links to wikipedia with a rel tag
	    var strUrl = "/bbs/download_attach_info.htm?";
    	$('[name=listAttach]').each(function()
    	{
    		// We make use of the .each() loop to gain access to each element via the "this" keyword...
    		$(this).qtip(
    		{
    			content: {
    				// Set the text to an image HTML string with the correct src URL to the loading image you want to use
    				//text: '<img class="throbber" src="/projects/qtip/images/throbber.gif" alt="Loading..." />',
    				text: 'loading...',
    				ajax: {
    					url: strUrl + $(this).attr('rel') // Use the rel attribute of each element for the url to load
    				},
    				title: {
    					//text: 'Download Files - ' + $(this).text(), // Give the tooltip a title using each elements text
    					text: 'Download Files', // Give the tooltip a title using each elements text
    					button: true
    				}
    			},
    			position: {
    				at: 'left center', // Position the tooltip above the link
    				my: 'right center',
    				viewport: $(window), // Keep the tooltip on-screen at all times
    				effect: false // Disable positioning animation
    			},
    			show: {
    				event: 'click',
    				solo: true // Only show one tooltip at a time
    			},
    			hide: 'unfocus',
    			style: {
    				//classes: 'qtip-wiki qtip-light qtip-shadow'
    				classes: 'ui-tooltip-bootstrap ui-tooltip-shadow ui-tooltip-rounded',
					width:250
    			}
    		})
    	})
     
    	// Make sure it doesn't follow the link when we click it
    	.click(function(event) { event.preventDefault(); });
	}
	
	function ShowUserInfoSet() {
	     // Make sure to only match links to wikipedia with a rel tag
	     var strUrl = "../common/userinfo.htm?userId=" ;

	   	$('.maninfo').each(function()
	    {
	   		// We make use of the .each() loop to gain access to each element via the "this" keyword...
	   		$(this).qtip(
	   		{
	   			content: {
	   				// Set the text to an image HTML string with the correct src URL to the loading image you want to use
	   				//text: '<img class="throbber" src="/projects/qtip/images/throbber.gif" alt="Loading..." />',
	   				text: 'loading...',
	   				ajax: {
	   					//url: $(this).attr('rel') // Use the rel attribute of each element for the url to load
	   					//url: strUrl // Use the rel attribute of each element for the url to load
	   					url: strUrl + $(this).attr('rel') // Use the rel attribute of each element for the url to load
	   				},
	   				title: {
	   					text: 'Man Information - ' + $(this).text(), // Give the tooltip a title using each elements text
	   					//text: 'Man Infomation', // Give the tooltip a title using each elements text
	   					button: true
	   				}
	   			},
	   			position: {
	   				at: 'left center', // Position the tooltip above the link
	   				my: 'right center',
	   				viewport: $(window), // Keep the tooltip on-screen at all times
	   				effect: false // Disable positioning animation
	   			},
	   			show: { 
	   				event: 'click',
	   				solo: true // Only show one tooltip at a time
	   			},
	   			hide: 'unfocus',
	   			style: {
	   				//classes: 'qtip-wiki qtip-light qtip-shadow'
	   				classes: 'ui-tooltip-bootstrap ui-tooltip-shadow ui-tooltip-rounded',
					width:350
	   			}
	   		})
	   	})
    
	   	// Make sure it doesn't follow the link when we click it
		.click(function(event) { event.preventDefault(); });
	}
	function checkTopBbs(topId){
		if($("#top"+topId).is(":checked")){
			//전체선택
			$("."+topId).attr("checked", true); 
			$("#span"+topId).html("<b><spring:message code='t.select.all.clear' text='전체해제' /></b>"); 
		}else{
			//전체해제
			$("."+topId).attr("checked", false); 
			$("#span"+topId).html("<b><spring:message code='t.select.all' text='전체선택' /></b>"); 
		}
	}
</script>

<script type="text/javascript">
$(document).ready(function(){

	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	var grid = $("#dataGrid");
	var emptyMsgDiv = $("<div style='width:100%;height:100%;position:relative;'><div style='position:absolute;top:50%;margin-top:-5em;width:100%;text-align:center;'><spring:message code='t.not.registered' text='등록된 자료가 없습니다.' /></div></div>");
	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/bbs/search_data.htm" />",
		datatype: "local",
		width: "100%",
	   	colNames:['<spring:message code='t.bbsName' text='게시판명'/>','<spring:message code='t.subject' />','<spring:message code='t.createDate' />','<spring:message code='t.writer' />','<spring:message code='t.attached' />','<spring:message code='t.readCnt' />'],
	   	colModel:[
  	   		{name:'bbsId',index:'bbsId', width:150},
	   		{name:'subject',index:'subject', width:500},
	   		{name:'createDate',index:'createDate', width:150, align:"center"},
	   		{name:'writer_.nName',index:'writer_.nName', width:120, align:"center"},
	   		{name:'fileCnt',index:'fileCnt', width:50, align:"center"},
	   		{name:'readCnt',index:'readCnt', width:50, align:"right"},
		],	
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'createDate',
	    sortorder: 'desc',
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

			listShowAttach();
	        
	        ShowUserInfoSet();
	    }
	});
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-130);

	$('#subject,#content,#writer').keydown(function(event) {
		if (event.which == 13) {
			event.preventDefault();
			findBbses();
		}
	});
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-130);
	}).trigger('resize');	

});

</script>
</c:if>
<style>
.ui-jqgrid tr.jqgrow td{text-align: center !important;}
.ui-jqgrid tr.jqgrow td:nth-child(2){text-align: left !important;}
</style>
</HEAD>

<body>
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="docId" />
	<form:hidden path="bbsId" />
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />

	<!-- List Title -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="60%" style="padding-left:5px; padding-top:5px; ">
			<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
			<span class="ltitle">
				<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />
				<spring:message code="bbs.community" text="커뮤니티"/> &gt;
				<spring:message code="t.search.unified" text="통합검색" />
			</span>
		</td>
		<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
	</tr>
	</table>
	<!-- List Title -->

<table border="0" cellspacing="2" width="100%">
	<tr>
		<td width="120" class="td_le1">
			<spring:message code="main.Board" text="게시판" />
		</td>
		<td class="td_le2">
<%
	//최상위분류
	List<BbsMaster> topDatas = (List<BbsMaster>)request.getAttribute("bbsTop");
%>
			<input type="checkbox" id="topchkboxcode" onclick="checkTopBbs('chkboxcode');"/><span id="spanchkboxcode"><b><spring:message code='t.select.all' text='전체선택' /></b></span>&nbsp;
<% 	
		for(int i = 0, len = topDatas.size(); i < len; i++) {	
			BbsMaster topMaster = topDatas.get(i);
%>
			<form:checkbox path="bbsIds" class="chkboxcode" value="<%=topMaster.getBbsId() %>" /><%=topMaster.getTitle(locale) %>
<%	}	%>
		</td>
	</tr>
<%
	//하위분류
	List<BbsMaster> listDatas = (List<BbsMaster>)request.getAttribute("bbsList");
	int rowCnt = 4;	//Cols
	int count = 1;
	if (listDatas != null) {
		String oldCode = "";
		String tCode = "";
		for(int i = 0, len = listDatas.size(); i < len; i++) {
			BbsMaster bbsMaster = listDatas.get(i);
			BbsTopCode topCode = bbsMaster.getTopCode();
 			if(!topCode.getWorkType().equals("1")) continue;	//workType (1:게시판, 2:제안관리, 3:프로젝트)
			if (topCode != null && !topCode.getCodeName(locale).equals(oldCode)) {
				if (i != 0 && !"".equals(oldCode)) out.println("</td></tr>");
				oldCode = topCode.getCodeName(locale);
				tCode = topCode.getCode();
%>
	<tr>
		<td width="110" class="td_le1"><%=oldCode %></td>
		<td width="*" class="td_le2" style="line-height: 180%;">
			<input type="checkbox" id="top<%=tCode%>" onclick="checkTopBbs('<%=tCode%>');"/><span id="span<%=tCode%>"><b><spring:message code='t.select.all' text='전체선택' /></b></span>&nbsp;
			<form:checkbox path="bbsIds" class="<%=tCode%>" value="<%=bbsMaster.getBbsId() %>" /><%=bbsMaster.getTitle(locale) %>
<%				count=1;
			} else if (!oldCode.equals("")) { %>
			<form:checkbox path="bbsIds" class="<%=tCode%>" value="<%=bbsMaster.getBbsId() %>" /><%=bbsMaster.getTitle(locale) %>
<%			}
			count++;
		}
	}
	
// 	for(int k = count; k <= rowCnt; k++) {
// 		out.print("<td>&nbsp;</td>");
// 	}
// 	if (count-1 != rowCnt) out.print("</tr></table></td>"); 
%>
		</td>
	</tr>
</table>

<br style="line-height:5px">

<table width="100%">
	<tr>
		<td class="td_le1" style="width:110px;">
			<input type="button" value="<spring:message code="t.select.all" text="전체선택" />" onclick="OnClickToggleAllSelect()">
		</td>		
		<td class="td_le1" style="width:50px;">
			&nbsp;<spring:message code="t.subject" text="제목" />
			</td>
		<td class="td_le2" style="width:110px;">
			<form:input id="subject" path="subject" cssClass="input" cssStyle="width:95px;" />
		</td>
		<td class="td_le1" style="width:50px;">
			&nbsp;<spring:message code="t.contents" text="내용" />
		</td>
		<td class="td_le2" style="width:110px;">
			<form:input id="content" path="content" cssClass="input" cssStyle="width:95px;" />
		</td>
		<td class="td_le1" style="width:50px;"><spring:message code="t.writer" text="작성자" /></td>
		<td class="td_le2" style="width:110px;"><form:input id="writer" path="writer" cssStyle="width:95px;" cssClass="input" /></td>
		<td width="*">
			<span onclick="findBbses()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색" /> </span>
			<span onclick="fnReset()" id="resetSearch" class="button white medium" style="display:none; ">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거" /> </span>
		</td>
	</tr>
</table>

<br style="line-height:5px">

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>
</form:form>
</body>
</html>