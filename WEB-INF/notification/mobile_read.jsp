<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek3.domain.notification.*" %>
<%!
	private String readableFileSize(long size) {
		if (size <= 0) return "0";
		final String[] units = new String[] { "B", "KB", "MB", "GB", "TB" };
		int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
		return new DecimalFormat("#,##0.00").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
	}
%>
<%
	SimpleDateFormat dtformat = new SimpleDateFormat("yyyy-MM-dd HH:mm aa");
	Notes notes = (Notes)request.getAttribute("notes");

	String notiTosValue = "";
	
	String searchKey = request.getParameter("searchKey");
	String searchValue = request.getParameter("searchValue");
	String boxId = request.getParameter("boxId");
	String noteType = request.getParameter("noteType");
	
	if(searchKey == null) searchKey = "";
	if(searchValue == null) searchValue = "";
	if(boxId == null) boxId = "1";
	if(noteType == null) noteType = "0";
	

	Map recipients = notes.getDepartmentRecipients();
	if (recipients != null) {
		Iterator iter = recipients.values().iterator();
		while (iter.hasNext()) {
			Address address = (Address)iter.next();
			if (!notiTosValue.equals("")) notiTosValue += ", ";
			notiTosValue += HtmlEncoder.encode(address.toDisplayString());
		}
	}
	recipients = notes.getPersonRecipients();
	if (recipients != null) {
		Iterator iter = recipients.values().iterator();
		while (iter.hasNext()) {
			UserAddress user = (UserAddress)iter.next();
			if (!notiTosValue.equals("")) notiTosValue += ", ";
			notiTosValue += HtmlEncoder.encode(user.toDisplayString());
		}
	}
	

	String notiAttachValue = "";

	String homePath = "http://" + request.getServerName();
	String baseURL = homePath;
	if (!baseURL.endsWith("/")) {
		baseURL += "/";
	}
	baseURL += "notification/notification_dn_attachment.jsp?fileid=";
	
	if (notes.getNoteAttachs() != null && notes.getNoteAttachs().size() > 0) {
		StringBuffer attachFiles = new StringBuffer();
		Iterator iter = notes.getNoteAttachs().iterator();
		int count = 0;
		while (iter.hasNext()) {
			NoteAttachments attachment = (NoteAttachments)iter.next();
			String fileName = attachment.getFileName();
			if (count != 0) notiAttachValue += "<br>";
			notiAttachValue += "<a href=\""+baseURL+attachment.getId().getServerName()+"\" data-ajax=\"false\" title=\""+fileName+"\">"
					+fileName+"</a> <span>("+readableFileSize(attachment.getFileSize())+")</span>";
			count++;
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Garam Mobile Demo</title>	
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <!----S: 2021리뉴얼 추가------->
    <link rel="stylesheet" href="/mobile/css/mobile.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_sub_page.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_mail_read.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_mail_form_s.css"/>
    <script src="/mobile/js/sw_file_add.js"></script>

    <script>
        $(document).ready(function(){


            $('#burger-check').click(function(){
                $('.menu_bg').show(); 
                $('.sub_ham_page').css('display','block'); 
                $('.sidebar_menu').show().animate({
                    right:0
                });
                $('.ham_pc_footer_div').show().animate({
                    bottom:0,right:0
                });
            });
            $('.close_btn>a').click(function(){
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

    <!----E: 2021리뉴얼 추가-------> 
</head>
<body>

<div data-role="page" id="page-list">
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
	
	<div data-role="content">
        <div class="date_text"><%=dtformat.format(notes.getCreated()) %></div>
		<p style="font-size:18px;"><b><%=notes.getSubject() %></b></p>
		<hr/>
		<p style="font-size:14px;" class="p_line">
			<b><fmt:message key="t.outgoing"/><!-- 발신 --> </b> 
			<span class="span_left"><%=HtmlEncoder.encode(notes.getSender().toDisplayString()) %></span>
			
		</p>
        
        <p style="font-size:14px;" class="p_line">
			<b><fmt:message key="mail.sendto"/><!-- 수신 --></b> 
			<span class="span_left"><%=notiTosValue %></span>
			
		</p>
		
        <p style="font-size:14px;" class="file_box">
			<b><fmt:message key="t.attached"/><!-- 첨부 --></b> 
			<span class="span_left"><%=notiAttachValue %></span>
			
		</p>
	

		<hr/>
        
        <div id="mailBodyValue"><%=notes.getBody() %></div>
        
        <div class="ui-btn-inline" onClick="javascript:location.href='/mobile/notification/list.jsp?boxId=<%=boxId %>&noteType=<%=noteType %>&searchKey=<%=searchKey %>&searchValue=<%=searchValue %>'">
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
.ui-btn-inline{background: #266fb5;color: #fff;width: 116px;text-align: center;margin: 5% auto;display: block;padding:20px 0;cursor: pointer;font-weight: 600;font-size: 13px;}
</style>
</body>
</html>