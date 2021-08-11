<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/common/usersession.jsp"%>
<%
	String userDomain = uservariable.userDomain;
	String logoTxt = " ";
	String logoImg = "";
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<%
Long nowTimeL = new Date().getTime();

int port = request.getServerPort();
String baseURL = request.getScheme() + "://" + request.getServerName() + (port != 80 ? ":" + Integer.toString(port) : "") + request.getContextPath();

%>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title><%=logoTxt %>GroupWare System</title><%--=uservariable.campaignTitle --%>

<%-- <link rel="shortcut icon" href="<%=baseURL %>/common/images/starion_fav.png" /> --%>

<!--  jquery cdn -->
<link rel="stylesheet" href="/common/jquery/ui/1.10.3/themes/smoothness/jquery-ui.css" />
<!-- <link rel="stylesheet" href="/common/jquery/ui/1.8.16/themes/smoothness/jquery-ui.css" /> -->
<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/css/base/jquery.ui.all.css" />jquery-ui-1.8.16 base CSS -->

<!-- <script src="/common/jquery/js/jquery-1.9.1.js"></script> -->
<!-- <script src="/common/jquery/js/jquery-1.10.1.min.js"></script> -->

<!-- <script type="text/javascript" src="/common/jquery/js/jquery-1.6.4.min.js"></script>  -->
<script src="/common/jquery/js/jquery-1.7.1.js" type="text/javascript"></script>

<!-- <script src="/common/jquery/ui/1.8.16/jquery-ui.min.js" type="text/javascript"></script> -->
<script src="/common/jquery/ui/1.10.3/jquery-ui.js"></script>

<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" /> -->

<!-- jpolite -->
<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen"/>

<!-- jpolite silver mode -->
<link rel="stylesheet" title="silver" href="css/style.css" type="text/css" media="screen"/>

<!-- RSS Plug-in -->
<!-- <link rel="stylesheet" type="text/css" href="/common/jquery/plugins/FeedEk/FeedEk.css"/> -->
<!-- <script type="text/javascript" src="/common/jquery/plugins/FeedEk/FeedEk.js"></script> -->

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<!-- modaldialog Plug-in -->
<script src="/common/jquery/plugins/modaldialogs.js"></script>

<!-- chosen -->
<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/chosen-master/chosen/chosen.css" /> -->
<!-- <script src="/common/jquery/plugins/chosen-master/chosen/chosen.jquery.min.js" type="text/javascript"></script> -->

<!-- weather -->
<script src="/common/jquery/plugins/zweatherfeed-121/jquery.zweatherfeed.min.js" type="text/javascript"></script>
<!-- Example page styling (not required) -->
<link href="/common/jquery/plugins/zweatherfeed-121/example.css" rel="stylesheet" type="text/css" />

</head>

<body classs='normal' style="min-width:1194px; heights:950px; margin:10px; wsidth:1194px; background-color:#fff;" onloads="switchTheme('silver');">

<style>
#top {}
#top html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,
pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,font,img,ins,kbd,q,s,samp,small,strike,
strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,
tbody,tfoot,thead,tr,th,td{font-family:Verdana, Gulim; margin:0;padding:0;border:0;outline:0;font-size:9pt;vertical-align:baseline_a;background:null}
/*
body{line-height:1}blockquote,
q{quotes:none}blockquote:before,blockquote:after,q:before,q:after{content:'';content:none}:
focus{outline:0}ins{text-decoration:none}del{text-decoration:line-through}table{border-collapse:collapse;border-spacing:0} */
#top table { }
#top a { font-size:9pt; text-decoration:none; height:100%; }
#top th, td {padding:0xp; margin:0px; }
#top hr, p, ul, ol, dl, pre, blockquote, address, table, form {  }
#top .msub {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:link {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:visited {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:active {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:hover {color:#FFFFFF;text-decoration:underline; font-weight:bold; letter-spacing:-1px;}

#ui-tabs-1 {padding:0px;}
#ui-tabs-2 {padding:0px;}

/* h1 { */
/* 	font: 4em normal Arial, Helvetica, sans-serif; */
/* 	padding: 20px;	margin: 0; */
/* 	text-align:center; */
/* } */

/* h1 small{ */
/* 	font: 0.2em normal  Arial, Helvetica, sans-serif; */
/* 	text-transform:uppercase; letter-spacing: 0.2em; line-height: 5em; */
/* 	display: block; */
/* } */

/* h2 { */
/*     font-weight:700; */
/*     color:#bbb; */
/*     font-size:20px; */
/* } */

/* h2, p { */
/* 	margin-bottom:10px; */
/* } */

/* @font-face { */
/*     font-family: 'BebasNeueRegular'; */
/*     src: url('BebasNeue-webfont.eot'); */
/*     src: url('BebasNeue-webfont.eot?#iefix') format('embedded-opentype'), */
/*          url('BebasNeue-webfont.woff') format('woff'), */
/*          url('BebasNeue-webfont.ttf') format('truetype'), */
/*          url('BebasNeue-webfont.svg#BebasNeueRegular') format('svg'); */
/*     font-weight: normal; */
/*     font-style: normal; */

/* } */

/* .container {width: 75px; margin: 0 auto; overflow: hidden;} */

.clock {float:left; width:70px; height:19px; margin:2px 1px 0px 5px; padding:2px 1px 0px 4px; border:1px solid #dfdfdf; background-color:#efefef;   }
#Date { font-family:'BebasNeueRegular', Arial, Helvetica, sans-serif; font-size:36px; text-align:center; text-shadow:0 0 5px #00c6ff; }

.clock ul { swidth:75px; margin:0 auto; padding:0px; list-style:none; text-align:center; }
.clock ul li { line-height: 150%; display:inline; font-size:0.9em; font-weight:bold; text-align:center; font-family:'tahoma', Arial, Helvetica, sans-serif; colors:#3072b3; text-shadow:1px 1px 0 #bbb; /*text-shadows:-1px -1px 0 rgba(0,0,0,0.3);*/ margin:0px; float:left;}

#point { padding:0px 1px; position:relative; top: -2px; -moz-animation:mymove 1s ease infinite; -webkit-animation:mymove 1s ease infinite;  }

@-webkit-keyframes mymove 
{
0% {opacity:1.0; text-shadow:0 0 20px #00c6ff;}
50% {opacity:0; text-shadow:none; }
100% {opacity:1.0; text-shadow:0 0 20px #00c6ff; }	
}

@-moz-keyframes mymove 
{
0% {opacity:1.0; text-shadow:0 0 20px #00c6ff;}
50% {opacity:0; text-shadow:none; }
100% {opacity:1.0; text-shadow:0 0 20px #00c6ff; }	
}

</style>

<center>

<div class="all_centent_box" style="height: 100vh;">
    <div class="top_centent_box">
        <!-- TOP MENU INCLUDE -->
        <%@ include file="/top_include.jsp"%>
        <!-- TOP MENU INCLUDE -->
    </div>
    <!-- 전체 크기 _메인 -->
    <div class="main_centent_box">
        <!-- 좌측 메뉴 시작-->
        <div class="left_centent_box">
            <div class="main_auto">
                <!-- calendar area -->
                <div id="cal" style="border:0px solid #ddd; float:left;">
                    <div id="datepicker" style="float:left;width:50%; "></div>
                    <div id="sche" style="float:right; width:45%; height:156px; margins: 0px 3px 0px 1px; border:1px solid #bbb; border-top:1px dotted #bbb; background:#efefef; overflow: auto; overflow-x:hidden; scrollbar-base-color:#FFFAF0; scrollbar-darkshadow-color:#d3d3d3;">
                    </div>
                </div>
            </div>
        </div>
        <!-- 좌측 메뉴 끝-->
        <!-- 우측 메뉴 시작-->
        <div class="right_centent_box">
            rrrrrrr
        </div>
        <!-- 우측 메뉴 끝-->
    </div>
</div>



<!-- 전체 크기  -->
<div style="width:1192px; height:634px; border:1px solid #8294a4; border-width:0px 1px 1px 1px; background-color:#efefef; position: relative; top:50px;">

<!-- 좌측 메뉴 시작-->
<div style="width:230px; float:left; borders:1px solid #0099ff; background:#e4e6eb; padding:5px 10px; ssborder-bottom:1px solid #8294a4;">

<!-- welcome area -->
<div id="mailCounts" style="float:left; width:95%; border:1px solid #d2d2d2; margin-left0:5px; padding:2px 4px; float:left; background-color:#e2e2e2; ">
<table border="1" cellpadding="0" cellspacing="0" width="100%">
<tr>
<!-- <td width=70> -->
<%-- <img width="70" height="70" src="/userdata/photos/<%=loginuser.uid %>" onerror="this.src='/common/images/photo_user_default.gif'" /> --%>
<!-- </td> -->
<td style="padding-left:5px; vertical-align:top; padding-top:3px; text-align:left;">
<!-- 	<a href="#" onclick="javascript:fnlogout();" id="play_time_series" class="minibutton btn-download" style="position:relative; top:-2px; float:right;"> -->
<!-- 		<span><span class="icon-close"></span>종료 -->
<!-- 	</span></a> -->
	
<div style="line-height:18px; font-size:12px; font-family:dotum;"><b><%=loginuser.nName %> <fmt:message key="main.by.who"/></b>&nbsp;&nbsp;
<fmt:message key="main.Nice.to.meet.you"/><!-- welcome --><br/><fmt:message key="main.last.connect"/><!-- 최근 접속일시--> : <span id="lastLoginTime" style="font-size:90%;">2014-06-06 12:00:00</span></div>
</td>
</tr>
</table>
</div>
<!-- welcome area end -->

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="3">
<td></td>
</tr>
</table>

<!-- count area -->
<span id="q1" class="ui-corner-all" onclick="openTreeMenu('01','MENU010202');" style="cursor:pointer; float:left; background:#fff; border:2px solid #8294a4; width:65px; height:62px; line-height:12px; font-weightㄴ:bold; text-align:center; vertical-align:middle; padding-top:0px; margin-left:0px;ㄴtext-shadow: 1px 1px 0 #CCC;"><img src="/common/images/icon-mail-32.png" /><br/>
<fmt:message key="mail.email"/><!-- 전자메일 --><br/>
<span id="appr_idx5">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 -->
</span>

<span id="q2" class="ui-corner-all" onclick="openTreeMenu('02','MENU020201');" style="cursor:pointer; float:left; background:#fff; border:2px solid #8294a4; width:65px; height:60px; line-height:12px; font-weightㄴ:bold; text-align:center; vertical-align:middle;  padding-top:2px; margin-left:11px; margin-right:11px;ㄴtext-shadow: 1px 1px 0 #CCC;">
<img src="/common/images/icon-doc-32.png" /><br/><fmt:message key="main.Approval"/><!-- 전자결재 --><br/>
<span id="appr_idx1">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 -->
</span>

<span id="q3" class="ui-corner-all" onclick="openTreeMenu('01','MENU010302');" style="cursor:pointer; float:left; background:#fff; border:2px solid #8294a4; width:65px; height:60px; line-height:12px; font-weightㄴ:bold; text-align:center; vertical-align:middle; padding-top:2px;ㄴtext-shadow: 1px 1px 0 #CCC;">
<img src="/common/images/icon-folder-32.png" /><br/><fmt:message key="main.Message"/><!-- 쪽지--><br/>
<span id="appr_idx6">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 -->
</span>

<!-- count area end -->

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<div style="line-height: 0px; border-top: 1px solid #c4c9d3; border-bottom:1px solid #eeeff3; width: 108%; margin: 0px;z-index: 10; position: relative;left: -10px;">&nbsp;</div>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<!-- quick menu area -->
<fieldset id="fieldset11" style="text-align:left; border: 1px solid rgb(187, 187, 187); heights: 86px; border-top-left-radius: 3px; border-top-right-radius: 3px; border-bottom-left-radius: 3px; border-bottom-right-radius: 3px; ">
<legend style="margin:1px 10px; padding:0px 0px; border:1px; cursor:pointer;">
<span class="mtitle"><img src="../common/images/group_go.png" border="0" align="absmiddle">
	Quick Menu
</legend>

<div style="line-height:3px;">&nbsp;</div>
	
<div id="splay_time_series_button" style="text-align:left; ">
	&nbsp;<a href="javascript:qmenu(1);" id="play_time_series" class="minibutton btn-download" style="width:46%;">
		<span><span class="icon-mail"></span><fmt:message key="main.E-mail.Write"/><!-- 편지쓰기-->
	</span></a>
	<a href="javascript:qmenu(2);" id="play_time_series" class="minibutton btn-download" style="width:46%;">
		<span><span class="icon-calendar"></span><fmt:message key="main.schedule.write"/><!-- 일정작성-->
	</span></a><br/>
	<div style="line-height:3px;">&nbsp;</div>
	&nbsp;<a href="javascript:qmenu(3);" id="play_time_series" class="minibutton btn-download" style="width:46%;">
		<span><span class="icon-document"></span><fmt:message key="main.approval.write"/><!-- 결재작성-->
	</span></a>
	<a href="javascript:qmenu(5);" id="play_time_series" class="minibutton btn-download" style="width:46%;">
		<span><span class="icon-notification"></span><fmt:message key="notification.message.write"/> <!-- 쪽지작성-->
	</span></a>
<!-- 	<a href="javascript:qmenu(4);" id="play_time_series" class="minibutton btn-download" style="width:46%;"> -->
<!-- 		<span><span class="icon-sms"></span>SMS 보내기 -->
<!-- 	</span></a> -->
</div>
<div style="line-height:6px;">&nbsp;</div>
</fieldset>
<!-- quick menu area end -->

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<div style="line-height: 0px; border-top: 1px solid #c4c9d3; border-bottom:1px solid #eeeff3; width: 108%; margin: 0px;z-index: 100; position: relative;left: -10px;">&nbsp;</div>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>



<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>
<!-- <div style="line-height: 0px; border-top: 1px solid #c4c9d3; border-bottom:1px solid #eeeff3; width: 108%; margin: 0px;z-index: 100; position: relative;left: -10px;">&nbsp;</div> -->

<!--  식단표, 시스템 링크, 생일자, 설문 등 숨김 -->
<!-- 

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="dsisplay:none;">
<tr height="5">
<td></td>
</tr>
</table>

	<a href="#" id="q3" class="btn-blue btn-icon" onclick="qmenu(3);">
		<span style="width:211px; text-align:left; color:#fff; "><span class="icon-document"></span>금주 식단표 ~<br/>
	</span></a>
	<div style="line-height:5px;">&nbsp;</div>

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="dsisplay:none;">
	<tr height="5">
	<td></td>
	</tr>
	</table>

	<fieldset id="fieldset1" style="width:225px; margin-lefts:10px; margins:3px; paddings:3px; border:1px solid #bbb; height:76px;">
		<legend style="text-align:left; margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
		<span class="mtitle">
			업무 시스템 바로가기</span>
		</legend>
 <center>

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="dsisplay:none;">
<tr height="5">
<td></td>
</tr>
</table>

	<a href="javascript:goSystem(1);" id="q3" class="btn btn-icon">
		<span style="width:82px; text-align:left;"><span class="icon-document"></span>e-Pro<br/>
	</span></a>&nbsp;	
	<a href="javascript:goSystem(1);" id="q3" class="btn btn-icon" sonclick="goSystem(2);">
		<span style="width:82px; text-align:left;"><span class="icon-document"></span>SNS <br/>
	</span></a>
	<div style="line-height:5px;">&nbsp;</div>
	
	<a href="javascript:goSystem(1);" id="q3" class="btn btn-icon" sonclick="goSystem(3);">
		<span style="width:82px; text-align:left;"><span class="icon-document"></span>IS_OTS <br/>
	</span></a>&nbsp;
	<a href="javascript:goSystem(1);" id="q3" class="btn btn-icon" sonclick="goSystem(4);">
		<span style="width:82px; text-align:left;"><span class="icon-document"></span>EIS <br/>
	</span></a>
	<div style="line-height:5px;">&nbsp;</div>
</center>
	</fieldset>

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="dsisplay:none;">
<tr height="5">
<td></td>
</tr>
</table>

	<select id="go-homepage" data-placeholder="홈페이지 바로가기" style="width:220px;">
	<option value=""></option>
		<option value="0">스타리온 성철부산</option>
		<option value="1">스타리온 성철창원</option>
		<option value="2">스타리온 원우</option>
		<option value="3">스타리온 기원</option>
		<option value="4">스타리온 일우</option>
		<option value="5">스타리온 하나</option>
	</select>
	
	
<style>
.chzn-container .chzn-results li {text-align: left;}
</style>
 -->
<img src="../common/images/icon-rubber-balloons.png" border="0" align="absmiddle"> <b><fmt:message key="t.this.week"/><!-- 금주 생일자--></b><br/>

<div id="birthDiv" class="birthDiv" style="float:left; width:100%; height:115px; margins: 0px 3px 0px 1px; border:0px solid #bbb; border-top:0px dotted #bbb; background:#e4e6eb; overflow: auto; overflow-x:hidden; scrollbar-base-color:#FFFAF0; scrollbar-darkshadow-color:#d3d3d3;">
	
	<table width=100% border="1" cellspacing="0" cellpadding="0" style="border:1px solid #aaa;" class="birthDiv">
	<tr height="100%">
		<td align="center" valign="top" id="birthday">
			<table width="100%" border="0" style="table-layout:fixed;border:0px solid #aaa;">
				<tr height="100%" >
					<td align="center">
						<fmt:message key="t.no.birth"/><!-- 생일자가 없습니다. -->
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
</div>
<!-- 
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="dsisplay:none;">
<tr height="5">
<td></td>
</tr>
</table>

<div style="line-height: 0px; border-top: 1px solid #c4c9d3; border-bottom:1px solid #eeeff3; width: 108%; margin: 0px;z-index: 100; position: relative;left: -10px;">&nbsp;</div>

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="dsisplay:none;">
<tr height="5">
<td></td>
</tr>
</table>

<img src="../common/images/icon-chart1.png" border="0" align="absmiddle"> <b>설문조사</b><br/>
<div style="float:left; width:100%; height:116px; margins: 0px 3px 0px 1px; border:0px solid #bbb; border-top:0px dotted #bbb; background:#e4e6eb; overflow: auto; overflow-x:hidden; scrollbar-base-color:#FFFAF0; scrollbar-darkshadow-color:#d3d3d3;">
	<table width=100% border="1" cellspacing="0" cellpadding="0" style="border:1px solid #aaa;">
	<tr height=115>
		<td align="center" id="poll" valign="top">
			<table width="100%" border="0" style="table-layout:fixed;border:0px solid #aaa;">
				<tr height=113>
					<td align="center">
						진행중인 설문이 없습니다.
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
</div>
 -->
 
 
</div>
<!-- 좌측 메뉴 끝-->


<!-- middle1 -->
<div id="mid11" align="left" style="float:left; padding: 5px 3px 0px 8px; width:928px; border-left:1px solid #8294a4; sssborder-right:2px solid #8294a4;  sssborder-bottom:1px solid #8294a4; background-color:#fff; ">

<div id="mid1" align="left" style="float:left; margin-lefts:5px; padding:0px; width:100%; border:0px solid #0099ff;">
<table border="1" cellpadding="0" cellspacing="0" width="100%" style="display:none;">
<tr>
<td align="right">
	<!-- 카운트 영역 -->
	<div id="apCount" style="border:1px solid #d2d2d2; padding:4px; float:left; width:575px; height:45px; background-color:#e2e2e2; ">
	<table border="1" cellpadding="8" cellspacing="0" width="100%" height="100%" bordercolor="#FFFFFF" style="cell-spacing:5px; dfloat:right; ">
	<colgroup>
		<col width="90"></col>
		<col width="90"></col>
		<col width="90"></col>
		<col width="90"></col>
	</colgroup>
	<tr bgcolor="#f1f1f1" align="center">
	<td class="met" onclick="openTreeMenu('02','MENU020201');" style="cursor:pointer;"><fmt:message key="main.Approval.to.Doc"/>&nbsp;<!-- 결재할 문서 --></td>
	<td class="met" onclick="openTreeMenu('02','MENU020401');" style="cursor:pointer;"><fmt:message key="main.Distribute.received.documents"/>&nbsp;<!-- 배포받은 문서 --></td>
	<td class="met" onclick="openTreeMenu('02','MENU020802');" style="cursor:pointer;"><fmt:message key="main.Circulating.Inbox"/>&nbsp;<!-- 회람받은 문서 --></td>
	<td class="met" onclick="openTreeMenu('02','MENU020102');" style="cursor:pointer;"><fmt:message key="main.Temporary.storage"/>&nbsp;<!-- 임시저장 --></td>
	</tr>
	<tr bgcolor="#E6E6E6" align="center">
	<td class="mnum" onclick="openTreeMenu('02','MENU020201');" style="cursor:pointer;"><span id="appr_idx1_BK">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 --></td>
	<td class="mnum" onclick="openTreeMenu('02','MENU020401');" style="cursor:pointer;"><span id="appr_idx2">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 --></td>
	<td class="mnum" onclick="openTreeMenu('02','MENU020802');" style="cursor:pointer;"><span id="appr_idx3">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 --></td>
	<td class="mnum" onclick="openTreeMenu('02','MENU020102');" style="cursor:pointer;"><span id="appr_idx4">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 --></td>
	</tr>
	</table>
	</div>

	<div id="etcCount" style="border:1px solid #d2d2d2; margin-left:5px; padding:4px; float:left; width:312px; height:45px; background-color:#e2e2e2; ">
	<table border="1" cellpadding="8" cellspacing="0" width="100%" height="100%" bordercolor="#FFFFFF" style="cell-spacing:5px; dfloat:right; ">
	<colgroup>
		<col width="90"></col>
		<col width="90"></col>
	</colgroup>
	<tr bgcolor="#f1f1f1" align="center">
	<td class="met"><fmt:message key="main.Proposed.document"/>&nbsp;<!-- 제안문서 --></td>
	<td class="met"><fmt:message key="main.Screening.document"/>&nbsp;<!-- 심사문서 --></td>
	</tr>
	<tr bgcolor="#E6E6E6" align="center">
	<td class="mnum" onclick="openTreeMenu('10','MENU100201');" style="cursor:pointer;"><span id="appr_idx7">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 --></td>
	<td class="mnum" onclick="openTreeMenu('10','MENU100302');" style="cursor:pointer;"><span id="appr_idx8">0</span> <fmt:message key="main.ea"/>&nbsp;<!-- 건 --></td>
	</tr>
	</table>
	</div>
	<!-- 카운트 영역 끝 -->
	
</td>
</tr>
</table>

<!-- News Ticker 숨김 -->

<!-- <div class="nobg" style="border: 0px; display: none; "> -->
<!-- <div class="moduleHeader ui-corner-all" style="background-color: #b6d2f5; border:0px;"> -->
<!-- 	<div class="moduleTitle" style="margin: 6px 5px;width:100%;"><span style="position:relative; top:-1px;">News Ticker | </span> -->
<!-- 	<marquee style="float:leftss;" bgcolor="" direction="left" scrolldelay="150" width="80%" heights="100"> -->
<%-- 	<% --%>
<!-- 	if(noticeArry!=null){ -->
<!-- 		int count = 0; -->
<!-- 		for(int i=0;i<noticeArry.size();i++){ -->
<!-- 			noticeItem = (NoticeTickerItem)noticeArry.get(i); -->
<!-- 			out.print("<a href='javascript:noticeTickerRead("+noticeItem.docId+")'>"); -->
<!-- 			out.print(noticeItem.subject); -->
<!-- 			out.print("</a>"); -->
<!-- 			if(i!=noticeArry.size()-1){ -->
<!-- 				String spaceStr = ""; -->
<!-- 				for(int k=0;k<150;k++){ -->
<!-- 					spaceStr += "&nbsp;"; -->
<!-- 				} -->
<!-- 				out.print(spaceStr); -->
<!-- 			} -->
<!-- 		} -->
<!-- 	} -->
<!-- 	%> -->
<!-- 	</marquee> -->
<!-- 	</div> -->
<!-- </div> -->
<!-- </div> -->
 
<!-- <div style="line-height:5px;">&nbsp;</div> -->

<table width="100%" height="200" border="1" cellpadding="0" cellspacing="0" style="border:0px solid red;">
<!-- <table width="100%" height="200" border="1" cellpadding="0" cellspacing="0" style="border:0px solid red; backgrounds-image:url(/common/images/starion_skin_580_150.png); background-repeat:no-repeat;"> -->
	<tr>
	<td valign="middle" width="50%">
		<img style="margin-left:3px;" id="skinImage" src="/userdata/campaign_logo" width="457" height="180">
	</td>
	<td style="padding-left:3px; padding-right:5px; padding-top:3px; ">
		<div id="tabs" style="width:98%; height:188px; margin:0px 2px; padding:0px; border:0px solid red; overflow-y:hidden; overflow-x:hidden; ">
			<ul style="padding-top:3px; sborder-bottom:1px solid #ddd; padding-left:10px; background-color: #E4E6EB;">
				<li><a href="#tabs-2"><fmt:message key="main.weather_l"/><!-- 국내날씨 --></a></li>
				<li><a href="#tabs-1"><fmt:message key="main.weather_g"/><!-- 해외날씨 --></a></li>
			<a href="#" id="wreload" classs="ui-state-default ui-corner-all" title="refresh" style="float:right; smargin-right:5px; margin-top:3px;"><img src="/common/images/arrow-circle-225.png" />&nbsp;</a>
			<span href="#" id="buttons" classs="ui-state-default ui-corner-all" title="more" style="cursor:pointer; margin-right:5px; border:1px solid #aaa; float:right; height:15px; position:relative; top:3px; ;">
			<img src="/common/images/control-180-small.png" /><img src="/common/images/control-000-small.png" />
			</span>
			</ul>
			<div id="tabs-2" style="padding:0px; ">
				<div class="toggler" style="width:250px;margin:auto;">
					<div id="local"></div>
					<div class="clock" style="width:236px;"><ul><li id="localhours" style="float: none;">00-00 00:00</li></ul></div>
				</div>
			</div>
			<div id="tabs-1" style="padding:0px; ">
				<!-- 해외 날씨 1 -->
				<div class="toggler" style="width:250px;margin:auto;">
					<div id="effect" class="ui-widget-contents ui-corner-all" style="height:158px; margin-top:2px;">
					
					<div id="global1"></div>
							<div class="clock"><ul><li id="hours2" class="hongkong">00-00 00:00</li></ul></div>
							<div class="clock"><ul><li id="hours3" class="macau">00-00 00:00</li></ul></div>
							<div class="clock"><ul><li id="hours4" class="guangzhou">00-00 00:00</li></ul></div>
					</div>
				</div>
				
				<!-- 해외 날씨 2 -->
				<div class="toggler" style="width:250px;margin:auto;">
					<div id="effect1" class="ui-widget-contents ui-corner-all" style="display:none; height:158px; margin-top:2px;">
					
					<div id="global2"></div>
							<div class="clock"><ul><li id="hours7" class="la">00-00 00:00</li></ul></div>
							<div class="clock"><ul><li id="hours8" class="peicheng">00-00 00:00</li></ul></div>
							<div class="clock"><ul><li id="hours9" class="sydney">00-00 00:00</li></ul></div>
					</div>
				</div>
				
			</div>
		</div>
	</td>
	<td width="150" style="padding-top:3px;">
		<div class="moduleFrame nobg" style="width: 100%; float: left;">
			<div class="moduleHeader ui-corner-all">
				<div class="moduleTitle" style="margin: 4px 5px;"><fmt:message key="main.exchange.report"/><!-- 환율정보 --></div>
				</div>
			<div style="margin:0px 3px; width: 205px; height: 166px; padding-bottom: 0px; padding-top: 0px;">
				<iframe marginwidth="0" marginheight="0" frameborder="no" width="210" scrolling="no" height="166" style="margin-top: 0;" src="https://okbfex.kbstar.com/quics?page=C019465&cc=b028364:b031677&bgcol=7&CusBus=0&KorEng=K&widthPx=200"></iframe>
				<%-- 
					<iframe src="http://community.fxkeb.com/fxportal/jsp/RS/DEPLOY_EXRATE/3926_0.html" id="monTb" name="monTb" width="178" height="150" border="0" frameborder="no" scrolling="no" marginwidth="0" hspace="0" vspace="0"></iframe>
				--%>
			</div>
		</div>
	</td>
	</tr>
</table>

</td>
</tr>
</table>
</div>
<!-- middle1 -->

<div id="content" class="container" style="width:925px; background-color:#fff; float:left; ">

	<!-- email -->
	<div class="moduleFrame nobg" style="width: 50%; float: left;">
		<div class="moduleHeader ui-corner-all">
			<div class="moduleTitle" style="margin: 6px 5px;"><fmt:message key="mail.email"/><!-- 전자메일 --></div>
			<div class="moduleActions" style="margin: 6px 5px;">
				<b title="Refresh" class="actionRefresh"></b>
				<b title="More Content" class="actionMore"></b>
			</div>
		</div>
		<div id="tabs-mail" class="tabs moduleContent" style="height:170px; border:0px;">
			<ul class="tabsul" style="border:0px solid #ddd; border-bottom:1px solid #ddd; padding-left:10px; background-color: #fff;">
				<li style="font-size:9pt;"><a href="/mail/mail_front.jsp?listCount=6" data-pcode="01" data-scode="MENU010202"><img src="../common/images/icon-mail-receive.png" class="png24" align="absmiddle" />&nbsp;<fmt:message key='mail.InBox'/></a></li>
				<li style="font-size:9pt;"><a href="/notification/widget.htm?boxId=1" data-pcode="01" data-scode="MENU010302"><img src="../common/images/icon-balloon-box.png" class="png24" align="absmiddle" />&nbsp;<fmt:message key='main.Message'/></a></li>
			</ul>
<!-- 			<div id="tabs-mail-1" style="padding:0px; "></div> -->
<!-- 			<div id="tabs-mail-2" style="padding:0px; "></div> -->
		</div>
	</div>

	<!-- announce -->
	<div class="moduleFrame nobg" style="width: 50%; float: left;">
		<div class="moduleHeader ui-corner-all">
			<div class="moduleTitle" style="margin: 6px 5px;"><fmt:message key="main.notice"/><!-- 공지사항 --></div>
			<div class="moduleActions" style="margin: 6px 5px;">
				<b title="Refresh" class="actionRefresh" onclick="getAnnounceData()"></b>
				<b title="More Content" class="actionMore" onclick="openTreeMenu('05','MENU0501');"></b>
			</div>
		</div> 
		<div id="announce" class="moduleContent" style="margin:3px 3px; height: 170px; /* border: 1px solid #dfdfdf; padding:0px 3px; */"></div>
	</div>
	
	<!-- 최근글 목록시작 -->
		<%--
		<div class="moduleFrame nobg" style="width: 50%; float: left;">
			<div class="moduleHeader ui-corner-all">
				<div class="moduleTitle" style="margin: 6px 5px;"><fmt:message key="bbs.board.newest"/><!-- 최근글목록 --></div>
				<div class="moduleActions" style="margin: 6px 5px;">
					<b title="Refresh" class="actionRefresh" onclick="getNewestData()"></b>
					<b title="More Content" class="actionMore" onclick="openTreeMenu('05', 'MENU0512');"></b>
				</div>
			</div> 
			<div id="newest" class="moduleContent" style="margin:3px 3px; height: 170px;"></div>
		</div>
		--%>
	<!-- 최근글 목록 종료 -->
	
<div style="line-height:5px;">&nbsp;</div>
	
	<!-- approval -->
	<div class="moduleFrame nobg" style="width: 50%; float: left;">
		<div class="moduleHeader ui-corner-all">
			<div class="moduleTitle" style="margin: 6px 5px;"><fmt:message key="main.Approval"/><!-- 전자결재 --></div>
			<div class="moduleActions" style="margin: 6px 5px;">
				<b title="Refresh" class="actionRefresh"></b>
				<b title="More Content" class="actionMore"></b>
			</div>
		</div> 
		
		<div id="tabs-approval" class="tabs moduleContent" style="height:170px; border:0px;">
			<ul class="tabsul" style="border:0px solid #ddd; border-bottom:1px solid #ddd; padding-left:10px; background-color: #fff;">
				<li><a href="/approval/widget.htm?listCount=5&ctype=1" data-pcode="02" data-scode="MENU020201"><img src="../common/images/icon-document.png" align="absmiddle" />&nbsp;<fmt:message key='main.approval.tab'/><!--  <span style="color:red; font-weight:bold;">(1건)</span> --> </a></li>
				<li><a href="/approval/widget.htm?listCount=6&ctype=2" data-pcode="02" data-scode="MENU020202"><img src="../common/images/icon-document-arrow.png" align="absmiddle" />&nbsp;<fmt:message key='appr.menu.ing.appr'/><!--  3 건 --></a></li>
				<li><a href="/approval/widget.htm?listCount=6&ctype=3" data-pcode="02" data-scode="MENU020301"><img src="../common/images/icon-document-epub.png" align="absmiddle" />&nbsp;<fmt:message key='main.completed'/><!--  5 건 --></a></li>
			</ul>
<!-- 			<div id="tabs-approval-1" style="padding:0px; "></div> -->
<!-- 			<div id="tabs-approval-2" style="padding:0px; "></div> -->
<!-- 			<div id="tabs-approval-3" style="padding:0px; "></div> -->
		</div>
	</div>
	
	<!-- board -->
	<div class="moduleFrame nobg" style="width: 50%; float: left;">
		<div class="moduleHeader ui-corner-all">
			<div class="moduleTitle" style="margin: 6px 5px;"><fmt:message key="main.Board"/><!-- 게시판 --></div>
			<div class="moduleActions" style="margin: 6px 5px;">
				<b title="Refresh" class="actionRefresh"></b>
				<b title="More Content" class="actionMore"></b>
			</div>
		</div> 
		
<!-- 		<div id="board" class="moduleContent" style="margin:3px 3px; height: 170px;"></div> -->
		<div id="tabs-community" class="tabs moduleContent" style="height:170px; border:0px;">
			<ul class="tabsul" style="border:0px solid #ddd; border-bottom:1px solid #ddd; padding-left:10px; background-color: #fff;">
				<li><a href="/bbswork/widget.htm?listCount=5" data-pcode="05" data-scode="MENU0511"><img src="../common/images/icon-document.png" align="absmiddle" />&nbsp;<fmt:message key='main.Work.Board'/><!-- 업무게시판 --></a></li>
<%-- 				<li><a href="/bbs/widget_board.htm?endNum=6" data-pcode="05" data-scode="MENU0512"><img src='../common/images/NN.gif' align="absmiddle" />&nbsp;<fmt:message key='bbs.board.newest'/><!-- 최근글 목록 --></a></li> --%>
<!-- 				<li><a href="/bbs/widget_team.htm?listCount=6&topCode=2014101010370156" data-pcode="05" data-scode="MENU0511"><img src="../common/images/icon-document-arrow.png" align="absmiddle" />&nbsp;갤러리</a></li> -->
				<li><a href="/bbs/widget.htm?listCount=5&bbsId=bbs00000000000004" data-pcode="05" data-scode="MENU0505"><img src="../common/images/icon-document-arrow.png" align="absmiddle" />&nbsp;<fmt:message key='main.Free.Board'/><!-- 자유게시판 --></a></li>
			</ul>
<!-- 			<div id="tabs-approval-1" style="padding:0px; "></div> -->
<!-- 			<div id="tabs-approval-2" style="padding:0px; "></div> -->
<!-- 			<div id="tabs-approval-3" style="padding:0px; "></div> -->
		</div>
	</div>
	
<div id="header" style="display:none; width: 925px; background-color:#fff; float: left; margin-top:5px; border:1px solid #e4e4e4; border-width:0px 0px 1px 0px; height:20px;">
	<!-- <div id="logo"></div>
	<div id="title">A Lightweight Portal Framework based on jQuery</div>
	 -->
	<ul id="main_nav">
		<li id="t1" style="width:65x; height:20px; line-height:20px; "><b class="hover" style=" font-size:9pt;"><fmt:message key='main.common.screen'/><!-- 공통화면 --></b><fmt:message key='main.common.screen'/><!-- 공통화면 --></li>
<!-- 		<li id="t2"><b class="hover">TAB 1</b>TAB 1</li> -->
	</ul>
	 
<!-- 	<div id="info_bar" style="line-height:2px; height:2px; border:0px solid red; background-color:#fff;"> -->
<!-- 		<b id="loading"></b><b id="menu_btn"></b><i class="left hint">Module menu</i> -->
<!-- 		<i class="right"> -->
<!-- 			<b id="maxAll" title="Expand All Modules"></b> -->
<!-- 			<b id="minAll" title="Collapse All Modules"></b> -->
<!-- 		</i> -->
<!-- 		<i class="hint right">Adjust module appearance</i> -->
<!-- 	</div> -->
</div>

	<!--  portlet width handle : screen.css 에 설정됨. modules.js를 통해 width 등 클래스 핸들링 -->
	<div id="module_menu" class="jqmWindow" style="background-color:#fff;"></div>

	<div id="c2" class="cc" style="display:none;"></div>
	<div id="c1" class="cc" style="display:none;"></div>
	<div id="c3" class="cc" style="display:none;"></div>
	<!-- <hr style="line-height:0px; height:0px; border:0px;"> -->
	<!-- 1 records -->
	
<!-- 	<div id="c4" class="cc"></div> -->
	<div id="c5" class="cc" style="display:none;"></div>
	<div id="c6" class="cc" style="display:none;"></div>
	<!-- <hr style="line-height:0px; height:0px; border:0px;"> -->
	<!-- 2 records -->
 
 	<!-- 
	<div id="c7" class="cc" style="margin-left:3px; margin-top:10px; float:left; width:920px; display:none;">
		<div class="module nobg" id="m104:t1" style="border:0px">
			<div class="moduleFrame">
				<div class='moduleHeader ui-corner-all' style="border: 1px solid #d2d2d2; sdisplay:none;">
					<div class='moduleTitle' style="margin:4px 3px;">휴가자 및 출장 정보</div>
					<div class='moduleActions' style="display:none;">
						<b title="Collapse" class="actionMin"></b>
						<b title="Expand" class="actionMax"></b>
						<b title="Close" class="actionClose"></b>
					</div>
				</div>
				<div class='moduleContent' style="height:152px; margin: 0px 0px; "> 
					<div class="span-8" style="width:28%; margin-left:4px; spadding-top:3px; border:0px solid #e7566d; heightㄴ:180px;">
						<fieldset id="fieldset1" style="margin-lefts:10px; margins:3px; paddings:3px; border:1px solid #bbb; height:145px;">
						<legend style="margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
						<span class="mtitle"><img src="../common/images/icon-offline.png" align="absmiddle" />
							<fmt:message key="main.state.vavation"/>&nbsp; 휴가자 현황 </span> - <span id="appr_idx11">0</span><fmt:message key="main.people.vacation"/>&nbsp; 명 휴가중 
						</legend>
						<div id="vacation" style="width:100%;"></div>
						</fieldset>
					</div>
					
					<div class="span-8" style="spadding-top:3px; margin-left:10px; border:0px solid #579ae9; heightㄴ:180px; width:33%;">
						<fieldset style="margins:3px; paddings:3px; border:1px solid #bbb; height:145px;">
							<legend style="margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
							<span class="mtitle"><img src="../common/images/icon-away.png" border="0" align="absmiddle" />
								<fmt:message key="main.state.trip"/>&nbsp; 출장자 현황</span> - <span id="appr_idx12">0</span><fmt:message key="main.people.trip"/>&nbsp;명 출장중
							</legend>
							<div id="trip" style="width:100%; spadding-left:10px;"></div>
						</fieldset>
					</div>
					
					<div class="span-8" style="spadding-top:3px; margin-left:10px; border:0px solid #579ae9; heightㄴ:180px; width:325px;">
						<fieldset style="margins:3px; paddings:3px; border:1px solid #bbb; height:145px;">
							<legend style="margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
							<span class="mtitle"><img src="../common/images/icon-block-share.png" align="absmiddle" />
								자료실&nbsp;자료실</span>
							</legend>
							<div id="pds" style="width:100%; spadding-left:10px;"></div>
						</fieldset>
					</div>
					
					<div class="span-11" style="margin-left:1px; margin-top:5px; spadding-top:3px; padding-bottom:5px; border:0px solid #e7566d; float:left; width:375px; height:166px;">
						<div><img style="position:relative; top:-2px;" src="/common/images/icon-feed.png" align="absmiddle"/>&nbsp;<b>영어/한글 번역기</b></div>
						<iframe width=100% height=155 frameborder=1 scrolling="no" style="float:right; overflow: hidden; border: 1px solid #DDD; width: 100%; height: 145px; overflow:hidden; " src="/jpolite/modules/translate.html"></iframe>
					</div>

					<div class="span-11" style="margin-left:1px; margin-top:5px; spadding-top:3px; padding-bottom:5px; border:0px solid #e7566d; float:left; width:253px; height:168px; padding-right:12px;">
						<div><img style="position:relative; top:-2px;" src="/common/images/icon-feed.png" align="absmiddle" />&nbsp;<b>Daum News</b></div>
						<div id="divRss"></div>
					</div>
					
					<div class="span-11 last" style="margin-left:1px; margin-top:5px; spadding-top:3px; padding-bottom:5px; border:0px solid #e7566d; float:left; width:253px; height:168px; padding-right:12px;">
						<div><img style="position:relative; top:-2px;" src="/common/images/icon-feed.png" align="absmiddle"/>&nbsp;<b>Google News</b></div>
						<div id="divRssNaver"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
	-->
	
</div><!--  End Content -->

</div>

</div>

</center>

<script type="text/javascript">

	function goSystem( args ) {
		if ( args == 1 ) {
			window.open("http://www.starion.co.kr:87/ePro/", "_blank"); 
		} else if (args == 2 ) {
			window.open("http://www.starion.co.kr:87/SnS/", "_blank");
		} else if (args == 3 ) {
			window.open("http://www.starion.co.kr:87/Isots/login.aspx" ,"_blank");
		} else if (args == 4 ) {
			window.open("http://www.starion.co.kr:87/eis/default.aspx", "_blank");
		}
		
	}

	// 상단 알림창 - 레이어
	function getNoticePopup() {
		$.ajax({
		    url: '/bbs/notice_popup.htm',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	var tmp = data.split("</a>");
		    	for( var i=0; i < tmp.length-1; i++) {
			    	var topNoty = generate('topRight', 'alert', tmp[i] + "</a>");
			    	setTimeout(function() {
			    		$.noty.close(topNoty.options.id);
			    	}, 10000 );
		    	}
		    }
		});
	}
	
	function noticeTickerRead(docId) {
		var url = "/noticeticker/noticeticker_read.jsp?docid=" + docId;
		dhtmlwindow.open(
				url, "iframe", url, "noticeTickerRead", 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
	}

	$.cookie('jpolite2layout',null);
	function getAnnounceData() {
		$.ajax({
		    url: '/bbs/widget.htm?listCount=7&bbsId=bbs00000000000000',
		    //url: '/jpolite/modules/weather.html',
		    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#announce").html( data );
		    }
		});
	}
	
	function getNewestData() {
		$.ajax({
		    url: '/bbs/widget_board.htm?endNum=6',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#newest").html( data );
		    }
		});
	}
	
	/* 메인화면 자유게시판 초기호출 */
	function getBbsData() {
		//return;
		$.ajax({
		    url: '/bbs/widget.htm?listCount=7&bbsId=bbs00000000000004',
		    //url: '/jpolite/modules/weather.html',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#board").html( data );
		    }
		});
	}
	
	function getApprovalIngData() {
		$.ajax({
		    url: '/approval/widget.htm?listCount=10&ctype=1',
		    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#tabs-1").html( data );
		    }
		});
	}
	
	function getVacationIngData() {
		$.ajax({
		    url: '/vacation/widget.jsp?listcount=6&ctype=1',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#vacation").html( data );
		    }
		});
	}

	// 생일자 가져오기
	function getBirthdayData() {
		$.ajax({
// 		    url: '/sche/birthdaywidget.jsp?listcount=6&ctype=1',
			url: '/sche/widget_birthday.jsp',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#birthday").html( data );
		    }
		});
	}
	
	function getPollData() {
		$.ajax({
			url: '/poll/widget.jsp',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#poll").html( data );
		    }
		});
	}
	
	function getTripIngData() {
		$.ajax({
		    url: '/trip/widget.jsp?listcount=6&ctype=1',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#trip").html( data );
		    }
		});
	}
	
	/* 메인화면 자료실 초기호출 */
	function getPdsData() {
		$.ajax({
		    url: '/bbs/widget.htm?listCount=5&bbsId=bbs00000000000002',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#pds").html( data );
		    }
		});
	}

	// 메인화면 최근 접속일시 가져오기
	function getlastLoginTime() {
		$.ajax({
		    url: '/common/getLastLoginTime.htm',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#lastLoginTime").html( data );
		    }
		});
	}
				
/* 	function setWidgetCount(apprType) {
		$.ajax({
		    url: '/approval/apprWidgetCount.htm?apprType=' + apprType,
		    type: 'POST',
		    dataType: 'text',
		    success: function(data, text, request) {
		    	var objSpan = document.getElementById("appr_idx" + apprType);
		    	objSpan.innerText = data + " 건";
		    }
		});
	} */ // 02/21 김광일
	
	function setWidgetCount(apprType) {
		var u_Str = "";
		
		switch(apprType)
		{
		case 5:	//전자메일 읽지 않은 수
			url_Str = '/mail/WidgetCount.jsp';
			break;
		case 6:	//사내쪽지 읽지 않은수
			url_Str = '/notification/WidgetCount.htm';
			break;
//		case 10:	//대여
//			url_Str = '/fixtures/data/fixturesWidgetCount.jsp';
			break;
		case 7:		// 제안문서
		case 8:		// 심사문서
			url_Str = '/proposal/data/proposalWidgetCount.jsp?menu=' + apprType;
			break;
		case 11: 	// 휴가자 수
			url_Str = '/vacation/data/widgetCount.jsp';
			break;
		case 12:	// 출장자 수
			url_Str = '/trip/data/widgetCount.jsp';
			break;
		default :	//전자결재 관련 카운터
			url_Str = '/approval/apprWidgetCount.htm?apprType='+ apprType;
			break;
		}
		
		$.ajax({
		    url: url_Str,
		    type: 'POST',
		    dataType: 'text',
		    success: function(data, text, request) {
		    	var objSpan = document.getElementById("appr_idx" + apprType);
		    	var cnt = parseInt($.trim(data));
		    	if (isNaN(cnt)) cnt = 0;
		    	objSpan.innerHTML = cnt;
		    }
		});
	}
	
	function getScheIngData(date) {
		$.ajax({
// 		    url: '/sche/widget.jsp?listcount=999&ctype=1&date=' + date,
		    url: '/schedule/widget.htm?listcount=999&ctype=1&date=' + date,
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	var dateHeight = $("#datepicker").height();	//메인화면 달력의 세로길이
		    	/**
		    		해당월이 총 몇주인가에 따라 달력의 세로 길이가 변한다.
		    		변하는 세로길이에 맞춰 생일자 항목의 세로 길이를 조정한다.
		    	*/
		    	if(dateHeight >= 180){	//6주
		    		$(".birthDiv").css("height", "97");
		    	}else if(dateHeight >= 159){	//5주
		    		$(".birthDiv").css("height", "115");
		    	}else if(dateHeight <= 138){	//4주
		    		$(".birthDiv").css("height", "138");
		    	}
		    	$("#sche").html( data );
		    }
		});
	}

function setTab_not_use() {
	//getAnnounceData();	사용않음
	
	$( "#tabs" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				
				$( anchor.hash ).html(
					"Couldn't load this tab. We'll try to fix this as soon as possible. " +
					"If this wouldn't be a demo." );
				
				//alert( status );
			}
		}
	});
	
	//getBbsData();
	getVacationIngData();
	getBirthdayData();
	getPollData();		// 설문조사
	getTripIngData();
	getPdsData();	//업무자료실
	//getScheIngData("");
}
</script>
	
<script>
$(document).ready(function() {
	
	$( "#tabs" ).tabs();

	// calendar draw
 	$( "#datepicker" ).datepicker({		
 		dateFormat: 'yy-mm-dd',
 		onSelect: function(dateText, inst) { getScheIngData(dateText); },
 		onChangeMonthYear: function(year, month, inst){ getScheIngData(""); }//달력 월선택 변경시
 	});
 	
 	/*
	$("#go-system").chosen({
		default_text: "시스템 바로가기",
		disable_search_threshold: 6
 		//allow_single_deselect: true
	});

	$("#go-homepage").chosen({
		//no_results_text: "홈페이지 바로가기",
		disable_search_threshold: 7
 		//allow_single_deselect: true
	});
*/ 	

	getNoticePopup();	// 공지사항 팝업

	// Portal Counter	
	//1. 전자결재
	setWidgetCount(1);	//결재할 문서 수
// 	setWidgetCount(2);
// 	setWidgetCount(3);
// 	setWidgetCount(4);
 	
 	setWidgetCount(5);	//전자메일 수

 	setWidgetCount(6);	//사내쪽지
//  setWidgetCount(7);	//제안문서
//  setWidgetCount(8);	//제안심사
 	
// 	setWidgetCount(11);	//휴가자수
// 	setWidgetCount(12); //출장자수

	getScheIngData("");	//오늘의 일정 가져오기
	
//  getVacationIngData();	//휴가자 가져오기
 	getBirthdayData();		//생일자 가져오기
//  getPollData();			//진행설문 가져오기
// 	getTripIngData();		//출장자 가져오기
// 	getPdsData();		//자료실 가져오기
	getlastLoginTime();	//최근 접속일시 가져오기
	
	
	searchTel();
	
	//menu map crate
	jkmegamenu.render($);
	 	
	/*
 	$( "#tabs" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});
 	*/
 	
 	$( "#tabs-approval" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});
 	
 	$( "#tabs-community" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});

 	$( "#tabs-mail" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});

//  	 $( "#tabs-mail" ).tabs({
//  		beforeLoad: function( event, ui ) {
//  		ui.jqXHR.error(function() {
// 	 		ui.panel.html(
// 	 		"Couldn't load this tab. We'll try to fix this as soon as possible. " +
// 	 		"If this wouldn't be a demo." );
// 	 		});
//  		}
//  	});
 	 
 	getAnnounceData();
 	getNewestData();
 	getBbsData();
 	
	// 공지사항 tabs boarder 제거
 	$('#tabs > ul').removeClass('ui-widget-header');
 	$('ul').removeClass('ui-corner-all');

 // run the currently selected effect
 	function runEffect() {
 		 
	 	// get effect type from
	 	//var selectedEffect = $( "#effectTypes" ).val();
	 	var selectedEffect = "slide";
	 	// most effect types need no options passed by default
	 	var options = {};
	 	// some effects have required parameters
	 	if ( selectedEffect === "scale" ) {
	 	options = { percent: 0 };
	 	} else if ( selectedEffect === "size" ) {
	 	options = { to: { width: 200, height: 60 } };
 		}
 		// run the effect
 		$( "#effect" ).toggle( selectedEffect, options, 500 );
 		$( "#effect1" ).toggle( selectedEffect, options, 500 );
 	};
 	
 	 //callback function to bring a hidden box back
 	function callback() {
 		//$( "#effect1:none" ).removeAttr( "style" ).fadeOut();
 		$( "#effect1" ).toggle( selectedEffect, options, 500 );
 	};
 	
 	// set effect from select menu value
 	$( "#buttons" ).click(function() {
 		runEffect();
 		return false;
 	});
 	
 	$( "#wreload" ).click(function() {
 		weatherReload();
 		return false;
 	});

 	var ServerTimeL = <%=nowTimeL %>;
	var ServerTimeZ = 540 * 60000;
 	var ClientTimeL = new Date().getTime();
	var ClientTimeZ = new Date().getTimezoneOffset() * 60000;
 	var SyncTimeL = ClientTimeL - ServerTimeL;

 	function wTime(hoffset) {
 		var wDate = new Date();
 		var offset = hoffset * 3600000;
 		var tz = wDate.getTime() - SyncTimeL + offset + ServerTimeZ + ClientTimeZ;
 		wDate.setTime(tz);
 		var sDate = leftZero(wDate.getMonth()+1) + "-" + leftZero(wDate.getDate()) + " " + leftZero(wDate.getHours()) + ":" + leftZero(wDate.getMinutes());
 		return sDate;
 	}
 	
 	function ywTime(hoffset) {
 		var wDate = new Date();
 		var offset = hoffset * 3600000;
 		var tz = wDate.getTime() - SyncTimeL + offset + ServerTimeZ + ClientTimeZ;
 		wDate.setTime(tz);
 		var sDate = wDate.getFullYear() + "-" + leftZero(wDate.getMonth()+1) + "-" + leftZero(wDate.getDate()) + " " + leftZero(wDate.getHours()) + ":" + leftZero(wDate.getMinutes());
 		return sDate;
 	}
 	
 	function leftZero(num) { return ((num < 10)? "0": "") + num; }
 	
 	setInterval( function() {
 		// Create a newDate() object and extract the minutes of the current time on the visitor's
 		// var minutes = new Date().getMinutes();
 		// Add a leading zero to the minutes value
 		// for( var i=1; i < 11; i++ ) {
 		//	$("#min"+(i)).html(( minutes < 10 ? "0" : "" ) + minutes);
 		// }
 		
 		// HongKong
 		$(".hongkong").html(wTime(-1));
 		 
 		// Macau
  		$(".macau").html(wTime(-1));
 		
  		// Guangzhou
 		$(".guangzhou").html(wTime(-1));
  	
 		// LA
 		$(".la").html(wTime(-16));
 	
 		// Peicheng
 		$(".peicheng").html(wTime(-1));
 	
 		// Sydney
 		$(".sydney").html(wTime(+1));
 		
 		$("#localhours").html(ywTime(0));
	},1000);
 		
//  	setInterval( function() {
 		// Create a newDate() object and extract the hours of the current time on the visitor's
 		// var hours = new Date().getHours();
 		// Add a leading zero to the hours value
 		// $("#hours").html(( hours < 10 ? "0" : "" ) + hours);
 		// $("#hours1").html(( hours < 10 ? "0" : "" ) + hours);
 		// for( var i=1; i < 11; i++ ) {
 		// 	$("#hours"+(i)).html(( hours < 10 ? "0" : "" ) + hours);
 		// }
// 	}, 1000);
 	
 	// 국가 검색 사이트는 아래에서 참조
 	// http://www.zazar.net/developers/jquery/zweatherfeed/
 	// http://www.zazar.net/developers/jquery/zweatherfeed/example_location.html
 	
	function weatherReload() {
		$('#global1').html("");
		$('#global2').html("");
		$('#local').html("");
		
		//HongKong Macau Guangzhou 
		$('#global1').weatherfeed(['2165352','1887901','2161838'],{
			unit: 'c',
			image: true,
			country: true,
			highlow: true,
			wind: false,
			humidity: false,
			visibility: false,
			sunrise: false,
			sunset: false,
			forecast: false,
			link: false,
			woeid: true
		});
		// LA Peicheng Sydney 
		$('#global2').weatherfeed(['2442047','2137120','1105779'],{
			unit: 'c',
			image: true,
			country: true,
			highlow: true,
			wind: false,
			humidity: false,
			visibility: false,
			sunrise: false,
			sunset: false,
			forecast: false,
			link: false,
			woeid: true
		});
		
		// Seoul Busan Jeju
		$('#local').weatherfeed(['1132599','1132447','1132454'],{
			unit: 'c',
			image: true,
			country: false,
			highlow: true,
			wind: false,
			humidity: false,
			visibility: false,
			sunrise: false,
			sunset: false,
			forecast: false,
			link: false,
			woeid: true
		});
		
		setTimeout( function() {
			$('.weatherItem').css( 'background-image', function() {
				if ( this.style.backgroundImage.indexOf('20d.png') > -1 ) {
					this.style.backgroundImage = this.style.backgroundImage.replace(/20d\.png/gi,"28s.png");
				} else if ( this.style.backgroundImage.indexOf('20n.png') > -1 ) {
					this.style.backgroundImage = this.style.backgroundImage.replace(/20n\.png/gi,"28s.png");
				} else {
					this.style.backgroundImage = this.style.backgroundImage.replace(/d\.png/gi,"s.png");
					this.style.backgroundImage = this.style.backgroundImage.replace(/n\.png/gi,"s.png");
				}
			});
		}, 1000 );
	}
	
	function weatherResize() {
		//console.log("weatherResize");
		// 기본 d.png , n.png 를 s.png로 변경
		$('.weatherItem').css( 'background-image', function() {
			if ( this.style.backgroundImage.indexOf('20d.png') > -1 ) {
				this.style.backgroundImage = this.style.backgroundImage.replace(/20d\.png/gi,"28s.png");
			} else if ( this.style.backgroundImage.indexOf('20n.png') > -1 ) {
				this.style.backgroundImage = this.style.backgroundImage.replace(/20n\.png/gi,"28s.png");
			} else {
			this.style.backgroundImage = this.style.backgroundImage.replace(/d\.png/gi,"s.png");
			this.style.backgroundImage = this.style.backgroundImage.replace(/n\.png/gi,"s.png");
			}
		});
	}
	
	weatherReload();
	
	/* 국내 날씨 */
	/*
	setInterval( function() {
 		// Create a newDate() object and extract the minutes of the current time on the visitor's
 		var minutes = new Date().getMinutes();
 		// Add a leading zero to the minutes value
 		$("#localmin").html(( minutes < 10 ? "0" : "" ) + minutes);
	},1000);
 		
 	setInterval( function() {
 		// Create a newDate() object and extract the hours of the current time on the visitor's
 		var hours = new Date().getHours();
 		// Add a leading zero to the hours value
 		$("#localhours").html(( hours < 10 ? "0" : "" ) + hours);
	}, 1000);
 	*/	
	
 	
 	//$('.ui-datepicker').css( 'border', '1px solid #fff'); 	
 	//$(".moduleFrame").addClass("ui-corner-all");

 	/* 	
	$('#divRss').FeedEk({
// 		FeedUrl : 'http://media.daum.net/rss/part/primary/digital/rss2.xml',
		FeedUrl : 'http://www.daum.net/rss.xml',
		MaxCount : 10,
		ShowDesc : false,
		ShowPubDate:true
	});
	
	$('#divRssNaver').FeedEk({
// 		FeedUrl : 'http://media.daum.net/rss/part/primary/digital/rss2.xml',
// 		FeedUrl : 'http://www.zdnet.co.kr/services/rss/all/EUC/ZDNetKorea_News.asp',
		FeedUrl : 'http://news.google.co.kr/news?pz=1&ned=kr&hl=ko&topic=po&output=rss',
		MaxCount : 10,
		ShowDesc : false,
		ShowPubDate:true
	});
	*/
 	
 	$(".actionRefresh").bind("click", function() {
 		var moduleFrame = $(this).parents(".moduleFrame").eq(0);
 		if (moduleFrame.find(".moduleContent.ui-tabs").length > 0) {
 	 		var moduleContent = moduleFrame.find(".moduleContent.ui-tabs").eq(0);
 	 		var active = moduleContent.tabs("option", "active");
 	 		moduleContent.tabs("load", active);
 		} else {
 			// No Tabs
 		}
 	});

 	$(".actionMore").bind("click", function() {
 		var moduleFrame = $(this).parents(".moduleFrame").eq(0);
 		if (moduleFrame.find(".moduleContent.ui-tabs").length > 0) {
	 		var moduleContent = moduleFrame.find(".moduleContent.ui-tabs").eq(0);
	 		var active = moduleContent.tabs("option", "active");
	 		var a = moduleContent.find("ul>li a").eq(active);
	 		openTreeMenu(a.attr('data-pcode'), a.attr('data-scode'));
 		} else {
 			// No Tabs
 		}
 	});
});


</script>

<script type="text/javascript" src="/common/scripts/jkmegamenu.js">
/***********************************************
* jQuery Mega Menu- by JavaScript Kit (www.javascriptkit.com)
* jkmegamenu.js의 jkmegamenu.render($); 를 주석처리. index.jsp, main_sub.jsp의 document.ready 에서 호출하도록 수정.
***********************************************/
</script>

<script type="text/javascript">
//jkmegamenu.definemenu("anchorid", "menuid", "mouseover|click")
jkmegamenu.definemenu("megaanchor", "megamenu1", "click")
</script>

<style>
	

span.group-item-icon,
span.file-item-icon {
  display: inline-block;
  height: 16px;
  width: 16px;
  margin-left: -16px;
}
span.group-item-icon {
  background: url("/common/images/icons/admin_icon_7.jpg") no-repeat left 4px;
}

ul.ui-menu {
	list-style-type: none;
	margin:5px;
	white-space:pre;
}

li.ui-menu-item {
	vertical-align:top;
	padding:3px;
	//width:400px;
	height:75px;
	float: left;
}

li.ui-menu-item a {
	text-decoration:none;
	padding:3px;
	padding-top:0px;
	line-height:16px;
	cursor:pointer;
}
/* .ui-dialog-titlebar {height:25px;} */


#ui-datepicker-div {
	display:none;
}

#aps {font-size:9pt; }
#aps table { border:1px solid blue; table-layout:fixed;}
#aps tr {height:24px;}
#aps tr:hover { background-color:#eee; }
#aps td {white-space:nowrap; text-overflow:ellipsis; overflow:hidden; line-height:12px; font-size:9pt; padding-left:0px; padding-right:2px; padding-bottom:2px; }

/* #aps a, font {color:#000; font-weight:normal; text-decoration:none; } */
#aps a:hover, font:hover {color:#09F; font-weight:bold; text-decoration:none;}
#aps .clip {white-space:nowrap; text-overflow:clip; overflow:hidden;}


#approval_front {}
#approval_front td	{text-overflow:ellipsis; overflow:hidden; white-space:nowrap;}
/* td	{text-overflow:ellipsis; overflow:hidden; white-space:nowrap;} */


.ui-datepicker{
	width : 100%;
	height: inherit;
	font-size:10px;
	border:1px soldi #fff; 
}
/* .ui-datepicker td {padding:0px;} */
.ui-datepicker td span, .ui-datepicker td a {
padding:0.2em;
/* padding-bottom: 0px; */
}
.ui-datepicker-today {
font-weight:bold;
}
.ui-datepicker th {
padding: .3em .3em;
}

.ui-tabs .ui-tabs-nav li a {
padding: .3em 1em;
}

.tabsul {
//background: #EFEFEF;
background: #fff;
border-bottom:1px solid #ddd;
}

table.ui-datepicker-calendar a.ui-state-default {font-weight:bold;}
.ui-datepicker-today {color:blue;}
/* table.ui-datepicker-calendar a.ui-state-highlight { background:#b6d3f5; color:blue; border:1px solid blue;} */
table.ui-datepicker-calendar a.ui-state-active { background:#b6d3f5; color:blue; border:1px solid blue;}
/* ui-state-highlight ui-state-active */

table.ui-datepicker-calendar {font-family:arial}

.ui-tabs .ui-tabs-panel {padding: 0px;}
.ui-tabs .ui-tabs-nav {padding: 0em .2em;}
.moduleContent {margin: 0px; padding: 2px;}

.ui-tabs .ui-tabs-nav li.ui-tabs-selected {padding-bottom: 0px;}

div#menu ul ul li {text-align: left;}

.ui-tabs .ui-tabs-nav li.ui-tabs-active a, .ui-tabs .ui-tabs-nav li.ui-state-disabled a, .ui-tabs .ui-tabs-nav li.ui-tabs-loading a {
font-weight: bold;
}

</style>
</body>
</fmt:bundle>
</html>