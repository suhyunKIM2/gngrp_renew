<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- jqGrid -->
<link rel="stylesheet" type="text/css" media="screen" href="/resources/css/jqgrid/4.4.1/ui.jqgrid.css" />
<!-- 
<link rel="stylesheet" type="text/css" media="screen" href="/resources/css/jqgrid/4.4.1/ui.multiselect.css" />
 -->
<!-- 그리드 스타일
<link rel="stylesheet" type="text/css" media="screen" href="/resources/css/themes/${userVO.grid_style}/jquery-ui.css" />
 -->

<!-- 
<script type="text/javascript" src="/resources/js/jquery-1.6.min.js"			></script>
 -->
<!-- 
<script type="text/javascript" src="/resources/js/jquery-1.9.1.min.js"			></script>
<script type="text/javascript" src="/resources/js/jquery-migrate-1.1.0.js"		></script>
 -->
<script type="text/javascript" src="/resources/js/jquery-1.8.3.min.js"			></script>
<script type="text/javascript" src="/resources/js/jquery.cookie.js"				></script>
<script type="text/javascript" src="/resources/js/util/util-2562.js"			></script>
<script type="text/javascript" src="/resources/js/util/string.js"				></script>
<script type="text/javascript" src="/resources/js/jquery.layout.js"				></script>
<script type="text/javascript" src="/resources/js/jquery.alphanumeric.plus.js"	></script>

<!-- jQGrid Plugin -->
<script type="text/javascript" src="/resources/js/jqgrid/4.4.1/i18n/grid.locale-kr.js"		></script>
<script type="text/javascript" src="/resources/js/jqgrid/4.4.1/jquery.jqGrid.min.js"			></script>

<!-- jQuery UI plugin -->
<link rel="stylesheet" type="text/css" media="screen" href="/resources/redmond/jquery-ui-1.10.0.custom.min.css" />
<script type="text/javascript" src="/resources/js/jquery-ui-1.10.0.custom.min.js"></script>

<link rel="stylesheet" type="text/css" media="screen" href="/resources/css/jquery-ui-plugins-0.0.14.min.css" />
<script type="text/javascript" src="/resources/js/jquery-ui-plugins-0.0.14.min.js"></script>

<!-- selectBox plugin -->
<link rel="stylesheet" type="text/css" media="screen" href="/resources/css/jquery.selectBox.css" />
<script type="text/javascript" src="/resources/js/jquery.selectBox.js"></script>

<!-- form plugin -->
<script type="text/javascript" src="/resources/js/jquery.form.js"></script>

<!-- validation plugin -->
<script type="text/javascript" src="/resources/js/jquery.validate.js"></script>

<!-- mask input plugin -->
<script type="text/javascript" src="/resources/js/jquery.maskedinput.js"></script>

<script type="text/javascript" >




function setPng24(obj) { 
  obj.width=obj.height=1; 
  obj.className=obj.className.replace(/\bpng24\b/i,''); 
  obj.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+ obj.src +"',sizingMethod='image');" 
  obj.src=''; 
  return ''; 
} 


$(function(){
	$("#btnMainPage").click(function(){goPage('/fsmt/login/');});
	$("#btnLogout").click(function(){goPage('/fsmt/login/fsmtLogout.do');});
});

goPage = function(url){
	location.href = url;
};

//로딩상태 화면 시작
function fn_loadingView($loadingTxt){
	
	/*
	x1 = window.event.clientX ; 
	x2 = document.body.scrollLeft ;
	y1 = window.event.clientY ;
	y2 = document.body.scrollTop ;
	
	
	$(".loding").css("top",y1+y2-50);
	$(".loding").css("left",x1+x2-100);
	*/
	$(".loding").css("top",270);
	$(".loding").css("left",660);
	
	$("#loadingText").empty().append($loadingTxt);
	$(".loadingMask").css("display","block");
}

//로딩상태 화면 종료
function fn_unLoading(){
	$(".loadingMask").css("display","none");
}
</script>

<!--
****************************************************** 
** 달력 
ex)
$(document).ready(function(){
	$("input 아이디 또는 클래스명").datepicker({
		defaultDate: new Date(2009, 1 - 1, 30),
		showOn: "both", // focus, button, both
		showAnim: "show",  // show, fadeIn, slideDown
		duration: 200
	}); 
});

******************************************************
 -->
 <!-- 
<link type="text/css" href="/resources/css/calendar/ui.all.css" rel="stylesheet" />
  -->

<style>
<!--
#ui-datepicker-div {font-size: 75%; font-family:"Dotum", "Tahoma";}
.ui-datepicker { width: 23em; padding: .2em .2em 0; display: none; font-size: 20px;}
-->
</style>
<!-- 
<script type="text/javascript" src="/resources/js/ui/ui.core.js"></script>
<script type="text/javascript" src="/resources/js/ui/effects.core.js"></script>
<script type="text/javascript" src="/resources/js/ui/effects.blind.js"></script>
<script type="text/javascript" src="/resources/js/ui/effects.drop.js"></script>
<script type="text/javascript" src="/resources/js/ui/effects.explode.js"></script>
<script type="text/javascript" src="/resources/js/ui/ui.datepicker.js"></script>
 -->
<script type="text/javascript">
<!--
//한국어
$.datepicker.regional['ko'] = {
	monthNames: ['년 1월','년 2월','년 3월','년 4월','년 5월','년 6월','년 7월','년 8월','년 9월','년 10월','년 11월','년 12월'],
	monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
	dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
	showMonthAfterYear:true,
	currentText: '오늘',
	closeText: '닫기',
//	changeYear:true,		// 년 comboBox
    showButtonPanel: true,	// today button
//    showOtherMonths: true,	// 이번달 달력외의 다음, 이전달력 표시
//	selectOtherMonths: true,	// 이번달 달력외의 다음, 이전달력 선택
//	numberOfMonths: 3,			// 달력 갯수
//    prevText : "<",
//	nextText : ">",
	dateFormat: 'yy-mm-dd',
	buttonImageOnly: true,
	buttonText: "달력",
	buttonImage: "/resources/images/cmmn/cal/calendar.gif"
};

//영어
$.datepicker.regional['us'] = {
	showButtonPanel: true,	// today button
	dateFormat: 'yy-mm-dd',
	buttonImageOnly: true,
	buttonText: "Calendar",
	buttonImage: "/resources/images/cmmn/cal/calendar.gif"
};

$.datepicker.setDefaults($.datepicker.regional['ko']);

// 월 달력 셋팅
// 월 달력 사용시 일달력 사용 불가능
// 월 달력 사용시 페이지에 스타일 추가 (꼭 스타일로만 추가해야함.)
// table.ui-datepicker-calendar { display:none; }
// 사용 방법 
// $("#id").datepicker(datepicker_month);
var datepicker_month = {
        buttonText: "달력",
        currentText: "이번달",
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        yearRange: 'c-99:c+99',
        showOtherMonths: true,
        selectOtherMonths: true,
    	closeText : "선택",
    	dateFormat : "yy-mm",
  		duration : 200
    };
	datepicker_month.onClose = function (dateText, inst) {
		var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
		var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
		$(this).datepicker( "option", "defaultDate", new Date(year, month, 1) );
		$(this).datepicker('setDate', new Date(year, month, 1));
	};

	datepicker_month.beforeShow = function () {
		var selectDate = $(this).val().split("-");
		var year = Number(selectDate[0]);
		var month = Number(selectDate[1]) - 1;
		$(this).datepicker( "option", "defaultDate", new Date(year, month, 1) );
	};
//-->
</script>
<!--
****************************************************** 
** 달력 End
******************************************************
 -->
 <script type="text/javascript">
// 코드 리스트 조회
getAjaxCodeList = function($obj,$param,$cd){
	$.ajax({
		type:"POST",
		url	:"/getAjaxCodeList.do",
		data:$param,
		dataType: "json",
		success:function(data){fnCodeListView(data,$obj,$cd);},
		error:function(msg){
			fn_unLoading();
			alert("전송 실패!!");
			return;
		}
	});
};

// 코드값 셋팅
fnCodeListView = function(data , $obj, $cd){
	$obj.empty();

	$.each(data.rows,function(){
		$addresOption = $('<option></option>');
		
		var htmlTxt = this.cd_nm;
		$addresOption.text(htmlTxt);
		$addresOption.attr("value",this.code);
		if($cd == this.code){
			$addresOption.attr("selected",true);
		}
		$obj.append($addresOption);
	});
};

// 코드 리스트 조회 (selectBox plugin 용)
getAjaxCodeListSelectBox = function($obj, $param, $cd, $firstOption, $nextFunction){
	if(!$param.use_yn){
		$param.use_yn = "Y";
	}
	
	$.ajax({
		type:"POST",
		url	:"/getAjaxCodeList.do",
		data:$param,
		dataType: "json",
		success:function(data){fnCodeListViewSelectBox(data, $obj, $cd, $firstOption, $nextFunction);},
		error:function(msg){
			fn_unLoading();
			alert("전송 실패!!");
			return;
		}
	});
};

// 코드값 셋팅
fnCodeListViewSelectBox = function(data, $obj, $cd, $firstOption, $nextFunction){
	var cdCheck = false;
	var optionObj = "";
	$obj.empty();
	
	if($firstOption){
		optionObj = '<option value="">' + $firstOption+'</option>';
	}
	
	$.each(data.rows,function(){
		optionObj += '<option value="'+ this.code + '">' + this.cd_nm+'</option>';
		
		if($cd == this.code) cdCheck = true;
	});
	
	$obj.selectBox("options",optionObj);
	
	if(cdCheck) $obj.selectBox("value",$cd);
	
	if($nextFunction){
		eval($nextFunction);
	}
};


// Array로 코드값 object를 받아와 코드 SelectBox 셋팅.
fnClassArrSetting = function ($paramArr){

	for(var i=0 ; i < $paramArr.length ; i++ ){
		var $obj		= $paramArr[i];
		var $param 		= new Object();
		
		$param.parent_class_seq     = $obj.parent_class_seq;
		getAjaxClassCdListSelectBox($obj.selObj,$param,$obj.class_seq,$obj.titleTxt);
	}
};

//가맹점 리스트 조회 (selectBox plugin 용)
getAjaxMrhstListSelectBox = function($obj, $param, $cd, $firstOption){
	$.ajax({
		type:"POST",
		url	:"/getAjaxMrhstList.do",
		data:$param,
		dataType: "json",
		success:function(data){fnMrhstListViewSelectBox(data, $obj, $cd, $firstOption);},
		error:function(msg){
			fn_unLoading();
			alert("전송 실패!!");
			return;
		}
	});
};

//가맹점 값 셋팅
fnMrhstListViewSelectBox = function(data, $obj, $cd, $firstOption){
	var cdCheck = false;
	var optionObj = "";
	$obj.empty();
	
	if($firstOption){
		optionObj = '<option value="">' + $firstOption+'</option>';
	}
	
	$.each(data.rows,function(){
		optionObj += '<option value="'+ this.mrhst_cd + '">' + this.mrhst_nm+'</option>';
		
		if($cd == this.mrhst_cd) cdCheck = true;
	});
	
	$obj.selectBox("options",optionObj);
	
	if(cdCheck) $obj.selectBox("value",$cd);
};

//원부자재 리스트 조회 (selectBox plugin 용)
getAjaxRwmatrListSelectBox = function($obj, $param, $cd, $firstOption){
	$.ajax({
		type:"POST",
		url	:"/getAjaxRwmatrList.do",
		data:$param,
		dataType: "json",
		success:function(data){fnRwmatrListViewSelectBox(data, $obj, $cd, $firstOption);},
		error:function(msg){
			fn_unLoading();
			alert("전송 실패!!");
			return;
		}
	});
};

//원부자재 값 셋팅
fnRwmatrListViewSelectBox = function(data, $obj, $cd, $firstOption){
	var cdCheck = false;
	var optionObj = "";
	$obj.empty();
	
	if($firstOption){
		optionObj = '<option value="">' + $firstOption+'</option>';
	}
	
	$.each(data.rows,function(){
		optionObj += '<option value="'+ this.rwmatr_cd + '">' + this.rwmatr_nm +'</option>';
		
		if($cd == this.rwmatr_cd) cdCheck = true;
	});
	
	$obj.selectBox("options",optionObj);
	
	if(cdCheck) $obj.selectBox("value",$cd);
};

// 대/중/소 리스트 조회 (selectBox plugin 용)
getAjaxClassCdListSelectBox = function($obj, $param, $cd, $firstOption){
	$.ajax({
		type:"POST",
		url	:"/getAjaxClassCdList.do",
		data:$param,
		dataType: "json",
		success:function(data){fnClassCdListViewSelectBox(data, $obj, $cd, $firstOption);},
		error:function(msg){
			fn_unLoading();
			alert("전송 실패!!");
			return;
		}
	});
};

// 대/중/소  값 셋팅
fnClassCdListViewSelectBox = function(data, $obj, $cd, $firstOption){
	var cdCheck = false;
	var optionObj = "";
	$obj.empty();
	
	if($firstOption){
		optionObj = '<option value="">' + $firstOption+'</option>';
	}
	
	$.each(data.rows,function(){
		optionObj += '<option value="'+ this.class_seq + '">' + this.class_name+'</option>';
		
		if($cd == this.class_seq) cdCheck = true;
	});
	
	$obj.selectBox("options",optionObj);
	
	if(cdCheck) $obj.selectBox("value",$cd);
};

// 특정 문자 모두 바꾸기
function replaceAll(inputString, targetString, replacement){
	   var v_ret = null;
	   var v_regExp = new RegExp(targetString, "g");
	   
	   v_ret = inputString.replace(v_regExp, replacement);
	   
	   return v_ret;
 }
 
//그리드 tab 열고 닫기 
 /****************************************************/
 /****************************************************
 $("#info_close_btn").button()
					.removeClass("ui-state-default")
					.find(".ui-button-text").each(function(){
						$(this).removeClass("ui-button-text");
					})
					.click(fnTabHideShowEvent);
					
<li style="float: right;">
	<span id="info_close_btn"><span class="ui-icon ui-icon-circle-triangle-n" status="ON"></span> </span>
</li>
 ****************************************************/
fnTabHideShowEvent = function(){
	var $obj = $("#contentFormDiv");
	var $icon = $(this).find(".ui-icon");
	var $state = $icon.attr("status");
	var $icon_on = "ui-icon-circle-triangle-n";
	var $icon_off = "ui-icon-circle-triangle-s";
	
	if($state=="ON"){
		//$obj.fadeOut("fast");
		$obj.hide("blind",null,100);
		$icon.removeClass($icon_on).addClass($icon_off).attr("status","OFF");
	}else{
		//$obj.fadeIn("fast");
		$obj.show("blind",null,100);
		$icon.removeClass($icon_off).addClass($icon_on).attr("status","ON");
	}
}; 
/****************************************************/

//grid 자동 높이 조절
fn_grid_height = function(grid,minus){
 
	var gridTop = grid.offset().top;
	var windowHeight = $(window).height();
	var gridMinHeight = 100;
	var leftMenuHeight = 55;
	
	var gridHeight = 0;
	
	if(minus){
		windowHeight = windowHeight - minus;
	}
	 	
	gridHeight =  windowHeight - gridTop - leftMenuHeight;
	
	gridHeight = gridHeight > gridMinHeight ? gridHeight : gridMinHeight;
	
	grid.jqGrid("setGridHeight",gridHeight).trigger('reloadGrid');
};

// 우편번호 검색 팝업
comZipcodeSearch = function(obj){
    var site = "/ims/mst/zipcodeSearchPop.do";
    var style = "dialogWidth:400px;dialogHeight:390px;center:1;help:0;status:0;scroll:0"; // 사이즈등 style을 선언
    var rtnObj = window.showModalDialog(site, "" ,style); //우편번호 팝업
    
    if(!rtnObj)return false;
    
    obj.zip_code.val(rtnObj.post);
    obj.addr.val(rtnObj.adres);
    obj.addr_detail.focus();
    event.keyCode = null;
    return false;
};

// 상품정보찾기 팝업인데 아직 팝업창만 띄워지고 진행 안되있음.
comGoodsSearch = function(obj){
    var site = "/ims/mst/goods/goodsSearchPop.do";
    var style = "dialogWidth:800px;dialogHeight:600px;center:1;help:0;status:0;scroll:0"; // 사이즈등 style을 선언
    var rtnObj = window.showModalDialog(site, "" ,style); //우편번호 팝업
    
    if(!rtnObj)return false;
    
    obj.zip_code.val(rtnObj.post);
    obj.addr.val(rtnObj.adres);
    obj.addr_detail.focus();
    event.keyCode = null;
    return false;
};

//정규식 관련
// 영문 검사.
validatorAlpha = function (value, element){
	return this.optional(element) || /^[a-zA-Z]+$/.test(value);
};
// 영문 숫자 검사.
validatorAlphanumeric = function (value, element){
	return this.optional(element) || /^[a-zA-Z0-9]+$/.test(value);
};
// 영문 숫자 언더바(_) 검사.
validatorAlphaNumUnderbar = function (value, element){
	return this.optional(element) || /^[a-zA-Z0-9_]+$/.test(value);
};

// 정규식 메소드 추가
$.validator.addMethod("alpha",validatorAlpha);
$.validator.addMethod("alphanum",validatorAlphanumeric);
$.validator.addMethod("alphanumunder",validatorAlphaNumUnderbar);

/*
 * Translated default messages for the jQuery validation plugin.
 * Locale: KO
 * Filename: messages_ko.js
 */
$.extend($.validator.messages, {
	required: "필수 입력!!",
	remote: "수정 바랍니다.",
	email: "이메일 주소를 올바로 입력하세요.",
	url: "URL을 올바로 입력하세요.",
	date: "날짜가 잘못 입력됐습니다.",
	dateISO: "ISO 형식에 맞는 날짜로 입력하세요.",
	number: "숫자만 입력하세요.",
	digits: "숫자(digits)만 입력하세요.",
	creditcard: "올바른 신용카드 번호를 입력하세요.",
	equalTo: "값이 서로 다릅니다.",
	accept: "승낙해 주세요.",
	maxlength: jQuery.validator.format("{0}글자 이상은 입력할 수 없습니다."),
	minlength: jQuery.validator.format("적어도 {0}글자는 입력해야 합니다."),
	rangelength: jQuery.validator.format("{0}글자 이상 {1}글자 이하로 입력해 주세요."),
	range: jQuery.validator.format("{0}에서 {1} 사이의 값을 입력하세요."),
	max: jQuery.validator.format("{0} 이하로 입력해 주세요."),
	min: jQuery.validator.format("{0} 이상으로 입력해 주세요."),
	alpha: "영문 만 입력 가능합니다.",
	alphanum: "영문 숫자만 입력 가능합니다.",
	alphanumunder: "영문,숫자,_ 만 입력 가능합니다."
});


// 검색시 div object 에 검색조건 표시.
/*
 * param $objStr 	search form onClose 시 받아오는 변수값을 넣어주면 됨.
 * param $viewObj	표시될 object 
 * param $viewObj	row에 표시 될 조건 갯수 
 */
fnGridSearchString = function($objStr,$viewObj,$row){
	
	var objId = $objStr.replace("searchmodfbox","fbox");
	var i = 0;
	var $div = $("<div class=''></div>");
	
	if($viewObj.tabs()){
		$viewObj.tabs("destroy");
	}
	
	$viewObj.empty();
	$viewObj.removeClass();
	$viewObj.addClass('ui-state-default');
	
	$(objId + " table.group td.first").each(function(){
		
		var $span = $("<span class=''></span>");		
		
		var $col 	= $(this).next().children();
		var $oper 	= $(this).next().next().children();
		var $data 	=  $(this).next().next().next().children();

		var $colTxt = $col.children(":selected").text();
		var $operTxt = $oper.children(":selected").text();
		var $dataTxt = $data.val();
		
		var $searchTxt = "";
		
		if(i > 0 && i % $row == 0){
			$div.append("<br />");
		}
		
		if(i > 0 && i % $row != 0 ){
			$searchTxt = " ," +$colTxt+" "+$operTxt+" "+$dataTxt;
		}else{
			$searchTxt = $colTxt+" "+$operTxt+" "+$dataTxt;
		}
		
		
		$span.append($searchTxt);
		$div.append($span);

		i++;
	});
	
	var $ul = $("<ul><li><a href='#"+$viewObj.attr('id')+"'>검색조건</a></li></ul><br/>");
	$viewObj.append($ul);
	
	$viewObj.append($div);
	$viewObj.tabs();
};


/*
마감 상태 확인 후 function 실행
fnCmmnClosCheck(param,마감 확인 후 정상 처리 할 function);

ex)
var param = {};
param.brand_cd 	= f.brand_cd.value;
param.mrhst_cd 	= f.mrhst_cd.value;
param.clos_de	= f.bsn_de.value; 
fnCmmnClosCheck(param,invBtnClickEventAjaxPrev);
*/
fnCmmnClosCheck = function(param,$method){
	fn_loadingView("마감 확인중...");
	var err = false;
	if(!param.clos_de){
		alert("날짜 미선택");
		err = true;
	}else if(param.clos_de == ""){
		alert("날짜 미선택");
		err = true;
	}else if(param.clos_de.length < 7){
		alert("날짜 선택 오류["+param.clos_de+"]");
		err = true;
	}else{
		param.clos_de = param.clos_de.substr(0,7);
	}
	
	if(param.brand_cd == "" ){
		alert("브랜드 미선택");
		err = true;
	}else if(param.mrhst_cd == ""){
		alert("가맹점 미선택");
		err = true;
	}
	
	if(err) {
		fn_unLoading();
		return false;
	}
	$.ajax({
		type:"POST",
		url	:"/closCheck.do",
		data:param,
		dataType: "json",
		async:false,	//비동기 false로 해야지만 다음 수행 할 메소드가 정상 수행됨.
		success:function(data){
			fn_unLoading();
			if(data.status == "SUCCESS"){
				if(data.clos){
					var d = data.clos[0];
					if(!d){
						$method();
						return;
					}
					
					if(!d.clos_status_cd){
						$method();
					}else{
						if(d.clos_status_cd == "1"){
							alert("["+d.clos_de+"]이미 마감되었습니다. 확인 해 주세요!!!");
							return;
						}else{
							$method();
						}
					}
				}
			}else if(data.status == "LOGIN_ERROR"){
				alert("로그인이 안되어있습니다. 확인 해 주세요.");
				top.location.href =  "/";
			}else if(data.status == "ERROR"){
				alert(data.message);
			}
		},
		error:function(msg){
			alert("마감 확인 실패!!");
			fn_unLoading();
			return false;
		}
	});
};

// 공백 제거
fn_strTrim = function(str)
{
    return str.replace(/(^\s*)|(\s*$)/g, "");
};

fn_onlyNumber = function(e){
	
	if( (e.keyCode >= 48 && e.keyCode <= 57) 
	  ||(e.keyCode >= 96 && e.keyCode <= 105)
	  || e.keyCode == 8
	){
		return true;
	}else if(e.keyCode == 9
			//|| e.keyCode == 8
			|| e.keyCode == 46){
		fn_onlyNumberBlur($(this));
		return false;
	}else{
		e.keyCode = 0;
		return false;
	}
};

fn_onlyNumberBlur = function($obj){
	
	if(!$obj) $obj = $(this);
	
	var numValue = $obj.val().replace(/[^0-9]/gi, '');
	$obj.val(numValue);
};

fn_onlyNumberStyle = function(){
	$(this).css("textAlign","right");
};

decimalChk = function(obj){
	var val = obj.value;
	// 숫자, . 허용.. 근데 한글이 입력되는것 같어요..ㄹ
	obj.value = val.replace(/[^0-9|.]/gi, '');
	
	var split = val.split(".");
	if(split.length > 2){
		obj.value = val.substr(0, val.length-1);
	}
	if(split[1] != null){
		if(split[1].length > 1){
			obj.value = val.substr(0, val.length-1);
		}
	}
	// 천단위 콤마찍기
	obj.value = obj.value.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
};
</script>