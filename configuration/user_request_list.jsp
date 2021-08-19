<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.configuration.*" %>
<%@ page import="nek.common.NoAdminAuthorityException" %>
<%@ page import="nek.common.util.*" %>
<% 	request.setCharacterEncoding("utf-8"); %>

<%@ include file="../common/usersession.jsp"%>
<%!

	private String setSelectedOption(int i1, int i2)
	{
		String selectStr = "";
		if (i1 == i2) selectStr = "selected";
		return selectStr;
	}

	private String setSelectedOption(String str1, String str2)
	{
		String selectStr = "";
		if (str1.equals(str2)) selectStr = "selected";
		return selectStr;
	}

%>
<%
	int pg = 0;
	try
	{
		pg = Integer.parseInt(request.getParameter("pg"));
	}
	catch(Exception e)
	{
		pg = 1;
	}
	
	int listPPage = 10;
	int blockPPage = 10;
	UserRequestList userList = null;
	ArrayList listData = null;
	UserItem userItem = null;
	ConfigItem cfItem = null;
    int listCount = 0;
	try
	{
		userList = new UserRequestList(loginuser);
		userList.getDBConnection();
		
		listPPage = uservariable.listPPage;
		blockPPage = uservariable.blockPPage;

		listData = userList.getUserList();
		if (listData != null) listCount = listData.size();
	}
	catch(NoAdminAuthorityException ex)
	{
		out.write("<script language='javascript'>alert('관리권한이 없습니다');history.back();</script>");
		//out.close();
		return;
	}
	finally
	{
		userList.freeDBConnection();
	}
%>
<HTML>
<HEAD>
<TITLE>사용신청자정보</TITLE>
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script language="javascript">
	SetHelpIndex("admin_userlist");
</script>

<script language="javascript">
<!--
	var targetWin;

	function goSubmit(cmd, isNewWin ,uid)
	{
		var frm = document.submitForm;
		var url = "";
		switch(cmd)
		{
			case "view":
				frm.uid.value = uid;
				frm.action = "./user_edit_form.jsp";
				url = "./user_edit_form.jsp?uid=" + uid;
				break;

			case "new":
				frm.action = "./user_form.jsp";
				url = "./user_form.jsp";
				break;

		}
		if (isNewWin == "true")
		{
			OpenWindow( url, "", "755" , "610" );
			return;
			//frm.opentype.value = "winopen";
			//frm.target = "targetWin";
		}
		else
		{
			frm.target = "_self";
			frm.opentype.value = "";
		}

		frm.submit();
	}
-->
</script>
</HEAD>

<body>

<form name="submitForm" >
	<input type="hidden" name="pg" value="1">
	<input type="hidden" name="opentype" value="">
	<input type="hidden" name="uid" value="">

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
																		<td class="SubTitle">조직관리 - 사용신청자</td>
																		<td valign="bottom" width="250" align="right"> 
																			<table border="0" cellspacing="0" cellpadding="0" height="17">
																				<tr> 
																					<td valign="top" class="SubLocation">관리자 &gt; 조직관리 &gt; <b>사용신청자</b></td>
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
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('new','true','');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr>
																					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;등록</span></td>
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
																			<div style="position:relative;bottom:3px;display:inline;">총문서수:<b><%=listCount%></b></div>
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
																<div id="viewList" class="div-view" onpropertychange="div_resize();">
																<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
																	<tr> 
																		<td height="30" valign="top"> 
																			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29" background="<%=imagePath %>/titlebar_bg.jpg">
																				<tr> 
																					<td width="5" background="<%=imagePath %>/titlebar_left.jpg"></td>
																					<td align="center">
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
																							<colgroup>
																								<!-- <col width="20"> -->
																								<col width="*">
																								<col width="1">
																								<col width="15%">
																								<col width="1">
																								<col width="6%">
																								<col width="1">
																								<col width="10%">
																								<col width="1">
																								<col width="16%">
																								<col width="1">
																								<col width="12%">
																								<col width="1">
																								<col width="12%">
																								<col width="1">
																								<col width="12%">
																							</colgroup>
																							<tr>
																								<!-- <td align="center"></td> -->
																								<td align="center" class="SubTitleText">이름</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">부서</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">직위</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">사번</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">업무</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">전화번호</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">핸드폰</td>
																								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
																								<td align="center" class="SubTitleText">E-mail</td>

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
																				for (int i=0; i<listCount; i++)
																				{
																					userItem = (UserItem)listData.get(i);
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
																											<!-- <col width="20"> -->
																											<col width="*">
																											<col width="1">
																											<col width="15%">
																											<col width="1">
																											<col width="6%">
																											<col width="1">
																											<col width="10%">
																											<col width="1">
																											<col width="16%">
																											<col width="1">
																											<col width="12%">
																											<col width="1">
																											<col width="12%">
																											<col width="1">
																											<col width="12%">
																										</colgroup>
																										<tr> 
																											<!-- 
																											<td nowrap>
																												<a href="javascript:goSubmit('view','true','<%=userItem.uid%>' );"><img src="../common/images/btn_listdot.gif" border=0 title="새창으로 열기"></a>
																											</td>
																											 -->
																											<td class="SubText">&nbsp;
																												<a href="javascript:goSubmit('view','true','<%=userItem.uid%>' );"><%="".equals(userItem.nName) ? "[이름없음]":userItem.nName%></a>
																											</td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=userItem.dpName%></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=userItem.upName %></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=userItem.sabun %></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=Convert.TextNullCheck(userItem.mainJob) %></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=Convert.TextNullCheck(userItem.telNo) %></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=Convert.TextNullCheck(userItem.cellTel) %></td>
																											<td align="center"></td>
																											<td align="center" class="SubText"><%=Convert.TextNullCheck(userItem.userName) %></td>
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
																				if (listCount == 0){
																					out.println("<table width='100%' style='height:expression(document.body.clientHeight-220);' border='0' cellspacing='0' cellpadding='0'><tr>"
																							+ "<td width='5'></td><td>"+StringUtil.getNODocExistMsg()
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
																</div>
																<!-- 페이지 / 검색 -->
																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="36" id="viewPage">
																	<tr>
																		<td bgcolor="90b3d2" align="center" valign="middle">
																			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="30">
																				<tr>
																					<td width="3"></td>
																					<td bgcolor="ebf0f8"> 
																						<table width="100%" border="0" cellspacing="0" cellpadding="0">
																							<tr>
																								<td width="15">&nbsp;</td>
																								<td width="290" class="PageNo">
																									<%
																									  String linkURL = request.getRequestURI();
																									%>
																									<jsp:include page="../common/page_numbering.jsp" flush="true">
																										<jsp:param name="totalcount" value="<%=listCount%>"/>
																										<jsp:param name="pg" value="<%=pg%>"/>
																										<jsp:param name="linkurl" value="<%=linkURL%>"/>
																										<jsp:param name="paramstring" value=""/>
																										<jsp:param name="linktype" value="1"/>
																										<jsp:param name="listppage" value="<%=listPPage%>"/>
																										<jsp:param name="blockppage" value="<%=blockPPage%>"/>
																									</jsp:include>
																								</td>
																								<td>&nbsp;</td>
																								<td width="340" align="right"> 
																									<table border="0" cellspacing="0" cellpadding="0">
																										<tr>
																											<td width="55"></td>
																											<td width="215">
																											</td>
																											<td width="55">
																											</td>
																										</tr>
																									</table>
																								</td>
																								<td width="5">&nbsp;</td>
																							</tr>
																						</table>
																					</td>
																					<td width="3"></td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																</table>
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