<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.Convert" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="net.sf.json.*" %>
<%@ page import="org.apache.log4j.Logger" %>
<%!
	static Logger log = Logger.getLogger("address_mail_json2.jsp");
%>
<% 	request.setCharacterEncoding("utf-8"); %>
<%
	nek.common.login.LoginUser loginuser = (nek.common.login.LoginUser)session.getAttribute(nek.common.SessionKey.LOGIN_USER);
	nek.common.login.UserVariable uservariable = (nek.common.login.UserVariable)session.getAttribute(nek.common.SessionKey.USER_VAR);
	
	String searchValue = Convert.nullCheck(request.getParameter("searchValue"));
	String dpid = Convert.nullCheck(request.getParameter("dpid"));
	boolean bAddressbook = ("1".equals(request.getParameter("addressbook"))) ? true: false;
	boolean bUsers = ("1".equals(request.getParameter("users"))) ? true: false;
	boolean bDepartment = ("1".equals(request.getParameter("department"))) ? true: false;
	boolean bMailAutocomplete = ("1".equals(request.getParameter("mail_autocomplete"))) ? true: false;
	boolean bMailForm = ("1".equals(request.getParameter("mail_form"))) ? true: false;
	boolean bMailGroup = ("1".equals(request.getParameter("mail_group"))) ? true: false;
	boolean bRepresentation = ("1".equals(request.getParameter("mail_representation"))) ? true: false;
	boolean isRootMailSend = uservariable.isRootMailSend;
	String addressBook = "''";
	
	log.debug("searchValue: " + searchValue);
	log.debug("dpid: " + dpid);
	log.debug("bAddressbook: " + bAddressbook);
	log.debug("bUsers: " + bUsers);
	log.debug("bDepartment: " + bDepartment);
	log.debug("bMailAutocomplete: " + bMailAutocomplete);
	log.debug("isRootMailSend: " + isRootMailSend);
	log.debug("bRepresentation: " + bRepresentation);
	log.debug("bMailGroup: " + bMailGroup);
	
	String[] searchValues = searchValue.split(",");
	
	LinkedHashMap<String, List<HashMap<String, String>>> map = new LinkedHashMap<String, List<HashMap<String, String>>>();
	List<String> dpids = new ArrayList<String>();
		
	DBHandler db = new DBHandler();
	try {
		Connection pconn = db.getDbConnection();
		AutoCompleteMail autoMail = new AutoCompleteMail(loginuser);
		
		if (dpid.equals("")) {
			if (!uservariable.addressBook.equals("")) {
				String[] ids = uservariable.addressBook.split(",");
				for(int i = 0, len = ids.length; i < len; i++) {
					if (i != 0) dpid += ",";
					dpid += "'" + ids[i] + "'";
				}
			} else {
				dpid = "'" + autoMail.getParentDepartmentId(pconn, loginuser.dpId) + "'";
			}
		} else {
			dpid = "'" + dpid + "'";
		}
		addressBook = dpid;
		
		if (dpid.indexOf("00000000000000") == -1) {
			dpids = autoMail.getChildDepartmentIds(pconn, dpid);
			dpids = new ArrayList(new HashSet(dpids));

			String[] deptIds = new String[dpids.size()];
			deptIds = dpids.toArray(deptIds);
			dpid = dpid + ",'" + StringUtils.join(deptIds, "','") + "'";
		} else {
			dpid = "";
		}
		
		for(int i = 0, len = searchValues.length; i < len; i++) {
			String search = StringUtils.trim(searchValues[i]);
			if (!search.equals("")) map.put(search, autoMail.getAddressMailJson(pconn, search, dpid, bAddressbook, bUsers, bDepartment, bMailAutocomplete, bMailForm, isRootMailSend, bMailGroup, addressBook, bRepresentation));
		}
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		if (db != null) { db.freeDbConnection(); }
	}

	JSONObject jsonData = new JSONObject();
	JSONArray cellArray = new JSONArray();
	JSONObject cellObj = new JSONObject();

	for(int i = 0, len = searchValues.length; i < len; i++) {
		String search = StringUtils.trim(searchValues[i]);
		
		if (!search.equals("")) {
			log.debug("search: " + search);
			List<HashMap<String, String>> list = map.get(search);
			for(int j = 0, size = list.size(); j < size; j++) {
				HashMap<String, String> item = list.get(j);

				log.debug("listType: " + item.get("listType"));
				log.debug("name: " + item.get("name"));
				log.debug("upname: " + item.get("upname"));
				log.debug("dpname: " + item.get("dpname"));
				log.debug("email: " + item.get("email"));
				
				String label = "";
				if (item.get("listType").equals("user")) {
					label = "\"" + item.get("name") + "("+item.get("ename")+")\"" + " " + "<" + item.get("email") + ">" + " [임직원/" + item.get("dpname") + "/" + item.get("upname") + "]";
				} else if (item.get("listType").equals("private")) {
					label = "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">" + " [개인주소록]";
				} else if (item.get("listType").equals("public")) {
					label = "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">" + " [공용주소록]";
				} else if (item.get("listType").equals("department")) {
					label = item.get("name") + " [부서]";
				} else if (item.get("listType").equals("auto")) {
					label = "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">";
				} else if (item.get("listType").equals("share_group")) {
					label = item.get("name") + " [공용메일그룹]";
				} else if (item.get("listType").equals("person_group")) {
					label = item.get("name") + " [개인메일그룹]";
				} else if (item.get("listType").equals("representation")) {
					label = "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">" + " [대표메일]";
				}
				
				// autocomplete 용
				cellObj.put("label", label);
				cellObj.put("value", "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">");
				
				// objAddress 용
				if (item.get("listType").equals("department")) {
					cellObj.put("name", item.get("name"));
					cellObj.put("id", item.get("email"));
					cellObj.put("depttype", item.get("listType"));
					cellObj.put("address", item.get("name"));
					cellObj.put("includeSub", true);
					cellObj.put("toString", "D:" + item.get("email") + ":" + item.get("name") + ":true");
					cellObj.put("toDisplay", item.get("name") + "[+]");
				} else if (item.get("listType").equals("share_group")) {
					cellObj.put("name", item.get("name"));
					cellObj.put("id", item.get("email"));
					cellObj.put("depttype", item.get("listType"));
					cellObj.put("address", item.get("name"));
					cellObj.put("toString", "G:" + item.get("email") + ":" + item.get("name"));
					cellObj.put("toDisplay", item.get("name"));
				} else {
					cellObj.put("personal", item.get("name"));
					cellObj.put("address", item.get("email"));
					cellObj.put("toString", "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">");
					cellObj.put("toDisplay", "\"" + item.get("name") + "\"" + " " + "<" + item.get("email") + ">");
				}
				cellArray.add(cellObj);
				cellObj.clear();
			}
			jsonData.put(search, cellArray);
			cellArray.clear();
		}
	}
	log.debug("address_mail_json2: " + jsonData);
	out.println(jsonData);
%>