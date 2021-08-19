<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.common.MessageHelper" %>
<%
	String title = request.getParameter("title");
	String caption = request.getParameter("caption");
	
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String[] viewType = {"0"};

	boolean bOnlyDept = "1".equals(request.getParameter("onlydept")) ? true : false;		//부서만 로드 여부
	boolean bOnlyUser = "1".equals(request.getParameter("onlyuser")) ? true : false;		//부서사용자 모두 선택 가능 여부
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><%=caption %></title>
<%@ include file="./include.common.jsp" %>
<%@ include file="./include.jquery.jsp" %>
<link rel="stylesheet" type="text/css" href="<c:url value="/common/css/popup.css" />" >
<link rel="stylesheet" type="text/css" href="<%= imgCssPath %>">
<%-- <script type="text/javascript" src="<c:url value="/common/scripts/WebTree.js" />"></script> --%>

<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />

<script src="/common/jquery/js/jquery-1.6.4.min.js" type="text/javascript"></script>
<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js" type="text/javascript"></script>
<script src='/common/libs/json-js/json2.js' type="text/javascript"></script>

<script src='/common/jquery/js/jquery.cookie.js' type="text/javascript"></script> 

<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'> 
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 

<script src='/common/libs/json-js/json2.js' type="text/javascript"></script> 
<style type="text/css">
.ui-autocomplete-loading { background: white url('/common/images/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
	max-height: 300px;
	overflow-y: auto;
	/* prevent horizontal scrollbar */
	overflow-x: auto;
}
.ui-autocomplete a {
	white-space: nowrap;
}
* html .ui-autocomplete {
	height: 300px;
}
</style>
<script type="text/javascript">

window.code = '_CHILDWINDOW_COMM1001';

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
<script language="javascript">
	var objRecipients = new Array();
	
	var ORGUNIT_TYPE_USER = 0;
	var ORGUNIT_TYPE_DEPARTMENT = 1;

	var if_list = getFrameByName("if_list");
	var pWindow = (if_list == null)? window.parent: if_list.parent;

	// 사용자 부분 데이터
	var userSector = [			
			{ 
				"title": "<c:out value="${userSector.dpName }" />", 
				"isFolder": true, 
				"isLazy": true, 
	    		"type": "department",
				"key": "<c:out value="${userSector.dpId }" />", 
	    		"datas": "${userSector.dpName}:${userSector.dpId}",
	    		"address": "${userSector.dpName}:${userSector.dpId}"
			}
	];
	
	// 사용자 전사 데이터
	var addressBook = [
		<c:forEach var="dept" items="${addressBookList }" varStatus="status">
			<c:if test="${status.first == false }">,</c:if>
			{ 
				"title": "<c:out value="${dept.dpName }" />", 
				"isFolder": true, 
				"isLazy": true, 
	    		"type": "department",
				"key": "<c:out value="${dept.dpId }" />", 
	    		"datas": "${dept.dpName}:${dept.dpId}",
	    		"address": "${dept.dpName}:${dept.dpId}"
			}
		</c:forEach>
	];
	
	function OnTest() {
		var div = "<div>";
		div += "<p>bOnlyDept: <%=bOnlyDept %> / bOnlyUser: <%=bOnlyUser %></p>";
		div += JSON.stringify(objRecipients, null, '\t');
		div += "</div>";

		getFrameByName("if_list").parent.dhtmlwindow.open(
				"Test", "inline", div, "Test",
				"width=550px,height=380px,center=1,resize=1,scrolling=0", "recal"
		);
	}
	
	function getFrameByName(name) {
		var f_windows = new Array();
		var f_window = null;
		
		if (isOpener && isWindow) 
			f_windows = window.opener.frames;
		else if (isParent && isFrame) 
			f_windows = window.top.frames;

		for(var i = 0; i < f_windows.length; i++) {
			if (f_windows[i].name == name)
				f_window = f_windows[i];
		}
		return f_window;
	}

	function OnCancel() {
		window.returnValue = null;
		if (pWindow.window.addressBookFunction != null) {	// 2013-03-11 dhtmlmodal 추가시 적용 LSH
			addressBookFunction = pWindow.window.addressBookFunction;
			pWindow.window.addressBookFunction = null;
			addressBookFunction(null, window);
		} else {
// 			window.close();
			parent.closeDhtmlModalWindow();
		}
	}

	function OnOK() {
		window.returnValue = objRecipients;
		if (pWindow.window.addressBookFunction != null) {	// 2013-03-11 dhtmlmodal 추가시 적용 LSH
			addressBookFunction = pWindow.window.addressBookFunction;
			pWindow.window.addressBookFunction = null;
			addressBookFunction(objRecipients, window);
		} else {
// 			window.close();
			try {
				parent.setReceive(objRecipients);
				parent.closeDhtmlModalWindow();
			} catch(e) { 
				// TODO: isOpener Check
				window.close(); 
			}
		}
	}

	$(function(){ 
		var rootKey = "${corp.itemId}";
		var rootName = "${corp.itemTitle}";
		var isFirst = true;

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
// 	        	, "addClass": "${corp.itemTitle}:${corp.itemId}"
// 	        	, "address": rootName + ":" + rootKey
// 	        	} 
// 	        ],
	    	onDblClick: function(node, e) {		// 더블 클릭되었을 때 호출합니다.
	    		var targetType = node.getEventTargetType(e); // 클릭한 노드영역
	    		if (targetType) {
	    			OnClickAddRecipient(node);
	    		} else return false;
	    	},
	    	onLazyRead: function(node) {		// 처음으로 확장 될 때 호출됩니다.
				node.appendAjax({
					url: "/common/recipient_selector_support_json.htm",
					data: {
						<%	if (bOnlyUser) { out.print("onlyuser: 1,"); } %>
						<%	if (bOnlyDept) { out.print("onlydept: 1,"); } %>
						dpId: node.data.key
					},
					async: (isFirst)?false:true	// 포커스를 주기 위해서 비동기로 사용
				});
			}
	    }); 

	 	// 루트 노드를 확장합니다.
		//$("#treeCtnr").dynatree("getTree").getNodeByKey(rootKey).toggleExpand();

// 		$("input[name=search]").bind("keydown", function(e) {
// 			if (e.keyCode == $.ui.keyCode.ENTER) $(this).autocomplete('search', $(this).val());
// 		})
		
		$("input[name=search]").autocomplete({
			//"/common/findrecipients2.htm?onlyuser=" + onlyuser + "&onlydept=" + onlydept + "&dpid=" + $('select[name=addressBookList]').val()
			source: function(request, response) {
				var elem = $(this.element);
				$.ajax({
					url: "/common/findrecipients2.htm",
					dataType: "json",
					data: {
						term: request.term,
						<%	if (bOnlyUser) { out.print("onlyuser: 1,"); } %>
						<%	if (bOnlyDept) { out.print("onlydept: 1,"); } %>
						rangetype: $('select[name=range]').val()
					},
					success: function(datas) {
						elem.removeClass("ui-autocomplete-loading");
						if (datas.length == 0) {
							alert("\"" + elem.val() + "\", <spring:message code='t.search.no.results' text='검색결과가 없습니다.' />");
						} else if (datas.length == 1) {
							elem.val("");
							//alert(JSON.stringify(datas[0]));
							
							var data = datas[0].id;

							if (data.type == 'P') {	// type == orgaTree._NT_ITEM
								<%	if (!bOnlyDept) { %>
								var objAddress = new Object();
								objAddress.type = ORGUNIT_TYPE_USER;
								objAddress.name = data.username;
								objAddress.id = data.userid;
								objAddress.position = data.upname;
								objAddress.department = data.dpname;
								objAddress.sabun = data.sabun;
								objAddress.dpid = data.dpid;
								objAddress.duty = data.udname;
//			 					objAddress.orders = datas[7];		//03-15
//			 					objAddress.bankNm = datas[9];		//04-12
//			 					objAddress.trnAccNo = datas[10];		//04-12
								AddRecipient(objAddress, false);
								<%	} %>
							} else if (data.type == 'D') {
								<%	if (!bOnlyUser) { %>
								var objAddress = new Object();
								objAddress.type = ORGUNIT_TYPE_DEPARTMENT;
								objAddress.name = data.dpname;
								objAddress.id = data.dpid;

								if (confirm(objAddress.name + ", <spring:message code='c.include.subdepartment' text='예하부서를 포함하시겠습니까?' />")){
									objAddress.includeSub = true;
								} else objAddress.includeSub = false;
								AddRecipient(objAddress, false);
								<%	} %>
							}
							
							
						} else {
							response(datas);
						}
					}
				});
			},
			autoFocus: false,
			minLength: Number.MAX_VALUE,
			delay: 10,
			select: function(event, ui) { 
				$(event.target).val("");
// 				alert(JSON.stringify(ui.item));
				
				var data = ui.item.id;

				if (data.type == 'P') {	// type == orgaTree._NT_ITEM
					<%	if (!bOnlyDept) { %>
					var objAddress = new Object();
					objAddress.type = ORGUNIT_TYPE_USER;
					objAddress.name = data.username;
					objAddress.id = data.userid;
					objAddress.position = data.upname;
					objAddress.department = data.dpname;
					objAddress.sabun = data.sabun;
					objAddress.dpid = data.dpid;
					objAddress.duty = data.udname;
// 					objAddress.orders = datas[7];		//03-15
// 					objAddress.bankNm = datas[9];		//04-12
// 					objAddress.trnAccNo = datas[10];		//04-12
					AddRecipient(objAddress, false);
					<%	} %>
				} else if (data.type == 'D') {
					<%	if (!bOnlyUser) { %>
					var objAddress = new Object();
					objAddress.type = ORGUNIT_TYPE_DEPARTMENT;
					objAddress.name = data.dpname;
					objAddress.id = data.dpid;

					if (confirm(objAddress.name + ", <spring:message code='c.include.subdepartment' text='예하부서를 포함하시겠습니까?' />")){
						objAddress.includeSub = true;
					} else objAddress.includeSub = false;
					AddRecipient(objAddress, false);
					<%	} %>
				}
				return false;
			},
			open: function(event, ui) {
				$( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
			},
			close: function(event, ui) {
				$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
			}
		});

		$("input[name=search]").bind("keydown.autocomplete",function( event ){
			if (event.keyCode == $.ui.keyCode.ENTER) {
				$(this).autocomplete('option', 'minLength', 1);
				$(this).autocomplete('search', $(this).val());
				$(this).autocomplete('option', 'minLength', Number.MAX_VALUE);
				event.preventDefault();
			}
		});
		
		$("#searchBtn").click(function() {
			$("input[name=search]").autocomplete('option', 'minLength', 1);
		    $("input[name=search]").autocomplete('search', $('input[name=search]').val());
			$("input[name=search]").autocomplete('option', 'minLength', Number.MAX_VALUE);
		});
		
		$('#search').focus();

		var isiPad = navigator.userAgent.toLowerCase().indexOf("ipad");
		if( isiPad > -1 ) {
			$('#select_recipients').toggle();
			$('#select_recipients_div').toggle();
		}
		
	 	isFirst = false;

		var objSelecteds = null;
		//objSelecteds = window.dialogArguments;
		
		// 2013-03-11 dhtmlmodal 추가 LSH
		try {
			objSelecteds = (window.dialogArguments == null)? 
					pWindow.window.addressBookArgument: window.dialogArguments;
			pWindow.window.addressBookArgument = null;
			
			if (objSelecteds == null) {
				if (parent.getReceive)
					objSelecteds = parent.getReceive(); // `기안서 작성`에서 `수신처 지정`호출
			}
		} catch(e) { try{ console.log(e); } catch(e) {} }
		// end
		
		for (var i = 0; i < objSelecteds.length; i++) {
			objRecipients.push(objSelecteds[i]);
		}
	
		RefreshRecipientsList();

// 		$('#edit_recipient').focus();

	}); 

	// 사용자 추가는 가능하나, 삭제가 안됨. - 수정해야 함.
	function ipadSelectSync() {
		
		var isiPad = navigator.userAgent.toLowerCase().indexOf("ipad");
		if( isiPad == -1 ) return;
		
			var sel = $("#select_recipients");
			var div = $("#select_recipients_div");

			oplen = $('#select_recipients option');
			div.html("");

			for( var i=0; i < oplen.length; i++ ) {
				var ob = oplen.eq(i);
				
				ids = "div_sel_" + i;
				txtId = ids + "_text";
				valId = ids + "_value";

				strText = ob.text();
				strVal = ob.attr("value");
				
				//console.log( i + " - " + strText + " / " + strVal );
				
				var addDiv = $('<div onclick="javascript:recipients_div_del(\'' + ids + '\');" style="cursor:pointer; width:100%; white-space:pre; " id="' + ids + '"></div>');
				/*
				addDiv.hover( function() {
					this.css( 'background-color', '#dfdfdf' );
				});
				*/
				
				addDiv.append( $('<span id="' + txtId + '"></span>').text( strText ) );
				addDiv.append( $('<span style="display:none;" id="' + valId + '">' + strVal + '</span>') );
				
				div.append( addDiv );
			}
	}
	// ipad 에서 삭제 하는 경우
	function recipients_div_del( args ) {
		//alert( args );
		var selIds = args.split("_");
		var selId = selIds[selIds.length-1];

		var sel = $('#select_recipients');
		sel = $('#select_recipients option');
		sel.eq(selId).attr("selected", "selected");
		
		OnClickRemoveRecipients();
	}
	
	function getFrameByName(name) {
		var isWindow = (top == window);
		var isFrame = (window.frameElement != null);
		var isOpener = (window.opener != null);
		var isParent = (window.parent != null);
		var f_windows = new Array();
		var f_window = null;
		
		if (isOpener && isWindow) 
			f_windows = window.opener.frames;
		else if (isParent && isFrame) 
			f_windows = window.top.frames;

		for(var i = 0; i < f_windows.length; i++) {
			if (f_windows[i].name == name)
				f_window = f_windows[i];
		}
		return f_window;
	}

	function RefreshRecipientsList() {
		var objList = document.getElementById("select_recipients");
		while (objList.options.length > 0) {
			objList.options.remove(0);
		}
		for (var i = 0; i < objRecipients.length; i++) {
			var objRecipient = objRecipients[i];
			var objOption = document.createElement("OPTION");
			objOption.text = AddressToDisplayString(objRecipient);
			objOption.value = AddressToString(objRecipient);
			objList.options.add(objOption);
		}
		
		ipadSelectSync();
	}
	
	function OnClickRemoveRecipients() {
		var objList = document.getElementById("select_recipients");
		var bRefresh = false;
		for (var i = objList.options.length - 1; i >= 0; i--) {
			if (objList.options[i].selected) {
				RemoveRecipient(objList.options[i].value);
				bRefresh = true;
			}
		}
		if (bRefresh) {
			RefreshRecipientsList();
		}
	}

	function OnClickAddRecipient(node) {
		var type, datas;
		if(node){
			type = node.data.isFolder; // orgaTree.getType(node);
			datas = node.data.address.split(":"); // orgaTree.getData(node).split(":");
		} else {
			var selectedNode = $("#treeCtnr").dynatree("getActiveNode");
			if (selectedNode == null) {
				alert("<spring:message code='t.select.target.add' text='추가할 대상을 선택하세요!' />");
				return;
			}
			type = selectedNode.data.isFolder; //orgaTree.getSelectedNodeType();
			datas = selectedNode.data.address.split(":"); //orgaTree.getSelectedData().split(":");
		}
		
		//alert( type );
		//alert( ORGUNIT_TYPE_USER );

		if (!type) {	// type == orgaTree._NT_ITEM
			<% if(!bOnlyDept){%>
			if (datas != null && datas.length >= 4) {
				var objAddress = new Object();
				objAddress.type = ORGUNIT_TYPE_USER;
				objAddress.name = datas[0];
				objAddress.id = datas[2];
				objAddress.position = datas[1];
				objAddress.department = datas[6];
				objAddress.sabun = datas[8];
				objAddress.dpid = datas[9];
				objAddress.orders = datas[7];		//03-15
				objAddress.duty = datas[10];		//03-15
// 				objAddress.bankNm = datas[9];		//04-12
// 				objAddress.trnAccNo = datas[10];		//04-12
				AddRecipient(objAddress, false);
			}
			<%}%>
		} else if (type) {	// type == orgaTree._NT_FOLDER
			<% if (!bOnlyUser) { %>
			if (datas != null && datas.length > 1) {
				
				if ( ORGUNIT_TYPE_USER ) return;
				
				var objAddress = new Object();
				objAddress.type = ORGUNIT_TYPE_DEPARTMENT;
				objAddress.name = datas[0];
				objAddress.id = datas[1];

				if (confirm(objAddress.name + ", <spring:message code='c.include.subdepartment' text='예하부서를 포함하시겠습니까?' />")){
					objAddress.includeSub = true;
				} else objAddress.includeSub = false;
				AddRecipient(objAddress, false);
			}
			<%}%>
		}
	}
 
	function AddRecipient(objAddress, bSilent) {
		var type = objAddress.type;
		for (var i = 0; i < objRecipients.length; i++) {
			if (objRecipients[i].type == type && objRecipients[i].id == objAddress.id) {
				if (!bSilent) {
					alert("'" + AddressToDisplayString(objAddress) + "' <spring:message code='c.selected' text='님은 이미 선택되었습니다!' />");
				}
				return;
			}
		}
		objRecipients.push(objAddress);
		RefreshRecipientsList();
	}

	function RemoveRecipient(strAddress) {
		var objNewRecipients = new Array();
		var nIndex = -1;
		var objAddress = ParseAddress(strAddress);
		if (objAddress != null) {
			for (var i = 0; i < objRecipients.length; i++) {
				if (objAddress.type != objRecipients[i].type ||
					objAddress.id != objRecipients[i].id) {
					objNewRecipients.push(objRecipients[i]);
				}
			}
			objRecipients = objNewRecipients;
		}
	}

	function ParseAddress(strData) {
		if (strData == "") return null;
	
		if (strData.charAt(0) == 'P') {
			//user, P:이름:UID:직급
			var segments = strData.split(':');
			if (segments.length < 5) {
				return null;
			}
			var objAddress = new Object();
			objAddress.type		= ORGUNIT_TYPE_USER;
			objAddress.name		= segments[1];
			objAddress.id		= segments[2];
			objAddress.position	= segments[3];
			objAddress.department = segments[4];
			objAddress.sabun = segments[5];
			objAddress.dpid = segments[6];
			objAddress.orders 	= segments[7];		//03-15
// 			objAddress.bankNm 	= segments[8];		//04-12
// 			objAddress.trnAccNo	= segments[9];		//04-12
			return objAddress;
		} else if (strData.charAt(0) == 'D') {
			//department, D:부서이름:부서ID:(+|-)
			var segments = strData.split(':');
			if (segments.length < 4) {
				return null;
			}
			var objAddress = new Object();
			objAddress.type = ORGUNIT_TYPE_DEPARTMENT;
			objAddress.name = segments[1];
			objAddress.id	= segments[2];
			objAddress.includeSub = (segments[3] == "+");
			return objAddress;
		}
	
		return null;
	}

	function AddressToString(objAddress) {
		if (objAddress.type == ORGUNIT_TYPE_USER) {
			return "P:" + objAddress.name + ":" + objAddress.id + ":" + objAddress.position
				+ ":" + objAddress.department + ":" + objAddress.sabun + ":" + objAddress.dpid + ":" + objAddress.orders;
		} else if (objAddress.type == ORGUNIT_TYPE_DEPARTMENT) {
			return "D:" + objAddress.name + ":" + objAddress.id + ":"
				+ (objAddress.includeSub ? "+" : "-");
		}
		return "";
	}

	function AddressToDisplayString(objAddress) {
		var strDisplay = "";
		if (objAddress.type == ORGUNIT_TYPE_USER) {
			var strTitle = objAddress.position;
			strDisplay += objAddress.name;
			strDisplay += "/";
			strDisplay += strTitle;
			strDisplay += "/";
			strDisplay += objAddress.department;
		} else if (objAddress.type == ORGUNIT_TYPE_DEPARTMENT) {
			strDisplay += objAddress.name;
			if (objAddress.includeSub) {
				strDisplay += "[+]";
			} else {
				strDisplay += "[-]";
			}
		}
		return strDisplay;
	}

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

<body height="100%" bgcolor="#dfdfdf" style="margin:0px;"> <%-- onload="OnLoad();" --%>
	<table width="100%" cellspacing="0" cellpadding="0" border="0" sbgcolor="#DFDFDF" style="table-layout:fixed">
		<tr height="40">
			<td bgcolor="white" style="padding:5px;">
				<!-- 타이틀 시작 -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" bgcolor="white">
					<tr> 
						<td height="27">
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="35"><img src="../common/images/blue/sub_img/sub_title_configuration.jpg" width="27" height="27"></td>
									<td class="SubTitle" style="font-size:10pt;"><b><%=title %></b></td>
									<td valign="bottom" width="*" align="right">
										<!--<a onclick="OnTest()" class="button white medium"> JSON </a>-->
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
		<tr height="1" bgcolor="#aaa"><td colspan=1></td></tr>
		<tr height="1" bgcolor="#fff"><td colspan=1></td></tr>
		<tr>
			<td style="padding: 5px; padding-bottom:0px;" bgcolor="#DFDFDF">
				<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
					<tr>
						<td>
							<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
								<tr>
									<td width="47%">
										<div style="border:1px solid #aaa;  background-color:#fff; padding:3px 5px 5px 5px;" class="ui-corner-all">
													
										<table width="100%" border="0">
											<tr height="30">
												<td width="64" style="text-align: center;">
													<spring:message code='mail.addresses' text='주소록' />
												</td>
												<td valign="top" align="right">
													<select name="range"  style="width:90%;" class="ui-corner-all" onchange="dynatreeChange(this)">
														<option value="1"><spring:message code='mail.addressbook.sector' text='부문주소록' /></option>
														<option value="2" selected><spring:message code='mail.addressbook.all.company' text='전사주소록' /></option>
													</select>
													<%-- 
													<select name="addressBookList" style="width:90%;" class="ui-corner-all" onchange="dynatreeChange(this)">
													<c:forEach var="dept" items="${addressBookList }" varStatus="status">
														<option value="<c:out value="${dept.dpId }" />"><c:out value="${dept.dpName }" /></option>											
													</c:forEach>
													</select>
													 --%>
												</td>
											</tr>
										</table>

										<table width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed;margin-bottom: 2px;">
											<tr>
												<td width="*">
													<input type="text" id="search" name="search" style="width:90%" class="ui-corner-all" />
												</td>
												<td width=63 align=right>
													<input id="searchBtn" type="button" value="검색" style="width:60px">
												</td>
											</tr>
<!-- 											<tr height="1" bgcolor="#aaa"><td colspan=2></td></tr> -->
<!-- 						                    <tr height="1" bgcolor="#FFFFFF"><td colspan=2></td></tr> -->
										</table>
																				
										<div id="treeCtnr" style="border:1px solid #ddd; background-color:#fff; overflow: auto; height: 243px;"></div>
<%-- 									<div id="treeCtnr" style="margin-top:5px; BORDER-TOP: black 1px solid;BORDER-LEFT: black 1px solid; BACKGROUND: #ffffff; WIDTH: 100%; PADDING: 0px; padding-top:0px; height:243px; "></div> --%>
										</div>
									</td>
									<td>
										<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed">
											<tr>
												<td width="80" align="center" style="padding-left:5px;">
													<input type="button" value="<spring:message code='t.add' text='추가' /> >>" style="width:65px;" onclick="OnClickAddRecipient()"><br><br>
													<input type="button" value="<< <spring:message code='t.delete' text='삭제' />" style="width:65px;" onclick="OnClickRemoveRecipients()">
												</td>
												<td>
													<select multiple name="select_recipients" id="select_recipients" style="font-family:Gulim; font-size:9pt; width: 100%; height: 310px;" ondblclick="javascript:OnClickRemoveRecipients()">
													</select>
													<div id="select_recipients_div" style="display:none; width:100%; height:310px; background:#fff; border:1px solid #aaa;">
													</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr height="5"><td ></td></tr>
	</table>
	<!-- 확인 버튼 -->
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr height="1" bgcolor="#aaa"><td></td></tr>
		<tr height="1" bgcolor="#efefef"><td></td></tr>
		<tr bgcolor="#DFDFDF">
			<td align="center" style="padding-top:6px;">
			
				<a onclick="OnOK()" class="button white medium" style="width:65px;"><spring:message code='t.ok' text='확인' /></a>
				<a onclick="OnCancel()" class="button white medium" style="width:65px;"><spring:message code='t.cancel' text='취소' /></a>
				<!-- 		
				<img src="../common/images/bu_ok.gif" onclick="OnOK()" style="cursor:hand;">&nbsp;&nbsp;
				<img src="../common/images/bu_cancel.gif" onclick="OnCancel()" style="cursor:hand;">
				 -->
			</td>
		</tr>
	</table>
</body>
</html>