<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="nek.approval.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>

<%!
    String SELECT_FLAG = ApprDocCode.APPR_SETTING_SEL ;
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
%>
<%
	//협력업체 권한 체크
	if (loginuser.securityId < 1){
		out.print("<script language='javascript'>alert('사용권한이 없습니다.');history.back();</script>");
		return;
	}

    String sUid = loginuser.uid ;  //
    String sDpId = loginuser.dpId ;  //
    String sBujaeDpId = "" ;

    int iMenuId = Integer.parseInt( ApprUtil.setnullvalue(request.getParameter("menu"), ApprMenuId.ID_440_NUM) ) ;//메뉴번호
    String cmd = ApprUtil.setnullvalue(request.getParameter("cmd"), ApprDocCode.APPR_NEW) ; //신규-> null, 수정 -> edit,

    String sCheckSelect = ApprUtil.nullCheck(request.getParameter("selectcheck")) ;

//조회
    AppBujaeInfo appbujaeInfo = null ;
    ApprBuJae bujaeObj = null ;
    try
    {
        bujaeObj = new ApprBuJae() ;
        appbujaeInfo = bujaeObj.ApprBujaeSel( sUid) ;

    }catch(Exception e){
        Debug.println (e) ;
    } finally {
        bujaeObj.freeConnecDB() ;
    }

//보여줄 데이타 설정
    String sCheck = ApprUtil.nullCheck(appbujaeInfo.getCheck()) ;
    sCheckSelect = "" ;
    if ( sCheck.equals(ApprDocCode.APPR_SETTING_T) ) {
        sCheckSelect = SELECT_FLAG ;
    }

//조직도에서 펼쳐질 부서 찿기
//부서는 부재자가있다면 부재자의 부서를 없다면 내부서를 보여주어라.
    String sTempDpid = appbujaeInfo.getDpid() ;
    if ((sTempDpid == null) || ("".equals(sTempDpid) ) )
        sBujaeDpId = sDpId ;
    else sBujaeDpId = sTempDpid ;

//Debug.println(appbujaeInfo.getDaeID()) ;
%>
<!DOCTYPE html>
<html>
<head>
<title>부재자 지정</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" href="<%=cssPath %>/list.css" type="text/css">
<script language="javascript">
<!--
 //도움말
SetHelpIndex("appr_bujae") ;

function goSubmit()
{
    //if ( (isEmpty( "dptnm" )) && (document.mainForm.chbujae.checked) ) {
    if (isEmpty( "dptnm" )) {
        if (document.mainForm.chbujae.checked) {
            alert("<%=msglang.getString("appr.select.decide.another") /* 대결자를 지정하십시오 */ %>");
        } 
        return ;
    }

    var sText = "" ;
    if (document.mainForm.chbujae.checked) sText = "<%=msglang.getString("appr.absentee.set") /* 부재자를 설정하시겠습니까? */ %>" ;
    else sText = "<%=msglang.getString("appr.absentee.disable") /* 부재자를 해제하시겠습니까? */ %>" ;
    if (! confirm(sText))  return;

    //부재 설정해제 메세지
    document.mainForm.cmd.value = "<%= ApprDocCode.APPR_EDIT %>" ;
    document.mainForm.method = "post" ; 
    document.mainForm.submit() ;
}

function setDeptSelector(sVal)
{
    var arrVal = sVal.split(":") ; 
    var sNname = arrVal[0] ; // 사용자명
    var sUID = arrVal[1] ;  //UID
    var sUpNm = arrVal[2] ;  //직위명
    var sDpNm = arrVal[3] ;   //부서명

    if (sUID == "<%= sUid %>")
    {
        alert("<%=msglang.getString("appr.not.equals.login.decide") /* 로그인 한 사람과 대결자는 같은 사람으로 설정 할 수 없습니다. */ %>");
        return ;
    }

    document.mainForm.dptnm.value = sDpNm ;
    document.mainForm.upnm.value = sUpNm ;
    document.mainForm.nnm.value = sNname ;
    document.mainForm.uid.value = sUID ;

    if (!mainForm.chbujae.checked)
    {
        mainForm.chbujae.checked = true ;
    }
}

//(window.showModalDialog Version)
function getDaerigaModal() {
    var url = "../common/department_selector.jsp?openmode=1&isadmin=0&expand=1&expandid=<%= sDpId %>&onlydept=0&onlyuser=1&winname=parent&conname=mainForm" ;
    var objDaeri = new Object() ; 
    var returnval = OpenModal( url , objDaeri, 320 , 450 ) ;
    if (returnval != null) {            
        //alert(returnval);  
        setDeptSelector(returnval) ;
    }
}

//(dhtmlmodal Version)
function getDaeriga() {
	var url = "../common/department_selector.jsp?openmode=1&isadmin=0&expand=1&expandid=<%= sDpId %>&onlydept=0&onlyuser=1&winname=parent&conname=mainForm" ;
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_COMM1002", "iframe", url, "<%=msglang.getString("main.Approval") /* 전자결재 */ %>", 
		"width=320px,height=450px,resize=0,scrolling=1,center=1", "recal"
	);
}

function getObjDaeri() {
	return objDaeri;
}

function gohaeje()
{
    document.mainForm.chbujae.checked = false ;
    document.mainForm.dptnm.value = "" ;
    document.mainForm.upnm.value = "" ;
    document.mainForm.nnm.value = "" ;
    document.mainForm.reason.value = "" ;
}
//-->
</SCRIPT>
<style>
.td_ce1{height:50px;}
.td_le2{padding: 18px;}
.btn_goSubmit{width: 150px;
    margin: 5% auto;
    text-align: center;
    background: #266fb5;
    color: #fff;
    height: 40px;
    line-height: 40px;
    font-weight: 600;
    cursor: pointer;}
.td_le2 INPUT[type=text]{height:25px;}
</style>
</head>
<body style="padding: 0; margin: 0;">
<form NAME="mainForm" action="./appr_bujaecontrol.jsp" METHOD="post" onsubmit="return false;">
<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /><b> 
		<%//=ApprUtil.getNavigation(iMenuId) %>
		<%=msglang.getString("main.Approval") /* 전자결재 */ %> &gt;
		<%=msglang.getString("appr.menu.config") /* 환경설정 */ %> &gt;
		<%=msglang.getString("appr.menu.bujae") /* 부재중설정 */ %>
	</b></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
		<tr> 
			<td valign="top"> 
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
					<tr> 
						<td bgcolor="#FFFFFF" valign="top">
						
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="35px">&nbsp; </td>
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
<!-- 															<td height="1">  -->
<!-- 																<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27"> -->
<!-- 																	<tr>  -->
<%-- 																		<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_approval.jpg" width="27" height="27"></td> --%>
<%-- 																		<td class="SubTitle"><%= ApprUtil.getNavigation(iMenuId)%><!-- <%= ApprUtil.getTitleText(iMenuId) %>--></td> --%>
<!-- 																		<td valign="bottom" width="250" align="right">  -->
<!-- 																			<table border="0" cellspacing="0" cellpadding="0" height="17"> -->
<!-- 																				<tr>  -->
<%-- 																					<td valign="top" class="SubLocation">&nbsp;<!-- <%= ApprUtil.getNavigation(iMenuId)%>--></td> --%>
<%-- 																					<td align="right" width="15"><img src="<%=imagePath %>/sub_img/sub_title_location_icon.jpg" width="10" height="10"></td> --%>
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
																<div id="viewList" class="div-view" onpropertychange="div_resize();">
                                                                <div width="185" style="text-align: left;">
                                                                    <span onclick="getDaeriga()" class="button white medium">
                                                                    <img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("appr.select.bujae") /* 대결지정 */ %> </span>
                                                                 </div>
																<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
																	<tr> 
																		<td height="30" valign="top"> 
																		<!-- 본문 DATA 시작 -->
																			<table width="50%" cellspacing="0" cellpadding="0" border="0">
																				<tr height="10"><td colspan="4"></td></tr>
																				<tr>
																					<td width="5"></td>
																					<td width="100%" valign="top">
																						<table width="100%" cellspacing="0" cellpadding="0" border="0" >
																							<tr>
																								<td width="20%" class="td_ce1">
																									<%=msglang.getString("appr.absence") %><!--  부재설정-->
																									<font color="red">*</font>
																								</td>
																								<td class="td_le2" width="243">
																									<input type="checkbox" name="chbujae" id="chbujae" value="<%= ApprDocCode.APPR_SETTING_T %>" <% if (sCheck.equals( ApprDocCode.APPR_SETTING_T)) out.write("checked"); %> >
																								 	<label for="chbujae" style="cursor: pointer;"><%=msglang.getString("ope.use") %><%-- 사용 --%></label>
																								</td>
																								
																							</tr>
																							<tr>
																								<td width="20%" class="td_ce1"><%=msglang.getString("t.dpName") %><!--  부서--></td>
																								<td class="td_le2" width="243">
																									<input type="text" name="dptnm" value="<%= ApprUtil.nullCheck(appbujaeInfo.getDname()) %>" style="width:92%;" readonly>
																								</td>
																							</tr>
																							<tr>
																								<td width="20%" class="td_ce1"><%=msglang.getString("t.upName") %><!--  직위--></td>
																								<td class="td_le2">
																									<input type="text" name="upnm" value="<%= ApprUtil.nullCheck(appbujaeInfo.getUname()) %>"  style="width:92%;" readonly>
																								</td>
																							</tr>
																							<tr>
																								<td width="20%" class="td_ce1"><%=msglang.getString("t.name") %><!--  성명--></td>
																								<td class="td_le2">
																									<input type="text" name="nnm" value="<%= ApprUtil.nullCheck(appbujaeInfo.getNname()) %>" style="width:92%;" readonly>
																								</td>
																							</tr>
																							<tr>
																								<td width="20%" class="td_ce1"><%=msglang.getString("appr.out.reason") %><!-- 사유--></td>
																								<td class="td_le2" >
																									<textarea rows="3"  name="reason" style="height: 100px; width: 92%;" cols="20"><%= ApprUtil.nullCheck(appbujaeInfo.getReason())%></textarea>                    
																								</td>
																							</tr>
																						</table>
                                                                                        <div class="btn_goSubmit" onclick="goSubmit()" >
                                                                                            <%=msglang.getString("t.save") /* 저장 */ %>
                                                                                        </div>
																					</td>
																					<td width="20">
																			            <input type="hidden" name="cmd" value="<%= cmd %>" >
																			            <input type="hidden" name="apprdaeno" value="<%= ApprUtil.nullCheck(appbujaeInfo.getDaeID()) %>" >
																			            <input type="hidden" name="selectcheck" value="<%= sCheckSelect %>" >
																			            <input type="hidden" name="uid" value="<%=ApprUtil.nullCheck(appbujaeInfo.getBuJaeUID()) %>">
																			        </td>
																				</tr>
																			</table>
																			<!-- 본문 DATA 끝 -->
																		</td>
																	</tr>
																	<tr> 
																		<td height="15"></td>
																	</tr>
																</table>
																</div>
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
				</table>
			</td>
		</tr>
	</table>

</form>

</body>
</html>

<script>
previewCancel();	/* preview cancellation */
</script>