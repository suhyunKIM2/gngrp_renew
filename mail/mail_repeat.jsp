<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ include file="../common/usersession.jsp"%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Repeat</title>
	<link rel=stylesheet type="text/css" href="<%=cssPath %>/write.css" />
	<link rel="stylesheet" type="text/css" href="<%=imgCssPath %>" />
	<script src="<%=scriptPath %>/common.js"></script>
	<script src="<%=scriptPath %>/autocomplete.js"></script>
	<script src="<%=scriptPath %>/DatePicker.js"></script>
	<script src="<%=scriptPath %>/xmlhttp.vbs" type="text/vbscript"></script>
	<script src="/common/jquery/js/jquery-1.6.4.min.js"  type="text/javascript"></script>
	<script type="text/javascript">
	
		var ab = ['days', 'weeks', 'months', 'years']
		
		function frequency(select) {
			var code = select.options[select.selectedIndex].value;
			$("#frequency_nm").text(ab[select.selectedIndex]);
			switch(code) {
				case '0' : 
					$("#r_").html($("#dodays").html());
					break;
				case '1' : 
					$("#r_").html($("#doweeks").html());
					break;
				case '2' :
					$("#r_").html($("#domonths").html() + "&nbsp; &nbsp;" + $("#dodays").html()); 
					break;
				case '3' :
					$("#r_").html($("#doyears").html() + " - " + $("#domonths").html() + "&nbsp; &nbsp;" + $("#dodays").html());  
					break;
			}
		}

		function stringToDate(strDate, option) {
			var a = strDate.split("-");
			var b = [0,0,0,0]; 
			if (option == "end") b = [23,59,59,9]
			return new Date(a[0], a[1]-1, a[2], b[0], b[1], b[2], b[3]);
		}
		
		function getDate(args) {
			if (!args) args = new Date();
			var today = new Date(args);
			var y = today.getFullYear();
			var m = today.getMonth()+1;
			var d = today.getDate();
			var h = today.getHours();
			
			if(m < 10) m = "0" + m;
			if(d < 10) d = "0" + d;
			if(h < 10) h = "0" + h;
			
			var strDate = y + "-" + m + "-" + d + " " + h;
			return strDate;
		}
		
		Date.prototype.addYears = function(years) { this.setFullYear(this.getFullYear() + years); }
		Date.prototype.addMonths = function(months) { this.setMonth(this.getMonth() + months); }
		Date.prototype.addWeeks = function(days) { this.setDate(this.getDate() + days * 7); }
		Date.prototype.addDays = function(days) { this.setDate(this.getDate() + days); }
		Date.prototype.addHours = function(hours) { this.setHours(this.getHours() + hours); }
		Date.prototype.addMinutes = function(minutes) { this.setMinutes(this.getMinutes() + minutes); }
		Date.prototype.addSeconds = function(seconds) { this.setSeconds(this.getSeconds() + seconds); }
		Date.prototype.addMilliseconds = function(milliseconds) { this.setMilliseconds(this.getMilliseconds() + milliseconds); }
		Number.prototype.digits2 = function() { var s = (this < 10) ? "0" + this: this; return s; }
		
		function done() {
			var st = $("input[name=startDate]").val();
			var ed = $("input[name=endDate]").val();
			
			var st_date = stringToDate(st);
			var ed_date = stringToDate(ed, "end");
			if (st_date.getTime() > ed_date.getTime()) { alert("종료일이 시작일보다 작습니다."); return; }
			
			var frequency = $("select[name=frequency]").val();
			var interval = parseInt($("select[name=interval]").val());
			var count = 0;
						
			while(st_date.getTime() < ed_date.getTime()) {
				log(getDate(st_date));
				switch(frequency) {
					case '0' : st_date.addDays(interval); break;
					case '1' : st_date.addWeeks(interval); break;
					case '2' : st_date.addMonths(interval); break;
					case '3' : st_date.addYears(interval); break;
				}
				count++;
			}
			log(count);
		}
		
		function log() {
			for (var i = 0; i < arguments.length; i++) {
				$("#consol").append("<span>"+arguments[i]+"</span><br/>");
			}
		}
	</script>
</head>
<body>
	<table border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="80" class="td_le1">Repeats</td>
			<td class="td_le2">
				<select name="frequency" onchange="frequency(this)">
					<option value="0" selected>Daily</option>
					<option value="1">Weekly</option>
					<option value="2">Monthly</option>
					<option value="3">Yearly</option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="td_le1">Repeat every</td>
			<td class="td_le2">
				<select name="interval">
					<% for(int i = 1; i <= 30; i++) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
				</select>
				<span id="frequency_nm">days</span>
			</td>
		</tr><!-- do m/w repeat by -->
		<tr>
			<td class="td_le1">Repeat on</td>
			<td class="td_le2" id="r_">
				<select name="dohours">
					<% for(int i = 0; i <= 23; i++) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
				</select>
				:
				<select name="dominutes">
					<% for(int i = 0; i < 60; i = i + 10) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
				</select>
			</td>
		</tr>
		<tr>
			<td class="td_le1">Starts On</td>
			<td class="td_le2">
				<input type="text" name="startDate" size="10" onfocus="ShowDatePicker()" onclick="ShowDatePicker()" readonly="readonly" />
			</td>
		</tr>
		<tr>
			<td class="td_le1">Ends On</td>
			<td class="td_le2">
				<input type="text" name="endDate" size="10" onfocus="ShowDatePicker()" onclick="ShowDatePicker()" readonly="readonly" />
			</td>
		</tr>
	</table>
	
	<table><tr><td class=tblspace09></td></tr></table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="*">&nbsp;</td>
			<td width="60" style="text-align: right;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="done()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;Done&nbsp;</span></td>
						<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			<td width="6">&nbsp;</td>
			<td width="60" style="text-align: right;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="self.close()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;Cancel&nbsp;</span></td>
						<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
	<div id="doyears" style="display:none">
		<select name="domonth">
			<% for(int i = 1; i <= 12; i++) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
		</select>
	</div>
	
	<div id="domonths" style="display:none">
		<select name="dodays">
			<% for(int i = 1; i <= 31; i++) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
		</select>
	</div>
	
	<div id="dodays" style="display:none">
		<select name="dohours">
			<% for(int i = 0; i <= 23; i++) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
		</select>
		:
		<select name="dominutes">
			<% for(int i = 0; i < 60; i = i + 10) out.println("<option value=\""+i+"\">"+i+"</option>"); %>
		</select>
	</div>
	
	<div id="doweeks" style="display:none">
		<input type="checkbox" name="doweek" value="1" />M
		<input type="checkbox" name="doweek" value="2" />T
		<input type="checkbox" name="doweek" value="3" />W
		<input type="checkbox" name="doweek" value="4" />T
		<input type="checkbox" name="doweek" value="5" />F
		<input type="checkbox" name="doweek" value="6" />S
		<input type="checkbox" name="doweek" value="0" />S
	</div>
	
	<div id="consol"></div>
	
</body>
</html>