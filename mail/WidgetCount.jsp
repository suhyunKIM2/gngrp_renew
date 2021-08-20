<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.notification.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ include file="../common/usersession.jsp"%>
<%!
	private MailRepository repository = MailRepository.getInstance();
%>
<%
	long mailQuota = uservariable.mailBoxSize/(1024*1024);
	DBHandler db =  null;
	Connection pconn = null;
	Mailboxes mailboxes = null;
	MailboxSummaries summaries = null;
	NotificationSummaries noteSsummaries = null;
	ArrayList data = null;
	int mailUnRead= 0;
	try{
		String domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
		
		db = new DBHandler();
		pconn = db.getDbConnection();
		
		//받은편지함 읽지 않은 갯수
//		MailRepositorySummary mailboxSummary  =  MailRepository.getInstance().getRepositorySummary(pconn, loginuser.emailId, domainName);
		
//		double mailUsage = (double)mailboxSummary.getTotalSize();
//		mailUsage = mailUsage/(1024.0*1024.0);
//		int mailPercent = (int)(mailQuota == 0 ? 0 : (100* mailUsage)/mailQuota);
//		if (mailPercent > 100) {
//			mailPercent = 100;
//		}
		//전자메일 - 서브폴더
//		mailboxes = repository.getCustomMailboxes(pconn, loginuser.emailId, domainName);
//		summaries = repository.getMailboxSummaries(pconn, loginuser.emailId, domainName);
		mailUnRead= MailRepository.getInstance().getMailUnReadCount(pconn, loginuser.emailId, domainName);
		
		//임시저장함 갯수
//		int iDraftMailCnt =  repository.getTotalMailCnt(pconn, loginuser.emailId, domainName, Mailbox.DRAFT);
		//예약함 갯수
//		int iReservedMailCnt =  repository.getTotalMailCnt(pconn, loginuser.emailId, domainName, Mailbox.RESERVED);
		//스팸편지함 갯수
//		int iSpamMailCnt =  repository.getTotalMailCnt(pconn, loginuser.emailId, domainName, Mailbox.SPAM);
		//휴지통 갯수
//		int iTrashMailCnt = repository.getTrashMailCnt(pconn, loginuser.emailId, domainName);
		
// 		out.print(mailboxSummary.getUnreadCount());
		out.print(mailUnRead);
	}catch(Exception e){
		
	}finally{
		if (db != null) db.freeDbConnection();
	}
%>