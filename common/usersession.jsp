<%-- <%@ page contentType="text/html;charset=utf-8" %> --%>
<%-- <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %> --%>
<%!
	private String imagePath = "../common/images/";
	private String scriptPath = "../common/scripts";
	private String cssPath = "../common/css";
	private String imgCssPath = "../common/css/blue/blue.css";
	
	private void setImagePath(int mainType){
		if(mainType == 1){
			imagePath = "../common/images/blue";
			imgCssPath = "../common/css/blue/blue.css";
		}else if(mainType == 2){
			imagePath = "../common/images/gray";
			imgCssPath = "../common/css/gray/gray.css";
		}else if(mainType == 3){
			imagePath = "../common/images/green";
			imgCssPath = "../common/css/green/green.css";
		}else if(mainType == 4){
			imagePath = "../common/images/sepia";
			imgCssPath = "../common/css/sepia/sepia.css";
		}
	}
%>
<%
nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);
nek.common.login.UserVariable uservariable = (nek.common.login.UserVariable)session.getAttribute(nek.common.SessionKey.USER_VAR);
String ieEditor = (String)session.getAttribute("ieEditor");

java.util.Locale locale = request.getLocale();
if (loginuser != null) locale = new java.util.Locale(loginuser.locale);
java.util.ResourceBundle msglang = java.util.ResourceBundle.getBundle("messages", locale);

String viewType[] =(String[])session.getAttribute("viewtype");
//java.util.Hashtable loginSession = (java.util.Hashtable)application.getAttribute("loginSession");
String sessionMsg = "오랜시간사용하지 않아 세션이 종료되었습니다\\n\\n 다시 로그인 해주십시오";
//Object sessionObject = loginSession.get(session.getId());
//if (sessionObject == null) //sessionMsg = "다른 곳에서 로그인 하여 세션이 강제종료되었습니다";
sessionMsg = msglang.getString("sys.no.session"); //세션이 종료되었습니다.\\n\\n다시 로그인 해주십시오.

Object o = null;
try{
	Object obj= request.getSession().getServletContext().getAttribute("NEKWebSession");
	java.util.Hashtable nekWebSessions = (java.util.Hashtable<String, nek3.web.NEKWebSession>)obj;
	o = nekWebSessions.get(request.getSession().getId());
}catch(Exception e){}

if (uservariable == null) uservariable = new nek.common.login.UserVariable();
if (loginuser == null || uservariable == null || o == null)
{
// 	System.out.println("top #1");
	loginuser = new nek.common.login.LoginUser();
	loginuser.loginId = "admin";
	loginuser.uid = "00000000000000";
	loginuser.nName = "관리자";
	loginuser.securityId = 9;
	loginuser.emailId = "admin";
	loginuser.dpName = "가람시스템";
	loginuser.dpId = "00000000000000";
	loginuser.upId = "DR";
	loginuser.udId = "GJ";

    uservariable.listPPage = 10 ; 
	uservariable.blockPPage 	= 5 ;
	uservariable.mailBoxSize	= (long)(1024*1024*10) ;
	uservariable.sendMailSize = (long)(1024*1024*10) ;
	uservariable.uploadSize = (long)(1024*1024*10) ; 
	uservariable.campaignText = "COPYRIGHT ⓒ 2012 GaramSystem Company All right reserved";
	uservariable.campaignTitle = "가람시스템";
// 	System.out.println("top #2");
%>
		<script language="javascript">
		alert("<%=sessionMsg%>");
		//top.location.href = "../index.jsp";
		top.location.href = "/logout.jsp";
		</script>
<%
		session.invalidate();
		//out.close();
		return;
}
setImagePath(loginuser.mainType);
%>
