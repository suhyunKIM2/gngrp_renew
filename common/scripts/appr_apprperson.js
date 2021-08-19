var ORGUNIT_TYPE_USER = 0;
var objRecipients = new Array();
var SNOPOSITION_HAN = "<spring:message code='appr.positon.no' text='직급없음' />";
var SNODUTYHAN = "<spring:message code='t.not.job.title' text='직책없음' />";

//document.onclick = OnClick;
//document.ondblclick = OnDblClick;


//return xmlhttprequest
function createXmlHttp() {
	var xmlhttp;
	if (window.XMLHttpRequest)
	{// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();
	}
	else
	{// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	return xmlhttp;
}

function OnCancel() {
//	window.returnValue = null;
//	window.close();
	parent.closeDhtmlModalWindow();
}

function OnOK() {
	if (objRecipients.length < 1) {
		alert("<spring:message code='appr.not.approver' text='결재자가 없습니다.' />\n\n"
				+ "<spring:message code='appr.approver.select' text='결재자를 선택하십시오' />");
		return;
	}

	// 2013-08-23 김성진 중간 결재선 변경시 합의자는 마지막으로 선택할수 없음.
	if (cmd == "EDIT" && ApprType != "6") {
		// 추가방식이 역순으로 변경되면서 마지막 순번이 0 이됨 2014-07-16 LSH (unshift)
//		var objApprVal = objRecipients[0]; // objRecipients.length - 1
		// 추가방식 정방향으로 변경 2015.11.24 대현 (push)
		var objApprVal = objRecipients[objRecipients.length - 1]; // 0
		if (objApprVal.apprtype == "H") {
			alert("<spring:message code='appr.lastAgreedTo' text='마지막의 합의자를 지정할수 없습니다.' />");
			return;
		}
	}

	// window.returnValue = objRecipients;
	// window.close();
	if (ApprType != "5") {
		parent.setApprPer(objRecipients);
	} else { // 신청결재
		parent.setApprPer_req(objRecipients);
	}
	parent.closeDhtmlModalWindow();
}

function OnClicks() {
//	var objSrcElem = window.event.srcElement;
	var objSrcElem = event.target || event.srcElement;
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
		SelectNode(objContainer);
	} else if ("clsSelected" == className) {
	}
}


function OnDblClick() {
    bFirst = false ;

	var objSrcElem = window.event.srcElement;
	if (objSrcElem == null) {
		return false;
	}

	var className = objSrcElem.className;
	if (className == "clsLabel" || className  == "clsSelected") {
		var objContainer = objSrcElem.parentElement;
		var strType = objContainer.getAttribute("nek_type");
		if (strType == "user") {
			OnClickAddRecipient();
		} else {
			ToggleNode(objContainer);
		}
	}
}

function SelectNode(objElem) {
	var type = objElem.getAttribute("nek_type");
	if (type != null && "user" == type ) {
		if (g_objNodeSelected != null) {
			g_objNodeSelected.children[2].className = "clsLabel";
		}

		g_objNodeSelected = objElem;
		objElem.children[2].className ="clsSelected";
	}
}

function ToggleNode(objContainer) {
	var objChildContainer = objContainer.children[3];

	var strType = objContainer.getAttribute("nek_type");
	if (strType == "department") {
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
			LoadOrgUnits(objContainer.children[3]);
		}
	}
}


function LoadOrgUnits(objContainer) {
	AddInfo(objContainer, g_strLoadingText);
	var strData = objContainer.parentElement.getAttribute("nek_data");
	var datas = strData.split(':');
	var strXmlSrc = "../common/recipient_selector_support.htm?dpId=" + datas[1];

	var nCall = NewCall();
	//var objXmlReq = new ActiveXObject("MSXML2.XMLHTTP");
	var objXmlReq = createXmlHttp();
	
	g_Calls[nCall] = new CallObject(objXmlReq, objContainer);
	objXmlReq.open("POST", strXmlSrc, false);
    //objXmlReq.open("POST", strXmlSrc, false);
	objXmlReq.onreadystatechange = Function("LoadOrgUnitsCompleted(" + nCall + ");");
	objXmlReq.send();
}


function LoadOrgUnitsCompleted(nIndex) {
	if (nIndex == null) return;

	var nReadyState = null;
	var objCall = g_Calls[nIndex];

	nReadyState = objCall.objXmlReq.readyState;

	if (4 != nReadyState) return;	//4: load completed state

	if (objCall != null)
	{
		if (objCall.objXmlReq.status != 200)
		{
			alert("Error Code: " + objCall.objXmlReq.status + "\r\n" + objCall.objXmlReq.statusText);
			objCall.objNode.innerHTML = "";
			AddNode(objCall.objNode, g_strErrorText);
			return;
		}

		//text/xml
		var contentType = objCall.objXmlReq.getResponseHeader("Content-Type");
		if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
			alert("<spring:message code='appr.data.wrong' text='잘못된 데이터입니다. 오랫동안 사용하지 않아 세션이 종료되었거나, 서버오류입니다\!' />");
			return;
		}

		objCall.objNode.parentElement.setAttribute("nek_retrieved", "1");

		var objDepartments = objCall.objXmlReq.responseXML.selectNodes("//ou[@type='department']");
		var objUsers = objCall.objXmlReq.responseXML.selectNodes("//ou[@type='user']");

		objCall.objNode.innerHTML = "";
		if (objDepartments.length + objUsers.length < 1) {
			AddNoItem(objCall.objNode);
		} else {
			for (var i = 0; i < objDepartments.length; i++) {
				var strID	= objDepartments[i].getAttribute("deptid");
				var strName = objDepartments[i].getAttribute("name");

				//AddFolder(objCall.objNode, strName, "department", strName + ":" + strID, false);
                AddFolderWithId(objCall.objNode, strName, "department", strName + ":" + strID, false, "folder_" + strID);
			}

			for (var i = 0; i < objUsers.length; i++) {
				var strName		= objUsers[i].getAttribute("name");
				var strUID		= objUsers[i].getAttribute("uid");
				var strPosition = objUsers[i].getAttribute("position");
				var strDuty 	= objUsers[i].getAttribute("duty");
				var strDepartment = objUsers[i].getAttribute("department");
				if (strPosition == null || strPosition == "") {
					strPosition = SNOPOSITION_HAN ;
				}

				//AddNode(objCall.objNode, strName + "/" + strPosition,
				//	"user", strName + ":" + strUID + ":" + strPosition + ":" + strDepartment);
                AddNodeWithId(objCall.objNode, strName + "/" + strPosition,
						"user", strName + ":" + strUID + ":" + strPosition + ":" + strDepartment + ":" + strDuty , "node_" + strUID);
			}
		}
		DeleteCall(nIndex);
	}
	else
	{
	}

    //최초 load될때만 실행하라.
    if (bFirst) {
        FirstExpandDeptId() ;
    }

}

function OnClickAddRecipient() {
	var selectedNode = $("#objTree").dynatree("getActiveNode");	// 'dynatree'로 인해 추가 - 2012-10-18 LSH
	if (selectedNode == null) { 			//g_objNodeSelected == null
		alert("<spring:message code='appr.select.add' text='추가할 결재자를 선택하세요\!' />     ");
		return;
	}

	var type = selectedNode.data.type; 		// g_objNodeSelected.getAttribute("nek_type");
	if (type == null) {
		return;
	} else if (type == "user") {
		var data = selectedNode.data.datas; // g_objNodeSelected.getAttribute("nek_data");
		if (data != null) {
			var datas = data.split(":");
			if (datas != null && datas.length > 1) {
				var objAddress = new Object();
				objAddress.type = ORGUNIT_TYPE_USER;
				objAddress.name = datas[0];
				objAddress.id = datas[1];
				objAddress.position = datas[2];
				objAddress.department = datas[3];
				objAddress.duty = datas[5];
				
                var objapprtype = getApprType("apprtype") ;
                objAddress.apprtype = objapprtype.apprtype  ; //결재형태
				objAddress.apprname = objapprtype.apprname ; //결재형태명
				AddRecipient(objAddress, false);
			}
		}
	}
}

function AddRecipient(objAddress, bSilent) {
	var sApprNO = 0; // 일반결재자 수
	var sApprHelpNO = 0; // 합의 결재자 수
	for( var i = 0; i < objRecipients.length; i++) {
		if (objRecipients[i].apprtype == "H") {
			sApprHelpNO++;
		} else {
			sApprNO++;
		}
	}

	if (objAddress.id == sUid) {
		alert("<spring:message code='appr.select.self.no' text='자신은 선택 할 수 없습니다.' />");
		return;
	}

	if (objAddress.id == gianUID) {
		alert("<spring:message code='appr.select.drafter.no' text='기안자는 선택 할 수 없습니다.' />");
		return;
	}

	if (ApprType == "6" || ApprType == "7") {
		if (sApprNO > (eval(APPR_SIZE) - 1) && objAddress.apprtype == "A") {
	    	alert("<spring:message code='appr.general.over' text='일반 결재자는' /> "+ APPR_SIZE + "<spring:message code='appr.cannat.over' text='명을 넘을 수 없습니다.' />");
			return;
		}
	} else {
		// 스타리온은 기안자 고정으로 1칸을 먹고 들어감.
		if (sApprNO > (eval(APPR_SIZE) - 2) && objAddress.apprtype == "A") {
	    	alert("<spring:message code='appr.general.over' text='일반 결재자는' /> "+ (APPR_SIZE-1) + "<spring:message code='appr.cannat.over' text='명을 넘을 수 없습니다.' />");
			return;
		}
	}

	if (sApprHelpNO > eval(HELP_SIZE) - 1 && objAddress.apprtype == "H") {
    	alert("<spring:message code='appr.agreed.over' text='합의 결재자는' /> " + HELP_SIZE + "<spring:message code='appr.cannat.over' text='명을 넘을 수 없습니다.' />");
		return;
	}

	// var type = objAddress.type;
	for( var i = 0; i < objRecipients.length; i++) {
		if (objRecipients[i].id == objAddress.id) {
			if (!bSilent) {
				alert("'" + AddressToDisplayString(objAddress) + "'<spring:message code='c.selected' text='님은 이미 선택되었습니다\!' />");
			}
			return;
		}
	}
	
	// 배열 맨 뒤에 새로운 요소를 삽입
	objRecipients.push(objAddress);

	// 배열 맨 앞에 새로운 요소를 삽입 2014-07-10 LSH (역순)
//	objRecipients.unshift(objAddress);

	RefreshRecipientsList();
}


function OnInputRecipientKeyDown(event) {
	if(event.which){
		if (event.which == 13) {
			var bRet = OnClickAddRecipients();
			event.returnValue = false;
			return bRet;
		}
	}else{ // 윈도우, 사파리, 크롬
		if (event.keyCode == 13/*\r*/) {
			var bRet = OnClickAddRecipients();
			event.returnValue = false;
			return bRet;
		}
	}
}

function Trim(str) {
	return (str.replace(/^\s*|\s*$/g, ""));
}
//----------------------------------------------------------------
//검색
function OnClickAddRecipients() {

    var objSearchText = document.getElementsByName("searchtext")[0] ;
    var strText = objSearchText.value;
	if (Trim(strText).length == 0) {
		alert("<spring:message code='t.enter.searchValue' text='검색어를 입력하세요!' />");
		objSearchText.focus();
		return;
	}

	var keywords = strText.split(',');

	var qualifieds = new Array();
	var unqualifieds = new Array();
	for (var i = 0; i < keywords.length; i++) {
		var segment = Trim(keywords[i]);
		if (segment != "") {
			if (segment.length < 2) {
				unqualifieds.push(segment);
			} else {
				qualifieds.push(segment);
			}
		}
	}


	if (unqualifieds.length > 0) {
		var msg = "<spring:message code='c.2characters.required' text='검색어는 2자 이상이어야 합니다. 잘못된 검색어\: ' />";
		for (var i = 0; i < unqualifieds.length; i++) {
			if (i > 0) {
				msg += ", ";
			}
			msg += "'";
			msg += unqualifieds[i];
			msg += "'";
		}

		if (qualifieds.length > 0) {
			msg += "\r\n<spring:message code='t.search.continue' text='다른 검색어에 대하여 검색을 계속하시겠습니까?' />";
			if (confirm(msg)) {
				SearchRecipients(qualifieds);
			} else {
				return;
			}
		} else {
			alert(msg);
		}
	}
	else {
		SearchRecipients(qualifieds);
	}

	objSearchText.select();
}
function SearchRecipients(keywords) {
	var param = "nek=java";
	for (var i = 0; i < keywords.length; i++) {
		param += "&keyword=";
		param += encodeURI(keywords[i]);
	}

 
	//var objXmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
	var objXmlHttp = createXmlHttp();
	objXmlHttp.open("POST", "../common/findrecipients.htm?" + param, false, "", "");
	//objXmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	objXmlHttp.send();

	if (objXmlHttp.status != 200) {
		var msg = "<spring:message code='c.search.error' text='검색 중 오류가 발생하였습니다\!' />\r\n[";
		msg += objXmlHttp.status;
		msg += "] ";
		msg += objXmlHttp.statusText;
		alert(msg);
		return;
	}

	var contentType = "" + objXmlHttp.getResponseHeader("Content-Type");
	if (contentType.length < 8 || contentType.toLowerCase().substring(0, 8) != "text/xml") {
		alert("<spring:message code='c.search.ssesion' text='검색 중 오류가 발생하였거나, 오랫동안 사용하지 않아 세션이 종료되었습니다.' />");
		return;
	}

	var objXml = objXmlHttp.responseXML;
	var objMultis = new Array();
	var results = objXml.selectNodes("//search-result");
	for (var i = 0; i < results.length; i++) {
		var objElems = results[i].selectNodes("./ou");
		if (objElems.length == 0) {
			//검색 결과 없음
		} else if (objElems.length == 1) {
			//한명
			var objElem = objElems[0];
			var type = objElem.getAttribute("type");
			if (type == "user") {
				var name	= objElem.getAttribute("name");
				var uid		= objElem.getAttribute("uid");
				var position = objElem.getAttribute("position");
				if (position == "") {
					position = SNOPOSITION_HAN ;
				}
				var duty = objElem.getAttribute("duty");

				if (duty == "") {
					duty = SNODUTYHAN ;
				}
				var department = objElem.getAttribute("department");
				var objAddress = new Object();
				objAddress.type = ORGUNIT_TYPE_USER;
				objAddress.name = name;
				objAddress.id	= uid;
				objAddress.position = position;
				objAddress.department = department;
				objAddress.duty	= duty;

                var objapprtype = getApprType("apprtypesearch") ;
                objAddress.apprtype = objapprtype.apprtype  ; //결재형태
				objAddress.apprname = objapprtype.apprname ; //결재형태명

				AddRecipient(objAddress, true);
			}
		} else {
			//여러명
			objMultis.push(results[i]);
		}
	}
	if (objMultis.length > 0) {
		var ret = window.showModalDialog("../common/multiple_recipients.html", objMultis,
			"dialogHeight: 300px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; scroll: no;");

		if (ret != null) {
			for (var i = 0; i < ret.length; i++) {
				var objAddress = ParseAddress(ret[i]);
				if (objAddress != null) {
					AddRecipient(objAddress, true);
				}
			}
		}
	}
}

function ParseAddress(strData) {
	if (strData == "") {
		return null;
	}

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
        var objapprtype = getApprType("apprtypesearch") ;
        objAddress.apprtype = objapprtype.apprtype  ; //결재형태
        objAddress.apprname = objapprtype.apprname ; //결재형태명
		return objAddress;
	}
	return null;
}

//----------------------------------------------------------------


// 속성
//objRecipients.name 성명
//objRecipients.id   UID
//objRecipients.position  직위명
//objRecipients.department  부서명
//objRecipients.apprtype  결재 형태
//objRecipients.apprname  결재 형태 명

function getApprType(apprtyperadio)
{
	var objAppr = document.getElementsByName("apprtype");
    //var objAppr = document.all[apprtyperadio] ;
    //alert(apprtyperadio + objAppr) ;
    var objapprtype = new Object() ;
    if(ApprType=="7"||ApprType=="5"||ApprType=="6"){
    	objapprtype.apprtype = APPR_CODE ;
        objapprtype.apprname = APPR_HAN ;
    }else{
	    if (objAppr[0].checked){
	        objapprtype.apprtype = APPR_CODE ;
	        objapprtype.apprname = APPR_HAN ;
	    } else if (objAppr[1].checked){
	        objapprtype.apprtype = HAP_CODE ;
	        objapprtype.apprname = HAP_HAN ;
	    }
	}

    return objapprtype ;
}


//=================================================================================

function OnLoad() {
	//var objSelecteds = window.dialogArguments;
	var objSelecteds = new Array();
	if(ApprType=="5"){
		objSelecteds = parent.getApprPer(ApprType); //dialogArguments.window.arrPeople_req;
	}else{
		objSelecteds = parent.getApprPer(ApprType); //dialogArguments.window.arrPeople;
	}
	
//if (objSelecteds == null ) objSelecteds = new Array() ; //*****************************************************************
	for (var i = 0; i < objSelecteds.length; i++) {
		objRecipients.push(objSelecteds[i]);
	}
	/**
	 * 역순
	for (var i = objSelecteds.length; i > 0; i--) {
		objRecipients.push(objSelecteds[i-1]);
	}
	*/
	RefreshRecipientsList();
}

function RefreshRecipientsList() {
	
	var objList = document.getElementsByName("apprpersonlist")[0];
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

function AddressToString(objAddress) {

	if (objAddress.type == ORGUNIT_TYPE_USER) {
		return "P:"+ objAddress.apprtype + ":"+ objAddress.apprname + ":"
                   + objAddress.name + ":" + objAddress.id + ":" + objAddress.position + ":" + objAddress.department + ":" + objAddress.fixed;
	}
	return "";
}

function AddressToDisplayString(objAddress) {
	var strDisplay = "";

	var strTitle = objAddress.position;
	
    strDisplay += objAddress.apprname;
    strDisplay += "/";
    strDisplay += objAddress.name;
    strDisplay += "/";
    strDisplay += strTitle;
    strDisplay += "/";
    strDisplay += objAddress.department;

	return strDisplay;
}

function onClickRemoveList()
{

    if (document.getElementsByName("apprpersonlist")[0].selectedIndex < 0 )
    {
        alert("<spring:message code='appr.select.delete' text='삭제할 결재자를 선택하세요!'/>");
        return ;
    }
    OnClickRemoveRecipients() ;
}

function OnClickRemoveRecipients() {

    var objList = document.getElementsByName("apprpersonlist")[0];
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

function RemoveRecipient(strAddress) {
	var objNewRecipients = new Array();
	var strAddressLower = strAddress.toLowerCase();
	var nIndex = -1;
	var tmp = strAddress.split(':');
	if(tmp[7]=="1"){
		alert("<spring:message code='appr.not.ingapprover.remove' text='이미 결재한 사용자는 제거할수 없습니다.'/>");
		return;
	}
	
	for (var i = 0; i < objRecipients.length; i++) {
		if (strAddressLower != AddressToString(objRecipients[i]).toLowerCase()) {
			objNewRecipients.push(objRecipients[i]);
		}
	}
	objRecipients = objNewRecipients;
}

//list up down
//1 : down , 0 : up
function moveListUpDown(iUpDown)
{
    var objList = document.getElementsByName("apprpersonlist")[0];
	if (objList.options.length == 0)  return ;

    var iIndex = objList.selectedIndex ;
    if (iIndex < 0 )
    {
        alert("<spring:message code='appr.choose' text='선택하십시오.' />") ;
        return ;
    }

    if (iUpDown == 0 ) {
        if ( iIndex == 0) return;
        arrIndexMove(iIndex) ;
        objList.selectedIndex = iIndex - 1 ;
    }else {
        if ( iIndex == objList.options.length-1 ) return;
        arrIndexMove(iIndex+1) ;
        objList.selectedIndex = iIndex + 1 ;
    }


}

//반환 객체의 순서 변경
function arrIndexMove(iIndex)
{

    var arr1 = objRecipients.slice(0, iIndex+1) ;
    var arr2 = objRecipients.slice(iIndex+1) ;

    var obj1 = arr1.pop() ; //index
    var obj2 = arr1.pop() ; //index -1
    
    if(obj1.fixed=="1"||obj2.fixed=="1"){
    	alert("<spring:message code='appr.not.ingapprover.move' text='이미 결재한 사용자는 이동할수 없습니다.'/>");
    	return;
    }

    arr1.push(obj1) ;
    arr1.push(obj2) ;

	for (var i = 0; i < arr2.length; i++) {
		arr1.push(arr2[i]);
	}

    objRecipients = arr1 ;

    RefreshRecipientsList();

    //objList.selectedIndex = iIndex ;

}

//결재선
function OpenModal( modal_url , modal_arg , modal_width , modal_height ) {
	modal_left = (screen.width - modal_width) / 2;
	modal_top = (screen.height - modal_height) / 2;
	returnvalue = self.showModalDialog( modal_url , modal_arg,
     	             "status:no;scroll=no;dialogLeft:" + modal_left + ";dialogTop:" + modal_top + ";help:no;dialogWidth:" + modal_width + "px;dialogHeight:" + modal_height + "px");
	return returnvalue;
}

//자주 사용하는 결재선 선택 (window.showModalDialog Version)
function ShowApprLineModal() {
    var sUrl = "./appr_line.jsp?no="+NUM  ;
    var sUrl = "./appr_line_new.jsp?no="  ;
    //var returnval = OpenModal( sUrl , null , 690 , 476 ) ;
    //var returnval = OpenModal( sUrl , null , 690 , 486 ) ;
    //var returnval = OpenModal( sUrl , null , 690 , 496 ) ;
    var returnval = OpenModal( sUrl , null , 600 , 400 ) ;
    setShowApprLine(returnval);
}

//자주 사용하는 결재선 선택 (dhtmlmodal Version)
function ShowApprLine() {
    var url = "./appr_line_new.jsp?no=";
	window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_APPR1001", "iframe", url, "<spring:message code='main.Approval' text='전자결재' />", 
			"width=500px,height=380px,resize=0,scrolling=1,center=1", "recal"
		);
}

function setShowApprLine(returnval) {
    if (returnval != null && returnval != "") {
    	setApprPersonLine(returnval);
    } else {
    	if (window.returnValue)
    		setApprPersonLine(window.returnValue);
    }
}

//결재라인을 추가 //기존결재자는 전부 삭제 후 추가 한다.
function setApprPersonLine(sTemp)
{
    var sArr ;
    var sList = sTemp.split(APPRGUBUN);
    var objAdd = new Array() ;
    var iApprCnt = 0;
    var iHelpCnt = 0;

    for (var i = 1 ; i < sList.length ; i++ )  // 1부터 시작하는 이유 처음은 값이 없다.
    {
        sArr = sList[i].split("|");

        var objAddress = new Object();

        objAddress.type = ORGUNIT_TYPE_USER;
        objAddress.apprname = sArr[0] ;
        objAddress.department = sArr[1];

        if (sArr[2] == null || sArr[2] == "") {
            sArr[2] = SNOPOSITION_HAN ;
        }
        objAddress.position = sArr[2];
        objAddress.name = sArr[3];
        objAddress.id	= sArr[4];
        objAddress.apprtype = sArr[5]  ;
        objAddress.duty = sArr[6];
        
        if(objAddress.apprtype=="A"){
        	iApprCnt++;
        }else if(objAddress.apprtype=="H"){
        	iHelpCnt++;
        }

        objAdd.push(objAddress) ;
    }
    
  //결재선 결재자/합의자 수가  양식의 지정된 수를 넘어선다면 막는다.
    if(iApprCnt > APPR_SIZE){
    	alert("<spring:message code='appr.general.over' text='일반 결재자는' /> "+ APPR_SIZE + "<spring:message code='appr.cannat.over' text='명을 넘을 수 없습니다.' />");
    	return;
    }else if(iHelpCnt > HELP_SIZE){
    	alert("<spring:message code='appr.agreed.over' text='합의 결재자는' /> " + HELP_SIZE + "<spring:message code='appr.cannat.over' text='명을 넘을 수 없습니다.' />");
    	return;
    }

    objRecipients = objAdd ;

    RefreshRecipientsList()

}

//결재선 저장
function OpenWindow(UrlStr, WinTitle, WinWidth, WinHeight) {
	winleft = (screen.width - WinWidth) / 2;
	wintop = (screen.height - WinHeight) / 2;
	var win = window.open(UrlStr , WinTitle , "width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
    win.focus() ;
}

function ApprLineSave()
{
    //alert(document.all.apprpersonlist.options.length);
    if(document.getElementsByName("apprpersonlist")[0].options.length < 1) {
		alert("<spring:message code='appr.not.approver' text='결재자가 없습니다.' />\n\n"
				+ "<spring:message code='appr.approver.select' text='결재자를 선택하십시오' />") ;
        return ;
    }

    var sVal = "" ;
    var iLne = objRecipients.length ;
    for( var i = 0 ; i < iLne ; i++ )
    {
        var sTemp = objRecipients[i] ;
        sVal = sVal + APPRGUBUN +sTemp.id +"|"+ sTemp.apprtype ;
    }
    var url = "./appr_linesave_pop.jsp?apprtype="+sVal + "&formid=" + FORMID ;

    winleft = (screen.width - 517) / 2;
	wintop = (screen.height - 160) / 2;
	
	//부모객체를 사용하여 window open
//	var win = dialogArguments.window.open(url , "linesave" , "width=517, height=170, top="+ wintop +", left=" + winleft + ", resizable=yes, status=yes"  );
	var win = parent.window.open(url , "linesave" , "width=517, height=170, top="+ wintop +", left=" + winleft + ", resizable=yes, status=yes"  );
	win.focus();
    OpenWindow(url, "linesave", "517" , "170") ;
}
