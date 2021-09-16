<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="nek.common.login.LoginUser" %>
<%@ page contentType="text/html;charset=utf-8" %>
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
%>
<%
	request.setCharacterEncoding("utf-8");
	LoginUser loginUser = (LoginUser) session.getAttribute(SessionKey.LOGIN_USER);

	String deptId = StringUtils.defaultString(request.getParameter("dept"));
	String type = StringUtils.defaultString(request.getParameter("type"));
	String acid = StringUtils.defaultString(request.getParameter("acid"));
	String gubun = ("private".equals(type))? "P": "S";
	int typeNum = ("private".equals(type))? AddressBook.PRIVATE: AddressBook.PUBLIC;

	Collection results = new ArrayList();
	
	DBHandler db = new DBHandler();
	Connection con = null;
	try {
		con = db.getDbConnection();

		if (StringUtils.isNotBlank(deptId)) {
			results = (Collection) OrganizationTool.getLowerDeptNUserList(con, deptId);
		} else {
			results.addAll((Collection) ab.getAddressBookCategory(con, gubun, acid, loginUser.uid));
			results.addAll(ab.getContacts(con, acid, typeNum, loginUser));
		}
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		if (db != null) { db.freeDbConnection(); }
	}

	response.resetBuffer();
	response.setContentType("text/html");
%>
[
<%
	if (results != null) {
		int number = 0;
		Iterator iter = results.iterator();
		while (iter.hasNext()) {
			if (++number > 1) out.print(",");
			XmlObject result = (XmlObject)iter.next();
			out.println(result.toJSON());
		}
	}
%>
]