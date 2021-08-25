<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title><spring:message code="sch.Datebook"/><%-- 일정관리 --%></title>
<link rel="stylesheet" type="text/css" href="/common/jquery/ui/1.8.16/themes/sunny/jquery-ui.css" media="screen" />
<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.css' />
<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.print.css' media='print' />

<script type='text/javascript' src='/common/jquery/js/jquery-1.6.4.min.js'></script>
<script type='text/javascript' src='/common/jquery/ui/1.8.16/jquery-ui.min.js'></script>
<script type='text/javascript' src='/common/jquery/fullcalendar/fullcalendar.js'></script>
<script type='text/javascript' src='/common/jquery/plugins/modaldialogs.js'></script>				<!-- jquery - modal -->
<script type='text/javascript' src='/common/jquery/plugins/jquery.qtip.min.js'></script>			<!-- jquery - qTip -->
<script type='text/javascript' src='/common/scripts/common.js'></script>

<!-- uniform -->
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/uniform/themes/default/css/uniform.default.css" />
<script src="/common/jquery/plugins/uniform/jquery.uniform.min.js" type="text/javascript"></script>

<style type='text/css'>
.fc-event,
.fc-agenda .fc-event-time,
.fc-event a {
	background-color: black; /* background color */
	border-color: black;     /* border color */
	color: red;              /* text color */
}
.ui-widget-header {
	font-family:Gulim;
	font-size:10pt;
	padding:5px;
}
.holiday,
.fc-agenda .holiday .fc-event-time,
.holiday a {
	background-color: green; /* background color */
	border-color: green;     /* border color */
	color: yellow;           /* text color */
}
#tooltip {
	position:absolute;
	border:1px solid #333;
	background:#f7f5d1;
	padding:2px 5px;
	color:#333;
	display:none;
}
</style>
<script type='text/javascript'>

Date.prototype.addDate = function(d) { this.setDate(this.getDate() +d); return this; };
Date.prototype.addMinutes = function(m) { this.setMinutes(this.getMinutes() +m); return this; };
Date.prototype.toDateString = function() { d = this.getFullYear() + '-' + (this.getMonth()+1).lpad() + '-' + this.getDate().lpad(); return d; };
Date.prototype.toTimeString = function() { t = this.getHours().lpad() + ':' + this.getMinutes().lpad() + ':' + this.getSeconds().lpad(); return t; };
Date.prototype.toString = function() { s = this.toDateString() + ' ' + this.toTimeString(); return s; };
Date.prototype.gethh = function() { return (this.getHours() % 12 || 12).lpad(); };
Date.prototype.getTT = function() { return this.getHours() < 12 ? "AM": "PM"; };
Number.prototype.lpad = function(l) { l = l || 2; n = this + ''; while(n.length < l) n = '0' +n; return n; };

var originalPeriod = "";	// 일정 드래그 이동 및 일정 종료일시 조정시 일시를 임시저장하는 변수
var originalAllday = "";	// 일정 드래그 이동시 종일일정 설정을 임시저장하는 변수


var source = new Array();
source[0] = {
	color: 'red', textColor: '#fff', borderColor: "#000",
	events: function(start, end, callback) {
		var start = $('#calendar').fullCalendar('getView').visStart.toDateString();
		var end = $('#calendar').fullCalendar('getView').visEnd.toDateString();
		$.ajax({
			url: '/schedule/holiday_json.htm?startDate=' + start + '&endDate=' + end,
		    type: 'POST',
		    dataType: 'json',
		    success: function(data, text, request) {
		    	var events = data;
		        callback(events);
		    }
		});
	}
};

source[1] = {
	textColor: '#fff',
	events : function(start, end, callback) {
		var fc_start = $('#calendar').fullCalendar('getView').start.toDateString();
		var fc_end = $('#calendar').fullCalendar('getView').end.toDateString();
		var gubun = $('input[name=gubun]:checked').val();
		var scid = $('select[name=scid]').val();

		var bgColor = ["#838383","#0066EE","#EE6600"];	// 중요도 배경색
		
		$.ajax({
		    url: './calendar_json.htm?startDate=' + fc_start + '&endDate=' + fc_end + '&gubun=' + gubun + '&scid=' + scid,
		    type: 'POST',
		    dataType: 'json',
		    success: function(data, text, request) {
		    	events = [];
		    	for(var i in data) {
	    			var evt = data[i];
	    			var s = stringToDateFull(evt.start);
	    			var e = stringToDateFull(evt.end);
	    					    		
	    			//text.substr(0,limit)
	    			switch(evt.repeattype) {
		    			case "0" :									// 반복 없음
							events.push({
								id: evt.id,
								title: evt.title.substr(0,23),
								start: new Date(s.valueOf()),
								end: new Date(e.valueOf()),
								descript: evt.descript,
								backgroundColor: bgColor[evt.important || 0],
								allDay: (evt.allDay)?true:(((e.getTime() - s.getTime()) / (1000 * 60 * 60) >= 24)? true: false)	// 24시간 이상인 경우 종일일정으로 표시
							});
		    				break;
		    			case "1" :									// 반복 일간
		    				var rday = parseInt(evt.repeatday);		// 반복 일수
			    			while (s <= e) {
								events.push({
									id: evt.id,
									title: evt.title.substr(0,23),
									start: new Date(s.valueOf()),
									descript: evt.descript,
									backgroundColor: bgColor[evt.important || 0],
									allDay: evt.allDay,
									className: 'repeat'
								});
								s.setDate(s.getDate() + rday);
			    			}
		    				break;
		    			case "2" :									// 반복 주간
		    				var rweek = parseInt(evt.repeatweek);	// 요일
			    			while (s <= e) {
			    				if (s.getDay() <= rweek) {
		    						s.setDate(s.getDate() + (rweek - s.getDay()));
			    					events.push({
										id: evt.id ,
										title: evt.title.substr(0,23),
										start: new Date(s.valueOf()),
										descript: evt.descript,
										backgroundColor: bgColor[evt.important || 0],
										allDay: evt.allDay,
										className: 'repeat'
									});
			    				}
			    				s.setDate(s.getDate() + (7 - (s.getDay() - rweek)));
							}
		    				break;
		    			case "3" :									// 반복 월간
		    				var rmonth = parseInt(evt.repeatmonth);	// 일자
			    			while (s <= e) {
			    				if (s.getDate() <= rmonth) {
		    						s.setDate(rmonth);
			    					events.push({
										id: evt.id ,
										title: evt.title.substr(0,23),
										start: new Date(s.valueOf()),
										descript: evt.descript,
										backgroundColor: bgColor[evt.important || 0],
										allDay: evt.allDay,
										className: 'repeat'
									});
			    				}
			    				s.setMonth(s.getMonth() + 1);
							}
		    				break;
	    			}
		    	}
				callback(events);
		    }
		});
	}
};



$(document).ready(function() {
	$('#category, #gubun').buttonset();	/* radio set */
	
	var calendar = $('#calendar').fullCalendar({
			// General Display
			header: {
				left: 'prev,next today',
				center: 'prev,title,next',
				right: 'month,agendaWeek,agendaDay'
			},
			theme: false,
			viewDisplay: function(view) {},
			
			// Utilities
			formatDate: "yyyy-mm-dd",
			
			// Text/Time Customization
			titleFormat: {
				month: 'yyyy-MM',
				week: "yyyy-MM-d{ '~' yyyy-MM-d}",
			    day: 'yyyy-MM-d-dddd'
			},
			timeFormat: {
				'': 'hh:mmTT'
			},
			buttonText: {
			    today: '<spring:message code="sch.Todays.schedule"/>',		// 오늘의 일정
			    month: '<spring:message code="sch.Amonthly.calendar"/>',	// 월간일정
			    week: '<spring:message code="sch.Weekly.Schedule"/>',		// 주간일정
			    day: '<spring:message code="sch.Daily.Schedule"/>'			// 일간일정
			},
			monthNames: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
			monthNamesShort: [],
			dayNames: ['<font color=\'red\'><spring:message code="sch.Sunday"/></font>',	// 일요일
			           '<spring:message code="sch.Monday"/>',								// 월요일
			           '<spring:message code="sch.Tuesday"/>',								// 화요일
			           '<spring:message code="sch.Wednesday"/>',							// 수요일
			           '<spring:message code="sch.Thursday"/>',								// 목요일
			           '<spring:message code="sch.Friday"/>',								// 금요일
			           '<spring:message code="sch.Saturday"/>'],							// 토요일
           dayNamesShort: ['<font color=\'red\'><spring:message code="sch.Sunday"/></font>',
			           '<spring:message code="sch.Monday"/>',
			           '<spring:message code="sch.Tuesday"/>',
			           '<spring:message code="sch.Wednesday"/>',
			           '<spring:message code="sch.Thursday"/>',
			           '<spring:message code="sch.Friday"/>',
			           '<spring:message code="sch.Saturday"/>'],
			           
			// Agenda Options
			allDaySlot: true,			// all-day 사용 여부
			allDayText: '종일일정',		// all-day 문자표시 설정
			
			// Selection
			selectable: true,
			selectHelper: true,
			select: function(start, end, allDay) {
				var startdate = start.toDateString();
				var enddate = end.toDateString();
				var url = "/schedule/form.htm?startDate=" + startdate + "&endDate=" + enddate;

				OpenWindow(url, "Schedule", "800", "400");
				
// 				parent.dhtmlwindow.open(
// 					url, "iframe", url, "Schedule", 
// 					"width=800px,height=400px,resize=1,scrolling=1,center=1", "recal"
// 				);
				calendar.fullCalendar('unselect');
			},
			
			// Event Dragging & Resizing
			editable: true,				// 일정 편집 여부
			disableDragging: false,		// 일정 드래그 해제
			disableResizing: false,		// 일정 크기 조정 해제
			eventDragStart: function(event, jsEvent, ui, view) {					// 일정이동이 시작될때 일정기간을 임시저장
				originalPeriod = event.start.toString() + " ~ " + event.end.toString();
				originalAllday = event.allDay;
			},
			eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
				if (event.className.join(",").indexOf("repeat") > -1) {				// 반복일정인 경우
					revertFunc();
					alert("<spring:message code='sch.repeat.not.moved' text='반복 일정은 이동 할 수 없습니다.' />");
				} else if (event.className.join(",").indexOf("holiday") > -1) {		// 국경일정인 경우
					revertFunc();
					alert("<spring:message code='sch.holiday.not.moved' text='국경일은 이동 할 수 없습니다.' />");
				} else {															// 일정이동
					var newPeriod = event.start.toString() + " ~ " + event.end.toString();
					var msg = "";
					if (originalPeriod != newPeriod) {
						msg += "\"" + event.title + "\" 의 일정의 기간을 \n";
						msg += "\"" + originalPeriod  + "\" 에서 \n";
						msg += "\"" + newPeriod  + "\" 로 \n";
						msg += "이동";
					}
					if (originalAllday == false && allDay) { 
						if (msg != "") msg += "하고 \n";
	 					msg += "종일일정으로 설정";
					}
					if (msg != "") msg += "하시겠습니까?";

					var url = '/sche/data/sche_update.jsp?id=' + event.id 
						    + '&startdate=' + event.start.toDateString() 
						    + '&starth='  + event.start.gethh() 
						    + '&startm='  + event.start.getMinutes().lpad() 
						    + '&starts='  + event.start.getTT()
						    + '&enddate=' + event.end.toDateString() 
						    + '&endh='  + event.end.gethh() 
						    + '&endm='  + event.end.getMinutes().lpad()
						    + '&ends='  + event.end.getTT()
						    + '&allday=' + ((allDay) ? '1' : '0');

					if (confirm(msg) && msg != "") {
						$.ajax({
							url: url,
						    type: 'POST',
						    dataType: 'json',
						    success: function(data, text, request) {
						    	var result = $.trim(data);
						    }
						});
					} else revertFunc();
				}
				originalAllday = "";
				originalPeriod = "";
			},
			eventResizeStart: function(event, jsEvent, ui, view) {					// 일정조정이 시작될때 종료일시를 임시저장
				originalPeriod = event.end.toString();
			},
			eventResize: function(event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view) {
				if (event.className.join(",").indexOf("repeat") > -1) {				// 반복일정인 경우
					revertFunc();
					alert("반복 일정은 조정 할 수 없습니다.");
				} else if (event.className.join(",").indexOf("holiday") > -1) {		// 국경일정인 경우
					revertFunc();
					alert("국경일은 조정 할 수 없습니다.");
				} else if (!event.end) {											// 종료일시가 없는 경우
					revertFunc();
					alert("<spring:message code='sch.end.early.start' text='종료일이 시작일보다 작을 수 없습니다.' />");
				} else {															// 일정조정
					var msg = "\"" + event.title + "\" 의 종료일시를 \n"
							+ "\"" + originalPeriod  + "\" 에서 \"" + event.end.toString()  + "\" 로 \n"
							+ "조정하시겠습니까?";
					var url = '/sche/data/sche_update.jsp?id=' + event.id 
						    + '&enddate=' + event.end.toDateString() 
						    + '&endh='  + event.end.gethh() 
						    + '&endm='  + event.end.getMinutes().lpad() 
						    + '&ends='  + event.end.getTT()
						    + '&allday=' + ((event.allDay) ? '1' : '0');
					
					if (confirm(msg)) { 
						$.ajax({
							url: url,
						    type: 'POST',
						    dataType: 'json',
						    success: function(data, text, request) {
						    	var result = $.trim(data);
						    }
						});
					} else revertFunc();
				}
				originalPeriod = "";
			},
			
			// Clicking & Hovering
			dayClick: function(date, allDay, jsEvent, view) {},
			eventClick: function(calEvent, jsEvent, view) {
				if (calEvent.id == '0' || !calEvent.id) return;
		        var url = "/schedule/read.htm?docId=" + calEvent.id;
		        OpenWindow(url, "Schedule", "800", "350");
// 				parent.dhtmlwindow.open(
// 					url, "iframe", url, "Schedule", 
// 					"width=800px,height=400px,resize=1,scrolling=1,center=1", "recal"
// 				);
		    },
		    
		    // Event Rendering
			eventRender: function(event, element, view)   {
				if (event.id == '0') return;
				element.qtip({
					content: event.descript,
					style: {
						width:300,padding:3,background:'#fff',color:'#FFF','font-size':'11px','z-index':'500',
						textAlign:'left',
						border:{width:3,radius:5,color:'#72a9d3'},
						tip:'bottomLeft',
						name:'dark' // Inherit the rest of the attributes from the preset dark style
					},
					position: {
						corner: {target:'topMiddle', tooltip:'bottomLeft'},
						adjust: {screen:true}
					},
					hide: {when:'mouseout', fixed:true, delay:50}
				});
		    },
		    
		    // Event Data
			eventSources: [ source[0], source[1] ]
		});
		
		// 신규버튼 삽입
		var strButton = "<span class='fc-button fc-button-prev fc-state-default fc-corner-left fc-corner-right'>" 
					  + "	<span class='fc-button-inner' onclick='todayInsert()'>"
					  + "		<span class='fc-button-content'><b>New</b></span>"
					  + "		<span class='fc-button-effect'></span>"
					  + "	</span>"
					  + "</span>"
					  + "<span style='width:6px;display:inline-block;'></span>";
		var insButton = $(strButton);
		$("#calendar").find(".fc-header-right").prepend(insButton);
		

// 		function MyEvents(start,end, callback) {
// 		}
		
		$(".uniform").uniform();
		$('#uniform-scid').hide();
	});
	
		// 김정국 추가
		function stringToDate(strDate) {
			//yyyy-mm-dd 형태
			var a = strDate.split("-");
			var date1 = new Date(a[0], a[1]-1, a[2], 00, 00, 00, 00);
			return date1;
		}
		
		// 김정국 추가
		function stringToDateFull(strDate) {
			//yyyy-mm-dd hh:mm 형태
			var i = strDate.split(" ");
			var a = i[0].split("-");
			var b = i[1].split(":"); 
			var date1 = new Date(a[0], a[1]-1, a[2], b[0], b[1], 00, 00 );
			return date1;
		}

	function todayInsert() {
		var today = new Date();
		var startdate = today.toDateString();
		var enddate = today.toDateString();
		var url = "/schedule/form.htm?startDate=" + startdate + "&endDate=" + enddate;

		OpenWindow(url, "Schedule", "800", "400");
		
// 		parent.dhtmlwindow.open(
// 			url, "iframe", url, "Schedule", 
// 			"width=800px,height=400px,resize=1,scrolling=1,center=1", "recal"
// 		);
	}

	function goCal(args) {
		var url = "";
		switch(args) {
			case 1 : url = "/schedule/calendarall.htm"; break;		// 통합일정표
			case 2 : url = "/schedule/corpschedule_calendar.htm"; break;	// 회사일정
			case 3 : url = "/schedule/calendar.htm"; break;			// 개인공유일정
// 			case 4 : url = "/trip/calendar.jsp"; break;			// 출장자현황
			case 5 : url = "/vacation/calendar.jsp"; break;		// 연차휴가현황
			case 6 : url = "/project/calendar.htm"; break;		// 프로젝트
		}
		self.location = url;
	}
	
// 	function reload() {
// 		setTimeout(function() { 
// 			$('#calendar').fullCalendar('removeEvents');
// 			$('#calendar').fullCalendar('addEventSource', 'JsonResponse.ashx?technicans=' + technicians)
			
// 			$('#calendar').fullCalendar('refetchEvents');
// 			$('#calendar').fullCalendar('rerenderEvents');
// 		}, 0);
// 	}
	
	
	var optionS = '<option value=""><spring:message code="t.all" text="전체" /></option>';
	var optionP = '<option value=""><spring:message code="t.all" text="전체" /></option>';

	<c:forEach var="item" items="${categoryList}">
		<c:if test="${item.gubun == 'S' }">
			<c:choose>
				<c:when test="${locale == 'ko' }">
					optionS += '<option value="<c:out value="${item.scid}" />"><c:out value="${item.titleKo}" /></option>';
				</c:when>
				<c:when test="${locale == 'en' }">
					optionS += '<option value="<c:out value="${item.scid}" />"><c:out value="${item.titleEn}" /></option>';
				</c:when>
				<c:when test="${locale == 'ja' }">
					optionS += '<option value="<c:out value="${item.scid}" />"><c:out value="${item.titleJa}" /></option>';
				</c:when>
				<c:when test="${locale == 'zh' }">
					optionS += '<option value="<c:out value="${item.scid}" />"><c:out value="${item.titleZh}" /></option>';
				</c:when>
				<c:otherwise>
					optionS += '<option value="<c:out value="${item.scid}" />"><c:out value="${item.title}" /></option>';
				</c:otherwise>
			</c:choose>
		</c:if>
	</c:forEach>

	<c:forEach var="item" items="${categoryList}">
		<c:if test="${item.gubun == 'P' }">
			optionP += '<option value="<c:out value="${item.scid}" />"><c:out value="${item.title}" /></option>';
		</c:if>
	</c:forEach>
	
	function gubunReloadCal(val) {
		if (val == "") {
			$('#uniform-scid').hide();
		} else {
			$('#uniform-scid').show();
			if (val == "S") {
				$('#scid').html(optionS).uniform();
			} else if (val == "P"){
				$('#scid').html(optionP).uniform();
			}
		}
		reloadCal();
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
    margin-left: 0px;
}
.fc-widget-header font{color:#f91313;}
.fc-agenda-divider{height: auto;line-height: normal;}
</style>
</head>

<body style="margin:0px;">
<!-- Calendar Title Start -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#f7f7f7; position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
		<td width="*" style="padding-left:5px; padding-top:2px;" align="left">
			<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
			<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
				<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
				<spring:message code="sch.Calendar"/><%-- 일정관리 > --%>
				<spring:message code="sch.Individuals.a.shared.calendar"/><%-- 개인-공유일정 --%>
			</span>
			&nbsp;
			&nbsp;
			<%-- 
			<select name="gubun" class="uniform" onchange="gubunReloadCal(this.value)">
				<option value=""><spring:message code="t.all" text="전체" /></option>
				<option value="S"><spring:message code="sch.A.shared" text="공유일정" /></option>
				<option value="P"><spring:message code="sch.Personal" text="개인일정" /></option>
			</select>
			--%>
			<span id="gubun" style="font-size:11px;">
				<input onclick="gubunReloadCal(this.value)" type="radio" id="guA" name="gubun" value="" checked="checked"/>
				<label for="guA"><spring:message code="t.all" text="전체" />&nbsp;</label>
				<input onclick="gubunReloadCal(this.value)" type="radio" id="guS" name="gubun" value="S" />
				<label for="guS"><spring:message code="sch.A.shared" text="공유일정" />&nbsp;</label>
				<input onclick="gubunReloadCal(this.value)" type="radio" id="guP" name="gubun" value="P" />
				<label for="guP"><spring:message code="sch.Personal" text="개인일정" />&nbsp;</label>
			</span>
			<select name="scid" id="scid" class="uniform" onchange="reloadCal()">
				<option value=""><spring:message code="t.all" text="전체" /></option>
			</select>
		</td>
		<td width="*" align="right" style="font-size:9pt;">
			<span id="category" style="font-size:11px;">
				<input onclick="goCal(1);" type="radio" id="cat0" name="category" value="" />
				<label for="cat0"><spring:message code="sch.Integrated.schedule" text="통합일정표" />&nbsp;</label>
				<input onclick="goCal(2);" type="radio" id="cat1" name="category" value="" />
				<label for="cat1"><spring:message code="sch.Company.schedules" text="회사일정" />&nbsp;</label>
				<input onclick="goCal(3);" type="radio" id="cat2" name="category" value="" checked="checked" />
				<label for="cat2"><spring:message code="sch.Individuals.a.shared.calendar" text="개인-공유일정" />&nbsp;</label>
<!-- 				<input onclick="goCal(5);" type="radio" id="cat4" name="category" value="" /> -->
<%-- 				<label for="cat4"><spring:message code="sch.Annual.vacation.Status" text="연차-휴가현황" />&nbsp;</label> --%>
				<!-- <input onclick="goCal(4);" type="radio" id="cat3" name="category" value="" /> -->
				<%-- <label for="cat3"><spring:message code="sch.Business.tripper.status"/>출장자현황</label> --%>
				<!-- <input onclick="goCal(6);" type="radio" id="cat5" name="category" value="" /> -->
				<!-- <label for="cat5">프로젝트연차-휴가현황</label> -->
			</span>
		</td>
	</tr>
</table>
<!-- Calendar Title End -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="5"><td></td></tr></table>

<div id='calendar' style="width:85%;margin: 2% auto 0;    max-width: 1270px;"></div>

</body>
</html>