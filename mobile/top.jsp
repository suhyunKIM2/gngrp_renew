<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Mobile Groupware</title>
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jqm-docs.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
</head> 
<body> 
	<div class="nav_div">
    <!--<div data-role="page" data-theme="a" class="nav-search">-->
		
	<div data-role="content">   

	<style>

		.nav-search .ui-content {
			margin-top:16px;
		}
		.nav-search .ui-corner-top {
			-moz-border-radius: 0;
			-webkit-border-radius: 0;
			border-radius: 0;
		}
		.nav-search .ui-bar-a {
			background-image:none;
			background-color:#555;
		}
		.nav-search .ui-btn-up-a {
			background-image:none;
			background-color:#333333;
		}
		.nav-search .ui-btn-inner {
			border-top: 1px solid #888;
			border-color: rgba(255, 255, 255, .1);
		}
        .nav-search .ui-content{display: block;}
	</style>
	
	<script>
		$('body').delegate('.nav-search', 'pageshow', function( e ) {
			$('.ui-input-text').attr("autofocus", true)
		});			
	</script>
	
	<ul data-role="listview" data-theme="a" data-divider-theme="a" data-filter="true" data-filter-theme="a" data-filter-placeholder="Search menu...">
			
			<li data-filtertext="<%=msglang.getString("main.E-mail") /* 전자메일 */ %> <%=msglang.getString("mail.InBox") /* 받은편지함 */ %>">
				<a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("main.E-mail") /* 받은편지함 */ %></a>
			</li>
            <li data-filtertext="">
				<a href="appr/list.jsp?menu=240" data-ajax="false">전자결재</a>
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
	</div><!-- /content -->
    <div class="footer_pc_ver ham_pc_footer_div" onClick="location.href='/jpolite/index.jsp'" style="position:fixed;;background:#f5f5f5;width:80%;right:0;bottom:-100%;">
    <img src="/common/images/m_icon/13.png"> PC버전으로 보기
</div>
</div><!-- /page -->
</body>
</html>
