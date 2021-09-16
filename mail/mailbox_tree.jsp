<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<% 	request.setCharacterEncoding("utf-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%
	String boxCode = request.getParameter("boxid");
	if(boxCode==null) boxCode ="0";
	String subBoxCode = request.getParameter("subboxid");
	if(subBoxCode==null) subBoxCode ="0";
%>
<!DOCTYPE html>
<html>
<head>
<title>menu code</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>

<link rel="stylesheet" type=text/css href="../common/css/list.css">
<link rel="stylesheet" href="../common/css/popup.css" type="text/css">
<link rel="stylesheet" type="text/css" href="<%=imgCssPath %>">
<!-- <script src="../common/scripts/menu_tree.js"></script> -->

<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'>
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 

<style>
body { margin-left:0pt; margin-top:0pt; margin-right:0pt; margin-width:0pt;}

td {font-family:Tahoma, 돋움; font-size:9pt;}

.img {text-align:right;}
.menu	{color:#000000; padding-left:5px; padding-top:3px; line-height:24px;}
.sub	{color:#000000; padding-left:5px; padding-top:3px; line-height:18px;}

a.1depth:link		{color:#000000; text-decoration:none;}
a.1depth:visited	{color:#000000; text-decoration:none;}
a.1depth:hover 	{color:#3A81AB; text-decoration:none;}


a.2depth:link		{color:#000000; text-decoration:none; font-style:normal;}
a.2depth:visited 	{color:#000000; text-decoration:none; font-style:normal;}
a.2depth:hover   	{color:#ff0000; text-decoration:none; font-style:normal;}

BODY {font-family:Arial; font-size:9pt; margin-top:0;margin-left:0; margin-right :0;
	scrollbar-face-color:#F7F7F7; scrollbar-shadow-color:#cccccc ; scrollbar-highlight-color: #FFFFFF; 
	scrollbar-3dlight-color: #FFFFFF; scrollbar-darkshadow-color: #FFFFFF; scrollbar-track-color: #FFFFFF; 
	scrollbar-arrow-color: #cccccc; ;
}

SPAN.clsSelected
{
	font-family: Tahoma, 돋움
	height: 1.2em;
	font-size:9pt;
	vertical-align: bottom;
	padding-left: 3px;
	background-color: #90B9CB;
	border:1px solid #999999;
	cursor: hand;
}

SPAN.clsLabel
{
	font-family: Tahoma, 돋움
	height: 1.2em;
	font-size:9pt;
	vertical-align: bottom;
	padding-left: 0px;
	background-color:#FFFFFF;
	cursor: hand;
}

SPAN.clsInfo
{
	font-family: Tahoma, 돋움
	height: 1.2em;
	font-size:9pt;
	vertical-align: bottom;
	padding-left: 3px;
	background-color:#FFFFFF;
}

.hide
{
	display:none;
}

.shown
{
	display:block;
	margin-left:16px;
}

IMG.node
{
	vertical-align: middle;
	width : 18px;
	height : 18px;
	cursor: hand;
}

</style>
<style type="text/css">
/*   ul.dynatree-container { */
/*         overflow: scroll; */
/*         position: relative; */
/*         box-sizing: border-box;  */
/*         -webkit-box-sizing:border-box;  */
/*         -moz-box-sizing: border-box;  */
/*         -ms-box-sizing: border-box; */
/*         width: 100%; */
/*         height: 350px; */
/*   }; */
</style>
</HEAD>

<script>

window.code = '_CHILDWINDOW_MAIL1004';

var menuID = "<%=boxCode%>";
var subMenuID = "<%=subBoxCode%>";

var imgPath = "/common/images/tree2/" ;

var IMG_BOOKCLOSED = imgPath + "folder.gif";
var IMG_BOOKOPENED = imgPath + "folderopen.gif";
var IMG_MNODE = imgPath + "minus1.gif";
var IMG_PNODE = imgPath + "plus1.gif";
var IMG_BLANK = imgPath + "blank.gif";
var IMG_PERSON = imgPath + "page1.gif";
var IMG_NOITEM = imgPath + "noitem.gif";

var g_nMaxCalls = 1024;
var g_Calls = new Array();
var g_nLastCall = 0;
var g_strLoadingText = "로딩...";
var g_strErrorText = "로드 실패!";
var g_strNoItemText = "구성원이 없습니다.";
var g_objNodeSelected = null;
var g_strNoItemText = "하위분류가 없습니다";
var menuID;		//메뉴ID
var subMenuID;	//하위메뉴ID

var error = "<%=msglang.getString("mail.error.code")%>";	//오류코드
var errMsg = "<%=msglang.getString("appr.data.wrong")%>";	//잘못된 데이터입니다. 오랫동안 사용하지 않아 세션이 종료되었거나, 서버오류입니다\!


//기존트리에서 'dynatree'로 변경 2012-10-19
$(function(){ 
	var rootKey = "0";
	var rootName = "Mail Box";
	
	$("#tree_area").dynatree({
		children: [   						// 초기(루트) 노드를 생성합니다.
			{ "title": rootName
			, "type": "department"
			, "isFolder": true
			, "isLazy": true
			, "key": rootKey
			, "dbpath": "mail"
			, "opentype": "TOP"
			, "datas": rootName + ":" + rootKey + ":1:0:mail:TOP" 
			/* datas : catName + ":" + code + ":" + isChildExist + ":" + mainBoxID + ":" + dbPath + ":" + popup */
			}
		],
		onDblClick: function(node, e) {		// 더블 클릭되었을 때 호출합니다.
			var targetType = node.getEventTargetType(e); // 클릭한 노드영역
			if (targetType) {
				OnOK();
			} else return false;
		},
	 	onLazyRead: function(node) {		// 처음으로 확장 될 때 호출됩니다.
			node.appendAjax({
				url: "./mailbox_json.jsp",
				success: function(node) {	// 처음확장 이후 전체 펼침 - 2013-12-20 김정국
					node.visit(function(n) {
						n.expand(true);
					})
				},
				data: { boxid: node.data.key, dbpath: node.data.dbpath, opentype: node.data.opentype }
			});
		}
	});
	
	$("#tree_area").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();	//처음확장
	
});

function CallObject(objXmlReq, objNode)
{
	this.objXmlReq = objXmlReq;	
	this.objNode = objNode;
}

function NewCall()
{
	var nReturn = g_nLastCall;
	if (g_nLastCall == g_nMaxCalls)
	{
		g_nLastCall = 0;
	}
	else
	{
		g_nLastCall++;
	}
	return nReturn;
}

function DeleteCall(nIndex)
{
	g_Calls[nIndex] = null;
}

function AddFolder(objParent, strName, strType, strData, expandChild, selectedNode) {
	var strHtml = "<div style='' nowrap nek_type='" + strType + "' nek_data='" + strData + "' oncontextmenu='return false' onselectstart='return false' ondragstart='return false'>";
	var datas = strData.split(':');
	if(datas[2] == "1"){
		strHtml += "<img style='width:13;height=13;' class='node' src='";
		strHtml += IMG_PNODE;
		strHtml += "'>";
	}else{
		strHtml += "<img style='width:13;height=13;' src='";
		strHtml += IMG_BLANK;
		strHtml += "'>";
	}
	strHtml += "&nbsp;<img class='node' width='18' height='18'";
	strHtml += " src='" + IMG_BOOKCLOSED + "'><span class='clsLabel'>"
	strHtml += strName;
	strHtml += "</span><div class='hide'></div></div>";
	objParent.insertAdjacentHTML("beforeEnd", strHtml);
	if (expandChild) {
		if(subMenuID==strType){
			objParent.children[selectedNode].children[0].click();
		}
	}
}

function AddFolderWithId(objParent, strName, strType, strData, expandChild, layerId, selectedNode){
	var strHtml = "<div id='" + layerId + "' nowrap nek_type='" + strType + "' nek_data='" + strData + "' oncontextmenu='return false' onselectstart='return false' ondragstart='return false'>";
	var datas = strData.split(':');
	if(datas[2] == "1"){
		strHtml += "<img style='width:13;height=13;' class='node' src='";
		strHtml += IMG_PNODE;
		strHtml += "'>";
	}else{
		strHtml += "<img style='width:13;height=13;' src='";
		strHtml += IMG_BLANK;
		strHtml += "'>";
	}
	strHtml += "&nbsp;<img style='width:18;height=18;' middle;' class='node' ";
	strHtml += " src='" + IMG_BOOKCLOSED + "'><span class='clsLabel'>"
	strHtml += strName;
	strHtml += "</span><div class='hide'></div></div>";
	objParent.insertAdjacentHTML("beforeEnd", strHtml);

	if (expandChild) {
		if(menuID==strType || subMenuID==strType){
			objParent.children[selectedNode].children[0].click();
		}
	}
}

function AddNodeWithId(objParent, strName, strType, strData, layerId) {
	var strHtml = "<div id='" + layerId + "' nowrap nek_type='" + strType + "' nek_data='" + strData + "' style='padding-top:2px; padding-left:2px;'>";

	strHtml += "<img style='width:12;height=15;' class='node'";
	strHtml += " src='" + IMG_PERSON + "'>";
	strHtml += "<span class='clsLabel' style='padding-left:3px;'>"
	strHtml += strName;
	strHtml += "</span></div>";
	objParent.insertAdjacentHTML("beforeEnd", strHtml);
}

function AddNode(objParent, strName, strType, strData) {
	var strHtml = "<div nowrap nek_type='" + strType + "' nek_data='" + strData + "'>";
	var datas = strData.split(':');
	/*
	strHtml += "<img class='node' width='13' height='13' src='";
	strHtml += IMG_BLANK;
	strHtml += "'>";
	*/
	strHtml += "<img style='width:12;height=15;' class='node'";
	strHtml += " src='" + IMG_PERSON + "'>";
	strHtml += "<span class='clsLabel'>"
	strHtml += strName;
	strHtml += "</span></div>";
	objParent.insertAdjacentHTML("beforeEnd", strHtml);
}

function AddInfo(objParent, strText) {
	var strHtml = "<div nowrap nek_type='info'>";
	strHtml += "<img style='width:12;height=15;' class='node' src='";
	strHtml += IMG_NOITEM;
	strHtml += "'>";
	strHtml += "<span class='clsInfo'>";
	strHtml += strText;
	strHtml += "</span></div>";
	objParent.innerHTML = strHtml;
}

function AddInfoWithId(objParent, strText, layerId) {
	var strHtml = "<div id='" + layerId + "' nowrap nek_type='info'>";
	strHtml += "<img class='node' width='13' height='13' src='";
	strHtml += IMG_NOITEM;
	strHtml += "'>";
	strHtml += "<span class='clsInfo'>";
	strHtml += strText;
	strHtml += "</span></div>";
	objParent.innerHTML = strHtml;
}

function AddNoItem(objParent) {
	var strHtml = "<div nowrap nek_type='noitem'>";
	strHtml += "<img class='node' width='13' height='13' src='";
	strHtml += IMG_NOITEM;
	strHtml += "'>";
	strHtml += "<span class='clsInfo'>";
	strHtml += g_strNoItemText;
	strHtml += "</span></div>";
	objParent.innerHTML = strHtml;
}

function AddNoItemWithId(objParent, layerId){
	var strHtml = "<div id='" + layerId + "' nowrap nek_type='noitem'>";
	strHtml += "<img class='node' width='13' height='13' src='";
	strHtml += IMG_NOITEM;
	strHtml += "'>";
	strHtml += "<span class='clsInfo'>";
	strHtml += g_strNoItemText;
	strHtml += "</span></div>";
	objParent.innerHTML = strHtml;
}


function CollapseNode(objContainer) {
	var objChildContainer = objContainer.children[3];
	objChildContainer.className = "hide";
	objContainer.children[0].src = IMG_PNODE;
	objContainer.children[1].src = IMG_BOOKCLOSED;
}

function onload_action(){
	//좌측메뉴 타이틀
	var leftTitle = document.getElementById("leftTitle");
	var subImage = document.getElementById("subimg");
	
	var strXmlSrc = "/common/menu_xml.jsp?menucode=" + menuID ;
	var container = document.all.tree_area;
	
	var nCall = NewCall();
	var objXmlReq = new ActiveXObject("MSXML2.XMLHTTP");
	g_Calls[nCall] = new CallObject(objXmlReq, container);
	objXmlReq.open("POST", strXmlSrc, true); 	//비동기적으로
	objXmlReq.onreadystatechange = Function("LoadCompleted(" + nCall + ");");
	objXmlReq.send();
}

function LoadCompleted(nIndex){
	if (nIndex == null) return;
	var nReadyState = null;
	var objCall = g_Calls[nIndex];
	nReadyState = objCall.objXmlReq.readyState;
	if (4 != nReadyState) return;	//4: load completed state
	if (objCall != null)
	{
		if (objCall.objXmlReq.status != 200)
		{
			alert(error+": " + objCall.objXmlReq.status + "\r\n" + objCall.objXmlReq.statusText);
			objCall.objNode.innerHTML = "";
			AddNode(objCall.objNode, g_strErrorText);
			return;
		}
		//text/xml
		var contentType = objCall.objXmlReq.getResponseHeader("Content-Type");
		if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
			alert(errMsg);
			return;
		}

		var objCollect = objCall.objXmlReq.responseXML.selectNodes("//doc");

		//objCall.objNode.innerHTML = "";
		if (objCollect.length < 1) {
			AddNoItem(objCall.objNode);
		} else {
			for (var i = 0; i < objCollect.length; i++) {
				var code	= objCollect[i].getAttribute("code");
				var catName = objCollect[i].getAttribute("name");
				var url = objCollect[i].getAttribute("url");
				var isChildExist = objCollect[i].getAttribute("isChildExist");
				//AddFolder(tree_area, catName, code, catName + ":" + code + ":" + isChildExist + ":" + url, true, i);

				if(isChildExist=="1"){
					AddFolderWithId(tree_area, catName, code, catName + ":" + code + ":" + isChildExist + ":" + url+ ":" + popup, true, "code_"+code, i);
				}else{
					//AddNodeWithId(tree_area, catName, code, catName + ":" + code + ":" + isChildExist + ":" + url + ":" + popup, "code_"+code);
					if (objCollect.length == 1) {
						AddNoItem(objCall.objNode);
					}
				}
			}
		}
	}
}

function OnDblClick() {
	var objSrcElem = window.event.srcElement;
	if (objSrcElem == null) {
		return false;
	}

	var className = objSrcElem.className;

	if (className == "clsLabel" || className  == "clsSelected") {
		var objContainer = objSrcElem.parentElement;
		//var strType = objContainer.getAttribute("nek_type");
		var strData = objContainer.getAttribute("nek_data");
		var datas = strData.split(":");
		if (datas[2] == "0") {
			if (objContainer.id == "" || objContainer.id == null) return;
			OnOK();
		}else{
			//if (objContainer.id == "" || objContainer.id == null) return;
			ToggleNode(objContainer);
		}
	}
}

function SelectNode(objElem) {
	var type = objElem.getAttribute("nek_type");
	var data = objElem.getAttribute("nek_data");
	var datas = data.split(":");

	if (g_objNodeSelected != null) {
		if(g_objNodeSelected.children[1].className=="clsSelected"){
			g_objNodeSelected.children[1].className = "clsLabel";
		}
		if(g_objNodeSelected.children[2]!=null){
			if(g_objNodeSelected.children[2].className=="clsSelected"){
				g_objNodeSelected.children[2].className = "clsLabel";
			}
		}
	}

	g_objNodeSelected = objElem;
	if(datas[2]==1){
		objElem.children[2].className ="clsSelected";
	}else{
		objElem.children[1].className ="clsSelected";
	}
	//클릭 이벤트 실행
	//OnOK();
}

function ToggleNode(objContainer) {
	var objChildContainer = objContainer.children[3];
	var strType = objContainer.getAttribute("nek_type");
	var strData = objContainer.getAttribute("nek_data");
	var datas = strData.split(':');
	
	if(datas[2] == "1"){
		if (objChildContainer.className == "hide") {
			ExpandNode(objContainer);
		} else {
			CollapseNode(objContainer);
		}
	}
}

function ExpandNode(objContainer) {
	var objChildContainer = objContainer.children[3];
	objChildContainer.className = "shown";
	objContainer.children[0].src = IMG_MNODE;
	objContainer.children[1].src = IMG_BOOKOPENED;

	var retrieved = objContainer.getAttribute("nek_retrieved");
	if (retrieved != "1") {
		LoadCategory(objContainer.children[3]);
	}
}

function LoadCategory(objContainer){
	AddInfo(objContainer, g_strLoadingText);
	var strData = objContainer.parentElement.getAttribute("nek_data");
	var datas = strData.split(':');

	var strXmlSrc = "./mailbox_xml.jsp?boxid=" + datas[1] + "&dbpath=" + datas[4] ;
	//첫 로딩할때 사내통신도 같이 포함하기 위해 첫로딩 Flag 추가
	if(datas[5]!=null) strXmlSrc += "&opentype=" + datas[5];

	var nCall = NewCall();
	var objXmlReq = new ActiveXObject("MSXML2.XMLHTTP");
	g_Calls[nCall] = new CallObject(objXmlReq, objContainer);
	objXmlReq.open("POST", strXmlSrc, true); 	//비동기적으로
	objXmlReq.onreadystatechange = Function("LoadCategoryCompleted(" + nCall + ");");
	objXmlReq.send();
}

function LoadCategoryCompleted(nIndex){
	if (nIndex == null) return;

	var nReadyState = null;
	var objCall = g_Calls[nIndex];

	nReadyState = objCall.objXmlReq.readyState;
	if (4 != nReadyState) return;	//4: load completed state

	if (objCall != null)
	{
		if (objCall.objXmlReq.status != 200)
		{
			alert(error+": " + objCall.objXmlReq.status + "\r\n" + objCall.objXmlReq.statusText);
			objCall.objNode.innerHTML = "";
			AddNode(objCall.objNode, g_strErrorText);
			return;
		}

		//text/xml
		var contentType = objCall.objXmlReq.getResponseHeader("Content-Type");
		if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
			alert(errMsg);
			return;
		}

		if (objCall.objNode.parentElement != null) objCall.objNode.parentElement.setAttribute("nek_retrieved", "1");
			//var objDmsCategory = objCall.objXmlReq.responseXML.selectNodes("//dmscategory[@type='dms_category']");
		
		var objCollect = objCall.objXmlReq.responseXML.selectNodes("//doc");

		objCall.objNode.innerHTML = "";
		var chk = 0;
		if (objCollect.length < 1) {
			AddNoItem(objCall.objNode);
		} else {
			for (var i = 0; i < objCollect.length; i++) {
				var code	= objCollect[i].getAttribute("code");
				var catName = objCollect[i].getAttribute("name");
				var isChildExist = objCollect[i].getAttribute("isChildExist");
				var mainBoxID = objCollect[i].getAttribute("mainBoxID");
				var dbPath = objCollect[i].getAttribute("dbpath");

				if(isChildExist=="1"){
					AddFolderWithId(objCall.objNode, catName, code, catName + ":" + code + ":" + isChildExist + ":" + mainBoxID + ":" + dbPath, true, "code_"+code, i);
					chk++;
				}else{
					//AddNodeWithId(objCall.objNode, catName, code, catName + ":" + code + ":" + isChildExist + ":" + url + ":" + popup, "code_"+code);
					if (objCollect.length == 1) {
						AddNoItem(objCall.objNode);
						chk++;
					}
				}
			}
			if(chk==0){
			 	AddNoItem(objCall.objNode);
			}
		}
	
		DeleteCall(nIndex);
	}
	else
	{
	}
}

function OnOK() {
	var selectedNode = $("#tree_area").dynatree("getActiveNode");	// 'dynatree'로 인해 추가 - 2012-10-19 LSH
	var imsg = '<%=msglang.getString("mail.c.mailbox.newname")%>';		// 새 편지함 이름을 입력하세요!
	var smsg = '<%=msglang.getString("mail.new.folder.list")%>';			//폴더를 생성할 편지함을 선택 하세요.
	
	if (selectedNode != null) // g_objNodeSelected != null
	{
		var nekDatas = selectedNode.data.datas; //g_objNodeSelected.getAttribute("nek_data");
		if (nekDatas.split(':')[1] != "0") {
// 			window.returnValue = nekDatas;
// 			window.close();



			var f_name = $("#f_name").val();
			strname = TrimAll(f_name);
			if (strname == "") {
				alert(imsg);	//새 편지함 이름을 입력하세요!
				$("#f_name").focus();
				return;
			}
		
			parent.setTopCode(nekDatas, f_name);
			parent.OnClickCreate();
			parent.closeDhtmlModalWindow();
		} else {
			alert( smsg );
			return;
		}
	} else {
		alert( smsg );
		return;
	}
}

function OnCancel() {
// 	window.close();
	parent.closeDhtmlModalWindow();
}

document.ondblclick = OnDblClick;

function OnClick() {
	var objSrcElem = window.event.srcElement;
	if (objSrcElem == null) {
		return;
	}

	var className = objSrcElem.className;
	if (className == null) {
		return;
	}

	if ("node" == className) {
		ToggleNode(objSrcElem.parentElement);
	} else if ("clsLabel" == className) {
		var objContainer = objSrcElem.parentElement;
		if (objContainer.id == "" || objContainer.id == null) return;
		SelectNode(objContainer);
	} else if ("clsSelected" == className) {
		OnOK();
	}
}	

function OnBoxNameKeyDown(e) {
	if(/\W/.test(String.fromCharCode(event.keyCode)) && event.keyCode != 46 && event.keyCode !=32 ){	// ( '.' , 'space' ) 허용
		event.returnValue = false;
	}

	if (event.keyCode == 13) {
		//OnClickCreate();
		OnOK();
	}
}

document.onclick = OnClick;
</script>

<body onLoad="//onload_action();" style="margin-left:5px;">

	<table width="100%" height="430" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
		<tr height="40">
			<td>
				<!-- 타이틀 시작 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34">
					<tr> 
						<td height="27"> 
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
								<tr> 
									<td width="35"><img src="../common/images/blue/sub_img/sub_title_email.jpg" width="27" height="27"></td>
									<td class="SubTitle">Mail Box</td>
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
									<td width="200" bgcolor="eaeaea" style="line-height: 0%"><img src="../common/images/blue/sub_img/sub_title_line.jpg" width="200" height="3"></td>
									<td bgcolor="eaeaea" style="line-height: 0%"></td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<!-- 타이틀 끝 -->
			</td>
		</tr>
		<tr>
			<td style="padding:5 5 5 5">
				<table width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed;height:100%;">
					<colgroup><col width="100%"><col width="90"></colgroup>
					<tr>
						<td colspan="2">
							<div id="tree_area" style="overflow: auto; height: 315px;"></div>
							<div style="margin-top:3px; padding-top:3px; border-top:1px solid #d2d2d2; font-weight:bold;">* <%=msglang.getString("mail.new.folder")/*생성할 폴더명*/ %> : <input type="text" id="f_name" name="f_name" maxlength="20" onkeypress="OnBoxNameKeyDown(event)"></div>
							
							<%=msglang.getString("mail.mailbox.name.limit.20") %>
<!-- 							<div id="tree_area" style="margin-top:5px; BORDER-TOP: black 1px solid;BORDER-LEFT: black 1px solid; BACKGROUND: #ffffff; WIDTH: 100%; PADDING: 0px; padding-top:0px; height:350px; "></div> -->
							
							<!-- <div id="tree_area" style="width:100%;height:100%;box-sizing: border-box; -webkit-box-sizing:border-box; -moz-box-sizing: border-box; -ms-box-sizing: border-box;"></div> -->
							<%--
							<script language="javascript">
								AddFolderWithId(tree_area, "MailBox Code", "0", "MailBox Code:0:1:0:mail:TOP", true, "code_0", 0);
							</script>
							 --%>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr height="40">
			<td>
				<!-- 확인 버튼 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td align="center" style="padding-top:6px;">
							<span onclick="OnOK()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.ok") /* 확인 */ %> </span>
							
							<span onclick="OnCancel()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.close") /* 확인 */ %> </span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</HTML>
