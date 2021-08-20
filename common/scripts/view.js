function senddata( args ) {
	document.all['id'].value = args ;
	document.form1.submit();
}

function docNothing(){
	var str = "<table width=100%><tr><td class=docNothing>";
	str = str + "<br><br><br><font style='font-size:12pt'><img src=/images/i_filenotfound.gif></font><br><br><br><br>";
	str = str + "</td></tr></table>";
	
	document.all["docNothing"].innerHTML = str;
}

//보기에서 문서 선택 후 삭제하는 함수
function deletedoc() {
	var selectmsg = "문서를 선택하여 주십시오     " ;
	var ids = getids() ;
	
	if ( ids == "" ) { 
		alert( selectmsg );
		return ;
	}
	var docnum = ids.split(',').length ;
	var deletemsg = "선택하신 " + docnum + "개의 문서를 삭제 하시겠습니까 ?     " ;
	if ( !confirm( deletemsg ) ) {
		return ; 
	}
}

//검색 URL을 만들어 주는 함수
function searchsubmit(){
	if(document.all.Search.value == ""){
		alert("검색 질의어를 입력하여 주십시오");
		document.all.Search.focus();
		return;
	}

	var option = document.all.SearchInfo.options;
	if (option.selectedIndex < 1) {
		alert('검색 분류를  선택하여 주십시오.');
		option.focus() ;
		return;
	}

	var url = document.location.href;
	
	if(url.indexOf("?") == -1){
		url = url + "?";
	}

	if(url.indexOf("&cmd=search") != -1){
		tmpstr = url.split("&cmd=search");
		url = tmpstr[0];
	}
	
	url = url + "&cmd=search&SearchInfo=" + document.all["SearchInfo"].value + "&Search=" + document.all["Search"].value;
	document.location.href = url;
}

//보기의 배경 및 줄간 색 설정
function ViewColorSet( vwTable ) {
	try {
		var tmp ;
		var TRLength = vwTable.rows.length ;		
		var startcnt = 1 ;

		for (i=startcnt; i < TRLength; i++) {
			if ( vwTable.rows[i].cells.length == 1 ) {
			} else {
				// TR 높이, 배경색, 줄간색구분, RollOver
				// vwTable.rows[i].style.height = "19px" ;
				vwTable.rows[i].onmouseover = LineOver ;
				vwTable.rows[i].onmouseout=LineOut ;
				vwTable.rows[i].onclick = LineClick ;
			}
		}
	}
	catch(e) {
		alert( 'View.js의 ViewColorSet() Error !' );
	}
}

//마우스 over 색상 및 스타일 설정
function LineOver() {
	// TD 개체의 Border들을 설정해 줌
	//var borderStyle = "1px solid #79a9d2";
	//var borderStyle = "1px solid #3C3C3C";
	//this.style.backgroundColor = "#79a9d2";

	for(var j =0; j < this.cells.length ; j++){
		var cell = this.cells[j] ;
//		if ( cell.innerHTML == "" ) {
//			cell.innerHTML = "&nbsp;"
//		}

//		cell.style.borderTop = borderStyle;
//		cell.style.borderBottom = borderStyle;
//		cell.style.cursor = "default";
		cell.style.backgroundColor = "#EFEFEF";
	}
//	this.cells[0].style.borderLeft = borderStyle;
//	this.cells[this.cells.length-1].style.borderRight = borderStyle;
}

//마우스 out시 원래 스타일로 변경하는 함수
function LineOut() {
	// TD 개체의 Border들을 Clear 해줌
	for(var j=1; j < this.cells.length; j++){
	//	this.cells[j].style.border = "";
		this.cells[j].style.backgroundColor = "#FFFFFF" ;
	}
}

//문서 선택 시 문서의 checkbox에 check
function LineClick() {
	if ( this.cells[0].children[0].name == 'docid' ) {	//첫 컬럼의 id가 docid ( 체크박스개체 ) 라면...
		var chkbox = this.cells[0].children[0] ;

		if ( chkbox.checked ) {
			chkbox.checked = false ;
		} else {
			chkbox.checked = true ;
		}
	}
}

function ChkBoxClick( args ) {
	if ( args.checked ) {
		args.checked = false ;
	} else {
		args.checked = true ;
	}
}

function SelectChkBox( args ) {
	var docid = document.all['docid'] ;
	if ( !docid ) { return false }
	var chk;
	if(docid[0]){
		chk = true;
		if(docid[0].checked) chk =false;
		var i=0;
		while(docid[i]){
			docid[i].checked =chk;
			i++;
		}		
	}else if(docid){
		chk = true;
		if(docid.checked) chk =false;
		docid.checked = chk;
	}		
}
function getids() {
	var docid = document.all['docid'] ;
	var ids = "" ;
	if ( !docid ) { 
		alert( "오류 ! CHECKBOX 개체가 없습니다     " ) ;
		return ids
	}

	for ( var i = 0; i < docid.length; i++ ) {
		if ( docid[i].checked ) {
			if ( ids == "" ) {
				ids = docid[i].value;
			} else {
				ids = ids + "," + docid[i].value;
			}
		}
	}
	return ids ;
}

function na_restore_img_src(name, nsdoc)
{
  var img = eval((navigator.appName == 'Netscape') ? nsdoc+'.'+name : 'document.all.'+name);
  if (name == '')
    return;
  if (img && img.altsrc) {
    img.src    = img.altsrc;
    img.altsrc = null;
  } 
}

function na_preload_img()
{ 
  var img_list = na_preload_img.arguments;
  if (document.preloadlist == null) 
    document.preloadlist = new Array();
  var top = document.preloadlist.length;
  for (var i=0; i < img_list.length; i++) {
    document.preloadlist[top+i]     = new Image;
    document.preloadlist[top+i].src = img_list[i+1];
  } 
}

function na_change_img_src(name, nsdoc, rpath, preload)
{ 
  var img = eval((navigator.appName == 'Netscape') ? nsdoc+'.'+name : 'document.all.'+name);
  if (name == '')
    return;
  if (img) {
    img.altsrc = img.src;
    img.src    = rpath;
  } 
}

//월력보기의 tooltip
function  showcalendar(sw, subject, date, content)
{	
	var text;
	text = '<div id="inn" style="position:relative; overflow:hidden; width:200px; height:110px; background-color:#FFFFE0; font-size:9pt; border-width:1px; border-color:black; border-style:solid;z-index:64 ">';
	text += '<table class="table_basic" width=200 border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFE0" STYLE="table-layout:fixed;">';
	text += '<tr><td  nowrap style="text-overflow:ellipsis; overflow:hidden;"><font color=#000000>제목 : </font><font color=blue>' + subject + '</font></td></tr>';
	text += '<tr><td  nowrap style="text-overflow:ellipsis; overflow:hidden;">날짜 : </font><font color=blue>' + date + '</td></tr>';
	text += '<tr><td  nowrap style="text-overflow:ellipsis; overflow:hidden;">내용 : </font><font color=blue>' + content + '</td></tr></table></div>';
	
	if (document.body.scrollLeft+event.clientX+240 > document.body.clientWidth){
		document.all["message"].style.pixelLeft = document.body.clientWidth - 210 ;
	} else {
		document.all["message"].style.pixelLeft = document.body.scrollLeft + event.clientX +30 ;
	}
	
	if (document.body.scrollLeft+event.clientY + 120 > document.body.clientHeight)
		document.all["message"].style.pixelTop = document.body.scrollTop+event.clientY-120; 
	else		
		document.all["message"].style.pixelTop = document.body.scrollTop+event.clientY+10; 

	message.innerHTML = text;
     if(sw == 1 ){
		document.all["message"].style.display = "";
	}else 
		document.all["message"].style.display = "none";
}
