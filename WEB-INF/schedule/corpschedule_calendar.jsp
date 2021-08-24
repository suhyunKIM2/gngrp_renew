<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
	boolean isCorpScheduleManager = (Boolean) request.getAttribute("isCorpScheduleManager");
%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="main.Company.Schedule" text="회사일정" /></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/sunny/jquery-ui.css" />

<!--  jquery Full Calendar Plug-In -->
<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.css' />
<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.print.css' media='print' />
<script type='text/javascript' src='/common/jquery/fullcalendar/fullcalendar.js'></script>

<!-- jquery : qTip -->
<script src="/common/jquery/plugins/jquery.qtip.min.js" type="text/javascript"></script>

<script type="text/javascript">

var source = new Array();
source[0] = {
		events: function(start, end, callback) {
			var start = getDate($("#calendar").fullCalendar("getView").visStart);
			var end = getDate($("#calendar").fullCalendar("getView").visEnd);
			$.ajax({
				url: "/schedule/holiday_json.htm?startDate="+start+"&endDate="+end,
				type: "POST",
				dataType: "json",
				success: function(data, text, request) {
					//var events = eval(data.jsonTxt);
					var events = data;
					callback(events);
				}
			});
		},
		color: "red", // an option!
		textColor: "#fff", // an option!
		borderColor: "#000"
};

source[1] = {
		events: function(start, end, callback) {
			var start = getDate($("#calendar").fullCalendar("getView").visStart);
			var end = getDate($("#calendar").fullCalendar("getView").visEnd);
			$.ajax({
				url: "/schedule/corpschedule_calendar_json.htm?start="+start+"&end="+end,
				type: "POST",
				dataType: "json",
				success: function(data, text, request) {
					//var events = eval(data.jsonTxt);
					var events = data;
					callback(events);
				}
			});
		}
		//color: "#e84d11", // an option!
		//color: 'null', // an option!
		//textColor: '#000', // an option!
		//borderColor: "#4682B4"
};

$(document).ready(function() {
	$("#category").buttonset();

	var calendar = $('#calendar').fullCalendar({
		theme: false,
		formatDate: "yy-mm-dd",
		header: {
			left: "prev,next,today",
			center: "prev,title,next",
			right: "month,agendaWeek,agendaDay"
		},
		buttonText: {
			prev: "&nbsp;&#9668;&nbsp;",  // left triangle
			next: "&nbsp;&#9658;&nbsp;",  // right triangle
			prevYear: "&nbsp;&lt;&lt;&nbsp;", // <<
			nextYear: "&nbsp;&gt;&gt;&nbsp;", // >>
			today: "<spring:message code='sch.Todays.schedule' text='오늘의일정' />",
			month: "<spring:message code='sch.Amonthly.calendar' text='월간일정' />",
			week: "<spring:message code='sch.Weekly.Schedule' text='주간일정' />",
			day: "<spring:message code='sch.Daily.Schedule' text='일간일정' />"
		},
		titleFormat: {
			month: "yyyy-MM",
			week: "yyyy-MM-d[ yyyy]{ '~'[ MMM] d}",
			day: "yyyy-MM-d dddd"
		},
		monthNames: ["1 ", "2 ", "3 ", "4 ", "5 ", "6 ", "7 ", "8 ", "9 ", "10 ", "11 ", "12 "],
		monthNamesShort: [],
		dayNames: ["<font color=\"red\"><spring:message code='sch.Sunday' text='일요일' /></font>",
				   "<spring:message code='sch.Monday' text='월요일' />",
				   "<spring:message code='sch.Tuesday' text='화요일' />",
				   "<spring:message code='sch.Wednesday' text='수요일' />",
				   "<spring:message code='sch.Thursday' text='목요일' />",
				   "<spring:message code='sch.Friday' text='금요일' />",
				   "<spring:message code='sch.Saturday' text='토요일' />"],
	   dayNamesShort: ["<font color=\"red\"><spring:message code='sch.Sunday' text='일요일' /></font>",
				   "<spring:message code='sch.Monday' text='월요일' />",
				   "<spring:message code='sch.Tuesday' text='화요일' />",
				   "<spring:message code='sch.Wednesday' text='수요일' />",
				   "<spring:message code='sch.Thursday' text='목요일' />",
				   "<spring:message code='sch.Friday' text='금요일' />",
				   "<spring:message code='sch.Saturday' text='토요일' />"],
				   
		// Agenda Options
		allDaySlot: true,			// all-day 사용 여부
		allDayText: '종일일정',		// all-day 문자표시 설정
					
		viewDisplay: function(view) {},
		selectable: true,
		selectHelper: true,
		select: function(start, end, allDay) {
			<%	if (isAdmin || isCorpScheduleManager) { %>
			var startdate = getDate(start);
			var enddate = getDate(end);
			var url = "/schedule/corpschedule_form.htm?startdate="+startdate+"&enddate="+enddate;
			OpenWindow(url, "<spring:message code='main.Company.Schedule' text='회사일정' />", 500, 320);
			calendar.fullCalendar("unselect");
			<%	} %>
		},
		editable: true,
		disableDragging: true,
		disableResizing: true,
		dayClick: function(date, allDay, jsEvent, view) {},
		eventClick: function(calEvent, jsEvent, view) {				
			if (!calEvent.id) return;
			var url = "/schedule/corpschedule_read.htm?docid="+calEvent.id;
			OpenWindow(url, "<spring:message code='main.Company.Schedule' text='회사일정' />", 500, 320);
		},
		eventRender: function(event, element, view)   {
			element.qtip({
					content: event.descript,
					style: {width:300,padding:3,background:"#fff",color:"#FFF","font-size":"11px","z-index":"500",
						textAlign: "left",
						border: {width:3,radius:5,color:"#72a9d3"},
						tip: "bottomLeft",
						name: "dark" // Inherit the rest of the attributes from the preset dark style
					},
					position: {
						corner: {target:"topMiddle", tooltip:"bottomLeft"},
						adjust: {screen:true}
					},
					hide: {when:"mouseout", fixed:true, delay:100}
			});
			
			if (event.style == 1) { // 안건
				element.find(".fc-event-inner").css("color", "#FFF" );
				element.find(".fc-event-inner").css("background-color", "#9b6e38" );	// 갈색/황토색/고동색		//"#b6d2f5"
				//element.find(".fc-event-inner").css("background-color", "#6495ED" );
				//element.find(".fc-event-inner").css("border-color", "#000" );
				//element.find(".fc-event-skin").css("border-color", "#fff" );
			} else if (event.style == 2) {	// 출장
				element.find(".fc-event-inner").css("color", "#333" );
				element.find(".fc-event-inner").css("background-color", "#98fb98" );	// 초록					//"#b6d2f5"
				//element.find(".fc-event-inner").css("border-color", "#000" );
			} else if (event.style == 3) { // 방문
				element.find(".fc-event-inner").css("color", "#FFF" );
				element.find(".fc-event-inner").css("background-color", "#cc3366" );	// 빨강 					//"#b6d2f5"
				//element.find(".fc-event-hori").css("border-width", "1px" );
				//element.find(".fc-event-inner").css("border-color", "#4682B4" );
			}
			element.find(".fc-event-inner").css("font-weight", "bold" );
			element.find(".fc-event-time").html("");
			//element.find(".fc-event-inner").css("background-color", "#fff" );
			//element.find(".fc-event-time").html("<img align='absmiddle' src=\"/common/images/icons/approual_icon_" + event.style + ".jpg\" />");
		},
		//eventColor: '#378006',
		//eventBackgroundColor: '',
		//eventBorderColor: '',
		//eventTextColor: 'blue',
		//eventRender: function(event, element) {
		//	element.qtip({
		//		content: event.description
		//	});
		//},
		eventSources: [ source[0], source[1] ]
	});

	<%	if (isAdmin || isCorpScheduleManager) { %>
	var strButton = "<span class='fc-button fc-button-prev fc-state-default fc-corner-left fc-corner-right'>" 
				  + "	<span class='fc-button-inner' onclick='todayInsert()'>"
				  + "		<span class='fc-button-content'><b>New</b></span>"
				  + "		<span class='fc-button-effect'></span>"
				  + "	</span>"
				  + "</span>"
				  + "<span style='width:6px;display:inline-block;'></span>";
	var insButton = $(strButton);
	$("#calendar").find(".fc-header-right").prepend(insButton);
	<%	} %>
});

function goCal(args) {
	var url = "";
	switch(args) {
		case 1: url = "/schedule/calendarall.htm"; break;
		case 2: url = "/schedule/corpschedule_calendar.htm"; break;
		case 3: url = "/schedule/calendar.htm"; break;
	}
	self.location = url;
}

function getDate(args) {
	if (!args) {
		args = new Date();
	}
	var today = new Date(args);
	var y = today.getFullYear();
	var m = today.getMonth()+1;
	var d = today.getDate();
	
	if (m < 10) m = "0"+m;
	if (d < 10) d = "0"+d;
	
	var strDate = y+"-"+m+"-"+d;
	return strDate;
}

function todayInsert() {
	var startdate = getDate();
	var enddate = getDate();
	var url = "/schedule/corpschedule_form.htm?startdate="+startdate+"&enddate="+enddate;
	OpenWindow(url, "<spring:message code='main.Company.Schedule' text='회사일정' />", 500, 330);
	calendar.fullCalendar('unselect');
}

function reloadCal() {
	var newSource = new Array();
	newSource[0] = source[0];
	newSource[1] = source[1];
	$('#calendar')
		.fullCalendar('removeEventSource', source[0])
		.fullCalendar('removeEventSource', source[1])
		.fullCalendar('refetchEvents')
		.fullCalendar('addEventSource', newSource[0])
		.fullCalendar('addEventSource', newSource[1])
		.fullCalendar('refetchEvents');
	source[0] = newSource[0];
	source[1] = newSource[1];
}
</script>
<style>
.fc-border-separate td div{min-height:80px !important;}
.fc-widget-header{height:30px;line-height: 30px;background: #eee;}
.fc-state-highlight{background: #f5f9ff;border: 2px solid #266fb5 !important;}
.fc-grid .fc-day-number{min-height:auto !important;}
.fc-widget-header, .fc-widget-content{border: 1px solid #eaeaea;}
.fc-widget-content:hover{background:#f1f1f1;}
.fc-event-hori{border:0;background:none !important;}
.fc-corner-right .fc-event-inner {
    background: #fed54c  !important;
    border: 0 !important;
    color: #8a6001  !important;
}
.fc-widget-header font{color:#f91313;}
</style>
</head>
<body style="margin:0px;">

<!-- Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#f7f7f7; position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="270" style="padding-left:5px; padding-top:5px; ">
			<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
				<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
				<spring:message code="main.Schedule" text="일정관리" /> &gt;
				<spring:message code="sch.Company.schedules" text="회사일정" /> &gt; 
				<spring:message code="t.calendar" text="캘린더" /> 
			</span>
		</td>
		<td width="*" align="right" >
			<span id="category">
				<input onclick="goCal(1);" type="radio" id="cat0" name="category" value="" />
				<label for="cat0"><spring:message code="sch.Integrated.schedule" text="통합일정표" /></label>
				<input onclick="goCal(2);" type="radio" id="cat1" name="category" value="" checked="checked" />
				<label for="cat1"><spring:message code="sch.Company.schedules" text="회사일정" /></label>
				<input onclick="goCal(3);" type="radio" id="cat2" name="category" value="" />
				<label for="cat2"><spring:message code="sch.Individuals.a.shared.calendar" text="개인-공유일정" /></label>
			</span>
		</td>
	</tr>
</table>
<!-- Title -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="5"><td></td></tr></table>

<div id="calendar" style="width:85%;margin: 2% auto 0;    max-width: 1270px;"></div>

</body>
</html>