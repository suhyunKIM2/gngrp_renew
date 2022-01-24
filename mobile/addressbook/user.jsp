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
		.ui-li .ui-btn-inner a.ui-link-inherit, .ui-li-static.ui-li {
		    padding-top: 0.25em;
		    padding-bottom: 0.25em;
	    }
	</style>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script src="/common/scripts/mobile_common.js"></script>
    <script type="text/javascript">
	    var searchK = "<%=searchKey%>"; 
		var searchV = "<%=searchValue%>";
		var page = null;
		
		$("#page-list").live("pageshow", function(e) {
			page = 1;
			loadDataAjax();
		});
		
		function loadDataAjax(cmd) {
	    	
			//임직원정보 상세보기에서 back 했을때 검색목록이 아닌 전체목록이 나타나는 오류수정
    		if(cmd != "search" && $('#searchValue').val() == "" && searchV != ""){
    			$("#searchKey").val(searchK);
    			$("#searchValue").val(searchV);
    		}
			
			if (cmd == 'search') page = 1;
			var url = "/common/user_list_data.htm?pageNo=" + page + "&sortColumn=nName"
					+ "&searchKey=" + $('#searchKey').val() + "&searchValue=" + encodeURI($('#searchValue').val(), "UTF-8");
			$.get(url, function(data) {
				sessionChk(data);
				if (page == 1) $("#list").html("");
				showData(data);
				page++;
			});
		}

		function showData(string) {
			var data = eval(string) || { total: 0, page: 1, records: 0, rows: [] };
			var url = "user_info.jsp?userid=";
			var pmt = "&searchKey=" + $('#searchKey').val() + "&searchValue=" + encodeURI($('#searchValue').val(), "UTF-8");
			var pageTotal = data.total;
			var pageNo = data.page;
			var records = data.records;
			var rowcnt = data.rowcnt;
			var html = (pageNo == 1)? "<li data-role='list-divider'><%=msglang.getString("t.worksupport") /* 업무지원 */ %> &gt; <%=msglang.getString("t.employees") /* 임직원 */ %> <span class='ui-li-count'><font style='color:#000'>TOTAL :</font> "+records+"명</span></li>": "";
			
			$('#rowCnt').html(rowcnt);
			
			for (var i=0; i<data.rows.length; i++) {
				var item = data.rows[i];
				var id = item.id;
				var sabun = item.cell[3];
				var subj = item.cell[0].split(">")[2].split("<")[0].replace("[]","");
				var subj2 = item.cell[2];
				var companyName = item.cell[1];
				if (companyName != "") subj2 += " - " + companyName;
				
				var tel = item.cell[5];
				var cellTel = item.cell[6];
				if (cellTel != "") tel += (tel == "")? cellTel: ", " + cellTel;
				
				var mail = item.cell[7];
				
				html += "<li><a href='" + url + id + pmt + "' data-ajax='false'>" 
					 +  "<img src='/common/images/photo_user_default.gif' height='80' width='80' />"
					 +  "<h2>" + subj + "</h2>"
					 +  "<p>" + subj2 + "</p>"
					 +  "<p>" + mail + "</p>";
				html += "</a></li>";
			}
			
			if (data.rows.length == 0) {
				html += "<li><h2><%=msglang.getString("i.noData") /* 데이터가 없습니다. */ %></h2><p>&nbsp;</p></li>";
			}
			
			$("#list").append(html);
			$("#list").listview('refresh');
			
			if (pageTotal == pageNo || pageTotal < pageNo) {
				$(".pagerBtn").closest('.ui-btn').hide();
				$(".pager").html("");
			}
			else {
				$(".pagerBtn").closest('.ui-btn').show();
				$(".pager").html("(" + pageNo + "/" + pageTotal + ")");
			}
		}
    </script>
     <!----S: 2021리뉴얼 추가------->
    <link rel="stylesheet" href="/mobile/css/mobile.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_sub_page.css"/>
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
    });
    </script>

    <script>
        $('body').delegate('.nav-search', 'pageshow', function( e ) {
            $('.ui-input-text').attr("autofocus", true)
        });			
    </script>
    <style>
 .content_div .ui-icon.ui-icon-arrow-r.ui-icon-shadow{background-color: #266fb5 !important; background-position: -884px 50% !important;} 
 .ui-li-has-arrow.ui-li-has-count .ui-li-count {
    right: 33px;
    top: 33%;
    text-shadow: none;
    font-size: 0;
    padding: 0.6% 1% 1.3%;
}
.ui-li-desc, .ui-li-heading{width:68%;float:left;margin: 0.2em 0 0.2em 90px;}
.ui-li-thumb{top:7px;}
.ui-li-desc{height:16px;}
@media screen and (max-width:320px){
.ui-li-desc, .ui-li-heading{width:61%;}
}
@media screen and (max-width: 280px){
.ui-li-desc, .ui-li-heading {
    width: 55%;
    font-size:12px;
}
}
</style>
    <!----E: 2021리뉴얼 추가------->
    <!----S: 2022리뉴얼 추가------->
    <link rel="stylesheet" href="/mobile/css/mobile_top.css"/>
    <script src="/mobile/js/mobile_top.js"></script>
    <!----E: 2022리뉴얼 추가------->
</head>
<body>
<div data-role="page" id="page-list">
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
         <div class="ham_user_name"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b></div>
         <div class="logout_btn" onClick="location.href='/logout.jsp'">로그아웃</div>
         <div class="menu_wrap">
             <div data-role="page" class="type-home sub_ham_page" id="page-home" style="position:relative;clear: both;z-index: 1;background: #fff;">
                 <div class="nav_div">
                 <div data-role="content" style="border-top:9px solid #f5f5f5;margin-top:1%;">   
                 <ul  class="ham">
                    <li class="ham_li">
                        <span>전자메일<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mail/mobile_mail_form_s.jsp'">편지작성<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=1&unread='">받은편지함<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=2&unread='">보낸편지함<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=3&unread='">임시보관함<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/mail/list.jsp?box=4&unread='">지운편지함<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/notification/list.jsp?boxId=1&noteType=0'">사내쪽지<b class="link_arrow">></b></li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>전자결재<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=240'">결재할문서<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=340'">결재한문서<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=640'">수신함<b class="link_arrow">></b></li>
                            <li onClick="location.href='/mobile/appr/list.jsp?menu=820'">회람함<b class="link_arrow">></b></li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>업무지원<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/addressbook/user.jsp'">
                                임직원정보<b class="link_arrow">></b>
                            </li>
                            <li onClick="location.href='/mobile/addressbook/list.jsp'">
                                주소록 관리<b class="link_arrow">></b>
                            </li>
                        </ul>
                    </li>
                    <li class="ham_li">
                        <span>게시판<i></i></span>
                        <ul  class="hidden_ul">
                            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000004'">
                                게시판<b class="link_arrow">></b>
                            </li>
                            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000000'">
                                공지사항<b class="link_arrow">></b>
                            </li>
                        </ul>
                    </li>

                    <!--<li data-filtertext="편지작성">
                        <a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">편지작성</a>
                    </li>
                    <li data-filtertext="<%=msglang.getString("main.E-mail") /* 전자메일 */ %> <%=msglang.getString("mail.InBox") /* 받은편지함 */ %>">
                        <a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("main.E-mail") /* 받은편지함 */ %></a>
                    </li>
                    <li data-filtertext="">
                        <a href="appr/list.jsp?menu=240" data-ajax="false">전자결재</a>
                    </li>-->
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
            <img src="/common/images/icon/2_logo.png" height="29" border="0" >
        </a>
     </h1>
    <div class="right_menu" >
        <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
     </div>
</div>
	
	<div data-role="content" class="content_div">
	    <fieldset class="ui-grid-a">
			<div class="ui-block-a">
				<select name="searchKey" id="searchKey">
					<option value="nName"><%=msglang.getString("addr.name") /* 이름 */ %></option> 
					<option value="department_.dpName"><%=msglang.getString("t.dpName") /* 부서 */ %></option>
					<option value="userPosition_.upName"><%=msglang.getString("addr.positon") /* 직급 */ %></option>
				</select>
			</div>
		</fieldset>
		<div class="ui-grid-solo">
			<input type="search" name="searchValue" id="searchValue" value="" placeholder="검색어" />
		</div>
			
        <div class="ui-block-b button_color">
            <button onclick="loadDataAjax('search')" data-theme="b">검색</button>
        </div>
		
		<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b" id="list"></ul>
		<div class="ui-grid-solo ui-btn">
			<button onclick="loadDataAjax()" data-inline="true" data-mini="true" class="pagerBtn ui-btn-hidden">
				<span id="rowCnt">0</span><%=msglang.getString("main.ea") /* 건 */ %> <%=msglang.getString("t.more") /* 더보기 */ %>
				<span class="pager"></span>
			</button>
		</div>
	</div>
</div>
</body>
</html>
