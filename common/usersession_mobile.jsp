<%
nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);
nek.common.login.UserVariable uservariable = (nek.common.login.UserVariable)session.getAttribute(nek.common.SessionKey.USER_VAR);

java.util.Locale locale = request.getLocale();
if (loginuser != null) locale = new java.util.Locale(loginuser.locale);
java.util.ResourceBundle msglang = java.util.ResourceBundle.getBundle("messages", locale);

String sessionMsg = msglang.getString("sys.no.session"); //세션이 종료되었습니다.\\n\\n다시 로그인 해주십시오.

Object o = null;
try {
	Object obj= request.getSession().getServletContext().getAttribute("NEKWebSession");
	java.util.Hashtable nekWebSessions = (java.util.Hashtable<String, nek3.web.NEKWebSession>)obj;
	o = nekWebSessions.get(request.getSession().getId());
} catch(Exception e) {}

if (uservariable == null) 
	uservariable = new nek.common.login.UserVariable();

if (loginuser == null || uservariable == null || o == null) {
	%><script language="javascript">alert("<%=sessionMsg%>");top.location.href = "/";</script><%
	session.invalidate();
	return;
}
%>
