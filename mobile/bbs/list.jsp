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
		var page = null;
		var bbsId = null;		
		var menuName = "";		
		
		function bbsMenu(bbsId) {
			switch(bbsId) {
				case "bbs00000000000000" : $("#newDoc").hide(); menuName = "<%=msglang.getString("main.notice") /* 공지사항 */ %>"; break;
				case "bbs00000000000002" : $("#newDoc").hide(); menuName = "<%=msglang.getString("main.Work.Library") /* 업무자료실 */ %>"; break;
				case "bbs00000000000004" : $("#newDoc").show(); menuName = "<%=msglang.getString("main.Free.Board") /* 자유게시판 */ %>"; break;
				case "bbs20110922153448" : $("#newDoc").show(); menuName = "<%=msglang.getString("main.Family.events.Board") /* 사내경조사 */ %>"; break;
				case "bbs20140902094343" : $("#newDoc").show(); menuName = "갤러리"; break;
				default : $("#newDoc").show(); try { menuName = decodeURI($.urlParam("bbsNm")) || "" } catch(e) {};
			}
			if (menuName == "") menuName = "&nbsp;";
			return menuName;
		}
		
		$("#page-list").live("pageshow", function(e) {
			page = 1;
			bbsId = $.urlParam("bbsId");
			loadDataAjax();
		});
		
		$.urlParam = function(name){
		    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
		    return results[1] || 0;
		}
		
		function loadDataAjax(cmd) {
			//게시판 상세보기에서 back 했을때 검색목록이 아닌 전체목록이 나타나는 오류수정
    		if(cmd != "search" && $('#searchValue').val() == "" && searchV != ""){
    			$("#searchKey").val(searchK);
    			$("#searchValue").val(searchV);
    		}
			if (cmd == 'search') page = 1;			
			var url = "/bbs/list_data.htm?bbsId=" + bbsId + "&pageNo=" + page + "&searchRange=0&menuName="+menuName
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
			var url = "/bbs/mobile_read.htm?bbsId=" + bbsId + "&docId=";
			var pmt = "&searchKey=" + $('#searchKey').val() + "&searchValue=" + encodeURI($('#searchValue').val(), "UTF-8");
			var pageTotal = data.total;
			var pageNo = data.page;
			var records = data.records;
			var rowcnt = data.rowcnt;
			var html = (pageNo == 1)? "<li data-role='list-divider'>"+bbsMenu(bbsId)+" <span class='ui-li-count'>"+records+"</span></li>": "";

			$('#rowCnt').html(rowcnt);
			
			for (var i=0; i<data.rows.length; i++) {
				var item = data.rows[i];
				var id = item.id;
				var subj = item.subj;
				var created = item.cell[3];
				var author = item.cell[4].split("absmiddle'>")[1].split("<")[0];
				var attach = item.cell[5];
				
				html += "<li><a href='" + url + id + pmt + "' data-ajax='false'>" 
					 +  "<h2>" + subj + "</h2>"
					 +  "<p>" + created + " - " + author + "</p>";
				if (attach != "") 
					html += '<span class="ui-li-count"><%=msglang.getString("t.attached") /* 첨부 */ %></span>';
				html += "</a></li>";
			}
			
			if (data.rows.length == 0) {
				html += '<li><h2><%=msglang.getString("i.noData") /* 데이타가 없습니다. */ %></h2><p>&nbsp;</p></li>';
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
		
		function newDoc() {
    		location.href = '/bbs/mobile_form.htm?bbsId='+bbsId;
		}
    </script>
</head>
<body>
<div data-role="page" id="page-list">
	<div data-role="header" data-position="fixed" data-theme="b">
		<h2>Mobile Groupware</h2>
		<a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">Home</a>
		<a href="/mobile/nav.jsp" data-icon="search" data-rel="dialog" data-transition="fade" data-iconpos="right">Menu</a>
	</div>
	
	<div data-role="content">
	
		<div class="ui-grid-solo">
			<input type="search" name="searchValue" id="searchValue" value="" placeholder='<%=msglang.getString("t.searchValue") /*  검색어 */ %>' />
		</div>
		<fieldset class="ui-grid-a">
			<div class="ui-block-a">
				<select name="searchKey" id="searchKey">
					<option value="subject"><%=msglang.getString("t.subject") /*  제목 */ %></option> 
					<option value="writer_.nName"><%=msglang.getString("t.writer") /* 작성자 */ %></option>
					<option value="content"><%=msglang.getString("t.content") /* 본문 */ %></option>
				</select>
			</div>
			<div class="ui-block-b">
				<button onclick="loadDataAjax('search')" data-theme="b">Search</button>
			</div>
		</fieldset>
		
		<a id="newDoc" href="javascript:newDoc();" data-role="button" data-ajax='false' data-mini="true" data-inline="true" data-theme="b" data-icon="plus">새문서</a>
		
		<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b" id="list" style="margin-top: 3px;"></ul>
		<div class="ui-grid-solo ui-btn">
			<button onclick="loadDataAjax()" data-inline="true" data-mini="true" class="pagerBtn ui-btn-hidden">
				<span id="rowCnt">0</span> <%=msglang.getString("main.ea") /* 건 */ %> <%=msglang.getString("t.more") /* 건 더보기 */ %> 
				<span class="pager"></span>
			</button>
		</div>
	</div>

	<div data-role="footer" data-position="fixed" class="footer-docs ui-bar" data-theme="b">
		<a href="javascript:history.back()" data-ajax='false' data-icon="arrow-l">Back</a>
		<a href="javascript:location.reload()" data-ajax='false' data-icon="refresh">Reload</a>
		<a href="/mobile/logout.jsp" data-ajax='false' data-rel="dialog" data-icon="delete" data-iconpos="right" style="float:right;">Logout</a>
	</div>
</div>
</body>
</html>
