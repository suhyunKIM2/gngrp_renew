<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="nek.corpschedule.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*, nek.common.util.Convert" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="net.sf.json.*"%>
<% 	request.setCharacterEncoding("utf-8"); %>
<%@ include file="/common/usersession.jsp"%>

<%
ArrayList listDatas = null;

CorpScheduleItem corpScheduleItem = null;
CorpScheduleList corpScheduleList = null;

int listCount = 0;
int totalCount = 0;
String listPage = "";
String docId = request.getParameter("docId");
SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
SimpleDateFormat dspformatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
Date NOW = new Date();
String today = formatter.format(NOW);
long lToday = NOW.getTime();	// 86400000	 : 하루의 milisecond

String dspDate = "";
int listPPage = 10;
int blockPPage = 10;
String linkURL = "";
String paramString = "";
String reward = "0";
String mileage = "0";
String dpids = "''";

String start = request.getParameter("start");
String end = request.getParameter("end");
try
{
	corpScheduleList = new CorpScheduleList(loginuser, corpScheduleItem); 
	corpScheduleList.getDBConnection();
	
	listPPage = uservariable.listPPage;
	blockPPage = uservariable.blockPPage;
	listPage = Convert.nullCheck(request.getParameter("listnum"));
	if(!listPage.equals("")){
		listPPage = Integer.parseInt(listPage);
	}else{
		listPPage = uservariable.listPPage;
	}
	if (uservariable.addressBook != null && !uservariable.addressBook.equals("")) {
		dpids = "'" + uservariable.addressBook.replaceAll(",", "','") + "'";
	}

	listDatas = corpScheduleList.getCorpScheduleList(start, end, loginuser.locale, dpids); 
	
	if (listDatas != null)
	{
	  listCount = listDatas.size();
	  //totalCount = proposalList.getTotalCount();
	}
//	linkURL = request.getRequestURI();


	JSONObject jsonData =new JSONObject();    
	//jsonData.put("total", listPage.getPageCnt());
	//jsonData.put("page", listPage.getPage());
	//jsonData.put("records", listPage.getTotalCnt());
	jsonData.put("total", listPPage);
	jsonData.put("page", blockPPage);
	jsonData.put("records", 10);

	JSONArray cellArray=new JSONArray();
	JSONArray cell = new JSONArray();     
	JSONObject cellObj=new JSONObject();
	String chk = "";
	for (int i=0; i<listCount; i++)
	{
		corpScheduleItem = (CorpScheduleItem)listDatas.get(i);

		cellObj.put("id", corpScheduleItem.getDocId() );
		
		
		
		chk = "[" + corpScheduleItem.getsTitle() + "] - " + corpScheduleItem.getDpname() + "\n";
		//if( chk.equals("예정")) {
			//chk = "<font color='red'><b>" + chk + "</b></font>";
		//}
        cellObj.put("title", chk + corpScheduleItem.getSubject() );
        cellObj.put("start", corpScheduleItem.getStartdate() + " 09:00:00");
        cellObj.put("end", corpScheduleItem.getEnddate() + " 15:00:00" );
        cellObj.put("allDay", false);
        cellObj.put("type", "corpschedule");
        cellObj.put("style", corpScheduleItem.getStype() );
        
        	//출장자명, 출장목적, 출장지역, 출발일, 복귀일, 출발지 >도착지, 등록자,
        //String tripuser = corpScheduleItem.getTripUsers();
        String tag = "" +
        "<style>" +
        "#trip {border-collapse:collapse; }" +
        "#trip td {padding:3px; font-size:10pt; color:#000; font-family:Dotum; word-break:break-all; border:1px solid #b7cbd9;}" +
        ".title {font-weight:bold; color:#000; text-align:center; background-color:#f2f7ff;}" +
        "</style>" +
        "  <table id='trip' width=100% height=100% border=0 cellspacing=0 cellpadding=0 style='border-collapse:collapse;'>" +
        "  <tr>" +
        "	<td width=80 class='title'>부 서</td>" +
        "	<td width=* bgcolor='#ffffff'>" + corpScheduleItem.getDpname() + "</td>" +
        " </tr>" +
        "  <tr>" +
        "	<td width=80 class='title'>일 자</td>" +
        "	<td width=* bgcolor='#ffffff'>" + corpScheduleItem.getStartdate() + " ~ " + corpScheduleItem.getEnddate() + "</td>" +
        " </tr>" +
        " <tr>" +
        "	<td class='title'>제 목</td>" +
        "	<td bgcolor='#ffffff'>" + "[" + corpScheduleItem.getStypeNm() + "]-" + corpScheduleItem.getSubject() + "</td>" +
        " </tr>" +
        " <tr>" +
        "	<td class='title'>내 용</td>" +
        "	<td bgcolor='#ffffff'>" + corpScheduleItem.getContents() + "</td>" +
        " </tr>" +
        " <tr>" +
        "	<td class='title'>등록자</td>" +
        "	<td bgcolor='#ffffff'>" + corpScheduleItem.getNname() + "</td>" +
        " </tr>" +

        "  </table>";
        
        cellObj.put("descript", tag);
        
        cellArray.add(cellObj);
	}

	jsonData.put("rows",cellArray);
    out.println(cellArray);
}
finally
{
	if (corpScheduleList != null) corpScheduleList.freeDBConnection();
}
%>