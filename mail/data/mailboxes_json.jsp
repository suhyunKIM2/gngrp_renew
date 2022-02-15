<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="nek.mail.*" %>
<%@ page import="net.sf.json.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ include file="/common/usersession.jsp" %>
<%	request.setCharacterEncoding("utf-8"); %>
<%
	MailRepository repository = MailRepository.getInstance();
// 	javax.naming.Context initCtx = new javax.naming.InitialContext();
// 	javax.naming.Context envCtx = (javax.naming.Context)initCtx.lookup("java:/comp/env");
// 	javax.sql.DataSource ds = (javax.sql.DataSource)envCtx.lookup("jdbc/james");
    String domainName = application.getInitParameter("nek.mail.domain");
    if (!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
    
    Iterator iter = null;
	Connection jamesCon = null;
	Mailboxes mailboxes = null;
	
	DBHandler db = new DBHandler();
	Connection con = null;
	try {
		//jamesCon = ds.getConnection();	//메일 DBConnection
		con = db.getDbConnection();
		
		mailboxes = repository.getCustomMailboxes(con, loginuser.emailId, domainName);
	} finally { if (con != null) con.close(); }

	JSONArray cellArray= new JSONArray();
	JSONObject cellObj = new JSONObject();
	
	//받은편지함 서브 트리
	iter = mailboxes.iterator();
	while (iter.hasNext()) {
		Mailbox box = (Mailbox)iter.next();
		if (box.getMainBoxId() != 1) continue;

		cellObj.put("type", box.getMainBoxId());
		cellObj.put("name", box.getName());
		cellObj.put("id", box.getID());
		cellArray.add(cellObj);
	}

	//보낸편지함 서브 트리
	iter = mailboxes.iterator();
	while (iter.hasNext()) {
		Mailbox box = (Mailbox)iter.next();
		if (box.getMainBoxId() != 2) continue;

		cellObj.put("type", box.getMainBoxId());
		cellObj.put("name", box.getName());
		cellObj.put("id", box.getID());
		cellArray.add(cellObj);
	}
	out.println(cellArray);
%>