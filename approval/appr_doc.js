var PPOP_WIDTH = 775 ; //의견, 진행 pop
var PPOP_HEIGHT = 245 ; 
var PPOP_WIDTH = 570 ; //의견, 진행 pop
var PPOP_HEIGHT = 260 ; 
var APPR_POP_WIDTH = 355 ; //결재 pop
var APPR_POP_HEIGHT = 255 ; 

//------------------------------------------------------------------------------------------------------------------
//결재 진행 상태 팦업창
function goApprperProcess(apprid) 
{//스크롤이 생기지 않아야 한다. 그때문에 공통의 open을 사용안함
    var sUrl = "./appr_apprperprocess_pop.jsp?apprid="+apprid  ;    

   OpenWindowNoScr(sUrl,  "apprProcess", PPOP_WIDTH, PPOP_HEIGHT) ; 
}
//------------------------------------------------------------------------------------------------------------------
//결재자 정보
function ShowApprUserInfo( apprid, appruid, apprno ) {
    var url = "./appr_userinfo.jsp?apprid="+ apprid +"&appruid=" + appruid+"&apprno=" + apprno ;
    xmlhttpRequest( "GET", url , "afterShowUserInfo" ) ;
}
//------------------------------------------------------------------------------------------------------------------
//pop up으로 보여주어라. 무엇을 내용을 
function ShowFormOpen()
{    
    OpenWindow( "", "apprnewpop", "850" , "500" );
    mainForm.target = "apprnewpop";
} 
//------------------------------------------------------------------------------------------------------------------
//list로 돌아가기
function returnList(action)
{
    document.mainForm.cmd.value = "" ;

    document.mainForm.action = action ;
    document.mainForm.method = "get" ; 
    document.mainForm.submit() ;
}
//------------------------------------------------------------------------------------------------------------------
//결재 처리
function goApproval() 
{     
    if (mainForm.typepopup == null ) {
        alert("이미 결재한 문서입니다."); 
        return ; 
    }
    //폼을 뛰위야 한다. 
    // 서명과 결재 형태를 결정해서 받아야 한다.   

    var type = mainForm.typepopup.value ;
    var apprno = mainForm.apprno.value ;

    var sUrl = "./appr_approval_pop_up.jsp?apprid="+FORMID+"&type="+type+"&apprno="+apprno  ;    
    var sReturnval = OpenModal( sUrl , null , APPR_POP_WIDTH , APPR_POP_HEIGHT+70 ) ;    
    
    if ((sReturnval != null) && (sReturnval != "") )
    {
        var sList = sReturnval.split("|") ; 
        document.mainForm.apprflagid.value = sList[0] ;
        document.mainForm.apprpass.value = sList[1] ;
        document.mainForm.apprnote.value = sList[2] ;
        document.mainForm.apprxengeal.value = sList[3] ;

        document.mainForm.calltype.value = "" ; 
        document.mainForm.action = "./appr_ingcontrol.jsp" ;
        document.mainForm.method = "post" ; 
        document.mainForm.submit() ;
    }
}
//------------------------------------------------------------------------------------------------------------------
//기안문 재작성
function newDoc()
{        
    if (!confirm("기안문을 재 작성하시겠습니까?")) return ;

    document.mainForm.cmd.value = S_EDIT ;
    document.mainForm.menu.value = MOVE_MENU_ID;
    document.mainForm.action = "appr_imsidoc.jsp" ;
    document.mainForm.method = "get" ; 
    document.mainForm.submit() ;
}
//------------------------------------------------------------------------------------------------------------------
function OnClickCirculation(apprid)
{
	//회람용 팝업창을 뛰워라. 
	//
    var sUrl = "./appr_circulation_pop.jsp?apprid="+apprid  ;    

    OpenWindowNoScr(sUrl,  "apprProcess", PPOP_WIDTH, PPOP_HEIGHT) ; 
    
}
//------------------------------------------------------------------------------------------------------------------
//보존년한 변경
function OnClickSend()
{
    if (!confirm("저장하시겠습니까?")) return ;
    document.mainForm.cmd.value = "" ;
    document.mainForm.action = "./appr_apprhamcontrol.jsp" ;
    document.mainForm.submit() ;
}

//------------------------------------------------------------------------------------------------------------------
//결재의견보기
function ApprOpinion(apprid)
{    
    //apprid = document.all.apprid.value ;     

    var sUrl = "./appr_appropinion_pop.jsp?apprid="+apprid  ;    

    OpenWindowNoScr(sUrl,  "appropinion", PPOP_WIDTH, PPOP_HEIGHT) ; 
}

//------------------------------------------------------------------------------------------------------------------
//결재 인쇄
function doPrint()
{ 
    //webprint에 있슴
    setReturnPath("../approval/appr_apprdoc.jsp?apprid="+FORMID+"&menu="+MUNU);
    //docPrint('top.frames(1).frames(1)');
    docPrint('document');
}


//------------------------------------------------------------------------------------------------------------------
//수신이력
var objHistoryPopup;	//Popup 변수는 항상 전역 변수로 선언되어 있어야 한다 ! ( 사용이 용이해짐 )
function ShowReceiveRead(apprid) {

	var sUrl = "./appr_receive_history_pop.jsp?apprid="+apprid  ;    

	OpenWindowNoScr(sUrl,  "apprReceiveHistory", PPOP_WIDTH-150, PPOP_HEIGHT+100) ; 

	/*
	var url = "./appr_receive_history.jsp?apprid=" + apprid ;    
	xmlhttpRequest( "GET", url , "ReceiveHistoryInfo" ) ;
	*/
}

// 스크롤 가능하게 바꾸어라.
function ReceiveHistoryInfo() {
	if ( xmlhttp.readyState == 4 ) {
		if ( xmlhttp.status != 200 ) {
			alert( '오류가 발생하였습니다 : XMLHTTP     \n\n오류위치 : afterShowUserInfo()' );
			return;
		}        
		var statusStr ;
		objHistoryPopup = window.createPopup();
		var oPopupBody = objHistoryPopup.document.body;
		//oPopupBody.innerHTML = BinToText( xmlhttp.responseBody,32000 ) ;
        oPopupBody.innerHTML = xmlhttp.responseText ;

		wid = 355 ;
		hei = 170;

		x = 367 ;
		y = 48 ;

		objHistoryPopup.show(x, y, wid, hei , document.body);

		xmlhttp = null ;
	}
}

function HideReceiveRead() {
	objHistoryPopup.hide()
}


//------------------------------------------------------------------------------------------------------------------
//문서이관
function OnClickDcoManage()
{    
    if (!confirm("현재 문서를 문서관리로 이관하시겠습니까?")) return ;

    document.mainForm.action = "./appr_transapprdoc.jsp" ;
    document.mainForm.method = "post" ;
    document.mainForm.target = "hidd" ;
    
    document.mainForm.submit() ;

}
//본문내용보이기
function dispBody(sdisbody)
{
    if (document.getElementById(sdisbody) !=null)
    {
        var obj = document.getElementById(sdisbody) ; 
        //document.mainForm.content.value = obj.innerText ;
        var dispBody = obj.innerHTML;
        obj.innerHTML = dispBody;
		obj.style.display="";
    }
}



//------------------------------------------------------------------------------------------------------------------
//checkbox의 값 설정
function OnClickCheckBox() 
{
	var names = document.getElementsByName("chkno");  
    var iLen =  names.length ; 
    if ( iLen > 0 ){
        var checked = !document.mainForm.chkval.checked;
        document.mainForm.chkval.checked  = checked ;
        for (var i = 0; i < iLen ; i++) {
            names[i].checked = checked;
        }        
    }  
}

//일괄결재
function allApproval()
{
    if (CheckAllApproval() ) return  ; 

    //전체건중 합의 와 결재가 혼재인지 검사.

    var sUrl = "./appr_approval_pop.jsp?type=A" ;    
    var sReturnval = OpenModal( sUrl , null , APPR_POP_WIDTH , APPR_POP_HEIGHT ) ;
    
    if ((sReturnval != null) && (sReturnval != "") )
    {
        var sList = sReturnval.split("|") ; 
        document.mainForm.apprflagid.value = sList[0] ;
        document.mainForm.apprpass.value = sList[1] ;
        document.mainForm.apprnote.value = sList[2] ;
        document.mainForm.apprxengeal.value = sList[3] ;

        document.mainForm.calltype.value = "" ; 
        document.mainForm.cmd.value = "ALLAPPR" ; 
        document.mainForm.action = "./appr_ingcontrol.jsp" ;
        document.mainForm.method = "post" ; 
        document.mainForm.submit() ;
    }
}
//결재문서검사
function CheckAllApproval() 
{
    //checkbox의 갯수를 검사.
    var iChkCnt = 0 ; 
    var oldTypeVal = "" ;  
    var newTypeVal = "" ; 
    var iTypeCnt = 0 ; 
    var oldApproalTypeVal = "" ;  
    var newApproalTypeVal = "" ; 
    var iApproalTypeCnt = 0 ; 
	var chknonames = document.getElementsByName("chkno");  
    var typenames = document.getElementsByName("chktype");  
    var apprtypenames = document.getElementsByName("chkapprovaltype");  
    var iLen =  chknonames.length ; 
    if ( iLen > 0 ){        
        for (var i = 0; i < iLen ; i++) {
            if (chknonames[i].checked){
                //checkbox검사
                iChkCnt++ ; 
                //결재 형태 검사
                newTypeVal = typenames[i].value ;
                if (newTypeVal != oldTypeVal)  iTypeCnt++  ; 
                oldTypeVal = newTypeVal ; 
                //결재방식검사
                newApproalTypeVal = apprtypenames[i].value ;
                if (newApproalTypeVal != oldApproalTypeVal)  iApproalTypeCnt++  ; 
                oldApproalTypeVal = newApproalTypeVal ;                 
            }
        }        
    } 

    if (iChkCnt < 1 ) 
    {
        alert("결재문서를 선택하십시오.") ; 
        return true ;         
    } 

    if ( iTypeCnt > 1 ) // 1은 처음의 변화값이다.
    {
        if (!confirm("결재 형태가 다른 문서가 존재합니다.\n계속 진행하시겠습니까?")) return true ;
    }

    if ( iApproalTypeCnt > 1 ) // 1은 처음의 변화값이다.
    {
        if (!confirm("결재 방식이 다른 문서가 존재합니다.\n계속 진행하시겠습니까?")) return true ;
    }

    return false ; 
}

//------------------------------------------------------------------------------------------------------------------
//소유권이전
function getReceiveOwnID()
{
    url = "../common/department_selector.jsp?openmode=1&isadmin=0&expand=1&expandid=00000000000000&onlydept=0&onlyuser=1&winname=parent&conname=mainForm" ;

    var objDaeri = new Object() ;
    var returnval = OpenModal( url , objDaeri, 320 , 350 ) ;
    if (returnval != null && returnval != "") {
        var arrVal = returnval.split(":") ;

        var sNm = arrVal[0] ;  //
        var sID = arrVal[1] ;  //ID
        var sUnm = arrVal[2] ;
        var sDnm = arrVal[3] ;
        var sText = sNm + "/" + sUnm + "/" + sDnm ;

        if (!confirm("해당문서를 '"+sNm+"'님께 인계 하시겠습니까?")) return ;

        document.mainForm.receiveownid.value = sID ;
        //alert(document.mainForm.receiveownid.value+"/"+sText ) ; 
        document.mainForm.action = "./appr_onedocchangeown.jsp" ; 
        document.mainForm.method ="post" ; 
        document.mainForm.submit() ; 
    }
}

//------------------------------------------------------------------------------------------------------------------
//문서삭제
function OnDelOneDoc()
{    
    if (!confirm("삭제하시겠습니까?")) return ;

    document.mainForm.action = "./appr_ingcontrol.jsp" ;
    document.mainForm.calltype.value = S_DEL ;
    document.mainForm.method = "post" ;
    //document.mainForm.target = "hidd" ;
    document.mainForm.target = "_self" ;

    document.mainForm.submit() ;

}

//------------------------------------------------------------------------------------------------------------------
//결재독촉
function OnUrgentDoc()
{    
    if (!confirm("결재를 독촉하시겠습니까?")) return ;

    document.mainForm.action = "./appr_ingcontrol.jsp" ;
    document.mainForm.calltype.value = S_URGENT ;
    document.mainForm.method = "post" ;
    document.mainForm.target = "hidd" ;
    document.mainForm.target = "_self" ;

    document.mainForm.submit() ;

}

//보류 설정
function goBoryuAppr()
{
/*
    var apprno = mainForm.apprno.value ;

    var sUrl = "./appr_apprboryu_pop.jsp?apprid="+FORMID+"&apprno="+apprno  ;    
    var sReturnval = OpenModal( sUrl , null , APPR_POP_WIDTH , APPR_POP_HEIGHT-100 ) ;    
    
    if ((sReturnval != null) && (sReturnval != "") )
    {
        document.mainForm.apprpass.value = sReturnval ;


        document.mainForm.calltype.value = "BORYU" ; 
        document.mainForm.action = "./appr_ingcontrol.jsp" ;
        document.mainForm.method = "post" ; 
        document.mainForm.submit() ;
    }
    */
    
    if(!confirm("이 문서를 보류문서로 지정하시겠습니까?")){
    	return;
    }
    
    document.mainForm.calltype.value = "BORYU" ;
	document.mainForm.action = "./appr_ingcontrol.jsp" ;
	document.mainForm.method = "post" ; 
	document.mainForm.submit() ;
}

function windowClose(){
	top.window.opener = top;
	top.window.open('','_parent', '');
	top.window.close();
}

function altMsg( args ) {
	var statusStr ;
	oPopup = window.createPopup();
	var oPopupBody = oPopup.document.body;

	var tag = "<div id=spanpop style='padding:5px; background:white; padding-top:7px; ";
	tag += "font-size:9pt; font-family:굴림; position:relative; width:100%; height:100%;";
	tag += "top:0; left:0; height:30px; border:2px solid #A1B5FE;'>" + args + "</div>";

	oPopupBody.innerHTML = tag ;

	var x1 = event.srcElement.offsetLeft + event.srcElement.offsetWidth + 30;
	var y1 = event.srcElement.offsetTop + event.srcElement.offsetHeight + 100;

	x = window.event.x + 15;
	y = window.event.y - 5;

	wid = ( args.length * 11) + args.split(" " ).length ;
	hei = 30;
	
	oPopup.show(x1, y, wid, hei , document.body);
}

function altMsg_off( args ) {
	if ( oPopup ) oPopup.hide();
}