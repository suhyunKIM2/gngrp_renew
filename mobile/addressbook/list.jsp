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
			//주소록 상세보기에서 back 했을때 검색목록이 아닌 전체목록이 나타나는 오류수정
    		if(cmd != "search" && $('#searchValue').val() == "" && searchV != ""){
    			$("#searchKey").val(searchK);
    			$("#searchValue").val(searchV);
    		}
			if (cmd == 'search') page = 1;
			var url = "/addressbook/list_json.htm?pageNo=" + page
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
			var url = "/mobile/addressbook/user_info_biz.jsp?docid=";
			var pmt = "&searchKey=" + $('#searchKey').val() + "&searchValue=" + encodeURI($('#searchValue').val(), "UTF-8");
			var pageTotal = data.total;
			var pageNo = data.page;
			var records = data.records;
			var rowcnt = data.rowcnt;
			var html = (pageNo == 1)? "<li data-role='list-divider'><%=msglang.getString("t.worksupport") /* 업무지원 */ %> &gt; <%=msglang.getString("main.Business.Card") /* 주소록관리 */ %> <span class='ui-li-count'><font style='color:#000'>TOTAL :</font> "+records+"명</span></li>": "";

			$('#rowCnt').html(rowcnt);
			
			for (var i=0; i<data.rows.length; i++) {
				var item = data.rows[i];
				var id = item.id;
				var subj = item.cell[2].split(">")[4].split("<")[0] + " " + item.cell[4];
				var companyName = item.cell[3];
				if (companyName != "") subj += " - " + companyName;
				
				var tel = item.cell[5];
				var cellTel = item.cell[6];
				if (cellTel != "") tel += (tel == "")? cellTel: ", " + cellTel;
				
				//console.log(item.cell[7]);
				
				var mail = "";
				if (item.cell[7].indexOf(">") > -1) {
					mail = item.cell[7].split(">")[1].split("<")[0];
				}
				
				var remark = item.cell[10];
				
				html += "<li><a href='" + url + id + pmt +"' data-ajax='false'>" 
					 +  "<h2>" + subj + "</h2>"
					 +  "<p>" + tel + "</p>"
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
.ui-li-desc, .ui-li-heading{width:85%;}

</style>
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
	
	<div data-role="content" class="content_div">
	
		<fieldset class="ui-grid-a">
			<div class="ui-block-a">
				<select name="searchKey" id="searchKey">
					<option value="name"><%=msglang.getString("t.name") /* 이름 */ %></option> 
					<option value="companyname"><%=msglang.getString("t.company") /* 회사 */ %></option>
					<option value="email"><%=msglang.getString("addr.email") /* 이메일 */ %></option>
					<option value="writer_.nName"><%=msglang.getString("t.writer") /* 작성자 */ %></option>
				</select>
			</div>
		</fieldset>
        
        <div class="ui-grid-solo">
			<input type="search" name="searchValue" id="searchValue" value="" placeholder="<%=msglang.getString("t.searchValue") /* 검색어 */ %>" />
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
