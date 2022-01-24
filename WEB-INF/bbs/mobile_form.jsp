<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<%
String bbsWriter = (String)request.getAttribute("bbsWriter");
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
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
// 		var page = null;
// 		var bbsId = null;		
// 		var cdate = "";
		
// 		function bbsMenu(bbsId) {
// 			var menuName = "";
// 			switch(bbsId) {
<%-- 				case "bbs00000000000000" : menuName = "<%=msglang.getString("main.notice") /* 공지사항 */ %>"; break; --%>
<%-- 				case "bbs00000000000002" : menuName = "<%=msglang.getString("main.Work.Library") /* 업무자료실 */ %>"; break; --%>
<%-- 				case "bbs00000000000004" : menuName = "<%=msglang.getString("main.Free.Board") /* 자유게시판 */ %>"; break; --%>
<%-- 				case "bbs20110922153448" : menuName = "<%=msglang.getString("main.Family.events.Board") /* 사내경조사 */ %>"; break; --%>
// 				case "bbs20140902094343" : menuName = "갤러리"; break;
// 				default : menuName = decodeURI($.urlParam("bbsNm")) || "";
// 			}
// 			if (menuName == "") menuName = bbsNm || "";
// 			return menuName;
// 		}
		
// 		$.urlParam = function(name){
// 		    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
// 		    return results[1] || 0;
// 		}

		// 영구보존 관련 추가
		$("#page-list").live("pageshow", function(e) {
			$('#never').bind("click tap vclick vmousedown", function() {
				var ischecked = $('#never').is(":checked");
				if (ischecked) {
					// 이전 값 보존 후, 영구설정.
					cdate = $("input[name='bbs.closeDate']").val();
					$("input[name='bbs.closeDate']").val( "2020-12-30" );
					$("input[name='bbs.startDate']").attr("disabled", "true" );
					$("input[name='bbs.closeDate']").attr("disabled", "true" );
				} else {
					// 이전 값 보존.
					$("input[name='bbs.closeDate']").val(cdate);
					$("input[name='bbs.startDate']").attr("disabled", "false");
					$("input[name='bbs.closeDate']").removeAttr("disabled");
				}
			});
		});
		
		function OnClickSend() {
			var form = document.getElementById("bbsWebForm");
			var tempBody = $("#txtContent").html();

			$("input[name='bbs.startDate']").removeAttr("disabled");
			$("input[name='bbs.closeDate']").removeAttr("disabled");
			
			tempBody = tempBody.replace(/\r\n/g, "<br>");
			tempBody = tempBody.replace(/\n/g, "<br>");
			tempBody = tempBody.replace(/\r/g, "<br>");
			$("[name='bbs.content']").val("<html><head></head><body>"+tempBody+"</body></html>");
					
			form.submit();
		}
    </script>
    <!----S: 2021리뉴얼 추가------->
    <link rel="stylesheet" href="/mobile/css/mobile.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_sub_page.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_mail_read.css"/>
    <link rel="stylesheet" href="/mobile/css/mobile_mail_form_s.css"/>
    <script src="/mobile/js/bbs_file_add.js"></script>

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
            <img src="/common/images/icon/logo.png" height="29" border="0" >
        </a>
     </h1>
    <div class="right_menu" >
        <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
     </div>
</div>
	
	<div data-role="content" class="bbs_mobile_form">
	<form:form enctype="multipart/form-data" commandName="bbsWebForm" action="./save.htm">
	<c:if test="${bbsWebForm.search != null }">
		<form:hidden path="search.searchKey" />
		<form:hidden path="search.searchValue" />
		<form:hidden path="search.pageNo" />
		<form:hidden path="search.bbsId" />
		<form:hidden path="search.docId" />
		<form:hidden path="search.useLayerPopup" />
		<form:hidden path="search.useNewWin" />
	</c:if>
	<form:hidden path="bbs.docId" />
	<form:hidden path="bbs.pDocId" />
	<form:hidden path="bbs.tpDocId" />
	
	<div style="display: none;">
		<!-- 게시판분류 -->
		<form:select path="bbs.bbsId">
			<form:options items="${bbsMasters }" itemValue="bbsId" itemLabel="title" />
		</form:select>
		
		<!-- 보존년한 -->
		<form:select path="bbs.preservePeriod.preserveId">
			<form:options items="${preservePeriods }" itemValue="preserveId" itemLabel="title" />
		</form:select>
	</div>
		<div data-role="fieldcontain" class="fieldcontain_bottom">
			<label for="bbs.writerName" class="left_label"><b><fmt:message key="t.writer"/><!-- 게시자 --></b></label>
			<form:input data-mini="true" path="bbs.writerName" value="<%=bbsWriter %>"/>
		</div>
		<div data-role="fieldcontain" class="fieldcontain_bottom">
			<label for="bbs.writerName" class="left_label left_label_02"><b><fmt:message key="t.posting.period"/><!-- 게시기간 --></b></label>
			<fieldset class="ui-grid-b right_box_line">
				<div class="ui-block-a" style="width:49%;"><form:input data-mini="true" path="bbs.openDate" type="date" style="width:100% !important;"/></div>
				<div class="ui-block-b" style="width:2%;"></div>	   
				<div class="ui-block-c" style="width:49%;"><form:input data-mini="true" path="bbs.closeDate" type="date" style="width:100% !important;"/></div>
            </fieldset>
		</div>
        
       
        
        <div data-role="fieldcontain">
        <div class="fileUploadSectionWrapper">
            <label for="filehidden"><b><fmt:message key="t.attached"/></b></label>
            <!-- 첨부파일 -->
            <div class="fileUploadSection file_btn">			
                <div class="fileUpWrapper">				
                    <div id="fileUpBtnWrapper" class="fileUpBtnWrapper" style="position:relative;">				 								
                        <%-- input의 id명 뒤의 숫자를 변경하지 말것(인덱스 번호로 사용됨) --%>				
                        <input id="file" onchange="makeUploadElem(this)" class='file' type="file" name="upFile[]" style="width: 94px;position: absolute;right:0px;top:0px; opacity:0; filter: alpha(opacity=0);cursor: pointer;outline:none;" / >					 				
                        <span class="fileUp">+ 파일추가</span>
                     </div>
                </div>
            </div>		
            <!-- 첨부추가/제거 -->
            <div class="fieldcontain_box">
            <div class="addAttachFileSection">
                <ul class="attachFileList">
                </ul>
            </div>	
            </div>
        </div>

		</div>
        
        
		
		<div data-role="fieldcontain" class="mail_subject">
			<label for="subject" class="left_label ui-input-text"><b><fmt:message key="t.subject"/><!-- 제목 --></b></label>
			<form:input data-mini="true" path="bbs.subject"/>
		</div>
		<div data-role="fieldcontain">
			<div class="mailbody_name"><b><label for="mailbody"><fmt:message key="t.content"/><!-- 본문 --></label></b></div>
			<form:textarea data-mini="true" path="bbs.content" style="display:none;"/>
			<div data-role="content" contenteditable="true" id="txtContent" 
				 class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini" style="margin-bottom:0;"></div>
		</div>
		
        <div class="che_ui_box">
            <ul>
                <li style="font-size: 13px;"><b><fmt:message key="t.option"/><!-- 옵션 --></b></li>
                <li>
				    <input data-mini="true" type="checkbox" name="never" id="never">
			    <label for="never" style="margin:0;"><fmt:message key='t.permanent.post' /><!-- 영구게시 --> </label></li>
            </ul>
        </div>
        
        <div data-role="fieldcontain" class="save_btn_box">
		    <a href="/mobile/index.jsp" data-mini="true" data-role="button" data-icon="check" data-theme="c" data-inline="true" class="btn_save" style="padding: 3% 13% !important;"><fmt:message key="t.cancel"/></a>
            <a onclick="OnClickSend()" href="#" data-mini="true" data-role="button" data-icon="check" data-theme="b" data-inline="true" class="btn_send"><fmt:message key="t.save"/></a>
		 </div>
        
	</form:form>
	</div>
</div>
</body>
</fmt:bundle>
</html>
