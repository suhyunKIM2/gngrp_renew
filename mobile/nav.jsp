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
	<div data-role="page" data-theme="a" class="nav-search">
		
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
	</style>
	
	<script>
		$('body').delegate('.nav-search', 'pageshow', function( e ) {
			$('.ui-input-text').attr("autofocus", true)
		});			
	</script>
	
	<ul data-role="listview" data-theme="a" data-divider-theme="a" data-filter="true" data-filter-theme="a" data-filter-placeholder="Search menu...">
			<!-- 	
			<li data-filtertext="전자결재 기안목록">
				<a href="appr/list.html?menu=130" data-ajax="false">기안목록</a>
			</li>
			<li data-filtertext="전자결재 결재할문서">
				<a href="appr/list.html?menu=240" data-ajax="false">결재할문서</a>
			</li>
			<li data-filtertext="전자결재 결재한문서">
				<a href="appr/list.html?menu=340" data-ajax="false">결재한문서</a>
			</li>
			<li data-filtertext="전자결재 반려된문서">
				<a href="appr/list.html?menu=530" data-ajax="false">반려된문서</a>
			</li>
			<li data-filtertext="전자결재 전체보기">
				<a href="appr/list.html?menu=540" data-ajax="false">전체보기</a>
			</li>
			<li data-filtertext="전자결재 부서수신">
				<a href="appr/list.html?menu=620" data-ajax="false">부서수신</a>
			</li>
			<li data-filtertext="전자결재 개인수신">
				<a href="appr/list.html?menu=630" data-ajax="false">개인수신</a>
			</li>
			<li data-filtertext="전자결재 보낸회람">
				<a href="appr/list.html?menu=810" data-ajax="false">보낸회람</a>
			</li>
			<li data-filtertext="전자결재 받은회람">
				<a href="appr/list.html?menu=820" data-ajax="false">받은회람</a>
			</li>
			 -->
			<li data-filtertext="<%=msglang.getString("main.E-mail") /* 전자메일 */ %> <%=msglang.getString("mail.InBox") /* 받은편지함 */ %>">
				<a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false"><%=msglang.getString("mail.InBox") /* 받은편지함 */ %></a>
			</li>
			<%--
			<li data-filtertext="<%=msglang.getString("main.E-mail") /* 전자메일 */ %> <%=msglang.getString("c.logout") /* 쪽지함 */ %>">
				<a href="/mobile/notification/list.html?boxId=1&noteType=0" data-ajax="false"><%=msglang.getString("c.logout") /* 쪽지함 */ %></a>
			</li>
			--%>
			<li data-filtertext="<%=msglang.getString("main.Board") /* 게시판 */ %> <%=msglang.getString("main.notice") /* 공지사항 */ %>">
				<a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false"><%=msglang.getString("main.notice") /* 공지사항 */ %></a>
			</li>
			<li data-filtertext="<%=msglang.getString("main.Board") /* 게시판 */ %> <%=msglang.getString("main.Work.Board") /* 업무게시판 */ %>">
				<a href="/mobile/bbs/list_work.jsp" data-ajax="false"><%=msglang.getString("main.Work.Board") /* 업무게시판 */ %></a>
			</li>
<!-- 			<li data-filtertext="게시판 자유게시판"> -->
<!-- 				<a href="bbs/list.html?bbsId=bbs00000000000004" data-ajax="false">자유게시판</a> -->
<!-- 			</li> -->
<!-- 			<li data-filtertext="게시판 사내경조사"> -->
<!-- 				<a href="bbs/list.html?bbsId=bbs20110922153448" data-ajax="false">사내경조사</a> -->
<!-- 			</li> -->
			<li data-filtertext="<%=msglang.getString("t.worksupport") /* 업무지원 */ %> <%=msglang.getString("main.Employee.Info") /* 임직원정보 */ %>">
				<a href="/mobile/addressbook/user.jsp" data-ajax="false"><%=msglang.getString("main.Employee.Info") /* 임직원정보 */ %></a>
			</li>
			<li data-filtertext="<%=msglang.getString("t.worksupport") /* 업무지원 */ %> <%=msglang.getString("main.Business.Card") /* 주소록 */ %>">
				<a href="/mobile/addressbook/list.jsp" data-ajax="false"><%=msglang.getString("main.Business.Card") /* 주소록관리 */ %></a>
			</li>
		</ul>
	</div><!-- /content -->

</div><!-- /page -->
</body>
</html>
