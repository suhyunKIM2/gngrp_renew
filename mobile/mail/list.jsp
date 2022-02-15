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
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script src="/common/scripts/mobile_common.js"></script>
    <script type="text/javascript">
    var searchK = "<%=searchKey%>"; 
	var searchV = "<%=searchValue%>";
	var page = "";
	var box = "";
	var unread = "";

	function boxMenu(bbsId) {
		var menuName = "";
		switch(bbsId) {
			case "1" : 
				if (unread == "") menuName = "<%=msglang.getString("mail.InBox") /* 받은편지함 */ %>";
				else menuName = "<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>"; 
			break;
			case "2" : menuName = "<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %>"; break;
			case "3" : menuName = "<%=msglang.getString("mail.TempBox") /* 임시보관함 */ %>"; break;
			case "4" : menuName = "<%=msglang.getString("mail.DeletedBox") /* 지운편지함 */ %>"; break;
			case "6" : menuName = "<%=msglang.getString("mail.ReservationBox") /* 예약편지함 */ %>"; break;
			case "7" : menuName = "<%=msglang.getString("mail.spamBox") /* 스팸편지함 */ %>"; break;
			default : menuName = decodeURI($.urlParam("boxnm")) || "";
		}
		return menuName;
	}

	$("#page-list").live("pageshow", function(e) {
		page = 1;
		box = $.urlParam("box");
		unread = $.urlParam("unread") || "";
		loadDataAjax();
	});

	function loadDataAjax(cmd) {
		//메일 상세보기에서 back 했을때 검색목록이 아닌 전체목록이 나타나는 오류수정
		if(cmd != "search" && $('#searchtext').val() == "" && searchV != ""){
			$("#searchtype").val(searchK);
			$("#searchtext").val(searchV);
		}
		if (cmd == 'search') page = 1;			
		var url = "/mail/data/mail_list_json2.jsp?rowsNum=30&box=" + box + "&unread=" + unread + "&codekey="
				+ "&pageNo=" + page + "&rowsNum=30&sortColumn=created&sortType=desc"
				+ "&searchtype=" + $('#searchtype').val() + "&searchtext=" + encodeURI($('#searchtext').val(), "UTF-8");
		$.get(url, function(data) {
			sessionChk(data);
			if (page == 1) $("#list").html("");
			showData(data || { total: 0, page: 1, records: 0, rows: [] });
			page++;
		}, 'json');
	}
	
	$.urlParam = function(name){
	    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
	    if (!results) return "";
	    return decodeURI(results[1]) || 0;
	}

	function showData(data) {
		var pageTotal = data.total;
		var pageNo = data.page;
		var records = data.records;
		
		var html = (pageNo == 1)? "<li data-role='list-divider'>"+boxMenu(box)+" <span class='ui-li-count'><font style='color:#000'>안읽은메일 :</font> "+records+"개</span></li>": "";

		for (var i=0; i<data.rows.length; i++) {
			var item = data.rows[i];
			var id = item.mailid;
			var subj = item.cell[4];
			var created = item.cell[5];
			var author = item.cell[0];
			var attach = item.cell[2];
			var importance = item.cell[1];
			var read = item.cell[3];
			if ( box == '3' ) {
				var url = "/mail/mobile_mail_form_s.jsp?box=" + box + "&importance=" + importance + "&message_name=";
			} else {
				var url = "/mail/mobile_mail_read.jsp?box=" + box + "&importance=" + importance + "&boxnm=" + ($.urlParam("boxnm") || "") + "&unread=" + unread + "&message_name=";	
			}
			
			var pmt = "&searchtype=" + $('#searchtype').val() + "&searchtext=" + encodeURI($('#searchtext').val(), "UTF-8");
			var read_y = '<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("t.okread") /* 읽음 */ %>" src="/common/images/icon-mail-open.png" style="margin-right:3px;position:relative;top:0px;left:0px;">';
			var read_n = '<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("t.noread") /* 읽지않음 */ %>" src="/common/images/icon-mail.png" style="margin-right:3px;position:relative;top:0px;left:0px;">';
			var atta_f = '<img alt="<%=msglang.getString("t.attached") /* 첨부 */ %>" src="/common/images/icons/icon_disket.png" style="top:1px;position:relative;">';
			var color = (importance == "1")? " style='color:#d13e3e;'": "";
			
			html += "<li data-icon='false'><a href='" + url + id + pmt + "' data-ajax='false' style='padding: .2em 6px;'>" 
			 	 + "<h2" + color + ">" + ((read == '1')? read_y: read_n) + subj + "</h2>"
				 +  "<p>" + created + " - " + author + "</p>";
			if (attach != "") 
				html += "<span class='ui-li-count'>" + atta_f + "</span>";
				
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
                 <div data-role="content"  style="border-top:9px solid #f5f5f5;margin-top:1%;">
                 
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
				<select name="searchtype" id="searchtype">
					<%-- <option value='all_rec'><fmt:message key="mail.search.entire"/>전체검색</option> --%>
					<option value="subject"><%=msglang.getString("mail.subject") /* 제목 */ %></option>
					<option value="from"><%=msglang.getString("mail.sender") /* 발신인 */ %></option>
					<option value="recieve"><%=msglang.getString("mail.recipient") /* 수신인 */ %></option>
					<option value="ref"><%=msglang.getString("mail.TO") /* 수신 */ %>+<%=msglang.getString("mail.CC") /* 참조 */ %></option>
					<option value="body"><%=msglang.getString("t.content") /* 본문 */ %></option>
				</select>
			</div>
			
		</fieldset>
     
        <div class="ui-grid-solo">
			<input type="search" name="searchtext" id="searchtext" value="" placeholder="<%=msglang.getString("t.searchValue") /* 검색어 */ %> " />
		</div>
		<div class="ui-block-b button_color">
				<button onclick="loadDataAjax('search')" data-theme="b">검색</button>
			</div>
		 
		<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b" id="list"></ul>
		<div class="ui-grid-solo ui-btn">
			<button onclick="loadDataAjax()" data-inline="true" data-mini="true" class="pagerBtn ui-btn-hidden">
				30 <%=msglang.getString("t.more") /* 더보기 */ %> 
				<span class="pager"></span>
			</button>
		</div>
       </div>
    </div>
	
<div data-role="page" class="type-home" id="page-home" style="position: relative;clear:both;">
	<div data-role="content">
		<div class="content-secondary">
			<div id="jqm-homeheader">
				<h1 id="jqm-logo"><%=logoText %></h1>
<!-- 				<p>GroupWare System</p> -->
			</div>
			<p class="intro"><strong>Welcome.</strong> <%=logoText %>Mobile Groupware</p>

			<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="f">
				<li data-role="list-divider">Quick Menu</li>
				<li><a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">
					<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.title") /* 메일작성 */ %>" src="/common/images/icon-mail-pencil.png">
					<%=msglang.getString("mail.title") /* 메일작성 */ %></a>
				<li><a href="/mobile/mail/list.jsp?box=1&unread=1" data-ajax="false">
					<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>" src="/common/images/icons/email_icon_1.jpg">
					<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %></a>
					<span class="ui-li-count mailcount">0</span>
				 
				<li><a href="appr/list.jsp?menu=240" data-ajax="false">결재할 문서</a><span class="ui-li-count" id="count240">0</span>
				<li><a href="appr/list.jsp?menu=340" data-ajax="false">진행중 문서</a><span class="ui-li-count" id="count340">0</span>
				<li><a href="appr/list.jsp?menu=640" data-ajax="false">배포받은 문서</a><span class="ui-li-count" id="count640">0</span>
				<li><a href="appr/list.jsp?menu=820" data-ajax="false">회람할 문서</a><span class="ui-li-count" id="count820">0</span>
				
			</ul>
		</div>

		<div class="content-primary">
			<nav>
				<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b">
				<li data-role="list-divider">Menu</li>
				<!-- 2016.07.29 협력사인 경우 전자결재,전자메일, pc버전보기전환 메뉴만 보이게 셋팅 -->
				<% if (isPartnerTemp) {%>
					<li>전자결재
						<ul data-role="listview">
							<li data-role="list-divider">기안함
							<li><a href="appr/list.jsp?menu=130" data-ajax="false">기안목록</a>
							<li data-role="list-divider">결재함
							<li><a href="appr/list.jsp?menu=240" data-ajax="false">결재할문서</a>
							<li><a href="appr/list.jsp?menu=340" data-ajax="false">결재한문서</a>
							<li><a href="appr/list.jsp?menu=530" data-ajax="false">반려된문서</a>
							<li data-role="list-divider">완료함
							<li><a href="appr/list.jsp?menu=540" data-ajax="false">전체보기</a>
							<li data-role="list-divider">수신함
							<li><a href="appr/list.jsp?menu=620" data-ajax="false">개인수신</a>
							<li><a href="appr/list.jsp?menu=630" data-ajax="false">부서수신</a>
							<li data-role="list-divider">회람함
							<li><a href="appr/list.jsp?menu=810" data-ajax="false">보낸회람</a>
							<li><a href="appr/list.jsp?menu=820" data-ajax="false">받은회람</a>
						</ul>
						
					<li><%=msglang.getString("mail.email") /* 전자메일 */ %>
						<ul data-role="listview">
							<li><a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.title") /* 편지쓰기 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.title") /* 편지쓰기 */ %></a>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=1" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %></a><span class="ui-li-count mailcount">0</span>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.InBox") /* 받은편지함 */ %>" src="/common/images/icon-mail-receive.png">
								<%=msglang.getString("mail.InBox") /* 받은편지함 */ %></a>
							<li id="mailboxes1">
							    <label for="select-native-1" style="font-weight: bold;"><%=msglang.getString("mail.InBox.personal") /* 받은편지함(개인용) */ %></label>
							    <select name="select-native-1" id="select-native-1" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<li><a href="/mobile/mail/list.jsp?box=2" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %>" src="/common/images/icon-mail-send.png">
								<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %></a>
							<li id="mailboxes2">
							    <label for="select-native-2" style="font-weight: bold;"><%=msglang.getString("mail.OutBox.personal") /* 보낸편지함(개인용) */ %></label>
							    <select name="select-native-2" id="select-native-2" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<!-- <li><a href="/mobile/mail/list.jsp?box=7" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="스팸편지함" src="/common/images/icon-mail-sign.png">스팸편지함</a> -->
							<li><a href="/mobile/mail/list.jsp?box=3" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %>" src="/common/images/icon-mail-temp.png"><%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %></a>
							<!-- <li><a href="/mobile/mail/list.jsp?box=6" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="예약편지함" src="/common/images/icon-clock-arrow.png">예약편지함</a> -->
							<!-- <li><a href="/mobile/mail/list.jsp?box=4" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="지운편지함" src="/common/images/icon-mail-minus.png">지운편지함</a> -->
						</ul>
						<li><a href="/jpolite/index.jsp" data-ajax="false"><%=msglang.getString("t.switch.pc.version") /* PC 버전 보기 전환 */ %></a>
				<% }else {%>
					<li>전자결재
						<ul data-role="listview">
							<li data-role="list-divider">기안함
							<li><a href="appr/list.jsp?menu=130" data-ajax="false">기안목록</a>
							<li data-role="list-divider">결재함
							<li><a href="appr/list.jsp?menu=240" data-ajax="false">결재할문서</a>
							<li><a href="appr/list.jsp?menu=340" data-ajax="false">결재한문서</a>
							<li><a href="appr/list.jsp?menu=530" data-ajax="false">반려된문서</a>
							<li data-role="list-divider">완료함
							<li><a href="appr/list.jsp?menu=540" data-ajax="false">전체보기</a>
							<li data-role="list-divider">수신함
							<li><a href="appr/list.jsp?menu=620" data-ajax="false">개인수신</a>
							<li><a href="appr/list.jsp?menu=630" data-ajax="false">부서수신</a>
							<li data-role="list-divider">회람함
							<li><a href="appr/list.jsp?menu=810" data-ajax="false">보낸회람</a>
							<li><a href="appr/list.jsp?menu=820" data-ajax="false">받은회람</a>
						</ul>
						
					<li><%=msglang.getString("mail.email") /* 전자메일 */ %>
						<ul data-role="listview">
							<li><a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.title") /* 편지쓰기 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.title") /* 편지쓰기 */ %></a>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=1" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %></a><span class="ui-li-count mailcount">0</span>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.InBox") /* 받은편지함 */ %>" src="/common/images/icon-mail-receive.png">
								<%=msglang.getString("mail.InBox") /* 받은편지함 */ %></a>
							<li id="mailboxes1">
							    <label for="select-native-1" style="font-weight: bold;"><%=msglang.getString("mail.InBox.personal") /* 받은편지함(개인용) */ %></label>
							    <select name="select-native-1" id="select-native-1" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<li><a href="/mobile/mail/list.jsp?box=2" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %>" src="/common/images/icon-mail-send.png">
								<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %></a>
							<li id="mailboxes2">
							    <label for="select-native-2" style="font-weight: bold;"><%=msglang.getString("mail.OutBox.personal") /* 보낸편지함(개인용) */ %></label>
							    <select name="select-native-2" id="select-native-2" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<!-- <li><a href="/mobile/mail/list.jsp?box=7" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="스팸편지함" src="/common/images/icon-mail-sign.png">스팸편지함</a> -->
							<li><a href="/mobile/mail/list.jsp?box=3" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %>" src="/common/images/icon-mail-temp.png"><%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %></a>
							<!-- <li><a href="/mobile/mail/list.jsp?box=6" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="예약편지함" src="/common/images/icon-clock-arrow.png">예약편지함</a> -->
							<!-- <li><a href="/mobile/mail/list.jsp?box=4" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="지운편지함" src="/common/images/icon-mail-minus.png">지운편지함</a> -->
						</ul>		
					<li>사내쪽지
						<ul data-role="listview">
							<li><a href="/mobile/notification/list.jsp?boxId=1&noteType=0" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="받은쪽지함" src="/common/images/icons/approual_icon_4.jpg">받은쪽지함</a>
							<li><a href="/mobile/notification/list.jsp?boxId=1&noteType=1" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="읽지않은쪽지" src="/common/images/icons/notification_icon_1.jpg">읽지않은 쪽지</a>
							<!-- <li><a href="/mobile/notification/list.jsp?boxId=1&noteType=2" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="전자결재알림" src="/common/images/icons/approual_icon_10.jpg">전자결재 알림</a> -->
							<li><a href="/mobile/notification/list.jsp?boxId=2&noteType=0" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="보낸쪽지함" src="/common/images/icons/approual_icon_2.jpg">보낸쪽지함</a>
							<!-- <li><a href="/mobile/notification/list.jsp?boxId=2&noteType=-1" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="수신확인" src="/common/images/icons/admin_icon_9.jpg">수신확인</a> -->
						</ul>
					<li><%=msglang.getString("main.Board") /* 게시판 */ %>
						<ul data-role="listview" id="bbs">
<%-- 							<li><a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false"><%=msglang.getString("main.notice") /* 공지사항 */ %></a> --%>
							<li><a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false"><%=msglang.getString("main.notice") /* 공지사항 */ %></a>
							<li><a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000004" data-ajax="false">자유게시판</a>
							<!-- <li><a href="/mobile/bbs/list.jsp?bbsId=bbs20140902094343" data-ajax="false">갤러리</a> -->
							<!-- <li><a href="/mobile/bbs/list.jsp?bbsId=bbs20110922153448" data-ajax="false">사내경조사</a> -->
							<%-- 
							<li id="teamBbs">
							    <label for="select-native-3" style="font-weight: bold;"><%=msglang.getString("main.board.team") /* 팀게시판 */ %></label>
							    <select name="select-native-3" id="select-native-3" onchange="linkTeamBbs(this)">
							    	<option value=""><%=msglang.getString("t.select.board") /* 게시판 선택 */ %></option>
							    </select>
							--%>
						</ul>
					<li><%=msglang.getString("t.worksupport") /* 업무지원 */ %>
						<ul data-role="listview">
							<li><a href="/mobile/addressbook/user.jsp" data-ajax="false"><%=msglang.getString("main.Employee.Info") /* 임직원정보 */ %></a>
							<li><a href="/mobile/addressbook/list.jsp" data-ajax="false"><%=msglang.getString("main.Business.Card") /* 주소록관리 */ %></a>
						</ul>
					
					<!-- <img class="ui-li-icon ui-corner-none" alt="PC 전환" src="/common/images/icons/email_icon_10.jpg"> -->
					<li><a href="/jpolite/index.jsp" data-ajax="false"><%=msglang.getString("t.switch.pc.version") /* PC 버전 보기 전환 */ %></a>
				<%} %>
				</ul>
			</nav>
		</div>
	</div>

<!-- 	<div data-role="footer" class="footer-docs" data-theme="c"> -->
<!-- 		<p>Mobile Groupware</p> -->
<!-- 	</div> -->
</div>
</body>
</html>