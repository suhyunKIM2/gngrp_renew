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
	<style type="text/css">
		table { width:100%; }
		table caption { text-align:left;  }
		table thead th { text-align:left; border-bottom-width:1px; border-top-width:1px; }
		table th, td { font-size: 75%; text-align:left; padding:6px;} 
	</style>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script src="/common/scripts/mobile_common.js"></script>
    <script type="text/javascript">
    	var docid = null;
    	
		$("#page-info").live("pageshow", function(e) {
			docid = $.urlParam("docid");
			loadDataAjax();
		});

		$.urlParam = function(name){
		    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
		    return results[1] || 0;
		}
		
		function loadDataAjax() {
			var url = "/addressbook/user_info_biz_json.htm?docid=" + docid;
			$.get(url, function(string) {
				sessionChk(data);
 				var data = $.parseJSON(string);
 				$('#gubun').text(data.gubun);
 				$('#categoryName').text(data.categoryName);
 				$('#nName').text(data.name);
 				$('#cpName').text(data.companyName);
 				$('#dpName').text(data.dpName);
 				$('#upName').text(data.gradeName);
 				$('#udName').text(data.dutyName);
 				
 				var telLink = "";
 				var mailLink = "";
 				var cellTelLink = "";
 				var homePageLink = "";
 				
 				if (data.telNo != "") telLink = "<a href='tel:"+data.tel+"'>"+data.tel+"</a>";
 				if (data.internetMail != "") mailLink = "<a href='mailto:"+data.email+"'>"+data.email+"</a>";
 				if (data.cellTel != "") cellTelLink = "<a href='tel:"+data.cellTel+"'>"+data.cellTel+"</a>";
 				if (data.homePage != "") homePageLink = "<a href='"+data.homePage+"'>"+data.homePage+"</a>";
 				
 				$('#telNo').html(telLink);
 				$('#internetMail').html(mailLink);
 				$('#faxNo').text(data.fax);
 				$('#cellTel').html(cellTelLink);
 				$('#homepage').html(homePageLink);
 				$('#addr').html(data.address);
			});
		}
		
    </script>
</head>
<body>
<div data-role="page" id="page-info">
	<div data-role="header" data-position="fixed" data-theme="b">
		<h2>Mobile Groupware</h2>
		<a href="/mobile/index.jsp" data-icon="home" data-direction="reverse" data-ajax="false">Home</a>
		<a href="/mobile/nav.jsp" data-icon="search" data-rel="dialog" data-transition="fade" data-iconpos="right">Menu</a>
	</div>
	
	<div data-role="content">
	
		<div data-role="header" data-theme="b" class="ui-corner-top">
			<h2><span id="gubun"><%=msglang.getString("addr.personal") /* 개인 */ %></span> - <span id="categoryName"><%=msglang.getString("t.category") /* 분류 */ %></span></h2>
		</div>
		<div class="ui-body ui-body-c ui-corner-bottom">
			<table>
				<tr>
					<th rowspan="5">
						<img src='/common/images/photo_user_default.gif' />
					</th>
					<th><%=msglang.getString("addr.name") /* 이름 */ %></th>
					<td><span id="nName"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.company") /* 회사 */ %></th>
					<td><span id="cpName"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("t.dpName") /* 부서 */ %></th>
					<td><span id="dpName"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.positon") /* 직급 */ %></th>
					<td><span id="upName"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.job.title") /* 직책 */ %></th>
					<td><span id="udName"></span></td>
				</tr>
			</table>
		</div>
		<div data-role="collapsible" data-collapsed="false" data-theme="b" data-content-theme="c">
			<h1><%=msglang.getString("main.Personal.Info") /* 개인정보 */ %></h1>
			<table>
				<tr>
					<th><%=msglang.getString("addr.email") /* E-mail */ %></th>
					<td><span id="internetMail"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.phone") /* 전화 */ %></th>
					<td><span id="telNo"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.cellphone") /* 휴대폰 */ %></th>
					<td><span id="cellTel"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.fax") /* 팩스 */ %></th>
					<td><span id="faxNo"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.homepage") /* 홈페이지 */ %></th>
					<td><span id="homepage"></span></td>
				</tr>
				<tr>
					<th><%=msglang.getString("addr.address") /* 주소 */ %></th>
					<td><span id="addr"></span></td>
				</tr>
			</table>
		</div>
	</div>

	<div data-role="footer" data-position="fixed" class="footer-docs ui-bar" data-theme="b">
<!-- 		<a href="javascript:history.back()" data-ajax='false' data-icon="arrow-l">Back</a> -->
		<a href="javascript:location.href='/mobile/addressbook/list.jsp?searchKey=<%=searchKey %>&searchValue=<%=searchValue %>'" data-ajax='false' data-icon="arrow-l">Back</a>
		<a href="javascript:location.reload()" data-ajax='false' data-icon="refresh">Reload</a>
		<a href="/mobile/logout.jsp" data-ajax='false' data-rel="dialog" data-icon="delete" data-iconpos="right" style="float:right;">Logout</a>
	</div>
</div>
</body>
</html>
