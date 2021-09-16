<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/usersession.jsp"%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>" />
<fmt:bundle basename="messages">
<head>
<title><fmt:message key="mail.edit.orders" /></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel=stylesheet href="../common/css/popup.css" type="text/css">
<script type="text/javascript">

window.code = '_CHILDWINDOW_MAIL1003';

$(document).ready(function() {
	var orders = document.getElementById("orders");
	orders.value = <%=request.getParameter("orders") %>;
	orders.focus();
	
	$(orders).bind("keydown", function(e) {
		switch(e.keyCode) {
			case $.ui.keyCode.ENTER:
				OnOK();
			case $.ui.keyCode.BACKSPACE:
			case $.ui.keyCode.DELETE:
			case $.ui.keyCode.TAB:
			case $.ui.keyCode.HOME:
			case $.ui.keyCode.END:
			case $.ui.keyCode.LEFT:
			case $.ui.keyCode.RIGHT:
				return true;
		}
		if (e.ctrlKey) {	// Keyboard Ctrl
			switch(e.keyCode) {
				case 65:	// Keyboard A
				case 67:	// Keyboard C
				case 88:	// Keyboard X
				case 90:	// Keyboard Z
					return true;
			}
		}
		// Keyboard Number
		if ((e.keyCode >= 48 && e.keyCode <= 57) || (e.keyCode >= 96 && e.keyCode <= 105)) {
			return true;
		}
		return false;
	});
});

function OnCancel() {
// 	window.returnValue = null;
// 	window.close();
	parent.closeDhtmlModalWindow();
}

function OnOK() {
	var order = $.trim(document.getElementById("orders").value);
	if (order == "") {
		alert("<fmt:message key='mail.c.insert.order'/>");
		orders.focus();
		return;
	}
// 	window.returnValue = order;
// 	window.close();

	parent.setOrder(order);
	parent.closeDhtmlModalWindow();
}
</script>
</head>
<body bgcolor="d4d0c8">
	
	<table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tr height="40">
			<td background="../common/images/popup_bg.gif" width="30"><img src="../common/images/popup_title.gif"></td>
			<td background="../common/images/popup_bg.gif" width="*" class="title" style="padding-left: 9px;">
				<fmt:message key="mail.edit.orders" />
			</td>
		</tr>
		<tr>
			<td colspan="2"></td>
		</tr>
	</table>
	
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="d4d0c8">
		<tr>
			<td align="center" style="padding: 2px;">
			
				<table width="100%" bgcolor="d4d0c8" cellspacing="0" cellpadding="3">
					<tr>
						<td style="width: 100%; height: 100%; padding-top: 5px; font-size: 9pt">
						
							<table bgcolor="white" style="width: 100%; height: 100%; table-layout: fixed;">
								<tr>
									<td bgcolor="#EFEFEF" valign="top" style="padding-top: 10px;line-height: 2.2em; text-align: center;">
										<b>
											<fmt:message key="mail.mailbox.personal" />
											<fmt:message key="mail.mailbox.order" />
										</b>
										<br>
										<input type="text" id="orders" name="orders" value="" style="ime-mode: disabled;" maxlength="2">
										<br>
										<br>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				
				<table width="100%" height="2" border="0" cellspacing="0" cellpadding="0" bgcolor="d4d0c8" style="padding: 5px;">
					<tr>
						<td valign="middle" background="../common/images/pop_bg_line.gif"></td>
					</tr>
				</table>
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td align="center" style="padding-top: 6px;">
							<span onclick="OnOK()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.ok" /> <%-- 확인 --%> </span>
							&nbsp; 
							<span onclick="OnCancel()" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.cancel" /> <%-- 취소 --%> </span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</fmt:bundle>
</html>