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
	
		<div data-role="fieldcontain">
			<label for="bbs.writerName"><fmt:message key="t.writer"/><!-- 게시자 --></label>
			<form:input data-mini="true" path="bbs.writerName" value="<%=bbsWriter %>"/>
		</div>
		<div data-role="fieldcontain">
			<label for="bbs.writerName"><fmt:message key="t.posting.period"/><!-- 게시기간 --></label>
			<fieldset class="ui-grid-b">
				<div class="ui-block-a" style="width:49%;"><form:input data-mini="true" path="bbs.openDate" type="date"/></div>
				<div class="ui-block-b" style="width:2%;"></div>	   
				<div class="ui-block-c" style="width:49%;"><form:input data-mini="true" path="bbs.closeDate" type="date"/></div>
			</fieldset>
		</div>
		<div data-role="fieldcontain">
			<fieldset data-role="controlgroup">
			    <legend><fmt:message key="t.posting.period"/><!-- 게시기간 --> <fmt:message key="t.option"/><!-- 옵션 --></legend>
			    <input data-mini="true" type="checkbox" name="never" id="never">
			    <label for="never"><fmt:message key='t.permanent.post' /><!-- 영구게시 --></label>
			</fieldset>
		</div>
		<div data-role="fieldcontain">
			<label for="subject"><fmt:message key="t.subject"/><!-- 제목 --></label>
			<form:input data-mini="true" path="bbs.subject"/>
		</div>
		<div data-role="fieldcontain">
			<label for="mailbody"><fmt:message key="t.content"/><!-- 본문 --></label>
			<form:textarea data-mini="true" path="bbs.content" style="display:none;"/>
			<div data-role="content" contenteditable="true" id="txtContent" 
				 class="ui-input-text ui-body-c ui-corner-all ui-shadow-inset ui-mini"></div>
		</div>
		<div data-role="fieldcontain">
			<label for="filehidden"><fmt:message key="t.attached"/><!-- 첨부 --></label>
			<input data-mini="true" name="filehidden" id="filehidden" style="display: none;">
			<input type="file" name="bbs.mobileFiles[0]" value="" data-mini="true" style="display:block;line-height: 2em;margin:0;padding:0;">
			<input type="file" name="bbs.mobileFiles[1]" value="" data-mini="true" style="display:block;line-height: 2em;margin:0;padding:0;">
			<input type="file" name="bbs.mobileFiles[2]" value="" data-mini="true" style="display:block;line-height: 2em;margin:0;padding:0;">
			<input type="file" name="bbs.mobileFiles[3]" value="" data-mini="true" style="display:block;line-height: 2em;margin:0;padding:0;">
			<input type="file" name="bbs.mobileFiles[4]" value="" data-mini="true" style="display:block;line-height: 2em;margin:0;padding:0;">
		</div>
		<div data-role="fieldcontain">
		    <a onclick="OnClickSend()" href="#" data-mini="true" data-role="button" data-icon="check" data-theme="b" data-inline="true"><fmt:message key="t.save"/></a>
		    <a href="/mobile/index.jsp" data-mini="true" data-role="button" data-icon="check" data-theme="c" data-inline="true"><fmt:message key="t.cancel"/></a>
		</div>
	</form:form>
	</div>
</div>
</body>
</fmt:bundle>
</html>
