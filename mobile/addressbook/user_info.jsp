<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<%
String searchKey = request.getParameter("searchKey");
String searchValue = request.getParameter("searchValue");
if(searchKey == null) searchKey = "";
if(searchValue == null) searchValue = "";
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Mobile Groupware</title>	
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
	<style type="text/css">
		table { width:100%; }
		table caption { text-align:left;  }
		table thead th { text-align:left; border-bottom-width:1px; border-top-width:1px; }
		table th, td { font-size: 75%; text-align:left; padding:6px;} 
	</style>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script src="/common/scripts/mobile_common.js"></script>
    <script type="text/javascript">
    	var uid = null;
    	
		$("#page-info").live("pageshow", function(e) {
			uid = $.urlParam("userid");
			loadDataAjax();
		});

		$.urlParam = function(name){
		    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
		    return results[1] || 0;
		}
		
		function loadDataAjax() {
			var url = "/mobile/addressbook/user_info_json.jsp?uid=" + uid;
			$.get(url, function(string) {
				sessionChk(data);
 				var data = $.parseJSON(string);
 				$('#nName').text(data.nName);
 				$('#dpName').text(data.dpName);
 				$('#upName').text(data.upName);
 				$('#udName').text(data.udName);
				$("#userphoto").attr("src", "/userdata/photos/"+data.uid).error(function() {
					$("#userphoto").attr("src", "/common/images/photo_user_default.gif")
                
             /*S: 2021리뉴얼 추가*/
               if (!$('#udName').text().length) {
                       $(".none_b").css('display', 'none');
                    }
               
               if (!$('#telNo').text().length) {
                       $(".none_b_tel").css('display', 'none');
                    }
             /*E: 2021리뉴얼 추가*/        
				
                });
 				
 				var telLink = "";
 				var mailLink = "";
 				var cellTelLink = "";
 				
 				if (data.telNo != "") telLink = "<a href='tel:"+data.telNo+"'>"+data.telNo+"</a>";
 				if (data.internetMail != "") mailLink = "<a href='mailto:"+data.internetMail+"'>"+data.internetMail+"</a>";
 				if (data.cellTel != "") cellTelLink = "<a href='tel:"+data.cellTel+"'>"+data.cellTel+"</a>";
                
 				$('#telNo').html(telLink);
 				$('#internetMail').html(mailLink);
 				$('#faxNo').text(data.faxNo);
 				$('#cellTel').html(cellTelLink);
			});
		}
    </script>
<!----S: 2021리뉴얼 추가------->
<link rel="stylesheet" href="/mobile/css/mobile.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_sub_page.css"/>
<link rel="stylesheet" href="/mobile/css/mobile_mail_read.css"/>

<script>
    $(document).ready(function(){
 
        $('#burger-check').on('click', function(){
            $('.menu_bg').show(); 
            $('.sub_ham_page').css('display','block'); 
            $('.sidebar_menu').show().animate({
                right:0
            });
            $('.ham_pc_footer_div').show().animate({
                bottom:0,right:0
            });
        });
        $('.close_btn>a').on('click', function(){
            $('.menu_bg').hide(); 
            $('.sidebar_menu').animate({
                right: '-' + 100 + '%'
                       },function(){
            $('.sidebar_menu').hide(); 
            }); 
            $('.ham_pc_footer_div').animate({
                right: '-' + 100 + '%',
                bottom:'-' + 100 + '%'
                       },function(){
            $('.ham_pc_footer_div').hide(); 
            }); 
        });
         
        $('.blindcopyto_span').toggle(
            function(){ $('.blindcopyto_span').text("닫기▲"); 
                        $('.blindcopyto_box').css('display','block');
                },

            function(){$('.blindcopyto_span').text("비밀참조인▼"); 
                       $('.blindcopyto_box').css('display','none');
        
               });

        
});
</script>

<script>
    $('body').delegate('.nav-search', 'pageshow', function( e ) {
        $('.ui-input-text').attr("autofocus", true)
    });			
</script>
<style>
        .ui-mobile .ui-page-active{background:#fff;}
        .info_div_box{height:auto;overflow:hidden;margin:14% 0;text-align: center;}
        .s_font_g{font-size:11px;color:#999;font-weight: 600;vertical-align: text-top;}
        .img_info_user{width:auto;}
        .info_user_ul_div ul li{font-size:13px;font-weight: 600;border-bottom:0;padding: 0;color: #7c7c7c;    margin: 0.5em 0;}
        .info_user_ul_div ul li:nth-child(1){font-size:15px;color: #000;}
        .info_user_ul_div ul li:nth-child(2){display: block;}
        .info_user_ul_div ul li span a{color:#266fb5;}
    </style>
<!----E: 2021리뉴얼 추가------->    
</head>
<body>
<div data-role="page" id="page-info">
	<div class="main_contents_top">
    <div class="menu_bg"></div>
    <div class="sidebar_menu">
         <div class="close_btn">
            <a href="#">닫기 <img src="/common/images/m_icon/15.png"></a>
         </div>
         <div class="ham_user_name"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b></div>
         <div class="logout_btn" onClick="location.href='/logout.jsp'">로그아웃</div>
         <div class="menu_wrap">
             <div data-role="page" class="type-home sub_ham_page" id="page-home" style="position:relative;clear: both;z-index: 1;background: #fff;">
                 <div class="nav_div">
                 <div data-role="content">   
                 <ul data-role="listview" data-theme="a" data-divider-theme="a" data-filter="true" data-filter-theme="a" data-filter-placeholder="Search menu...">
                     <li data-filtertext="편지작성">
                        <a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">편지작성</a>
                    </li>
			        <li data-filtertext="<%=msglang.getString("main.E-mail") /* 전자메일 */ %> <%=msglang.getString("mail.InBox") /* 받은편지함 */ %>">
                        <a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("main.E-mail") /* 받은편지함 */ %></a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/appr/list.jsp?menu=240" data-ajax="false">전자결재</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/notification/list.jsp?boxId=1&noteType=0" data-ajax="false">사내쪽지</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000004" data-ajax="false">게시판</a>
                    </li>
                    <!--<li data-filtertext="">
                        <a href="" data-ajax="false">업무지원</a>
                    </li>-->
                    <li data-filtertext="">
                        <a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false">공지사항</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/addressbook/user.jsp" data-ajax="false">임직원정보</a>
                    </li>
                    <li data-filtertext="">
                        <a href="/mobile/addressbook/list.jsp" data-ajax="false">주소록관리</a>
                    </li>
                </ul>
                </div>
                <div class="footer_pc_ver ham_pc_footer_div" onClick="location.href='/jpolite/index.jsp'" style="position:fixed;;background:#f5f5f5;width:80%;right:0;bottom:-100%;">
                    <img src="/common/images/m_icon/13.png"> PC버전으로 보기
                </div>
                </div>
             </div>
         </div>
    </div>

     <h1 class="left_logo">
         <a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">
            <img src="/common/images/icon/logo.png" height="29" border="0" >
        </a>
     </h1>
    <div class="right_menu" >
        <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
     </div>
</div>
	
	<div data-role="content" class="ui-content">
	    <div class="info_div_box">
            <h4><span id="dpName"></span></h4>
            <div class="img_info_user"><img id="userphoto"  border="0" width="100" height="120" ></div>
            <div class="info_user_ul_div">
                <ul>
                    <li><span id="nName"></span> <span class="s_font_g">( <span id="upName"></span><b class="none_b">,</b>  <span id="udName"> </span> )</span></li>
                    <li><b class="none_b_tel">내선번호 :</b> <span id="telNo"></span></li>
                    <li><span id="internetMail"></span></li>
                    <li><span id="faxNo"></span></li>
                    <li><span id="cellTel"></span></li>
                </ul>
            </div>
        
        
        </div>
        
	    <div class="ui-btn-inline" onClick="javascript:location.href='/mobile/addressbook/user.jsp?searchKey=<%=searchKey %>&searchValue=<%=searchValue %>'">
            확인
        </div>
    </div>
    
    
</div>
<style>
dt {padding:0px; margin:0px;}
.ui-btn-left, .ui-btn-right, .ui-input-clear, .ui-btn-inline, .ui-grid-a .ui-btn, .ui-grid-b .ui-btn, .ui-grid-c .ui-btn, .ui-grid-d .ui-btn, .ui-grid-e .ui-btn, .ui-grid-solo .ui-btn {
margin-right: 2px;
margin-left: 2px;
}
.ui-navbar li .ui-btn {text-align:left;}
.ui-btn-inline{clear: both; background: #266fb5;color: #fff;width: 116px;text-align: center;margin: 5% auto;display: block;padding:15px 0;cursor: pointer;font-weight: 600;font-size: 13px;}
</style>
</body>
</html>
