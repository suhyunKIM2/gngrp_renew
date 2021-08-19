<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="nek.corpschedule.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*, nek.common.util.Convert" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="net.sf.json.*"%>
<% 	request.setCharacterEncoding("utf-8"); %>
<%@ include file="/common/usersession.jsp"%>
<%
	int pageNo = 1;											// 현재 페이지 번호
	int listPPage = 10;										// 한 페이지에 보여줄 레코드 수
	String[] sortLists = null;								// 소트값 배열
	String[] searchMap = null;								// 검색값 배열
	
	CorpScheduleDao dao = null;								// 회사일정 DAO
	ArrayList<CorpScheduleItem> corpScheduleList = null;	// 회사일정 리스트
	CorpScheduleItem item = null;							// 회사일정 아이템
	int totalPage = 0;										// 총 페이지 수
	int totalCount = 0;										// 총 아이템 수
	
	JSONObject jsonData = null;								// JSON data
	JSONArray cellArray = null;								// JSON rows
	JSONObject cellObj = null;								// JSON row
	JSONArray cell = null;									// JSON col

	SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm");
	ParameterParser pp = new ParameterParser(request);
	pp.setCharacterEncoding("UTF-8");
	try { pageNo = Integer.parseInt(request.getParameter("pageNo")); } catch(Exception e) {}
	try { listPPage = Integer.parseInt(request.getParameter("rowsNum")); } catch(Exception e) {}
	sortLists = new String[]{ pp.getStringParameter("sortColumn", ""), pp.getStringParameter("sortType", "") };
	searchMap = new String[]{ pp.getStringParameter("searchKey", ""), pp.getStringParameter("searchVal", "") };

	String dpids = "''";
	if (uservariable.addressBook != null && !uservariable.addressBook.equals("")) {
		dpids = "'" + uservariable.addressBook.replaceAll(",", "','") + "'";
	}
	dao = new CorpScheduleDao();
	try {
		dao.getDBConnection();
		corpScheduleList = dao.getCorpScheduleList(pageNo, listPPage, sortLists, searchMap, loginuser.locale, dpids);
		totalCount = dao.getCorpScheduleListCount();
		totalPage = (int)(Math.ceil((double)totalCount/(double)listPPage));
	
		cellArray = new JSONArray();
		for(int i = 0, len = corpScheduleList.size(); i < len; i++) {
			item = corpScheduleList.get(i);
			
		    cell = new JSONArray();
	        cell.add(item.getsTitle());						// 구분
	        cell.add(item.getDpname());							// 본부명
	        cell.add(item.getSubject());						// 일정제목
	        cell.add(item.getStartdate());						// 시작일자
	        cell.add(item.getEnddate());						// 종료일자					
	        cell.add(item.getNname());							// 작성자명
	        cell.add(format.format(item.getCreateDate()));		// 작성일자

			cellObj = new JSONObject();
			cellObj.put("id", item.getDocId());	 				// 회사일정번호
	        cellObj.put("cell", cell);
	        
	        cellArray.add(cellObj);   
		}
	   		
		jsonData = new JSONObject();
		jsonData.put("total", totalPage);
		jsonData.put("page", pageNo);
		jsonData.put("records", totalCount);
		jsonData.put("rows",cellArray);
	    
		out.println(jsonData);
	} finally { if (dao != null) dao.freeDBConnection(); }
%>