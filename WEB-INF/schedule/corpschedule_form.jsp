<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="nek3.domain.schedule.CorpSchedule" %>
<%@ page import="nek3.domain.schedule.ScheCategory" %>
<%
	String locale = (String) request.getAttribute("locale");
	CorpSchedule corpSchedule = (CorpSchedule) request.getAttribute("corpSchedule");
%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="main.Company.Schedule" text="회사일정" /></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<script type="text/javascript">
$(document).ready(function() {

	$("select[name='gubun'] > option[value='${corpSchedule.gubun }']").attr("selected", "selected");
	$("select[name='stype'] > option[value='${corpSchedule.stype }']").attr("selected", "selected");
	
	$("input[name='startdate'], input[name='enddate']").datepicker({
		showAnim: "slide",
		showOptions: { origin: ["top", "left"] },
		monthNamesShort: ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"],
		dayNamesMin: ["일", "월", "화", "수", "목", "금", "토"],
		dateFormat: "yy-mm-dd",
		buttonText: "Calendar",
		prevText: "이전달",
		nextText: "다음달",
		changeMonth: true,
		changeYear: true,
		showOtherMonths: true,
		selectOtherMonths: true,
		onClose : function(selectedDate) {
			if ($(this).attr("name") == "startdate") {
				$("input[name='enddate']").datepicker("option", "minDate", selectedDate );
			} else if ($(this).attr("name") == "enddate") {
				$("input[name='startdate']").datepicker("option", "maxDate", selectedDate);
			}
		}
	});
});

function goSubmit(cmd) {
	var subject = $("input[name='subject']");
	if ($.trim(subject.val()) == "") {
		alert("<spring:message code='sch.enter.title' text='제목을 입력해 주세요' />");
		subject.focus();
		return;
	}

	if ($("input[name='startdate']").val() == "" || $("input[name='enddate']").val() == "") {
		alert("<spring:message code='sch.c.enter.dates' text='날짜를 입력해 주세요.' />");
		return;
	}
	
	var msg = "<spring:message code='c.save' text='저장 하시겠습니까?' />";
	if (!confirm(msg)) return;
	
	$("#submitForm").submit();
}
</script>
</head>
<body>

<!-- Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#f7f7f7; position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr height="26">
		<td width="60%" style="padding-left:10px;">
			<span class="ltitle">
				<img src="/common/images/icons/icon_inquiry.jpg" border="0" align="absmiddle">
				<spring:message code="main.Company.Schedule" text="회사일정" />
			</span>
		</td>
		<td width="40%" align="right">
		</td>
	</tr>
</table>
<!-- Title -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="4"><td></td></tr></table>

<!-- Button -->	
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
	<tr height="35">
		<td width="10"><img src="../common/images/bar_left.gif" border="0"></td>
		<td width="*" style="padding-left:5px; background-image: url(../common/images/bar_bg.gif); background-repeat: repeat-x;" align="left">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-top: -3px;;padding:0;">
				<tr>
					<td width="*" align="right">
						<a onclick="goSubmit()" class="button gray medium">
						<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.save" text="저장" /></a>
						<a onclick="closeDoc()" class="button white medium">
						<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.close" text="닫기" /></a>
					</td>
				</tr>
			</table>
		</td>
		<td width="10"><img src="../common/images/bar_right.gif" border="0"></td>
	</tr>
</table>
<!-- Button -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="4"><td></td></tr></table>

<!-- Form -->
<form id="submitForm" name="submitForm" method="post" action="/schedule/corpschedule_save.htm">
<input type="hidden" name="docid" value="${corpSchedule.docid }">

<div class="space"></div>
<div class="hr_line">&nbsp;</div>
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<colgroup>
		<col width="100">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code="t.division" text="구분" /></td>
		<td class="td_le2">
			<select name="stype">
			<c:forEach items="${sCategoryList }" var="item">
				<% ScheCategory item = (ScheCategory) pageContext.getAttribute("item"); %>
				<option value="${item.scid }"><%=item.getTitle(locale) %></option>
			</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code="sch.central" text="본부" /></td>
		<td class="td_le2">
			<select name="gubun">
			<c:forEach items="${sDepartmentList }" var="item">
				<option value="${item.dpId }">${item.dpName }</option>
			</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code="t.subject" text="제목" /></td>
		<td class="td_le2">
			<input type="text" name="subject" style="width:90%;" maxlength="30" value="${corpSchedule.subject }" />
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code="mail.contents" text="내용" /></td>
		<td class="td_le2">
			<textarea name="contents" style="width:90%;" maxlength="1000">${corpSchedule.contents }</textarea>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code="t.schedule" text="일정" /></td>
		<td class="td_le2">
			<input type="text" name="startdate" style="width:75px;" maxlength="10" value="${corpSchedule.startdate }"> - 
			<input type="text" name="enddate" style="width:75px;" maxlength="10" value="${corpSchedule.enddate }">
		</td>
	</tr>
</table>

</form>
<!-- Form -->

</body>
</html>