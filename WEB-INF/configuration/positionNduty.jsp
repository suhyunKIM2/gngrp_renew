<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
	private String setSelectedOption(int i1, int i2)
	{
		String selectStr = "";
		if (i1 == i2) selectStr = "selected";
		return selectStr;
	}

	private String setSelectedOption(String str1, String str2)
	{
		System.out.println(str1);
		System.out.println(str2);
		String selectStr = "";
		if (str1.equals(str2)) selectStr = "selected";
		return selectStr;
	}
	
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><spring:message code="emp.position.jobtitle.info" text="직위 / 직책 정보"/></title>
<%@ include file="../common/include.common.jsp"%>
<script language="javascript">
	//SetHelpIndex("admin_upud");
</script>
<style>
.table_box_input .td_ce2 INPUT[type=text]{padding:10px 4px;border:0;border-bottom:1px solid #eee;border-left:1px solid #eee;}
.table_box_input tr:last-child .td_ce2 INPUT[type=text]{border-bottom:0;}
</style>
</head>
<body>
<form:form commandName="upUdWebForm" action="positionNduty_save.htm" method="POST" onsubmit="return false;">
	<!-- List Title -->

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="emp.mng.org" text="조직관리"/> &gt; <spring:message code="v.grade" text="직위"/></span>
	</td>
	<td width="40%" align="right" style="padding:0 20px 0 0;">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
	<!-- List Title -->
	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
		<tr> 
			<td valign="top"> 
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
					<!--<tr>
						<td height="10" width="6" background="<%=imagePath %>/box_left_top.jpg"></td> 
						<td height="6" background="<%=imagePath %>/box_center_top_left.jpg" align="right" style="background-repeat: no-repeat; background-position:0% 30%;"><img src="<%=imagePath %>/box_top_right.jpg" width="4" height="6"></td>
						<td height="10" width="6" background="<%=imagePath %>/box_right_top.jpg" ></td>
					</tr>-->
					<tr>
						<!--<td background="<%=imagePath %>/box_left_bg.jpg" style="background-repeat:repeat-y; background-position:left;">&nbsp;</td> -->
						<td bgcolor="#FFFFFF" valign="top">
						
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="11">&nbsp; </td>
									<td valign="top"> 
<!-- 										<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%"> -->
										<table width="400px" border="0" cellspacing="0" cellpadding="0" height="100%">
											<tr> 
												<td height="1"> 
												<!-- 타이틀 시작 -->
													<table border="0" cellpadding="0" cellspacing="0" width="100%">
													<tr>
														<td width="*" align="right" class="fileupload-buttonbar" style="padding-right:13px;">
															<a onclick="javascript:document.getElementById('upUdWebForm').submit();" class="button gray medium">
															<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.save' text='저장' /> </a>
														</td>
													</tr>
													</table>
												</td>
											</tr>
											<tr> 
												<td valign="top"> 
													<table width="100%" border="0" cellspacing="0" cellpadding="0">
														<tr> 
															<td height="10"></td>
														</tr>
														<tr> 
															<td> 
																<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
																	<tr> 
																		<td> 
																		<!-- 본문 DATA 목록 -->
																			<table width="100%" cellspacing="0" cellpadding="0" border="0">
																				<!-- 직위코드 -->
																					<td width="48%" valign="top">
																						<table width="99.5%" border="0" cellspacing="0" cellpadding="0" height="29" style="background:#eee;">
																							<tr> 
																								<td width="5"></td>
																								<td align="center">
																									<table width="100%" border="0" cellspacing="0" cellpadding="0">
																										<colgroup>
																											<col width="33%">
																											<col width="1">
																											<col width="*">
																											<col width="1">
																											<col width="20%">
																										</colgroup>
																										<tr>
																											<td align="center" class="SubTitleText"><spring:message code="emp.code.positon" text="직급코드"/></td>
																											<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																											<td align="center" class="SubTitleText"><spring:message code="emp.name.position" text="직급명"/></td>
																											<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																											<td align="center" class="SubTitleText"><spring:message code="mail.mailbox.order" text="순번"/></td>
																										</tr>
																									</table>
																								</td>
																								<td width="5"></td>
																							</tr>
																						</table>
																						<div style="width:100%;height:expression(document.body.clientHeight-150);overflow-y:auto">
																						<table width="99.5%" border="0" cellspacing="0" cellpadding="0" style="border:1px solid #eee;">
																							<tr> 
																								<td width="5"></td>
																								<td align="center">
																									<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_box_input">
																										<colgroup>
																											<col width="33%">
																											<col width="*">
																											<col width="20%">
																										</colgroup>
																										<c:forEach var="upItem" items="${userPositions }">
																										<tr>
																											<td class="td_ce2"><input type="hidden" name="upIds" value="${upItem.upId}"><c:out value="${upItem.upId}" /></td>
																											<td class="td_ce2"><input type="text" style="width:95%;" name="upNames" value="<c:out value="${upItem.upName}" />"></td>
																											<td class="td_ce2"><input type="text" style="width:95%;" name="upOrders" value="<c:out value="${upItem.orders}" />"></td>
																										</tr>
																										</c:forEach>
																									</table>
																								</td>
																								<td width="5"></td>
																							</tr>
																						</table>
																						</div>
																					</td>
<!-- 																					<td width="4%">&nbsp;</td> -->
																					<!-- 직책코드 -->
																					<%--
																					<td width="48%" valign="top">
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29" background="<%=imagePath %>/titlebar_bg.jpg">
																							<tr> 
																								<td width="5" background="<%=imagePath %>/titlebar_left.jpg"></td>
																								<td align="center">
																									<table width="100%" border="0" cellspacing="0" cellpadding="0">
																										<colgroup>
																											<col width="33%">
																											<col width="1">
																											<col width="*%">
																											<col width="1">
																											<col width="20%">
																										</colgroup>
																										<tr>
																											<td align="center" class="SubTitleText"><spring:message code="emp.code.jobTitle" text="직책코드"/></td>
																											<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																											<td align="center" class="SubTitleText"><spring:message code="emp.name.jobTitle" text="직책명"/></td>
																											<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																											<td align="center" class="SubTitleText"><spring:message code="mail.mailbox.order" text="순번"/></td>
																										</tr>
																									</table>
																								</td>
																								<td width="5" background="<%=imagePath %>/titlebar_right.jpg"></td>
																							</tr>
																						</table>
																						<div style="width:100%;height:expression(document.body.clientHeight-150);overflow-y:auto;">
																						<table width="99%" border="0" cellspacing="0" cellpadding="0">
																							<tr> 
																								<td width="5"></td>
																								<td align="center">
																									<table width="100%" border="0" cellspacing="0" cellpadding="0" >
																										<colgroup>
																											<col width="33%">
																											<col width="*">
																											<col width="20%">
																										</colgroup>
																										<c:forEach var="udItem" items="${userDuties }">
																										<tr>
																											<td class="td_ce2"><input type="hidden" name="udIds" value="${udItem.udId}"><c:out value="${udItem.udId}" /></td>
																											<td class="td_ce2"><input type="text" style="width:95%;" name="udNames" value="<c:out value="${udItem.udName}" />"></td>
																											<td class="td_ce2"><input type="text" style="width:95%;" name="udOrders" value="<c:out value="${udItem.orders}" />"></td>
																										</tr>
																										</c:forEach>
																									</table>
																								</td>
																								<td width="5"></td>
																							</tr>
																						</table>
																						</div>
																					</td>
																					 --%>
																				</tr>
																				
																			</table>
																		<!-- 본문 DATA 끝-->
																		</td>
																	</tr>
																</table>
															</td>
															<td width="11">&nbsp;</td>
														</tr>
													</table>
												</td>
											</tr>											
										</table>
									</td>
								</tr>
							</table>
						</td>
						<!--<td background="<%=imagePath %>/box_right_bg.jpg" style="background-repeat: repeat-y; background-position:50% 50%">&nbsp;</td>-->
					</tr>
					<!--<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_left_bottom.jpg"></td>
						<td height="6" align="right" background="<%=imagePath %>/box_center_bottom_left.jpg" style="background-repeat: no-repeat; background-position:0% 80%;"><img src="<%=imagePath %>/box_bottom_right.jpg" width="4" height="6"></td>
						<td valign="bottom" height="10px" width="6" background="<%=imagePath %>/box_right_bottom.jpg"></td>
					</tr>-->
				</table>
			</td>
		</tr>
	</table>
	
</form:form>
<script>
var input = document.getElementsByTagName("INPUT");
for( var i=0; i < input.length; i++) {
//	input[i].readOnly = true;
}
</script>
</BODY>
</HTML>