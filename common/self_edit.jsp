<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.Convert" %>
<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="./usersession.jsp"%>
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
	//협력업체 권한 체크
	if (loginuser.securityId < 1){
		out.print("<script language='javascript'>alert('사용권한이 없습니다.');history.back();</script>");
		//out.close();
		return;
	}
	ConfigUserEnv userView = null;
	UserItem userItem = null;
	ConfigItem cfItem = null;
	long mailBoxSize = 0;
	long sendMailSize = 0;
	int listPPage = 0;
	int blockPPage = 0;
	String seTitle = "";
    String sDomain = "" ; 
    boolean loginMgr = false;
    Hashtable cfHash2 = null;
    String userDomain = "";
	try
	{
		userView = new ConfigUserEnv(loginuser);
		userView.getDBConnection();
		userItem = userView.getSelfInfo();

		Hashtable cfHash = ConfigTool.getUserConfigs(userView.SQLConn(), loginuser.uid);
		cfHash2 = ConfigTool.getConfigs(userView.SQLConn());
		cfItem = (ConfigItem)cfHash.get("MAILDOMAIN");				// Mail Domain
		if (cfItem != null) userDomain = cfItem.cfValue;

		cfItem = (ConfigItem)cfHash.get(application.getInitParameter("CONF.LIST_P_PAGE"));			// list per page
		if (cfItem != null) listPPage = Integer.parseInt(cfItem.cfValue);

		cfItem = (ConfigItem)cfHash.get(application.getInitParameter("CONF.BLOCK_P_PAGE"));			// block per page
		if (cfItem != null) blockPPage = Integer.parseInt(cfItem.cfValue);

		cfItem = (ConfigItem)cfHash.get(application.getInitParameter("CONF.MAIL_BOX_SIZE"));		// mail box size
		if (cfItem != null) mailBoxSize = Long.parseLong(cfItem.cfValue);
		mailBoxSize = mailBoxSize/(1024*1024);

		cfItem = (ConfigItem)cfHash.get(application.getInitParameter("CONF.SEND_MAIL_SIZE"));		// send mail size
		if (cfItem != null) sendMailSize = Long.parseLong(cfItem.cfValue);
		sendMailSize = sendMailSize/(1024*1024);

		seTitle = CommonTool.getSecurityTitle(userView.SQLConn(), userItem.securityId);

        //도메인 주소를 가져오자.
        cfItem = ConfigTool.getConfigValue(userView.SQLConn(), application.getInitParameter("CONF.DOMAIN"));
        sDomain = cfItem.cfValue;
        
        //로그인 계정 관리
        cfItem = nek.common.ConfigTool.getConfigValue(userView.SQLConn(), "LOGINMODULE");
		System.setProperty("1", "true");
		loginMgr = Boolean.getBoolean(cfItem.cfValue.toString());

	}
	finally
	{
		userView.freeDBConnection();
	}
%>
<HTML>
<HEAD>
<TITLE>개인정보</TITLE>
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script src="<%=scriptPath %>/DatePicker.js"></script>
<script language="javascript">
	SetHelpIndex("config_selfedit");
</script>
<script language="javascript">
var bImageCheck = false ; 

	function passCheck(pass, passc) {
		if (TrimAll(pass.value) == "")
		{
			alert("패스워드를 입력해 주세요");
			return false;
		}
		<%if(loginMgr){%>
		if (pass.value == "<%=Convert.TextNullCheck(userItem.loginId)%>"){
			alert("로그인ID와 패스워드가 같습니다. 변경해 주십시오.");
			pass.value = "";
			passc.value = "";
			pass.focus();
			return false;
		}
		if (pass.value.length<4){
			alert("패스워드는 4자리이상  되어야 합니다.");
			pass.value = "";
			passc.value = "";
			pass.focus();
			return false;
		}
		if (!isAlphaNumeric(pass.value)){
			alert("영문/숫자가 포함 되어야 합니다.");
			pass.value = "";
			passc.value = "";
			pass.focus();
			return false;
		}
		if (!passBefore(pass.value)){
			alert("직전 패스워드입니다.");
			pass.value = "";
			passc.value = "";
			pass.focus();
			return false;
		}
		<%}%>
		if ( pass.value != passc.value ) {
			alert("패스워드와 패스워드확인이 같지 않습니다.\n다시 입력하여 주십시요.");
			pass.value = "";
			passc.value = "";
			pass.focus();
			return false;
		}
		return true;
	}
	
	//직전패스워드 체크
	function passBefore(passWd){
		
		var objXmlHttp = new ActiveXObject("Microsoft.XMLHTTP"); 
		var sURL="../common/password_check.jsp?password="+ encodeURI(passWd); 
		objXmlHttp.open("POST",sURL,false, "", ""); 
		objXmlHttp.send();
		if(objXmlHttp.responseText!=0){
			return false;
		}
		return true;
	}
	
	//영문/숫자를 혼합으로 구성되어있는지 체크하는 함수
	function  isAlphaNumeric(str) {
		var intChk = false;
		var strChk = false;
		var strAry = /[a-zA-Z]/; 
		var intAry = /[0-9]/;
		for (var i = 0; i < str.length; i++) {
			if (strAry.test(str.charAt(i))) {
				strChk = true;
			}
		}
		for (var i = 0; i < str.length; i++) {
			if (intAry.test(str.charAt(i))) {
				intChk = true;
			}
		}
		if(intChk&&strChk){
			return true;
		}
		return false;
	}

	function goSubmit()
	{
		var frm = document.submitForm;
        if (bImageCheck){
            alert("이미지 파일을 선택하십시오") ;  
            return ; 
        }
		if (frm.pwdcheck.checked)
		{
			if (!passCheck(frm.pwdhash, frm.confirm_pwdhash))return;
		}
		if (TrimAll(frm.nname.value) == "")
		{
			alert("이름을 입력해 주세요");
			frm.nname.focus();
			return;
		}
		if ((TrimAll(frm.birthday.value) == "")  || ( frm.birthday.value.length < 10 ))
		{
			alert("생년월일를 입력해 주세요");
            frm.birthday.focus();
			return ;
		}
/*
       activ-x 보안 수준이 최저 수준일때만 가능함.
		if (filsesizecheck(frm.photo)) {
			alert("잘못된 사이즈") ; 
			return;
		}
*/
		
		var cnt = submitForm.email.selectedIndex;
		var email = submitForm.email.options[cnt].value;
		var tmpStr = email.split("@");
		frm.userdomain.value = tmpStr[1];
		
		frm.method = "POST";
		frm.action = "./self_write.jsp";
		//alert("end");
		frm.submit();
	}

	function setUserPhoto(fileObj)
	{
        
		if (fileObj.value != "") {
            document.all.userphoto.src = fileObj.value;
        } else {
            document.all.userphoto.src = "./images/photo_user_default.gif";             
        }

        if (document.all.userphoto.src =="http://<%= sDomain%>/common/images/photo_user_default.gif" ) 
        {   
            alert("이미지 파일을 선택하십시오") ;  
            bImageCheck = true ; 
        } else {
            bImageCheck = false ; 
        }
	}

	function openOrgaTree(dpId)
	{
		var url = "../common/department_selector.jsp?onlydept=1&openmode=0&expand=1&expandid=" + dpId;
		winwidth = "320";
		winheight = "450";
		winleft = (screen.width - winwidth) / 2;
		wintop = (screen.height - winheight) / 2;
		winoptions = 'width=' + winwidth + ', height=' + winheight + ', left=' + winleft + ', scroll=no, top=' + wintop + ', toolbar=no';
		window.open(url,"orgaselftree",winoptions)
	}

	function fnopenzipcode() {
		var url= "../support/zipcode_form.jsp";
		winwidth = "379";
		winheight = "323";
		winleft = (screen.width - winwidth) / 2;
		wintop = (screen.height - winheight) / 2;
		winoptions = 'width=' + winwidth + ', height=' + winheight + ', left=' + winleft + ', top=' + wintop + ', toolbar=no';

		var addrwin=window.open(url,"",winoptions)
	}
/*
	function filsesizecheck(fileObj) {
	    var fso, f, s;
		fso = new ActiveXObject("Scripting.FileSystemObject");
		alert("bbbb") ; 
		f = fso.GetFile(fileObj.value);
		alert("aaa") ; 
		//f = fso.GetFile("c:\\a\\gins.zip");
		//s = f.Name + " uses " + f.size + " bytes.";
		if (f.size >(1024*1024)) return false ; 
		else return true ; 
		 
	}
*/
	function changeEmail(){
		var cnt = submitForm.email.selectedIndex;
		var email = document.getElementById("email");
		email.innerHTML  = submitForm.email.options[cnt].value;
	}
</script>


</HEAD>

<body>
<form name="submitForm" enctype="multipart/form-data">
<input type="hidden" name="uid" value="<%=loginuser.uid%>">
<input type="hidden" name="userdomain" value="">

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
																		<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_configuration.jpg" width="27" height="27"></td>
																		<td class="SubTitle">개인정보</td>
																		<td valign="bottom" width="250" align="right"> 
																			<table border="0" cellspacing="0" cellpadding="0" height="17">
																				<tr> 
																					<td valign="top" class="SubLocation">환경설정 &gt; <b>개인정보</b></td>
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
																			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
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
																			<!-- 개인정보 타이틀 시작 -->
																			<table width="800" border="0" cellspacing="0" cellpadding="0">
																				<tr height=30>
																					<td class=i_body><img src=../common/images/i_body.gif align=absmiddle>기본정보</td>
																				</tr>
																			</table>
																			<!-- 기본정보 타이틀 끝 -->

																			<table width="100%" cellspacing="0" cellpadding="0" border="0">
																				<colgroup>
																					<col width="15%">
																					<col width="*">
																				<colgroup>

																				<tr>
																					<td valign=middle align=center width=120 height=100%  class="td_le2" nowrap>
																						<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
																							<tr>
																								<td valign=middle align=center width=120 height=100%>
																									<IMG id="userphoto"  src="../userdata/photos/<%=loginuser.uid%>" border=0 width="100" height="120" onerror="this.src='./images/photo_user_default.gif';">
																								</td>
																							</tr>
																						</table>
																					</td>
																					<td  valign=top height=100%>

																						<table width="100%" border="0" cellspacing="0" cellpadding="0">
																							<colgroup>
																								<col width="120">
																								<col width="220">
																								<col width="120">
																								<col width="220">
																							</colgroup>
																							<tr>
																								<td class="td_le1" nowrap>로그인 ID</td>
																								<td class="td_le2">
																									<%=Convert.TextNullCheck(userItem.loginId)%>
																								</td>
																								<td class="td_le1" nowrap>e-Mail</td>
																								<td class="td_le2"><div id="email">
																								<%if(userItem.email==null||"".equals(userItem.email)){%>
																									<%=Convert.TextNullCheck(userItem.userName + "@"+sDomain)%>
																								<%}else{%>
																									<%=userItem.email%>
																								<%}%></div>
																								<input type="hidden" name="username" value="<%=userItem.userName %>">
																								</td>
																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>E-MAIL변경</td>
																								<td class="td_le2" colspan=3>
																									<select name="email" class="fld_200" onChange="changeEmail();">
																									<%
																										cfItem = (ConfigItem)cfHash2.get(application.getInitParameter("CONF.DOMAIN"));
																									%>
																										<option value="<%=Convert.TextNullCheck(userItem.userName)%>@<%=cfItem.cfValue%>" ><%=cfItem.cfValue%></option>
																									<%
																										cfItem = (ConfigItem)cfHash2.get(application.getInitParameter("CONF.MULTIDOMAIN"));
																										String str = "";
																										StringTokenizer token = new StringTokenizer(cfItem.cfValue, ",");
																										if(token.countTokens()>0){
																											while(token.hasMoreTokens()){
																												str= token.nextToken();
																									%>
																										<option value="<%=Convert.TextNullCheck(userItem.loginId)%>@<%=str%>" <%=setSelectedOption(str, userDomain)%> ><%=str%></option>
																									<%
																											}
																										}
																									%>
																											
																									</select>
																								</td>
																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>패스워드변경<input type="checkbox" name="pwdcheck" value="1"></td>
																								<td class="td_le2">
																									<input type="password" name="pwdhash" onKeyUp="CheckTextCount(this, 40);"  class="fld_150">
																								</td>
																								<td class="td_le1" nowrap>패스워드확인</td>
																								<td class="td_le2">
																									<input type="password" name="confirm_pwdhash" onKeyUp="CheckTextCount(this, 40);"  class="fld_150">
																								</td>
																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>사 번</td>
																								<td class="td_le2">
																									<%=Convert.TextNullCheck(userItem.sabun)%>
																									<input type="hidden" name="sabun" maxlength="14"  class="fld_150" value="<%=Convert.TextNullCheck(userItem.sabun)%>">
																								</td>
																								<td class="td_le1" nowrap>입사일자</td>
																								<td class="td_le2">
																									<% if(userItem.enterDate != null) out.println(userItem.enterDate); %>
																									<input type="hidden" name="enterdate" maxlength="10"  class="fld_150" value="<% if(userItem.enterDate != null) out.println(userItem.enterDate); %>" onfocus="ShowDatePicker()" onclick="ShowDatePicker()" readonly>
																								</td>
																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>이름(한글) <span class="readme"><b>*</b></td>
																								<td class="td_le2">
																									<%=Convert.TextNullCheck(userItem.nName)%>
																									<input type="hidden" name="nname" onKeyUp="CheckTextCount(this, 40);" size=32 class="fld_150" value="<%=Convert.TextNullCheck(userItem.nName)%>">
																								</td>
																								<td class="td_le1" nowrap>이름(영문)</td>
																								<td class="td_le2">
																									<input type="text" name="ename" onKeyUp="CheckTextCount(this, 40);" size=32 class="fld_150" style="ime-mode:disabled;"  value="<%=Convert.TextNullCheck(userItem.eName)%>">
																								</td>
																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>부서</td>
																								<td class="td_le2"><%=Convert.TextNullCheck(userItem.dpName)%>
																								<a href="javascript:openOrgaTree('<%=userItem.dpId%>');"><img src="../common/images/i_search.gif" border="0" align="absmiddle"></a>
																								</td>
																								<td class="td_le1" nowrap>보안등급</td>
																								<td class="td_le2"><%=seTitle%>
																								</td>

																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>직위</td>
																								<td class="td_le2"><%=Convert.TextNullCheck(userItem.upName)%>
																								</td>
																								<td class="td_le1" nowrap>직책</td>
																								<td class="td_le2"><%=Convert.TextNullCheck(userItem.udName)%>
																								</td>
																							</tr>
																							<tr>
																								<td class="td_le1" nowrap>업무</td>
																								<td class="td_le2">
																									<input type="text" name="mainjob" onKeyUp="CheckTextCount(this, 100);" class="fld_150" value="<%=Convert.TextNullCheck(userItem.mainJob)%>">
																								</td>
																								<td class="td_le1" nowrap>겸직</td>
																								<td class="td_le2">
																									<input type="text" name="addjob" onKeyUp="CheckTextCount(this, 100);" class="fld_150" value="<%=Convert.TextNullCheck(userItem.addJob)%>">
																								</td>
																							</tr>
																						</table>
																					</td>
																				</tr>
																			</table>

																			<table class=tblspace05><tr><td></td></tr></table>

																			<!-- 개인정보 타이틀 시작 -->
																			<table width="100%" border="0" cellspacing="0" cellpadding="0">
																				<tr height=30>
																					<td class=i_body><img src=../common/images/i_body.gif align=absmiddle>개인정보</td>
																				</tr>
																			</table>
																			<!-- 개인정보 타이틀 끝 -->

																			<table width="100%" border="0" cellspacing="0" cellpadding="0">
																				<colgroup>
																					<col width="15%">
																					<col width="35%">
																					<col width="15%">
																					<col width="35%">
																				</colgroup>
																				<tr>
																					<td class="td_le1" nowrap>전화(사무실)</td>
																					<td class="td_le2">
																						<input type="text" name="telno" maxlength=20 class="fld_150" value="<%=Convert.TextNullCheck(userItem.telNo)%>">
																					</td>
																					<td class="td_le1" nowrap>InternetMail</td>
																					<td class="td_le2">
																						<input type="text" name="internetmail" class="fld_150" style="ime-mode:disabled"  value="<%=Convert.TextNullCheck(userItem.internetMail)%>">
																					</td>
																			<!-- 		<td class="td_le1" nowrap>FAX</td>
																					<td class="td_le2">
																						<input type="text" name="faxno" maxlength=20 class="fld_150"  value="<%=Convert.TextNullCheck(userItem.faxNo)%>">
																					</td> -->
																				</tr>
																				<tr>
																					<td class="td_le1" nowrap>전화(자택)</td>
																					<td class="td_le2">
																						<input type="text" name="hometel" maxlength=20 class="fld_150" value="<%=Convert.TextNullCheck(userItem.homeTel)%>">
																					</td>
																					<td class="td_le1" nowrap>핸드폰</td>
																					<td class="td_le2">
																						<input type="text" name="celltel" maxlength=20 class="fld_150"  value="<%=Convert.TextNullCheck(userItem.cellTel)%>">
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1" nowrap>생년월일</td>
																					<td class="td_le2">
																						<input type="text" name="birthday" maxlength="10"  class="width:60%" value="<% String sbirth = Convert.TextNullCheck(userItem.birthDay) ; if (sbirth.equals("0000-00-00")) sbirth = "";  out.write(sbirth) ; %>" onfocus="ShowDatePicker()" onclick="ShowDatePicker()"  onkeyup="goKeyUp(this);"  maxlength="10">	
																						&nbsp;&nbsp;&nbsp;음력 <input type="checkbox" name="issolbirth" value="0" <% if (userItem.IsbirthDay == 0) out.write("checked") ;  %>>
																					</td>
																					<td class="td_le1" nowrap>사진</td>
																					<td class="td_le2">
																						<input type="file" name="photo" value="" class="fld_250" onchange="setUserPhoto(this);">
																					</td>
																				</tr>

																				<tr>
																					<td class="td_le1" nowrap rowspan="2">주소</td>
																					<td class="td_le2" colspan="3">
																						<input type="text" name="zipcode" onclick="javascript:fnopenzipcode();" class="fld_100" value="<%=Convert.TextNullCheck(userItem.zipCode)%>" readonly="yes">
																						<a href="javascript:fnopenzipcode()"><img src=../common/images/act_postsearch_off.gif border=0 onmouseover="btn_on(this)" onmouseout="btn_off(this)" align="absmiddle"></a>
																						&nbsp;<input type="text" name="address" style="width:400px;" value="<%=Convert.TextNullCheck(userItem.address)%>" readonly="yes">
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le2" colspan="3">
																						<input type="text" name="address2" style="width:400px;" value="<%=Convert.TextNullCheck(userItem.address2)%>">
																						(※나머지 주소 입력)
																					</td>
																				</tr>
																			</table>
																			<table class=tblspace05><tr><td></td></tr></table>


																			<!-- 환경정보 타이틀 시작 -->
																			<table width="100%" border="0" cellspacing="0" cellpadding="0">
																				<tr height=30>
																					<td class=i_body><img src=../common/images/i_body.gif align=absmiddle>환경정보</td>
																				</tr>
																			</table>
																			<!-- 환경정보 타이틀 끝 -->

																			<table width="100%" border="0" cellspacing="0" cellpadding="0">
																				<colgroup>
																					<col width="15%">
																					<col width="35%">
																					<col width="15%">
																					<col width="35%">
																				</colgroup>
																				<tr>
																					<td class="td_le1" nowrap>편지함 용량</td>
																					<td class="td_le2"><%=mailBoxSize%>&nbsp;MB
																					</td>
																					<td class="td_le1" nowrap>보내는메일크기 제한</td>
																					<td class="td_le2"><%=sendMailSize%>&nbsp;MB
																					</td>
																				<!--tr>
																					<td class="td_le1" nowrap width="120">다중로그인</td>
																					<td class="td_le2" colspan="3">
																						<input type="checkbox" disabled>다중로그인 가능
																					</td>
																				</tr-->
																				<tr>
																					<td class="td_le1" nowrap >list/page</td>
																					<td class="td_le2">
																						<select name="listppage" class="fld_100">
																							<option value="5"  <%=setSelectedOption(5,listPPage)%>>5</option>
																							<option value="10" <%=setSelectedOption(10,listPPage)%>>10</option>
																							<option value="15" <%=setSelectedOption(15,listPPage)%>>15</option>
																							<option value="20" <%=setSelectedOption(20,listPPage)%>>20</option>
																							<option value="25" <%=setSelectedOption(25,listPPage)%>>25</option>
																							<option value="30" <%=setSelectedOption(30,listPPage)%>>30</option>
																							<option value="35" <%=setSelectedOption(35,listPPage)%>>35</option>
																							<option value="40" <%=setSelectedOption(40,listPPage)%>>40</option>
																							<option value="45" <%=setSelectedOption(45,listPPage)%>>45</option>
																							<option value="50" <%=setSelectedOption(50,listPPage)%>>50</option>
																						</select>
																					</td>
																					<td class="td_le1" nowrap >block/page</td>
																					<td class="td_le2">
																						<select name="blockppage" class="fld_100">
																							<option value="5"  <%=setSelectedOption(5,blockPPage)%>>5</option>
																							<option value="10" <%=setSelectedOption(10,blockPPage)%>>10</option>
																							<option value="15" <%=setSelectedOption(15,blockPPage)%>>15</option>
																							<option value="20" <%=setSelectedOption(20,blockPPage)%>>20</option>
																						</select>
																					</td>
																				</tr>
																				<tr>
																					<td class="td_le1" nowrap>SMS 발송건수</td>
																					<td class="td_le2"><%=userItem.smsCnt %> 건</td>
																					<td class="td_le1" nowrap></td>
																					<td class="td_le2"></td>
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