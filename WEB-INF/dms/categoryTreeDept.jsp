<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page errorPage="/error.jsp" %>
<%@ page import="nek.dms.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.dbpool.DBHandler" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.NoAdminAuthorityException" %>
<%!
	private String cssPath = "../common/css";
	private String scriptPath = "../common/script";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>

<TITLE><c:out value="${caption }"  /></TITLE>
<c:if test="${iOpenMode < WINDOW_NORMAL }">
<link rel="stylesheet" type="text/css" href="../common/css/popup.css">
</c:if>
<link rel="stylesheet" type="text/css" href="../common/css/tree.css">
<%-- <script type="text/javascript" src="<c:url value="/common/scripts/WebTree.js" />"></script> --%>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<!-- <script src='/common/jquery/js/jquery-1.8.1.min.js' type="text/javascript"></script>  -->
<!-- <script src='/common/jquery/ui/1.8.16/jquery-ui.min.js' type="text/javascript"></script>  -->
<script src='/common/jquery/js/jquery.cookie.js' type="text/javascript"></script> 

<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'> 
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 


<script type="text/javascript">
	<!--
	var objRecipients = new Array();
	
	var ORGUNIT_TYPE_USER = 0;
	var ORGUNIT_TYPE_DEPARTMENT = 1;
		
// 	var orgaTree = new WebTree();
// 	orgaTree.setExpandImg("../common/images/tree/mnode.gif");
// 	orgaTree.setCollapseImg("../common/images/tree/pnode.gif");
// 	orgaTree.setFdCloseImg("../common/images/icons/folder.gif");
// 	orgaTree.setFdOpenImg("../common/images/icons/folderopen.gif");
// 	orgaTree.setItmImg("../common/images/tree/icon_person.gif");
// 	orgaTree.setBlankImg("../common/images/tree/blank.gif");
// 	orgaTree.setInfoImg("../common/images/tree/noitem.gif");
	
	function getNewXMLHttpRequest() {
		var xmlHttpRequest = null;
		try {
			xmlHttpRequest = new XMLHttpRequest();
		} catch(e) {
			try {
				xmlHttpRequest = new ActiveXObject("Msxml2.XMLHTTP");
			} catch(e) {
				try {
					xmlHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
				} catch(e) {
					return null;
				}
			}
		}
		return xmlHttpRequest;
	}
	
	
    g_strNoItemText = "하위분류가 없습니다";
	var WINDOW_POPUP 		= 0;        //팝업형 대화상자
	var WINDOW_MODALDIALOG = 1;		//Modal 대화상자
	var WINDOW_NORMAL 		= 2;		//일반선택
	var WINDOW_LISTSUB		= 3;		//리스트 선택용

	function OnCancel() {
		<c:if test="${iOpenMode == WINDOW_MODALDIALOG}">
			window.returnValue = null;
		</c:if>
		window.close();
	}

	function OnOK(node) {
		var nekDatas = (node)? node.data.datas: $("#treeCtnr").dynatree("getActiveNode").data.datas; //orgaTree.getData(node);
		if(nekDatas != null && nekDatas != "")
		{
			var nek_datas = nekDatas.split(":");
			var titleText = nek_datas[0];
			var target = null;
			if(${htmlWinObj} != null){
				if("${iOpenMode}" == WINDOW_NORMAL){
					target = ${htmlWinObj};
				}else{
					if(null != ${htmlWinObj}.${containerName}){
						target =  ${htmlWinObj}.${containerName};
					}
				}
			}
			if(WINDOW_MODALDIALOG == "${iOpenMode}"){
				var arrReturnValue = new Array(3);
				arrReturnValue[0] = nek_datas[0];
				arrReturnValue[1] = nek_datas[1];
				arrReturnValue[2] = titleText;
				window.returnValue = arrReturnValue;
				window.close();
			}else if("${iOpenMode}" == WINDOW_POPUP){
				if (target != null)
				{
		        	if (target.catid != null) target.catid.value = nek_datas[1];
		        	if (target.catname != null) target.catname.value = titleText;
		        	if (target.catfullname != null) target.catfullname.value = nek_datas[0];
				}
				window.close();
			}else if("${iOpenMode}" == WINDOW_NORMAL){
				var listURL = "./categoryListDept.htm?pCategoryId=" + nek_datas[1];
				listURL += "&pcatname=" + encodeURI(titleText);
				listURL += "&pcatfullname=" + encodeURI(nek_datas[0]);
				if (target == null) target = parent.list_frame;
				if (target !=null) target.location.href = listURL;
				else parent.list_frame.location.href = listURL;
			}else if("${iOpenMode}" == WINDOW_LISTSUB){
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

	$(function(){ 
		var rootKey = "<c:out value="${topCategoryItem.catId}" />";
		var rootName = "<c:out value="${topCategoryItem.catName}" />";
		
	    $("#treeCtnr").dynatree({
	        children: [   						// 초기(루트) 노드를 생성합니다.
				{ "title": rootName
	        	, "isFolder": true
	        	, "isLazy": true
	        	, "key": rootKey
	        	, "datas": "<c:out value="${topCategoryItem.catFullName}:${topCategoryItem.catId}" />"
	        	}
	        ],
	    	onSelect: function(select, node) {	// 클릭되었을 때 호출합니다.
	    		if ("${iOpenMode}" == WINDOW_NORMAL.toString()) OnOK(node); 
	    	},
	    	onLazyRead: function(node) {		// 처음으로 확장 될 때 호출됩니다.
				node.appendAjax({
					url: "/dms/categoryCallerDept.htm",
					data: { enable: "${isAdmin ? '0' : '1'}", pcatid: node.data.key }
				});
			}
	    }); 

	 	// 루트 노드를 확장하고 선택합니다.
		$("#treeCtnr").dynatree("getTree").getNodeByKey(rootKey).toggleExpand(); 
		$("#treeCtnr").dynatree("getTree").activateKey(rootKey).toggleSelect();
		
		<c:if test="${iOpenMode == 2}">
		$("#treeCtnr").css("height", $(window).height()-0);
		$(window).bind('resize', function() {
			$("#treeCtnr").css("height", $(window).height()-0);
		}).trigger('resize');
		</c:if>
	}); 
	
	function OnLoad()
	{
		<%-- 
		orgaTree.rootContainer = document.getElementById("treeCtnr");
		var corpNode = orgaTree.makeFolder(null, "<c:out value="${topCategoryItem.catName}" />", "<c:out value="${topCategoryItem.catFullName}:${topCategoryItem.catId}" />");
		orgaTree.onloadChildNode = function(folder){
			var xmlHttpRequest = getNewXMLHttpRequest();
			var nodeData = folder.getAttribute(orgaTree._NK_DATA);
			var datas = nodeData.split(':');
			var requestURL = "/dms/dms_category_caller.jsp?enable=<c:out value="${isAdmin ? '0' : '1'}" />&catid=" + datas[1];
			try {
				xmlHttpRequest.onreadystatechange = function(){OnGetChildNodesCompleted(this, folder);};
				xmlHttpRequest.open("POST", requestURL, true);
				xmlHttpRequest.send();
			} catch (e) {
				alert(e);
			}
		}
// 		orgaTree.ondblclickFolder = function(folder){OnClickAddRecipient(folder);return true;}
// 		orgaTree.ondblclickItem = function(item){OnClickAddRecipient(item);return true;}
		orgaTree.onclickFolder = function(folder){ OnOK(folder); return true;}
		orgaTree.onclickItem = function(item){ OnOK(item);return true;}

		if("${iOpenMode}" == WINDOW_NORMAL){
			orgaTree.onexpandFolder(corpNode);
		}
		--%>
	}
	
	function OnGetChildNodesCompleted(xhr, container){
		if(xhr.readyState == 4) {
			if (xhr.status == 200) {
				var contentType = xhr.getResponseHeader("Content-Type");
				if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
					orgaTree.makeInfoNode(container,"unsupported content type: " + contentType);
				} else {
					var nodes = xhr.responseXML.getElementsByTagName("dmscategory");
					if(nodes.length == 0){
						orgaTree.makeInfoNode(container, "<spring:message code='dms.sub.exits' text='하위분류가 존재하지 않습니다.'/>");
					}
					for(var i=0; i<nodes.length; i++){
						var catId	= nodes[i].getAttribute("catid");
						var catName = nodes[i].getAttribute("catname");
						var catFullName = nodes[i].getAttribute("catfullname");
						if(nodes[i].getAttribute("isenable")){
							orgaTree.makeFolderWithId(container, "folder_" + catId, catName, catName + ":" + catId);
						} else {
							orgaTree.makeItemWithId(container, "node_" + catId, catName, catFullName + ":" + catId);
						}
					}
				}
			} else {
				orgaTree.makeInfoNode(container, "request status error : " + xhr.status);
			}
		}
	}
//-->
</script>
</head>

<body style="margin:0px; border:6px solid #DFDFDF;" bgcolor="#DFDFDF"  onload="OnLoad();">
	<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
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
									<td width="200" bgcolor="eaeaea"><img src="../common/images/blue/sub_img/sub_title_line.jpg" width="200" height="3"></td>
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
			<td bgcolor="#f2f2f2" style="border-left:1px solid #aaa; border-right: 1px solid #aaa;">			
				<div id="treeCtnr"  class="ui-corner-all" style="border:1px solid #aaa; margin:5px; overflow: auto; height: 330px;"></div>
<!-- 				<div id="treeCtnr" style="margin-top:5px; BORDER-TOP: black 1px solid;BORDER-LEFT: black 1px solid; BACKGROUND: #ffffff; WIDTH: 100%; PADDING: 0px; padding-top:0px; height:400px; "></div> -->
<!-- 				<div id="treeCtnr" style="border: 1px solid rgb(170, 170, 170); width: 100%; height: 100%; padding-bottom: 6px;"></div> -->
			</td>
		</tr>
		<c:if test="${iOpenMode < 2}">
		<tr height="1" bgcolor="#aaa"><td colspan=1></td></tr>
		<tr height="1" bgcolor="#fff"><td colspan=1></td></tr>
		<tr height="40">
			<td>
				<!-- 확인 버튼 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td align="center" style="padding-top:6px;">
							<img src="../common/images/bu_ok.gif" onclick="OnOK()" style="cursor:hand;">&nbsp;&nbsp;
							<img src="../common/images/bu_cancel.gif" onclick="OnCancel();" style="cursor:hand;">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</c:if>
	</table>
</body>
</html>