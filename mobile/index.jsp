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
/*.ui-icon, .ui-icon-searchfield:after{    background: #266fb5 !important;
    background: rgba(0,0,0,.4) {global-icon-disc};
    background-image: url(/common/jquery/mobile/1.2.0/images/icons-18-white.png)  !important;}
.ui-icon-arrow-r {
    background-position: -108px 50% !important;
}   */ 
.quick_menu .ui-icon,.ui-listview .ui-icon{background: #1064b0 url(/common/jquery/mobile/1.2.0/images/icons-36-white.png);background-size: 776px 18px;
    background-position: -108px 50%;}

.popup_work_check{position:fixed;width:100%;height:100%;background:rgba(255,255,255,0.7);z-index: 9;touch-action: none; } 
.popup_work_check_window{position: fixed;width:75%;height:auto;background: #fff;left: 50%;top: 50%;transform: translate(-50%, -50%);border: 5px solid #266fb5;border-radius: 20px;padding:5% 5% 15%;text-align: center;}
.popup_work_check_window span{font-size:13px;color:#ee3f2e;}
.popup_work_check_close_btn{text-align: right; width:100%;margin-bottom:2%;font-size:20px;cursor: pointer;}

.square{
 position:relative;
  border:0;
  width:80px;
  padding:0px;
  margin-left: calc(50% - 40px);
  margin-left: -webkit-calc(50% - 40px);
  margin-left: -moz-calc(50% - 40px);
  background:#ffde05;
  border-radius: 50%;
  margin-bottom: 7%;
}

.spin {
  height: 70px;
  width: 70px;
  border-radius: 50%;
  border:dashed 5px #ffa443;
  -webkit-animation-name: spin;
  -webkit-animation-duration: 3.5s;
  -webkit-animation-iteration-count: infinite;
  -webkit-animation-timing-function: linear;
}
.notice_icon{position:absolute;left:50%;top:50%;transform: translate(-50%,-50%);}
.text_popup_work_check{margin-bottom:4%;}
.popup_work_check_window ul{margin-top:4%;}
.popup_work_check_window ul li{width:100%;background:#2f80ce;margin-top: 4%;border-radius: 20px;text-align: center;border-bottom:0;color:#fff;padding: 0.8em 0;}
@-webkit-keyframes spin {
  from   {  -webkit-transform: rotate(0deg); }
  to   {  -webkit-transform: rotate(360deg); }
}
</style>

</head>
<body>
<div class="main_contents_box" style="position:absolute;width:100%;z-index: 9;background: #fff;">
 <div class="popup_work_check">
     <div class="popup_work_check_window">
         <div class="popup_work_check_close_btn">X</div>
         <div class="square">
          <div class="spin"></div>
          <div class="notice_icon">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 581.33 493.33" style="width:50px;height:50px;"><defs><style>.cls-1{fill:#fef6e4;}.cls-2{fill:#eee4cf;}.cls-3{fill:#ee3f2e;}.cls-4{fill:#9cca5a;}.cls-5{fill:#c02226;}.cls-6{fill:#474e5d;}.cls-7{fill:#606776;}.cls-8{fill:#2e3544;}</style></defs><g id="layer_2" data-name="layer_2"><g id="Icons"><path class="cls-1" d="M0,146.67v320a26.67,26.67,0,0,0,26.67,26.66h400a26.67,26.67,0,0,0,26.66-26.66v-320Z"/><rect class="cls-2" y="146.67" width="453.33" height="13.33"/><path class="cls-3" d="M426.67,26.67h-400A26.67,26.67,0,0,0,0,53.33v93.34H453.33V53.33A26.67,26.67,0,0,0,426.67,26.67Zm-340,86.66a26.67,26.67,0,1,1,26.66-26.66A26.67,26.67,0,0,1,86.67,113.33Zm280,0a26.67,26.67,0,1,1,26.66-26.66A26.67,26.67,0,0,1,366.67,113.33Z"/><rect class="cls-2" x="53.33" y="380" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="146.67" y="380" width="66.67" height="66.67" rx="0.67"/><rect class="cls-4" x="240" y="380" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="53.33" y="286.67" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="146.67" y="286.67" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="240" y="286.67" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="333.33" y="286.67" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="146.67" y="193.33" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="240" y="193.33" width="66.67" height="66.67" rx="0.67"/><rect class="cls-2" x="333.33" y="193.33" width="66.67" height="66.67" rx="0.67"/><path class="cls-5" d="M73.33,63.7A26.44,26.44,0,0,1,113,83.33a20.31,20.31,0,0,0,.33-3.33V26.67h-40Z"/><path class="cls-5" d="M353.33,26.67v37A26.44,26.44,0,0,1,393,83.33a20.31,20.31,0,0,0,.33-3.33V26.67Z"/><path class="cls-6" d="M86.67,0a20,20,0,0,0-20,20V73.33a20,20,0,0,0,40,0V20A20,20,0,0,0,86.67,0Z"/><path class="cls-7" d="M76.67,73.33V20c0-11,4.47-20,10-20-8.29,0-15,9-15,20V73.33c0,11,6.71,20,15,20C81.14,93.33,76.67,84.38,76.67,73.33Z"/><path class="cls-8" d="M86.67,0c5.52,0,10,9,10,20V73.33c0,11-4.48,20-10,20a20,20,0,0,0,20-20V20A20,20,0,0,0,86.67,0Z"/><path class="cls-6" d="M366.67,0a20,20,0,0,0-20,20V73.33a20,20,0,0,0,40,0V20A20,20,0,0,0,366.67,0Z"/><path class="cls-7" d="M356.67,73.33V20c0-11,4.47-20,10-20-8.29,0-15,9-15,20V73.33c0,11,6.71,20,15,20C361.14,93.33,356.67,84.38,356.67,73.33Z"/><path class="cls-8" d="M366.67,0c5.52,0,10,9,10,20V73.33c0,11-4.48,20-10,20a20,20,0,0,0,20-20V20A20,20,0,0,0,366.67,0Z"/><polygon class="cls-4" points="335.48 417.85 347.03 361.05 392.29 406.3 335.48 417.85"/><circle class="cls-4" cx="453.33" cy="300" r="128"/><path class="cls-1" d="M378.67,319.68l42.29-26,19.85,36.76s41.32-85.89,83.94-102.81c0,0-12.8,15.45,3.25,55.63,0,0-29,2.61-84.59,89.15C443.41,372.39,413.48,335.63,378.67,319.68Z"/></g></g></svg>
          </div>
        </div>
        <div class="text_popup_work_check">
            <b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b> 안녕하세요.<br>
             업무시작 클릭 후 그룹웨어를 시작 하세요. <br>
         </div>
         <span>※ 업무시작 버튼 클릭시 출근처리 됩니다.</span>
         
         <ul>  
             <li>업무시작</li>
         </ul>
     </div>
 </div>
<jsp:include page="/mobile/header.jsp"></jsp:include>
<div class="main_contents">
   <div class="user_name">
        <img src="/common/images/icon/img_01.png" border="0" class="user_icon_img"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/>님</b>
    </div>
    <div class="btn_nav_main">
        <ul>
            <li onClick="location.href='/mobile/mail/list.jsp?box=1&unread='">
                <div class="count_box_relative">
                    <div class="count"><div class="speech-bubble"><span class="ui-li-count mailcount">0</span></div></div>
                </div>
                <img src="/common/images/m_icon/01.png"  border="0" ><div class="nav_btn_div"><b>메일</b></div>
            </li>
            <li onClick="location.href='appr/list.jsp?menu=240'">
                <img src="/common/images/m_icon/02.png"  border="0" ><div class="nav_btn_div"><b>전자결재</b></div>
            </li>
            <li onClick="location.href='/mobile/notification/list.jsp?boxId=1&noteType=0'">
                <img src="/common/images/m_icon/03.png"  border="0" ><div class="nav_btn_div"><b>쪽지</b></div>
            </li>
            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000004'">
                <img src="/common/images/m_icon/05.png"  border="0" ><div class="nav_btn_div"><b>게시판</b></div>
            </li>
            <li onClick="location.href='/mobile/addressbook/user.jsp'">
                <img src="/common/images/m_icon/06.png"  border="0" ><div class="nav_btn_div"><b>임직원 정보</b></div>
            </li>
            <li onClick="location.href='/mobile/bbs/list.jsp?bbsId=bbs00000000000000'">
                <img src="/common/images/m_icon/04_1.png"  border="0" ><div class="nav_btn_div"><b>공지사항</b></div>
            </li>
        </ul>
    </div>
    <div class="quick_menu">
        <h4>Quick Menu</h4>
        <ul>
            <li onClick="location.href='/mail/mobile_mail_form_s.jsp'"><img src="/common/images/m_icon/07.png"> <b>편지쓰기</b> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick="location.href='/mobile/mail/list.jsp?box=1&unread=1'"><img src="/common/images/m_icon/08.png"> <b>읽지않은 메일</b> <span class="ui-li-count mailcount">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick="location.href='appr/list.jsp?menu=240'"><img src="/common/images/m_icon/09.png"> <b>결재할 문서</b> <span class="ui-li-count" id="count240">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick="location.href='appr/list.jsp?menu=340'"><img src="/common/images/m_icon/10.png"> <b>진행중 문서</b> <span class="ui-li-count" id="count340">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick="location.href='appr/list.jsp?menu=640'"><img src="/common/images/m_icon/11.png"> <b>배포 받은 문서</b> <span class="ui-li-count" id="count640">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
            <li onClick="location.href='appr/list.jsp?menu=820'"><img src="/common/images/m_icon/12.png"> <b>받은회람</b> <span class="ui-li-count" id="count820">0</span> <span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></li>
        </ul>
    </div>
</div>
<div class="footer_pc_ver" onClick="location.href='/jpolite/index.jsp'">
    <img src="/common/images/m_icon/13.png"> PC버전으로 보기
</div>
</div>

</body>
</html>
