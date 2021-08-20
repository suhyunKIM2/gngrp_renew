var popupWinCnt = 0;
// main page open doc
function openBbs(cmd, isNewWin ,bbsId, docId){
	var url = "/bbs/read.htm?bbsId=" + bbsId + "&docId=" + docId;
	//url += "&useNewWin=true&useLayerPopup=false";
//	var winName = "popup_" + popupWinCnt++;
//	OpenWindow(url, winName, "800", "610");
//	return;
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
        if (typeof dhtmlwindow == "undefined") {
    		var a = ModalDialog({'t':'커뮤니티', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
        } else {
 			parent.dhtmlwindow.open(
				url, "iframe", url, "커뮤니티", 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
        }
	}
}

function openBbsWork(cmd, isNewWin, docId){
	var url = "/bbswork/read.htm?docId=" + docId;
	//url += "&useNewWin=true&useLayerPopup=false";
//	var winName = "popup_" + popupWinCnt++;
//	OpenWindow(url, winName, "800", "610");
//	return;
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
        if (typeof dhtmlwindow == "undefined") {
    		var a = ModalDialog({'t':'커뮤니티', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
        } else {
 			parent.dhtmlwindow.open(
				url, "iframe", url, "커뮤니티", 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
        }
	}
}

function goApprIng(apprtype, isNewWin, apprid, popcheck)
{
	var UrlStr = "";
    if( apprtype == "3" ){
    	UrlStr = "/approval/apprdoc.htm?menu=340&apprId="+apprid+"&pop=" + popcheck ;
    }else{
    	UrlStr = "/approval/apprdoc.htm?menu=240&apprId="+apprid+"&pop=" + popcheck ;
    }
    
    if(isNewWin == "true"){
    	UrlStr += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(UrlStr, winName, "800", "550");
	} else {	//self
		UrlStr += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
        if (typeof dhtmlwindow == "undefined") {
    		var a = ModalDialog({'t':'전자결재', 'modal':false, 'w':800, 'h':550, 'm':'iframe', 'u':UrlStr});
        } else {
 			parent.dhtmlwindow.open(
 				UrlStr, "iframe", UrlStr, "전자결재", 
				"width=820px,height=550px,resize=1,scrolling=1,center=1", "recal"
			);
        }
	}
}

function openDms(cmd, isNewWin, docId)
{
	var url = "/dms/read.htm?docId=" + docId;
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
        if (typeof dhtmlwindow == "undefined") {
    		var a = ModalDialog({'t':'문서관리', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
        } else {
 			parent.dhtmlwindow.open(
				url, "iframe", url, "문서관리", 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
        }
	}
}

// front mail open
function OnClickOpenMail(messageName)
{
    var WinWidth = 900 ;
    var WinHeight = 500 ;
    var winleft = (screen.width - WinWidth) / 2;
    var wintop = (screen.height - WinHeight) / 2;
    var UrlStr = "/mail/mail_read.jsp?front=&message_name=" + messageName ;
    if (typeof dhtmlwindow == "undefined") {
        var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
    } else {
			parent.dhtmlwindow.open(
				UrlStr, "iframe", UrlStr, "메일조회", 
			"width="+WinWidth+"px,height="+WinHeight+"px,resize=1,scrolling=1,center=1", "recal"
		);
    }
}

//front noty open
function OnClickOpenNote(boxID, noteID) {
	var WinWidth = 850 ; 
	var WinHeight = 500 ; 
	var winleft = (screen.width - WinWidth) / 2;
	var wintop = (screen.height - WinHeight) / 2;
	var UrlStr = "/notification/read.htm?newwin=&noteId=" + noteID + "&boxId=" +boxID ;
    if (typeof dhtmlwindow == "undefined") {
    	var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
    } else {
			parent.dhtmlwindow.open(
				UrlStr, "iframe", UrlStr, "쪽지조회", 
			"width="+WinWidth+"px,height="+WinHeight+"px,resize=1,scrolling=1,center=1", "recal"
		);
    }
}
