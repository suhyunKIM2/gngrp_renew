<%@page import="javax.persistence.Convert"%>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.UserL" %>
<%@ page import="nek3.common.ListPage" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="net.sf.json.*"%>
<%
	ListPage listPage = (ListPage)request.getAttribute("listPage");
	nek3.common.SystemConfig systemConfig = (nek3.common.SystemConfig)request.getAttribute("systemConfig");
	
    JSONObject jsonData =new JSONObject();    
    jsonData.put("total", listPage.getPageCnt());
    jsonData.put("page", listPage.getPage());
    jsonData.put("records", listPage.getTotalCnt());
    jsonData.put("rowcnt", listPage.getRowCnt());
    
    JSONArray cellArray=new JSONArray();
    JSONArray cell = new JSONArray();
    JSONObject cellObj=new JSONObject();
    
	java.util.List<UserL> items = listPage.getItems();
	int idx = items.size();
	for(int i=0; i<idx; i++){
		UserL item = items.get(i);
		cellObj.put("id", item.getUserId());
		StringBuilder sb = new StringBuilder();
		sb.append("<img style=\"position:relative; top:-1px; \" src=\"/common/images/xfn.png\" align=\"absmiddle\" /><a style='font-weight:bold;' href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getUserId()).append("\");'>")
			.append(StringUtils.isEmpty(item.getnName()) ? "[---]" : item.getnName())
			//.append(StringUtils.isEmpty(item.geteName()) ? "" : "["+item.geteName()+"]")
			.append("</a>");
		cell.add(sb.toString());					//nName            
		//cell.add(item.geteName());					//ename
        cell.add(item.getAddJob());						//addJob           
        cell.add(item.getDepartment().getDpName());	//dpName            
        cell.add(item.getUserDuty().getUdName());	//udName        
        cell.add(item.getUserPosition().getUpName());	//upName 
        /* cell.add(item.getSabun());					//sabun */
        cell.add(item.getMainJob());				//mainJob
        cell.add(item.getTelNo());					//Tel.
       	cell.add(StringUtils.isEmpty(item.getCellTel()) ? "" : item.getCellTel());				//Cell.
		cell.add(item.getEmail());				//userName (email)
//		cell.add(item.getUserName() + "@" + systemConfig.getDomain());				//userName (email)
        
        cellObj.put("cell",cell);    
        cell.clear();    
        cellArray.add(cellObj);    
	}
    jsonData.put("rows",cellArray);
    out.println(jsonData);
%>
