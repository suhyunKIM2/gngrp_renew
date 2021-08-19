<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="nek.common.CommonPager" %>
<% request.setCharacterEncoding("utf-8");%>
<%!
	private String imagePath = "../common/images/img";
%>
<%
String currentPage = request.getParameter("pg");
String linkURL = request.getParameter("linkurl");
String linkType = request.getParameter("linktype");
String totalCount = request.getParameter("totalcount");
String paramString = request.getParameter("paramstring");
String listPPage = request.getParameter("listppage");
String blockPPage = request.getParameter("blockppage");
String tableWidth = request.getParameter("tablewidth");

if ("".equals(tableWidth) || tableWidth == null) tableWidth = "800";

int iLinkType, iTotalCount, iCurrentPage, iListPPage, iBlockPPage;

if ("".equals(linkType) || linkType == null) iLinkType = 2;
else iLinkType = "1".equals(linkType)? 1 : 2;

if ("".equals(totalCount) || totalCount == null) iTotalCount = 0;
else iTotalCount = Integer.parseInt(totalCount);

if ("".equals(currentPage) || currentPage == null) iCurrentPage = 1;
else iCurrentPage = Integer.parseInt(currentPage);

if ("".equals(listPPage) || listPPage == null) iListPPage = 10;
else iListPPage = Integer.parseInt(listPPage);

if ("".equals(blockPPage) || blockPPage == null) iBlockPPage = 10;
else iBlockPPage = Integer.parseInt(blockPPage);

if (paramString == null) paramString = "";
//linkURL = java.net.URLDecoder.decode(linkURL);
//paramString = java.net.URLDecoder.decode(paramString);

CommonPager pager = new CommonPager(iTotalCount, iCurrentPage, linkURL, paramString);
pager.setBlockPPage(iBlockPPage);
pager.setListPPage(iListPPage);
pager.setPagerLinkType(iLinkType);
pager.isUsingImage(true);
%>

<%=pager.getPagerInfo()%>
								