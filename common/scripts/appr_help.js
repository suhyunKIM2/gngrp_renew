
//신청결재 결재자 선택
function goApprPer_req() {
	var frm = document.getElementById("apprWebForm");
	var reqCnt = REQ_SIZE;
	var apType = "AP";
	
	if (arguments.length > 0) {
		apType = "HAP";
	}
	
	if (frm.cmd.value=="NEW") {	//편집시 사용되는 갯수 한개더 추가
		reqCnt = reqCnt + 1;
	}
	
    var sUrl = "./appr_apprperson.htm?";
	var par = new Array();
	par.push("formId=" + FormCode);
	par.push("apprtype=" + 5);
	par.push("apprcnt=" + reqCnt);
	par.push("helpcnt=" + 0);
	par.push("aptype=" + apType);

	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_APPR1003", "iframe", sUrl+par.join("&"), "전자결재", 
		"width=650px,height=430px,resize=0,scrolling=1,center=1", "recal"
	);
}

//신청결재 결재자 선택 적용
function setApprPer_req(returnval) {
    var reqCnt = REQ_SIZE; // -1
    
    if (returnval != null) {
        arrPeople_req = new Array();
        
        for (var i = 0; i < returnval.length; i++) {
            arrPeople_req.push(returnval[i]);
        }
        //arrPeople = arrPeople.reverse() ;
        setApprPersonLine_req(arrPeople_req, reqCnt); 
    }
    setApLineEditorByRead();
    goApprReqLineSend(true); //서버에 신청결재선 저장
}

//해더 신청결재 초기화 (첫번째 사용자 제외)
function setApprPersonInit_req(reqCnt) {
	var frm = document.getElementById("apprWebForm"); 
    var objCnt = frm.apprpersoncnt;
    var iApprCnt = ((objCnt.value == null ) || (objCnt.value == "")) ? 0 : objCnt.value;
    var objtitle = null;
    var objtype = null; 
    var objuid = null; 
    var objTable = null; 
    var num = 0;
    
    for (var i = 1; i < reqCnt; i++) {
        frm.tbapprperuid_req[num].value = ""; 
        frm.tbapprpertype_req[num].value = ""; 
	    objTable = document.getElementById("apprtableadd_req"+i+"");
	    
	    $("#apprtitle_req"+i).html("");
	    $("#apprtype_req"+i).html("");
	    $("#appruid_req"+i).html("");
	    $("#apprup_req"+i).html("");

        if (objTable != null) {
        	$("#apprtableadd_req"+i).html("");
        }
        num++;
    }
    frm.apprpersontablecnt.value = 0;
    frm.apprpersoncnt.value = 0;
}

//선택된결재자들을 화면에 보여주기
function setApprPersonLine_req(sTemp, reqCnt)
{
	var frm = document.getElementById("apprWebForm");
    // 초기화
 	setApprPersonInit_req(reqCnt);

// 	arrPeople_req.reverse();	//하나로 역방향 순서로 변경
	
    var sApprCnt = 1;
    var sApprObj = new Array();	//일반결재자
    //일반 결재와 협조 결재 분리
    for (var i = 0 ; i < arrPeople_req.length; i++ )
    {
		objApprVal = arrPeople_req[i];
        sApprObj.push(arrPeople_req[i]);
    }
    
    //일반 결재자 처리 / 마지막 결재자는 별도 처리 
    for (var i = 0 ; i < sApprObj.length ; i++ )  
    {
        objApprVal = sApprObj[i] ;
		tblInsert_req(sApprCnt, objApprVal, sApprObj.length) ; //값 추가
		sApprCnt =  addIndex1_req(sApprCnt) ;  //1 증가
    }
    
    //제일 마지막 결재자 처리---------------------------
//    if(sApprObj.length > 0){
//    	var lastIndex=1;
//	    objApprVal = sApprObj[sApprObj.length-1] ;         
//	    tblInsert_req(lastIndex,objApprVal,sApprObj.length, sApprCnt) ; //값 추가
//	    sApprCnt = addIndex1_req(sApprCnt) ;  //1 증가
//	 }
	//결재자 재 정리
    arrPeople_req = new Array();
	for (var i = 0 ; i < sApprObj.length; i++ )
    {
		arrPeople_req.push(sApprObj[i]);
    }
    //제일 마직막 결재자 처리 끝-------------------------
	setSlash_req( sApprCnt );
}

function addIndex1_req(index)
{
    return eval(index) + eval(1) ;
}

//결재자를 추가
//function tblInsert(index)
//index : 결재판 display index, objApprVal:value, vindex:값이 들어갈index
function tblInsert_req(index, objApprVal, apprSize, vindex)
{
	var frm = document.getElementById("apprWebForm");
	vindex=(typeof(vindex)== "undefined")? index : vindex;
//	vindex += 1;
//objRecipients.apprtype  결재 형태
//objRecipients.apprname  결재 형태 명
  var sFonColor = "" ; 

  var titleObj = $("#apprtitle_req"+index);
  var typeObj = $("#apprtype_req"+index);
  var uidObj = $("#appruid_req"+index);
  var upObj = $("#apprup_req"+index);
  
  if (objApprVal.apprtype == "V"){
      sFonColor = "#000000" ; 
  } else {
      sFonColor = "#0033CC" ; 
  }
  sFonColor = "#000000" ;
  
  var sTitleFont = "<FONT  COLOR=" + sFonColor+  "><B>" + objApprVal.duty + "</B></FONT>"; 

  //typeObj.innerText = objApprVal.apprname ;
  titleObj.html(sTitleFont);
  typeObj.html(objApprVal.apprname) ; 
  uidObj.html("<a href=\"javascript:ShowUserInfo('"+objApprVal.id+"');\">"+objApprVal.name+"</a>")  ; 
//  upObj.innerHTML = objApprVal.position;

  frm.tbapprperuid_req[vindex-1].value  = objApprVal.id ; 
  frm.tbapprpertype_req[vindex-1].value  = "V" ; 
}

function setSlash_req(no){
//appruidx : x number
//perx : x number
var totApLine=6;
	for(var ii=0 ; ii < no-1 ; ii++){
		if(document.getElementById("per_req"+ii+"")) document.getElementById("per_req"+ii+"").background="";
	}
	for(var ii=no-1 ; ii < totApLine-1 ; ii++){
		if(document.getElementById("per_req"+ii+"")) document.getElementById("per_req"+ii+"").background="/images/slash.gif";
	}
}

//도움말
//--------------------------------------------------------------------------------
function sCheckValue(sImsiAppr)
{
	var frm = document.getElementById("apprWebForm");
	var formId = frm.apprformid.value;
  	
    if (isEmpty( "subject" )) {
        alert("제목을 입력하시기 바랍니다.");
        frm.subject.focus() ;
        return true;
    }

    if (sImsiAppr == "AP" )
    {

        //결재자
        if (frm.tbapprperuid[0].value == "")
        {
             alert("결재자가 없습니다. \n\n결재자를 선택하십시오") ;
             return true;
        }

         //본문
        if(formId=="A005"){
        }else{
//	        if(document.all.WebEditor.DOM.body.innerHTML == "") {
//	            alert("결재내용을 입력하시기 바랍니다.");
//	            return true;
//	        }
        }
    }

    return false ; 
}
//--------------------------------------------------------------------------------
function OnClickSend(sCallType, sImsiAppr)
{    
	var frm = document.getElementById("apprWebForm");
  	var formId = frm.apprformid.value;
  	
    if(sCheckValue(sImsiAppr)) return ; 
    /*
    if(formId=="A001"){
	    if (!isValidCheck()) return;	//정형결재 value 체크
	}
	*/
    
    var move_url = "" ;
    var move_num = "" ; 

    var sText = "" ;
    if (sImsiAppr == "AP" )
    {
        sText = "결재 요청을 하시겠습니까?" ;
        move_url = MOVE_URL_APPR ; 
        move_num = MOVE_NUM_APPR ; 
    } else if( sImsiAppr == "AE" ){
        sText = "결재 요청을 하시겠습니까?" ;
        move_url = MOVE_URL_APPR ; 
        move_num = MOVE_NUM_APPR ; 
    } else {
        sText = "작성하신 문서를 임시 저장하시겠습니까?" ;
        move_url = MOVE_URL_IMSI ;
        move_num = MOVE_NUM_IMSI ; 
    }
    if (!confirm(sText)) return ;
   
	if(formId=="A005"){
	}else{
//    	frm.editbody.value = document.all.WebEditor.DOM.body.innerHTML;
    }

//document.all.WebEditor.DOM.DocumentElements.innerHTML;
//document.all.WebEditor.DOM.DocumentElements.outerHTML;
//frm.editbody.value = document.all.WebEditor.DocumentHTML;
    frm.calltype.value = sCallType ;
    frm.formtitle.value = document.all.dspFormName.innerText ;
   	
   	//정형결재
   	if(formId=="A005"){
		//frm.action = "appr_fixcontrol.jsp" ;
   	}else{
	   	frm.action = "imsicontrol.htm" ;
   	}
    frm.method = "post" ;

    var uploader = document.all.Uploader;

    if (null != uploader)
    {		

        if (uploader.Submit(frm)) {

            var loc = uploader.Location;
            if (loc == "") {
                //document.write(uploader.Response);
                //새창 열었을때 response 값이 필요없다. 바로 window 닫아준다.
                //parent.opener.location.href = uploader.Response;
                try{
					parent.opener.location.reload();
				}catch(ex){
					window.close();
				}
				window.close();
            } else {
                //document.location.href = loc;
                document.location = move_url ; 
            }
        }
    }

}

//--------------------------------------------------------------------------------
//결재자를 추가
//function tblInsert(index)
// index : 결재판 display index, objApprVal:value, vindex:값이 들어갈index
function tblInsert(index, objApprVal,apprSize, vindex)
{
	var frm = document.getElementById("apprWebForm");
	vindex=(typeof(vindex)== "undefined")? index : vindex;
//objRecipients.apprtype  결재 형태
//objRecipients.apprname  결재 형태 명
  var sFonColor = "" ; 
  
  var titleObj = document.getElementById("apprtitle"+index) ;
  var typeObj = document.getElementById("apprtype"+index) ;
  var dtypeObj = document.getElementById("tapptype"+index) ;
  var uidObj = document.getElementById("appruid"+index) ;
  var duidObj = document.getElementById("tappuid"+index) ;
  var daObj = document.getElementById("tapp"+index) ;
  
  
//   var upObj = eval("document.all.apprup"+index);
  if (objApprVal.apprtype == "A"){
      sFonColor = "#000000" ; 
  } else {
      sFonColor = "#0033CC" ; 
  }
  //2013-06-13 스타리온 타이틀 직책 변경
  var sTitleFont = "<FONT  COLOR=" + sFonColor+  "><B>" + objApprVal.position + "</B></FONT>"; 
  
  titleObj.innerHTML = sTitleFont;
  typeObj.innerHTML = objApprVal.apprname ;  
  if(dtypeObj) dtypeObj.style.display="";
  uidObj.innerHTML = "<a href=\"javascript:ShowUserInfo('"+objApprVal.id+"');\">"+objApprVal.name+"</a>"  ; 
//   upObj.innerHTML = objApprVal.position;
  if(duidObj)duidObj.style.display="";
  if(daObj) daObj.style.display="";

  if (frm.tbapprperuid[vindex]) frm.tbapprperuid[vindex].value  = objApprVal.id ; 
  if (frm.tbapprpertype[vindex]) frm.tbapprpertype[vindex].value  = objApprVal.apprtype ; 
}

//--------------------------------------------------------------------------------
//협조 결재자를 추가
// index : 결재판 display index, objApprVal:value, vindex:값이 들어갈index
function tblInsertHelp(index, objApprVal,vindex)
{
	var frm = document.getElementById("apprWebForm");
	vindex=(typeof(vindex)== "undefined")? index : vindex;
//objRecipients.apprtype  결재 형태
//objRecipients.apprname  결재 형태 명
  var sFonColor = "" ; 
  
  var titleObj = document.getElementById("apprtitle_help"+index) ;
  var typeObj = document.getElementById("apprtype_help"+index) ;
  var dtypeObj = document.getElementById("tapptype_help"+index) ;
  var uidObj = document.getElementById("appruid_help"+index) ;
  var duidObj = document.getElementById("tappuid_help"+index) ;
  var daObj = document.getElementById("tapp_help"+index) ;
  
  if (objApprVal.apprtype == "A"){
      sFonColor = "#000000" ; 
  } else {
      sFonColor = "#0033CC" ; 
  }
  //2013-06-13 스타리온 타이틀 직책 변경
  var sTitleFont = "<FONT  COLOR=" + sFonColor+  "><B>" + objApprVal.duty + "</B></FONT>"; 

  //typeObj.innerText = objApprVal.apprname ;
  
  //typeObj.innerHTML = sTypeFont ;
  $(titleObj).html( sTitleFont);
  $(typeObj).html( objApprVal.apprname);
  if(dtypeObj) dtypeObj.style.display="";
  //uidObj.innerHTML = "<a href=\"javascript:ShowUserInfo('"+objApprVal.id+"');\">"+objApprVal.name+"</a>"  ;
  $(uidObj).html( "<a href=\"javascript:ShowUserInfo('"+objApprVal.id+"');\">"+objApprVal.name+"</a>" );
//   upObj.innerHTML = objApprVal.position;
  if(duidObj)duidObj.style.display="";
  if(daObj) daObj.style.display="";
  frm.tbapprperuid_help[vindex].value  = objApprVal.id ; 
  frm.tbapprpertype_help[vindex].value  = objApprVal.apprtype ; 
}

//--------------------------------------------------------------------------------
//추가 결재자 정보테이블을 그리자
function addApprTable(iLen) 
{
	var frm = document.getElementById("apprWebForm");
    var iTemp = eval(iLen) - eval(6); 
    if (iTemp < 0 ) return ; 

    var itbcnt = frm.apprpersontablecnt.value ; //테이블추가 횟수 시작 0

    var iLoop = Math.floor( (eval(iLen) + eval(2)) / eval(8)) ;

    if (iLoop <= itbcnt ) return  ; 

    var icnt = (eval(iLoop) * eval(8)) ; 

    getApprTableHTML(icnt) ;        

    frm.apprpersontablecnt.value = eval(itbcnt) + eval(1) ; 
}
//--------------------------------------------------------------------------------
//결재자 초기화
function setApprPersonInit() 
{
	var frm = document.getElementById("apprWebForm");
	  var iApprCnt = 0 ; 
	  var objCnt = frm.apprpersoncnt ; 
	  if ((objCnt.value == null )|| (objCnt.value == "")) iApprCnt = 0 ; 
	  else iApprCnt = objCnt.value ; 

	  var objtitle = null ; 
	  var objtype = null ; 
	  var objuid = null ; 
	  var objTable = null ; 
	  //for(var i = 0 ; i < iApprCnt ; i++)
	  //for(var i = iApprCnt -1 ; i > 0 ; i--)
	  for(var i = 1 ; i < APPR_SIZE-1 ; i++)
	  {
	      frm.tbapprperuid[i].value = ""; 
	      frm.tbapprpertype[i].value = "";

	      objtitle = document.getElementById("apprtitle"+i+""); 
	      objtype = document.getElementById("apprtype"+i+""); 
	      objuid = document.getElementById("appruid"+i+"");
//	       objup = eval("document.all.apprup"+i+""); 
	      objTable = document.getElementById("apprtableadd"+i+"");
	      
	      objtitle.innerHTML = "";
	      objtype.innerHTML = "" ; 
	      objuid.innerHTML = "" ;
//	       objup.innerHTML = "";
	      
	      if(objTable != null) {
	          objTable.innerHTML = "" ;
	      }
	  }
	  frm.apprpersontablecnt.value = 0 ; 
	  frm.apprpersoncnt.value = 0 ; 
}

//협조 결재자 초기화
function setApprHelpPersonInit() 
{
	var frm = document.getElementById("apprWebForm");
	  var iApprCnt = 0 ; 
	  var objCnt = frm.apprpersoncnt ; 
	  if ((objCnt.value == null )|| (objCnt.value == "")) iApprCnt = 0 ; 
	  else iApprCnt = objCnt.value ; 

	  var objtitle = null ;
	  var objtype = null ; 
	  var objuid = null ; 
	  var objTable = null ; 
	  var helpObj = document.getElementById("helpobj");	//협조 테이블

	  for(var i = 0 ; i < HELP_SIZE ; i++)
	  {
	      frm.tbapprperuid_help[i].value = ""; 
	      frm.tbapprpertype_help[i].value = ""; 

	      objtitle = document.getElementById("apprtitle_help"+i+"");
	      objtype = document.getElementById("apprtype_help"+i+"");
	      objuid = document.getElementById("appruid_help"+i+"");
//	       objup = eval("document.all.apprup_help"+i+""); 
	      objTable = document.getElementById("apprtableadd_help"+i+"");

	      $(objtitle).html("");
	      $(objtype).html("");	// 김정국 innerhtml 오류 수정
	      $(objuid).html("");
	      
	      //objtype.innerHTML = "" ; 
	      //objuid.innerHTML = "" ;
	      
//	       objup.innerHTML = "";
	      if(objTable != null) {
	    	  $(objTable).html("");
	          //objTable.innerHTML = "" ;
	      }
	  }
    //helpObj.style.display = "none";	//협조 테이블 숨김
}

//선택된결재자들을 화면에 보여주기
function setApprPersonLine(sTemp, apprType)
{
	var frm = document.getElementById("apprWebForm");
    // 초기화
    setApprPersonInit_tot();
    setApprPersonInit() ; 

    if(apprType=='A'){
    	setApprHelpPersonInit() ;	//합의문서가 생성되는 문서에서는 제외한다.(스타리온) - 김정국 잠시 살림.
    }

    var sApprCnt = 0 ; 
    var sApprHelpCnt = 0 ;
    var sApprVal = null ; 
    var lastHelp = false;
    var helpObj = document.getElementById("helpobj");	//협조 테이블
    var firstApprCnt = -1;
    var firstHelpCnt = -1; //최초 협조 결재자 순번
    var sApprObj = new Array();	//일반결재자
    var sApprHelpObj = new Array();	//협조결재자

//	arrPeople.reverse();	//하나로 역방향 순서로 변경
	
    //일반 결재와 협조 결재 분리
    for (var i = 0 ; i < arrPeople.length; i++ )  
    {
  		objApprVal = arrPeople[i] ;
        if(objApprVal.apprtype=="H"){	//협조 결재자
  	        sApprHelpObj.push(arrPeople[i]);
        	if(firstHelpCnt==-1){
        		firstHelpCnt = i; 	//최초 협조자 순번
        	}
        }else{	//일반 결재자 
        	sApprObj.push(arrPeople[i]);
        	firstApprCnt = i;
  		}
    }
    
    //합의자만 지정된 경우 값을 셋팅하지 말자
    if(sApprObj.length==0){
    	alert("합의자만 결재자로 지정할수 없습니다.\n\n결재자를 포함해서 선택해주십시오.");
    	return;
    }
    
    //최종결재자가 협조이면 결재를 조정한다. 알림으로 알려준다.
    if(arrPeople[arrPeople.length-1].apprtype=="H"){
//    	alert("마지막 결재자는 합의자가 될 수 없습니다. \n\n마지막 결재자가 아래로 이동합니다.");
//    	lastHelp = true;
    	alert("마지막 결재자는 합의자가 될수 없습니다. \n\n합의자 위치를 조정해주십시오.")
    	return;
    }
    
    //일반 결재자 처리 / 마지막 결재자는 별도 처리
    for (var i = 0 ; i < sApprObj.length-1 ; i++ ) 
    {
    	objApprVal = sApprObj[i] ;
    	addApprTable(sApprCnt) ; //테이블 추가
    	tblInsert(sApprCnt+1, objApprVal, sApprObj.length, sApprCnt) ; //값 추가
    	sApprCnt =  addIndex1(sApprCnt) ;  //1 증가
    }
    
    //협조 결재자 처리
    var num_help =  eval(HELP_SIZE) -sApprHelpObj.length;
    for (var i = 0 ; i < sApprHelpObj.length ; i++ )  
    {
  		objApprVal = sApprHelpObj[i] ;
  		helpObj.style.display = "";	//협조가 있으면 협조 테이블 visiable
        tblInsertHelp(sApprHelpCnt, objApprVal) ; //값 추가
  		sApprHelpCnt =  addIndex1(sApprHelpCnt) ;  //1 증가
    }
    
    //제일 마지막 결재자 처리---------------------------
    if(sApprObj.length > 0){
		var lastIndex=APPR_SIZE-1;
	    objApprVal = sApprObj[sApprObj.length-1] ;
	    addApprTable(lastIndex) ; //테이블 추가
	    tblInsert(lastIndex,objApprVal, sApprObj.length, sApprCnt) ; //값 추가
	    sApprCnt = addIndex1(sApprCnt) ;  //1 증가
	}
  
	//결재자 재 정리
	if(lastHelp){	//마지막 결재가 합의 이면 바로 위에 결재자와 위치를 바꾼다.
		var tmp = new Array();
		for (var i = 0 ; i < firstApprCnt; i++ )  
		{
			tmp.push(arrPeople[i]);
		}
		for(var j=firstApprCnt+1;j<arrPeople.length;j++){
			tmp.push(arrPeople[j]);
		}
		tmp.push(arrPeople[firstApprCnt]);
		arrPeople = tmp;
	}
	
	//DB 저장을위한 결재자 지정
	for (var i = 0 ; i < arrPeople.length; i++ )
	{
		objApprVal = arrPeople[i] ;
	    frm.tbapprperuid_tot[i].value  = objApprVal.id ; 
	    frm.tbapprpertype_tot[i].value  = objApprVal.apprtype ;
	    frm.tbapprperfix_tot[i].value  = (objApprVal.fixed==undefined) ? "" : objApprVal.fixed ;
	}
    //제일 마직막 결재자 처리 끝-------------------------
	frm.apprpersoncnt.value = sApprCnt ;
    //최초 협조자 순번 처리
    frm.apprhelpcnt.value = firstHelpCnt ;
	setSlash( sApprCnt );
}

function setApprPersonInit_tot() 
{
	var frm = document.getElementById("apprWebForm");
	var apps = document.getElementsByName("tbapprperuid_tot");
	for(var i = 0 ; i < apps.length ; i++)
	{
		frm.tbapprperuid_tot[i].value = "";
		frm.tbapprpertype_tot[i].value = "";
	}
}

function setSlash(no){
//appruidx : x number
//perx : x number
	var totApLine=10;
	for(var ii=0 ; ii < no-1 ; ii++){
		if(document.getElementById("per"+ii) ) document.getElementById("per"+ii).background="";
	}
	for(var ii=no-1 ; ii < totApLine-1 ; ii++){
		if(document.getElementById("per"+ii) ) document.getElementById("per"+ii).background="/images/slash.gif";
	}
}
var arrPeople = new Array() ; 
var arrPeople_req = new Array();
//--------------------------------------------------------------------------------
//결재자 선택 (window.showModalDialog Version)
function goApprPerModal(apprType)
{
	var apType = "AP";
//	if ( arguments.length > 0 ) {
//		apType = "HAP";
//	}

	var helpType = "1";
	if(apprType=="H"){
		helpType = "6";
	}
	
    var sUrl = "./appr_apprperson.htm?formId="+FormCode + "&apprtype=" + helpType ;
    sUrl += "&apprcnt=" + APPR_SIZE + "&helpcnt=" + HELP_SIZE;
    sUrl += "&aptype=" + apType;
    sUrl += "&cmd=EDIT";

//objRecipients.name 성명
//objRecipients.id   UID
//objRecipients.position  직위명
//objRecipients.department  부서명
//objRecipients.apprtype  결재 형태
//objRecipients.apprname  결재 형태 명
    
    //arrPeople = arrPeople.reverse() ;
    var args = new Object();
    args.window = window;	//모달에서 window open시 쿠키 정보가 사라지는 문제를 해결하기 위해 부모의 객체를 사용한다.
	var returnval = window.showModalDialog(sUrl, args, "dialogHeight: 430px; dialogWidth: 600px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
	setGoApprPer(returnval);
}

//결재자 선택 (dhtmlmodal Version)
function goApprPer(apprType) {
	var apType = "AP";
	var helpType = "1";
	if (apprType=="H") { helpType = "6"; }
	
    var url = "./appr_apprperson.htm?formId="+FormCode + "&apprtype=" + helpType ;
    url += "&apprcnt=" + APPR_SIZE + "&helpcnt=" + HELP_SIZE;
    url += "&aptype=" + apType;
    url += "&cmd=EDIT"
    url += "&gianUID=" + gianUID;

	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_APPR1003", "iframe", url, "전자결재", 
		"width=600px,height=430px,resize=0,scrolling=1,center=1", "recal"
	);
	SaveApprType.set(apprType);
}

SaveApprType = {
		value: null,
		set: function(value) { this.value = value; },
		get: function() { return this.value; }
};

function getApprPer(ApprType) {
	if (ApprType=="5") {
		return arrPeople_req;
	}
	return arrPeople;
}

function setApprPer(returnval) {
	var apprType = SaveApprType.get();
	SaveApprType.set(null);

	//아래 goApprLineSend()의 결재선 변경 컨펌을 여기서 확인해야 함. 2013.08.19 김정국
	//var frm = document.getElementById("apprWebForm");
    //if (!confirm("변경된 결재선을 저장하시겠습니까?)")) return ;
		
	if (returnval != null) {
		
		if (apprType == 'A') {
//		    if (!confirm("변경된 결재선을 저장하시겠습니까?)")) return ; //진행문서 결재선 변경시 `confirm`로 재확인 않함.
		    arrPeople = new Array();
			for (var i = 0; i < returnval.length; i++) {
				arrPeople.push(returnval[i]);
			}
			setApprPersonLine(arrPeople, apprType);
			setApLineEditorByRead();
			goApprLineSend(true);
		} else {
			arrPeople = new Array();
			for (var i = 0; i < returnval.length; i++) {
				arrPeople.push(returnval[i]);
			}
        	//arrPeople = arrPeople.reverse() ;
			setApprPersonLine(arrPeople, apprType);
		
			//결재선 설정
			setApLineEditorByRead();
		}
	}
}

//---------------------------------------------------------------------------------
//2013-8-19 결재선 변경사항 저장
function goApprLineSend(check) {
	var frm = document.getElementById("apprWebForm");
	if (!check) if (!confirm("변경된 결재선을 저장하시겠습니까?)")) return;

	frm.calltype.value = "";
	if (FormCode.length == 4) {
		if (document.getElementById("dispRegContent")) {
			frm.dbody.value = document.getElementById("dispRegContent").innerHTML;
		}
		// 정형양식 본문내용 처리하기위함.
		if (document.getElementById("regBody")) {
			frm.regbody.value = document.getElementById("regBody").innerHTML;
		}
	} else {
		frm.dbody.value = document.getElementById("dispContent").innerHTML;
	}

	frm.action = "apprLineEditcontrol.htm";
	frm.method = "post";
	frm.submit();
}

function goApprReqLineSend(check)
{
	var frm = document.getElementById("apprWebForm");
    if (!check) if (!confirm("변경된 결재선을 저장하시겠습니까?)")) return ;
    
    frm.calltype.value = "" ;
    if(FormCode.length==4){
    	if (document.getElementById("dispRegContent")) {
    		frm.dbody.value = document.getElementById("dispRegContent").innerHTML;
    	}
    	//정형양식 본문내용 처리하기위함.
    	if (document.getElementById("regBody")) {
    		frm.regbody.value = document.getElementById("regBody").innerHTML;
    	}
    }else{
    	frm.dbody.value = document.getElementById("dispContent").innerHTML;
    }
    
    frm.action = "apprReqLineEditcontrol.htm";
    frm.method = "post" ; 
    frm.submit() ;
}

//--------------------------------------------------------------------------------
function OnClickNew(sCmd)
{
	var frm = document.getElementById("apprWebForm");
    if (!confirm("문서를 다시 작성하시겠습니까?\n(지금까지 작성한 내용이 삭제 됩니다.)")) return ; 
    frm.cmd.value = sCmd ;
    frm.apprid.value = "" ;    
    frm.action = "imsidoc.htm" ;
    frm.method = "get" ; 
    frm.submit() ;
}
//--------------------------------------------------------------------------------
function OnDelete(sApprid, scalltype)
{
	var frm = document.getElementById("apprWebForm");
    if (!confirm("문서를 삭제하시겠습니까?")) return ; 

    if (sApprid == "" ) { //임시저장문서가 아니면 새문서로 보내라.
        if (!confirm("신규 작성 결재 문서입니다. \n\n새로 작성하시겠습니까?")) return ; 
            OnClickNew("") ; 
        return ; 
    }
    frm.calltype.value = scalltype ;
    frm.action = "imsicontrol.htm" ;
    frm.method = "post" ; 
    frm.submit() ;
}
//--------------------------------------------------------------------------------
//리스트 화면으로 이동
function returnList(sAction)
{
	var frm = document.getElementById("apprWebForm");
    frm.cmd.value = "" ; 
    frm.action = sAction ;//"./appr_imsilist.jsp" ;
    frm.method = "get" ; 
    frm.submit() ;
}

//------------------------------------------------------------------------------------------------------------------
//소유권이전
function getReceiveOwnID()
{
	var frm = document.getElementById("apprWebForm");
    url = "../common/department_selector.htm?openmode=1&isadmin=0&expand=1&expandid=00000000000000&onlydept=0&onlyuser=1&winname=parent&conname=mainForm" ;

    var objDaeri = new Object() ;
    var returnval = OpenModal( url , objDaeri, 320 , 350 ) ;
    if (returnval != null && returnval != "") {
        var arrVal = returnval.split(":") ;

        var sNm = arrVal[0] ;  //
        var sID = arrVal[1] ;  //ID
        var sUnm = arrVal[2] ;
        var sDnm = arrVal[3] ;
        var sText = sNm + "/" + sUnm + "/" + sDnm ;

        frm.receiveownid.value = sID ;
        //alert(frm.receiveownid.value+"/"+sText ) ; 
        frm.action = "./appr_onedocchangeown.htm" ; 
        frm.method ="post" ; 
        frm.submit() ; 
    }
}

//--------------------------------------------------------------------------------
//본문내용 입력
function setBody()
{
    //var body = document.all.dspbody.innerHTML ;        
    var body = document.all.dspbody.innerText ;        
    document.all.WebEditor.DocumentHTML = body ;
    //document.all.WebEditor.DOM.body.innerHTML = body ; //입력의 다른 방법
}

//--------------------------------------------------------------------------------
//결재 양식 을 가져와라.
function selFormContent(sFomType)
{
	var frm = document.getElementById("apprWebForm");
    var sFormid = frm.apprformsel[frm.apprformsel.selectedIndex].value ;
    if (sFormid == "" )
    {
        document.all.apprform.innerHTML = "" ;
        frm.formtitle.value = "" ;
        document.all.WebEditor.DocumentHTML = "" ;
        document.all.dspFormName.innerText= "일 반 양 식";
        frm.preserveitems.selectedIndex = 2 ;
        frm.apprformid.value = "";
        return  ;
    }
    document.subForm.apprformid.value = sFormid;
    frm.apprformid.value = sFormid;
    document.subForm.calltype.value = sFomType  ;
    document.subForm.submit() ;
    changeFormName();
}

//결재 양식명을 변경한다.
function changeFormName(){
	if( ! document.all.apprformsel ) return;
	var option=document.all.apprformsel.options;
	var formname=option[option.selectedIndex].text;
	document.all.dspFormName.innerText=formname;
}

var apprReceive = new Array() ; 
var apprReference = new Array() ; 
var ORGUNIT_TYPE_USER = 0;
var ORGUNIT_TYPE_DEPARTMENT = 1;
//--------------------------------------------------------------------------------
//수신처지정 (window.showModalDialog Version)
function goReceive() {
    var sUrl = "../common/recipient_selector.htm?"+RECEIVE_URL_PARAM;
    var sOpt = "dialogHeight: 400px; dialogWidth: 600px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no";
    var returnval = window.showModalDialog(sUrl, apprReceive, sOpt);
    setReceive(returnval);
}

//수신처지정 (dhtmlmodal Version)
function goReceive() {
    var url = "../common/recipient_selector.htm?"+RECEIVE_URL_PARAM;
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_COMM1001", "iframe", url, "전자결재", 
		"width=600px,height=400px,resize=0,scrolling=1,center=1", "recal"
	);
}

function getReceive() {
	return apprReceive;
}

function setReceive(returnval) {
	if (returnval != null) {
		apprReceive = new Array();
		for (var i = 0; i < returnval.length; i++) {
			apprReceive.push(returnval[i]);
		}
		setReceiveLine() ; 
	}
}

//결재 문서 링크
function goHelpApproval(apprid)
{
	if(apprid==""||apprid==undefined){
		alert("아직 합의부서의 진행이 되지 않았습니다.");
		return;
	}
	var WinWidth = 800 ; 
	var WinHeight = 600 ; 
	var winleft = (screen.width - WinWidth) / 2;
	var wintop = (screen.height - WinHeight) / 2;
	var UrlStr = "../approval/apprdoc.htm?menu=340&apprId="+apprid+"&pop=POP" ;
	var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
}

//--------------------------------------------------------------------------------
//선택된결재자들을 화면에 보여주기
function setReceiveLine()
{
    //초기화
    document.getElementById("receivehtml").innerHTML = "" ; 
    var objReceive = null ; 
    var sText = "" ; 
    for (var i = 0 ; i < apprReceive.length ; i++ ) 
    {
        objReceive = apprReceive[i] ; 

        sText = getReceiveDisplayStr(objReceive) ;

        tbReceiveInsert(sText, objReceive) ;
    }
}
//--------------------------------------------------------------------------------
function getReceiveDisplayStr(objReceive) 
{
    var strDisplay = "" ; 
	if (objReceive.type == ORGUNIT_TYPE_USER) {
		strDisplay += objReceive.name;
		strDisplay += "/";
		//strDisplay += objReceive.position;
		//strDisplay += "/";
		strDisplay += objReceive.department;
	} else if (objReceive.type == ORGUNIT_TYPE_DEPARTMENT) {
		strDisplay += objReceive.name;
		if (objReceive.includeSub) {
			strDisplay += "[+]";
		} else {
			strDisplay += "[-]";
		}
	}
    return strDisplay ; 
}
//--------------------------------------------------------------------------------
//수신자 추가
function tbReceiveInsert(sText, objReceive)
{
//receivehtml <div> id

    var sGubun = "" ; 
    var common  = "" ; 
    if (objReceive.type == ORGUNIT_TYPE_USER)  {
        sGubun = RECEIVE_USER ; 
        common = VAL_F ; 
    } else if (objReceive.type == ORGUNIT_TYPE_DEPARTMENT) {
        sGubun = RECEIVE_DEPT ; 
        if (objReceive.includeSub) //공유 구분
            common = VAL_T ; 
        else 
            common = VAL_F ; 
    }

    var sHtml = document.getElementById("receivehtml").innerHTML ;

    document.getElementById("receivehtml").innerHTML = sHtml + 
        "<font color='#000000'>" +sText + "</font>&nbsp;&nbsp;&nbsp;" +
        "<input type='hidden' name='receivetype' value='"+ sGubun +"'>" +
        "<input type='hidden' name='receiveid' value='"+ objReceive.id +"'>" + 
        "<input type='hidden' name='commoncheck' value='"+ common +"'>" ;
}


function addIndex1(index)
{
    return eval(index) + eval(1) ;
}

function addIndex(index, i)
{
    return eval(index) + eval(i) ;
}

//결재자정보 추가화면
function getApprTableHTML(indexOrg,cnt)
{
var index = eval(indexOrg) - eval(3) ;// 2는 처음이 6,6+8 6+8+8 , 6+8+8+8 증가 즉 2만큼 부족 그리고 loop가 0시작 1부족 합이 3
var sApprTableHTML =
"<table><tr><td class='tblspace03'></td></tr></table>" +
"<table cellspacing='0' cellpadding='0' class='table2'>" +
"<tr bgcolor='#EDF2F5'>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 1)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 1)+"'></span>" +
       "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 2)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 2)+"'></span>" +
        "<input type='hidden' name='tbapprperuid'  >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 3)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 3)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype'>" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 4)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 4)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype'>" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 5)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 5)+"'></span>" +
        "<input type='hidden' name='tbapprperuid'>" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 6)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 6)+"'></span>" +
        "<input type='hidden' name='tbapprperuid'  >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 7)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 7)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype'>" +
    "</td>" +
    "<td width=100 class='Appborder' id='tapptype"+addIndex(index, 8)+"' style='display:none'>&nbsp;<span id='apprtype"+addIndex(index, 8)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
"</tr>" +
"<tr style='HEIGHT:90px'>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 1)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 1)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 2)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 2)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 3)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 3)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 4)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 4)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 5)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 5)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 6)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 6)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 7)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 7)+"'></span></td>" +
    "<td class='Appborder' id='tappuid"+addIndex(index, 8)+"' style='display:none'>&nbsp;<span id='appruid"+addIndex(index, 8)+"'></span></td>" +
"</tr>" +
"<tr>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 1)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 1)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 2)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 2)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 3)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 3)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 4)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 4)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 5)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 5)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 6)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 6)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 7)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 7)+"'></span></td>" +
    "<td class='Appborder' id='tapp"+addIndex(index, 8)+"' style='display:none'>&nbsp;<span id='apprup"+addIndex(index, 8)+"'></span></td>" +
"</tr>" +
"</table>" +
"<table class='tblspace03'><tr><td></td></tr></table>" +
"<div id='apprtableadd"+addIndex(index, 8)+"' style='display:'></div>" ; 
//alert(addIndex(index, 8)+"   "+index); 
var objDiv = eval("document.all.apprtableadd"+index); 
if(objDiv) objDiv.innerHTML = sApprTableHTML ; 

}

function getApprTableHTML_old(indexOrg)
{
var index = eval(indexOrg) - eval(3) ;// 2는 처음이 6,6+8 6+8+8 , 6+8+8+8 증가 즉 2만큼 부족 그리고 loop가 0시작 1부족 합이 3
var sApprTableHTML =
"<table><tr><td class='tblspace03'></td></tr></table>" +
"<table width='800' cellspacing='0' cellpadding='0' class='table2'>" +
"<tr bgcolor='#EDF2F5'>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 1)+"'></span>" +
       "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 2)+"'></span>" +
        "<input type='hidden' name='tbapprperuid'  >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 3)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype'>" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 4)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype'>" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 5)+"'></span>" +
        "<input type='hidden' name='tbapprperuid'>" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 6)+"'></span>" +
        "<input type='hidden' name='tbapprperuid'  >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 7)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype'>" +
    "</td>" +
    "<td class='Appborder'>&nbsp;<span id='apprtype"+addIndex(index, 8)+"'></span>" +
        "<input type='hidden' name='tbapprperuid' >" +
        "<input type='hidden' name='tbapprpertype' >" +
    "</td>" +
"</tr>" +
"<tr style='HEIGHT:90px'>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 1)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 2)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 3)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 4)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 5)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 6)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 7)+"'></span></td>" +
    "<td class='Appborder'>&nbsp;<span id='appruid"+addIndex(index, 8)+"'></span></td>" +
"</tr>" +
"<tr>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
    "<td class='Appborder'>&nbsp;</td>" +
"</tr>" +
"</table>" +
"<table class='tblspace03'><tr><td></td></tr></table>" +
"<div id='apprtableadd"+addIndex(index, 8)+"' style='display:'></div>" ; 
//alert(addIndex(index, 8)+"   "+index); 
var objDiv = eval("document.all.apprtableadd"+index); 
if(objDiv) objDiv.innerHTML = sApprTableHTML ; 

}


//Daum editor 
function setApLineEditorCross() {
	alert("START- setApLineEditorCross");
 	try {
		var d = null;
		var ifrm = document.getElementById("tx_canvas_wysiwyg");
		if (ifrm == null) {
			d = document;
		} else {
			var y = (ifrm.contentWindow || ifrm.contentDocument);
			d = y.document;
		}

		var appobj = document.getElementById("appobj");	//ap table
		//F_APLINE,F_APLINE_H
		var F_TABLE = d.getElementById("F_APLINE").childNodes[1];
// 		if (F_TABLE.nodeType == 3) F_TABLE = d.getElementById("F_APLINE").childNodes[2];
		F_TABLE = $(d.getElementById("F_APLINE")).find("table").get(0);
		for ( var i=0; i < appobj.rows.length; i++ ) {
			for ( var j=0; j < appobj.rows[i].cells.length; j++) {
				if ( i==0 ) {
					//F_TABLE.rows[i].cells[j+1].innerText = appobj.rows[i].cells[j].innerText;
					F_TABLE.rows[i].cells[j+1].innerHTML = "<SPAN id=APPRTITLE" + j+">"+TrimAll(appobj.rows[i].cells[j].innerText)+"</SPAN>";
				} else if ( i==2 ) {
					console.log($(appobj.rows[i].cells[j]).html());
					F_TABLE.rows[i].cells[j].innerHTML = TrimAll(appobj.rows[i].cells[j].innerText); //.childNodes[1]
					// 직급 + 이름으로 되어 있는것을 이름만 표기
				} else {
					//결재사인을위해 정보 임의 ID 부여
					F_TABLE.rows[i].cells[j].innerHTML = "<SPAN id=APPRSIGN" + j+"></SPAN>";
					//F_TABLE.rows[i].cells[j].innerText = appobj.rows[i].cells[j].innerText;
				}
			}
		}

		//합의설정
		var appobj = document.getElementById("helpobj");	//ap table
		//F_APLINE,F_APLINE_H
		var F_TABLE = d.getElementById("F_APLINE_H").childNodes[1];
// 		if (F_TABLE.nodeType == 3) F_TABLE = d.getElementById("F_APLINE_H").childNodes[2];
		F_TABLE = $(d.getElementById("F_APLINE_H")).find("table").get(0);
		for ( var i=0; i < appobj.rows.length; i++ ) {
			for ( var j=0; j < appobj.rows[i].cells.length; j++) {
				if ( i==0 ) {
					//F_TABLE.rows[i].cells[j+1].innerText = appobj.rows[i].cells[j].innerText;
					F_TABLE.rows[i].cells[j+1].innerHTML = "<SPAN id=HELPTITLE" + j+">"+TrimAll(appobj.rows[i].cells[j].innerText)+"</SPAN>";
				} else if ( i==2 ) {
// 					F_TABLE.rows[i].cells[j].innerText = appobj.rows[i].cells[j].childNodes[1].innerText;
					F_TABLE.rows[i].cells[j].innerHTML = TrimAll(appobj.rows[i].cells[j].innerText); //.childNodes[1]
					// 직급 + 이름으로 되어 있는것을 이름만 표기
				} else {
					//F_TABLE.rows[i].cells[j].innerText = appobj.rows[i].cells[j].innerText;
					F_TABLE.rows[i].cells[j].innerHTML = "<SPAN id=HELPSIGN" + j+"></SPAN>";
				}
			}
		}
	//alert( 'editor에 결재선 설정 테스트');
  	} catch(e) {
  	}
}
