<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%!
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String[] viewType = {"0"};

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<title>게시판분류(시스템관리자)</title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<%@ include file="../common/include.common.jsp"%>
<script language="javascript">
	//SetHelpIndex("bbs_adminlist");
</script>
<script language=javascript>
	function checkInput(){
		var isValid = validator.form();
		if(!isValid) validator.focusInvalid();
		return isValid;
	}

	function goSubmit(cmd){
		var frm = document.getElementById("topCode");
		switch(cmd){
			case "list":
				location.href = "topcode_list.htm";
				return;
				break;
			case "save":
				if(!checkInput()) return;
				frm.method = "POST";
				frm.action = "topcode_save.htm";
				break;
			case "delete":
				if(!confirm("<spring:message code='i.category.all.delete' text='이 항목으로 분류된 게시판의 분류정보도 함께 삭제됩니다'/>\n<spring:message code='c.delete' text='삭제 하시겠습니까?' />")) return;
				frm.method = "POST";
				frm.action = "topcode_delete.htm";
				break;
			default:
				return;
				break;
		}
		frm.submit();
	}
</script>
<script type="text/javascript">
var validator = null;
$(document).ready(function(){
	validator = $("#topCode").validate({
		rules:{
		"codeName":{
			required:true
			}
		},
	messages:{
		"codeName":{
			required:"<spring:message code='v.bbs.code.required' text='분류명을  입력하십시요' />"
			}
		},
	focusInvalid:true
	});
});	
</script>
</head>
<body>
<form:form commandName="topCode" onsubmit="return false;">
	<form:hidden path="fixed" />
	<form:hidden path="code" />
	<form:hidden path="workType" value="1" />
	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
		<tr> 
			<td width="6"> 
				<table width="6" border="0" cellspacing="0" cellpadding="0" height="100%" style="display:none;">
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_left_top.jpg"></td>
					</tr>
					<tr> 
						<td background="<%=imagePath %>/box_left_bg.jpg">&nbsp;</td>
					</tr>
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_left_bottom.jpg"></td>
					</tr>
				</table>
			</td>
			<td valign="top"> 
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
					<tr style="display:none;"> 
						<td height="6" background="<%=imagePath %>/box_center_top_left.jpg" align="right"><img src="<%=imagePath %>/box_top_right.jpg" width="4" height="6"></td>
					</tr>
					<tr> 
						<td bgcolor="#FFFFFF" valign="top">
						
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="11">&nbsp; </td>
									<td valign="top"> 
										<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
											<tr> 
												<td height="44"> 
												
												<!-- 타이틀 시작 -->
													<table width="100%" border="0" cellspacing="0" cellpadding="0" height="44">
														<tr> 
															<td height="11"></td>
														</tr>
														<tr> 
															<td height="27"> 
																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
																	<tr> 
																		<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_board.jpg" width="27" height="27"></td>
																		<td class="SubTitle"><spring:message code='t.bbs.category' text='게시판분류' /></td>
																		<td valign="bottom" width="250" align="right"> 
																			<table border="0" cellspacing="0" cellpadding="0" height="17">
																				<tr> 
																					<td valign="top" class="SubLocation"><spring:message code='t.administrator' text='관리자' /> &gt; <spring:message code='main.Board.Management' text='게시판관리' /> &gt; <b><spring:message code='t.bbs.category' text='게시판분류' /></b></td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																</table>
															</td>
														</tr>
														<tr> 
															<td height="3"></td>
														</tr>
														<tr> 
															<td height="3"> 
																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3">
																	<tr> 
																		<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td>
																		<td bgcolor="eaeaea"></td>
																	</tr>
																</table>
															</td>
														</tr>
													</table>
													<!-- 타이틀 끝 -->
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
																<!-- 수행 버튼  시작 -->
																<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
																	<tr> 
																		<td width="70"> 
																		<a href="#" onclick="javascript:goSubmit('list');" >
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn">
																				<tr>
																					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.list' text='목록' /></span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</a>
																		</td>
																		<td width="68"> 
																		<a href="#" onclick="javascript:goSubmit('save');" >
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn">
																				<tr>
																					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.save' text='저장' /></span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</a>
																		</td>
																		<c:if test="${topCode.code != null && topCode.code != ''  && !topCode.fixed}">
																		<td> 
																		<a href="#" onclick="javascript:goSubmit('delete');" >
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn">
																				<tr>
																					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.delete' text='삭제' /></span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</a>
																		</td>
																		</c:if>
																		<td>&nbsp;</td>
																	</tr>
																</table>
																<!-- 수행 버튼  끝 -->
															</td>
														</tr>
														<tr> 
															<td height="10"></td>
														</tr>
														<tr> 
															<td>
																<table width="80%" border="0" cellspacing="0" cellpadding="0">
                                                                    <colgroup>
                                                                        <col width="5%">
                                                                        <col width="95%">
                                                                    </colgroup>
																	<tr>
																		<td class="td_ce2"><spring:message code='addr.category.name' text='분류명' /></td>
																		<td style="height:45px;">
																			<form:input path="codeName"/>
																			<form:hidden path="codeNameEn"/>
																			<form:hidden path="codeNameJa"/>
																			<form:hidden path="codeNameZh"/>
																		</td>
																	</tr>
																		<td class="td_ce2"><spring:message code='t.sortOrder' text='정렬순서' /></td>
																		<td>
																			<form:input path="orders" />
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
					</tr>
					<tr style="display:none;"> 
						<td height="6" align="right" background="<%=imagePath %>/box_center_bottom_left.jpg"><img src="<%=imagePath %>/box_bottom_right.jpg" width="4" height="6"></td>
					</tr>
				</table>
			</td>
			<td width="6"> 
				<table width="6" border="0" cellspacing="0" cellpadding="0" height="100%" style="display:none;">
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_right_top.jpg"></td>
					</tr>
					<tr> 
						<td background="<%=imagePath %>/box_right_bg.jpg">&nbsp;</td>
					</tr>
					<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_right_bottom.jpg"></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form:form>
</body>
</html>
