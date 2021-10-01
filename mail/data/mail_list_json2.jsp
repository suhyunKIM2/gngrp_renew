<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../../error.jsp" %>
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
<%!
	private MailRepository repository = MailRepository.getInstance();//new MailRepository();
	
	private static int SEARCH_EQ = 1;
	private static int SEARCH_LIKE = 2;
	private static int SEARCH_NOTIN = 3;
	private static int SEARCH_PERIOD = 4;
	
	public SearchConstraint getSearchConstraint(String searchText, String searchType, int whereType) {
		SearchConstraint constraint = null;
		
		HashMap<String, String[]> SEARCH_FIELDS = new HashMap<String, String[]>();
		SEARCH_FIELDS.put("all", new String[] { "subject", "fromname", "sender", "displayto", "textdescription" });
		SEARCH_FIELDS.put("subject", new String[] { "subject" });
		SEARCH_FIELDS.put("from", new String[] { "fromname", "sender" });
		SEARCH_FIELDS.put("recieve", new String[] { "displayto" });
		SEARCH_FIELDS.put("all_rec", new String[] { "fromname", "sender", "displayto" });
		SEARCH_FIELDS.put("ref", new String[] { "displayto" });
		
		SEARCH_FIELDS.put("all_body", new String[] { "subject", "textdescription" });
		SEARCH_FIELDS.put("body", new String[] { "textdescription" });
		SEARCH_FIELDS.put("mailboxid", new String[] { "mailboxid" });
		SEARCH_FIELDS.put("period", new String[] { "created" });
		
		
		
		if (searchText != "" && searchType != "") {
			String[] searchFields = (String[])SEARCH_FIELDS.get(searchType);
			if (searchFields != null) { 
				constraint = new SearchConstraint();
				constraint.setSearchText(searchText);
				constraint.setSearchFields(searchFields);
				constraint.setWhereType(whereType);
			}
		}
		return constraint;
	}
%>
<%request.setCharacterEncoding("utf-8");%>
<%
	ParameterParser pp = new ParameterParser(request);
	int mailboxID = pp.getIntParameter("box", Mailbox.INBOX);
	int pageNo = pp.getIntParameter("pageNo", 1);
	int rowsNum = pp.getIntParameter("rowsNum", uservariable.listPPage);
	String unReadChk = pp.getStringParameter("unread", "");
	String searchText = pp.getStringParameter("searchtext", "");
	String searchType = pp.getStringParameter("searchtype", "");
	String mainBoxID = pp.getStringParameter("codekey", "");
	
	String sel_receiver = pp.getStringParameter("sel_receiver", "");
	String ipt_receiver = pp.getStringParameter("ipt_receiver", "");
	//본문검색
	String sel_content = pp.getStringParameter("sel_content", "");
	String ipt_content = pp.getStringParameter("ipt_content", "");
	//메일함 검색
	String sel_mailbox = pp.getStringParameter("sel_mailbox", "");
	String rdo_srch = pp.getStringParameter("rdo_srch", "");
	//검색기간
	String sel_period = pp.getStringParameter("sel_period", "");
	String startdate =pp.getStringParameter("startdate", "");
	String enddate = pp.getStringParameter("enddate", "");
	
	List<SearchConstraint> searchList = new ArrayList<SearchConstraint>();
	
	if(!searchType.equals("")) searchList.add(getSearchConstraint(searchText, searchType, SEARCH_LIKE));
	if(!sel_receiver.equals("")) searchList.add(getSearchConstraint(ipt_receiver, sel_receiver, SEARCH_LIKE));
	if(!sel_content.equals("")) searchList.add(getSearchConstraint(ipt_content, sel_content, SEARCH_LIKE));
	if(sel_mailbox.equals("0")){
		if(rdo_srch.equals("exceptTrash")){
			searchList.add(getSearchConstraint("4／7", "mailboxid", SEARCH_NOTIN));
		}
	}else if(!sel_mailbox.equals("")){
		searchList.add(getSearchConstraint(sel_mailbox, "mailboxid", SEARCH_EQ));
	}else{
		if(!unReadChk.equals("1")){
			searchList.add(getSearchConstraint(String.valueOf(mailboxID), "mailboxid", SEARCH_EQ));
		}
	}
	if(!startdate.equals("")&&!enddate.equals("")){
		searchList.add(getSearchConstraint(startdate+"／"+enddate, "period", SEARCH_PERIOD));
	}
	
	
	String[] sortLists = new String[]{pp.getStringParameter("sortColumn", ""), pp.getStringParameter("sortType", "")};
%>
<%
	String domainName = ""; 
	ListPage listPage = null;
	int totalCount = 0;
	int iUnReadCnt = 0;
%>
<%
	DBHandler db = new DBHandler();
	Connection con = null;
	
	try {
		con = db.getDbConnection();
	
		domainName = application.getInitParameter("nek.mail.domain");
		if (!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
	
		if (unReadChk.equals("1")) {
			listPage = repository.unReadlist(con, loginuser.emailId, mailboxID, pageNo, rowsNum, searchList, domainName, sortLists);
		} else {
			listPage = repository.list(con, loginuser.emailId, mailboxID, pageNo, rowsNum, searchList, domainName, sortLists);
		}
		
		totalCount = listPage.getTotalCount();
	} catch (Exception e) {
		System.out.println("mail_list_json.jsp " + e);
	} finally {
		if (con != null) { db.freeDbConnection(); }
	}
	int totalPage = (int)(Math.ceil((double)totalCount/(double)rowsNum));
%>
<%
JSONObject jsonData = new JSONObject();
JSONArray cellArray= new JSONArray();
JSONArray cell = new JSONArray();
JSONObject cellObj = new JSONObject();

jsonData.put("records", totalCount);
jsonData.put("total", totalPage);
jsonData.put("page", pageNo);

if (listPage.getTotalCount() > 0) {
	Iterator iter = listPage.iterator();
	boolean alternating = false;
	while (iter.hasNext()) {
		MessageLineItem item = (MessageLineItem)iter.next();

		String who = "";
		if (mailboxID == Mailbox.OUTBOX || 
			mailboxID == Mailbox.DRAFT ||
			mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {
			who = item.getDisplayTo();
		} else {
			String fromName = HtmlEncoder.encode(item.getFromName());
			who = fromName;
		}
		
		String subject = item.getSubject();
		if (subject == null || subject.trim().length() < 1) {
			subject = "제목없음";
		} else {
			subject = HtmlEncoder.encode(subject);
		}
		
		String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(item.getDate());

		cell.add(who);
		cell.add(item.getImportance());	// 중요도
		cell.add(item.hasAttachment());	// 첨부여부
		cell.add(item.isRead());		// 읽음체크
		cell.add(subject);
		cell.add(date);

		cellObj.put("mailid", item.getMessageName());
		cellObj.put("cell",cell);
		cellArray.add(cellObj);
		cell.clear();
	}
}

jsonData.put("rows",cellArray);
out.println(jsonData);
%>