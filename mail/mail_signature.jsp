<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.tagfree.util.MimeUtil" %>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.nodes.Element" %>
<%@ page import="org.jsoup.select.Elements" %>
<%-- <%@ page import="com.namo.NamoMime" %> --%>
<%@ include file="../common/usersession.jsp"%>
<%!
	private MailRepository repository = MailRepository.getInstance();

	//에디터 이미지 삭제
	private void deleteImgFiles(String docId, String imgDir) {
		String fileSaveName = "";
		File imgFile[] = null;
		fileSaveName = imgDir;
		File dir = new File(fileSaveName);
		if (!dir.exists()) return;
		imgFile = new File(fileSaveName).listFiles();
		for(int i = 0; i < imgFile.length; i++){
			if (imgFile[i] == null){
				continue;
			}
			imgFile[i].delete();
		}
	}
	
	//에디터 이미지 웹 서버에 저장 및 디코딩한 HTML반환
	private String uploadImgFiles(String uploadPath, String uploadUrl, String content) {
		String bef_contentHeader = content.substring(0, content.length() > 80 ? 80 : content.length());
		MimeUtil util = new MimeUtil(); 				// com.tagfree.util.MimeUtil 생성
		if(bef_contentHeader.indexOf("TWE_MIME") > -1){	// tagfree
			util.setMimeValue(content); 				// 작성된 본문 + 포함된 이진 파일의 MIME 값 지정
			util.setSavePath(uploadPath); 				// 저장 디렉터리 지정
			util.setSaveUrl(uploadUrl); 				// URL 경로 지정
			util.setInCharEncoding("iso8859-1");
			util.setOutCharEncoding("utf-8");
			util.setRename(true); 						// 파일을 저장 시에 새로운 이름을 생성할 것인지를 설정
			util.processDecoding(); 					// MIME 값의 디코딩 -> 이 때 포함된 파일은 모두 웹 서버에 저장된다
		}
		return util.getDecodedHtml(false);				// 디코딩된 HTML을 가져옴.
	}
	
	//디렉토리의 존재여부를 체크
	private void checkSaveDir(String saveDir) {
	  File dir = new File(saveDir);
	  if (!dir.exists()) dir.mkdirs();
	}

	// Daumeditor Image Change - 2013-01-31 LSH
	public String imageChange(String cnts, String imageUploadUrl, String imageUploadPath, String tempImageUploadPath) {		
		File imageUploadDir = new File(imageUploadPath);
		if (!imageUploadDir.exists()) imageUploadDir.mkdirs();
		
		Document doc = Jsoup.parse(cnts);
		Elements imgs = doc.select("IMG");
		for(Element e: imgs) {
			String src = e.attr("src");
			int srcIndex = src.indexOf("imageupload?getfile=");
			if (srcIndex > -1) {
				String imageName = src.substring(srcIndex +20);
				File f = new File(tempImageUploadPath, imageName);
				
// 				System.out.println("isFile: " + f.isFile());
// 				System.out.println("tempImageUploadPath(out): " + tempImageUploadPath + imageName);
				
				f.renameTo(new File(imageUploadPath, imageName));
				e.attr("src", imageUploadUrl + imageName);

// 				System.out.println("imageUploadPath(in): " + imageUploadPath + imageName);
// 				System.out.println("imageUploadUrl(link): " + imageUploadUrl + imageName);
			}
		}
		return doc.html();
	}
%>
<%
	request.setCharacterEncoding("utf-8");

	String userAgent = request.getHeader("User-Agent");	// OS 버전 확인
	boolean isIE = nek.common.util.Convert.isIE(request);
	boolean selEditor = (userAgent == null || userAgent.indexOf("Windows 95") > 0 || userAgent.indexOf("Windows 98") > 0)? true: false;
	Connection con = null;
	DBHandler db = new DBHandler();
	Signature signature = null;
// 	NamoMime mime = new NamoMime();	// 나모웹에디터 적용

	// 업로드할 위치와 MIME에서 대치할 LINK를 만듭니다.
	String uploadUrl = "";
	String uploadPath = request.getSession().getServletContext().getRealPath("/") + File.separator + "common" + File.separator + "namo" + File.separator;
	checkSaveDir(uploadPath);

	String folderName = "LXkMTACScSwMTkF2118";
	String imgUploadPath = application.getInitParameter("image_upload_path2"); //html5 Image uploadpath
	
	isIE = false;	//20121207 웹에디터 쓰지 않음
	ConfigItem cfItem = null;
	try {
		con = db.getDbConnection();
		
		cfItem = ConfigTool.getConfigValue(con, application.getInitParameter("CONF.HOME_PATH"));
		String homePath = cfItem.cfValue;
		if (!homePath.endsWith(File.separator)) homePath += File.separator;
		String signatureURL = homePath + folderName;
//	 	String signatureURL = "http://" + request.getServerName() + "/" + folderName;
		String signatureFolder = application.getInitParameter("maindir") + File.separator + folderName;
		checkSaveDir(signatureFolder);

		String signatureText = request.getParameter("signature");
		boolean isEnabled = request.getParameter("enabled") != null;

		// System.out.println("signatureText: " + signatureText);
		// System.out.println("isEnabled: " + isEnabled);
		
		if (signatureText != null) {
			signatureText = signatureText.trim();

			String tempImageUploadPath = imgUploadPath + File.separator + loginuser.uid + File.separator;
			String imageUploadUrl =  signatureURL + "/" + loginuser.uid + "/";
			String imageUploadPath = signatureFolder + File.separator + loginuser.uid + File.separator;
			
			uploadUrl = "http://" + request.getServerName() + "/common/namo/appr_sign/" + loginuser.uid;
			uploadPath += "appr_sign" + File.separator + loginuser.uid + File.separator;
			
			/* 
			mime.setSaveURL(uploadUrl);
		    mime.setSavePath(uploadPath);
		    mime.decode(signatureText);
		    signatureText = mime.getBodyContent();	//작은 따옴표(') 는 SQL에서 필드 구분자로 쓰이므로 \\'로 대체합니다. 
		    */

			if (signatureText.length() > 0) {
				deleteImgFiles(loginuser.uid, uploadPath);
				if (isIE) {
					signatureText = uploadImgFiles(uploadPath, uploadUrl, signatureText);
				} else {
					signatureText = imageChange(signatureText, imageUploadUrl, imageUploadPath, tempImageUploadPath);
				}
				repository.updateSignature(con, loginuser.uid, new Signature(signatureText, isEnabled));
				/* mime.saveFile(); */
				response.sendRedirect("mail_signature.jsp");
				return;
			}
		}
		signature = repository.getSignature(con, loginuser.uid);
	} finally {
		db.freeDbConnection();
	}
%>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>
	<fmt:message key="mail.email"/><%-- 전자메일 --%> 
	<fmt:message key="mail.sign.mng"/><%-- 서명관리 --%>
</title>

<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>

<script language="javascript">
function OnClickSave() {
	if (confirm("<fmt:message key='c.save'/>")) {	//저장 하시겠습니까?
		<%	if (isIE) { %>
			//fmSignature.signature.value = document.getElementById("twe").MimeValue();	/* document.all.Wec.MIMEValue; *///DOM.body.innerHTML;
			fmSignature.signature.value = geteditordata();	/* document.all.Wec.MIMEValue; *///DOM.body.innerHTML;
			fmSignature.browser.value = "IE";
		<%	} else { %>
			fmSignature.signature.value = geteditordata();
		<%	} %>
		fmSignature.submit();
	}
}
</script>
</head>
<!-- 나모웨에디터 로딩 이후 함수 수행  -->
<!-- <SCRIPT language="Javascript" FOR="Wec" EVENT="OnInitCompleted()">
	//CSS 설정
	document.all.Wec.BodyValue = document.all.dspsignature.innerHTML;
</script> -->
<script language="JScript" FOR="twe" EVENT="OnControlInit">
	var editor = document.getElementById("twe");
	editor.HtmlValue = document.all.dspsignature.innerHTML;
</script>

<script type="text/javascript">
//메일본문 에디터 설정 건 - override 메일용
function SetEditorData(objEditor, contentId) {
	var bodyData = $("#dspsignature").html();
	if ( bodyData == "" ) return;
	
	if( getEditorName() == "twe" ) {
		objEditor.HtmlValue = bodyData;
	} else if( getEditorName() == "xfree" ) {
		objEditor.setHtmlValue( bodyData );	
	} else {
		objEditor.modify({ content: bodyData });
	}
}

$(document).ready(function() {
		<%	if (!isIE) { %>
		//본문 -----------------------------------------
		//var dspBody = document.getElementById("dspsignature");
		//Editor.modify({
		//	"content": dspBody.innerHTML /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
		//});
		<%	} %>
	});
</script>
<body style="margin:0px;">
<form name="fmSignature" method="post" action="mail_signature.jsp" onsubmit="return false;"> 
<input type="hidden" name="signature" value="">
<input type="hidden" name="browser" value="">

<!--  서명부분 : signature -->
<div id="dspsignature" style="display:none"><%=((signature == null)? "": signature.getSignature()) %></div>

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="mail.option"/>&nbsp;&gt;&nbsp;<fmt:message key="mail.sign.mng"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>
<!-- List Title -->
	
<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="8"><td></td></tr></table>
<div style="width:90%;margin:auto;">	
<!-- 버튼 시작 -->
<div style="text-align: right;">
<a onclick="OnClickSave()" class="button white medium"> 
<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.save"/><%-- 저장 --%> </a>
</div>
<!-- 버튼 끝 -->
	
<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="6"><td></td></tr></table>

<div id="viewList" class="div-view" onpropertychange="div_resize();">
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
	<tr> 
		<td height="30" valign="top"> 
			<input type="checkbox" name="enabled" value="y" <%=(signature != null && signature.isEnabled()) ? "checked" : ""%>>
			<fmt:message key="mail.send.add.signature"/>&nbsp;<!-- 메일 발송시 서명을 추가합니다. -->
		</td>
	</tr>
	<tr>
		<td valign="top">
			<%	if (isIE) { %>
			<!-- 태그프리 에디터 적용 -->
			<script src="/common/scripts/tweditor.js"></script>
			<%	} else { %>
			<!-- 다음 에디터 적용 -->
			<jsp:include page="/WEB-INF/common/daum_editor_control.jsp" flush="true" />
			<%	} %>
		</td>
	</tr>
	<tr> 
		<td height="15"></td>
	</tr>
</table>
</div>
	</div>
</form>

<script language="javascript">
	SetHelpIndex("mail_signature");
</script>
</body>
</html>
</fmt:bundle>