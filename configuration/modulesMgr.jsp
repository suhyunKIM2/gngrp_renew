<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.configuration.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.NoAdminAuthorityException" %>
<% 	request.setCharacterEncoding("utf-8"); %>

<%@ include file="../common/usersession.jsp"%>
<%
String[] module_value = null;
	
ModuleMgr MoMgr = null;
ArrayList ModuleList = null;
ModuleItem MoItem = null;

if(request.getParameter("cmd") != null){
	module_value = request.getParameterValues("module_data");
	MoMgr = new ModuleMgr(loginuser);
	MoMgr.getDBConnection();
	MoMgr.MgrUpdate(module_value);
	response.sendRedirect("./modulesMgr.jsp");
}else{	

	try
	{
		MoMgr = new ModuleMgr(loginuser);
		MoMgr.getDBConnection();
		ModuleList = MoMgr.getModuleList();
	}
	catch(NoAdminAuthorityException ex)
	{
		out.write("<script language='javascript'>alert('관리권한이 없습니다');history.back();</script>");
		//out.close();
		return;
	}
	finally
	{
		MoMgr.freeDBConnection();
	}
%>
<HTML>
<HEAD>
<TITLE>모듈관리자</TITLE>
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script language="javascript">
	SetHelpIndex("admin_modulemgr");
</script>
<script language="javascript">
function docSubmit()
{
	yn = confirm("해당인원을 각 모듈의 관리자로 지정하시겠습니까?") ;
	if (yn) {
		document.form1.cmd.value="update";
		document.form1.submit()
	}
	
}

function getOwnID(num)
{
   var url = "" ;
   var sWidth = "320" ;
   var sHeight = "450" ;   

   url = "../common/department_selector.jsp?openmode=1&isadmin=0&expand=1&onlydept=0&onlyuser=1&winname=parent&conname=form1" ;
   
   var objDaeri = new Object() ;
   var returnval = OpenModal( url , objDaeri, sWidth , sHeight ) ;
   if (returnval != null && returnval != "") {
        //alert(returnval);
        //이름/uid/직위/부서명
        var arrVal = returnval.split(":") ;
        var sNm = arrVal[0] ;  //
        var sID = arrVal[1] ;  //ID
        var sUnm = "" ;
        var sDnm = "" ;
        var sText = sNm ;
		
		sUnm = arrVal[2] ;
		sDnm = arrVal[3] ;
		sText += "/" + sUnm + "/" + sDnm ;
		
		//var docmodule = eval("document.form1.title_" + moduleId); 
		//docmodule.value = sText ;
		var form = document.form1;
		form.module_data[num].value = sID+"/"+form.moduleid[num].value;
		form.title[num].value = sText;
		

    }
}
</script>
</HEAD>

<body>

<form name="form1" method="POST" action="./modulesMgr.jsp" >
<input type="hidden" name="cmd" value="">

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
									<td width="4"></td>
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
																		<td class="SubTitle">모듈관리자 지정</td>
																		<td valign="bottom" width="250" align="right"> 
																			<table border="0" cellspacing="0" cellpadding="0" height="17">
																				<tr> 
																					<td valign="top" class="SubLocation">관리자 &gt; <b>모듈관리자 지정</b></td>
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
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:docSubmit();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
																				<tr>
																					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;저장</span></td>
																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
																				</tr>
																			</table>
																		</td>
																		<td width="55"> 
																			
																		</td>
																		<td>&nbsp;</td>
																		<td width="16" class="DocuNo">
																		
																		</td>
																		<td width="70" class="DocuNo"></td>
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
																<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
																	<tr> 
																		<td> 
																		<!-- 본문 DATA 목록 -->
																			<table width="800" border="0" cellpadding="0" cellspacing="0">
																				<tr>
																					<td valign="top">
																						<table width="500" border="0" cellspacing="0" cellpadding="0">
																							<tr>
																								<td class="td_ce1"><b>해당모듈<b></td>
																								<td class="td_ce1"><b>관리자지정<b></td>
																							</tr>
																							<%
																							  for (int i=0; i<ModuleList.size(); i++)
																							  {
																								  MoItem = (ModuleItem)ModuleList.get(i);
																							%>

																							<tr>
																								<td class="td_ce1" width="170"><input type="hidden" name="module_data" value="<%=MoItem.uId%>/<%=MoItem.moduleId%>" readonly><%=MoItem.moduleName%>(<%=MoItem.moduleId%>)<input type="hidden" name="moduleid" value="<%=MoItem.moduleId%>">
																								</td>
																								<td class="td_ce2" width="330"><input type="text" name="title" value="<%=MoItem.infoStr%>" style="width:250" readonly>&nbsp;&nbsp;&nbsp;<a href="javascript:getOwnID('<%=i%>');"><img src=../common/images/i_search.gif align=absmiddle border=0></a></td>
																							</tr>
																							<% } %>
																						</table>
																					</td>
																					<td width="300" style="padding:10 10 10 10;" valign="top">
																						. 각각의 모듈별 관리자를 지정합니다.
																					</td>
																				</tr>
																			</table>
																		<!-- 본문 DATA 끝-->
																		</td>
																	</tr>
																	<tr> 
																		<td height="15"></td>
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
<%}%>