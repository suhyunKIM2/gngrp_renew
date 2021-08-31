<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="nek.fixtures.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.util.Convert" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/common/usersession.jsp"%>
<%
	String categoryId = Convert.nullCheck(request.getParameter("categoryId"));		// 카테고리ID

	// 카테고리
	ArrayList<FixturesCategoryItem> clist = null;
	FixturesCategoryList categoryDoc = null;
	try{
		categoryDoc = new FixturesCategoryList();
		categoryDoc.getDBConnection();
		clist = categoryDoc.getCategoryListFixtures();
	} finally { if (categoryDoc != null) categoryDoc.freeDBConnection(); }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
	<title>출장일정</title>
	<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/sunny/jquery-ui.css" />
	<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.css' />
	<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.print.css' media='print' />
	<link rel="stylesheet" href="/common/css/style.css">
	<script type='text/javascript' src='/common/jquery/js/jquery-1.6.4.min.js'></script>
	<script type='text/javascript' src='/common/jquery/ui/1.8.16/jquery-ui.min.js'></script>
	<script type='text/javascript' src='/common/jquery/fullcalendar/fullcalendar.min.js'></script>
	<script type='text/javascript' src="/common/jquery/plugins/modaldialogs.js"></script>
	<script src="/common/jquery/plugins/jquery.qtip.min.js" type="text/javascript"></script>
	<script type='text/javascript' src='/common/scripts/common.js'></script>
	<style type="text/css">
	.fc-event, .fc-agenda .fc-event-time, .fc-event a {
	    background-color: black; /* background color */
	    border-color: black;     /* border color */
	    color: red;              /* text color */
	}
	.ui-widget-header { font-family:Gulim; font-size:10pt; padding:5px; }
	.holiday, .fc-agenda .holiday .fc-event-time, .holiday a {
	    background-color: green; /* background color */
	    border-color: green;     /* border color */
	    color: yellow;           /* text color */
	}
	#tooltip { position:absolute; border:1px solid #333; background:#f7f5d1; padding:2px 5px; color:#333; display:none; }
	.fc-event-time { display: none; }
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
	<script type="text/javascript">
		var categoryId = "<%=categoryId %>";
		
		$(document).ready(function() {
			$("input[name=category][value="+categoryId+"]").prop('checked', true);
			$(".buttonset").buttonset();
	
			var calendar = $('#calendar').fullCalendar({
				theme: false,
				// Utilities
				formatDate: "yyyy-mm-dd",
				header: {
					left: 'prev,next today',
					center: 'prev,title,next',
					right: 'month,agendaWeek,agendaDay'
				},
				buttonText: {
				    prev:     '&nbsp;&#9668;&nbsp;',  // left triangle
				    next:     '&nbsp;&#9658;&nbsp;',  // right triangle
				    prevYear: '&nbsp;&lt;&lt;&nbsp;', // <<
				    nextYear: '&nbsp;&gt;&gt;&nbsp;', // >>
// 				    today:    '오늘의 일정',
// 				    month:    '월간현황',
// 				    week:     '주간현황',
// 				    day:      '일간현황'
				    today: '<fmt:message key="sch.Todays.schedule"/>',		// 오늘의 일정
				    month: '<fmt:message key="sch.Amonthly.calendar"/>',	// 월간일정
				    week: '<fmt:message key="sch.Weekly.Schedule"/>',		// 주간일정
				    day: '<fmt:message key="sch.Daily.Schedule"/>'			// 일간일정
				},
				titleFormat: {

					month: 'yyyy-MM',
					week: "yyyy-MM-d{ '~' yyyy-MM-d}",
				    day: 'yyyy-MM-d-dddd'
// 					month: 'yyyy년 MM월',                             // September 2009
// 				    //week: "yyyy년 MM월 d일 - (d[ yyyy]주) ", // Sep 7 - 13 2009
// 					week: "yyyy년 MM월 d[ yyyy]일{ '~'[ MMM] d일}",
// 				    day: 'yyyy년 MM월 d일 dddd'                  // Tuesday, Sep 8, 2009
				},
				monthNames: ['1 ', '2 ', '3 ', '4 ', '5 ', '6 ', '7 ', '8 ', '9 ', '10 ', '11 ', '12 '],
				monthNamesShort: [],
				dayNames: ['<font color=\'red\'><fmt:message key="sch.Sunday"/></font>',	// 일요일
				           '<fmt:message key="sch.Monday"/>',								// 월요일
				           '<fmt:message key="sch.Tuesday"/>',								// 화요일
				           '<fmt:message key="sch.Wednesday"/>',							// 수요일
				           '<fmt:message key="sch.Thursday"/>',								// 목요일
				           '<fmt:message key="sch.Friday"/>',								// 금요일
				           '<fmt:message key="sch.Saturday"/>'],							// 토요일
	           dayNamesShort: ['<font color=\'red\'><fmt:message key="sch.Sunday"/></font>',
				           '<fmt:message key="sch.Monday"/>',
				           '<fmt:message key="sch.Tuesday"/>',
				           '<fmt:message key="sch.Wednesday"/>',
				           '<fmt:message key="sch.Thursday"/>',
				           '<fmt:message key="sch.Friday"/>',
				           '<fmt:message key="sch.Saturday"/>'],
				allDaySlot: false,
				viewDisplay: function(view) {},
				selectable: true,
				selectHelper: true,
				select: function(start, end, allDay) {
					var startdate = getDate(start);
					var enddate = getDate(end);
					var url = "/fixtures/list.jsp?startdate=" + startdate + "&enddate=" + enddate;
					OpenWindow(url, "Fixtures", "800", "500");
					//ModalDialog({'t':'출장등록', 'w':800, 'h':550, 'm':'iframe', 'u':url, 'modal':true, 'd':false, 'r':false });
					calendar.fullCalendar('unselect');
				},
				editable: true,
				disableDragging: true,
				disableResizing: true,
				dayClick: function(date, allDay, jsEvent, view) {},
				eventClick: function(calEvent, jsEvent, view) {
					if (!calEvent.id) return;
			        var url = "/fixtures/userBooking.jsp?docId=" + calEvent.id+"&sno="+calEvent.sno+"&listBtn=N";
			        var result = OpenWindow(url, "Fixtures", "800", "420");
					//var result = OpenModal( url , "Fixtures" , 800 , 500 );
					if (result) window.location.reload();
			    },
				eventRender: function(event, element, view)   {
					element.qtip({
							content: event.descript,
							style: {width:300,padding:3,background:'#fff',color:'#FFF','font-size':'11px','z-index':'500',
							textAlign: 'left',
							border: {width:3,radius:5,color:'#72a9d3'},
							tip: 'bottomLeft',
							name: 'dark' // Inherit the rest of the attributes from the preset dark style
						},
						position: {
							corner: {target:'topMiddle', tooltip:'bottomLeft'},
							adjust: {screen:true}
						},
						hide: {when:'mouseout', fixed:true, delay:100}
					});
			    },
				/*
				eventColor: '#378006',
				eventBackgroundColor: '',
				eventBorderColor: '',
				eventTextColor: 'blue',
				*/
				eventSources: [
					{
						color: 'red', textColor: '#fff', borderColor: "#000",
						events: function(start, end, callback) {
							var start = getDate($('#calendar').fullCalendar('getView').start);
							var end = getDate($('#calendar').fullCalendar('getView').end);
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
					},
					{
						events: function(start, end, callback) {
							var start = getDate($('#calendar').fullCalendar('getView').start);
							var end = getDate($('#calendar').fullCalendar('getView').end);
							//var cId = document.getElementByName("category"); //카테고리 ID
							$.ajax({
							    //url: '/fixtures/data/carlendar_json.jsp?start=' + start + '&end=' + end + '&categoryId=' + "2012030709241425",
							    //url: '/fixtures/data/calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
							    url: '/fixtures/data/carlendar_json.jsp?start=' + start + '&end=' + end + '&categoryId=' + categoryId,
							    type: 'POST',
							    dataType: 'json',
							    success: function(data, text, request) {
							    	//var events = eval(data.jsonTxt);
							    	events = data;
							    	var eno = events.length;
							    	
							    	for(var i = 0; i < eno; i++) {
						    			var evt = data[i];
						    			var s = stringToDate(evt.start.split(" ")[0]);
						    			var e = stringToDate(evt.end.split(" ")[0]);
						    			
						    			while (s <= e ) {
						    				var stime = (evt.start.split(" ")[0] != getDate(s)) ? "08:30:00": evt.start.split(" ")[1];
						    				var etiem = (evt.end.split(" ")[0] != getDate(s)) ? "17:30:00": evt.end.split(" ")[1];
											events.push({
												id: evt.id ,
												title: evt.title ,
												start: getDate(s) + " " + stime,	//new Date( s.valueOf() ),
												end: getDate(s) + " " + etiem,
												descript: evt.descript,
												allDay: false,
												sno: evt.sno,			//비품예약 일련번호
												backgroundColor: (evt.rentFlag) ? '#FF6633': '#3366cc'
											});
											s.setDate(s.getDate() + 1 );
						    			}
						    			data.splice(i,1);
										--eno;
										--i;
							    	}
							        callback(events);
							    }
							});
						},
					    color: '#3366cc',   // an option!
					    textColor: '#fff' // an option!
					}
				]
	
			});
			//$('#calendar').fullCalendar('refetchEvents');
			
		});

		// 김정국 추가
		function stringToDate( strDate ) {
			var a = strDate.split("-");
			var date1 = new Date(a[0], a[1]-1, a[2], 00, 00, 00, 00);
			return date1;
		}
		
		function getDate( args ) {
			if ( !args ) {
				args = new Date();
			}
			var today = new Date( args );
			var y = today.getFullYear();
			var m = today.getMonth()+1;
			var d = today.getDate();
			
			if( m < 10) m = "0" + m;
			if(d < 10) d = "0" + d;
			
			var strDate = y + "-" + m + "-" + d;
			return strDate;
		}
		
		function search() {
			var url = "/fixtures/calendar.jsp?categoryId=" + $('input[name=category]:checked').val();
			self.location = url; 
		}
	</script>
</head>
<body>
	<!-- Title Start -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#f7f7f7; position:relative; lefts:-1px; height:37px; z-index:100;">
		<tr>
			<td width="50%" style="padding-left:5px; padding-top:5px;text-align: left; ">
				<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
				<span class="ltitle">
					<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> 
					<fmt:message key="main.Rent.Management"/><!-- 대여관리 --> &gt; 
					<fmt:message key="book.book.state"/><!-- 예약현황 -->
					- 
					<fmt:message key="t.calendar"/><!-- 캘린더 -->
				</span>
			</td>
			<td width="50%" align="right">
				<div class="buttonset" style="float: right;margin-left:6px;margin-right:6px;">
					<%	for(int i = 0, len = clist.size(); i < len; i++) {
							FixturesCategoryItem citem = (FixturesCategoryItem)clist.get(i);
							out.println("<input type=\"radio\" name=\"category\" id=\"cat"+(i+1)+"\" onclick=\"search();\" value=\""+citem.getCategoryId()+"\" />");
							out.println("<label for=\"cat"+(i+1)+"\">"+citem.getCategoryName(loginuser.locale)+"</label>");
						}
					%>
				</div>
				<div class="buttonset" style="float: right;margin-left:6px;margin-right:6px;">
					<input type="radio" name="category" id="cat0" onclick="search();" value="" />
					<label for="cat0"><fmt:message key="poll.view.all"/><!-- 전체보기 --></label>
				</div>
			</td>
		</tr>
	</table>
	<!-- Title End -->

	<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="5"><td></td></tr></table>

	<div id='calendar' style="width:85%;margin: 2% auto 0;    max-width: 1270px;"></div>
</body>
</fmt:bundle>
</html>