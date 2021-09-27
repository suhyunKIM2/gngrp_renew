<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<%
String logoText = " ";
String userDomain = uservariable.userDomain;
boolean isPartnerTemp = loginuser.securityId == 8;
%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><%=logoText %>Mobile</title>
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script src="/common/scripts/mobile_common.js"></script>
    <script type="text/javascript">    	
    	$("#page-home").live("pageshow", function(e) {
			loadCountAjax("240");
			loadCountAjax("340");
			loadCountAjax("640");
			loadCountAjax("820");
			loadMailCountAjax();
			loadMailboxes();
			//loadTeamBbs();
			loadCategoryBbs();
		});

    	function loadMailCountAjax() {
			var url = '/mail/WidgetCount.jsp';
			$.get(url, function(data) {
				sessionChk(data);
				var records = eval(data) || 0;
				$(".mailcount").html(records);
			});
    	}
    	
		function loadCountAjax(menu) {
			var url = "";
			switch(menu) {
				case "130" : case "340" : case "530" : case "540" :
					url = "/approval/finlist_json.htm"; break;
				case "240" : 
					url = "/approval/inglist_json.htm"; break;
				case "620" : case "630" : case "640" :
					url = "/approval/receivelist_json.htm"; break;
				case "810" : case "820" :
					url = "/approval/circulationlist_json.htm"; break;
			}
			url +="?menu=" + menu + "&pageNo=0";
			$.get(url, function(data) {
				sessionChk(data);
				var data = eval(data) || { records: 0 };
				var records = data.records;
				$("#count" + menu).html(records);
			});
		}

		var dataMailboxes = null;
    	function loadMailboxes() {
			var url = '/mail/data/mailboxes_json.jsp';
			$.get(url, function(data) {
				sessionChk(data);
				dataMailboxes = data || [];
				showMailboxes(dataMailboxes);
			}, 'json');
    	}
    	
    	function showMailboxes(boxes) {
			var option = $(document.createElement('option')).val("").text("<%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %>");
			var select1 = $('#select-native-1'); select1.empty().append(option.clone());
			var select2 = $('#select-native-2'); select2.empty().append(option.clone());
			for(var i = 0, len = boxes.length; i < len; i++) {
				var box = boxes[i];
				var select = (box["type"] == "1")? select1: select2;
				select.append(option.clone().val(box["id"]).text(box["name"]));
			}
			select1.selectmenu('refresh');
			select2.selectmenu('refresh');
			if (select1.find("option").length > 1) $('#mailboxes1').show(); else $('#mailboxes1').hide();
			if (select2.find("option").length > 1) $('#mailboxes1').show(); else $('#mailboxes2').hide();
    	}
    	
    	function linkMailboxes(sel) {
    		var selected = $(sel).find("option:selected");
    		var boxid = selected.val();
    		var boxnm = encodeURI(selected.text(), "UTF-8");
    		if (boxid == "") return;
    		location.href = "./mail/list.jsp?box=" + boxid + "&boxnm=" + boxnm;
    	}
    	
    	var teamBbs = null;
    	function loadTeamBbs() {
    		var url = '/bbs/team_bbs_json.htm';
			$.get(url, function(data) {
				sessionChk(data);
				teamBbs = data || [];
				showTeamBbs(teamBbs);
			}, 'json');
    	}
    	
    	function showTeamBbs(lists) {
			var option = $(document.createElement('option')).val("").text("<%=msglang.getString("t.select.board") /* 게시판 선택 */ %>");
			var select3 = $('#select-native-3'); select3.empty().append(option.clone());
			for(var i = 0, len = lists.length; i < len; i++) {
				var bbs = lists[i];
				select3.append(option.clone().val(bbs["id"]).text(bbs["name"]));
			}
			select3.selectmenu('refresh');
			if (select3.find("option").length > 1) $('#teamBbs').show(); else $('#teamBbs').hide();
    	}
    	
    	function linkTeamBbs(sel) {
    		var selected = $(sel).find("option:selected");
    		var bbsid = selected.val();
    		var bbsnm = encodeURI(selected.text(), "UTF-8");
    		if (bbsid == "") return;
    		location.href = "./bbs/list.jsp?bbsId=" + bbsid + "&bbsNm=" + bbsnm;
    	}
    	
    	function loadCategoryBbs() {
    		var url = '/bbs/topcode_list_json.htm';
			$.get(url, function(data) {
				sessionChk(data);
				categorys = data.rows || [];
				for(var i = 0, iSize = categorys.length; i < iSize; i++) {
					var category = categorys[i];
					loadBbs(category.id, category.cell[0]);
				}
				
			}, 'json');
    	}
    	
    	function loadBbs(categoryCode, categoryName) {
    		var bbs = $("#bbs");
    		if ($("#bbs"+categoryCode).length == 0) {
	    		var li = '<li id="bbs'+categoryCode+'" data-role="list-divider" role="heading" class="ui-li ui-li-divider ui-bar-a">'+categoryName+'</li>';
	    		bbs.append(li);
	
	    		var url = '/bbs/category_bbs_json.htm?categoryCode=' + categoryCode;
				$.get(url, function(data) {
					sessionChk(data);
					categoryBbs = data || [];
					if (categoryBbs.length == 0) $('#bbs'+categoryCode).hide(); else $('#bbs'+categoryCode).show();
					showBbs(categoryCode, categoryBbs);
				}, 'json');
    		}
    	}

    	function showBbs(categoryCode, lists) {
			var category = $('#bbs'+categoryCode);
			for(var i = lists.length - 1; i >= 0; i--) {
				var bbs = lists[i];
				var bbsid = bbs["id"];
				var bbsnm = encodeURI(bbs["name"], "UTF-8");
				category.after('<li><a href="/mobile/bbs/list.jsp?bbsId='+bbsid+'&bbsNm='+bbsnm+'" data-ajax="false">'+bbs["name"]+'</a>');
			}
			$('#bbs').listview('refresh');
    	}
    </script>
    <style>
    body{width:100%;background: #fff !important;    padding: 0 !important;margin: 0;}
    body.ui-mobile-viewport{background:#fff;}
    .main_contents_top{width:93%;margin:auto;height:auto;overflow:hidden;}
    .left_logo{width:50%;float:left;margin: 0.5em 0;}
    .right_menu{width:50%;float:right;height:37px;line-height: 37px;margin:1em 0;text-align: right;color: #266fb5;font-weight: 600;}
    .main_contents{background:#f7f7f7;width:92%;padding:5% 4%;height:calc(100vh-80px);}
    /*햄버거메뉴*/
    .nav-search .ui-content{display:none;}
    .menu {
          position: absolute;
          top: 0;
          right: 0;
          height: 100%;
          max-width: 0;
          transition: 0.5s ease;
          z-index: 1;
          background: rgba(0,0,0,0.7);
        }
        .burger-icon {
          cursor: pointer;
          display: inline-block;
          position: absolute;
          z-index: 2;
          padding: 8px 0;
          top: 25px;
          right:0;
          user-select: none;
          width: 104px;
          margin: 0;
        }

        .burger-icon .burger-sticks {
          background: #266fb5;
          display: block;
          height: 2px;
          position: relative;
          transition: background .2s ease-out;
          width: 18px;
        }

        .burger-icon .burger-sticks:before,
        .burger-icon .burger-sticks:after {
          background: #266fb5;
          content: '';
          display: block;
          height: 100%;
          position: absolute;
          transition: all .2s ease-out;
          width: 100%;
        }

        .burger-icon .burger-sticks:before {
          top: 5px;
        }

        .burger-icon .burger-sticks:after {
          top: -5px;
        }

        .burger-check {
          display: none;
        }

        /*.burger-check:checked .menu {
          max-width: 100%;
          width: 100%;
        }
        .burger-check:checked~.menu .nav_box_div{background:#fff;width:80%;height:100vh;position:absolute;right:0;}
        .burger-check:checked~.menu .nav-search .ui-content{display:block !important;}
        .burger-check:checked~.burger-icon .burger-sticks {
          background: transparent;
        }

        .burger-check:checked~.burger-icon .burger-sticks:before {
          transform: rotate(-45deg);
        }

        .burger-check:checked~.burger-icon .burger-sticks:after {
          transform: rotate(45deg);
        }

        .burger-check:checked~.burger-icon:not(.steps) .burger-sticks:before,
        .burger-check:checked~.burger-icon:not(.steps) .burger-sticks:after {
          top: -20px;
          right: -73px;
          background: #333;
        }*/
        .user_icon_img{height:25px;vertical-align: middle;margin-right: 5px;}
        .main_contents .user_name{font-size:15px;}
        .main_contents .user_name b{vertical-align: middle;}
        .btn_nav_main{text-align: center;position: relative;margin-top: 15px;}
        .btn_nav_main ul li{width:31%;background:#fff;height:84px;border-bottom:0;text-align: center;vertical-align: bottom;padding-top:12px;line-height: 75px;}
        .btn_nav_main ul li:nth-child(1),.btn_nav_main ul li:nth-child(4){float:left;}
        .btn_nav_main ul li:nth-child(2),.btn_nav_main ul li:nth-child(5){margin:auto;}
        .btn_nav_main ul li:nth-child(3),.btn_nav_main ul li:nth-child(6){position:absolute;right:0;}
        .btn_nav_main ul li:nth-child(3){top:0;}
        .btn_nav_main ul li:nth-child(6){top:107px;}
        .btn_nav_main ul li:nth-child(4),.btn_nav_main ul li:nth-child(5),.btn_nav_main ul li:nth-child(6){margin-top:13px;}
        .btn_nav_main ul li .nav_btn_div{position:relative;line-height: normal;top:-25px;}
        .btn_nav_main ul li b{position:absolute;width:100%;top: 0;left:0;}
        .btn_nav_main ul li a{color:#333;font-size:13px;}
        .count_box_relative{position:relative;top:-12px;}
        .count{position:absolute;right:0;top:0;background:#d00303;padding:4px 8px;min-width:16px;color:#fff;line-height: 20px;font-family: sans-serif;text-shadow: none;}
        .speech-bubble {
            position: relative;
            background: #d00303;
            border-radius: .4em;
        }

        .speech-bubble:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            width: 0;
            height: 0;
            border: 12px solid transparent;
            border-top-color: #d00303;
            border-bottom: 0;
            border-left: 0;
            margin-left: -10px;
            margin-bottom: -12px;
        }
        .btn_nav_main ul li img{height: 33%;image-rendering: -webkit-optimize-contrast;image-rendering:-moz-auto;image-rendering:-o-auto;image-rendering:auto;}
        .quick_menu ul{width:90%;padding:6% 5%;background:#fff;}
        .quick_menu h4{color: #266fb5;margin-bottom: 10px;}
        .quick_menu ul li{position:relative;font-size: 14px;padding:1em 0;cursor: pointer;height: auto;overflow: hidden;cursor: pointer;}
        .quick_menu ul li img{height: 20px;image-rendering: -webkit-optimize-contrast;image-rendering:-moz-auto;image-rendering:-o-auto;image-rendering:auto;margin-right: 4px;    vertical-align: middle;}
        .quick_menu ul li:nth-child(1){    padding-bottom: 0.8em;}
        .quick_menu ul li:nth-child(2) img{height:14px;}
        .ui-icon, .ui-icon-searchfield:after{background: rgb(38 111 181);}
        .ui-icon{position: absolute;right: 0; background: #266fb5 url(/common/jquery/mobile/1.2.0/images/icons-36-white.png) !important;background-position: -108px 50%!important;background-size: 776px 18px!important;}
        .quick_menu ul li .ui-li-count{    background: #8b8b8b;
    padding: 5px 6px;
    border-radius: 7px;
    position: absolute;
    right: 23px;
    top: 11px;
    color: #ffffff;
    font-weight: 500;
    border: 1px solid #bebebe;
    text-shadow: none;font-size:12px;}
    .footer_pc_ver{cursor:pointer;width:100%;text-align: center;height:80px;line-height: 80px;font-weight: 600;font-size: 13px;}
    .footer_pc_ver img{height: 30%;image-rendering: -webkit-optimize-contrast;image-rendering:-moz-auto;image-rendering:-o-auto;image-rendering:auto;vertical-align: middle;}
    
    .menu_bg{
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.7);
        position: absolute;
        top:0;
        display: none;
        z-index: 9;
        right: 0;
    }
    .sidebar_menu{
 display: none;
        width: 80%;
        height: 100%;
        background: #fff;
        position: absolute;
        top:0;
        right: -50%;
        z-index: 9;
    }
    .close_btn{
        margin:10px;
        text-align: right;
    }
    .close_btn > a{
        display: block;
        width: 100%;
        height: 100%;
        text-decoration: none;
        color:#000;
        font-weight: 600;
    }
    .close_btn > a > img{vertical-align: middle;}
    .menu_wrap{
        list-style: none;
        position:relative;
        width:100%;
        height:100vh;
        overflow: hidden;
    }
    .menu_wrap .nav_div{position:absolute;width:100%;left:0;top:-59px;}
select,input,button,a,label { -webkit-tap-highlight-color:transparent;}
.ham_user_name{float:left;margin: 10px;}
.logout_btn{float:right;background:#266fb5;color:#fff;font-weight: 600;padding:1% 5%;font-size:13px;margin: 10px;}
.ui-listview-filter{background:#fff !important;}
.ui-shadow-inset{background:#fff !important;}
    </style>
<script>
    $(document).ready(function(){
 
        $('#burger-check').on('click', function(){
            $('.menu_bg').show(); 
            $('.sidebar_menu').show().animate({
                right:0
            });  
        });
        $('.close_btn>a').on('click', function(){
            $('.menu_bg').hide(); 
            $('.sidebar_menu').animate({
                right: '-' + 50 + '%'
                       },function(){
$('.sidebar_menu').hide(); 
}); 
        });
 
    });
</script>

</head>
<body>
<div class="main_contents_box" style="position:absolute;width:100%;z-index: 9;background: #fff;">
<div class="main_contents_top">
<div class="menu_bg"></div>
<div class="sidebar_menu">
     <div class="close_btn"><a href="#">       
         <!--<img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBkPSJNMjMuOTU0IDIxLjAzbC05LjE4NC05LjA5NSA5LjA5Mi05LjE3NC0yLjgzMi0yLjgwNy05LjA5IDkuMTc5LTkuMTc2LTkuMDg4LTIuODEgMi44MSA5LjE4NiA5LjEwNS05LjA5NSA5LjE4NCAyLjgxIDIuODEgOS4xMTItOS4xOTIgOS4xOCA5LjF6Ii8+PC9zdmc+">-->닫기 <img src="/common/images/m_icon/15.png">
         </a>
     </div>
     <div class="ham_user_name"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b></div>
     <div class="logout_btn">로그아웃</div>
     <div class="menu_wrap">
         <div data-role="page" class="type-home" id="page-home" style="position:absolute;clear: both;z-index: 1;background: #fff;"><jsp:include page="/mobile/top.jsp"></jsp:include></div>
     </div>
</div>

 <h1 class="left_logo">
     <a href="">
        <img src="/common/images/icon/logo.png" height="29" border="0" >
    </a>
 </h1>
<div class="right_menu" >
    <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
 </div>
</div>

<div class="main_contents">
    <div class="user_name">
        <img src="/common/images/icon/img_01.png" border="0" class="user_icon_img"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b>
    </div>
    <div class="btn_nav_main">
        <ul>
            <li>
                <a href="">
                    <div class="count_box_relative">
                        <div class="count"><div class="speech-bubble"><span class="ui-li-count mailcount">0</span></div></div>
                    </div>
                    <img src="/common/images/m_icon/01.png"  border="0" ><div class="nav_btn_div"><b>메일</b></div>
                 </a>
            </li>
            <li>
                <a href="">
                    <img src="/common/images/m_icon/02.png"  border="0" ><div class="nav_btn_div"><b>전자결재</b></div>
                </a>
            </li>
            <li>
                <a href="">
                    <img src="/common/images/m_icon/03.png"  border="0" ><div class="nav_btn_div"><b>쪽지</b></div>
                 </a>
            </li>
            <li>
                <a href="">
                    <img src="/common/images/m_icon/04.png"  border="0" ><div class="nav_btn_div"><b>업무지원</b></div>
                </a>
            </li>
            <li>
                <a href="">
                    <img src="/common/images/m_icon/05.png"  border="0" ><div class="nav_btn_div"><b>게시판</b></div>
               </a>
            </li>
            <li>
                <a href="">
                    <img src="/common/images/m_icon/06.png"  border="0" ><div class="nav_btn_div"><b>임직원 정보</b></div>
                </a>
            </li>
        </ul>
    </div>
    <div class="quick_menu">
        <h4>Quick Menu</h4>
        <ul>
            <li onClick=""><img src="/common/images/m_icon/07.png"> <b>편지쓰기</b> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick=""><img src="/common/images/m_icon/08.png"> <b>읽지않은 메일</b> <span class="ui-li-count mailcount">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick=""><img src="/common/images/m_icon/09.png"> <b>결재할 문서</b> <span class="ui-li-count" id="count240">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick=""><img src="/common/images/m_icon/10.png"> <b>진행중 문서</b> <span class="ui-li-count" id="count340">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick=""><img src="/common/images/m_icon/11.png"> <b>배포 받은 문서</b> <span class="ui-li-count" id="count640">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick=""><img src="/common/images/m_icon/12.png"> <b>회람 할 문서</b> <span class="ui-li-count" id="count820">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
        </ul>
    </div>
</div>
<div class="footer_pc_ver" onClick="">
    <img src="/common/images/m_icon/13.png"> PC버전으로 보기
</div>
</div>

</body>
</html>
