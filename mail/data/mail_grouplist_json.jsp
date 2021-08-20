<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="net.sf.json.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="nek.mail.group.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ include file="/common/usersession.jsp" %>
<%!
	private RecipientGroupManager rgManager = RecipientGroupManager.getInstance();
	private static HashMap SEARCH_FIELDS = new HashMap();
	static {
		SEARCH_FIELDS.put("title", new String[] { "title" });
		SEARCH_FIELDS.put("description", new String[] { "description" });
		SEARCH_FIELDS.put("members", new String[] { "members" });
		SEARCH_FIELDS.put("all", new String[] { "title", "description", "members" });
	}
%>
<%

	int iPageRow = 10; 		//한 페이지에 보여줄 레코드 수
	int iTotRows = 0; 			//총건수
	int totalPage = 0; 			//총 페이지 수
	int totalCount = 0; 		//총 레코드 수
	
	int iPageNum = Integer.parseInt(ApprUtil.setnullvalue(request.getParameter("pageNo"), "1")); //현재페이지
	String sState = ApprUtil.setnullvalue(request.getParameter("state"), "");
	String gubun = ApprUtil.setnullvalue(request.getParameter("gubun"), "P");
	String cmd = ApprUtil.setnullvalue(request.getParameter("cmd"), "list");
	String formId = ApprUtil.nullCheck(request.getParameter("formid"));
	String searchKey = ApprUtil.setnullvalue(request.getParameter("searchKey"), "");
	String searchValue = ApprUtil.setnullvalue(request.getParameter("searchValue"), "");
	String sortColumn = ApprUtil.setnullvalue(request.getParameter("sortColumn"), "");
	String sortType = ApprUtil.setnullvalue(request.getParameter("sortType"), "");
	String sUid = loginuser.uid;
	DBHandler db = null;
	Connection con = null;	
	ListFilter filter = null;
	
	//검색추가
	String[] searchFields = (String[])SEARCH_FIELDS.get(searchKey);
	if (searchFields != null && searchValue.length() > 0) {
		filter = new ListFilter(searchValue, searchFields, sortColumn, sortType);
	}else{
		filter = new ListFilter("", null, sortColumn, sortType);
	}
		
	ListPage listPage = null;
	
	try {
		db = new DBHandler();
		con = db.getDbConnection();
		listPage = rgManager.getPage(con, sUid, iPageNum, iPageRow, filter, gubun);
	} finally {
		if (db != null) {
			db.freeDbConnection();
		}
	}
	
	int iSize = (listPage == null) ? 0 : listPage.getTotalCount();
	iTotRows = iSize;
	
	JSONObject jsonData = new JSONObject();
	JSONArray cellArray = new JSONArray();
	JSONObject cellObj = new JSONObject();
	JSONArray cell = new JSONArray();
	
	String title = "";
	if (iSize > 0) {
		Iterator iter = listPage.iterator();
		while(iter.hasNext()){
			RecipientGroupLineItem item = (RecipientGroupLineItem)iter.next();
			
			StringBuilder sb = new StringBuilder();
			sb.append("<a href=\"javascript:OnClickOpenRecipientGroup('"+item.getSubID()+"')\">");
			sb.append(item.getTitle());
			sb.append("</a>");
			title = sb.toString();
			sb.setLength(0);
			cell.add(title);								//구분명
			
			cell.add(item.getDescription());		//설명
			cell.add(item.getOrderNum());			//순서
			cellObj.put("id", item.getSubID());	//ID
			cellObj.put("cell", cell);
			cell.clear();
			cellArray.add(cellObj);
		}
	}

	//총 페이지수 구하기
	try {
		totalPage = (int) (Math.ceil((double) iTotRows / (double) iPageRow));
	} catch (Exception e) {
		e.printStackTrace();
	}

	jsonData.put("total", totalPage); 		//총페이지수
	jsonData.put("page", iPageNum); 	//현재페이지 번호
	jsonData.put("records", iTotRows); 	//총게시물수
	jsonData.put("rows", cellArray); 		//데이터
	out.println(jsonData);
%>