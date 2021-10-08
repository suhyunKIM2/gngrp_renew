<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%--@ page errorPage="../error.jsp" --%>
<%--@ include file="../common/usersession.jsp"--%>
<%!
	private String imagePath = "../common/images/";
	private String scriptPath = "../common/scripts";
	private String cssPath = "../common/css";
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
	String menuCode = request.getParameter("menucode");
	String subMenuCode = request.getParameter("submenucode");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<TITLE>좌측 메뉴</TITLE>
<link rel="stylesheet" type="text/css" href="<c:url value="/common/css/list.css" />" >
<link rel="stylesheet" type="text/css" href="<c:url value="/common/css/popup.css" />" >
<!--<script src="../common/scripts/menu_tree.js"></script>-->
<script type="text/javascript" src="<c:url value="/common/scripts/WebTree.js" />"></script>
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

IMG.node
{
	vertical-align: middle;
/*	width : 18px; */
/*	height : 18px; */
	cursor: hand;
}

.png24 {
   tmp:expression(setPng24(this));
}

</style>
</head>
<script src="<%=scriptPath %>/scripts/flash_patch.js"></script>
<script type="text/javascript">
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
	var imgPath = "/common/images/icons/" ;
	var menucode = "<%=menuCode%>";
	var submenucode = "<%=subMenuCode%>";

	var menuTree = new WebTree();
	menuTree.setExpandImg("../common/images/icons/minus1.gif");
	menuTree.setCollapseImg("../common/images/icons/plus1.gif");
	menuTree.setFdCloseImg("../common/images/icons/folder.gif");
	menuTree.setFdOpenImg("../common/images/icons/folderopen.gif");
	menuTree.setItmImg("../common/images/icons/page1.gif");
	menuTree.setBlankImg("../common/images/tree/blank.gif");
	menuTree.setInfoImg("../common/images/tree/noitem.gif");
	
	function onload_action(){
		menuID = menucode;
		subMenuID = submenucode;

		menuTree.rootContainer = document.getElementById("tree_area");
		var xmlHttpRequest = getNewXMLHttpRequest();
		var requestURL = "<c:url value="/common/menu_xml.jsp?menucode=" />" + menuID;
		try {
			xmlHttpRequest.onreadystatechange = function(){OnGetMenuCompleted(this, menuTree.rootContainer);};
			xmlHttpRequest.open("POST", requestURL, true);
			xmlHttpRequest.send();
		} catch (e) {
			alert(e);
		}
		
		menuTree.onloadChildNode = function(folder){
			var xmlHttpRequest = getNewXMLHttpRequest();
			var nodeData = folder.getAttribute(menuTree._NK_DATA);
			var datas = nodeData.split(':');
			var subCateId = (datas[7]==null) ? "" : datas[7];			
			var requestURL = "<c:url value="/common/menu_xml.jsp?menucode=" />" + datas[1] + "&subcateid=" + subCateId;
			try {
				xmlHttpRequest.onreadystatechange = function(){OnGetMenuCompleted(this, folder);};
				xmlHttpRequest.open("POST", requestURL, true);
				xmlHttpRequest.send();
			} catch (e) {
				alert(e);
			}
		}
		menuTree.onclickFolder = function(folder){return OnOK(folder);}
		menuTree.onclickItem = function(item){return OnOK(item);}
		menuTree.ondblclickFolder = function(folder){return OnOK(folder);}
		menuTree.ondblclickItem = function(item){return OnOK(item);}
		/*if(submenucode != ""){
			var expFolder = document.getElementById("code_" + submenucode);
			if(expFolder != null) menuTree.onexpandFolder(expFolder);
		}*/
	}

	function OnGetMenuCompleted(xhr, container){
		if(xhr.readyState == 4) {
			if(xhr.status == 200){				
				contentType = xhr.getResponseHeader("Content-Type");
				if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
					menuTree.makeInfoNode(container,"unsupported content type: " + contentType);
				} else {
					var objCollect = xhr.responseXML.getElementsByTagName("doc");
					if (objCollect.length == 0) {
						menuTree.makeInfoNode(container, "메뉴가 존재하지 않습니다");
					} else {
						for (var i = 0; i < objCollect.length; i++) {
							var code	= objCollect[i].getAttribute("code");	//0
							var catName = objCollect[i].getAttribute("name");	//1
							var url = objCollect[i].getAttribute("url");		//2
							var isChildExist = objCollect[i].getAttribute("isChildExist");	//3
							var popup = objCollect[i].getAttribute("popup");	//4
							var codeLevel = objCollect[i].getAttribute("codelevel");	//5
							var urlFlag = objCollect[i].getAttribute("urlflag");	//6
							var subCateID = objCollect[i].getAttribute("subcateid");	//7
							var iconFile = objCollect[i].getAttribute("iconfile");	//8
							var codeKey = objCollect[i].getAttribute("codekey");	//9
							if(isChildExist=="1"){
								//var menu = menuTree.makeFolder(container, catName, catName + ":" + code + ":" + isChildExist + ":" + url+ ":" + popup + ":" + codeLevel + ":" + urlFlag + ":" + subCateID + ":" + iconFile);
								//menu.setAttribute("usr_id", "code_" + code);
								var menu = menuTree.makeFolderWithId(container, "code_" + code, catName, catName + ":" + code + ":" + isChildExist + ":" + url+ ":" + popup + ":" + codeLevel + ":" + urlFlag + ":" + subCateID + ":" + iconFile);
								menu.setAttribute("usr_strType", code);
								menu.setAttribute("usr_selectedNode", i);
								menu.setAttribute("usr_expandChild", true);
								if(iconFile != "") menuTree.setCustomImg(menu, imgPath + iconFile);
							}else{
								//var subMenu = menuTree.makeItem(container, catName, catName + ":" + code + ":" + isChildExist + ":" + url + ":" + popup + ":" + codeLevel + ":" + urlFlag + ":" + iconFile);
								//subMenu.setAttribute("usr_id", "code_" + code);
								var subMenu = menuTree.makeItemWithId(container, "code_" + code, catName, catName + ":" + code + ":" + isChildExist + ":" + url + ":" + popup + ":" + codeLevel + ":" + urlFlag + ":" + iconFile);
								subMenu.setAttribute("usr_strType", code);
								if(iconFile != "") menuTree.setCustomImg(subMenu, imgPath + iconFile);									
							}
						}
					}
				}
			} else {
				menuTree.makeInfoNode(container, "request status error : " + xhr.status);
			}
			container.setAttribute("isLoaded", true);
		}
	}	
	
	function OnOK(node) {
		var nek_datas = menuTree.getData(node).split(":");
		var listURL =  "/common/menuleft.jsp?menucode=MENU04001"; //+ nek_datas[1];
		if(nek_datas[3] == "" || nek_datas[3] ==null){
			if(nek_datas[2]==0) alert("지정된 경로가 없습니다.");
			return false;
		}
		
		listURL = nek_datas[3];
		listURL = listURL.replace(/＆/g, "&");
		//@today를 오늘일자로 변경(일정용)
		//listURL = listURL.replace( /@today/gi, dToday );

		if(nek_datas[4].charAt(0) == "1"){
			if(nek_datas[1]=="MENU0101")
			{//메일작성
				winleft = (screen.width - 800) / 2;
				wintop = (screen.height - 650) / 2;
				window.open(listURL , "" , "scrollbars=no,width=800, height=650, top="+ wintop +", left=" + winleft);
			}else{
				winleft = (screen.width - 755) / 2;
				wintop = (screen.height - 610) / 2;
				window.open(listURL , "" , "scrollbars=yes,width=755, height=610, top="+ wintop +", left=" + winleft);
			}
		}else{
			//parent.frBody.location.href = listURL;
			if(listURL.indexOf("?")>-1){
				if (parent.main != null)	parent.main.location.href = listURL + "&menuid=" + nek_datas[1] + "&codekey=" + (nek_datas.length==10 ? nek_datas[9] : nek_datas[8]);
			}else{
				if (parent.main != null)	parent.main.location.href = listURL + "?menuid=" + nek_datas[1] + "&codekey=" + (nek_datas.length==10 ? nek_datas[9] : nek_datas[8]);
			}
		}
		return  true;
	}	
</script>
<script language="JavaScript">
function onload_img(){
	var subObj = document.getElementById("leftImg");
	if(menucode=="MENU01"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_mail.jpg' width='207' height='82'>";
	}else if(menucode=="MENU02"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_approval.jpg' width='207' height='82'>";
	}else if(menucode=="MENU03"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_dms.jpg' width='207' height='82'>";
	}else if(menucode=="MENU04"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_sche.jpg' width='207' height='82'>";
	}else if(menucode=="MENU05"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_board.jpg' width='207' height='82'>";
	}else if(menucode=="MENU06"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_community.gif' width='207' height='82'>";
	}else if(menucode=="MENU07"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_working.jpg' width='207' height='82'>";
	}else if(menucode=="MENU08"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_config.jpg' width='207' height='82'>";
	}else if(menucode=="MENU09"){
		subObj.innerHTML = "<img src='<%=imagePath %>/sub_img/subtitle_admin.jpg' width='207' height='82'>";
	}
}

function setPng24(obj) {
	obj.width=obj.height=1;
    obj.className=obj.className.replace(/\bpng24\b/i,'');
    obj.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+ obj.src +"',sizingMethod='image');"
    obj.src='';
    return '';
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
</script>

<body onload="javascript:onload_img();onload_action();" style="padding-left:5px;padding-bottom:5px;">

<table width="207" border="0" cellspacing="0" cellpadding="0" height="100%">
	<tr>
    	<td height="82" background="<%=imagePath %>/sub_img/submenu_top_bg.jpg"><span id="leftImg"><img src="<%=imagePath %>/sub_img/sub_img/subtitle_img.jpg" width="207" height="105"></span></td>
	</tr>
	<tr> 
		<td valign="top">
			<table width="207" border="0" cellspacing="0" cellpadding="0" height="100%">
				<tr>
					<td width="9" valign="top"> 
						<table width="9" border="0" cellspacing="0" cellpadding="0" background="<%=imagePath %>/sub_img/submenu_left_linebg.jpg" height="100%">
							<tr>
								<td height="350"><img src="<%=imagePath %>/sub_img/submenu_left_bg.jpg" width="9" height="100%"></td>
							</tr>
							<tr>
								<td valign="bottom"><img src="<%=imagePath %>/sub_img/submenu_left_bottom_bg.jpg" width="9" height="23"></td>
							</tr>
						</table>
					</td>
					<td width="189" valign="top">
						<table width="189" border="0" cellspacing="0" cellpadding="0" height="100%">
							<tr>
								<td bgcolor="#FFFFFF" valign="top">
									<table width="189" border="0" cellspacing="0" cellpadding="5" height="100%">
										<tr>
											<td width="184" align="center" valign="top">
												<table width=100% height=100% cellspacing=0 cellpadding=0 border=0 style="border:0px; border-collapse:collapse;">
													<tr height=100%>
														<td style="padding-left:10px; padding-right:5px;" valign=top id="tree_areas" bgcolor=#FFFFFF>
															<div id="tree_area" style="position:relative; padding-right:2px; left:0px; overflow:auto; overflow-y:auto;overflow-x:hidden;width:100%;height:expression(document.body.clientHeight-110);">
															</div>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td background="<%=imagePath %>/sub_img/submenu_bottom_bg.jpg" height="12"></td>
							</tr>
						</table>
					</td>
					<td width="9" valign="top"> 
						<table width="9" border="0" cellspacing="0" cellpadding="0" background="<%=imagePath %>/sub_img/submenu_right_linebg.jpg" height="100%">
							<tr> 
								<td height="350"><img src="<%=imagePath %>/sub_img/submenu_right_bg.jpg" width="9" height="100%"></td>
							</tr>
							<tr> 
								<td valign="bottom"><img src="<%=imagePath %>/sub_img/submenu_right_bottom_bg.jpg" width="9" height="23"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>