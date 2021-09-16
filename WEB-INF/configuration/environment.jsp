<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.common.SystemConfig" %>
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

	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>운영환경</title>
<%@ include file="../common/include.common.jsp"%>
<script language="javascript">
	//SetHelpIndex("admin_env");
</script>

<script type="text/javascript">
	function inputValidation(){
		var frm = document.getElementById("envWebForm");
		if (frm.elements["corpInfo.itemTitle"].value == ""){
			alert("<spring:message code='ope.c.company.name' text='회사명을 입력해 주세요.'/>");
			frm.elements["corpInfo.itemTitle"].focus();
			return false;
		}

		return true;
	}

	function goSubmit(){
		var frm = document.getElementById("envWebForm");
		/*
		var obj = document.getElementById("sendmailsize");
		if(obj.value>40){
			alert("보내는 메일크기의 제한 40M를 초과하였습니다.");
			obj.focus();
			return;
		}
		*/
		if (!inputValidation()) return;
		var changeSessTime = frm.elements["changeSessionTime"].checked;

		if(changeSessTime) {
			if(!confirm("<spring:message code='ope.c.sessionTime.change' text='세션시간을 변경하면 서비스가 재시작됩니다. \n변경하시겠습니까?'/>")){
				return;
			}
		}
		
		frm.submit();
	}
	
	function goSync(){
		if(!confirm("<spring:message code='ope.c.erp.sync' text='인사정보 동기화를 시작하시겠습니까?'/>")) return;
		var frm = document.getElementById("envWebForm");
		frm.action = "./syncOrgInfo.htm";
		frm.submit();
	}

	function setLogoPhoto(imgObj, fileObj)
	{
		if (fileObj.value != "") imgObj.src = fileObj.value;
		else imgObj.src = "";
	}
	
	function inputCheckSpecial(strValue){
		var mobj = document.getElementById("multiDomain");
		var strobj =  mobj.value
		var special=new Array("~","!","@","#","$","%","^","&","*","(",")","=","+","`","/");
		for(var i=0; i< special.length;i++){
		  		
		 	for(var s=0; s<strobj.length; s++){
				if(strobj.charAt(s) == special[i]) { 
					alert("<spring:message code='ope.c.specialCharacter.enter' text='특수문자는 입력하실수 없습니다.'/>"); 
					strValue.value = "";
					strValue.focus();
					return false;
				}
			}
		}
	}
	
	//비밀번호 주기 숨기기
	function showPass(value){
		var obj = document.getElementById("passTime");
		if(value=="1"){
			obj.style.display = "";
		}else if(value=="0"){
			obj.style.display = "none";
		}
	}
	
</script>
</head>
<body style="padding: 0;margin: 0;">
<form:form commandName="envWebForm" method="POST" action="environment_save.htm"  enctype="multipart/form-data" onsubmit="return false;">
<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="ope.operating.environment" text="운영환경"/> </span>
	</td>
	<td width="40%" align="right" style="padding:0 20px 0 0;">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
</table>
<!-- List Title -->

	<table width="95%" border="0" cellspacing="0" cellpadding="0" height="100%" style="margin:auto;">
		<tr> 
			<td valign="top"> 
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
					<!--<tr> 
						<td height="10" width="6" background="<%=imagePath %>/box_left_top.jpg"></td>
						<td height="6" background="<%=imagePath %>/box_center_top_left.jpg" style="background-repeat: no-repeat;" align="right"><img src="<%=imagePath %>/box_top_right.jpg" width="4" height="6"></td>
						<td valign="top" height="10px" width="6" background="<%=imagePath %>/box_right_top.jpg" ></td>
					</tr>-->
					<tr> 
						<!--<td background="<%=imagePath %>/box_left_bg.jpg" style="background-repeat: repeat-y;">&nbsp;</td>-->
                        <td style="background-repeat: repeat-y;">&nbsp;</td>
						<td bgcolor="#FFFFFF" valign="top">
						
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="4"></td>
									<td valign="top"> 
										<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
											<tr> 
												<td height="1"> 
												<!-- 타이틀 시작 -->
<!-- 													<table width="100%" border="0" cellspacing="0" cellpadding="0" height="44"> -->
<!-- 														<tr>  -->
<!-- 															<td height="11"></td> -->
<!-- 														</tr> -->
<!-- 														<tr>  -->
<!-- 															<td height="27">  -->
<!-- 																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- 																	<tr>  -->
<%-- 																		<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_admin.jpg" width="27" height="27"></td> --%>
<!-- 																		<td class="SubTitle">운영환경</td> -->
<!-- 																		<td valign="bottom" width="250" align="right">  -->
<!-- 																			<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 																				<tr>  -->
<!-- 																					<td valign="top" class="SubLocation">관리자 &gt; <b>운영환경</b></td> -->
<!-- 																				</tr> -->
<!-- 																			</table> -->
<!-- 																		</td> -->
<!-- 																	</tr> -->
<!-- 																</table> -->
<!-- 															</td> -->
<!-- 														</tr> -->
<!-- 														<tr>  -->
<!-- 															<td height="3"></td> -->
<!-- 														</tr> -->
<!-- 														<tr>  -->
<!-- 															<td height="3">  -->
<!-- 																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3"> -->
<!-- 																	<tr>  -->
<%-- 																		<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td> --%>
<!-- 																		<td bgcolor="eaeaea"></td> -->
<!-- 																	</tr> -->
<!-- 																</table> -->
<!-- 															</td> -->
<!-- 														</tr> -->
<!-- 													</table> -->
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
																<table width="100%"  border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
																	<tr> 
																		<td width="*">
<!-- 																			<a href="#" onclick="javascript:goSubmit();"> -->
<%-- 																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" OnMouseOut="ch_btn01.src='<%=imagePath %>/btn1_left.jpg'" OnMouseOver="ch_btn01.src='<%=imagePath %>/btn2_left.jpg'"> --%>
<!-- 																				<tr> -->
<%-- 																					<td width="23"><img id="btnIma01" name="ch_btn01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td> --%>
<%-- 																					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext" style="line-height:20px;">&nbsp;<spring:message code="t.save" text="저장"/></span></td> --%>
<%-- 																					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td> --%>
<!-- 																				</tr> -->
<!-- 																			</table> -->
<!-- 																			</a> -->
																			<a onclick="javascript:goSubmit();" class="button white medium">
																				<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="t.save" text="저장"/>
																			</a>
																			<a onclick="javascript:goSync();" class="button white medium">
																				<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="ope.sync" text="동기화"/>
																			</a>
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
																			<table width="100%" cellpadding="0" cellspacing="0" border="0" width="800">
																				<colgroup>
																					<col width="13%">
																					<col width="32%">
																					<col width="13%">
																					<col width="32%">
																				</colgroup>
																				<tr>
																					<td class="td_le1"><spring:message code="addr.company" text="회사"/></td>
																					<td class="td_le2"><form:input path="corpInfo.itemTitle" cssStyle="width:70%;" /></td>
																					<td class="td_le1"><spring:message code="ope.company.abb" text="회사약칭"/></td>
																					<td class="td_le2"><form:input path="corpInfo.upName" cssStyle="width:70%;" /></td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.domain" text="도메인명"/></td>
																					<td class="td_le2" colspan="3"><form:input path="domain" cssStyle="width:40%;"/></td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.domain.multi" text="멀티도메인명"/></td>
																					<td class="td_le2" colspan="3"><form:input path="multiDomain" cssStyle="width:90%;" onkeyup="inputCheckSpecial(this)" /></td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.groupwareURL" text="그룹웨어홈URL"/></td>
																					<td class="td_le2" colspan="3"><form:input path="homePath" cssStyle="width:40%;" /></td>
																				</tr>
<!-- 																				<tr style="display:none;"> -->
<!-- 																					<td class="td_le1">로그인로고이미지<br>(499 x 239) -->
<!-- 																					</td> -->
<!-- 																					<td  class="td_le2" valign="absmiddle" colspan="3"> -->
<!-- 																						<IMG id="loginphoto" src="../userdata/loginlogo" border=0 width="360" height="60" alt="로그인로고"><br> -->
<!-- 																						<input type="file" id="loginImg" name="loginImg" onchange="setLogoPhoto(loginphoto,this);" style="width:70%;"> -->
<!-- 																					</td> -->
<!-- 																				</tr> -->
																				<tr>
																					<td class="td_le1"><spring:message code="ope.img.logo" text="로고이미지"/><br>(164 x 54)
																					</td>
																					<td  class="td_le2" valign="absmiddle" colspan="3">
																						<IMG id="logophoto" src="../userdata/logo" border=0 width="160" height="46" alt="회사로고"><br>
																						<input type="file" id="corpImg" name="corpImg" onchange="setLogoPhoto(logophoto,this);" style="width:70%;">
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.img.campaign" text="캠페인로고이미지"/><br>(580 x 148)
																					</td>
																					<td  class="td_le2" valign="absmiddle" colspan="3">
																						<IMG id="campaign_logophoto" src="../userdata/campaign_logo" border=0 width="462" height="60" alt="캠페인로고"><br>
																						<input type="file" id="campaignImg" name="campaignImg" onchange="setLogoPhoto(campaign_logophoto,this);" style="width:70%;">
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.logo.campaign" text="캠페인로고"/>
																					</td>
																					<td  class="td_le2" valign="absmiddle" colspan="3">
																						<form:input path="campaignText"  cssStyle="width:80%;" maxlength="126" />
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.type.default.login" text="기본로그인유형"/></td>
																					<td class="td_le2">
																						<form:select path="loginType" cssStyle="width:100px;">
<!--																							<option value="1" <%=setSelectedOption("1", "${envWebForm.loginType}")%>>로그인ID</option>-->
<!--																							<option value="2" <%=setSelectedOption("2", "${envWebForm.loginType}")%>>이름</option>-->
<!--																							<option value="3" <%=setSelectedOption("3", "${envWebForm.loginType}")%>>사번</option>-->
																							<form:option value="1"><spring:message code="emp.loginId" text="로그인ID"/></form:option>
																							<form:option value="2"><spring:message code="t.name" text="이름"/></form:option>
																							<form:option value="3"><spring:message code="emp.id" text="사번"/></form:option>
																						</form:select>
																					</td>
																					<td class="td_le1"><spring:message code="ope.size.upload.file" text="업로드파일의 크기"/></td>
																					<td class="td_le2"><form:input path="uploadSize" cssStyle="ime-mode:disabled;text-align:right;width:100px;" onkeypress="if(CheckKeyCode() == false){ return false; };" />MB</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.size.user.mailbox" text="사용자메일박스크기"/></td>
																					<td class="td_le2"><form:input path="mailBoxSize" cssStyle="ime-mode:disabled;text-align:right;width:100px;" onkeypress="if(CheckKeyCode() == false){ return false; };" />MB</td>
																					<td class="td_le1"><spring:message code="emp.Outgoing.mail.sizex" text="보내는 메일크기"/></td>
																					<td class="td_le2"><form:input path="sendMailSize" cssStyle="ime-mode:disabled;text-align:right;width:100px;" onkeypress="if(CheckKeyCode() == false){ return false; };" />MB</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.number.pagelist" text="페이지당 목록수"/></td>
																					<td class="td_le2">
																						<form:select path="listPPage" cssStyle="width:100px;">
																							<form:option value="5">5</form:option>
																							<form:option value="10">10</form:option>
																							<form:option value="15">15</form:option>
																							<form:option value="20">20</form:option>
																							<form:option value="25">25</form:option>
																							<form:option value="30">30</form:option>
																							<form:option value="35">35</form:option>
																							<form:option value="40">40</form:option>
																							<form:option value="45">45</form:option>
																							<form:option value="50">50</form:option>
																						</form:select>
																					</td>
																					<td class="td_le1"></td>
																					<td class="td_le2">
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.product.version" text="제품버전"/></td>
																					<td class="td_le2"><%=SystemConfig.getInstance().getExtraConfigValue("VERSION")%></td>
																					<td class="td_le1"><spring:message code="ope.number.license" text="라이센스수"/></td>
																					<td class="td_le2"><%=SystemConfig.getInstance().getExtraConfigValue("LICENSECOUNT")%></td>
																				</tr>
																				<tr style="display:none;">
																					<td class="td_le1"><spring:message code="ope.session.time" text="세션시간"/></td>
																					<td class="td_le2" colspan=3>
																						<form:input path="sessionTime" cssStyle="ime-mode:disabled;text-align:right;width:100px;" onkeypress="if(CheckKeyCode() == false){ return false; };" maxlength="3" /><spring:message code="mail.time.minute" text="분"/>
																						<form:checkbox path="changeSessionTime" /><spring:message code="ope.setting" text="설정"/>
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1"><spring:message code="ope.policy.mng" text="계정정책관리"/></td>
																					<td class="td_le2" colspan=3>
																						<form:radiobutton path="loginModule" value="1" onclick="showPass(this.value);" /><spring:message code="ope.use" text="사용"/>
																						<form:radiobutton path="loginModule" value="0" onclick="showPass(this.value);" /><spring:message code="ope.notuse" text="사용안함"/>
																					</td>
																				</tr>
																				<tr style="display:none;">
																					<td class="td_le1"><spring:message text="IE전용 에디터"/></td>
																					<td class="td_le2" colspan=3>
																						<form:radiobutton path="ieEditor" value="none" /><label for="ieEditor1"><spring:message text="없음"/></label>
																						<form:radiobutton path="ieEditor" value="tagfree" /><label for="ieEditor2"><spring:message text="태그프리"/></label>
																					</td>
																				</tr>
																				<c:set var="passTimeStyle" value="style='display:none;'" />
																				<c:if test="${envWebForm.loginModule == 1}">
																					<c:set var="passTimeStyle" value="" />
																				</c:if>
																				<tr id="passTime" ${passTimeStyle }>
																					<td class="td_le1"><spring:message code="ope.passChange.cycle" text="비밀번호 변경주기"/></td>
																					<td class="td_le2" colspan="3">
																						<form:input path="passwordTime" cssStyle="ime-mode:disabled;text-align:right;width:100px;" onkeypress="if(CheckKeyCode() == false){ return false; };" maxlength="3" />일
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
						<!--<td background="<%=imagePath %>/box_right_bg.jpg" style="background-repeat: repeat-y;">&nbsp;</td>-->
                        <td style="background-repeat: repeat-y;">&nbsp;</td>
					</tr>
					<tr> 
						<!--<td height="10" width="6" background="<%=imagePath %>/box_left_bottom.jpg"></td>
						<td height="6" align="right" background="<%=imagePath %>/box_center_bottom_left.jpg" style="background-repeat: no-repeat; background-position:0% 70%;"><img src="<%=imagePath %>/box_bottom_right.jpg" width="4" height="6"></td>-->
                        <td></td>
                        <td></td>
						<!--<!--<td valign="bottom" height="10px" width="6" background="<%=imagePath %>/box_right_bottom.jpg"></td>-->
                        <td valign="bottom" height="10px" width="6" ></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

</form:form>
</body>
</html>