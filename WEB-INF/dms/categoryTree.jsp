<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page errorPage="../error.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title><c:out value="${caption }" /></title>
<%@ include file="../common/include.mata.jsp"%>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>
<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'> 
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script>
<script src='/common/jquery/js/jquery.cookie.js' type="text/javascript"></script> 
<script type="text/javascript">
	var WINDOW_POPUP 		= 0;        //팝업형 대화상자
	var WINDOW_MODALDIALOG  = 1;		//Modal 대화상자
	var WINDOW_NORMAL 		= 2;		//일반선택
	var WINDOW_LISTSUB		= 3;		//리스트 선택용
	var isAdmin = <c:out value="${isAdmin}"/>;
	var iOpenMode = "${iOpenMode}";
	var t_node;
	var categoryObject = [<c:forEach var="item" items="${categoryList }" varStatus="status">
	<c:if test="${status.first == false}">,</c:if>
	{
		"title": "<c:out value="${item.catName }"/>",
		"isFolder": true,
		"isLazy": true,
		"key": "<c:out value="${item.id.catId }"/>",
		"datas": "<c:out value="${item.catName }"/>:<c:out value="${item.id.catId }"/>:<c:out value="${item.catName }"/>"
	}
	</c:forEach>];

	window.code = '_CHILDWINDOW_DMS1001';

	function OnCancel() {
		parent.closeDhtmlModalWindow();
	}

	function OnOK(node) {
		var nekDatas = (node)? node.data.datas: $("#treeCtnr").dynatree("getActiveNode").data.datas;
		var pNekDatas = (node)? node.parent.data.datas: $("#treeCtnr").dynatree("getActiveNode").parent.data.datas;
		
		//최상위 루트는 선택 제외
		if (!isAdmin && nekDatas.indexOf("00000000000000") > -1) return;
		
		if (pNekDatas === undefined) pNekDatas = nekDatas
		
		if(nekDatas != null && nekDatas != "")
		{
			var nek_datas = nekDatas.split(":");
			var p_nek_datas = pNekDatas.split(":");
			var titleText = nek_datas[0];
			var target = null;
			if(<c:out value="${htmlWinObj}"/> != null){
				if(iOpenMode == WINDOW_NORMAL){
					target = <c:out value="${htmlWinObj}"/>;
				}else{
					if(null != <c:out value="${htmlWinObj}"/>.<c:out value="${containerName}"/>){
						target =  <c:out value="${htmlWinObj}"/>.<c:out value="${containerName}"/>;
					}
				}
			}
			if(WINDOW_MODALDIALOG == iOpenMode){
				var arrReturnValue = new Array(3);
				arrReturnValue[0] = nek_datas[0];
				arrReturnValue[1] = nek_datas[1];
				arrReturnValue[2] = titleText;
				arrReturnValue[3] = nek_datas[2];
				parent.setCategoryInfo(arrReturnValue);
				parent.closeDhtmlModalWindow();
			}else if(iOpenMode == WINDOW_POPUP){
				if (target != null)
				{
		        	if (target.catid != null) target.catid.value = nek_datas[1];
		        	if (target.catname != null) target.catname.value = titleText;
		        	if (target.catfullname != null) target.catfullname.value = nek_datas[0];
				}
				window.close();
			}else if(iOpenMode == WINDOW_NORMAL){
				var listURL = "./categoryForm.htm";
				listURL += "?pCategoryId="+p_nek_datas[1];
				listURL += "&catId="+nek_datas[1];
				listURL += "&cmd=${cmd}";
				listURL += "&cateType=${cateType}";
				listURL += "&cateGubun=${cateGubun}";
				listURL += "&pcatname="+encodeURI(titleText);
				listURL += "&pCatFullName="+encodeURI(p_nek_datas[0]);
				listURL += "&isSelect=true";
				
				if (target == null) target = parent.list_frame;
				
				if (target !=null) {
					target.location.href = listURL;
				} else {
					parent.list_frame.location.href = listURL;
				}
				

// 				var listURL = "./categoryList.htm?pCategoryId=" + nek_datas[1] + "&cmd=${cmd}&cateType=${cateType}";
// 				listURL += "&pcatname=" + encodeURI(titleText);
// 				listURL += "&pcatfullname=" + encodeURI(nek_datas[0]);
// 				if (target == null) target = parent.list_frame;
// 				if (target !=null) target.location.href = listURL;
// 				else parent.list_frame.location.href = listURL;
				
			}else if(iOpenMode == WINDOW_LISTSUB){
				if (g_objNodeSelected.id == "" || g_objNodeSelected.id == null) return;
				var listURL = "./list.jsp?mode=list&catId=" + nek_datas[1];
				listURL += "&catname=" + encodeURI(titleText);
				listURL += "&catfullname=" + encodeURI(nek_datas[0]);
				if (parent !=null && parent.document.all.includesub != null)
				{
					var includeSub = parent.document.all.includesub.checked;
					if (includeSub) listURL += "&includesub=1";
				}
				if(target == null) target = parent.parent.main;
				if (target != null) target.location.href = listURL;
			}
		}
	}
	
	$(document).ready(function() { 
	    $("#treeCtnr").dynatree({
	        children: categoryObject,   						// 초기(루트) 노드를 생성합니다.
	    	onSelect: function(select, node) {	// 클릭되었을 때 호출합니다.
	    		t_node = node;
	    		if (iOpenMode == WINDOW_NORMAL.toString()) OnOK(node); 
	    	},
	    	onLazyRead: function(node) {		// 처음으로 확장 될 때 호출됩니다.
				node.appendAjax({
					url: "/dms/categoryCaller.htm",
					data: { 
						cmd: "${cmd}",
						cateType: "${cateType}",
						cateGubun: "${cateGubun}",
						enable: "${isAdmin ? '0' : '1'}",
						pcatid : node.data.key
					}
				});
			}
	    }); 
		
	 	// 루트 노드를 확장하고 선택합니다.
	 	if (categoryObject.length > 0) {
			$("#treeCtnr").dynatree("getTree").getNodeByKey(categoryObject[0].key).toggleExpand(); 
			$("#treeCtnr").dynatree("getTree").activateKey(categoryObject[0].key).toggleSelect();
		}
		
		<c:if test="${iOpenMode == 2}">
			$("#treeCtnr").css("height", $(window).height()-30);
			$(window).bind('resize', function() {
				$("#treeCtnr").css("height", $(window).height()-30);
			}).trigger('resize');
		</c:if>
		if(parent.location.href.indexOf("approval")>-1){
			$(window).bind('resize', function() {
				$("#treeCtnr").css("height", $(window).height()-130);
			}).trigger('resize');
		}
	}); 
</script>
</head>

<body style="margin:0px; border:6px solid #dfdfdf;" bgcolor="#DFDFDF">

	<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed;">
	
	<c:if test="${iOpenMode < 2}">
		<tr height="40">
		<td bgcolor="white" style="padding:5px; border:1px solid #aaa; border-bottom:0px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" bgcolor="white">
					<tr> 
						<td height="27">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="35"><img src="../common/images/blue/sub_img/sub_title_configuration.jpg" width="27" height="27"></td>
									<td class="SubTitle" style="font-size:10pt; font-family:Dotum;"><b><c:out value="${title }" /></b></td>
									<td valign="bottom" width="*" align="right"> 
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr> 
						<td height="3"></td>
					</tr>
					<tr> 
						<td height="3"> 
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3">
								<tr> 
									<td width="200" bgcolor="eaeaea" style="font-size: 1px;"><img src="../common/images/blue/sub_img/sub_title_line.jpg" width="200" height="3"></td>
									<td bgcolor="eaeaea"></td>
								</tr>
							</table>
						</td>
					</tr>
			</table>
			</td>
		</tr>
		<tr height="1" bgcolor="#aaa"><td colspan=1></td></tr>
		<tr height="1" bgcolor="#fff"><td colspan=1></td></tr>
	</c:if>
		
		<tr>
			<td bgcolor="#f2f2f2" style="border:1px solid #aaa;">
				<div id="treeCtnr" class="ui-corner-all" style="border:1px solid #aaa; margin:5px;overflow: auto; height: 320px;"></div>
			</td>
		</tr>

	<c:if test="${iOpenMode < 2}">
		<tr height="1" bgcolor="#aaa"><td ></td></tr>
		<tr height="1" bgcolor="#efefef"><td ></td></tr>
		<tr height="40">
			<td>
				<!-- 확인 버튼 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td align="center" style="padding-top:6px;">
							<span onclick="OnOK()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.ok" text="확인" /> </span>
							
							<span onclick="OnCancel()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.cancel" text="취소" /> </span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</c:if>
	
	</table>
</body>
</html>