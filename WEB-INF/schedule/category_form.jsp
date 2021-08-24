<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page errorPage="../error.jsp" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek3.web.form.schedule.ScheduleWebForm" %>
<%@ page import="net.sf.json.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<!-- uniform -->
<script src="/common/jquery/plugins/uniform/jquery.uniform.min.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/uniform/themes/default/css/uniform.default.css" />

<link rel="stylesheet" type="text/css" href="/common/css/style.css" />
<script language="javascript">

function offEnter() {
	if (event.keyCode == 13) {
		if (event.preventDefault) { event.preventDefault(); } else { event.returnValue = false; }
	}
}

function del_confirm() {
	var frm = document.getElementById("scheWebForm");
	var yn = confirm("<spring:message code='c.delete' text='삭제 하시겠습니까?' />") ;
	if (yn) {
		document.getElementById("search.cmd").value = "delete";
		frm.action = "./category_save.htm";
		frm.submit();
	}
}

function edit_confirm(title, securityid) {
	var frm = document.getElementById("scheWebForm");
	if (TrimAll(document.getElementById("scheCategory.title").value) == "") {
		alert("<spring:message code='c.input.subject' text='제목을 입력하십시요.' />");
		document.getElementById("scheCategory.title").focus();
		return;
	}

	var yn = confirm("'" + title + "'<spring:message code='sch.subject.all.change' text='로 입력된 모든 일정 제목이 수정됩니다.' /> <spring:message code='addr.modify.category' text='수정 하시겠습니까?' />") ;
	if (yn) {
		document.getElementById("search.cmd").value="modify";
		frm.action = "./category_save.htm";
		frm.submit();
	}
}

function show_insert() {
	var frm = document.getElementById("scheWebForm");
	document.getElementById("search.cmd").value="";
	document.getElementById("search.scid").value="";
	self.location.href = "./category_form.htm?gubun=<c:out value="${scheWebForm.search.gubun}" />";
}	

function show_edit(cmd, scid) {
	var frm = document.getElementById("scheWebForm");

	self.location.href = "./category_form.htm?cmd="+ cmd + "&scid=" + scid + "&gubun=<c:out value="${scheWebForm.search.gubun}" />";
}

function docSubmit() {
	var frm = document.getElementById("scheWebForm");
	if (TrimAll(document.getElementById("scheCategory.title").value) == "") {
		alert("<spring:message code='c.input.subject' text='제목을 입력하십시요.' />");
		frm.document.getElementById("scheCategory.title").focus();
		return;
	}
	var imgfile = document.getElementsByName("scheCategory.imgFile");
	if (imgfile[0].checked != true && imgfile[1].checked != true 
			&& imgfile[2].checked != true && imgfile[3].checked != true 
			&& imgfile[4].checked != true && imgfile[5].checked != true 
			&& imgfile[6].checked != true && imgfile[7].checked != true 
			&& imgfile[8].checked != true && imgfile[9].checked != true 
			&& imgfile[10].checked != true && imgfile[11].checked != true 
			&& imgfile[12].checked != true && imgfile[13].checked != true 
			&& imgfile[14].checked != true && imgfile[15].checked != true) {
		alert("<spring:message code='sch.Please.select.image' text='이미지를 선택해 주세요' />");
		return;
	}
	document.getElementById("search.cmd").value = "insert";
	frm.action = "./category_save.htm";
	frm.submit();
}
 
</script>
</head>
<body style="margin:0;padding:0;">

<form:form  commandName="scheWebForm" onsubmit="return false">
<c:if test="${scheWebForm.search != null }">
	<form:hidden path="search.searchKey" />
	<form:hidden path="search.searchValue" />
	<form:hidden path="search.useLayerPopup" />
	<form:hidden path="search.useNewWin" />
	<form:hidden path="search.scid"/>
	<form:hidden path="search.cmd"/>
	<form:hidden path="search.gubun"/>
</c:if>
<form:hidden path="scheCategory.scid"/>
<table class="doc-width" cellspacing="0" cellpadding="0" border="0">
<tbody><tr>
<td>

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#f7f7f7; position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle" style="font-size:14px; font-weight:bold; float:left;">
		<img align="absmiddle" src="/common/images/icons/title-list-calendar1.png" />
		<fmt:message key="main.Schedule"/>&nbsp;<!-- 일정관리 -->&gt;&nbsp;Category
	</span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

<!--  Title -->
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%"> -->
<!-- <tr height="26"> -->
<!-- <td width="*" align=left> -->
<!-- 	<img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle">  -->
<!-- 	<span class="ltitle">일정분류등록&nbsp;일정관리</span> -->
<!-- </td> -->
<!-- <td width="300" align="right"> -->
<!-- 	<img src="../common/images/pp.gif" border="0" align="absmiddle"> -->
<%-- 	<a href="javascript:ShowUserInfo('<c:out value="${user.userId }" />');" class="maninfo"> --%>
<%-- 	<c:out value="${user.nName }" /> / <c:out value="${user.department.dpName }" /> </a>  --%>
<!-- </td> -->
<!-- </tr> -->
<!-- </table> -->

<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="5"><td></td></tr></table> -->

<!--  수행버튼  -->	
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%"> -->
<!-- <tr height="35"> -->
<!-- <td width="10"><img src="../common/images/bar_left.gif" border="0"></td> -->
<!-- <td width="*" background="../common/images/bar_bg.gif" style="padding-left:5px;" align=left> -->

<!-- 	<table border="0" cellpadding="0" cellspacing="0" width="100%"> -->
<!-- 	<tr> -->
<!-- 	<td width="*" align="right"> -->
<%-- 		<c:if test="${scheWebForm.search.cmd == '' || scheWebForm.search.cmd == 'insert' }"> --%>
<!-- 		<a onclick="docSubmit(); " class="button gray medium"> -->
<%-- 		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.save"/>&nbsp;<!-- 저장 --> </a> --%>
<%-- 		</c:if> --%>
<%-- 		<c:if test="${scheWebForm.search.cmd == 'edit' }"> --%>
<%-- 		<a onclick="edit_confirm('<c:out value="${scheWebForm.scheCategory.title}" />', '');" class="button white medium"> --%>
<%-- 		<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.modify"/>&nbsp;<!-- 수정 --></a> --%>
<!-- 		<a onclick="del_confirm();" class="button white medium"> -->
<%-- 		<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.delete"/>&nbsp;<!-- 삭제 --></a> --%>
<%-- 		</c:if> --%>
<!-- 	</td> -->
<!-- 	</tr> -->
<!-- 	</table> -->
<!-- </td> -->
<!-- <td width="10"><img src="../common/images/bar_right.gif" border="0"></td> -->
<!-- </tr> -->
<!-- </table> -->

<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="4"><td></td></tr></table> -->

	
<!-- <div id="viewList" class="div-view" onpropertychange="div_resize();"> -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
	<tr> 
		<td> 
		<!-- 본문 DATA 목록 -->
			<table width="95%" cellspacing="0" cellpadding="0" border="0" style="margin:10px; border-collapse:collapse">
				<tr>
					<td width="20%" valign="top">
						<table width="100%" cellspacing="0" cellpadding="0"  style="border:1px solid #dfdfdf; sbackground-color:#EDF2F5;">
							<tr>
								<td class="td_le1" align="center">
								<a onclick="show_insert();" class="button gray medium">
								<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.newDoc" text="New category"/>&nbsp;Category<!-- 일정 구분 등록 --> </a>
<!-- 								<a href="javascript:show_insert()">:: 새 일정 등록 ::</a></td> -->
							</tr>
							<!-- 일정분류 목록 -->
							<c:forEach items="${categoryList }" var="item">
							<tr>
								<td style="line-height:130%; padding:3px; height:20px; border:1px solid #dfdfdf; ">
									<a href="javascript:show_edit('edit','<c:out value="${item.scid }"/>')">
										<%-- <img src="../common/images/schedule/schedule_icon/<c:out value="${item.imgFile }" />" border="0"> --%>
										<c:out value="${item.title }" />
									</a>
								</td>
							</tr>
							</c:forEach>
							<!-- 일정분류 목록 -->
						</table>
					</td>
					<td width="10"></td>
					<td width="*" valign="top">
						<table width="100%" cellspacing=0 cellpadding=0 style="border:1px solid #90B9CB; padding:2 2 2 4; sbackground-color:#EDF2F5;">
							<tr>
								<td class="td_le1"><spring:message code="t.subject" text="제목"/></td>
								<td class="td_le2" NOWRAP>
									<form:input path="scheCategory.title" maxlength="10" style="width:200px;" onkeypress="offEnter()" />&nbsp;
									<c:if test="${scheWebForm.search.cmd == '' || scheWebForm.search.cmd == 'insert' }">
										<a onclick="docSubmit(); " class="button gray medium">
										<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.save"/>&nbsp;<!-- 저장 --> </a>
										</c:if>
										<c:if test="${scheWebForm.search.cmd == 'edit' }">
										<a onclick="edit_confirm('<c:out value="${scheWebForm.scheCategory.title}" />', '');" class="button white medium">
										<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.modify"/>&nbsp;<!-- 수정 --></a>
										<a onclick="del_confirm();" class="button white medium">
										<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.delete"/>&nbsp;<!-- 삭제 --></a>
									</c:if>
								</td>
							</tr>
							<tr style="display:none;">
								<td class="td_le1"><spring:message code="t.choice" text="select image"/></td>
								<td class="td_le2" NOWRAP>
									<table width="100%">
										<tr>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_day.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_day.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_education.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_education.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_etc.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_etc.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_event.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_event.gif">&nbsp;
											</td>
										</tr>
										<tr>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_meeting.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_meeting.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_promise.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_promise.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_work.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_work.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_mobile.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_mobile.gif">&nbsp;		
											</td>
										</tr>
										<tr>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_book.gif" checked="checked" />
												<img src="../common/images/schedule/schedule_icon/bu_book.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_graph.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_graph.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_stamp.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_stamp.gif">&nbsp;
											</td>					
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_allim.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_allim.gif">&nbsp;
											</td>
										</tr>
										<tr>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_mouse.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_mouse.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_man.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_man.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_balloon.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_balloon.gif">&nbsp;
											</td>
											<td>
												<form:radiobutton path="scheCategory.imgFile" value="bu_movie.gif" />
												<img src="../common/images/schedule/schedule_icon/bu_movie.gif">&nbsp;
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		<!-- 본문 DATA 끝-->
		</td>
	</tr>
	<tr><td height="15"></td></tr>
</table>
<!-- </div> -->

</td>
</tr>
</tbody>
</table>

</form:form>
<script language="javascript">SetHelpIndex("schep_category");</script>
</body>
</html>