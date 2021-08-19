<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.approval.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;

%>
<%
    //각 경로 패스    
    String sUid = loginuser.uid;

    //String sFileSendUrl = "" ;

    // 기안자의 정보를 가져온다.
    String sLoginName = loginuser.nName;//성명
    String sLoginDpname = loginuser.dpName;//부서명
    String sLoginDpid = loginuser.dpId;//직책코드
    String sLoginUName = "" ;
    String oldApprid = "";
	String gianDpName = "";	//기안부서(사업장포함)

    String sChkDelete = ApprDocCode.APPR_SETTING_T ; //상신 후 결재자의 결재가 없다면 삭제 가능하게 하라.

    //현페이지의 성격을 나타낸다. ( 신규, 수정, 임시저장, 삭제)
	String cmd = ApprUtil.setnullvalue(request.getParameter("cmd"),  ApprDocCode.APPR_NEW ); 
	String sMenuId = "120" ;//메뉴번호
    int iMenuId = Integer.parseInt(sMenuId) ; 

    String sApprId = ApprUtil.nullCheck(request.getParameter("apprid")) ;

    String sResultPass = ApprUtil.setnullvalue(request.getParameter("resultpass"),  ApprDocCode.APPR_SETTING_T) ; // 결재 패스워드 일치여부
           
    String sPop = ApprUtil.nullCheck(request.getParameter("pop")) ;
    String sReceiveHistory = ApprUtil.nullCheck(request.getParameter("receivehistory")) ; //수신이력을 보여준다.수신함일 경우만.. 


	
    
    ApprovalDocReadInfo apprreadInfo = new ApprovalDocReadInfo() ; //info
    ApprovalDocRead apprObj = null ; 
    String sChkReceive = "" ; 
    boolean sChkHelp = false;
    try
    {        
        apprObj = new ApprovalDocRead(loginuser, sApprId, iMenuId,  application.getInitParameter("CONF.HOME_PATH")) ;
//--------------------------------------------------
//권한 검사 
if (iMenuId < ApprMenuId.ID_2000_NUM_INT) {
%>
<%@ include file="./appr_authory.jsp" %>
<%
} else {
%>
<!-- 페이지 보기 권한 -->
<%@ include file="../common/nekauthority.jsp" %>
<%//@ include file="./appr_adminright.jsp" %>
<%
}
        //--------------------------------------------------
        //doc 조회
        apprreadInfo = apprObj.ApprovalSelect() ;
        
        gianDpName = apprObj.getTopDepatment(apprreadInfo.getGianUID());
        
        //최초 협조 결재자 일때 내부 결재자 선택이 가능 유무
        if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)&&apprreadInfo.getApprIngNo()==0){
        	sChkHelp = true;
        }
        
        if(apprreadInfo.getApprFormid().length()==4){
        	oldApprid = apprObj.ApprTopAppridSelect();
        }
        
    }catch(Exception e){
        Debug.println (e) ;
    } finally {
        apprObj = null ;
    }
    
	//폼양식 로드
    ApprFormInfo apprformInfo = null  ;
    ApprForm formObj = null;
    try
    {
		formObj = new ApprForm() ;
        apprformInfo = formObj.ApprFormSel(apprreadInfo.getApprFormid()) ;

    } finally {
        formObj.freeConnecDB() ;
    }

//------------------------------------------------------------------------------------------------------------------
    // 첨부 파일 경로 가져오기   
    String baseURL = apprreadInfo.getHomePathUrl() ;
    if (!baseURL.endsWith("/")) baseURL += "/";    
    baseURL += "approval/appr_download.jsp?apprid=" + sApprId + "&fileno=";    
//------------------------------------------------------------------------------------------------------------------
// 보존년한과 비밀등급 가져오기
    ArrayList arrSecurityID = new ArrayList() ;
    ArrayList arrPeriod = new ArrayList() ;

    arrPeriod = apprreadInfo.getArrPreserve() ; 
    arrSecurityID = apprreadInfo.getArrSecurity() ; 

//------------------------------------------------------------------------------------------------------------------
    //수신인의 타이틀값 한글값을 UTF-8로 변환해서 보내야 한다.
    String sReceiveParam = "caption="+java.net.URLEncoder.encode("NEK 주소록", "UTF-8")+"&title="+java.net.URLEncoder.encode("수신인을 선택하세요", "UTF-8") ; 
%>


<HTML>
<HEAD>
<TITLE>결재 - <%= apprreadInfo.getFormTitle() %></TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!-- css -->
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/apprread.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<!-- script -->
<script src="<%= sJsScriptPath %>/common.js"></script>
<script src="./appr_imsi.js"></script>
<script src="./appr_doc.js"></script>
<script src="<%= sJsScriptPath %>/xmlhttp.vbs" type="text/vbscript"></script>
<SCRIPT LANGUAGE="JavaScript">
<!--
//도움말
<%

    String sHelpID = "appr_appringdoc" ; 
    if ((iMenuId > ApprMenuId.ID_300_NUM_INT && iMenuId < ApprMenuId.ID_2000_NUM_INT) || (iMenuId == ApprMenuId.ID_130_NUM_INT))
        sHelpID = "appr_apprfinishdoc" ; 
    else if (iMenuId > ApprMenuId.ID_2000_NUM_INT) 
        sHelpID = "appr_apprhamdoc" ; 

%>
SetHelpIndex("<%= sHelpID %>") ; 

var S_EDIT = "<%= ApprDocCode.APPR_EDIT %>" ;
var S_DEL = "<%= ApprDocCode.APPR_DELETE %>" ;
var S_URGENT = "<%= ApprDocCode.APPR_URGENT %>" ;

var MOVE_MENU_ID = "<%= ApprMenuId.ID_110_NUM %>" ;
var FORMID = "<%= sApprId%>" ;
var MUNU = "<%= sMenuId%>" ;

var RECEIVE_USER = "<%= ApprDocCode.RECEIVE_PERSON %>" ;
var RECEIVE_DEPT = "<%= ApprDocCode.RECEIVE_DEPT %>" ;
var VAL_T = "<%= ApprDocCode.APPR_SETTING_T %>" ;
var VAL_F = "<%= ApprDocCode.APPR_SETTING_F %>" ;
var RECEIVE_URL_PARAM = "<%= sReceiveParam %>" ;

var FormCode = "<%= apprreadInfo.getApprFormid() %>";

function editDoc(appID, sType)
{
	document.location.href = "./appr_imsidoc.jsp?apprid="+ appID + "&cmd=<%= ApprDocCode.APPR_EDIT %>";
}
    
function doPrint()
{ 
    //webprint에 있슴
    setReturnPath("../approval/appr_apprview.jsp?apprid="+FORMID+"&menu="+MUNU);
    //docPrint('top.frames(1).frames(1)');
    docPrint('document');
}
//-->
</SCRIPT>
</HEAD>

<body class="body">
<form name="mainForm" method="get" action="./appr_imsicontrol.jsp" ENCTYPE="multipart/form-data"  onsubmit="return false;">
<input type="hidden" name="cmd" value="<%= cmd %>"> <% //신규작성(new), 수정(edit), 삭제(del)  %>
<input type="hidden" name="menu" value="<%= sMenuId %>"> 
<input type="hidden" name="apprid" value="<%= sApprId %>"> 
<input type="hidden" name="renewedit" value="S">
<input type="hidden" name="approvaltype" value="<%= apprreadInfo.getApprovalType() %>"> 
<input type="hidden" name="formid" value="<%= apprreadInfo.getApprFormid() %>" >
<input type="hidden" name="sformid" value="<%= apprreadInfo.getApprFormid() %>" >
<input type="hidden" name="calltype" >
<input type="hidden" name="chkhelp" value="<%=sChkHelp %>">
<!-- popup에서 받는 값 -->
<input type="hidden" name="apprflagid" > 
<input type="hidden" name="apprxengeal" > 
<input type="hidden" name="apprnote" > 
<input type="hidden" name="apprpass" > 

<!-- 소유권이전 -->
<input type="hidden" name="receiveownid" >
<input type="hidden" name="ownid" value="<%= sUid %>">

<!-- 문서이관 -->
<%
    String sFileSeparator = java.io.File.separator ;
    String sDownPath = application.getInitParameter("datadir") ;
    if (!sDownPath.endsWith(sFileSeparator)) sDownPath += sFileSeparator;
    String sDownFilePathName = sDownPath + "approval"+sFileSeparator ;
//Debug.println(apprreadInfo.getFileName() ) ; 
%>

<!-- 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" id=btntbl>
	<tr> 
		<td height="27"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
				<tr> 
					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_approval.jpg" width="27" height="27"></td>
					<td width="200" class="SubTitle">전자결재 양식</td>
					<td valign="bottom" width="*" align="right"> 
						<table border="0" cellspacing="0" cellpadding="0" height="17">
							<tr> 
								<td valign="top" class="SubLocation"><%= ApprUtil.getNavigation(iMenuId)%></td>
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

<table><tr><td class="tblspace03"></td></tr></table>

<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0" id=btntbl>
	<tr>
		<td align="right"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
				<tr> 
					<td width="*">&nbsp;</td>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:editDoc('<%= sApprId %>', '');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;편집</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnDelete('<%= sApprId %>', '<%= ApprDocCode.APPR_DELETE %>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma03','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;삭제</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:doPrint();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma09','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma09" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;인쇄</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:window.close();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma08','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma08" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;닫기</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->

<%-- //결재자들을 보여주어라. --%>
<!--  제목을 appr_apprdoc_in.jsp 안에 삽입 -->
<%@ include file="./appr_apprview_in.jsp"%>

<table><tr><td class="tblspace09"></td></tr></table>

<!-- 제목 시작 -->
<table width="100%" cellspacing="0" cellpadding="0" class="table2">
	<tr>
		<td width="15%" class="td_ce1" >제 목</td>
		<td width="*" class="td_le2" style="word-break:break-all;"><%=  apprreadInfo.getSubject() %></td>
	</tr>	
</table>
<!-- 제목 끝 -->
<table><tr><td class="tblspace09"></td></tr></table>
<%if(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_1)){%>
	<%@ include file="./appr_regularform_read.jsp"%>
<%}else if(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_2)){%>
	<%@ include file="./appr_regularbusi_read.jsp"%>
<%}else if(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_3)){%>
	<%@ include file="./appr_regularreport_read.jsp"%>
<%}else if(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_4)){%>
	<%@ include file="./appr_regularchit_read.jsp"%>
<%}else{ %>
<!-- 본문시작 -->
<table width="100%" height="450" border="0" cellspacing="1" cellpadding="0" bgcolor="90B9CB" style="table-layout:fixed; border-collapse:collapse;">
	<tr>
		<td class=content bgcolor=ffffff valign=top  style="word-break:break-all;">
            <div id="dispContent" style="display:none;"> 
                <%= apprreadInfo.getBody() %>
           </div>
        </td>
	</tr>
</table>
<!-- 본문 끝 -->
<%} %>

</form>

</BODY>
</HTML>

<SCRIPT LANGUAGE="JavaScript"> 
<!--
    dispBody("dispContent") ;
//-->
</SCRIPT>
<% //결재 승인시 비밀번호가 다를경우에 메세지를 보여주자
    if (sResultPass.equals(ApprDocCode.APPR_SETTING_F)) 
    {
%>
<SCRIPT LANGUAGE="JavaScript">
<!--
    alert("결재 비밀번호가 틀립니다."); 
//-->
</SCRIPT>
<%
    }    
%>

<%
	if(apprformInfo!=null){
		if(apprformInfo.getPageType().equals("R")){
%>
<SCRIPT LANGUAGE="JavaScript">
	window.resizeTo(1000, 710);
</SCRIPT>
<%	
		}
	}
%>