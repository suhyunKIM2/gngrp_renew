<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="nek3.domain.addressbook.AddrSearchItem" %>
<%!
	private String setSelectedOption(String str1, String str2) {
		String selectStr = "";
		if (str1.equals(str2)) selectStr = "selected";
		return selectStr;
	}
%>
<%
	String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="mail.addresses" text="주소록"/> <fmt:message key="addr.lookList"/>&nbsp;<!-- 목록보기 --></title>
<%@ include file="../common/include.mata.jsp"%>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>
<%@ include file="../common/include.common.jsp"%>

<!-- jquery : Validate -->
<script src="/common/libs/jquery-validation/1.9/jquery.validate.min.js" type="text/javascript"></script>
<script src="/common/libs/jquery-validation/jquery.validate.defaults.js" type="text/javascript"></script>

<style type="text/css">
	/* 추가분 */
	.PageNo1 {}
	.PageNo1 a { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; border:1px solid #EBF0F8; 
				background-color:#FFFFFF; text-decoration:none; color:#6b6b6b;
				padding:2px 3px 3px 3px; }
	.PageNo1 a:visited { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
				border:1px solid #EBF0F8; font-weight:bold; background-color:#FFFFFF; 
				text-decoration:none; color:#528BA0; padding:2px 3px 3px 3px; }
	.PageNo1 a:hover { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
				border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
				color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px; }
	.PageNo1 a:active { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
				border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
				color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px; }
	#bubble_table { width:100%; height:100%; background-color:#fff; sborder:0px; border:collapse:collapse; }
	#bubble_table td { height:15px; font-size:10pt; font-weight:bold; sborder:0px; sbackground-color:#fff; }
	#bubble_table td a { font-size:10pt; font-weight:bold; sborder:0px; }
	
	.en_qbtn { font-size:10pt; font-family:Tahoma; }

	.ui-jqgrid tr.jqgrow td {
		font-weight: normal; 
		overflow: visible; 
		line-height:15px; 
		white-space: normal; 
		height: 22px;
		word-break:break-all;
		padding: 2px 2px 0 2px;
		/*
		border-bottom-width: 1px; 
		border-bottom-color: inherit; 
		border-bottom-style: solid;
		*/
	}
/* 	.ltitle { */
/* 		color:#000000; font-weight:bold; letter-spacing:1px;  */
/* 		font-size:14px; font-family:dotum; position: relative; */
/* 		tops: 2px; */
/* 	} */
	
	.ui-tooltip, .qtip{
		max-width: 800px;
		min-width: 200px;
		color:#000;
		font-family: Malgun Gothic, Tahoma !important;
		font-family: gothic, Tahoma;
		font-weight:bold;
	}
	.ui-tooltip a, .qtip a{
		font-size:20pt;
		color:#000;
	}
	#bubble_tablex * { font-size: 12pt; }
    .ui-jqgrid tr.jqgrow td{text-align: center;}
    .ui-jqgrid-htable th:nth-child(1){width:auto !important;}
</style>
<script type="text/javascript">
// 	function newdoc(){
// 		location.href="http://localhost/DHIERP2Mobile/addressbook/form.htm";
// 	}
// 	function goSubmit(docid, acid, isNewWin){
// 		location.href="http://localhost/DHIERP2Mobile/addressbook/read.htm?docId="+docid+"&categoryId="+acid;
// 	}
	var popupWinCnt = 0;
	function goSubmit(cmd, docId, acid, isNewWin){
		var frm = document.getElementById("search");
		var url = "";
		switch(cmd)
		{
			case "search":
				if(!searchValidation()) return;
				frm.pg.value = "1";
				frm.action = "./list.jsp";
				break;
			case "view":
				frm.docId.value = docId;
				frm.categoryId.value = acid;
				frm.action = "read.htm";
				break;
			case "all":
				frm.action = "./bbs_list.jsp";
				frm.pg.value = "1";
				frm.searchtype.value = "0";
				frm.searchtext.value = "";
				break;
			case "new":
				frm.docId.value = '';
				frm.action = "form.htm";
				break;
			<c:if test="${_isManager}">
			case "manage":
				frm.action = "./bbs_manager_view.jsp";
				url = "./bbs_manager_view.jsp?bbsId=<c:out value='${bbsMaster.bbsId}' />";
				break;
			</c:if>

		}
		var vtitle = '<spring:message code="addr.business.card" text="주소록"/>';
		if(isNewWin == "true"){
			document.getElementById("useNewWin").value = true;
			var winName = "popup_" + popupWinCnt++;
			var url = frm.action;
			if ( cmd == "view" ) {
				OpenWindow("about:blank", winName, "760", "510");
				frm.target = winName;
			} else {
				var frms = $("#search").serialize();
				var url = frm.action + "?" + frms ;
				
				OpenWindow(url, winName, "760", "510");
				//parent.ModalDialog({'t':vtitle, 'w':800, 'h':520, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false });
// 				parent.dhtmlwindow.open(
// 						url, "iframe", url, vtitle, 
// 						"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 				);
				
				return;
			}
		} else {
			var frms = $("#search").serialize();
			var url = frm.action + "?" + frms ;
			OpenWindow(url, vtitle, "760", "510");
			//parent.ModalDialog({'t':vtitle, 'w':800, 'h':440, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false });
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, vtitle, 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
			return;
		}
		frm.submit();
	} 
	
	$(document).ready(function() {
		// 전체 그리드에 대해 적용되는 default
		$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
		var grid = $("#dataGrid");
		var emptyMsgDiv = $("<div style='width:100%;height:100%;position:relative;'><div style='position:absolute;top:50%;margin-top:-5em;width:100%;text-align:center;'>등록된 자료가 없습니다.</div></div>");
		$("#dataGrid").jqGrid({
// 		    scroll: true,
		   	url:"<c:url value="/addressbook/list_json.htm" />" + "?categoryId=" + $("#categoryId").val(),
			datatype: "json",
			//height: auto,
			width: '100%',
			height:'100%',
			//구분, 공개, 이름, 회사명, 직함, 회사전화, 핸드폰, 메일, 근무처(X) , 부서, 등록자, 비고
		   	colNames:[
					'<spring:message code='addr.category' />',
					'',
					'<spring:message code='t.name' />',
					'<spring:message code='t.companyName' />',
					'<spring:message code='t.userPosition' />',
					'<spring:message code='t.tel' />',
					'<spring:message code='t.cellTel' />',
					'<spring:message code='t.email' />',
// 					'<spring:message code='t.department' />',
// 					'<spring:message code='t.writer' />',
					'<spring:message code='addr.remark' />',
					'<spring:message code='none' text='작성여부' />',
					''
					],
		   	colModel:[
					{name:'addressBookCategory_.title',index:'addressBookCategory_.title', width:80}, 
					{name:'공유',index:'share', width:10},
					{name:'name',index:'name', width:70},
					{name:'companyName',index:'companyName', width:80},
					{name:'dutyName',index:'dutyName', width:50},
					{name:'tel',index:'tel', width:70, formatter: telFormatter},
					{name:'cellTel',index:'cellTel', width:80, formatter: mobileFormatter},
					{name:'email',index:'email', width:140, formatter: emailFormatter},
// 					{name:'dept',index:'dept', width:70},
// 					{name:'author',index:'author', width:40},
					{name:'bigo',index:'bigo', width:10, hidden:true},
					{name:'owu',index:'owu', width:10, hidden:true},
					{name:'nName',index:'nName', hidden:true}
			],	
		   	rowNum: ${userConfig.listPPage},
// 		   	rowList: [20,30,50,100,200,1000],
		   	mtype: "GET",
			prmNames: {search:null, nd: null, rows: "rowCnt", page: "pageNo", sort: "sortColumn", order: "sortType"},  
			pager: '#dataGridPager',
		    viewrecords: true,
		    sortname: 'name',
		    scroll:false,
		    multiselect: true,
		    pginput: true,	/* page number set */
		    gridview:true,	/* page number set */
		    
			loadError:function(xhr,st,err) {
		    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
		    },	    
		    /*
		    gridComplete : function() {
		    	//$('td:eq(2)').qTip();
		        $('tr', this).each(function(key, item) {
			      	//var rowId = $(item).prop('id');
			      	
			      	var resultData = "<span style='width:500px; background-color:white;'>";
					
	                
			      	$(item).qTip({
			      		content:	resultData
			         	
			         	//content: {
				        //    text: 'Loading...', // The text to use whilst the AJAX request is loading
				        //    ajax: {
				        //   		url: '/some/url.php', // URL to the local file
				        //   		type: 'GET', // POST or GET
				        //   		data: {
				        //     		'rowId' : rowId
				        //   		} // Data to pass along with your request
				        //    }
			         	//}
			      		
			      	});
		        });
		    }
			*/
		    loadComplete:function(data){
		    	
		    	/* jqGrid PageNumbering Trick */
		    	var i, myPageRefresh = function(e) {
		            var newPage = $(e.target).text();
		            grid.trigger("reloadGrid",[{page:newPage}]);
		            e.preventDefault();
		        };
		        
		    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
		        jqGridNumbering( grid, this, i, myPageRefresh );
		
	            var ids = grid.jqGrid('getDataIDs');

// 	            if (ids.length == 0) {
//	            	ModalDialog({'t':'주소록', 'w':800, 'h':495, 'm':'iframe', 'u':url, 'modal':true, 'esc':false, 'd':false});
//	            	ModalDialog({'t': 'Document Not Found', 'c':'<spring:message code="t.not.registered" text="등록된 자료가 없습니다."/>', 'w':'250', 'h':'130', 'modal':false });
// 	            }

	            if (ids.length == 0) {
	            	grid.hide();
	            	emptyMsgDiv.show();
	            } else {
	            	grid.show();
	            	emptyMsgDiv.hide();
	            }
	            
	            for (var i=0;i<ids.length;i++) {
	                var id=ids[i];
	                
	                var rowData = grid.jqGrid('getRowData',id);
	                
	                var resultData = "<span style='widths:700px; background-color:white;'>";
					resultData += "<table id='bubble_tablex' style='width:100%;' cellspacing=0 cellpadding=0>";
	                resultData += "<tr height=30><td colspan=2 style='padding:5px; font-size:12pt; '>" + rowData.name + " " + rowData.dutyName + " - " + rowData.companyName + "</td></tr>";
	                resultData += "<tr height=1><td colspan=2 style='height:1px; border-bottom:1px solid #e3e3e3;'></td></tr>";
	                resultData += "<tr height=30><td colspan=2 style='padding:5px; font-size:12pt; '><spring:message code='addr.phone' text='전화'/> : " + rowData.tel + " , <spring:message code='addr.cellphone' text='휴대폰'/> : " + rowData.cellTel + "</td>";
	                resultData += "<tr height=1><td colspan=2 style='height:1px; border-bottom:1px solid #e3e3e3;'></td></tr>";
	                resultData += "<tr height=30><td colspan=2 style='padding:5px; font-size:12pt; '><spring:message code='addr.email' text='이메일'/> : " + rowData.email + "</td></tr>";
	                resultData += "<tr height=1><td colspan=2 style='height:1px; border-bottom:1px solid #e3e3e3;'></td></tr>";
	                resultData += "<tr height=30><td style='width:70px; padding:5px; font-size:12pt; '><spring:message code='addr.remark' text='비고'/> : " + rowData.bigo + "</td></tr>";
	                resultData += "</table></span>";
	                
	                //alert( rowData.companyName);
					$('#' + id).qtip({
						content     : resultData,
						position    : {
							my :	'bottom center',
							at :	'top center',
							//target  : 'mouse'
							adjust: { mouse: true }
						},
						//style       : 'tooltipDefault'
						
// 						ui-tooltip-shadow{ } /* Adds a shadows to your tooltips */
// 						ui-tooltip-rounded{ } /* Adds a rounded corner to your tooltips */
// 						ui-tooltip-bootstrap{ } /* Bootstrap style */
// 						ui-tooltip-tipsy{ } /* Tipsy style */
// 						ui-tooltip-youtube{ } /* Youtube style */
// 						ui-tooltip-jtools{ } /* jTools tooltip style */
// 						ui-tooltip-cluetip{ } /* ClueTip style */
// 						ui-tooltip-tipped{ } /* Tipped style */
	
						style: {
							//default:	false,
							//classes:	'ui-tooltip-bootstrap',
							//classes : 'ui-tooltip-shadow',
							classes: 'ui-tooltip-blue ui-tooltip-shadow ui-tooltip-rounded',
							width:600
							//padding:'3px',
							//border: '1px solid black'
// 							background:'#fff',
// 							font-size:'11px', 
// 							z-index:'500'
						},
						//hide: {when:'mouseout', fixed:true, delay:100},
						api: {
						    //onContentUpdate: function() { this.updateWidth(); },
						    //onContentLoad:  function() { this.updateWidth(); },
						    //beforeContentLoad: function() { this.updateWidth(700); }
						}
	   		      	});
	            }
		    }
		});
		emptyMsgDiv.insertAfter(grid.parent());

		$("#dataGrid").jqGrid('hideCol','bigo');
		$("#dataGrid").jqGrid('hideCol','owu');
		$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
		
		/* listResize */
		gridResize("dataGrid", 172);
		/*
		$("#dataGrid").setGridWidth($(window).width()-0);
		$("#dataGrid").setGridHeight($(window).height()-170);
		
		$(window).bind('resize', function() {
			$("#dataGrid").setGridWidth($(window).width()+0);
			$("#dataGrid").setGridHeight($(window).height()-170);
		}).trigger('resize');
		*/
		
		enableAutosubmit(true);
	});
	
	function telFormatter(cellvalue, options, rowObject) {
		if( cellvalue == "") {
			return "";
		} else {
			return "<b><font style='font-family:Arial;'>" + cellvalue + "</font></b>";
		}
	}
	
	function emailFormatter(cellvalue, options, rowObject) {
		if( cellvalue == "") {
			return "";
		} else {
			return "<img align='absmiddle' src='/common/images/mail-medium.png'/><a style='color:#3072b3; font-weight: bold;' href='javascript:openMailForm(\""+rowObject[7]+"\",\""+rowObject[10]+"\")'>" + rowObject[7] + "</a>";
		}
	}
	
	function mobileFormatter(cellvalue, options, rowObject) {
		if( cellvalue == "") {
			return "";
		} else {
			return "<img align='absmiddle' style='position:relative; top:-2px;' src='/common/images/mobile-phone-medium.png' /><b><font style='font-family:Arial;'>" + cellvalue + "</font></b>";
		}
	}
	function openMailForm(mailto, nname) {
		var url = "/mail/mail_form.jsp?mailto=" + encodeURI(mailto+","+nname);
		OpenWindow( url, "", "800" , "650" );
	}
	
// 	function search(){
// 		var searchKey = $("#searchKey").val();
// 		var searchValue = $("#searchValue").val();
// 		var reqUrl = "<c:url value="/addressbook/list_xml.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
// 		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
// 	}
	
// 	$(function() {
// 		$("#dataFinder").accordion({
// 			collapsible: true,
// 			change:function(event, ui){
// 				//alert("changed");
// 			}
// 		});
// 	});
	
// 	function findSearch(){
// 		var searchKey = document.getElementById("searchKey").value;
// 		var searchValue = document.getElementById("searchValue").value;
// 		if($.trim(searchValue) == ""){
// 			$("#searchValue").focus();
// 			return false;
// 		}
		
// 		if ($.trim(searchKey) == "") {
// 			document.getElementById("searchKey").selectedIndex = 1;
// 		}
	
// 		var reqUrl = "/addressbook/list_json.htm?" + $("#search").serialize();
// 		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
// 		$("#resetSearch").show();
// 		return true;
// 	}
	
// 	function checkKey() {
// 		if( event.keyCode == 13 ) findSearch();
// 	}
	
	function q_search( args ) {
		document.getElementById("qsearch").value = args;
		var reqUrl = "/addressbook/list_json.htm?" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		document.getElementById("qsearch").value = "";
		return;
	}
	
	function resetSearch() {
		$("#search").each(function(){
			this.reset();
			flAuto = false;
			$("#submitButton").find("a").attr("disabled", false);
		});
		
		var reqUrl = "/addressbook/list_json.htm";
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	
	var timeoutHnd;
	var flAuto = false;

	function doSearch(e) {
		var result = ""; 
	    
		if (window.event)result = window.event.keyCode;
	    else result = e.which;
	    
		if (result == 13) {
			if (timeoutHnd) clearTimeout(timeoutHnd);
			gridReload();
		} else {
			if (!flAuto) return;
			if (timeoutHnd) clearTimeout(timeoutHnd);
			timeoutHnd = setTimeout(gridReload, 500);
		}
	}
	
	function startDoSearch(e) {
		if (timeoutHnd) { clearTimeout(timeoutHnd); }
		timeoutHnd = setTimeout(gridReload, 500);
	}
	
	function stopDoSearch(e) {
		clearTimeout(timeoutHnd);
	}
	
	var valCnt = 0;
	var oldVal = "";
	var newVal = "";
	function gridReload() {
// 		valCnt++;
		newVal = document.getElementById("searchValue").value;
		if (newVal != oldVal) {
			var reqUrl = "/addressbook/list_json.htm?" + $("#search").serialize();
			$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
			if (document.getElementById("searchValue").value != "") 
				$("#resetSearch").show(); else $("#resetSearch").hide();
		}
		oldVal = newVal;
		if (flAuto) { timeoutHnd = setTimeout(gridReload, 500); };
	}
	
	function enableAutosubmit(state) {
		flAuto = state;
		$("#autosearch").attr("checked", state);
		$("#submitButton").find("a").attr("disabled", state);
	}
	
	function excel_download() {
		var reqUrl = "/addressbook/excel_download.htm?" + $("#search").serialize();
		location.href = reqUrl;
	}
	
	function deleteAddressBookCK(str) {
		var rowids = str.split(",");
		for(var i = 0, len = rowids.length; i < len; i++) {
			var rowid = rowids[i];
			var data = $("#dataGrid").jqGrid('getRowData', rowid) || { owu: "false" };
			if (data.owu == "false") return false;
		}
		return true;
	}
	
	function deleteAddressBooks() {
		var selarrrow = jQuery("#dataGrid").jqGrid('getGridParam','selarrrow') + "";
		
		if (selarrrow == "") { 
			alert("<spring:message code='v.no.select.address' text='선택된 주소록이 없습니다.'/>");
			return; 
		}
		
		<c:if test="${user.securityLevel.securityId != 9}">
		if (!deleteAddressBookCK(selarrrow)) {
			alert("<spring:message code='v.you.create.delete.possible' text='자신이 작성한 주소록만 삭제할 수 있습니다.'/>\n<spring:message code='v.not.create.address' text='선택한 주소록중에서 자신이 작성자가 아닌 주소록이 있습니다.'/>");
			return;
		}
		</c:if>
		
		var len = selarrrow.split(",").length;
		
		if (!confirm("<spring:message code='t.addressbook' text='주소록'/> " + len + "<spring:message code='sch.c.select.delete2' text='개의 문서를 삭제 하시겠습니까?'/>"))
			return;

	    $.ajax({ 
	        url: '/addressbook/deleteAddressBooks.htm',
	        type: 'post' ,dataType: 'text' ,async: true,
	    	data: { ids: selarrrow },
	        beforeSend: function() { waitMsg(); },
	        complete: function(){ $.unblockUI(); },
	        success: function(data, status, xhr) { $("#dataGrid").trigger("reloadGrid"); },
	        error: function(xhr, status, error) { $.unblockUI(); }
	    });
	}
	
	function moveAddressBooks() {
		var selarrrow = jQuery("#dataGrid").jqGrid('getGridParam','selarrrow') + "";		//docid
		var moveKey = $('select[name=moveKey]').val();		//acid, gubun
		if (selarrrow == "") { 
			alert("<spring:message code='v.no.select.address' text='선택된 주소록이 없습니다.'/>");
			return; 
		}
		if(moveKey == ""){
			alert("<spring:message code='mail.c.move.doc' text='이동할 문서가 없습니다.'/>");
			return; 
		}
			
	    $.ajax({ 
	        url: '/addressbook/gubunCheck.htm',
	        type: 'post' ,
	        dataType: 'json' ,
	    	data: { "ids" : selarrrow},
	        success: function(data) {
	        	var count = data.result;
	        	if(data.result == 0){
	        		fnMove();
	        		return true;
	        	}else{
	        		alert("권한이 없는 문서가 "+count+" 건 있습니다.");
	        		return false;
	        	}
	        },
	        error: function() {}
	    }); 
	     
	}
	function fnMove(){
		var selarrrow = jQuery("#dataGrid").jqGrid('getGridParam','selarrrow') + "";		//docid
		var moveKey = $('select[name=moveKey]').val();		//acid, gubun
		
		var idNtype = new Array();
		idNtype = moveKey.split(",");
		var acid = idNtype[0];
		
		$.ajax({ 
	        url: '/addressbook/moveAddressBooks.htm',
	        type: 'post' ,
	        dataType: 'text' ,
	    	data: { "ids" : selarrrow, "acid": acid},
	        success: function(data, status, xhr) { $("#dataGrid").trigger("reloadGrid"); },
	        error: function() {}
	    }); 
	}
	
	function copyAddressBooks() {
		var selarrrow = jQuery("#dataGrid").jqGrid('getGridParam','selarrrow') + "";		//docid
		var moveKey = $('select[name=moveKey]').val();		//acid
		if (selarrrow == "") { 
			alert("<spring:message code='v.no.select.address' text='선택된 주소록이 없습니다.'/>");
			return; 
		}
		if(moveKey == ""){
			alert("<spring:message code='v.no.items.copied' text='복사할 항목이 없습니다.'/>");
			return; 
		}
		
		var idNtype = new Array();
		idNtype = moveKey.split(",");
		var acid = idNtype[0];
		
	    $.ajax({ 
	        url: '/addressbook/copyAddressBooks.htm',
	        type: 'post' ,
	        dataType: 'text' ,
	    	data: { "ids" : selarrrow, "acid": acid},
	        success: function(data, status, xhr) { $("#dataGrid").trigger("reloadGrid"); },
	        error: function() {}
	    }); 
	}
</script>

<!-- 빠른 등록 관련 스크립트 -->
<script type="text/javascript">
$(document).ready(function() {
	validator = $("#addressBookWebForm").validate({
		rules:{
			"addressBook.gubuns":{ required: true },
			"addressBook.name":{ required: true },
			"addressBook.email":{ required: true, email: true }
		},
		messages:{
			"addressBook.name":{ required: "<spring:message code='addr.required.input' text='필수입력'/>" },
			"addressBook.email":{ required: "<spring:message code='addr.required.input' text='필수입력'/>", email: "<spring:message code='i.not.main.format' text='메일 형식에 맞지 않습니다'/>" }
		},
		focusInvalid: true
	});
});

//빠른 등록
function qdoc() {
	var qdoc = document.getElementById("qdoc");
	if ( qdoc.style.display == "" ) {
		qdoc.style.display = "none";
	} else {
		qdoc.style.display = "";
	}
}

function qdocsave() {
	//valid check & save
	if(!validCheck()) return;
	var obj = null;
	
	var gubun = $(":[name=addressBook.gubuns]:checked").val();
	if (gubun == "S") {
		obj = document.getElementById("gubun_sv");
	} else {
		obj = document.getElementById("gubun_pv");
	}
	
	var acId = document.getElementById("acid");
	acId.value = obj.options[obj.selectedIndex].value;
	
	var fm = document.getElementById("addressBookWebForm");
	if (!confirm("<spring:message code='c.save' text='저장 하시겠습니까?'/>")) return false;
	fm.method = "POST";
	fm.action = "<c:url value="/addressbook/save.htm" />";
	fm.submit();
}

function validCheck() {
	var isValid = validator.form();
	if (!isValid) validator.focusInvalid();
	return isValid;
}

function selectAcid(val){
	var frm = document.form1;
	 acid1 = document.getElementById("gubun_s");
	 acid2 = document.getElementById("gubun_p");
	if(val == 'S'){
		acid1.style.display = "";
		acid2.style.display = "none";
		//frm.acid2.value = "";
		document.getElementById("gubun_pv").value = "";
		document.getElementById("gubun_pv")[0].selected = true;
	}else if(val == 'P'){
		acid1.style.display = "none";
		acid2.style.display = "";
		//frm.acid1.value = "";
		document.getElementById("gubun_sv").value = "";
		document.getElementById("gubun_sv")[0].selected = true;
	}
}

function crImeMode(obj) { 
	obj.value = obj.value.replace(/[\ㄱ-ㅎ가-힣]/g, '');
}

function telNumberMode(obj) { 
	obj.value = obj.value.replace(/[^(\-)^(0-9)]/g, '');
}
</script>
</head>

<body style="overflow:hidden;">

	<!-- List Title -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
				<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="t.worksupport" text="업무지원"/> &gt; <spring:message code="addr.business.card" text="주소록"/></span>
			</td>
			<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
		</tr>
	</table>
	<!-- List Title -->

	<!-- List Button -->
	<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
		<tr>
			<td width="*" style="padding-left:3px;">
				<a onclick="javascript:goSubmit('new','true','', 'true');" class="button gray medium">
					<img src="../common/images/bb01.gif" border="0"> <spring:message code="addr.newDoc" text="새문서"/>
				</a>
				
				<%-- <a href="javascript:qdoc();" class="button white medium">
					<img src="../common/images/bb01.gif" border="0"> <spring:message code="addr.insert.quick" text="빠른등록"/>
				</a> --%>
				
				<a href="javascript:excel_download();" class="button white medium">
					<img src="../common/images/bb01.gif" border="0"> <spring:message code="addr.excel.download" text="엑셀 다운로드"/>
				</a>
				
				<a href="javascript:deleteAddressBooks();" class="button white medium">
					<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.delete" text="삭제"/>
				</a>
				&nbsp;
				<select name="moveKey" style="width:150px;">
					<option value=""><spring:message code="sch.select.please" text="선택하세요"/></option>
					<option value="">--------<spring:message code="addr.category.share" text="공용분류"/>--------</option>
					<c:forEach var="result" items="${categoryListS }" varStatus="status">
					<option value="${result.acid },${result.gubun}" >${result.title }</option>
					</c:forEach>
					<option value="">--------<spring:message code="addr.category.person" text="개인분류"/>--------</option>
					<c:forEach var="result" items="${categoryListP }" varStatus="status">
					<option value="${result.acid },${result.gubun}" >${result.title }</option>
					</c:forEach>
				</select>
				
				<a href="javascript:moveAddressBooks();" class="button white medium">
					<img src="../common/images/bb01.gif" border="0"> <spring:message code="mail.move" text="이동"/>
				</a>
				
				<a href="javascript:copyAddressBooks();" class="button white medium">
					<img src="../common/images/bb01.gif" border="0"> <spring:message code="addr.copy" text="복사"/>
				</a>
			</td>
			<td width="*" class="DocuNo" align="right" style="padding-right:5px; ">
			<form:form commandName="search" onsubmit="return false;">
				<form:hidden path="docId" />
				<form:hidden path="categoryId" />
				<form:hidden path="useNewWin" />
				<form:hidden path="useAjaxCall" />
				<form:hidden path="qsearch" />
				<form:hidden path="useLayerPopup" />
				
                <input type="checkbox" id="autosearch" onclick="enableAutosubmit(this.checked)">
				<label for="autosearch" style="cursor:pointer;"><spring:message code="Enable.Autosearch" text="자동검색"/></label>
                
				<form:select path="searchKey">
					<option value="name" <%= setSelectedOption("name",searchKey) %> selected><spring:message code="t.name" /></option>
					<option value="companyname" <%= setSelectedOption("companyname",searchKey) %>><spring:message code="t.companyName" /></option>
					<option value="email" <%= setSelectedOption("email",searchKey) %>><spring:message code="t.email" /></option>
					<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option>
				</form:select>

				<form:input path="searchValue" onkeypress="doSearch(event)" onfocus="startDoSearch()" onblur="stopDoSearch()" style="width:100px;"/> 
				
				

				<!-- <img id="submitButton" src="/common/images/btn_search.gif" align="absmiddle" onclick="gridReload()" alt="검색" /> -->
				
				<span id="submitButton">
					<a onclick="gridReload();" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code="mail.seach" text="검색"/>
					</a>
				</span>
				<span id="resetSearch" style="display:none;">
					<a onclick="resetSearch();" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code="addr.del.search" text="검색제거"/> 
					</a>
				</span>
			</form:form>
			</td>
		</tr>
	</table>
	<!-- List Button -->

	<div class="space"></div>
	<div class="hr_line">&nbsp;</div>
	
	<form:form commandName="addressBookWebForm" onsubmit="return false;">
		<form:hidden path="acid" />
		<form:hidden path="addressBook.securityLevel.securityId" value="1" />
		
		<table width="100%" id="qdoc" style="display:none;">
			<colgroup>
				<col width="70">
				<col width="100">
				<col width="70">
				<col width="120">
				<col width="70">
				<col width="100">
				<col width="70">
				<col width="120">
				<col width="100">
			</colgroup>
			<tr>
				<td class="td_le10">
					<spring:message code='addr.division' text='구분'/> <span class="readme"><b>*</b></span>
				</td>
				<td class="td_le2" nowrap>
					<form:radiobutton path="addressBook.gubuns" value="S" checked="true" onclick="selectAcid('S')"/><spring:message code='addr.share' text='공유'/>
					<form:radiobutton path="addressBook.gubuns" value="P" onclick="selectAcid('P')"/><spring:message code='addr.personal' text='개인'/>
				</td>
				<td class="td_le10">
					<spring:message code='addr.category' text='분류'/> <span class="readme"><b>*</b></span>
				</td>
				<td class="td_le2" nowrap>
					<span id="gubun_s" style="width:200px;">
						<form:select path="addressBook.addressBookCategory.acid" id="gubun_sv">
							<form:options items="${categoryListS }" itemValue="acid" itemLabel="title" />
						</form:select>
					</span>
					<span id="gubun_p" style="display:none; width:200px;">
						<form:select path="addressBook.addressBookCategory.acid" id="gubun_pv">
							<form:options items="${categoryListP }" itemValue="acid" itemLabel="title" />
						</form:select>
					</span>
				</td>
				<td class="td_le10">
					<spring:message code='addr.name' text='이름'/> <span class="readme"><b>*</b></span>
				</td>
				<td class="td_le2" nowrap>
					<form:input path="addressBook.name" class="w100ps" maxlength="25" />
				</td>
				<td class="td_le10">
					E-mail <span class="readme"><b>*</b></span>
				</td>
				<td class="td_le2" nowrap>
					<form:input path="addressBook.email" class="w100ps" maxlength="50" style="ime-mode:disabled" onkeyup="crImeMode(this)" onblur="crImeMode(this)" />
				</td>
				<td class="td_le2" rowspan="2" valign="middle" style="text-align: center;">
					<a href="#" onclick="javascript:qdocsave();" class="button white medium">
						<img src="../common/images/bb01.gif" border="0"> 
						<spring:message code='t.save' text='저장'/>
					</a>
				</td>
			</tr>
			<tr>
				<td class="td_le10">
					<spring:message code='addr.cellphone' text='휴대폰'/>
				</td>
				<td class="td_le2">
					<form:input path="addressBook.cellTel" class="w90p" maxlength="30" onkeyup="telNumberMode(this)" onblur="telNumberMode(this)" />
				</td>
				<td class="td_le10">
					<spring:message code='addr.company' text='회사'/>
				</td>
				<td class="td_le2">
					<form:input path="addressBook.companyName" class="w90p" maxlength="50" />
				</td>
				<td class="td_le10">
					<spring:message code='addr.dept.position' text='부서 / 직위'/>
				</td>
				<td class="td_le2">
					<form:input path="addressBook.dpName" style="width:33%;" maxlength="25" /> / 
					<form:input path="addressBook.GradeName" style="width:33%;" maxlength="25" /> 
				</td>	
				<td class="td_le10">
					<spring:message code='addr.phone' text='전화'/>
				</td>
				<td class="td_le2">
					<form:input path="addressBook.tel" class="w90p" onkeyup="telNumberMode(this)" onblur="telNumberMode(this)" maxlength="30" />
					<span style="display:none;">
						<form:input path="addressBook.fax" class="w90p" onkeyup="telNumberMode(this)" onblur="telNumberMode(this)" maxlength="30" />
					</span>
				</td>
			</tr>
		</table>
	</form:form>
	

	<div style="width:100%; height:28px; border:1px; padding-top:6px;" class=PageNo1>
		<span style="border:1px solid #E8E8E8; padding:3px; background-color:#F4F4F4;">
			<img src="/common/images/vwicn008.gif" width="13" height="11"> 
			<spring:message code="addr.search.quick" text="빠른검색"/>
		</span> 
		<img src="/common/images/blue_arrow.gif" width="13" height="11"> 
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN1 %>');" title="ㄱ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㄱ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN2 %>');" title="ㄴ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㄴ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN3 %>');" title="ㄷ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㄷ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN4 %>');" title="ㄹ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㄹ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN5 %>');" title="ㅁ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅁ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN6 %>');" title="ㅂ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅂ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN7 %>');" title="ㅅ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅅ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN8 %>');" title="ㅇ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅇ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN9 %>');" title="ㅈ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅈ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN10 %>');" title="ㅈ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅊ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN12 %>');" title="ㅈ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅌ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN13 %>');" title="ㅍ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅍ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEHAN14 %>');" title="ㅎ<spring:message code="emp.search.include" text="을 포함하는 사람 검색"/>">ㅎ</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG1 %>');" title="<spring:message code="emp.search.AtoF" text="A에서 F사이를 포함하는 사람 검색"/>" class="en_qbtn">A~F</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG2 %>');" title="<spring:message code="emp.search.GtoJ" text="G에서 J사이를 포함하는 사람 검색"/>" class="en_qbtn">G~J</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG3 %>');" title="<spring:message code="emp.search.KtoO" text="K에서 O사이를 포함하는 사람 검색"/>" class="en_qbtn">K~O</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG4 %>');" title="<spring:message code="emp.search.PtoT" text="P에서 T사이를 포함하는 사람 검색"/>" class="en_qbtn">P~T</a>
		<a href="javascript:q_search('<%=AddrSearchItem.SEARCHTYPEENG5 %>');" title="<spring:message code="emp.search.UtoZ" text="U에서 Z사이를 포함하는 사람 검색"/>" class="en_qbtn">U~Z</a>
	</div>

	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<span id="errorDisplayer" style="color:red"></span>

</body>
</html>

