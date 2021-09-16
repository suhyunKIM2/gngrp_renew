<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.Organization" %>
<%@ page import="nek3.common.UserConfig" %>
<%@ page import="nek3.domain.UserL" %>
<%@ page import="nek3.domain.Department" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@page import="org.apache.commons.lang.math.NumberUtils"%>
<%!
	static final int WINDOW_POPUP 		= 0;        //팝업형 대화상자
	static final int WINDOW_MODALDIALOG = 1;		//Modal 대화상자
	static final int WINDOW_NORMAL 		= 2;		//일반선택

	private String imagePath = "../common/images/";
	private String imgCssPath = "../common/css/blue/blue.css";
	
	private void setImagePath(int mainType){
		if(mainType == 1){
			imagePath = "../common/images/blue";
			imgCssPath = "../common/css/blue/blue.css";
		}else if(mainType == 2){
			imagePath = "../common/images/gray";
			imgCssPath = "../common/css/gray/gray.css";
		}else if(mainType == 3){
			imagePath = "../common/images/green";
			imgCssPath = "../common/css/green/green.css";
		}else if(mainType == 4){
			imagePath = "../common/images/sepia";
			imgCssPath = "../common/css/sepia/sepia.css";
		}
	}
%>
<%
	boolean isAdmin = "1".equals(request.getParameter("isadmin"))? true:false;
	boolean bOnlyDept = "1".equals(request.getParameter("onlydept")) ? true : false;		//부서만 로드 여부
	boolean bOnlyUser = "1".equals(request.getParameter("onlyuser")) ? true : false;		//부서사용자 모두 선택 가능 여부
	int functionNumber = NumberUtils.toInt(request.getParameter("funnum"), 0);

	UserL loginUser = (UserL)request.getAttribute("loginUser");
	UserConfig userConfig = (UserConfig)request.getAttribute("userConfig");
	Organization corp = (Organization)request.getAttribute("corp");	
	
	String htmlWinObj = (request.getParameter("winname") == null ? "opener" : request.getParameter("winname"));
	String containerName = (request.getParameter("conname") == null ? "submitForm" : request.getParameter("conname"));
//	boolean expand	= "1".equals(request.getParameter("expand")) ? true:false;
	boolean expand = true;
	
	String expandId = request.getParameter("expandid");
	if (StringUtils.isEmpty(expandId)) expandId = Const.TOP_DEPTCODE;

	int iOpenMode = WINDOW_NORMAL;
	try {
		iOpenMode = Integer.parseInt(request.getParameter("openmode"));
		if (iOpenMode < WINDOW_POPUP || iOpenMode > WINDOW_NORMAL){
			iOpenMode = WINDOW_NORMAL;
		}
	} catch (Exception e) {
		iOpenMode = WINDOW_NORMAL;
	}

	String caption = request.getParameter("caption");
	String title = request.getParameter("title");
	
	if (null == caption) caption = corp.getItemTitle() + "-조직도";
	if (null == title) title = corp.getItemTitle() + "-조직도";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="nek3.common.Const"%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><%=caption %></title>
<%@ include file="./include.common.jsp" %>
<% if (iOpenMode < WINDOW_NORMAL) { %>
<link rel="stylesheet" type="text/css" href="<c:url value="/common/css/popup.css" />" >
<link rel="stylesheet" type="text/css" href="<%= imgCssPath %>">
<% } %>

<script src='/common/jquery/js/jquery-1.8.1.min.js' type="text/javascript"></script> 
<script src='/common/jquery/ui/1.8.16/jquery-ui.min.js' type="text/javascript"></script> 
<script src='/common/jquery/js/jquery.cookie.js' type="text/javascript"></script> 

<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'> 
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 

<%-- <script type="text/javascript" src="<c:url value="/common/scripts/WebTree.js" />"></script> --%>
<style type="text/css">
	.wtree-root {}
	.wtree-fd {cursor:pointer}
	.wtree-fd-selected {}
	.wtree-itm {cursor:pointer}
	.wtree-itm-selected {}
	
	div#treeCtnr ul { padding-top: 0; padding-bottom: 0;height: 96vh;border: 1px solid #eee; } 
	div#treeCtnr li:FIRST-CHILD { padding-top: 3px; }
	div#treeCtnr li.dynatree-lastsib { padding-bottom: 3px; }
</style>
<script type="text/javascript">

	window.code = '_CHILDWINDOW_COMM1004';

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
</script>
<script type="text/javascript">
	<% if (iOpenMode < WINDOW_NORMAL) { %>
	function OnCancel() {
		<%	if (iOpenMode == WINDOW_MODALDIALOG) { %> 
// 			window.returnValue = null;
// 			window.close();
			try { 
				parent.closeDhtmlModalWindow(); 
			} catch(e) { 
				// TODO: isOpener Check
				window.close(); 
			}
		<%	} else { %>
			window.close();
		<%	} %>
	}
	<% } %>
	
	function OnOK(node) {
		var selectedNode = node || $("#treeCtnr").dynatree("getActiveNode");
		var nekDatas = (node)? node.data.datas: $("#treeCtnr").dynatree("getActiveNode").data.datas; //orgaTree.getData(node);
		
		if (selectedNode.data.type == "department" && onlyUser) {
			nekDatas = null;
		} else if (selectedNode.data.type == "user" && onlyDept) {
			nekDatas = null;
		}
		if(nekDatas != null){
			var targetForm = null;
			if (null != <%= htmlWinObj%>)
			{
				if (null != <%=htmlWinObj%>.<%=containerName%>) targetForm = <%=htmlWinObj%>.<%=containerName%>;
			}
		<% if (iOpenMode == WINDOW_MODALDIALOG){ %>
// 			window.returnValue = nekDatas;
// 			window.close();

			switch(<%=functionNumber %>) {
				case 10041: parent.setAdminId(nekDatas); break;
				case 10042: parent.setWriterId(nekDatas); break;
				case 10043: parent.setShareId(nekDatas); break;
				default: try { parent.setDeptSelector(nekDatas); } catch(e) { window.returnValue = nekDatas; } break;
			} 
			try {
				parent.closeDhtmlModalWindow(); 
			} catch(e) {
				// TODO: isOpener Check
				window.close();
			}
			
		<% } else if (iOpenMode == WINDOW_POPUP || (iOpenMode == WINDOW_NORMAL && !isAdmin)) {%>

			if (targetForm != null){
	        	if (targetForm.orgadata != null){
					targetForm.orgadata.value = nekDatas;
					targetForm.orgadata.focus();
				}
			}
			<% if (iOpenMode == WINDOW_POPUP) {%>
			window.close();
			<%}%>
		<%} else if (iOpenMode == WINDOW_NORMAL && isAdmin) { %>
			var arrDatas = nekDatas.split(":");
			var titleText = arrDatas[0]; //orgaTree.getLabel(node);
			var listURL = "<c:url value='/configuration/department_list.htm?pDpId=' />" + arrDatas[1];
			listURL += "&pDpName=" + encodeURI(titleText);
			targetForm = parent.dept_frame;
			targetForm.location.href = listURL;
		<%}%>
		}
	}

//	var orgaTree = new WebTree();
// 	orgaTree.setExpandImg("<c:url value="/common/images/tree/mnode.gif" />");
// 	orgaTree.setCollapseImg("<c:url value="/common/images/tree/pnode.gif" />");
// 	orgaTree.setFdCloseImg("<c:url value="/common/images/icons/folder.gif" />");
// 	orgaTree.setFdOpenImg("<c:url value="/common/images/icons/folderopen.gif" />");
// 	orgaTree.setItmImg("<c:url value="/common/images/tree/icon_person.gif" />");
// 	orgaTree.setBlankImg("<c:url value="/common/images/tree/blank.gif" />");
// 	orgaTree.setInfoImg("<c:url value="/common/images/tree/noitem.gif" />");
	
	var onlyUser = <%=bOnlyUser %>;
	var onlyDept = <%=bOnlyDept %>;

	// 사용자 부분 데이터
	var userSector = [			
			{ 
				"title": "<c:out value="${userSector.dpName }" />",
				"type": "department",
				"isFolder": true, 
				"isLazy": true, 
				"key": "<c:out value="${userSector.dpId }" />", 
				"datas": "${userSector.dpName}:${userSector.dpId}"
			}
	];
	
	// 사용자 전사 데이터
	var addressBook = [
		<c:forEach var="dept" items="${addressBookList }" varStatus="status">
			<c:if test="${status.first == false }">,</c:if>
			{ 
				"title": "<c:out value="${dept.dpName }" />",
				"type": "department",
				"isFolder": true, 
				"isLazy": true, 
				"key": "<c:out value="${dept.dpId }" />", 
				"datas": "${dept.dpName}:${dept.dpId}" 
			}
		</c:forEach>
	];
	
	$(function(){ 
		var rootKey = "${corp.itemId}";
		var rootName = "${corp.itemTitle}";

		<c:forEach var="dept" items="${addressBookList }" varStatus="status">
			<c:if test="${status.first == true }">
				rootKey = "<c:out value="${dept.dpId }" />";
				rootName = "<c:out value="${dept.dpName }" />";
			</c:if>
		</c:forEach>
		
	    $("#treeCtnr").dynatree({
	        children: addressBook,	// 초기(루트) 노드를 생성합니다.
// 			[  					
// 				{ "title": rootName
// 	        	, "isFolder": true
// 	        	, "isLazy": true
// 	        	, "key": rootKey
// 	        	, "type": "department"
// 	        	, "datas": "${corp.itemTitle}:${corp.itemId}"
// 	        	}
// 	        ],
	    	onSelect: function(select, node) {	// 클릭되었을 때 호출합니다.
	    		if (node.data.isFolder) {
					<% 	if (iOpenMode == WINDOW_NORMAL && isAdmin) { out.println("OnOK(node);"); } %>
	    		}
	    	},
	    	onDblClick: function(node, e) {		// 더블 클릭되었을 때 호출합니다.
	    		var targetType = node.getEventTargetType(e); // 클릭한 노드영역
	    		if (targetType) {
	        		node.toggleSelect();
	        		if (targetType != "expander") {
	        			if (node.data.type == "department" && !onlyUser) {
	        				OnOK(node);
	        			} else if (node.data.type == "user" && !onlyDept) {
	        				OnOK(node);
	        			}
	        		}
	    		} else return false;
	    	},
	    	onLazyRead: function(node) {		// 처음으로 확장 될 때 호출됩니다.
				node.appendAjax({
					url: "/common/recipient_selector_support_json.htm",
					data: { onlydept: "<%=(bOnlyDept ? "1":"0")%>", isadmin: "<%=(isAdmin ? "1":"0")%>", dpId: node.data.key }
				});
			}
	    });

	 	// 루트 노드를 확장합니다.
		// $("#treeCtnr").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();
		
		<%	if (iOpenMode == WINDOW_NORMAL) { /* 일반선택 */
		 		// 루트 노드를 선택합니다.
		 		%>
				$("#treeCtnr").dynatree("getTree").activateKey(rootKey).toggleSelect();

				$("#treeCtnr").css("height", $(window).height()-0);
				$(window).bind('resize', function() {
					$("#treeCtnr").css("height", $(window).height()-0);
				}).trigger('resize');
		<%	}  else { %>
		 		$('#treeCtnr').css({"width":$(window).width()-0,"height":$(window).height()-120});
		 		$(window).bind('resize', function() {
		 			$('#treeCtnr').css({"width":$(window).width()-0,"height":$(window).height()-120});	
		 		}).trigger('resize');
		<%	} %>

	}); 
	
	function OnLoad(){
		<%--
		orgaTree.rootContainer = document.getElementById("treeCtnr");
		var corpNode = orgaTree.makeFolderWithId(null, "folder_${corp.itemId}", "<c:out value="${corp.itemTitle}" />", "<c:out value="${corp.itemTitle}:${corp.itemId}" />");
		
		orgaTree.onloadChildNode = function(folder){
			var xmlHttpRequest = getNewXMLHttpRequest();
			var nodeData = folder.getAttribute(orgaTree._NK_DATA);
			var datas = nodeData.split(':');
			var requestURL = "./recipient_selector_support.htm?onlydept=<%=(bOnlyDept ? "1":"0")%>&isadmin=<%=(isAdmin ? "1":"0")%>&dpId=" + datas[1];
			try {
				xmlHttpRequest.onreadystatechange = function(){OnGetChildNodesCompleted(this, folder);};
				xmlHttpRequest.open("POST", requestURL, <% if(expand) out.write("false"); else out.write("true"); %>);//확장여부에 따라 동기 또는 비동기처리
				xmlHttpRequest.send();
			} catch (e) {
				alert(e);
			}
		}
		<% if (!bOnlyUser) { %>
		orgaTree.onclickFolder = function(folder){ OnOK(folder); return true;}
		orgaTree.ondblclickFolder = function(folder){OnOK(folder);return true;}
		<% } %>
		<% if (!bOnlyDept){ %>
		orgaTree.onclickItem = function(item){ OnOK(item);return true;}
		orgaTree.ondblclickItem = function(item){OnOK(item);return true;}
		<% } %>
		<c:if test="${expandDepts != null}">
		<c:set var="len" value="${fn:length(expandDepts)}" />
		var folder = null;
		<c:forEach var="i" end="${len-1}" begin="0">
		folder = document.getElementById("folder_<c:out value='${expandDepts[len - (1 + i)].dpId}' />");
		if(folder != null) orgaTree.onexpandFolder(folder);
		</c:forEach>
		</c:if>
		<% if (iOpenMode == WINDOW_NORMAL && isAdmin){ %>
		orgaTree.onselectFolder(corpNode);
		OnOK(corpNode);
		<%}%>
		<% if (iOpenMode != WINDOW_NORMAL && expand){ %>
		orgaTree.onexpandFolder(corpNode);
		<%}%>
		--%>
	}
	
	function OnGetChildNodesCompleted(xhr, container){
		if(xhr.readyState == 4) {
			if (xhr.status == 200) {
				var contentType = xhr.getResponseHeader("Content-Type");
				if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
					orgaTree.makeInfoNode(container,"unsupported content type: " + contentType);
				} else {
					var nodes = xhr.responseXML.getElementsByTagName("ou");
					var objUsers = new Array();
					var str = "";
					
					<% if(bOnlyDept){ %>
							str = "<spring:message code='v.low.dept.no' text='하위부서가  없습니다.' />";
					<% }else{ %>
							str = "<spring:message code='mail.member.no' text='구성원이 없습니다.' />";
					<% } %>
					
					if(nodes.length == 0){
						orgaTree.makeInfoNode(container, str);
					}
					for(var i=0; i<nodes.length; i++){
						if(nodes[i].getAttribute("type") == "department"){
							var strName = nodes[i].getAttribute("name");
							var strID	= nodes[i].getAttribute("deptid");
							orgaTree.makeFolderWithId(container, "folder_" + strID, strName, strName + ":" + strID);
						} else {
							objUsers.push(nodes[i]);
						}
					}
					for (var i = 0; i < objUsers.length; i++) {
						var strName		= objUsers[i].getAttribute("name");
						var strUID		= objUsers[i].getAttribute("uid");
						var strPosition = objUsers[i].getAttribute("position");
						var strDepartment = objUsers[i].getAttribute("department");
						var strDeptId = objUsers[i].getAttribute("deptid");
						if (strPosition == null || strPosition == "") {
							strPosition = "<spring:message code='appr.positon.no' text='직급없음' />";
						}
						orgaTree.makeItemWithId(container, "node_" + strUID, strName + "/" + strPosition, strName + ":" + strUID + ":" + strPosition + ":" + strDepartment + ":" + strDeptId);
					}
				}
			} else {
				orgaTree.makeInfoNode(container, "request status error : " + xhr.status);
			}
		}
	}

// 	function dynatreeChange(elem) {
// 		var select = $(elem);
// 		var rootKey = select.val();
// 		var rootName = select.children("option:selected").text();
// 		var rootNode = $("#treeCtnr").dynatree("getRoot");
// 		rootNode.removeChildren();
// 		rootNode.addChild({ "title": rootName, "type": "department", "isFolder": true, "isLazy": true, "key": rootKey, "datas": rootName + ":" + rootKey });
// 		rootNode.render();
// 		$("#treeCtnr").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();	// 루트 노드를 확장합니다.
// 	}

	function dynatreeChange(elem) {
		var select = $(elem);
		var rootNode = $("#treeCtnr").dynatree("getRoot");
		rootNode.removeChildren();
		switch(select.val()) {
			case '1': rootNode.addChild(userSector[0]); break;
			case '2': for(i in addressBook) rootNode.addChild(addressBook[i]); break;
			default : break;
		}
		rootNode.render();
		//$("#treeCtnr").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();	// 루트 노드를 확장합니다.
	}
</script>
</head>
<body style="margin:0px; overflow: hidden;" bgcolor="#dfdfdf" onload="javascript:OnLoad();">
	<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
		<%if (iOpenMode < WINDOW_NORMAL){%>
		<tr height="40">
			<td bgcolor="white" style="padding:5px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" bgcolor="white">
					<tr> 
						<td height="27">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="35"><img src="../common/images/blue/sub_img/sub_title_configuration.jpg" width="27" height="27"></td>
									<td class="SubTitle" style="font-size:10pt;"><b><%=title %></b></td>
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
		<%}%>
		<tr>
			<td style="padding:5 5 5 5">
				<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
					<colgroup><col width="100%"><col width="90"></colgroup>
					<tr>
						<td colspan="2">
							<table width="100%" border="0">
								<tr height="30">
									<td width="85" style="text-align: center;">
										<spring:message code='mail.addresses' text='주소록' />
									</td>
									<td>
										
										<select name="range" class="w100p" class="ui-corner-all" onchange="dynatreeChange(this)">
											<option value="1"><spring:message code='mail.addressbook.sector' text='부문주소록' /></option>
											<option value="2" selected><spring:message code='mail.addressbook.all.company' text='전사주소록' /></option>
										</select>
										
										<%-- 
										<select style="width:95%;" class="ui-corner-all" onchange="dynatreeChange(this)">
										<c:forEach var="dept" items="${addressBookList }" varStatus="status">
											<option value="<c:out value="${dept.dpId }" />"><c:out value="${dept.dpName }" /></option>											
										</c:forEach>
										</select>
										 --%>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="2" valign="top">
							<div id="treeCtnr" style="background-color:#FFFFFF; overflow: auto; height: 330px;"></div> 
<!-- 							<div id="treeCtnr" style="margin-top: 5px; border-top: black 1px solid; border-left: black 1px solid; background: #ffffff; width: 100%; padding: 0px; height: 350px;"></div> -->
							
<!-- 							<div id="treeCtnr" style="BORDER-TOP: black 1px solid;BORDER-LEFT: black 1px solid; BACKGROUND: #ffffff; OVERFLOW: auto; WIDTH: 100%; PADDING-TOP: 5px; min-height:400px; max-height:400px;"> -->
<!-- 							</div> -->
<!--								<div id="treeCtnr" style="position:relative;border:black 1px solid;background:#ffffff;padding-right:2px; left:0px; overflow:auto; overflow-y:auto;overflow-x:hidden;width:100%;height:expression(document.body.clientHeight-110);">-->
<!--								</div>							-->
						</td>
					</tr>
					<!--tr height="30">
						<td>
							<input type="text" name="edit_recipient" style="width:100%" onkeydown="OnInputRecipientKeyDown()">
						</td>
						<td>&nbsp;
							<input type="button" value="검색" onclick="OnClickAddRecipients()" style="width:70px">
						</td>
					</tr-->
				</table> 
			</td>
		</tr>
		<% if (iOpenMode < WINDOW_NORMAL){ %>
		<tr height="1" bgcolor="#aaa"><td ></td></tr>
		<tr height="1" bgcolor="#efefef"><td ></td></tr>
		<tr height="40">
			<td>
				<!-- 확인 버튼 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td align="center" style="padding-top:6px;">
							<img src="../common/images/bu_ok.gif" onclick="javascript:OnOK()" style="cursor:hand;">&nbsp;&nbsp;
							<img src="../common/images/bu_cancel.gif" onclick="javascrit:OnCancel()" style="cursor:hand;">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<% } %>
	</table>
</body>
</html>