<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="net.sf.json.*"%>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.Convert" %>
<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="/common/usersession.jsp"%>
<%
	String uid = request.getParameter("uid");

	if ("".equals(uid) || uid == null) {
		out.write("<script language='javascript'>alert('사용자가 지정지되 않았습니다');history.back();</script>");
		return;
	}
	
	UserTool userView = null;
	UserItem userItem = null;
	ConfigItem cfItem = null;    
    try {
		userView = new UserTool(loginuser);
		userView.getDBConnection();
		userItem = userView.getUserInfo(uid);
	} finally { userView.freeDBConnection(); }
	
    JSONObject cellObj = new JSONObject();
	cellObj.put("uid", Convert.TextNullCheck(userItem.uid));
	cellObj.put("sabun", Convert.TextNullCheck(userItem.sabun));
	cellObj.put("nName", Convert.TextNullCheck(userItem.nName));
	cellObj.put("eName", Convert.TextNullCheck(userItem.eName));
	cellObj.put("telNo", Convert.TextNullCheck(userItem.telNo));
	cellObj.put("faxNo", Convert.TextNullCheck(userItem.faxNo));
	cellObj.put("homeTel", Convert.TextNullCheck(userItem.homeTel));
	cellObj.put("cellTel", Convert.TextNullCheck(userItem.cellTel));
	cellObj.put("loginId", Convert.TextNullCheck(userItem.loginId));
	cellObj.put("addJob", Convert.TextNullCheck(userItem.addJob));
	cellObj.put("mainJob", Convert.TextNullCheck(userItem.mainJob));
	cellObj.put("udId", Convert.TextNullCheck(userItem.udId));
	cellObj.put("udName", Convert.TextNullCheck(userItem.udName));
	cellObj.put("upId", Convert.TextNullCheck(userItem.upId));
	cellObj.put("upName", Convert.TextNullCheck(userItem.upName));
	cellObj.put("dpId", Convert.TextNullCheck(userItem.dpId));
	cellObj.put("dpName", Convert.TextNullCheck(userItem.dpName));
	cellObj.put("internetMail", Convert.TextNullCheck(userItem.internetMail));
	cellObj.put("securityTitle", Convert.TextNullCheck(userItem.securityTitle));
	cellObj.put("zipCode", Convert.TextNullCheck(userItem.zipCode));
	cellObj.put("address", Convert.TextNullCheck(userItem.address));
	cellObj.put("address2", Convert.TextNullCheck(userItem.address2));
	cellObj.put("userName", Convert.TextNullCheck(userItem.userName));
	cellObj.put("pwdHash", Convert.TextNullCheck(userItem.pwdHash));
	cellObj.put("comment", Convert.TextNullCheck(userItem.comment));
	cellObj.put("birthDay", Convert.TextNullCheck(userItem.birthDay));
	cellObj.put("email", Convert.TextNullCheck(userItem.email));
	cellObj.put("domainName", Convert.TextNullCheck(userItem.domainName));
    out.print(cellObj);
	
	
// 	CommonTool.getUserPositionTitle(userView.SQLConn(), userItem.upId);
// 	Convert.TextNullCheck(userItem.state);
// 	Convert.TextNullCheck(userItem.enterDate);
// 	Convert.TextNullCheck(userItem.securityId);
// 	Convert.TextNullCheck(userItem.sex); //성별
// 	Convert.TextNullCheck(userItem.IsbirthDay);
// 	Convert.TextNullCheck(userItem.userLock);//계정잠금
// 	Convert.TextNullCheck(userItem.mailFlag);	//메일사용여부
// 	Convert.TextNullCheck(userItem.smsCnt);	//SMS 발송건수
%>