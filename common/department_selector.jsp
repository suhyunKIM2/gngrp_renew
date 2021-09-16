<%@page import="org.apache.commons.lang.math.NumberUtils"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="java.sql.*" %>
<% 	request.setCharacterEncoding("utf-8"); %>
<%!
	static final int WINDOW_POPUP 		= 0;        //팝업형 대화상자
	static final int WINDOW_MODALDIALOG = 1;		//Modal 대화상자
	static final int WINDOW_NORMAL 		= 2;		//일반선택

%>
<%!
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
	
	nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);
	nek.common.login.UserVariable uservariable = (nek.common.login.UserVariable)session.getAttribute(nek.common.SessionKey.USER_VAR);

	java.util.Locale locale = request.getLocale();
	if (loginuser != null) locale = new java.util.Locale(loginuser.locale);
	java.util.ResourceBundle msglang = java.util.ResourceBundle.getBundle("messages", locale);

	if(loginuser!=null){
		setImagePath(loginuser.mainType);
	}else{
		setImagePath(1);
	}

	if (isAdmin)
	{
		if (loginuser == null || uservariable == null)
		{
			out.write("<script language='javascript'>alert('오랜 시간 사용하지 않아 로그 유지시간이 초과되었습니다.\\n\\n다시 로그인 해주십시오.');</script>");
			//out.close();
			return;
		}
		else if (loginuser.securityId != 9){
			out.write("<script language='javascript'>alert('관리권한이 없습니다');history.back();</script>");
			//out.close();
			return;
		}
	}
	else
	{
        
		if (loginuser == null || uservariable == null) bOnlyDept = true;
	}

%>

<%
	String depts = uservariable.addressBook;
	List<OrganizationItem> deptsInfo = new ArrayList<OrganizationItem>();
	
	String htmlWinObj = (request.getParameter("winname") == null ? "opener" : request.getParameter("winname"));
	String containerName = (request.getParameter("conname") == null ? "submitForm" : request.getParameter("conname"));
	boolean expand	= "1".equals(request.getParameter("expand")) ? true:false;
	String expandId = "00000000000000";
	if (expand)
	{
		expandId = request.getParameter("expandid");			//확장할 부서ID
		if (expandId == null) expandId = "00000000000000";
	}

	int iOpenMode = WINDOW_NORMAL;
	try {
		iOpenMode = Integer.parseInt(request.getParameter("openmode"));
		if (iOpenMode < WINDOW_POPUP || iOpenMode > WINDOW_NORMAL){
			iOpenMode = WINDOW_NORMAL;
		}
	} catch (Exception e) {
		iOpenMode = WINDOW_NORMAL;
	}

	Connection pconn = null;
	DBHandler db = new DBHandler();
	ArrayList deptList = new ArrayList();
	ArrayList expandList = new ArrayList();
	OrganizationItem corpInfo = null;;

	try {
		db = new DBHandler();
		pconn = db.getDbConnection();
		corpInfo = OrganizationTool.getCorpInfo(pconn);
		if (expand) expandList = OrganizationTool.getParentDeptList(pconn, expandId);

		if (depts.equals("")) {
			deptsInfo.add(OrganizationTool.getSubCorpInfo(pconn, loginuser.dpId));	
		} else {
			String[] items = depts.split(",");
			depts = "";
			for(int i = 0, len = items.length; i < len; i++) {
				String item = items[i];
				if (i != 0) depts += ",";
				depts += "'" + item + "'";
			}
			deptsInfo = OrganizationTool.getDeptsInfo(pconn, depts);
		}
	}
	finally {
		if(db != null) db.freeDbConnection();
	} 
	String caption = request.getParameter("caption");
	String title = request.getParameter("title");
	if (null == caption) caption = corpInfo.itemTitle + " - Address";
	if (null == title) title = corpInfo.itemTitle + " - Address";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>
<title><%=caption%></title>
<% if (iOpenMode < WINDOW_NORMAL) { %>
<!-- <link rel="stylesheet" type="text/css" href="../common/css/popup.css"> -->
<%-- <link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>"> --%>
<% } %>
<link rel="stylesheet" type="text/css" href="../common/css/tree.css">
<!-- <script language="javascript" src="../common/scripts/tree_share.js"></script> -->

<script src='/common/jquery/js/jquery-1.8.1.min.js' type="text/javascript"></script> 
<script src='/common/jquery/ui/1.8.16/jquery-ui.min.js' type="text/javascript"></script> 
<script src='/common/jquery/js/jquery.cookie.js' type="text/javascript"></script> 

<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'> 
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 

<link rel='stylesheet' type='text/css' href='/common/css/style.css'>
<script language="javascript">
	<!--

	window.code = '_CHILDWINDOW_COMM1002';
	
	var ORGUNIT_TYPE_USER = 0;
	var ORGUNIT_TYPE_DEPARTMENT = 1;
	var onlyUser = <%=bOnlyUser %>;
	var onlyDept = <%=bOnlyDept %>;

	// 사용자 부분 데이터
	var userSector = { 
		"title": "<%=loginuser.sectorName %>", 
		"type": "department",
		"isFolder": true, 
		"isLazy": true, 
		"key": "<%=loginuser.sectorId %>", 
		"datas": "<%=loginuser.sectorName %>:<%=loginuser.sectorId %>"
	};

	// 사용자 전사 데이터
	var addressBook = [
	<%	
		if (deptsInfo.size() != 0) {
			for(int i = 0, len = deptsInfo.size(); i < len; i++) {
				OrganizationItem item = deptsInfo.get(i);
				if (i != 0) out.print(",");
	%>
				{
					"title": "<%=item.itemTitle %>", 
					"type": "department",
					"isFolder": true, 
					"isLazy": true, 
					"key": "<%=item.itemId %>", 
					"datas": "<%=item.itemTitle %>:<%=item.itemId %>"
				}
	<%		}
		} else {
			out.print("userSector");
		}
	%>
	];
	
	$(function(){ 
		var rootKey = "<%=corpInfo.itemId%>";
		var rootName = "<%=corpInfo.itemTitle%>";

		<%	for(int i = 0, len = deptsInfo.size(); i < len; i++) {
				if (i != 0) continue;
				OrganizationItem item = deptsInfo.get(i); %>
				rootKey = "<%=item.itemId%>";
				rootName = "<%=item.itemTitle%>";
		<%	} %>
		
	    $("#objTree").dynatree({
	        children: addressBook,	// 초기(루트) 노드를 생성합니다.
// 			[  					
// 				{ "title": rootName
// 	        	, "isFolder": true
// 	        	, "isLazy": true
// 	        	, "key": rootKey
// 	        	, "type": "department"
// 	        	, "datas": rootName + ":" + rootKey
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
		// $("#objTree").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();
		
		<%	if (iOpenMode == WINDOW_NORMAL) { /* 일반선택 */
		 		// 루트 노드를 선택합니다.
		%>
// 		$("#objTree").dynatree("getTree").activateKey(rootKey).toggleSelect();
		<%	} %>
		

		<%	if (iOpenMode < WINDOW_NORMAL) { %>
		$('#objTree').css({"width":$(window).width()-12,"height":$(window).height()-120});
		$(window).bind('resize', function() {
			$('#objTree').css({"width":$(window).width()-12,"height":$(window).height()-120});	
		}).trigger('resize');
		<%	} else { %>
		$('#objTree').css({"width":$(window).width()-12,"height":$(window).height()-37});
		$(window).bind('resize', function() {
			$('#objTree').css({"width":$(window).width()-12,"height":$(window).height()-37});	
		}).trigger('resize');
		<%	} %>
	}); 
	
	
	<% if (bOnlyDept) {%> g_strNoItemText = "하위부서가 없습니다";<%}%>
	function OnDblClick() {
		var objSrcElem = window.event.srcElement;
		if (objSrcElem == null) {
			return false;
		}

		var className = objSrcElem.className;
		if (className == "clsLabel" || className  == "clsSelected") {
			var objContainer = objSrcElem.parentElement;
			var strType = objContainer.getAttribute("nek_type");
			if (strType == "department") {
				<% if (!bOnlyUser) { %>
				if (objContainer.id == "" || objContainer.id == null) return;
				OnOK();
				<%}%>
			}
			<% if(!bOnlyDept){%>
			else if (strType == "user") {
				if (objContainer.id == "" || objContainer.id == null) return;
				OnOK();
			}
			<%}%>
			else {
				if (objContainer.id == "" || objContainer.id == null) return;
				ToggleNode(objContainer);
			}
		}
	}

	function SelectNode(objElem) {
		var type = objElem.getAttribute("nek_type");
		<% if (bOnlyDept && !isAdmin) { %>
		if (type != null && ("user" == type || "department" == type))
		<%} else if (bOnlyDept && isAdmin) { %>
		if (type != null && ("department" == type))
		<%} else if (!bOnlyUser){%>
		if (type != null && ("user" == type || "department" == type))
		<%} else { %>
		if (type != null && ("user" == type))
		<% } %>
		{
			if (g_objNodeSelected != null) {
				g_objNodeSelected.children[2].className = "clsLabel";
			}

			g_objNodeSelected = objElem;

			objElem.children[2].className ="clsSelected";
			return true;
		}
		else return false;
	}

	function ToggleNode(objContainer) {
		var objChildContainer = objContainer.children[3];

		var strType = objContainer.getAttribute("nek_type");
		if (strType != "user")
		{
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
			var type = objContainer.getAttribute("nek_type");
			if (type == "department") {
   				LoadDeptList(objContainer.children[3]);
			}
		}
	}

    function LoadDeptList(objContainer){
		AddInfo(objContainer, g_strLoadingText);
		var strData = objContainer.parentElement.getAttribute("nek_data");
		var datas = strData.split(':');
		//var strXmlSrc = "./recipient_selector_support.jsp?onlydept=<%=(bOnlyDept ? "1":"0")%>&enable=<%=(isAdmin ? "0":"1")%>&dept=" + datas[1];
		var strXmlSrc = "./recipient_selector_support.jsp?onlydept=<%=(bOnlyDept ? "1":"0")%>&isadmin=<%=(isAdmin ? "1":"0")%>&dept=" + datas[1];
		var nCall = NewCall();
		var objXmlReq = new ActiveXObject("MSXML2.XMLHTTP");
		g_Calls[nCall] = new CallObject(objXmlReq, objContainer);
		isLoading = true;
		<% if (expand) {%>
		objXmlReq.open("POST", strXmlSrc, false);
		<%} else {%>
		objXmlReq.open("POST", strXmlSrc, true); 	//비동기적으로
		<%}%>
		objXmlReq.onreadystatechange = Function("LoadDeptListCompleted(" + nCall + ");");
		objXmlReq.send();
	}

	function LoadDeptListCompleted(nIndex){
		if (nIndex == null) return;

		var nReadyState = null;
		var objCall = g_Calls[nIndex];

		nReadyState = objCall.objXmlReq.readyState;

		if (4 != nReadyState) return;	//4: load completed state

		if (objCall != null)
		{
			if (objCall.objXmlReq.status != 200)
			{
				alert("오류 코드: " + objCall.objXmlReq.status + "\r\n" + objCall.objXmlReq.statusText);
				objCall.objNode.innerHTML = "";
				AddNode(objCall.objNode, g_strErrorText);
				return;
			}

			//text/xml
			var contentType = objCall.objXmlReq.getResponseHeader("Content-Type");
			if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
				alert("잘못된 데이터입니다. 오랫동안 사용하지 않아 세션이 종료되었거나, 서버오류입니다!");
				return;
			}

			if (objCall.objNode.parentElement != null) objCall.objNode.parentElement.setAttribute("nek_retrieved", "1");

			var objDepartments = objCall.objXmlReq.responseXML.selectNodes("//ou[@type='department']");
			var objUsers = objCall.objXmlReq.responseXML.selectNodes("//ou[@type='user']");


			objCall.objNode.innerHTML = "";
			if (objDepartments.length + objUsers.length < 1) {
				AddNoItem(objCall.objNode);
			} else {
				for (var i = 0; i < objDepartments.length; i++) {
					var strID	= objDepartments[i].getAttribute("deptid");
					var strName = objDepartments[i].getAttribute("name");
					var deptLevel = objDepartments[i].getAttribute("deptlevel");

					AddFolderWithId(objCall.objNode, strName, "department", strName + ":" + strID + ":" + deptLevel, false, "folder_" + strID);
				}

				for (var i = 0; i < objUsers.length; i++) {
					var strName		= objUsers[i].getAttribute("name");
					var strUID		= objUsers[i].getAttribute("uid");
					var strPosition = objUsers[i].getAttribute("position");
					var strDepartment = objUsers[i].getAttribute("department");
					var strDpid = objUsers[i].getAttribute("dpid");
					if (strPosition == null || strPosition == "") {
						strPosition = "직급없음";
					}

					AddNodeWithId(objCall.objNode, strName + "/" + strPosition,
						"user", strName + ":" + strUID + ":" + strPosition + ":" + strDepartment + ":" + strDpid, "node_" + strUID);
				}
			}
			DeleteCall(nIndex);
		}
		else
		{
		}
	}

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

	function OnOK() {
		var selectedNode = $("#objTree").dynatree("getActiveNode");
		
		if (selectedNode != null && selectedNode.data.type == "department" && onlyUser) {
			selectedNode = null;
		} else if (selectedNode != null && selectedNode.data.type == "user" && onlyDept) {
			selectedNode = null;
		}

		if (selectedNode != null) // g_objNodeSelected != null
		{
			var nekDatas = selectedNode.data.datas; //g_objNodeSelected.getAttribute("nek_data");
			var targetForm = null;
			if (null != <%= htmlWinObj%>)
			{
				var obj = <%=htmlWinObj%>.document.getElementById("<%=containerName%>");

				if (null != obj) targetForm = obj;
			}
		<% if (iOpenMode == WINDOW_MODALDIALOG){ %>
// 			window.returnValue = nekDatas;
// 			window.close();

			switch (<%=functionNumber %>) {
				case 207051: parent.setTransmitData(nekDatas); break;
				case 207052: parent.setReceiveData(nekDatas); break;
				default: try { parent.setDeptSelector(nekDatas); } catch(e) { window.returnValue = nekDatas; } break;
			}
			try { parent.closeDhtmlModalWindow(); } catch(e) { window.close(); }
			
		<% } else if (iOpenMode == WINDOW_POPUP || (iOpenMode == WINDOW_NORMAL && !isAdmin)) {%>

			if (targetForm != null)
			{
	        	if (targetForm.orgadata != null){
					targetForm.orgadata.value = nekDatas;
					targetForm.orgadata.onfocus();
					if (<%=htmlWinObj%>.window.tblInsert) <%=htmlWinObj%>.window.tblInsert();
				}
			}
			<% if (iOpenMode == WINDOW_POPUP) {%>
			window.close();
			<%}%>
		<%} else if (iOpenMode == WINDOW_NORMAL && isAdmin) { %>
			var arrDatas = nekDatas.split(":");
			var titleText = arrDatas[0]; //g_objNodeSelected.children[2].innerHTML;
			var listURL = "../configuration/department_list.jsp?pdpid=" + arrDatas[1];
			listURL += "&pdpname=" + encodeURI(titleText);
			targetForm = parent.dept_frame;
			targetForm.location.href = listURL;
		<%}%>
		}
	}

	//document.ondblclick = OnDblClick;

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
			if (SelectNode(objContainer)){
			<% if (iOpenMode == WINDOW_NORMAL && isAdmin ) {%>
			OnOK();
			<%}%>
			}
		} else if ("clsSelected" == className) {
		}
	}
	//document.onclick = OnClick;

	function OnLoad()
	{
		<%
			if (expand && expandList != null)
			{
				int iSize = expandList.size() - 1;
				OrganizationItem orgaItem = null;
				for (int i=iSize; i>=0 ;i--)
				{
					orgaItem = (OrganizationItem)expandList.get(i);
		%>
<%-- 		ExpandNode(folder_<%=orgaItem.itemId%>); --%>
		<%
				}
			}
		%>

		<% if (iOpenMode == WINDOW_NORMAL && isAdmin){ %>
<%-- 		var topTree = document.getElementById('folder_<%=expandId%>'); --%>
// 		if (SelectNode(topTree)) OnOK();
		<%}%>
		<% if (iOpenMode != WINDOW_NORMAL && expand){ %>
<%-- 		var topTree = document.getElementById('folder_<%=expandId%>'); --%>
// 		SelectNode(topTree);
		<%}%>
		
	}

// 	function dynatreeChange(elem) {
// 		var select = $(elem);
// 		var rootKey = select.val();
// 		var rootName = select.children("option:selected").text();
// 		var rootNode = $("#objTree").dynatree("getRoot");
// 		rootNode.removeChildren();
// 		rootNode.addChild({ "title": rootName, "type": "department", "isFolder": true, "isLazy": true, "key": rootKey, "datas": rootName + ":" + rootKey });
// 		rootNode.render();
// 		$("#objTree").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();	// 루트 노드를 확장합니다.
// 	}

	function dynatreeChange(elem) {
		var select = $(elem);
		var rootNode = $("#objTree").dynatree("getRoot");
		rootNode.removeChildren();
		switch(select.val()) {
			case '1': rootNode.addChild(userSector); break;
			case '2': for(i in addressBook) rootNode.addChild(addressBook[i]); break;
			default : break;
		}
		rootNode.render();
		//$("#treeCtnr").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();	// 루트 노드를 확장합니다.
	}
//-->
</script>
</HEAD>
<BODY bgcolor="#DFDFDF" onload="OnLoad();" style="margin: 0px;overflow: hidden;">
	<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
		<%
			if (iOpenMode < WINDOW_NORMAL)
			{
		%>
		<tr height="40" bgcolor="#FFFFFF">
			<td>
				<!-- 타이틀 시작 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34">
					<tr> 
						<td height="27"> 
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
								<tr> 
									<td width="35">&nbsp;<img src="../common/images/blue/sub_img/sub_title_working.jpg" width="27" height="27" align="absmiddle"></td>
									<td class="SubTitle" style="font-weight:bold;"><%=title %></td>
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
				<!-- 타이틀 끝 -->
			</td>
		</tr>
		<%
			}
		%>
		<tr bgcolor="#FFFFFF">
			<td style="padding:0px 0px 0px 0px">
				<table width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
					<colgroup><col width="100%"><col width="90"></colgroup>
					<tr>
						<td colspan="2" style="vertical-align:top;">
							<div style="padding: 0px 0px 3px 0px;">
								<label style="display:inline-block;width: 30%;text-align: center;"><%=msglang.getString("mail.addresses") /* 주소록 */ %></label>
								<select name="range" style="width: 63%; height: 2em;" class="ui-corner-all" onchange="dynatreeChange(this)">
									<option value="1"><%=msglang.getString("mail.addressbook.sector") /* 부문주소록 */ %></option>
									<option value="2" selected><%=msglang.getString("mail.addressbook.all.company") /* 전사주소록 */ %></option>
								</select>
								<%-- 
								<select style="width: 70%;height: 100%;" onchange="dynatreeChange(this)">
								<%	for(int i = 0, len = deptsInfo.size(); i < len; i++) {
										OrganizationItem item = deptsInfo.get(i); %>
									<option value="<%=item.itemId %>"><%=item.itemTitle %></option>
								<%	} %>
								</select>
								 --%>
							</div>
							<div id="objTree" style="border:1px solid #dfdfdf; background-color:#FFFFFF; overflow: auto; height: 320px; margin:5px;" class="ui-corner-all"></div>
<!-- 							<div id="objTree" style="margin-top: 5px; border-top: black 1px solid; border-left: black 1px solid; background: #ffffff; width: 100%; padding: 0px; height: 350px;"></div> -->
							
<!-- 							<div id="objTree" style="BORDER-TOP: black 1px solid;BORDER-LEFT: black 1px solid; BACKGROUND: #ffffff; overflow:hidden; overflow-x:hidden; overflow-y:hidden; WIDTH: 100%; PADDING-TOP: 0px; HEIGHT: 100%;"></div> -->
							<%--
							<script language="javascript">
								AddFolderWithId(objTree, "<%=corpInfo.itemTitle%>", "department", "<%=corpInfo.itemTitle%>:<%=corpInfo.itemId%>", true, "folder_<%=corpInfo.itemId%>");
							</script>
							 --%>
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
		<%
			if (iOpenMode < WINDOW_NORMAL)
			{
		%>
		<tr height="40">
			<td>
				<!-- 확인 버튼 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td align="center" style="padding-top:6px;">
<!-- 							<img src="../common/images/bu_ok.gif" onclick="OnOK()" style="cursor:hand;">&nbsp;&nbsp; -->
<!-- 							<img src="../common/images/bu_cancel.gif" onclick="OnCancel()" style="cursor:hand;"> -->
							<span onclick="OnOK()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.ok") %> </span>
							<span onclick="OnCancel()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.cancel") %> </span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<%
			}
		%>
	</table>

</BODY>
</HTML>