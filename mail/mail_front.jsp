<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%!
	private MailRepository repository = MailRepository.getInstance();
	private SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
	private SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
%>
<%@ include file="../common/usersession.jsp" %>
<%
	request.setCharacterEncoding("utf-8");

	int listSize = Integer.parseInt(request.getParameter("listCount"));

	ListPage listPage = null;
	String linkURL = "#";

	//메일서버 DBconnect
	DBHandler db = new DBHandler();
	Connection con = null;
	try {
		con = db.getDbConnection();
		String domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
		listPage = repository.list(con, loginuser.emailId, Mailbox.INBOX, 1, listSize, null, domainName,  null);
		
		linkURL = "./common/menu_index.jsp?menucode=MENU01&expandid=MENU0102";

	} finally {
		if (con != null) { db.freeDbConnection(); }
	}

%>

<script language="javascript">
<!--
//     function OnClickOpenMail(messageName)
//     {
//         var WinWidth = 850 ;
//         var WinHeight = 500 ;
//         var winleft = (screen.width - WinWidth) / 2;
//         var wintop = (screen.height - WinHeight) / 2;
//         var UrlStr = "mail/mail_read.jsp?front=&message_name=" + messageName ;
//         var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );

//     }
//-->
</script>

<table id="aps" width=100% style="table-layout:fixed;">
<tbody>
					<%
						int count = 0;
						Calendar calendar = Calendar.getInstance();
						calendar.set(Calendar.HOUR_OF_DAY, 0);
						calendar.set(Calendar.MINUTE, 0);
						calendar.set(Calendar.SECOND, 0);
						calendar.set(Calendar.MILLISECOND, 0);
						long todayTime = calendar.getTime().getTime();

						Iterator iter = listPage.iterator();
						while (iter.hasNext()) {
							MessageLineItem item = (MessageLineItem)iter.next();
							
							String importance = "";
							switch(item.getImportance()) {
								case 1 : importance = "<img src='../common/images/icon-flag.png' border='0' title='중요메일' style='cursor:hand;'>"; break;
								case 5 : importance = "<img src='../common/images/icon-flag-green.png' border='0' title='중요메일' style='cursor:hand;'>"; break;
							}
							String attachmentSize = FileSizeFormatter.format(item.getSize());
					%>
										<tr style="height:24px; border-bottom:1px dotted #ddd; "> 
											<td width="90"><img src="/common/images/xfn.png" align="absmiddle"/><span style="font-weight:bold; color:#3072b3;; position:relative; top:2px;"><%=item.getFromName() %></span></td>
											<td width="20" style="padding:0px; " align="center"><%=importance %></td>
											<td width="20" align="center">
											<%
												if (item.hasAttachment()) {
													out.println("<img src='../common/images/icons/icon_attach.gif'>");
												}
											%>
											</td>
											<td width="20" style="padding:0px; " align="center"><img src="/common/images/<%=(item.isRead()) ? "icon-mail-open.png" : "icon-mail.png"%>" width=70% height=70% align=absmiddle></td>
											<td width="*" style="padding-left:3px; padding-top:3px;">
											<a href="javascript:OnClickOpenMail('<%=item.getMessageName()%>')" <%=(item.isRead()) ? "style='color:#777;' " : ""%> onfocus="this.blur();"><%= (item.getImportance() == 1) ? "<font style='color:red;'>" : "" %><%=HtmlEncoder.encode(item.getSubject())%> <%= (item.getImportance() == 1) ? "</font>" : "" %>
											</a></td>
<%-- 											<td width="60" align="center"><%=HtmlEncoder.encode(item.getFromName())%></td> --%>
											<td width="70" align="center" class="clip" style="font-family:arial; padding-left:3px;padding-top:3px;">
						<%
							java.util.Date date = item.getDate();
							if (todayTime < date.getTime()) {
								out.print(timeFormatter.format(date));
							} else {
								out.print(dateFormatter.format(date));
							}
						%>
											</td>
											<td width="40" align="right" style="padding-top:3px;colors:#777;font-family:arial; "><%=attachmentSize %></td>
										</tr>
						<%
						}
						%>
</table>