<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.util.*" %>
<% 	request.setCharacterEncoding("utf-8"); %>
[
<%
	nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);
	nek.common.login.UserVariable uservariable = (nek.common.login.UserVariable)session.getAttribute(nek.common.SessionKey.USER_VAR);
	
	java.util.Locale locale = request.getLocale();
	if (loginuser != null) locale = new java.util.Locale(loginuser.locale);
	java.util.ResourceBundle msglang = java.util.ResourceBundle.getBundle("messages", locale);

	int totCount = 0;
	MenuMgr subMenu = null;
	ArrayList datas = null;
	HashMap data = null;
	String totText = "";
	int childExist = 0;
	Iterator iter =null;
	totText = "";

	String strKey = request.getParameter("boxid");
	String openType = request.getParameter("opentype");
	if (openType == null) openType ="";
	
	String dbPath = request.getParameter("dbpath");
	String domainName = application.getInitParameter("nek.mail.domain");
	
	if (!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
	
	if (openType.equals("TOP")) {
		try {
			subMenu = new MenuMgr(loginuser, domainName);
			subMenu.getDBConnection();
			datas = subMenu.getBoxInfo(strKey, dbPath);
			totCount = datas.size();
		} catch (Exception ex) {
			System.out.println("Mailbox_tree JSON Error : " + ex);
		} finally {
			subMenu.freeDBConnection();
		}
		
		
		iter = datas.iterator();
		while(iter.hasNext()) {
			if (!totText.equals("")) totText += ",";
			data = (HashMap)iter.next();
			try {
				subMenu = new MenuMgr(loginuser, domainName);
				subMenu.getDBConnection();
				childExist = subMenu.isExistMailBox(data.get("id").toString(), dbPath);
			} catch (Exception ex) {
				System.out.println("Mailbox_tree sub JSON Error : " + ex);
			} finally {
				subMenu.freeDBConnection();
			}
			
			childExist = 1;
			String name = "";
			//if(data.get("id").equals("2")) continue;
			if (data.get("id").equals("1")) {
				name = msglang.getString("mail.InBox"); /* 받은 편지함 */
			} else if (data.get("id").equals("2")) {
				name = msglang.getString("mail.OutBox"); /* 보낸 편지함 */
			} else {
				name = data.get("name").toString(); 
			}
			
			String count = data.get("cnt").toString();
			
// 			totText += "<doc name=\"" + name
// 					+ "\" code=\"" + data.get("id")
// 					+ "\" isChildExist=\"" + childExist 
// 					+ "\" mainBoxID=\"" + data.get("mainid")
// 					+ "\" dbpath=\"mail\" />\n";
					
			totText+= "{ \"name\": \"" + name + "\""
					+ ", \"code\": \"" + data.get("id") + "\""
					+ ", \"isChildExist\": \"" + childExist + "\""
					+ ", \"mainBoxID\": \"" + data.get("mainid") + "\""
					+ ", \"dbpath\": \"mail\""
					
					+ ", \"title\": \"" + name + "\""
					+ ", \"type\": \"" + data.get("id") + "\""
					+ ", \"isFolder\": \"" + ((childExist == 1)?true:false) + "\""
					+ ", \"isLazy\": \"" + ((childExist == 1)?true:false) + "\""
					+ ", \"key\": \"" + data.get("id") + "\""
					+ ", \"count\": \"" + data.get("cnt") + "\""
					+ ", \"opentype\": \"" + openType + "\""
					+ ", \"datas\": \"" + name + ":" + data.get("id") + ":" + childExist + ":" + data.get("mainid") + ":mail:" + openType + "\""
					+ "}";
		}
		//사내수신함
	// 	totText += "<doc name=\"사내수신함"
	// 			+ "\" code=\"1" 
	// 			+ "\" isChildExist=\"1"
	// 			+ "\" mainBoxID=\"1"
	// 			+ "\" dbpath=\"note\" />\n";

	} else {
		try {
			subMenu = new MenuMgr(loginuser, domainName);
			subMenu.getDBConnection();
			datas = subMenu.getBoxInfo(strKey, dbPath);
			totCount = datas.size();
		} catch (Exception ex) {
			System.out.println("Mailbox_tree JSON Error : " + ex);
		} finally {
			subMenu.freeDBConnection();
		}
		
		
		if (dbPath.equals("mail")) {
			iter = datas.iterator();
			while(iter.hasNext()) {
				if (!totText.equals("")) totText += ",";
				data = (HashMap)iter.next();
				childExist = 0;
				
				try {
					subMenu = new MenuMgr(loginuser, domainName);
					subMenu.getDBConnection();
					childExist = subMenu.isExistMailBox(data.get("id").toString(), dbPath);
				} catch (Exception ex) {
					System.out.println("Mailbox_tree sub JSON Error : " + ex);
				} finally {
					subMenu.freeDBConnection();
				}
				
				childExist = 1;
				String name = "";
				if (data.get("id").equals("1")) {
					name = msglang.getString("mail.InBox"); /* 받은 편지함 */
				} else if (data.get("id").equals("2")) {
					name = msglang.getString("mail.OutBox"); /* 보낸 편지함 */
				} else {
					name = data.get("name").toString(); 
				}
				
// 				totText += "<doc name=\"" + name
// 						+ "\" code=\"" + data.get("id")
// 						+ "\" isChildExist=\"" + childExist 
// 						+ "\" mainBoxID=\"" + data.get("mainid")
// 						+ "\" dbpath=\"mail\" />\n";

				totText+= "{ \"name\": \"" + name + "\""
						+ ", \"code\": \"" + data.get("id") + "\""
						+ ", \"isChildExist\": \"" + childExist + "\""
						+ ", \"mainBoxID\": \"" + data.get("mainid") + "\""
						+ ", \"dbpath\": \"mail\""
						
						+ ", \"title\": \"" + name + "\""
						+ ", \"type\": \"" + data.get("id") + "\""
						+ ", \"isFolder\": \"" + ((childExist == 1)?true:false) + "\""
						+ ", \"isLazy\": \"" + ((childExist == 1)?true:false) + "\""
						+ ", \"key\": \"" + data.get("id") + "\""
						+ ", \"opentype\": \"" + openType + "\""
						+ ", \"datas\": \"" + name + ":" + data.get("id") + ":" + childExist + ":" + data.get("mainid") + ":mail:" + openType + "\""
						+ "}";
			}
		} else if (dbPath.equals("note")) {
			iter = datas.iterator();
			while(iter.hasNext()) {
				if (!totText.equals("")) totText += ",";
				data = (HashMap)iter.next();
				childExist = 0;
				try {
					subMenu = new MenuMgr(loginuser, domainName);
					subMenu.getDBConnection();
						childExist = subMenu.isExistMailBox(data.get("id").toString(), "note");
				} catch(Exception ex) {
					System.out.println("Mailbox_tree sub JSON Error : " + ex);
				} finally {
					subMenu.freeDBConnection();
				}
				childExist = 1;
				String name = "";
				if (data.get("id").equals("1")) {
					name = "사내수신함";
				} else {
					name = data.get("name").toString(); 
				}
// 				totText += "<doc name=\"" + name
// 						+ "\" code=\"" + data.get("id")
// 						+ "\" isChildExist=\"" + childExist 
// 						+ "\" mainBoxID=\"" + data.get("mainid")
// 						+ "\" dbpath=\"note\" />\n";
						
				totText+= "{ \"name\": \"" + name + "\""
						+ ", \"code\": \"" + data.get("id") + "\""
						+ ", \"isChildExist\": \"" + childExist + "\""
						+ ", \"mainBoxID\": \"" + data.get("mainid") + "\""
						+ ", \"dbpath\": \"mail\""
						
						+ ", \"title\": \"" + name + "\""
						+ ", \"type\": \"" + data.get("id") + "\""
						+ ", \"isFolder\": \"" + ((childExist == 1)?true:false) + "\""
						+ ", \"isLazy\": \"" + ((childExist == 1)?true:false) + "\""
						+ ", \"key\": \"" + data.get("id") + "\""
						+ ", \"opentype\": \"" + openType + "\""
						+ ", \"datas\": \"" + name + ":" + data.get("id") + ":" + childExist + ":" + data.get("mainid") + ":mail:" + openType + "\""
						+ "}";
			}
		}
	}
out.print(totText);
%>
]