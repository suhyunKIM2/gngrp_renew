<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="/common/usersession_mobile.jsp"%>
<%
String logoText = " ";
String userDomain = uservariable.userDomain;
boolean isPartnerTemp = loginuser.securityId == 8;
%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><%=logoText %>Mobile</title>
    <link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.css" />
	<link rel="stylesheet" href="/common/jquery/mobile/1.2.0/jqm-docs.css"/>
    <script src="/common/jquery/js/jquery-1.8.0.min.js"></script>
    <script src="/common/jquery/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script src="/common/scripts/mobile_common.js"></script>
    <script type="text/javascript">    	
    	$("#page-home").live("pageshow", function(e) {
			loadCountAjax("240");
			loadCountAjax("340");
			loadCountAjax("640");
			loadCountAjax("820");
			loadMailCountAjax();
			loadMailboxes();
			//loadTeamBbs();
			loadCategoryBbs();
		});

    	function loadMailCountAjax() {
			var url = '/mail/WidgetCount.jsp';
			$.get(url, function(data) {
				sessionChk(data);
				var records = eval(data) || 0;
				$(".mailcount").html(records);
			});
    	}
    	
		function loadCountAjax(menu) {
			var url = "";
			switch(menu) {
				case "130" : case "340" : case "530" : case "540" :
					url = "/approval/finlist_json.htm"; break;
				case "240" : 
					url = "/approval/inglist_json.htm"; break;
				case "620" : case "630" : case "640" :
					url = "/approval/receivelist_json.htm"; break;
				case "810" : case "820" :
					url = "/approval/circulationlist_json.htm"; break;
			}
			url +="?menu=" + menu + "&pageNo=0";
			$.get(url, function(data) {
				sessionChk(data);
				var data = eval(data) || { records: 0 };
				var records = data.records;
				$("#count" + menu).html(records);
			});
		}

		var dataMailboxes = null;
    	function loadMailboxes() {
			var url = '/mail/data/mailboxes_json.jsp';
			$.get(url, function(data) {
				sessionChk(data);
				dataMailboxes = data || [];
				showMailboxes(dataMailboxes);
			}, 'json');
    	}
    	
    	function showMailboxes(boxes) {
			var option = $(document.createElement('option')).val("").text("<%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %>");
			var select1 = $('#select-native-1'); select1.empty().append(option.clone());
			var select2 = $('#select-native-2'); select2.empty().append(option.clone());
			for(var i = 0, len = boxes.length; i < len; i++) {
				var box = boxes[i];
				var select = (box["type"] == "1")? select1: select2;
				select.append(option.clone().val(box["id"]).text(box["name"]));
			}
			select1.selectmenu('refresh');
			select2.selectmenu('refresh');
			if (select1.find("option").length > 1) $('#mailboxes1').show(); else $('#mailboxes1').hide();
			if (select2.find("option").length > 1) $('#mailboxes1').show(); else $('#mailboxes2').hide();
    	}
    	
    	function linkMailboxes(sel) {
    		var selected = $(sel).find("option:selected");
    		var boxid = selected.val();
    		var boxnm = encodeURI(selected.text(), "UTF-8");
    		if (boxid == "") return;
    		location.href = "./mail/list.jsp?box=" + boxid + "&boxnm=" + boxnm;
    	}
    	
    	var teamBbs = null;
    	function loadTeamBbs() {
    		var url = '/bbs/team_bbs_json.htm';
			$.get(url, function(data) {
				sessionChk(data);
				teamBbs = data || [];
				showTeamBbs(teamBbs);
			}, 'json');
    	}
    	
    	function showTeamBbs(lists) {
			var option = $(document.createElement('option')).val("").text("<%=msglang.getString("t.select.board") /* 게시판 선택 */ %>");
			var select3 = $('#select-native-3'); select3.empty().append(option.clone());
			for(var i = 0, len = lists.length; i < len; i++) {
				var bbs = lists[i];
				select3.append(option.clone().val(bbs["id"]).text(bbs["name"]));
			}
			select3.selectmenu('refresh');
			if (select3.find("option").length > 1) $('#teamBbs').show(); else $('#teamBbs').hide();
    	}
    	
    	function linkTeamBbs(sel) {
    		var selected = $(sel).find("option:selected");
    		var bbsid = selected.val();
    		var bbsnm = encodeURI(selected.text(), "UTF-8");
    		if (bbsid == "") return;
    		location.href = "./bbs/list.jsp?bbsId=" + bbsid + "&bbsNm=" + bbsnm;
    	}
    	
    	function loadCategoryBbs() {
    		var url = '/bbs/topcode_list_json.htm';
			$.get(url, function(data) {
				sessionChk(data);
				categorys = data.rows || [];
				for(var i = 0, iSize = categorys.length; i < iSize; i++) {
					var category = categorys[i];
					loadBbs(category.id, category.cell[0]);
				}
				
			}, 'json');
    	}
    	
    	function loadBbs(categoryCode, categoryName) {
    		var bbs = $("#bbs");
    		if ($("#bbs"+categoryCode).length == 0) {
	    		var li = '<li id="bbs'+categoryCode+'" data-role="list-divider" role="heading" class="ui-li ui-li-divider ui-bar-a">'+categoryName+'</li>';
	    		bbs.append(li);
	
	    		var url = '/bbs/category_bbs_json.htm?categoryCode=' + categoryCode;
				$.get(url, function(data) {
					sessionChk(data);
					categoryBbs = data || [];
					if (categoryBbs.length == 0) $('#bbs'+categoryCode).hide(); else $('#bbs'+categoryCode).show();
					showBbs(categoryCode, categoryBbs);
				}, 'json');
    		}
    	}

    	function showBbs(categoryCode, lists) {
			var category = $('#bbs'+categoryCode);
			for(var i = lists.length - 1; i >= 0; i--) {
				var bbs = lists[i];
				var bbsid = bbs["id"];
				var bbsnm = encodeURI(bbs["name"], "UTF-8");
				category.after('<li><a href="/mobile/bbs/list.jsp?bbsId='+bbsid+'&bbsNm='+bbsnm+'" data-ajax="false">'+bbs["name"]+'</a>');
			}
			$('#bbs').listview('refresh');
    	}
    </script>
    <style>
    .main_contents_top{width:95%;margin:auto;height:auto;overflow:hidden;}
    .left_logo{width:50%;float:left;margin: 0.5em 0;}
    .right_menu{width:50%;float:right;height:37px;line-height: 37px;margin:1em 0;text-align: right;color: #266fb5;font-weight: 600;}
    .main_contents{background:#f7f7f7;width:100%;height:100vh;}
    /*햄버거메뉴*/
    .menu {
          position: absolute;
          top: 0;
          right: 0;
          height: 100%;
          max-width: 0;
          transition: 0.5s ease;
          z-index: 1;
          background: rgba(0,0,0,0.7);
        }
        .burger-icon {
          cursor: pointer;
          display: inline-block;
          position: absolute;
          z-index: 2;
          padding: 8px 0;
          top: 25px;
          right:82px;
          user-select: none;
          width: auto;
          margin: 0;
        }

        .burger-icon .burger-sticks {
          background: #266fb5;
          display: block;
          height: 2px;
          position: relative;
          transition: background .2s ease-out;
          width: 18px;
        }

        .burger-icon .burger-sticks:before,
        .burger-icon .burger-sticks:after {
          background: #266fb5;
          content: '';
          display: block;
          height: 100%;
          position: absolute;
          transition: all .2s ease-out;
          width: 100%;
        }

        .burger-icon .burger-sticks:before {
          top: 5px;
        }

        .burger-icon .burger-sticks:after {
          top: -5px;
        }

        .burger-check {
          display: none;
        }

        .burger-check:checked~.menu {
          max-width: 100%;
          width: 100%;
        }
        .burger-check:checked~.menu div{background:#fff;width:80%;height:100vh;position:absolute;right:0;}
        .burger-check:checked~.burger-icon .burger-sticks {
          background: transparent;
        }

        .burger-check:checked~.burger-icon .burger-sticks:before {
          transform: rotate(-45deg);
        }

        .burger-check:checked~.burger-icon .burger-sticks:after {
          transform: rotate(45deg);
        }

        .burger-check:checked~.burger-icon:not(.steps) .burger-sticks:before,
        .burger-check:checked~.burger-icon:not(.steps) .burger-sticks:after {
          top: -20px;
          right: -73px;
          background: #333;
        }
    </style>
</head>
<body>
<div class="main_contents_top">
 <h1 class="left_logo">
     <a href="">
        <img src="/common/images/icon/logo.png" height="29" border="0" >
    </a>
 </h1>
<div class="right_menu">
   <input class="burger-check" type="checkbox" id="burger-check" />All Menu<label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
    <div class="menu">
      <div></div>
    </div>
</div>
</div>
<div class="main_contents">

</div>
<div data-role="page" class="type-home" id="page-home" style="position: relative;clear:both;">
	<div data-role="content">
		<div class="content-secondary">
			<div id="jqm-homeheader">
				<h1 id="jqm-logo"><%=logoText %></h1>
<!-- 				<p>GroupWare System</p> -->
			</div>
			<p class="intro"><strong>Welcome.</strong> <%=logoText %>Mobile Groupware</p>

			<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="f">
				<li data-role="list-divider">Quick Menu</li>
				<li><a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">
					<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.title") /* 메일작성 */ %>" src="/common/images/icon-mail-pencil.png">
					<%=msglang.getString("mail.title") /* 메일작성 */ %></a>
				<li><a href="/mobile/mail/list.jsp?box=1&unread=1" data-ajax="false">
					<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>" src="/common/images/icons/email_icon_1.jpg">
					<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %></a>
					<span class="ui-li-count mailcount">0</span>
				 
				<li><a href="appr/list.jsp?menu=240" data-ajax="false">결재할 문서</a><span class="ui-li-count" id="count240">0</span>
				<li><a href="appr/list.jsp?menu=340" data-ajax="false">진행중 문서</a><span class="ui-li-count" id="count340">0</span>
				<li><a href="appr/list.jsp?menu=640" data-ajax="false">배포받은 문서</a><span class="ui-li-count" id="count640">0</span>
				<li><a href="appr/list.jsp?menu=820" data-ajax="false">회람할 문서</a><span class="ui-li-count" id="count820">0</span>
				
			</ul>
		</div>

		<div class="content-primary">
			<nav>
				<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b">
				<li data-role="list-divider">Menu</li>
				<!-- 2016.07.29 협력사인 경우 전자결재,전자메일, pc버전보기전환 메뉴만 보이게 셋팅 -->
				<% if (isPartnerTemp) {%>
					<li>전자결재
						<ul data-role="listview">
							<li data-role="list-divider">기안함
							<li><a href="appr/list.jsp?menu=130" data-ajax="false">기안목록</a>
							<li data-role="list-divider">결재함
							<li><a href="appr/list.jsp?menu=240" data-ajax="false">결재할문서</a>
							<li><a href="appr/list.jsp?menu=340" data-ajax="false">결재한문서</a>
							<li><a href="appr/list.jsp?menu=530" data-ajax="false">반려된문서</a>
							<li data-role="list-divider">완료함
							<li><a href="appr/list.jsp?menu=540" data-ajax="false">전체보기</a>
							<li data-role="list-divider">수신함
							<li><a href="appr/list.jsp?menu=620" data-ajax="false">개인수신</a>
							<li><a href="appr/list.jsp?menu=630" data-ajax="false">부서수신</a>
							<li data-role="list-divider">회람함
							<li><a href="appr/list.jsp?menu=810" data-ajax="false">보낸회람</a>
							<li><a href="appr/list.jsp?menu=820" data-ajax="false">받은회람</a>
						</ul>
						
					<li><%=msglang.getString("mail.email") /* 전자메일 */ %>
						<ul data-role="listview">
							<li><a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.title") /* 편지쓰기 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.title") /* 편지쓰기 */ %></a>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=1" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %></a><span class="ui-li-count mailcount">0</span>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.InBox") /* 받은편지함 */ %>" src="/common/images/icon-mail-receive.png">
								<%=msglang.getString("mail.InBox") /* 받은편지함 */ %></a>
							<li id="mailboxes1">
							    <label for="select-native-1" style="font-weight: bold;"><%=msglang.getString("mail.InBox.personal") /* 받은편지함(개인용) */ %></label>
							    <select name="select-native-1" id="select-native-1" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<li><a href="/mobile/mail/list.jsp?box=2" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %>" src="/common/images/icon-mail-send.png">
								<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %></a>
							<li id="mailboxes2">
							    <label for="select-native-2" style="font-weight: bold;"><%=msglang.getString("mail.OutBox.personal") /* 보낸편지함(개인용) */ %></label>
							    <select name="select-native-2" id="select-native-2" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<!-- <li><a href="/mobile/mail/list.jsp?box=7" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="스팸편지함" src="/common/images/icon-mail-sign.png">스팸편지함</a> -->
							<li><a href="/mobile/mail/list.jsp?box=3" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %>" src="/common/images/icon-mail-temp.png"><%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %></a>
							<!-- <li><a href="/mobile/mail/list.jsp?box=6" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="예약편지함" src="/common/images/icon-clock-arrow.png">예약편지함</a> -->
							<!-- <li><a href="/mobile/mail/list.jsp?box=4" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="지운편지함" src="/common/images/icon-mail-minus.png">지운편지함</a> -->
						</ul>
						<li><a href="/jpolite/index.jsp" data-ajax="false"><%=msglang.getString("t.switch.pc.version") /* PC 버전 보기 전환 */ %></a>
				<% }else {%>
					<li>전자결재
						<ul data-role="listview">
							<li data-role="list-divider">기안함
							<li><a href="appr/list.jsp?menu=130" data-ajax="false">기안목록</a>
							<li data-role="list-divider">결재함
							<li><a href="appr/list.jsp?menu=240" data-ajax="false">결재할문서</a>
							<li><a href="appr/list.jsp?menu=340" data-ajax="false">결재한문서</a>
							<li><a href="appr/list.jsp?menu=530" data-ajax="false">반려된문서</a>
							<li data-role="list-divider">완료함
							<li><a href="appr/list.jsp?menu=540" data-ajax="false">전체보기</a>
							<li data-role="list-divider">수신함
							<li><a href="appr/list.jsp?menu=620" data-ajax="false">개인수신</a>
							<li><a href="appr/list.jsp?menu=630" data-ajax="false">부서수신</a>
							<li data-role="list-divider">회람함
							<li><a href="appr/list.jsp?menu=810" data-ajax="false">보낸회람</a>
							<li><a href="appr/list.jsp?menu=820" data-ajax="false">받은회람</a>
						</ul>
						
					<li><%=msglang.getString("mail.email") /* 전자메일 */ %>
						<ul data-role="listview">
							<li><a href="/mail/mobile_mail_form_s.jsp" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.title") /* 편지쓰기 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.title") /* 편지쓰기 */ %></a>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=1" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %>" src="/common/images/icons/email_icon_1.jpg">
								<%=msglang.getString("mail.unread") /* 읽지않은 메일 */ %></a><span class="ui-li-count mailcount">0</span>
							<li><a href="/mobile/mail/list.jsp?box=1&unread=" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.InBox") /* 받은편지함 */ %>" src="/common/images/icon-mail-receive.png">
								<%=msglang.getString("mail.InBox") /* 받은편지함 */ %></a>
							<li id="mailboxes1">
							    <label for="select-native-1" style="font-weight: bold;"><%=msglang.getString("mail.InBox.personal") /* 받은편지함(개인용) */ %></label>
							    <select name="select-native-1" id="select-native-1" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<li><a href="/mobile/mail/list.jsp?box=2" data-ajax="false">
								<img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %>" src="/common/images/icon-mail-send.png">
								<%=msglang.getString("mail.OutBox") /* 보낸편지함 */ %></a>
							<li id="mailboxes2">
							    <label for="select-native-2" style="font-weight: bold;"><%=msglang.getString("mail.OutBox.personal") /* 보낸편지함(개인용) */ %></label>
							    <select name="select-native-2" id="select-native-2" onchange="linkMailboxes(this)">
							    	<option value=""><%=msglang.getString("mail.select.mailbox") /* 편지함 선택 */ %></option>
							    </select>
							<!-- <li><a href="/mobile/mail/list.jsp?box=7" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="스팸편지함" src="/common/images/icon-mail-sign.png">스팸편지함</a> -->
							<li><a href="/mobile/mail/list.jsp?box=3" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="<%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %>" src="/common/images/icon-mail-temp.png"><%=msglang.getString("appr.menu.tempBox") /* 임시보관함 */ %></a>
							<!-- <li><a href="/mobile/mail/list.jsp?box=6" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="예약편지함" src="/common/images/icon-clock-arrow.png">예약편지함</a> -->
							<!-- <li><a href="/mobile/mail/list.jsp?box=4" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="지운편지함" src="/common/images/icon-mail-minus.png">지운편지함</a> -->
						</ul>		
					<li>사내쪽지
						<ul data-role="listview">
							<li><a href="/mobile/notification/list.jsp?boxId=1&noteType=0" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="받은쪽지함" src="/common/images/icons/approual_icon_4.jpg">받은쪽지함</a>
							<li><a href="/mobile/notification/list.jsp?boxId=1&noteType=1" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="읽지않은쪽지" src="/common/images/icons/notification_icon_1.jpg">읽지않은 쪽지</a>
							<!-- <li><a href="/mobile/notification/list.jsp?boxId=1&noteType=2" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="전자결재알림" src="/common/images/icons/approual_icon_10.jpg">전자결재 알림</a> -->
							<li><a href="/mobile/notification/list.jsp?boxId=2&noteType=0" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="보낸쪽지함" src="/common/images/icons/approual_icon_2.jpg">보낸쪽지함</a>
							<!-- <li><a href="/mobile/notification/list.jsp?boxId=2&noteType=-1" data-ajax="false"><img class="ui-li-icon ui-corner-none" alt="수신확인" src="/common/images/icons/admin_icon_9.jpg">수신확인</a> -->
						</ul>
					<li><%=msglang.getString("main.Board") /* 게시판 */ %>
						<ul data-role="listview" id="bbs">
<%-- 							<li><a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false"><%=msglang.getString("main.notice") /* 공지사항 */ %></a> --%>
							<li><a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000000" data-ajax="false"><%=msglang.getString("main.notice") /* 공지사항 */ %></a>
							<li><a href="/mobile/bbs/list.jsp?bbsId=bbs00000000000004" data-ajax="false">자유게시판</a>
							<!-- <li><a href="/mobile/bbs/list.jsp?bbsId=bbs20140902094343" data-ajax="false">갤러리</a> -->
							<!-- <li><a href="/mobile/bbs/list.jsp?bbsId=bbs20110922153448" data-ajax="false">사내경조사</a> -->
							<%-- 
							<li id="teamBbs">
							    <label for="select-native-3" style="font-weight: bold;"><%=msglang.getString("main.board.team") /* 팀게시판 */ %></label>
							    <select name="select-native-3" id="select-native-3" onchange="linkTeamBbs(this)">
							    	<option value=""><%=msglang.getString("t.select.board") /* 게시판 선택 */ %></option>
							    </select>
							--%>
						</ul>
					<li><%=msglang.getString("t.worksupport") /* 업무지원 */ %>
						<ul data-role="listview">
							<li><a href="/mobile/addressbook/user.jsp" data-ajax="false"><%=msglang.getString("main.Employee.Info") /* 임직원정보 */ %></a>
							<li><a href="/mobile/addressbook/list.jsp" data-ajax="false"><%=msglang.getString("main.Business.Card") /* 주소록관리 */ %></a>
						</ul>
					
					<!-- <img class="ui-li-icon ui-corner-none" alt="PC 전환" src="/common/images/icons/email_icon_10.jpg"> -->
					<li><a href="/jpolite/index.jsp" data-ajax="false"><%=msglang.getString("t.switch.pc.version") /* PC 버전 보기 전환 */ %></a>
				<%} %>
				</ul>
			</nav>
		</div>
	</div>

<!-- 	<div data-role="footer" class="footer-docs" data-theme="c"> -->
<!-- 		<p>Mobile Groupware</p> -->
<!-- 	</div> -->
</div>
</body>
</html>
