<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="main.Schedule" text="일정관리"/></title>
<script type='text/javascript' src='/common/jquery/js/jquery-1.6.4.min.js'></script>

<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/themes/sunny/jquery-ui.css" />
<script type='text/javascript' src='/common/jquery/ui/1.8.16/jquery-ui.min.js'></script>

<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.css' />
<link rel='stylesheet' type='text/css' href='/common/jquery/fullcalendar/fullcalendar.print.css' media='print' />
<script type='text/javascript' src='/common/jquery/fullcalendar/fullcalendar.js'></script>
<!-- jquery - modal -->
<script type='text/javascript' src="/common/jquery/plugins/modaldialogs.js"></script>
<!-- jquery : qTip -->
<script src="/common/jquery/plugins/jquery.qtip.min.js" type="text/javascript"></script>

<script type='text/javascript' src='/common/scripts/common.js'></script>
<script language=javascript>

	function goURL(docid){
		tmp = "_read_form";

		//document.location.href = "schedule_p_read_form.jsp?docid=" + docid;
		var url = "/schedule/schedule_p_read_form.jsp?backlist=Y&docid=" + docid ;
		url += "&opentype=none";
		OpenWindowNoScr( url, "", "755" , "610" );
		//OpenWindow( url, "", "755" , "610" );
	}

	function openURL(str, caldate){
		if(str == "today"){
			url = document.location.href;
			if(url.indexOf("month") != -1){
				str = "_month_list.jsp?caldate=" + caldate;
			}else if(url.indexOf("week") != -1){
				str = "_week_list.jsp?caldate=" + caldate;
			}else{
				str = "_day_list.jsp?caldate=" + caldate;
			}
		}else if(str == "month"){
			str = "_month_list.jsp?caldate=" + caldate;
		}else if(str == "week"){
			str = "_week_list.jsp?caldate=" + caldate;
		}else{
			str = "_day_list.jsp?caldate=" + caldate;
		}
		document.location.href = "schedule_p" + str;
	}



	//월력보기의 tooltip
function  showcalendar(sw, subject, date, content)
{	
	var text;
	text = '<div id="inn" style="position:relative; overflow:hidden; width:200px; height:110px; background-color:#FFFFE0; font-size:9pt; border-width:1px; border-color:black; border-style:solid;z-index:64 ">';
	text += '<table class="table_basic" width=200 border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFE0" STYLE="table-layout:fixed;">';
	text += '<tr><td  nowrap style="text-overflow:ellipsis; overflow:hidden;"><font color=blue>' + subject + '</font></td></tr></table></div>';
	
	if (document.body.scrollLeft+event.clientX+240 > document.body.clientWidth){
		document.all["message"].style.pixelLeft = document.body.clientWidth - 210 ;
	} else {
		document.all["message"].style.pixelLeft = document.body.scrollLeft + event.clientX +30 ;
	}
	
	if (document.body.scrollLeft+event.clientY + 120 > document.body.clientHeight){
		document.all["message"].style.pixelTop = document.body.scrollTop+event.clientY-120; 
	}else{		
		document.all["message"].style.pixelTop = document.body.scrollTop+event.clientY+10; 
	}

	message.innerHTML = text;
     if(sw == 1 ){
		document.all["message"].style.display = "";
	}else{ 
		document.all["message"].style.display = "none";
	}
}

function showscid(scid){
	form1.scid.value=scid;
	form1.submit();
}

function addZero(num) {
	//alert( num );
	num = parseInt(num);
    if(num<10) return '0'+num;
    else ''+num;
}

</script>

<style>
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
    
#tooltip{

	position:absolute;

	border:1px solid #333;

	background:#f7f5d1;

	padding:2px 5px;

	color:#333;

	display:none;

	}
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
<script type='text/javascript'>
$(document).ready(function() {
	
		$( "#category" ).buttonset();	/* radio set */
		
		var date = new Date();
		var d = date.getDate();
		var m = date.getMonth();
		var y = date.getFullYear();
		
		var calendar = $('#calendar').fullCalendar({
			theme: false,
			formatDate: "yy-mm-dd",
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
			    today: '<spring:message code="sch.Todays.schedule"/>',		// 오늘의 일정
			    month: '<spring:message code="sch.Amonthly.calendar"/>',	// 월간일정
			    week: '<spring:message code="sch.Weekly.Schedule"/>',		// 주간일정
			    day: '<spring:message code="sch.Daily.Schedule"/>'			// 일간일정
			},
			titleFormat: {
				month: 'yyyy-MM',
				week: "yyyy-MM-d{ '~' yyyy-MM-d}",
			    day: 'yyyy-MM-d-dddd'
			},
			timeFormat: {
				'': 'hh:mmTT'
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
			
			viewDisplay: function(view) {
		    },
			
			selectable: true,
			selectHelper: true,
			select: function(start, end, allDay) {
				var startdate = getDate(start);
				var enddate = getDate(end);
				var url = "/schedule/form.htm?startDate=" + startdate + "&endDate=" + enddate;
				 
				//var result = OpenModal( url , "" , 280 , 400 );
				/* result는 시작일, 종료일, 제목 */
				//OpenWindow(url, "Sche", "800", "450");
				//ModalDialog({'t':'일정 등록', 'w':800, 'h':550, 'm':'iframe', 'u':url, 'modal':true, 'd':false, 'r':false });
				calendar.fullCalendar('unselect');
				
				/*
				//var title = prompt('Event Title:');
				var title = "test calendar";
				if (title) {
					calendar.fullCalendar('renderEvent',
						{
							title: title,
							start: start,
							end: end,
							allDay: allDay
						},
						true // make the event "stick"
					);
				}				
				*/
			},
			editable: true,
			disableDragging: true,
			disableResizing: true,
			
			dayClick: function(date, allDay, jsEvent, view) {
				/*
		        if (allDay) {
		            //alert('Clicked on the entire day: ' + date);
		        }else{
		            //alert('Clicked on the slot: ' + date);
		        }
		        //alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
		        //alert('Current view: ' + view.name);
		        // change the day's background color just for fun
		        $(this).css('background-color', 'red');
		        */
		    },
    
			eventClick: function(calEvent, jsEvent, view) {
				if (calEvent.id == '0' || !calEvent.id) return;
				if (calEvent.type ) {
		        var url = "/" + calEvent.type + "/read.htm?docId=" + calEvent.id;
		        
				OpenWindow(url, "<spring:message code='sch.lookup' text='일정조회' />", "800", "450");
		        //ModalDialog({'t':'일정 조회', 'w':800, 'h':550, 'm':'iframe', 'u':url, 'modal':true, 'd':false, 'r':false });
				//var result = OpenModal( url , "" , 800 , 500 );
				}
		    },
			eventRender: function(event, element, view)   {
				if (event.id == '0') return;
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
					hide: {when:'mouseout', fixed:true, delay:50}
				});
				
				if( event.style == 1 ) {
					element.find(".fc-event-inner").css("color", "#000" );
					element.find(".fc-event-inner").css("background-color", "#fff" );
					element.find(".fc-event-inner").css("font-weight", "bold" );
				} else if( event.style == 2 ) {
					element.find(".fc-event-inner").css("background-color", "#fff" );
					element.find(".fc-event-inner").css("color", "blue" );
					element.find(".fc-event-inner").css("font-weight", "bold" );
				} else if( event.style == 3 ) {
					element.find(".fc-event-inner").css("color", "red" );
					element.find(".fc-event-inner").css("background-color", "#fff" );
					element.find(".fc-event-inner").css("border-width", "1px" );
					element.find(".fc-event-inner").css("font-weight", "bold" );
					element.find(".fc-event-inner").css("border-color", "red" );
				}
				
				//element.find(".fc-event-inner").css("background-color", "#fff" );
				//element.find(".fc-event-time").html("<img align='absmiddle' src=\"/common/images/icons/approual_icon_" + event.style + ".jpg\" />");
				//element.find(".fc-event-time").html("");
				
		    },

			/*
			eventColor: '#378006',
			eventBackgroundColor: '',
			eventBorderColor: '',
			eventTextColor: 'blue',
			*/

			//start=1319900400&end=1323529200&_=1321270106013
			//eventRender: function(event, element) {
		     //   element.qtip({
		      //      content: event.description
		       // });
		    //},
		    //공휴일
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
			    /* 회사일정 */
				{
					events: function(start, end, callback) {
						var start = getDate($('#calendar').fullCalendar('getView').visStart);
						var end = getDate($('#calendar').fullCalendar('getView').visEnd);
						var bgColor = ["","#9b6e38","#98fb98","#cc3366"];
						var txColor = ["","#FFF","#333","#FFF"];
						$.ajax({
							url: "/schedule/corpschedule_calendar_json.htm?start="+start+"&end="+end,
// 						    url: '/schedule/corpschedule_list_json.jsp?start=' + start + '&end=' + end,
						    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
						    type: 'POST',
						    dataType: 'json',
						    success: function(data, text, request) {
						    	//var events = eval(data.jsonTxt);
						    	var events = data;
						    	
						    	//var events = eval(data.jsonTxt);
						    	//events = data;
						    	var eno = events.length;
						    	for(var i = 0; i < eno; i++) {
					    			var evt = data[i];
					    			var s = stringToDate(evt.start.split(" ")[0]);
					    			var e = stringToDate(evt.end.split(" ")[0]);

					    			while (s <= e ) {
										events.push({
											id: evt.id ,
											title: evt.title ,
											start: getDate(s) + " " + new String((evt.start.split(" ")[0] != getDate(s)) ? "15:30:00": evt.start.split(" ")[1]),//new Date( s.valueOf() ),
											end: getDate(s) + " " + new String((evt.end.split(" ")[0] != getDate(s)) ? "17:30:00": evt.end.split(" ")[1]),
											descript: evt.descript,
											backgroundColor: bgColor[evt.style || 0],
											textColor: txColor[evt.style || 0],
											allDay: true
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
				    //color: '#e84d11',   // an option!
// 				    color: '#8B0000',   // an option!
// 				    textColor: '#fff', // an option!
// 				    borderColor: "#000"
// 					textColor: "#FFF",
				    borderColor: "#888"
				},

				/* 일정관리 */
				{
				    events : MyEvents ,
				    //events : HoliEvents ,
				    //color: '#85b5d9',   // an option!
// 					textColor: '#fff' // an option!
					//borderColor: '#3366cc'
				    color: '#3366cc',
				    textColor: '#FFF',
				    borderColor: "#888"
				},
				
			]

		});
				
		// 김정국 추가
		function stringToDate( strDate ) {
			var a = strDate.split("-");
			var date1 = new Date(a[0], a[1]-1, a[2], 00, 00, 00, 00);
			//alert( date1 );
			//var a = date1.setFullYear(strDate);
			//alert( a );
			return date1;
		}
		
		// 김정국 추가
		function stringToDateFull( strDate ) {
			//yy-mm-dd hh:mm:AM PM 형태
			var i = strDate.split(" ");
			//alert( i);
			var a = i[0].split("-");
			var b = i[1].split(":");
			//alert( a + "\n" + b);
			//if ( b[2] == "PM") b[0] = b[0] + 12; 
			var date1 = new Date(a[0], a[1]-1, a[2], b[0], b[1], 00, 00 );
			
			//alert( date1 );
			//var a = date1.setFullYear(strDate);
			//alert( a );
			return date1;
		}
		
		function MyEvents(start,end, callback) {
			var fc_start = getDate($('#calendar').fullCalendar('getView').start);
			var fc_end = getDate($('#calendar').fullCalendar('getView').end);
			$.ajax({
			    url: './calendar_json.htm?startDate=' + fc_start + '&endDate=' + fc_end,
			    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
			    type: 'POST',
			    dataType: 'json',
			    success: function(data, text, request) {
			    	//document.write(events.length);
			    	//for(i in data) events.push(data[i]);
			    	events = data;
			    	//alert( "전체 Event 수 : " + events.length );
			    	var eno = events.length;
			    	for ( var i = 0; i < eno; i++ ) {
			    		if ( data[i].repeatType == '0' ) {
			    			
			    			/* 개인.공유일정의 연속일정을 독립일정으로 변경 */
			    			var evt = data[i];
			    			var s = stringToDate(evt.start.split(" ")[0]);
			    			var e = stringToDate(evt.end.split(" ")[0]);

			    			while (s <= e ) {
								events.push({
									id: evt.id ,
									title: evt.title ,
									start: getDate(s) + " " + new String((evt.start.split(" ")[0] != getDate(s)) ? "08:30:00": evt.start.split(" ")[1]),//new Date( s.valueOf() ),
									end: getDate(s) + " " + new String((evt.end.split(" ")[0] != getDate(s)) ? "17:30:00": evt.end.split(" ")[1]),
									descript: evt.descript,
									allDay: false
								});
								s.setDate(s.getDate() + 1 );
			    			}
			    			
			    			data.splice(i,1);
							--eno;
							--i;
							
			    		} else {
			    			var evt = data[i];
							
			    			var a = evt.start.split(" ");
			    			var b = evt.end.split(" ");
			    			var s = stringToDate( a[0] );
			    			var e = stringToDate( b[0] );
			    			
			    			var s = stringToDateFull( evt.start );
			    			var e = stringToDateFull( evt.end );
			    			
			    			//alert( s + "\n" + e);
			    			//var events = [];
			    			// 시작일의 월요일
			    			var rtype = evt.repeattype;
			    			if ( rtype == "1" ) {
				    			while (s <= e ) {
									events.push({
										id: evt.id ,
										title: evt.title ,
										start: new Date( s.valueOf() ),
										descript: evt.descript,
										allDay: false
									});
									s.setDate(s.getDate() + parseInt( evt.repeatday ) );
				    			}
			    			} else if ( rtype == "2" ) {
			    				// 시작시점의 첫째주 부분은 제외 해야 함...
			    				var sDay = s.setDate((s.getDate() - s.getDay()) + 0);
				    			while (s <= e ) {
			    					//주단위 반복의 해당 요일이 맞는지 확인... repeatweek = 0,1,2,3...
				    				var rweek = parseInt( evt.repeatweek );
				    				//일주일씩 루핑돌면서 해당 요일이 맞는지 확인해서 추가 해야 함.
				    				for( var j = 0; j < 7; j++ ) {
				    					if ( rweek == j ) {
				    						
				    						var vdate = new Date( s );
				    						vdate.setDate( vdate.getDate() + j );
				    						//alert( vdate.getDate() );
					    					events.push({
												id: evt.id ,
												title: evt.title ,
												start: new Date( vdate.valueOf() ),
												descript: evt.descript,
												allDay: false
											});
				    					}
				    				}
				    				s.setDate(s.getDate() + 7 );	//일주일 증가
								}
			    			} else {
			    				//월간 단위 일정
			    				//s.setDate(1);
			    				
				    			while (s <= e ) {
			    					//주단위 반복의 해당 요일이 맞는지 확인... repeatmonth = 0,1,2,3...
				    				var rmonth = parseInt( evt.repeatmonth );
				    				//한달동안 루핑돌면서 해당 일자가  맞는지 확인해서 추가 해야 함.
				    				for( var j = 1; j < 30; j++ ) {
				    					if ( rmonth == j ) {
				    						//alert( rmonth + "/" + j);
				    						s.setDate( j );
					    					events.push({
												id: evt.id ,
												title: evt.title ,
												start: new Date( s.valueOf() ),
												descript: evt.descript,
												allDay: false
											});
				    					}
				    				}
				    				s.setMonth( s.getMonth() + 1 );	//한달 증가
								}
			    			}
			    			// long event removed option
			    			data.splice(i,1);
							--eno;
							--i;
			    		}
			    	}
			    	//alert( "기본 Event 수 : " + eno + "\n이후 Event 수 : " + events.length );
			    	var str = "";
			    	for( var i=0; i < events.length; i++ ) {
			    		str += " | " + events[i].start;
			    	}
			    	
			    	//HoliEvents(start, end, callback, events);
			    	//alert( str );
					callback(events);

			    }
				
			});
		}
		
		function HoliEvents(start, end, callback, events) {
			var fc_start = getDate($('#calendar').fullCalendar('getView').start);
			var fc_end = getDate($('#calendar').fullCalendar('getView').end);
			$.ajax({
			    url: './holiday_json.htm?startDate=' + fc_start + '&endDate=' + fc_end,
			    type: 'POST',
			    dataType: 'json',
			    success: function(data, text, request) {
			    	for(var i in data) {
	                    events.push({
	                    	id: '0',
	                        title: data[i].title,
	                        start: data[i].start,
	                        backgroundColor: (data[i].isfreeday == "1") ? "#f05e25" : "#5d25f0"
	                    });
			    	}
					callback(events);
			    }
			});
		}
		
		$( "button", "#action" ).button();
});
 

//휴가, 출장 일 경우 시간 없애는 부분 임 - 안먹힘.
function timeHidden() {
	$('span fc-event-title').each( function() {
		alert();
		var text=$(this).text();
		if ( text.indexOf("[휴가]") > -1 || text.indexOf("[출장]") > -1 ) {
			$('span fc-event-time').html("");
		} else {
		}
	});
}

</script>

<style type='text/css'>
	.fc-event-time {
		  display: none;
	}
</style>

<script>
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
function newdoc(startdate, enddate) {
	startdate = getDate();
	enddate = getDate();
	
	var url = "/schedule/form.htm?&startDate=" + startdate + "&endDate=" + enddate;
	OpenWindow(url, "<spring:message code='sch.Schedule.Registration' text='일정등록' />", "800", "450");
	//ModalDialog({'t':'일정등록', 'w':800, 'h':550, 'm':'iframe', 'u':url, 'modal':true, 'd':false, 'r':false });
}

function goCal(args) {
	var url = "";
	if( args == 1) {
		url = "/schedule/calendarall.htm";
	} else if ( args == 2 ) {
		url = "/schedule/corpschedule_calendar.htm";
	} else if ( args == 3 ) {
		url = "/schedule/calendar.htm";
	} else if ( args == 4 ) {
		url = "/trip/calendar.jsp";
	} else if ( args == 5 ) {
		url = "/vacation/calendar.jsp";
	} else if ( args == 6 ) {
		url = "/project/calendar.htm";
	}
	self.location = url;
}
</script>
</HEAD>

<body onload="timeHidden();" style="margin:0px;">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#f7f7f7; position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="40%" style="padding-left:5px; padding-top:2px; ">
	<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
	<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
	<spring:message code="sch.Calendar"/><%-- 일정관리 > --%> 
	<spring:message code="sch.Integrated.schedule"/><%-- 개인-공유일정 --%>
	</span>
</td>
<td width="*" align="right" style="font-size:9pt;">

<!-- <span class="fc-button fc-button-month fc-state-default fc-corner-left fc-state-active"><span class="fc-button-inner"><span class="fc-button-content">월간일정</span><span class="fc-button-effect"><span></span></span></span></span><span class="fc-button fc-button-agendaWeek fc-state-default"><span class="fc-button-inner"><span class="fc-button-content">주간일정</span><span class="fc-button-effect"><span></span></span></span></span><span class="fc-button fc-button-agendaDay fc-state-default fc-corner-right"><span class="fc-button-inner"><span class="fc-button-content">일간일정</span><span class="fc-button-effect"><span></span></span></span></span> -->

	<span id="category" style="font-size:11px;">
<!-- 		<input onclick="goCal(1);" type="radio" id="cat0" checked="checked" name="category" value="" /> -->
<!-- 		<label for="cat0">통합일정표</label> -->
<!-- 		<input onclick="goCal(2);" type="radio" id="cat1" name="category" value="" /> -->
<!-- 		<label for="cat1">회사일정</label> -->
<!-- 		<input onclick="goCal(3);" type="radio" id="cat2" name="category" value="" /> -->
<!-- 		<label for="cat2">개인.공유일정</label> -->
<!-- 		<input onclick="goCal(4);" type="radio" id="cat3" name="category" value="" /> -->
<!-- 		<label for="cat3">출장자현황</label> -->
<!-- 		<input onclick="goCal(5);" type="radio" id="cat4" name="category" value="" /> -->
<!-- 		<label for="cat4">연차.휴가현황</label> -->
<!-- 		<input onclick="goCal(6);" type="radio" id="cat5" name="category" value="" /> -->
<!-- 		<label for="cat5">프로젝트</label> -->

		<input onclick="goCal(1);" type="radio" id="cat0" name="category" value="" checked="checked" />
		<label for="cat0"><spring:message code="sch.Integrated.schedule" text="통합일정표" />&nbsp;</label>
		<input onclick="goCal(2);" type="radio" id="cat1" name="category" value="" />
		<label for="cat1"><spring:message code="sch.Company.schedules" text="회사일정" />&nbsp;</label>
		<input onclick="goCal(3);" type="radio" id="cat2" name="category" value="" />
		<label for="cat2"><spring:message code="sch.Individuals.a.shared.calendar" text="개인-공유일정" />&nbsp;</label>
<!-- 		<input onclick="goCal(5);" type="radio" id="cat4" name="category" value="" /> -->
<%-- 		<label for="cat4"><spring:message code="sch.Annual.vacation.Status" text="연차-휴가현황" />&nbsp;</label> --%>
		
<!-- 		<input onclick="goCal(4);" type="radio" id="cat3" name="category" value="" /> -->
<%-- 		<label for="cat3"><spring:message code="sch.Business.tripper.status" text="출장자현황" /></label> --%>
	</span>
</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<div id='calendar' style="width:85%;margin: 2% auto 0;    max-width: 1270px;"></div>

</BODY>

</HTML>