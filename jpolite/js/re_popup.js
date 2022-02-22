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