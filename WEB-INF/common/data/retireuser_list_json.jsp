<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.User" %>
<%@ page import="nek3.common.ListPage" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="net.sf.json.*"%>
<%
	java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd");
	ListPage listPage = (ListPage)request.getAttribute("listPage");
	
    JSONObject jsonData =new JSONObject();    
    jsonData.put("total", listPage.getPageCnt());
    jsonData.put("page", listPage.getPage());
    jsonData.put("records", listPage.getTotalCnt());
    
    JSONArray cellArray = new JSONArray();
    JSONArray cell = new JSONArray();
    JSONObject cellObj = new JSONObject();
    
	java.util.List<User> items = listPage.getItems();
	for(int i = 0, idx = items.size(); i < idx; i++) {
		User item = items.get(i);

        cell.add(formatter.format(item.getRetireDate()));
        cell.add(item.getDepartment().getDpName());
        cell.add(item.getnName());
        cell.add(item.getUserPosition().getUpName());
        cell.add(item.getLoginId());

		cellObj.put("id", item.getUserId());
        cellObj.put("cell",cell);    
        cell.clear();    
        cellArray.add(cellObj);    
	}
    jsonData.put("rows",cellArray);
    out.println(jsonData);
%>
