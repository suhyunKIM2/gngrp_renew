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
		
	<div data-role="content" style="border-top:9px solid #f5f5f5;margin-top:1%;">   


	<script>
		$('body').delegate('.nav-search', 'pageshow', function( e ) {
			$('.ui-input-text').attr("autofocus", true)
		});	
   </script>

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
        
	</div><!-- /content -->
    <div class="footer_pc_ver ham_pc_footer_div" onClick="location.href='/jpolite/index.jsp'" style="position:fixed;;background:#f5f5f5;width:80%;right:0;bottom:-100%;">
    <a href="/jpolite/index.jsp" style="color:#000;text-decoration: none;"><img src="/common/images/m_icon/13.png"> PC버전으로 보기</a>
</div>
</div><!-- /page -->
</body>
</html>
