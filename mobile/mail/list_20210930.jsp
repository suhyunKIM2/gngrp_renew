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
		
		var html = (pageNo == 1)? "<li data-role='list-divider'>"+boxMenu(box)+" <span class='ui-li-count'>"+records+"</span></li>": "";

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
			<input type="search" name="searchtext" id="searchtext" value="" placeholder="<%=msglang.getString("t.searchValue") /* 검색어 */ %> " />
		</div>
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
			<div class="ui-block-b">
				<button onclick="loadDataAjax('search')" data-theme="b">Search</button>
			</div>
		</fieldset>
		 
		<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b" id="list"></ul>
		<div class="ui-grid-solo ui-btn">
			<button onclick="loadDataAjax()" data-inline="true" data-mini="true" class="pagerBtn ui-btn-hidden">
				30 <%=msglang.getString("t.more") /* 더보기 */ %> 
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