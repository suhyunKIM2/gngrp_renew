<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../../error.jsp" %>
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
    	var docid = null;
    	
		$("#page-info").live("pageshow", function(e) {
			docid = $.urlParam("docid");
			loadDataAjax();
		});

		$.urlParam = function(name){
		    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
		    return results[1] || 0;
		}
		
		function loadDataAjax() {
			var url = "/addressbook/user_info_biz_json.htm?docid=" + docid;
			$.get(url, function(string) {
				sessionChk(data);
 				var data = $.parseJSON(string);
 				$('#gubun').text(data.gubun);
 				$('#categoryName').text(data.categoryName);
 				$('#nName').text(data.name);
 				$('#cpName').text(data.companyName);
 				$('#dpName').text(data.dpName);
 				$('#upName').text(data.gradeName);
 				$('#udName').text(data.dutyName);
 				
 				var telLink = "";
 				var mailLink = "";
 				var cellTelLink = "";
 				var homePageLink = "";
 				
 				if (data.telNo != "") telLink = "<a href='tel:"+data.tel+"'>"+data.tel+"</a>";
 				if (data.internetMail != "") mailLink = "<a href='mailto:"+data.email+"'>"+data.email+"</a>";
 				if (data.cellTel != "") cellTelLink = "<a href='tel:"+data.cellTel+"'>"+data.cellTel+"</a>";
 				if (data.homePage != "") homePageLink = "<a href='"+data.homePage+"'>"+data.homePage+"</a>";
 				
 				$('#telNo').html(telLink);
 				$('#internetMail').html(mailLink);
 				$('#faxNo').text(data.fax);
 				$('#cellTel').html(cellTelLink);
 				$('#homepage').html(homePageLink);
 				$('#addr').html(data.address);
                /*S: 2021????????? ??????*/
               if (!$('#udName').text().length) {
                       $(".none_b").css('display', 'none');
                    }
               
               if (!$('#telNo').text().length) {
                       $(".none_b_tel").css('display', 'none');
                    }
             /*E: 2021????????? ??????*/  
			});
		}
		
    </script>
<!----S: 2021????????? ??????------->
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
            function(){ $('.blindcopyto_span').text("?????????"); 
                        $('.blindcopyto_box').css('display','block');
                },

            function(){$('.blindcopyto_span').text("??????????????????"); 
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
<!----E: 2021????????? ??????------->    
<!----S: 2022????????? ??????------->
<link rel="stylesheet" href="/mobile/css/mobile_top.css"/>
<script src="/mobile/js/mobile_top.js"></script>
<!----E: 2022????????? ??????------->
</head>
<body>
<div data-role="page" id="page-info">
	<div class="main_contents_top">
    <div class="menu_bg"></div>
    <div class="sidebar_menu">
         <div class="home_icon_div">
            <ul>
            <li onClick="location.href='/'">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2017.11 1996.25" style="width:15px;height:15px;margin-right:1px;"><defs><style>.cls-1{fill:#fff;}</style></defs><g id="icon_2" data-name="icon2"><g id="icon_2" data-name="icon_2"><path class="cls-1" d="M209.3,912.32V1948.74c0,25.75,14.26,47.51,31.14,47.51h571.9V1363.3h392.44v633h571.89c16.88,0,31.14-21.76,31.14-47.51V912.32L1008.56,352.68Z"/><path class="cls-1" d="M1984.23,666.28h0L1057.63,17.42l-.39-.32A76.54,76.54,0,0,0,1010.72,0l-2.21,0-2,0A76.55,76.55,0,0,0,959.88,17.1l-1.62,1.22-925.37,648a77.28,77.28,0,0,0-19,107.48l51.32,73.31a77,77,0,0,0,100.39,23.36,78.88,78.88,0,0,0,7.1-4.41l835.81-585.24L1844.36,866a79.7,79.7,0,0,0,7.14,4.37,77.06,77.06,0,0,0,100.36-23.32l51.32-73.31A77.26,77.26,0,0,0,1984.23,666.28Z"/></g></g></svg>
            </li>
            <li><div class="close_btn"><a href="#"><img src="/common/images/icon/logout.png" height="25"></a></div></li>
            </ul>
        </div>
         <div class="ham_user_name"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>???</b></div>
         <div class="logout_btn" onClick="location.href='/logout.jsp'">????????????</div>
         <div class="menu_wrap">
             <div data-role="page" class="type-home sub_ham_page" id="page-home" style="position:relative;clear: both;z-index: 1;background: #fff;">
                 <div class="nav_div">
                 <div data-role="content" style="border-top:9px solid #f5f5f5;margin-top:1%;">   
                 <ul  class="ham">
                    <li class="ham_li">
                        <span>????????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mail/mobile_mail_form_s.jsp'">????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=1&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=2&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=3&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=4&unread='">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/notification/list.jsp?boxId=1&noteType=0'">????????????<b class="link_arrow">></b></li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>????????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=240'">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=340'">???????????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=640'">?????????<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=820'">?????????<b class="link_arrow">></b></li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>????????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/addressbook/user.jsp'">
                                ???????????????<b class="link_arrow">></b>
                            </li>
                            <li onClick="location.href='/mobile/addressbook/list.jsp'">
                                ????????? ??????<b class="link_arrow">></b>
                            </li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>?????????<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000004'">
                                ?????????<b class="link_arrow">></b>
                            </li>
                            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000000'">
                                ????????????<b class="link_arrow">></b>
                            </li>
                        </ul>
                    </li>

                    <!--<li data-filtertext="????????????">
                        <a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">????????????</a>
                    </li>
                    <li data-filtertext="<%=msglang.getString("main.E-mail") /* ???????????? */ %> <%=msglang.getString("mail.InBox") /* ??????????????? */ %>">
                        <a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("main.E-mail") /* ??????????????? */ %></a>
                    </li>
                    <li data-filtertext="">
                        <a href="appr/list.jsp?menu=240" data-ajax="false">????????????</a>
                    </li>-->
                </ul>
                </div>
                <div class="footer_pc_ver ham_pc_footer_div" onClick="location.href='/jpolite/index.jsp'" style="position:fixed;;background:#f5f5f5;width:80%;right:0;bottom:-100%;">
                    <img src="/common/images/m_icon/13.png"> PC???????????? ??????
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
            <h4><span id="cpName"></span><span id="dpName"></span></h4>
            <div class="img_info_user"><img src='/common/images/photo_user_default.gif' /></div>
            <div class="info_user_ul_div">
                <ul>
                    <li><span id="nName"></span> <span class="s_font_g">( <span id="upName"></span><b class="none_b">,</b>  <span id="udName"> </span> )</span></li>
                    <li><b class="none_b_tel">???????????? :</b> <span id="telNo"></span></li>
                    <li><span id="internetMail"></span></li>
                    <li><span id="faxNo"></span></li>
                    <li><span id="cellTel"></span></li>
                    <li><span id="homepage"></span></li>
                    <li><span id="addr"></span></li>
                </ul>
            </div>
        
        
        </div>
        
	    <div class="ui-btn-inline" onClick="javascript:location.href='/mobile/addressbook/list.jsp?searchKey=<%=searchKey %>&searchValue=<%=searchValue %>'">
            ??????
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
