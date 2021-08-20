<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
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

// 			MailRepositorySummary mailboxSummary  = repository.getUnreadRepositoryCount(con, loginuser.emailId, domainName, String.valueOf(mailboxID), null);
// 			iUnReadCnt = mailboxSummary.getUnreadCount();
		} else {
			listPage = repository.list(con, loginuser.emailId, mailboxID, pageNo, rowsNum, searchList, domainName, sortLists);

// 			MailRepositorySummary mailboxSummary  = repository.getRepositoryCount(con, loginuser.emailId, domainName, String.valueOf(mailboxID), null);
// 			iUnReadCnt = mailboxSummary.getUnreadCount();
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
// jsonData.put("userdata", String.valueOf(iUnReadCnt));


if (listPage.getTotalCount() > 0) {
	Iterator iter = listPage.iterator();
	boolean alternating = false;
	while (iter.hasNext()) {
		MessageLineItem item = (MessageLineItem)iter.next();

		String checkbox = "";
		checkbox = "<input type='checkbox' name='mailid' value='" + item.getMessageName() + "' hidefocus=true onclick='chkBg();'>";
		
		String who = "";
// 		if (envelope != null) {
// 			MimeMessage msg = envelope.getMessage();
// 			String email = "";
// 			try { Address[] froms = msg.getFrom();
// 				if (froms != null) { InternetAddress from = (InternetAddress)froms[0]; email = from.getAddress(); }
// 			} catch(Exception ex) { email = "UNKNOWN"; }
			
// 			if (mailboxID == Mailbox.OUTBOX || 
// 				mailboxID == Mailbox.DRAFT ||
// 				mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {
// 				who = item.getDisplayTo();
// 			} else {
// 				StringTokenizer st = new StringTokenizer(item.getFromName(), "?");
// 				String tmpStr = "", enType = "", fromName= "";
// 				int count = 0;
// 				while(st.hasMoreTokens()) {
// 					String tmp = st.nextToken();
// 					if (count == 2) { enType = tmp; } else if (count == 3) { tmpStr = tmp; }
// 					count++;
// 				}
// 				if (enType.equals("Q")) { //인코딩 타입 Q : quoted-printable / B : Base64
// 					org.apache.commons.codec.net.QuotedPrintableCodec qp = new org.apache.commons.codec.net.QuotedPrintableCodec();
// 					fromName = qp.decode(tmpStr);
// 				} else { fromName = HtmlEncoder.encode(item.getFromName()); }
				
// 				String filterFormName = fromName.replaceAll("/\r\n/g", "").replaceAll("'", "´");
// 				who = new StringBuffer()
// 						.append("<a href=\"#\" ")
// 						.append(">")
// 						.append(fromName)
// 						.append("</a>")
// 						.append("<input type='hidden' name='mailinfo' value='" + item.getMessageName() + "／" + filterFormName + "／" + email + "'>")
// 						.toString();
				
// 			}
// 		}
		
		if (mailboxID == Mailbox.OUTBOX || 
			mailboxID == Mailbox.DRAFT ||
			mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {
			who = item.getDisplayTo();
			who += "<input type='hidden' name='mailinfo' value='" + item.getMessageName() + "／" + item.getDisplayTo() + "／" + item.getDisplayTo() + "'>";
		} else {
			String fromName = HtmlEncoder.encode(item.getFromName());
			String filterFormName = fromName.replaceAll("/\r\n/g", "").replaceAll("'", "´");
			String email = item.getSender();
			
			String regex = "[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}";
			java.util.regex.Pattern p = java.util.regex.Pattern.compile(regex, java.util.regex.Pattern.CASE_INSENSITIVE);
			java.util.regex.Matcher m = p.matcher(email);
			while(m.find()){
				email = m.group(0);
    		}
    		
			who = new StringBuffer()
			.append("<a href=\"#\" ")
				.append(">")
				.append(fromName)
				.append("</a>")
				.append("<input type='hidden' name='mailinfo' value='" + item.getMessageName() + "／" + filterFormName + "／" + email + "'>")
				.toString();
		}
		
		String importance = "";
		switch(item.getImportance()) {
			case 1 : importance = "<img src='../common/images/icon-flag.png' border='0' title='중요메일' style='cursor:hand;'>"; break;
			case 5 : importance = "<img src='../common/images/icon-flag-green.png' border='0' title='중요메일' style='cursor:hand;'>"; break;
		}
		
		String readImg = "";
		if (mailboxID == Mailbox.DRAFT ||
			mailboxID == Mailbox.RESERVED) {
			readImg = "<img src='../common/images/btn_draft.gif' border='0'>";						
		} else {
			if (item.isRead()) {
				if (mailboxID == Mailbox.OUTBOX) {
					readImg = "<a href=javascript:OnClickCheckReceipt('" + item.getMessageName() + "')>"
							+ "<img id='mchk_" + item.getMessageName() + "' src='../common/images/icon-mail-open.png' border='0' title='읽음'></a>";
				} else readImg = "<img id='mchk_" + item.getMessageName() + "' src='../common/images/icon-mail-open.png' border='0' title='읽음'>";
			} else readImg = "<img id='mchk_" + item.getMessageName() + "' src='../common/images/icon-mail.png' border='0' title='읽지않음'>";
		}
		
		//회신
		String isReply = "";
		if(item.isReply()){
			isReply = "<img src='/common/images/icon-mail-send-receive.png' title='회신' style='cursor:hand;' align=absmiddle hidefocus=true>";
		}
		
		String subject = item.getSubject();
		if (subject == null || subject.trim().length() < 1) subject = "제목없음"; else subject = HtmlEncoder.encode(subject);
		if (mailboxID == Mailbox.DRAFT ||
			mailboxID == Mailbox.RESERVED) {
			subject = new StringBuffer()
					.append("<a href=\"javascript:OnClickEdit('").append(item.getMessageName())
					.append("')\">").append(subject).append("</a>").toString();
		} else {
			subject = new StringBuffer()
					.append("<a" + ((item.isRead()) ? " style='color:#555;'" : "" ) + " href=\"javascript:OnClickOpen('").append(item.getMessageName())
					.append("','"+ item.getImportance() + "'" + ")\">" + ((item.isRead()) ? "" : "<span id='bl_"+item.getMessageName()+"'><B style='color:#000000;'>"/*<B>*/))
					.append((item.getImportance() == 1 && item.isRead()) ? "<font style='color:red;'>" : "").append(subject).append("</font>")
					.append(((item.isRead()) ? "" : "</B>" /*</B>*/)+ "</a>").toString();
		}
		
// 		if ( item.getImportance() == 1 ) {
// 			subject = "<font style='color:red;'>" + subject + "</font>";
// 		}
		String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(item.getDate()).substring(0, 16);

		String attachmentImg = "";
		if (item.hasAttachment()) {
// 			Collection attachments = envelope.getAttachments();
// 			int count = 0;
// 			if (attachments != null && attachments.size() > 0) {
// 				Iterator iter2 = attachments.iterator();
// 				while (iter2.hasNext()) {
// 					Attachment attachment = (Attachment)iter2.next();
// 					String cid = attachment.getContentID();
// 					if (cid != null) continue;
// 					count++;
// 				}
// 			}
// 			if (count > 0) {
				attachmentImg = "<a name='listAttach' rel='" + item.getMessageName() + "' href='#'><img src=\"../common/images/icons/icon_attach.gif\" title=\"첨부있음\" /></a>";
// 			}
		}
		
		String attachmentSize = FileSizeFormatter.format(item.getSize());

		cell.add(checkbox);
		cell.add(who);
		cell.add(importance);
		cell.add(attachmentImg);
		cell.add(readImg);
		cell.add(isReply);
		cell.add(subject);
		cell.add(date);
		cell.add(attachmentSize);
		cell.add(item.isRead());
		cellObj.put("mailid", item.getMessageName());
		cellObj.put("cell",cell);
		cellArray.add(cellObj);
		cell.clear();
	}
}

jsonData.put("rows",cellArray);
out.println(jsonData);
%>