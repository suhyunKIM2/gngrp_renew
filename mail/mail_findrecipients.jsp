<?xml version="1.0" encoding="utf-8" ?>
<%@ page contentType="text/xml; charset=utf-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.addressbook.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%!
//	RecipientSearcher searcher = new RecipientSearcher();
	private AddressBook ab = new AddressBook();
%>
<%//@ include file="../common/usersession.jsp" %>
<%
	request.setCharacterEncoding("utf-8");
	nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);

	String[] keywords = request.getParameterValues("keyword");
	if (keywords == null || keywords.length < 1) {
		response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR , 
			"No search keywords");
		return;
	}

	DBHandler db = new DBHandler();
	Connection con = null;
	Collection results = null;

	try {
		con = db.getDbConnection();

		results = new ArrayList();
		for (int i = 0; i < keywords.length; i++) {
			RecipientSearchResult result = new RecipientSearchResult(keywords[i]);

			Collection ous = OrganizationTool.findUsers(con, keywords[i]);
			if (ous != null) {
				result.addAll(ous);
			}

			Collection privates = ab.findFromPrivates(con, loginuser.uid, keywords[i]);
			if (privates != null) {
				result.addAll(privates);
			}

			Collection publics = ab.findFromPublics(con, loginuser.securityId, keywords[i]);
			if (publics != null) {
				result.addAll(publics);
			}

			results.add(result);
		}

		//results  = searcher.find(con, loginuser.uid, keywords, domain);
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}

	
	//response.resetBuffer();
	response.setContentType("text/xml");
%>
<search-results>
<%
	if (results != null) {
		Iterator iter = results.iterator();
		while (iter.hasNext()) {
			XmlObject result = (XmlObject)iter.next();
			out.println(result.toXml());
		}
	}
%>
</search-results>