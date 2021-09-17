<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title><spring:message code='main.common.code' text='공통코드' /></title>
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
	<script src="/common/jquery/js/jquery-1.6.4.min.js"  type="text/javascript"></script>
	<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js"  type="text/javascript"></script>
	<script src="/common/jquery/plugins/modaldialogs.js"  type="text/javascript"></script>
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.jqgrid.css"  />
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/ui.multiselect.css"  />
	
	<script src="/common/jquery/js/i18n/grid.locale-ko.js"  type="text/javascript"></script>
	<script src="/common/jquery/plugins/jquery.jqGrid.min.js" type="text/javascript"></script>
	<script src="/common/jquery/plugins/ui.multiselect.js" type="text/javascript"></script>
	
	<script type="text/javascript">
		$.jgrid.no_legacy_api = true;
		$.jgrid.useJSON = true;
	</script>
	<link rel="stylesheet" href="/common/css/style.css">
	<script src="/common/scripts/common.js"></script>

	<script type="text/javascript">
	var catego1 = {};
	
	function refreshCategorySelect() {
		var select = jQuery("select#list09");
		jQuery.ajax({'url': '/configuration/commoncode_select_json.htm',
			'dataType': 'json', 'async': false, 'global': false,
			'success': function (j) {
				catego1 = j;
				select.html(createCategorySelect(true));
				select.change();
			}
		});
	}
	
	function createCategorySelect(flag) {
		var options = '';
		if (flag) options += '<option value=""><spring:message code="t.all" text="전체" /></opton>';
		for(var i in catego1) {
			options += '<option value="' + i + '"';
			if (i == jQuery("select#list09").val()) options += ' selected="selected"';
			options += '>' + catego1[i] + '</option>';
		}
		return options;
	}
	
	jQuery(document).ready(function() {		
		refreshCategorySelect();

		jQuery("select#list09").change(function(){
			jQuery("#list10").jqGrid('setGridParam',{url:"/configuration/commoncode_list_json.htm?categoNo=2&id="+jQuery(this).val(),page:1});
			jQuery("#list10").jqGrid('setCaption', "<spring:message code='main.code.class' text='코드분류' />: " + jQuery(this).find("option:selected").text())
			.trigger('reloadGrid');
		});

		jQuery("#list10").jqGrid({
		   	url:'/configuration/commoncode_list_json.htm?categoNo=2&id=' + jQuery("select#list09").val(),
			datatype: "json",
		   	colNames:[
		   	          '<spring:message code="main.parent.code" text="부모코드" />',
		   	          '<spring:message code="main.code" text="코드" />',
		   	          '<spring:message code="main.code.name" text="코드명" />',
		   	          '<spring:message code="main.use" text="사용여부" />',
		   	          '<spring:message code="t.sortOrder" text="정렬순서" />'
			],
		   	colModel:[
				{name:'pid',index:'pid', width:0, editable: true, edittype: 'select', editoptions:{value:catego1}, hidden: true, editrules: {edithidden:true}},
		   		{name:'code',index:'code', width:20, align:'center', editable: true},
		   		{name:'codeName',index:'codeName', width:50, editable: true},
		   		{name:'enable',index:'enable', width:15, align:'center', editable: true, edittype: 'select', editoptions:{value:{'true': 'Ｏ', 'false':'Ｘ'}}, hidden: true, editrules: {edithidden:true}},
		   		{name:'orderNo',index:'orderNo', width:20, align:'center', editable: true}
		   	],
		   	rowNum: 999,
		   	rowList: [],				// disable page size dropdown
		   	pager: '#pager10',
		   	pgbuttons: false,		// disable page control like next, back button
		   	pgtext: null,			// disable pager text like 'Page 0 of 10'
		    viewrecords: true,		// disable current view record text like 'View 1-10 of 100' 
			prmNames: {search: null, nd: null, rows: null, page: null, sort: "sortColumn", order: "sortType"},  
		   	sortname: 'orderNo',
		    sortorder: "asc",
			multiselect: false,
			caption: "<spring:message code='main.code.class' text='코드분류' />",
			hidegrid: false,
			ondblClickRow: function(rowid) {
				jQuery(this).jqGrid('editGridRow', rowid, {
					closeOnEscape: true,
					closeAfterEdit: true,
					afterShowForm: function(formid) { jQuery(formid).find('select#pid').html(createCategorySelect()); },
				   	url:"/configuration/commoncode_saveOrUpdate.htm"
				});
			},
			onSelectRow: function(ids) {
				if (ids != null) {
					var rowObject = jQuery(this).jqGrid('getRowData', ids);
					jQuery("input[name=categoNo2]").val(ids);
					jQuery("#list10_d").jqGrid('setGridParam',{url:"/configuration/commoncode_list_json.htm?categoNo=3&id="+ids,page:1});
					jQuery("#list10_d").jqGrid('setCaption',"<spring:message code='main.common.code' text='공통코드' />: " + rowObject.codeName)
					.trigger('reloadGrid');
				}
			}
		});
		jQuery("#list10").jqGrid('navGrid','#pager10',
			{edit: true, add: true, del: true, search: false, refresh: true, view: false}, 
			{	// edit options
				closeOnEscape: true,
				closeAfterEdit: true,
				afterShowForm: function(formid) { jQuery(formid).find('select#pid').html(createCategorySelect()); },
			   	url:"/configuration/commoncode_saveOrUpdate.htm"
			}, {// add options
				closeOnEscape: true,
				closeAfterAdd: true,
				closeAfterEdit: true,
				afterShowForm: function(formid) { jQuery(formid).find('select#pid').html(createCategorySelect()); },
			   	url:"/configuration/commoncode_saveOrUpdate.htm"
			}, {// del options
				closeOnEscape: true,
			   	url:"/configuration/commoncode_delete.htm"
			}, {// search options
			}, {// view options
				closeOnEscape: true
			}
		);
		
		jQuery("#list10_d").jqGrid({
		   	url:'',
			datatype: "json",
			colNames:[
		   	          '<spring:message code="main.parent.code" text="부모코드" />',
		   	          '<spring:message code="main.code" text="코드" />',
		   	          '<spring:message code="main.code.name" text="코드명" />',
		   	          '<spring:message code="main.use" text="사용여부" />',
		   	          '<spring:message code="t.sortOrder" text="정렬순서" />'
			],
		   	colModel:[
				{name:'pid',index:'pid', width:0, editable: true, hidden: true, editrules: {edithidden:true}},
		   		{name:'code',index:'code', width:20, align:'center', editable: true},
		   		{name:'codeName',index:'codeName', width:50, editable: true},
		   		{name:'enable',index:'enable', width:15, align:'center', editable: true, edittype: 'select', editoptions:{value:{'true': 'Ｏ', 'false':'Ｘ'}}, hidden: true, editrules: {edithidden:true}},
		   		{name:'orderNo',index:'orderNo', width:15, align:'center', editable: true}
		   	],
		   	rowNum: 999,
		   	rowList: [],				// disable page size dropdown
		   	pager: '#pager10_d',
		   	pgbuttons: false,		// disable page control like next, back button
		   	pgtext: null,			// disable pager text like 'Page 0 of 10'
		    viewrecords: true,		// disable current view record text like 'View 1-10 of 100' 
			prmNames: {search: null, nd: null, rows: null, page: null, sort: "sortColumn", order: "sortType"},  
		   	sortname: 'orderNo',
		    sortorder: "asc",
			multiselect: false,
			caption:"<spring:message code='main.common.code' text='공통코드' />",
			hidegrid: false,
			ondblClickRow: function(rowid) {
				jQuery(this).jqGrid('editGridRow', rowid, {
					closeOnEscape: true,
					closeAfterEdit: true,
					afterShowForm: function(formid) {
						jQuery(formid).find('input#pid').val(jQuery("input[name=categoNo2]").val()).attr('readonly','readonly');
					},
				   	url:"/configuration/commoncode_saveOrUpdate.htm"
				});
			},
			onSelectRow: function(ids) {
				if (ids != null) {
					var rowObject = jQuery(this).jqGrid('getRowData', ids);
					jQuery("input[name=categoNo3]").val(ids);
					jQuery("#list10_dt").jqGrid('setGridParam',{url:"/configuration/commoncode_list_json.htm?categoNo=4&id="+ids,page:1});
					jQuery("#list10_dt").jqGrid('setCaption',"<spring:message code='main.common.code' text='공통코드' />: " + rowObject.codeName)
					.trigger('reloadGrid');
				}
			}
		}).navGrid('#pager10_d',
			{edit: true, add: true, del: true, search: false, refresh: true, view: false}, 
			{	// edit options
				closeOnEscape: true,
				closeAfterEdit: true,
				afterShowForm: function(formid) {
					jQuery(formid).find('input#pid').val(jQuery("input[name=categoNo2]").val()).attr('readonly','readonly'); 
				},
			   	url:"/configuration/commoncode_saveOrUpdate.htm"
			}, {// add options
				closeOnEscape: true,
				closeAfterAdd: true,
				closeAfterEdit: true,
				afterShowForm: function(formid) {
					jQuery(formid).find('input#pid').val(jQuery("input[name=categoNo2]").val()).attr('readonly','readonly'); 
				},
			   	url:"/configuration/commoncode_saveOrUpdate.htm"
			}, {// del options
				closeOnEscape: true,
			   	url:"/configuration/commoncode_delete.htm"
			}, {// search options
			}, {// view options
				closeOnEscape: true
			}
		);
		
		jQuery("#list10_dt").jqGrid({
		   	url:'',
			datatype: "json",
			colNames:[
		   	          '<spring:message code="main.parent.code" text="부모코드" />',
		   	          '<spring:message code="main.code" text="코드" />',
		   	          '<spring:message code="main.code.name" text="코드명" />',
		   	          '<spring:message code="main.use" text="사용여부" />',
		   	          '<spring:message code="t.sortOrder" text="정렬순서" />'
			],
		   	colModel:[
				{name:'pid',index:'pid', width:0, editable: true, hidden: true, editrules: {edithidden:true}},
		   		{name:'code',index:'code', width:20, align:'center', editable: true},
		   		{name:'codeName',index:'codeName', width:50, editable: true},
		   		{name:'enable',index:'enable', width:15, align:'center', editable: true, edittype: 'select', editoptions:{value:{'true': 'Ｏ', 'false':'Ｘ'}}, hidden: true, editrules: {edithidden:true}},
		   		{name:'orderNo',index:'orderNo', width:15, align:'center', editable: true}
		   	],
		   	rowNum: 999,
		   	rowList: [],				// disable page size dropdown
		   	pager: '#pager10_dt',
		   	pgbuttons: false,		// disable page control like next, back button
		   	pgtext: null,			// disable pager text like 'Page 0 of 10'
		    viewrecords: true,		// disable current view record text like 'View 1-10 of 100' 
			prmNames: {search: null, nd: null, rows: null, page: null, sort: "sortColumn", order: "sortType"},  
		   	sortname: 'orderNo',
		    sortorder: "asc",
			multiselect: false,
			caption:"<spring:message code='main.common.code' text='공통코드' />",
			hidegrid: false,
			ondblClickRow: function(rowid) {
				jQuery(this).jqGrid('editGridRow', rowid, {
					closeOnEscape: true,
					closeAfterEdit: true,
					afterShowForm: function(formid) {
						jQuery(formid).find('input#pid').val(jQuery("input[name=categoNo3]").val()).attr('readonly','readonly');
					},
				   	url:"/configuration/commoncode_saveOrUpdate.htm"
				});
			},
		}).navGrid('#pager10_dt',
			{edit: true, add: true, del: true, search: false, refresh: true, view: false}, 
			{	// edit options
				closeOnEscape: true,
				closeAfterEdit: true,
				afterShowForm: function(formid) {
					jQuery(formid).find('input#pid').val(jQuery("input[name=categoNo3]").val()).attr('readonly','readonly'); 
				},
			   	url:"/configuration/commoncode_saveOrUpdate.htm"
			}, {// add options
				closeOnEscape: true,
				closeAfterAdd: true,
				closeAfterEdit: true,
				afterShowForm: function(formid) {
					jQuery(formid).find('input#pid').val(jQuery("input[name=categoNo3]").val()).attr('readonly','readonly'); 
				},
			   	url:"/configuration/commoncode_saveOrUpdate.htm"
			}, {// del options
				closeOnEscape: true,
			   	url:"/configuration/commoncode_delete.htm"
			}, {// search options
			}, {// view options
				closeOnEscape: true
			}
		);


		$("#list10").setGridWidth(340);
		$("#list10").setGridHeight($(window).height()-155);

		$("#list10_d").setGridWidth(340);
		$("#list10_d").setGridHeight($(window).height()-155);

		$("#list10_dt").setGridWidth(340);
		$("#list10_dt").setGridHeight($(window).height()-155);
		
		$(window).bind('resize', function() {
			$("#list10").setGridWidth(340);
			$("#list10").setGridHeight($(window).height()-155);
			
			$("#list10_d").setGridWidth(340);
			$("#list10_d").setGridHeight($(window).height()-155);

			$("#list10_dt").setGridWidth(340);
			$("#list10_dt").setGridHeight($(window).height()-155);
		}).trigger('resize');
		
		setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
	});
	
	function openCommonCodeCategory() {
		var url = '/configuration/commoncode_category_list.htm';
		parent.dhtmlwindow.open(
				url, "iframe", url, "<spring:message code='main.common.code' text='공통코드' /> <spring:message code='main.big.class' text='대분류' />", 
				"width=600px,height=400px,resize=1,scrolling=1,center=1", "recal"
		);
	}
	</script>
<style>
.ui-jqgrid .ui-jqgrid-htable{min-width: 100% !important;}
</style>
</head>
<body>
<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="60%" style="padding-left:5px; padding-top:5px; ">
			<span class="ltitle">
				<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> 
				<spring:message code='main.common.code' text='공통코드' /> 
			</span>
		</td>
		<td width="40%" align="right"></td>
	</tr>
</table>
<!-- List Title -->

<table border="0" cellpadding="0" cellspacing="0" frame="void" rules="none" style="table-layout: fixed;">
	<colgroup>
		<col width="340">
		<col width="340">
		<col width="340">
	</colgroup>
	<tr style="height: 32px;">
		<td align="right">
			<label><spring:message code='main.common.code' text='공통코드' /> <spring:message code='main.class' text='분류' /></label> :
			<select id="list09">
				<option value=""><spring:message code='t.all' text='전체' /></option>
			</select>
			<button onclick="openCommonCodeCategory()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code='main.class.add' text='분류추가' /> </button>
		</td>
		<td align="right">
			<input type="hidden" name="categoNo2" value="" />
		</td>
		<td align="right">
			<input type="hidden" name="categoNo3" value="" />
		</td>
	</tr>
	<tr>
		<td align="center" style="padding: 0px 6px;">
			<table id="list10"></table>
			<div id="pager10"></div>
		</td>
		<td align="center">
			<table id="list10_d"></table>
			<div id="pager10_d"></div>
		</td>
		<td align="center" style="padding: 0px 6px;">
			<table id="list10_dt"></table>
			<div id="pager10_dt"></div>
		</td>
	</tr>
</table>
	
</body>
</html>