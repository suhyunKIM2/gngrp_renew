<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page errorPage="../error.jsp" %>
<%
	String gubun = (String)request.getAttribute("gubun");
	String rootJSON = "";
	String gubunNm = "";
	if ("S".equals(gubun)) {
		gubunNm = "공용";
		rootJSON = "{ 'title': '공용', 'isFolder': true, 'isLazy': true, 'key': 'S', 'type': 'department', 'datas': '공용:S' }";
	} else if ("P".equals(gubun)) {
		gubunNm = "개인";
		rootJSON = "{ 'title': '개인', 'isFolder': true, 'isLazy': true, 'key': 'P', 'type': 'department', 'datas': '개인:P' }";
	}
%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="addr.category.insert.edit" text="분류 등록/수정"/></title>
<%@ include file="../common/include.mata.jsp" %>
<%@ include file="../common/include.jquery.jsp" %>
<%@ include file="../common/include.common.jsp" %>

<!-- dynatree load -->
<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'> 
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 

<style type="text/css">
.number { text-align: right; ime-mode: disabled; }
#objTree { padding-top: 3px; padding-bottom: 3px; }
ul.dynatree-container { padding-top: 0px; padding-bottom: 0px; }
.td_le2{height:60px;}
</style>
<script language="javascript">
var openNode = null;
var tree = null;

$(document).ready(function() {
	$("#objTree").dynatree({
		children: [ <%=rootJSON %> ],		// 초기(루트) 노드를 생성합니다.
    	onSelect: function(select, node) {	// 클릭되었을 때 호출합니다.
    	},
    	onDblClick: function(node, e) {		// 더블 클릭되었을 때 호출합니다.
    		openNode = node;
			resetForm();
    		if (node.data.key.length == 1) {
    		} else if (node.data.isFolder) {
				var category = node.data.category;
				var pacName = category.pacName;
				if (pacName == "") {
					switch(category.gubun) {
						case 'S': pacName = "<spring:message code='appr.out.putblic' text='공용' />"; break;
						case 'P': pacName = "<spring:message code='appr.personal' text='개인' />"; break;
					}
				}
				$('input[name=pacid]').val(category.pacid);
				$('input[name=pacName]').val(pacName);
				$('input[name=acid]').val(category.acid);
				$('input[name=title]').val(category.title);
				$('input[name=sortNum]').val(category.sortNum);
				$('input[name=depthNum]').val(category.depthNum);
				$('input[name=gubun]').val(category.gubun);
				$('#saveOrUpdateText').text("<spring:message code="t.save" text="저장" />");
				$('#delete').show();
    		}
    	},
    	onLazyRead: function(node) {		// 처음으로 확장 될 때 호출됩니다.
    		if (node.data.key.length == 1) {
				node.appendAjax({
					url: "/addressbook/addressbook_category_root_json.htm",
					data: { gubun: node.data.key, depthNum: 0, order: 1 }
				});
    		} else {
				node.appendAjax({
					url: "/addressbook/addressbook_category_child_json.htm",
					data: { pacid: node.data.key, order: 1 }
				});
    		}
		}
    });
    
    tree = $("#objTree").dynatree("getTree");

	$("#objTree").css("height", $(window).height()-100);
	$(window).bind('resize', function() {
		$("#objTree").css("height", $(window).height()-100);
	}).trigger('resize');
});

function openCatagorySelectorModal() {
	var winwidth = "280";
	var winheight = "380";
	var winleft = (screen.width - winwidth) / 2;
	var wintop = (screen.height - winheight) / 2;
	var url = "/addressbook/category_selector.htm?gubun=${gubun }";
	var opt = "status:no;scroll=no;dialogLeft:"+winleft+";dialogTop:"+wintop+";help:no;dialogWidth:"+winwidth+"px;dialogHeight:"+winheight+"px"
	var returnvalue = self.showModalDialog(url, '', opt);
	
	if (returnvalue == undefined) returnvalue = window.returnValue;
	if (returnvalue != null) {
		category = returnvalue;
		$('input[name=pacid]').val(category.acid);
		$('input[name=pacName]').val(category.title);
		$('input[name=gubun]').val(category.gubun);
	}
}

function openCatagorySelector() {
	var url = "/addressbook/category_selector.htm?gubun=${gubun }";
		window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_140916_1514", "iframe", url, "<spring:message code='t.pcategory' text='상위분류'/>", 
			"width=280px,height=380px,resize=0,scrolling=1,center=1", "recal"
		);
}

function setCatagorySelector(returnvalue) {
	if (returnvalue == undefined) returnvalue = window.returnValue;
	if (returnvalue != null) {
		category = returnvalue;
		$('input[name=pacid]').val(category.acid);
		$('input[name=pacName]').val(category.title);
		$('input[name=gubun]').val(category.gubun);
	}
}
function validate() {
	var num_regx = /^[0-9]*$/;
	var title = $('input[name=title]');
	var sortNum = $('input[name=sortNum]');
	
	if (title.val() == "") {
		alert("<spring:message code='v.classification.name.required' text='분류이름은 필수입력란 입니다.' />\n<spring:message code='sch.please.enter' text='입력해 주세요.' />");
		title.focus();
		return false;
	}
	if (sortNum.val() == "") {
		alert("<spring:message code='v.sort.order.required' text='정렬순서는 필수입력란 입니다.' />\n<spring:message code='sch.please.enter' text='입력해 주세요.' />");
		sortNum.focus();
		return false;
	}
	if (!num_regx.test(sortNum.val())) {
		alert("<spring:message code='v.sort.only.number' text='정렬순서는 숫자만 입력해주세요.' />");
		sortNum.select();
		return false;
	}
	return true;
}

function resetForm() {
	$('#saveOrUpdateText').text("<spring:message code="t.insert" text="등록" />");
	$('#delete').hide();
	$('form[name=submitForm]')[0].reset();
}

function saveOrUpdate() {
	if (!validate()) return;
    $.ajax({ 
    	url: '/addressbook/addressBookCategorySaveOrUpdate.htm',
    	type: 'post',
    	dataType: 'json',
    	async: true,
    	data: $("#submitForm").serialize(),
    	beforeSend: function() {},
    	complete: function(){},
    	success: function(data, status, xhr) {
    		resetForm();

    		//var openParentKey = null;  
    		//try { openParentKey = openNode.getParent().data.key; } catch(ex) {} 
    		//var opNode = tree.getNodeByKey(openParentKey); 
    		//if (opNode != null && data.parentKey != openParentKey) { try { opNode.reloadChildren(); } catch(ex) {} } 
    		
			var pNode = tree.getNodeByKey(data.parentKey);
    		if (pNode != null) {
    			if (pNode.hasChildren() == false) {
    				try { pNode.getParent().reloadChildren(); } catch(ex) {}
    			} else {
        			pNode.reloadChildren();
    			} 
    		}
    	},
    	error: function(xhr, status, error) {}
    });
}

function categoryDelete() {
    $.ajax({ type: 'post' ,dataType: 'json' ,async: true
        ,url: '/addressbook/addressBookCategoryDelete.htm'
        ,data: $("#submitForm").serialize()
        ,beforeSend: function() {} 
        ,complete: function(){}
        ,success: function(data, status, xhr) {
        	var msg = data.msg || null;
        	if (msg != null) {
        		alert(msg);
        	} else {
				var pNode = tree.getNodeByKey(data.parentKey);
	    		resetForm();
	    		if (pNode != null) pNode.reloadChildren();
        	}
        }
        ,error: function(xhr, status, error) {}
    });
}

</script>
</head>
<body>
	<!-- 타이틀 시작 -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="60%" style="padding-left:5px; padding-top:5px;">
				<span class="ltitle">
					<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />
					<spring:message code="main.Business.Support" text="업무지원" /> &gt;
					<spring:message code="none" text="명함관리" /> &gt;
					<%=gubunNm %><spring:message code="none" text="분류 관리" />
				</span>
			</td>
			<td width="40%" align="right"></td>
		</tr>
	</table>
	<!-- 타이틀 끝 -->

	<table cellpadding="6" cellspacing="0" style="margin:10px;">
		<tr>
			<td width="20%" valign="top" style="vertical-align: top;">
				<div class="hr_line">&nbsp;</div>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout: fixed;">
					<tr>
						<td class="td_le1"><spring:message code="addr.card.classfication" text="명함분류" /></td>
					</tr>
					<tr>
						<td class="td_le2" style="padding: 0;">
							<div id="objTree" style="overflow: auto; height: 350px;"></div>
						</td>
					</tr>
				</table>
			</td>
			<td width="70%" valign="top" style="vertical-align: top;margin-right:20px;padding-top: 3px;">
				<div class="space"></div>
				<div class="hr_line">&nbsp;</div>
				<form name="submitForm" id="submitForm" method="post">
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr style="display: none;">
							<td class="td_le1"><spring:message code="t.pcategory" text="상위분류" />ID</td>
							<td class="td_le2">
								<input type="text" name="pacid" readonly="readonly" class="ui-state-disabled number">
							</td>
						</tr>
						<tr>
							<td class="td_le1"><spring:message code="t.pcategory" text="상위분류" /></td>
							<td class="td_le2">
								<input type="text" name="pacName" readonly="readonly" onclick="openCatagorySelector()" style="cursor: pointer;">
								<span onclick="openCatagorySelector()" class="button white medium">
								<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색" /></span>
							</td>
						</tr>
						<tr style="display: none;">
							<td class="td_le1"><spring:message code="addr.category" text="분류" />ID</td>
							<td class="td_le2">
								<input type="text" name="acid" readonly="readonly" class="ui-state-disabled number">
							</td>
						</tr>
						<tr>
							<td class="td_le1"><spring:message code="addr.category.name" text="분류명" /></td>
							<td class="td_le2">
								<input type="text" name="title" maxlength="60">
							</td>
						</tr>
						<tr>
							<td class="td_le1"><spring:message code="t.sortOrder" text="정렬순서" /></td>
							<td class="td_le2">
								<input type="text" name="sortNum" value="0" size="3" maxlength="3" class="number">
							</td>
						</tr>
						<tr style="display: none;">
							<td class="td_le1"><spring:message code="addr.classfication.depth" text="분류깊이" /></td>
							<td class="td_le2">
								<input type="text" name="depthNum" readonly="readonly" class="ui-state-disabled number" value="0">
							</td>
						</tr>
						<tr style="display: none;">
							<td class="td_le1"><spring:message code="addr.classfication.division" text="분류구분" /></td>
							<td class="td_le2">
								<input type="text" name="gubun" readonly="readonly" class="ui-state-disabled number" value="${gubun }">
							</td>
						</tr>
					</table>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
					<tr height="35">
						
						<td width="*"  align=left>
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td width="*" align="right">
									<div onclick="saveOrUpdate()" class="button gray medium"><img src="../common/images/bb02.gif" border="0">
									<span id="saveOrUpdateText" ><spring:message code="t.insert" text="등록" /></span></div>
									<div onclick="categoryDelete()" id="delete" style="display: none;" class="button white medium"><img src="../common/images/bb02.gif" border="0">
									<spring:message code="t.delete" text="삭제" /></div>
									<div onclick="resetForm()" class="button white medium"><img src="/common/images/bb02.gif" border="0">
									<spring:message code="t.cancel" text="취소" /></div>
								</td>
							</tr>
							</table>
						</td>
					</tr>
				</table>
				</form>
			</td>
		</tr>
	</table>
	
</body>
</html>