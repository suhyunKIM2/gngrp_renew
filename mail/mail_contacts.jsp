<?xml version="1.0" encoding="utf-8" ?>
<%@ page contentType="text/xml;charset=utf-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.addressbook.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%!
	AddressBook ab = new AddressBook();
	//RecipientSearcher searcher = new RecipientSearcher();
%>
<%//@ include file="../common/usersession.jsp" %>
<%
	request.setCharacterEncoding("utf-8");
	nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);

	String type = request.getParameter("type");
	String deptId = request.getParameter("dept");
	String acid = request.getParameter("acid");

	DBHandler db = new DBHandler();
	Connection con = null;
//	Collection fromContact = null;
//	Collection fromOrg = null;
	Collection results = null;

	try {
		con = db.getDbConnection();

		if (deptId != null) {
			results = (Collection)OrganizationTool.getLowerDeptNUserList(con, deptId);
		} else {	
			if (type != null && type.equals("private")) {
				if (acid == null) {
					results = ab.getPrivateCategories(con, loginuser.uid);
				} else {
					results = ab.getContacts(con, acid, AddressBook.PRIVATE, loginuser);
				}
			} else {
				if (acid == null) {
					results = ab.getPublicCategories(con, loginuser.securityId);
				} else {
					results = ab.getContacts(con, acid, AddressBook.PUBLIC, loginuser);//(con);
				}
			}
		}
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}

	response.resetBuffer();
	response.setContentType("text/xml");
%>
<contacts>
<%
	//String domain = application.getInitParameter("nek.mail.domain");

	if (results != null) {
		Iterator iter = results.iterator();
		while (iter.hasNext()) {
			XmlObject result = (XmlObject)iter.next();
			out.println(result.toXml());
		}
	}

/*
	if (fromOrg != null) {
		Iterator iter = fromOrg.iterator();
		while (iter.hasNext()) {
			OrganizationItem ou = (OrganizationItem)iter.next();
			if (ou.isUser) {
				out.println("<user name='" + XmlUtility.encodeText(ou.itemTitle) + "' email='" + 
					ou.emailId + "@" + domain + "' position='" + XmlUtility.encodeText(ou.upName) + "'/>");
			} else {
				out.println("<department deptid='" + ou.itemId + "' name='" + XmlUtility.encodeText(ou.itemTitle) + "'/>");
			}
		}
	}
*/
%>
</contacts>