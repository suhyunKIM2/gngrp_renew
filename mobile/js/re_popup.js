//<![CDATA[
    function wrapWindowByMask(){
 
        //화면의 높이와 너비를 구한다.
        var maskHeight = $(document).height();  
        var maskWidth = $(window).width();  
 
        //마스크의 높이와 너비를 화면 것으로 만들어 전체 화면을 채운다.
        $("#popup_work_check").css({"width":maskWidth,"height":maskHeight});  
 
        //애니메이션 효과 - 일단 0초동안 까맣게 됐다가 60% 불투명도로 간다.
 
        $("#popup_work_check").fadeIn(0);      
        $("#popup_work_check").fadeTo("slow",0.6);    
 
 
    }
 
    $(document).ready(function(){
       
        //닫기 버튼을 눌렀을 때
        $(".popup_work_check_close_btn").click(function (e) {  
            //링크 기본동작은 작동하지 않도록 한다.
            e.preventDefault();  
            $("#popup_work_check").hide();  
        });       
 
          
 
    });
 
//]]>

$( document ).ready(function() {
	cookiedata = document.cookie; 

	/*if ( cookiedata.indexOf("ncookie=done") < 0 ){ 
		document.getElementById('window').style.display = "block";    
        document.getElementById('mask_popup').style.display = "block";
	} else {
		document.getElementById('window').style.display = "none";    
        document.getElementById('mask_popup').style.display = "none";
	}*/
    if ( cookiedata.indexOf("ncookie=done") < 0 ){ 
		document.getElementById('popup_work_check').className += 'fadeIn';   
        document.getElementById('popup_work_check').style.display = "block";   
	} else {
		document.getElementById('popup_work_check').className = 'fadeOut';    
        document.getElementById('popup_work_check').style.display = "none";    
	}
});

function setCookie( name, value, expiredays ) { 
	/*var todayDate = new Date(); 
	todayDate.setDate( todayDate.getDate() + expiredays );
	document.cookie = name + "=" + escape( value ) + "; path=/; expires=" + todayDate.toGMTString() + ";"
}
*/
var todayDate = new Date();   
    todayDate = new Date(parseInt(todayDate.getTime() / 86400000) * 86400000 + 54000000);  
    if ( todayDate > new Date() )  
    {  
    expiredays = expiredays - 1;  
    }  
    todayDate.setDate( todayDate.getDate() + expiredays );   
     document.cookie = name + "=" + escape( value ) + "; path=/; expires=" + todayDate.toGMTString() + ";"   
  }  

function closeWin() { 
	document.getElementById('popup_work_check').className = 'fadeOut';   
    document.getElementById('popup_work_check').style.display = "none";
}

function todaycloseWin() { 
	setCookie( "ncookie", "done" , 1 );     // 저장될 쿠키명 , 쿠키 value값 , 기간( ex. 1은 하루, 7은 일주일)
	/*document.getElementById('window').style.display = "none";    
    document.getElementById('mask_popup').style.display = "none"; */
    document.getElementById('popup_work_check').className = 'fadeOut';   
    document.getElementById('popup_work_check').style.display = "none";    
}


// JavaScript Document
$(function () {
  // 레이어 display none 상태
  $(".layer_bg, .layer_wrap").hide();
  //레이어팝업 위치 지정 function 만들기
  function layer_position(){
    var win_W = $(window).width();
    var win_H = $(window).height();
    $(".layer_wrap").css({'left':(win_W-500)/2, 'top':(win_H-500)/2});
  };
  //레이어팝업 open 상태 function 만들기
  function layer_open(no){
    $(".layer_wrap[layer="+no+"]").fadeIn();
    $(".layer_bg").fadeIn();
    layer_position();
    //레이어 영역 외 바탕화면 클릭시 화면 닫기
    $(".layer_bg").click(function (e) {
      if(!$(".layer_wrap").has(e.target).length){
        layer_close();
      };
    });
  };
  //레이어팝업 close 상태 function 만들기
  function layer_close(){
    $(".layer_wrap, .layer_bg").fadeOut();
  };
  //링크 클릭시 해당 레이어팝업 호출
  $(".btn_layer").click(function () {
    var no = $(this).attr("layer");
    layer_open(no);
  });
  //닫기 버튼 클릭시 레이어 닫기
  $(".btn_close").click(function () {
    layer_close();
  });
  //반응형 대응 - 레이어 위치 잡기
  $(window).resize(function () {
    layer_position();
  });
})
