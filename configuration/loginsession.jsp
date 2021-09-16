<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.NoAdminAuthorityException" %>
<%@ page import="nek.common.login.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="nek.common.StringUtil"%>
<% 	request.setCharacterEncoding("utf-8"); %>

<%@ include file="../common/usersession.jsp"%>
<%

	String cmdType = request.getParameter("command");
	if (cmdType == null || "".equals(cmdType)) cmdType = "list";

	SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	LoginSessionItem[] sessionItems = null;
	int iSessionCount = 0;
	try
	{
		if ("delete".equals(cmdType))
		{
			String[] sessionIds = request.getParameterValues("chkidx");
			int iRowCnt = (sessionIds != null) ? sessionIds.length: 0;
			for (int i=0; i< iRowCnt; i++)
			{
				SessionMgr.removeSession(application, sessionIds[i]);
			}
		}
		sessionItems = SessionMgr.getLoginSession(loginuser, application);
		if (sessionItems != null) iSessionCount = sessionItems.length;
	}
	catch(NoAdminAuthorityException ex)
	{
		out.write("<script language='javascript'>alert('관리권한이 없습니다');history.back();</script>");
		//out.close();
		return;
	}
%>
<HTML>
<HEAD>
<TITLE>로그인세션정보</TITLE>
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script src="<%=scriptPath %>/xmlhttp.vbs" language="vbscript"></script>
<script src="<%=scriptPath %>/DatePicker.js"></script>

<script language="javascript">
	SetHelpIndex("admin_loginsession");
</script>

<script language="javascript">
	<!--
	function goSubmit(cmd)
	{
		var fm = document.submitForm;
		switch(cmd)
		{
			case "delete":					//선택삭제
				if (!deleteValidation()) return;
				fm.action = "./loginsession.jsp";
				fm.method = "POST";
				break;
		}
		fm.command.value = cmd;
		fm.submit();
	}

	function deleteValidation()
	{
		var bChecked = IsCheckedItemExist();
		if (!bChecked)
		{
			alert("선택된 로그인 세션이 없습니다");
			return false;
		}
		return confirm("선택된 로그인 세션을 종료하시겠습니까?");
	}
	function OnClickToggleAllSelect() {
		var items = document.getElementsByName("chkidx");
		if (items != null && items.length > 0) {
			var checked = !items[0].checked;
			for (var i = 0; i < items.length; i++) {
				items[i].checked = checked;
			}
		}
	}

	function IsCheckedItemExist()
	{
		var bChecked = false;
		var items = document.getElementsByName("chkidx");
		if (items != null && items.length > 0) {
			for (var i = 0; i < items.length; i++) 
			{
				if (items[i].checked)
				{
					bChecked = true;
					break;
				}
			}
		}
		return bChecked;
	}

	-->
</script>
</HEAD>

<body>

<form name="submitForm" >
	<input type="hidden" name="command" value="list">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
		<tr> 
			<td width="6"> 
				<table width="6" border="0" cellspacing="0" cellpadding="0" height="100%">
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
					<tr> 
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
																		<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_admin.jpg" width="27" height="27"></td>
																		<td class="SubTitle">로그인세션정보</td>
																		<td valign="bottom" width="250" align="right"> 
																			<table border="0" cellspacing="0" cellpadding="0" height="17">
																				<tr> 
																					<td valign="top" class="SubLocation">관리자 &gt; <b>로그인세션정보</b></td>
																					<td align="right" width="15"><img src="<%=imagePath %>/sub_img/sub_title_location_icon.jpg" width="10" height="10"></td>
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
																		<td width="60"> 
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('delete');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr>
																					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;삭제</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<td width="68"> 
																		</td>
																		<td> 
																		</td>
																		<td>&nbsp;</td>
																		<td width="140" class="DocuNo" align="right">
																			<img src="<%=imagePath %>/icon_docu.jpg" width="14" height="16">
																			<div style="position:relative;bottom:3px;display:inline;">접속자수:<b><%=iSessionCount%></b></div>
																		</td>
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
																<!-- <div id="viewList" class="div-view" onpropertychange="div_resize();"> -->
																<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
																	<tr> 
																		<td height="30" valign="top"> 
																			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29" background="<%=imagePath %>/titlebar_bg.jpg">
																				<tr> 
																					<td width="5" background="<%=imagePath %>/titlebar_left.jpg"></td>
																					<td align="center">
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px;">
																							<colgroup>
																								<col width="19">
																								<col width="1">
																								<col width="18%">
																								<col width="1">
																								<col width="12%">
																								<col width="1">
																								<col width="*">
																								<col width="1">
																								<col width="25%">
																								<col width="1">
																								<col width="12%">
																							</colgroup>
																							<tr>
																								<td align="center" class="SubTitleText">
																									<img src="../common/images/btn_checkbox.gif" onClick="OnClickToggleAllSelect()" style="cursor: hand" align="absmiddle">
																								</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">로그인일시</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">로그인ID</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">성명/부서</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">IP주소</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">브라우저유형</td>
																							</tr>
																						</table>
																					</td>
																					<td width="5" background="<%=imagePath %>/titlebar_right.jpg"></td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																	<tr> 
																		<td> 
																			<!-- 본문 DATA 목록 -->
																			<%
																				for (int i=0; i< iSessionCount; i++)
																				{
																			%>
																			<table width="100%" border="0" cellspacing="0" cellpadding="0">
																				<tr> 
																					<td width="5"></td>
																					<td> 
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px;">
																							<tr height='25' <% if ((i % 2) == 1) out.write("bgcolor='#f9f9f9'");%>> 
																								<td>
																									<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tblfix">
																										<colgroup>
																											<col width="19">
																											<col width="1">
																											<col width="18%">
																											<col width="1">
																											<col width="12%">
																											<col width="1">
																											<col width="*">
																											<col width="1">
																											<col width="25%">
																											<col width="1">
																											<col width="12%">
																										</colgroup>
																										<tr> 
																											<td align="center" class="SubText"><input type="checkbox" name="chkidx" value="<%=sessionItems[i].sessionId%>"></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=formatter.format(sessionItems[i].loginDate)%></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=sessionItems[i].loginId%></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><a href="javascript:ShowUserInfo('<%=sessionItems[i].uid%>')"><%=sessionItems[i].nName%>/<%=sessionItems[i].dpName%></a></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=sessionItems[i].hostIp%></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=sessionItems[i].agentType%></td>
																										</tr>
																									</table>
																								</td>
																							</tr>
																							<tr valign="top"> 
																								<td height="1" bgcolor="c3c3c3"></td>
																							</tr>
																						</table>
																					</td>
																					<td width="5"></td>
																				</tr>
																			</table>
																			<%
																				}
																				if (iSessionCount == 0){
																					out.println("<table width='100%' style='height:expression(document.body.clientHeight-220);' border='0' cellspacing='0' cellpadding='0'><tr>"
																							+ "<td width='5'></td><td>"+StringUtil.getNODocExistMsg("생성된 로그인세션이 없습니다")
																							+ "</td><td width='5'></td></tr></table>");
																				}
																			%>
																	<!-- 본문 DATA 끝-->
																		</td>
																	</tr>
																	<tr> 
																		<td height="15"></td>
																	</tr>
																</table>
																<!--</div>-->
																<!-- 페이지 / 검색 -->
																<!-- 페이지 / 검색 끝 -->
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
					<tr> 
						<td height="6" align="right" background="<%=imagePath %>/box_center_bottom_left.jpg"><img src="<%=imagePath %>/box_bottom_right.jpg" width="4" height="6"></td>
					</tr>
				</table>
			</td>
			<td width="6"> 
				<table width="6" border="0" cellspacing="0" cellpadding="0" height="100%">
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

</form>
</BODY>
</HTML>