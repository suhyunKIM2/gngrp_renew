<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page contentType="text/html;charset=utf-8"%>
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%@ page import="javax.activation.*"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="org.jsoup.Jsoup"%>
<%@ page import="org.jsoup.nodes.Document"%>
<%@ page import="org.jsoup.nodes.Element"%>
<%@ page import="org.jsoup.select.Elements"%>
<%@ page import="nek.mail.*"%>
<%@ page import="nek.common.*"%>
<%@ page import="nek.common.dbpool.*"%>
<%@ page import="org.json.*" %>
<%@ page import="com.tagfree.util.*"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="java.util.regex.Pattern"%>
<%!private MailRepository repository = MailRepository.getInstance();

	private long totSize = 0; //총 업로드 파일 크기
	private int totCnt = 0; //총 파일수

	SimpleDateFormat format_today = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmssSS");
	SimpleDateFormat endFormat = new SimpleDateFormat("yyyy-MM-dd");
	private String nowString = "";

	private Address[] makeInternetAddresses(String recipients, String encoding)
			throws UnsupportedEncodingException {
		String[] strs = StringUtil.splitStr(recipients, ',');
		if (strs == null) {
			return null;
		}

		ArrayList results = null;

		int start;
		int end;

		String personal;
		String address;

		for (int i = 0; i < strs.length; i++) {
			String str = strs[i].trim();
			if (str.length() > 1) {
				personal = null;
				address = null;

				//personal -------------------------------------------
				start = str.indexOf('"');
				if (start > -1) {
					end = str.indexOf('"', start + 1);
					if (end > -1) {
						personal = str.substring(start + 1, end);
					}
				}

				//address --------------------------------------------
				start = str.indexOf('<');
				if (start > -1) {
					end = str.indexOf('>', start + 1);
					if (end > -1) {
						address = str.substring(start + 1, end);
					}
				}

				if (address == null) {
					//address 없음
				} else {
					if (results == null) {
						results = new ArrayList();
					}
					results.add(new InternetAddress(address, personal, encoding));
				}
			}
		}

		if (results == null) {
			return null;
		} else {
			int size = results.size();
			Address[] addresses = new Address[size];
			for (int i = 0; i < size; i++) {
				addresses[i] = (Address) results.get(i);
			}
			return addresses;
		}
	}

	//업로드 파일 총크기를 비교한다.
	private boolean getPostedFiles(MultipartRequest multi, long filesize, String isDms, String[] dmsFiles) {
		boolean breturn = false;
		try {
			Enumeration fileNames = multi.getFileNames();

			String fileName;
			File attachFile;

			while (fileNames.hasMoreElements()) {
				fileName = (String) fileNames.nextElement();
				if (multi.getFilesystemName(fileName) != null) {
					attachFile = multi.getFile(fileName);
					//사이즈 검사를 하자. ??????????????
					totSize += attachFile.length();
				}
				totCnt++;
			}
			
			if(!isDms.equals("")){
				for(int i=0;i<dmsFiles.length;i++){
					String tmp = dmsFiles[i];
					try{
						long dmsFileSize = Long.parseLong(tmp.substring(tmp.lastIndexOf("／")+1));
						totSize += dmsFileSize;
						totCnt++;
					}catch(Exception e){}
				}
			}

			//System.out.println("업로드 파일 크기 :" +totSize + " / 제한파일크기 : " + filesize);
			//설정된 파일 크기보다 업로드된 파일이 크다면 true
			if (totSize > filesize) {
				breturn = true;
			}
		} catch (Exception e) {
		} finally {
		}
		return breturn;
	}
	
	private boolean getHtml5PostedFiles(String htmlUploadPath, long filesize, String isDms, String[] dmsFiles) {
		boolean breturn = false;
		try {
			File folderFile[] = null;
			File fileDir = new File(htmlUploadPath);
			if (fileDir.exists()){
				folderFile = new File(htmlUploadPath).listFiles();
				
				int count = 0;
				for(int i=0;i<folderFile.length;i++){
					if(folderFile[i]==null){
						continue;
					}
					if (folderFile[i].isDirectory()) continue;
					String name = folderFile[i].getName();

					totSize += folderFile[i].length();
					totCnt++;
				}
			}
			
			if(!isDms.equals("")){
				for(int i=0;i<dmsFiles.length;i++){
					String tmp = dmsFiles[i];
					try{
						long dmsFileSize = Long.parseLong(tmp.substring(tmp.lastIndexOf("／")+1));
						totSize += dmsFileSize;
						totCnt++;
					}catch(Exception e){}
				}
			}

			//System.out.println("업로드 파일 크기 :" +totSize + " / 제한파일크기 : " + filesize);
			//설정된 파일 크기보다 업로드된 파일이 크다면 true
			if (totSize > filesize) {
				breturn = true;
			}
		} catch (Exception e) {
		} finally {
		}
		return breturn;
	}
	

	//업로드 파일크기 용량계산
	private static String reportTraffic(long trafficPrint) {

		if ((trafficPrint / (1024 * 1024 * 1024)) > 0) {
			return ((new java.math.BigDecimal((float) trafficPrint
					/ (1024 * 1024 * 1024)).setScale(1,
					java.math.BigDecimal.ROUND_HALF_UP)) + " GB");
		} else if ((trafficPrint / (1024 * 1024)) > 0) {
			return ((new java.math.BigDecimal((float) trafficPrint
					/ (1024 * 1024)).setScale(1,
					java.math.BigDecimal.ROUND_HALF_UP)) + " MB");
		} else if ((trafficPrint / 1024) > 0) {
			return ((new java.math.BigDecimal((float) trafficPrint / 1024)
					.setScale(1, java.math.BigDecimal.ROUND_HALF_UP)) + " KB");
		} else {
			return (trafficPrint + " Byte");
		}
	}
	
	public boolean deleteFolder(File targetFolder){
		
		if(targetFolder == null) return false;
		if(!targetFolder.isDirectory()) return false;

		File[] childFile = targetFolder.listFiles();
	    boolean confirm = false;
	      
	    int size = childFile.length;
	    if (size > 0) {
	    	for (int i = 0; i < size; i++) {
	    		if (childFile[i].isFile()) {
	    			confirm = childFile[i].delete();
// 	                  System.out.println(childFile[i]+":"+confirm + " 삭제");
				} else {
					deleteFolder(childFile[i]);
				}
	    	}
	    }
	    targetFolder.delete();
	 
	    return (!targetFolder.exists());
	}
	
	//메일 주소 태그 영역 추출
	private String getMailToAddress(String recipient){
		//메일 주소 영역
		String myRegExp = "[_0-9a-zA-Z-]+[_a-z0-9-.]{2,}@[a-z0-9-]{2,}(.[a-z0-9]{2,})*";
		String emailAddr = "";
		Pattern p = Pattern.compile(myRegExp);
		Matcher m = p.matcher(recipient);
		boolean result = m.find();
		if (result) {
			emailAddr = m.group();
		} else {
			emailAddr = recipient;
		}
		return emailAddr;
	}

	//메일 주소 네임  태그 영역 추출
	private String getMailToName(String recipient){
		String regex = "\"[^\"]*\"";
		Pattern p = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
		Matcher m = p.matcher(recipient);
		String emailNm= "";
		while(m.find()){
			emailNm = m.group(0);
		}
		emailNm = emailNm.replaceAll("\"", "");
		
		return emailNm;
	}

	//디렉토리의 존재여부를 체크
	private void checkSaveDir(String saveDir) {
		File dir = new File(saveDir);
		if (!dir.exists())
			dir.mkdirs();
	}

	//그룹맴버값에서 이름 <메일주소> 형식으로 반환
	private String groupMember(String str) {
		String members = "";
		String[] list = str.split(",");
		for(int i = 0, len = list.length; i < len; i++) {
			if (!members.equals("")) members += ",";
			String item = StringUtils.trim(list[i]);
			String name = item.split("<")[0].split("\\(")[0].split("\\/")[0] + "\"";
			String email = "<" + item.split("<")[1];
			members += name + " " + email;
		}
		return members;
	}
%>
<%@ include file="../common/usersession.jsp"%>
<%
	long lStart = System.currentTimeMillis();
	String webPort = ""; //"14275";

	//현재 사용자의 임시 업로드 저장폴더 확인 후 없으면 생성해준다.
	String tmpPath = application.getInitParameter("nek.mail.tempdir")
			+ loginuser.loginId;
	String uploadPath = application.getInitParameter("upload_path"); //html5 uploadpath
		String imgUploadPath = application.getInitParameter("image_upload_path2"); //html5 Image uploadpath
	File tmpDir = new File(tmpPath);
	if (!tmpDir.exists() || !tmpDir.isDirectory()) {
		tmpDir.mkdir();
	}
	
	//문서관리 데이터 저장영역
	String dmsDir = application.getInitParameter("datadir");
	if (!dmsDir.endsWith(File.separator)) dmsDir += File.separator;
	dmsDir = dmsDir + "dms" + File.separator;

	MultipartRequest mr = null;

	DBHandler db = null;
	Connection con = null;
	int redirectMailbox = 2;
	ConfigItem cfItem = null;

	try {
		//paramters ------------------------------------------------------
		String nekMsgID = ""; //회수메일 ID
		String cmd = null;
		boolean isDraft = false;
		boolean isReply = false;
		boolean saveAfterSent = false;
		boolean checkReceipt = false;
		String to = null;
		String cc = null;
		String bcc = null;
		String body = null;
		int importance;
		String messageName = null;
		List drops = null;
		java.util.Date reserved = null;
		String filePath = "";
		String nanoPath = "";
		File fileDir = null;
		File ImgFileDir = null;
		String browser = null;
		String isDms= null;
		String[] dmsFiles = null;
		List<String> imsiFiles = null;
		
		//-----------------------------------------------------------------------------------

		long sendMailSize = 0;
		try {
			db = new DBHandler();
			con = db.getDbConnection();
			cfItem = ConfigTool
					.getConfigValue(con, application
							.getInitParameter("CONF.SEND_MAIL_SIZE")); // send mail size
			if (cfItem != null)
				sendMailSize = Long.parseLong(cfItem.cfValue);
		} finally {
			if (db != null)
				db.freeDbConnection();
		}

		mr = new MultipartRequest(request, tmpPath, (int) uservariable.sendMailSize, "utf-8", new DefaultFileRenamePolicy());

		messageName = mr.getParameter("message_name");
		browser = mr.getParameter("browser");
		browser = "";	//20121207 웹에디터 쓰지 않음
		filePath = mr.getParameter("filepath");
		nanoPath = mr.getParameter("nanotime");
		String[] imgHidList = mr.getParameterValues("imghid");	//본문이미지 실제파일명 구분자 특수문자 ／
		isDms = mr.getParameter("isdms");
		dmsFiles = mr.getParameterValues("dmsfiles"); 
		if (isDms == null) {
			isDms = "";
		}

		cmd = mr.getParameter("cmd");
		if (cmd == null) {
			cmd = "send";
		}

		isDraft = cmd.equals("draft");
		saveAfterSent = mr.getParameter("saveaftersent") != null;
		checkReceipt = mr.getParameter("chkreceipt") != null;

		to = mr.getParameter("to");
		cc = mr.getParameter("cc");
		bcc = mr.getParameter("bcc");
		
		isReply = cmd.equals("reply") ? true :  cmd.equals("replyall") ? true : false;	
		String reply_userName = mr.getParameter("reply_userName");
		String reply_messageName = mr.getParameter("reply_messageName");
		String reply_domainName = mr.getParameter("reply_domainName");
		
		String logString = format_today.format(new java.util.Date());
// 		System.out.println("["+logString+"]  MAIL - ");
// 		System.out.println("["+logString+"]  MAIL - cmd: " + cmd);
// 		System.out.println("["+logString+"]  MAIL - user-agent: " + request.getHeader("user-agent"));

		//내부사용자 체크 Flag
		boolean inUser = false;
		String domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;

		//대광직물 멀티도메인 (하드코딩)
		String multiDomainName[] = {"daekwangtex.com", "icei.co.kr", "nscind.co.kr"};
		
		//사내 부서그룹메일 발송시 
		//recipients -----------------------------------------------------------------
		String[] recipient_to = to.split(",");
		String[] recipient_cc = cc.split(",");
		String[] recipient_bcc = bcc.split(",");
		String reTO = "";
		String reCC = "";
		String reBCC = "";
		ArrayList arrList = null;
		ArrayList autoEmailList = new ArrayList();
		if (recipient_to != null) {
			for (int i = 0; i < recipient_to.length; i++) {
				if (recipient_to[i].length() > 0) {
					char c = recipient_to[i].charAt(0);
					if (c == 'D') {
						//D:이름:deptid:(+|-)...
						if (i != 0)
							reTO += ",";
						String[] tempStr = recipient_to[i].split(":");
						String dpId = tempStr[1];
						try {
							db = new DBHandler();
							con = db.getDbConnection();
							if (Boolean.parseBoolean(tempStr[3])) {
								arrList = repository
										.getDeptUserMailList(con, dpId);
							} else {
								arrList = repository.getUserMailList(
										con, dpId);
							}
						} finally {
							if (db != null)
								db.freeDbConnection();
						}
						if (arrList != null) {
							Iterator iter = arrList.iterator();
							HashMap data = null;
							int count = 0;
							while (iter.hasNext()) {
								data = (HashMap) iter.next();
								// 사내 부서그룹메일 발송시 수신인에 자신이 포함되어 있다면 자신은 제외한다. 2014-02-04
								if (loginuser.emailId.equals(data.get("mailid"))) continue;
								if (count != 0)
									reTO += ",";
								reTO += "\"" + data.get("nname")
										+ "\" <" + data.get("mailid")
										+ "@" + data.get("domain")
										+ ">";
								count++;
								//메일 자동완성 주소 (네임과 주소를 구분 특수문자 ㄱ (／)
								autoEmailList.add(data.get("nname")
										+ "／" + data.get("mailid")
										+ "@" + data.get("domain"));
							}
							inUser = true;
						}
					} else if (c == 'G') {
						//G:이름:subid...
						String[] tempStr = recipient_to[i].split(":");
						String subid = tempStr[1];
						String members = null;
						try {
							db = new DBHandler();
							con = db.getDbConnection();
							members = repository.getMailGroupMembers(con, subid, "S");
						} finally { if (db != null) db.freeDbConnection(); }

						if (members != null) {
							if (i != 0) reTO += ",";
							reTO += groupMember(members);
							inUser = true;
						}
					} else {
						if (i != 0)
							reTO += ",";
						reTO += recipient_to[i];
// 						int frLeft = recipient_to[i].indexOf("<");
// 						int frRight = recipient_to[i].indexOf(">");
// 						String mailTo = (recipient_to[i].substring(frLeft + 1, frRight));
// 						String toName = mailTo;
// 						if (recipient_to[i].indexOf("\"") > -1) {
// 							toName = recipient_to[i].substring(0, frLeft - 1).replaceAll("\"", "");
// 						}
						//메일 자동완성 주소
						autoEmailList.add(getMailToName(recipient_to[i]) + "／" + getMailToAddress(recipient_to[i]));
						//내부 사용자확인(도메인으로 체크)
						if (recipient_to[i].indexOf(domainName) > -1) {
							inUser = true;
						}
						//내부 사용자확인 (멀티도메인으로 체크:하드코딩) 2014-10-10
						for(int m = 0, len = multiDomainName.length; m < len; m++) {
							if (recipient_to[i].indexOf(multiDomainName[m]) > -1) {
								inUser = true;
							}
						}
					}
				}
			}
		}
		if (recipient_cc != null) {
			for (int i = 0; i < recipient_cc.length; i++) {
				if (recipient_cc[i].length() > 0) {
					char c = recipient_cc[i].charAt(0);
					if (c == 'D') {
						//D:이름:deptid:(+|-)...
						if (i != 0)
							reCC += ",";
						String[] tempStr = recipient_cc[i].split(":");
						String dpId = tempStr[1];
						try {
							db = new DBHandler();
							con = db.getDbConnection();
							if (Boolean.parseBoolean(tempStr[3])) {
								arrList = repository
										.getDeptUserMailList(con, dpId);
							} else {
								arrList = repository.getUserMailList(
										con, dpId);
							}
						} finally {
							if (db != null)
								db.freeDbConnection();
						}
						if (arrList != null) {
							Iterator iter = arrList.iterator();
							HashMap data = null;
							int count = 0;
							while (iter.hasNext()) {
								data = (HashMap) iter.next();
								// 사내 부서그룹메일 발송시 참조인에 자신이 포함되어 있다면 자신은 제외한다. 2014-02-04
								if (loginuser.emailId.equals(data.get("mailid"))) continue;
								if (count != 0)
									reCC += ",";
								reCC += "\"" + data.get("nname")
										+ "\" <" + data.get("mailid")
										+ "@" + data.get("domain")
										+ ">";
								count++;
							}
							inUser = true;
						}
					} else if (c == 'G') {
						//G:이름:subid...
						String[] tempStr = recipient_cc[i].split(":");
						String subid = tempStr[1];
						String members = null;
						try {
							db = new DBHandler();
							con = db.getDbConnection();
							members = repository.getMailGroupMembers(con, subid, "S");
						} finally { if (db != null) db.freeDbConnection(); }

						if (members != null) {
							if (i != 0) reCC += ",";
							reCC += groupMember(members);
							inUser = true;
						}
					} else {
						if (i != 0)
							reCC += ",";
						reCC += recipient_cc[i];
// 						int frLeft = recipient_cc[i].indexOf("<");
// 						int frRight = recipient_cc[i].indexOf(">");
// 						String mailTo = (recipient_cc[i].substring(
// 								frLeft + 1, frRight));
// 						String ccName = mailTo;
// 						if (recipient_cc[i].indexOf("\"") > -1) {
// 							ccName = recipient_cc[i].substring(0,
// 									frLeft - 1).replaceAll("\"", "");
// 						}
// 						autoEmailList.add(ccName + "／" + mailTo);
						//메일 자동완성 주소
						autoEmailList.add(getMailToName(recipient_cc[i]) + "／" + getMailToAddress(recipient_cc[i]));
						//내부 사용자확인(도메인으로 체크)
						if (recipient_cc[i].indexOf(domainName) > -1) {
							inUser = true;
						}
						//내부 사용자확인 (멀티도메인으로 체크:하드코딩) 2014-10-10
						for(int m = 0, len = multiDomainName.length; m < len; m++) {
							if (recipient_cc[i].indexOf(multiDomainName[m]) > -1) {
								inUser = true;
							}
						}
					}
				}
			}
		}
		if (recipient_bcc != null) {
			for (int i = 0; i < recipient_bcc.length; i++) {
				if (recipient_bcc[i].length() > 0) {
					char c = recipient_bcc[i].charAt(0);
					if (c == 'D') {
						//D:이름:deptid:(+|-)...
						if (i != 0)
							reBCC += ",";
						String[] tempStr = recipient_bcc[i].split(":");
						String dpId = tempStr[1];
						try {
							db = new DBHandler();
							con = db.getDbConnection();
							if (Boolean.parseBoolean(tempStr[3])) {
								arrList = repository.getDeptUserMailList(con, dpId);
							} else {
								arrList = repository.getUserMailList(con, dpId);
							}
						} finally {
							if (db != null)
								db.freeDbConnection();
						}
						if (arrList != null) {
							Iterator iter = arrList.iterator();
							HashMap data = null;
							int count = 0;
							while (iter.hasNext()) {
								data = (HashMap) iter.next();
								// 사내 부서그룹메일 발송시 비밀참조인에 자신이 포함되어 있다면 자신은 제외한다. 2014-02-04
								if (loginuser.emailId.equals(data.get("mailid"))) continue;
								if (count != 0)
									reBCC += ",";
								reBCC += "\"" + data.get("nname")
										+ "\" <" + data.get("mailid")
										+ "@" + data.get("domain")
										+ ">";
								count++;
							}
							inUser = true;
						}
					} else if (c == 'G') {
						//G:이름:subid...
						String[] tempStr = recipient_bcc[i].split(":");
						String subid = tempStr[1];
						String members = null;
						try {
							db = new DBHandler();
							con = db.getDbConnection();
							members = repository.getMailGroupMembers(con, subid, "S");
						} finally { if (db != null) db.freeDbConnection(); }

						if (members != null) {
							if (i != 0) reBCC += ",";
							reBCC += groupMember(members);
							inUser = true;
						}
					} else {
						if (i != 0)
							reBCC += ",";
						reBCC += recipient_bcc[i];
// 						int frLeft = recipient_bcc[i].indexOf("<");
// 						int frRight = recipient_bcc[i].indexOf(">");
// 						String mailTo = (recipient_bcc[i].substring(
// 								frLeft + 1, frRight));
// 						String bccName = mailTo;
// 						if (recipient_bcc[i].indexOf("\"") > -1) {
// 							bccName = recipient_bcc[i].substring(0, frLeft - 1).replaceAll("\"", "");
// 						}
// 						autoEmailList.add(bccName + "／" + mailTo);
						//메일 자동완성 주소
						autoEmailList.add(getMailToName(recipient_bcc[i]) + "／" + getMailToAddress(recipient_bcc[i]));
						//내부 사용자확인(도메인으로 체크)
						if (recipient_bcc[i].indexOf(domainName) > -1) {
							inUser = true;
						}
						//내부 사용자확인 (멀티도메인으로 체크:하드코딩) 2014-10-10
						for(int m = 0, len = multiDomainName.length; m < len; m++) {
							if (recipient_bcc[i].indexOf(multiDomainName[m]) > -1) {
								inUser = true;
							}
						}
					}
				}
			}
		}
		to = reTO;
		cc = reCC;
		bcc = reBCC;

// 		System.out.println("["+logString+"]  MAIL - To: " + to);
// 		if (cc != null && !"".equals(cc.trim()))
// 			System.out.println("["+logString+"]  MAIL - Cc: " + cc);
// 		if (bcc != null && !"".equals(bcc.trim()))
// 			System.out.println("["+logString+"]  MAIL - BCc: " + bcc);

		body = mr.getParameter("mailbody");
		MimeUtil util = new MimeUtil(); // com.tagfree.util.MimeUtil 생성
		String imsiPath = request.getSession().getServletContext().getRealPath("/") + File.separator + "mail" + File.separator + "temp" + File.separator + loginuser.loginId + File.separator + "imsi" ;
		if (body == null) {
			body = "";
		}else{
			if(!browser.equals("")){
				util.setMimeValue(body); // 작성된 본문 + 포함된 이진 파일의 MIME 값 지정
				util.setSavePath(imsiPath); // 저장 디렉터리 지정
				util.setSaveUrl("/common/"); // URL 경로 지정
				util.setInCharEncoding("iso8859-1");
				util.setOutCharEncoding("utf-8");
				util.setSaveFilePattern("yyyyMMddHHmmssSS");	//이미지 파일명을 랜덤으로 변경함.
				util.setRename(true); // 파일을 저장 시에 새로운 이름을 생성할 것인지를 설정
				util.setNekImgList(imgHidList);	//가람 추가 20121113
				util.processNekMailDecoding(); // MIME 값의 디코딩(메일용)
				body = util.getDecodedHtml(false);// 디코딩된 HTML을 가져옴.
			}else{
				
			}
		}

		if (mr.getParameter("reserved") != null) {
			reserved = new java.util.Date(Long.parseLong(mr.getParameter("reserved_dt")));
		}

		//String paramImportance = mr.getParameter("importance");
		//if (paramImportance == null) {
		//	importance = 3;	//1, 3, 5
		//} else {
		//	importance = Integer.parseInt(paramImportance);
		//}
		importance = mr.getParameter("importance") == null ? 3 : 1;

		String[] dropFiles = mr.getParameterValues("DROP");
		if (dropFiles != null) {
			drops = Arrays.asList(dropFiles);
		}

		//parse parameters end --------------------------------------------------

		//create mail session
		String smtp = application
				.getInitParameter("nek.mail.smtp.host");
		Properties prop = new Properties();
		prop.put("mail.smtp.host", smtp);
		//prop.put("mail.smtp.port", "27");
		//prop.put("mail.smtp.localhost",  "MailService"); 

		javax.mail.Session mailSession = javax.mail.Session
				.getInstance(prop, null);

		//new message
		MimeMessage msg = new MimeMessage(mailSession);

		//set recipients & from ------------------------------------------------------
		Address[] recipients = null;
		if (to != null&& (recipients = makeInternetAddresses(to, "utf-8")) != null) {
			msg.addRecipients(Message.RecipientType.TO, recipients);
		}
		if (cc != null&& (recipients = makeInternetAddresses(cc, "utf-8")) != null) {
			msg.addRecipients(Message.RecipientType.CC, recipients);
		}
		if (bcc != null&& (recipients = makeInternetAddresses(bcc, "utf-8")) != null) {
			msg.addRecipients(Message.RecipientType.BCC, recipients);
		}
		//멀티도메인
		String fromAdd = "";
		if (!uservariable.userDomain.equals("")) {
			fromAdd = loginuser.emailId + "@" + uservariable.userDomain;
			domainName = uservariable.userDomain;
		} else {
			if (!"".equals(loginuser.email) && null != loginuser.email)	fromAdd = loginuser.email;
			fromAdd = loginuser.emailId + "@" + application.getInitParameter("nek.mail.domain");
		}
		InternetAddress sender = null;
		if(loginuser.eName!=null){
			if(!loginuser.eName.trim().equals("")){
				sender = new InternetAddress(fromAdd, loginuser.nName+ "(" +loginuser.eName+")", "utf-8");
			}else{
				sender = new InternetAddress(fromAdd, loginuser.nName, "utf-8");
			}
		}else{
			sender = new InternetAddress(fromAdd, loginuser.nName, "utf-8");
		}

// 		System.out.println("["+logString+"]  MAIL - Sender: " + loginuser.nName + "/" + loginuser.upName + "/" + loginuser.dpName + "/" + loginuser.uid + " ("+fromAdd+")");
		
// 		sender = new InternetAddress(fromAdd, loginuser.nName, "utf-8");
		//InternetAddress sender = new InternetAddress(loginuser.emailId + "@" + application.getInitParameter("nek.mail.domain"), loginuser.nName, "utf-8");
		msg.setFrom(sender);
		InternetAddress[] replyTo = new InternetAddress[1];
		replyTo[0] = sender;
		msg.setReplyTo(replyTo);
		if(checkReceipt){
			msg.setHeader("Disposition-Notification-To", sender.toString());
		}
		//XXX:2004-12-27 추가 by Kim Do Hyoung
		msg.setHeader("Return-Path", sender.toString());
		//XXX:2009-04-16 추가 by Kim Sung Jin 회수메일 ID
		if (inUser) {
			java.util.Date now = new java.util.Date();
			java.text.SimpleDateFormat sm = new java.text.SimpleDateFormat(
					"yyyyMMddHHmmssSS");
			nekMsgID = "NEK_" + sm.format(now);
			msg.setHeader("X-NEK-Message-ID", nekMsgID);
		}

		String homePath = null;
		db = new DBHandler();
		con = db.getDbConnection(); //그룹웨어서버
		cfItem = ConfigTool.getConfigValue(con,	application.getInitParameter("CONF.HOME_PATH"));
		homePath = cfItem.cfValue;
		if (!homePath.endsWith("/")) homePath += "/";
		
		if ("daekwangtex.com".equals(domainName)) {
			homePath = "http://mail." + domainName + "/";
		} else if ("icei.co.kr".equals(domainName)) {
			homePath = "http://mail." + domainName + "/";
		} else if ("nscind.co.kr".equals(domainName)) {
			homePath = "http://mail." + domainName + "/";
		}

		// 메일 대용량다운/수신체크 (폐쇄망 일 시 특정 포트 사용)
		if (!"".equals(webPort)) {
			homePath = homePath.replaceFirst("(?s)(.*)/", "$1:"+webPort+"/");
		}

		String newMessageName = mr.getParameter("maildoc");
		newMessageName = "S"+newMessageName;
		newMessageName = "SMail"  + loginuser.uid + System.currentTimeMillis();
		StringBuffer newBody2 = new StringBuffer()
				.append("<img id='nekrecchk' style='display:hidden' width='0' height='0' src='")
				.append(homePath)
				.append("mail/mail_chkreceipt.jsp?domainName=")
				.append(domainName).append("&message_name=")
				.append(newMessageName).append("&recipient=$_RCPT_$'>");
		//IE인 경우 Active 처리함.
		String nowBody = "";
// 		if(!browser.equals("")){
// 			sun.misc.BASE64Encoder encode = new sun.misc.BASE64Encoder();
// 			nowBody = encode.encode(newBody2.toString().getBytes());
// 		}else{
// 			nowBody = newBody2.toString();
// 		}
// 		if (checkReceipt) {	
			nowBody = newBody2.toString();		//하나로 수신확인은 무조건 함. 
// 		}

		//-------------------------------------------------------------------------
		//업로된 파일 크기가 설정된 크기보다 크면 링크 처리
		totSize = 0; //초기화
		totCnt = 0; //초기화
		boolean isChk = false;
		boolean isBigChk = false;
		sendMailSize = 1024 * 1024 * 21; //21M이상부터는 자동으로 대용량메일 발송
		String htmlUploadPath = uploadPath + filePath  + File.separator + loginuser.uid + File.separator + nanoPath;
		String htmlImgUploadPath = imgUploadPath + File.separator + loginuser.uid;

		String bigFile = nek.common.util.Convert.nullCheck(mr.getParameter("bigfile"));
		if (bigFile.equals("T")) isBigChk = true;
		if(!browser.equals("")){
			isChk = getPostedFiles(mr, sendMailSize, isDms, dmsFiles);
		}else{
			isChk = getHtml5PostedFiles(htmlUploadPath, sendMailSize, isDms, dmsFiles);
		}
		
		sun.misc.BASE64Encoder encode = new sun.misc.BASE64Encoder();
		if (isChk || isBigChk) {
			Enumeration fileNames = mr.getFileNames();
			java.util.Date now = new java.util.Date();
			nowString = formatter.format(now);
			String saveDir = request.getRealPath("/") + File.separator + "down";
			checkSaveDir(saveDir);
			String uploadUrl = homePath + "mail/mail_attach_down.jsp?docid=" + encode.encode(nowString.getBytes()) + "&no=";
// 			String uploadUrl = "http://" + request.getServerName() + "/mail/mail_attach_down.jsp?docid=" + nowString	+ "&no=";
			String fileName;
			File attachFile;
			File saveFile;
			int fileCount = 1;
			HashMap datas = new HashMap();
			StringBuffer newFileLink = new StringBuffer();
			//다운로드 기간 설정
			Calendar cal = Calendar.getInstance();
			cal.add(Calendar.DATE, 20); //다운로드 기간 20일

			newFileLink
					.append("<BR><BR><hr size=1 width='600' noshade='noshade' color='blue' align='left'><style>")
					.append("#big_attach {width:100%;}")
					.append("#big_attach span{padding-left:8px; font-family:돋움; font-size:10pt;  width:100%;}")
					.append("#big_attach #b_file{margin-left:8px; color:#555555; height:20px; padding-left:10px; background-image:url('http://" + request.getServerName() + "/common/images/ico_bfile.gif'); background-repeat:no-repeat; clear:both;}")
					.append("#b_file a{color:#779ac1; font-weight:bold;}")
					.append("#big_attach #b_comment{border-top:1px solid #f8f8f8; color:#80abcd; padding-top:5px; }")
					.append("</style>");
			newFileLink
					.append("<div id='big_attach'>")
					.append("<span style='padding-top:7px; height:25px; background-color:#F8F8F8;'>")
					.append("<B>대용량 첨부파일</B> : 총 <font color='#FF1600'><B>"
							+ totCnt
							+ "</B></font> 개 ( <font color=blue>다운로드 기간</font> : "
							+ endFormat.format(cal.getTime()) + " 까지 )")
					.append("</span>")
					.append("<div style='line-height:5px;'>&nbsp;</div>");
			
			if(!browser.equals("")){ //IE이면 ActiveX
				while (fileNames.hasMoreElements()) {
					fileName = (String) fileNames.nextElement();
					if (mr.getFilesystemName(fileName) != null) {
						attachFile = mr.getFile(fileName);
						String fileRealName = mr
								.getFilesystemName(fileName); //실제 파일명
						//업로드이후 파일 링크 경로를 하기위함.
						String fileSaveName = nowString + "_" + fileCount; //저장 파일명
						if (fileCount != 1) {
							newFileLink.append("<BR>");
						}
						newFileLink.append("<span id='b_file'><a href='"
								+ uploadUrl + fileCount + "'>"
								+ fileRealName + "</a>");
						long fileSize = attachFile.length();
						saveFile = new File(saveDir + File.separator + fileSaveName);
						attachFile.renameTo(saveFile);
						datas = new HashMap();
						datas.put("docid", nowString);
						datas.put("fileno", fileCount);
						datas.put("fileName", fileRealName);
						datas.put("fileSaveName", fileSaveName);
						datas.put("fileSize", fileSize);
						repository.insertMailAttachToDB(con, datas);
						newFileLink.append(" (" + reportTraffic(fileSize)
								+ ") <B><a href='" + uploadUrl + fileCount
								+ "'>[내려받기]</a></B></span>");
						fileCount++;
					}
				}
			}else{	//HTML5 Upload
				File folderFile[] = null;
				fileDir = new File(htmlUploadPath);
				if (fileDir.exists()){
					folderFile = new File(htmlUploadPath).listFiles();
					
					int count = 0;
					for(int i=0;i<folderFile.length;i++){
						if(folderFile[i]==null){
							continue;
						}
						if (folderFile[i].isDirectory()) continue;
						String name = folderFile[i].getName();
						
						//업로드이후 파일 링크 경로를 하기위함.
						String fileSaveName = nowString + "_" + fileCount; //저장 파일명
						if (fileCount != 1) {
							newFileLink.append("<BR>");
						}
						newFileLink.append("<span id='b_file'><a href='"
								+ uploadUrl + fileCount + "'>"
								+ name + "</a>");
						long fileSize = folderFile[i].length();
						saveFile = new File(saveDir + File.separator + fileSaveName);
						folderFile[i].renameTo(saveFile);
						datas = new HashMap();
						datas.put("docid", nowString);
						datas.put("fileno", fileCount);
						datas.put("fileName", name);
						datas.put("fileSaveName", fileSaveName);
						datas.put("fileSize", fileSize);
						repository.insertMailAttachToDB(con, datas);
						newFileLink.append(" (" + reportTraffic(fileSize)
								+ ") <B><a href='" + uploadUrl + fileCount
								+ "'>[내려받기]</a></B></span>");
						fileCount++;
					}
				}
			}
			
			//문서관리 첨부파일 별도 처리
			if(!isDms.equals("")){
				for(int i=0;i<dmsFiles.length;i++){
					String tmp = dmsFiles[i];
					String[] dmsInfo = tmp.split("／");		//0: docid / 1: fileSaveFile / 2: fileName / 3 : fileSize
					
					attachFile = new File(dmsDir + dmsInfo[0]+ File.separator + dmsInfo[1]);		//문서관리 실제파일
					String fileRealName = dmsInfo[2];
					//업로드이후 파일 링크 경로를 하기위함.
					String fileSaveName = nowString + "_" + fileCount; //저장 파일명
					if (fileCount != 1) {
						newFileLink.append("<BR>");
					}
					newFileLink.append("<span id='b_file'><a href='"
							+ uploadUrl + fileCount + "'>"
							+ fileRealName + "</a>");
					long fileSize = Long.parseLong(dmsInfo[3]);
					saveFile = new File(saveDir + File.separator + fileSaveName);
					attachFile.renameTo(saveFile);
					datas = new HashMap();
					datas.put("docid", nowString);
					datas.put("fileno", fileCount);
					datas.put("fileName", fileRealName);
					datas.put("fileSaveName", fileSaveName);
					datas.put("fileSize", fileSize);
					repository.insertMailAttachToDB(con, datas);
					newFileLink.append(" (" + reportTraffic(fileSize)
							+ ") <B><a href='" + uploadUrl + fileCount
							+ "'>[내려받기]</a></B></span>");
					fileCount++;
				}
			}
			
			newFileLink
					.append("<div style='line-height:5px;'>&nbsp;</div>")
					.append("<span id='b_comment'>※ 대용량 첨부파일은 20일간 다운로드 가능하며, 이후 자동 삭제됩니다</span>")
					.append("</div>");

// 			if(!browser.equals("")){
// 				nowBody += encode.encode(newFileLink.toString().getBytes("UTF-8"));
// 			}else{
// 				nowBody += newFileLink.toString();
// 			}
			nowBody += newFileLink.toString();
		}
		//-------------------------------------------------------------------------
		//IE인 경우 Active 처리함.
// 		if(!browser.equals("")){
// 			int lastLine = 0;
// 			int cnt = 0;
// 			if(body.indexOf("Content-Type: multipart/related") != -1){
// 				int lineA = body.indexOf("Content-Type: text/html");
// 				String tmp = body;
// 				while(true){
					/*cnt = tmp.indexOf("--=_NamoWEC");*/
// 					cnt = tmp.indexOf("--TWE_MIME");
// 					lastLine += cnt;
// 					if(lineA < lastLine){
// 						break;
// 					}
// 					tmp = tmp.substring(cnt+3, tmp.length());
// 				}
// 				body = body.substring(0, lastLine-1) + nowBody + body.substring(lastLine, body.length());
// 			}else{
// 				body += nowBody;
// 			}
// 		}else{
// 			body += nowBody;
// 		}

		body += nowBody;

		//String bodySave = mr.getParameter("mailbodysave");

		//set subject
		msg.setSubject(mr.getParameter("subject"), "utf-8");
		
// 		System.out.println("["+logString+"]  MAIL - Subject:" + mr.getParameter("subject"));

		Multipart mp = new MimeMultipart();

		//Date
		//msg.setSentDate(new java.util.Date());

		//set mail body
		MimeBodyPart mbp = null;
// 		if(!browser.equals("")){	//태그프리 / 나모 처리
// 			InputStream is = new ByteArrayInputStream(body.getBytes());
// 			mbp = new MimeBodyPart(is);
// 			mp.addBodyPart(mbp);
// 		}else{
// 			mbp = new MimeBodyPart();
// 			mbp.setContent(body, "text/html; charset=utf-8");
// 			mp.addBodyPart(mbp);
// 		}
		mbp = new MimeBodyPart();
		mbp.setContent(body, "text/html; charset=utf-8");
		mp.addBodyPart(mbp);

		Enumeration names = null;

		//설정된 파일크기보다 적으면 일반 업로드 사용
		totSize = 0; //초기화
		if (!(isChk || isBigChk)) {
			if (mr.getParameter("isfiles") == null|| "".equals(mr.getParameter("isfiles"))) {	//HTML5 Upload 사용여부
				//add new attachments ------------------------------------------------------------
				names = mr.getFileNames(); // 폼의 이름 반환
				MimeBodyPart attachmentBodyPart = null;
				while (names.hasMoreElements()) {
					String name = (String) names.nextElement();
					String fsName = mr.getFilesystemName(name);
					if (fsName != null) {
						attachmentBodyPart = new MimeBodyPart();

						String path = tmpPath + File.separator + fsName;
						attachmentBodyPart.setFileName(MimeUtility.encodeWord(fsName, "utf-8", "B"));
						FileDataSource fds = new FileDataSource(path);
						attachmentBodyPart.setDataHandler(new DataHandler(fds));
						mp.addBodyPart(attachmentBodyPart);
						//new File(path).delete();
					}
				}
			} else {
				File folderFile[] = null;
				fileDir = new File(htmlUploadPath);
				if (fileDir.exists()){
					folderFile = new File(htmlUploadPath).listFiles();
					int count = 0;
					for(int i=0;i<folderFile.length;i++){
						if(folderFile[i]==null){
							continue;
						}
						if (folderFile[i].isDirectory()) continue;
						MimeBodyPart attachmentBodyPart = null;
						String name = folderFile[i].getName();
						attachmentBodyPart = new MimeBodyPart();

						String path = htmlUploadPath + File.separator + name;
						attachmentBodyPart.setFileName(MimeUtility.encodeWord(name, "utf-8", "B"));
						FileDataSource fds = new FileDataSource(path);
						attachmentBodyPart.setDataHandler(new DataHandler(fds));
						mp.addBodyPart(attachmentBodyPart);
						//new File(path).delete();
					}
				}
			}
			//문서관리 첨부파일 처리
			if(!isDms.equals("")){
				for(int i=0;i<dmsFiles.length;i++){
					String tmp = dmsFiles[i];
					String[] dmsInfo = tmp.split("／");		//0: docid / 1: fileSaveFile / 2: fileName / 3 : fileSize
					
// 					long fileSize = Long.parseLong(dmsInfo[3]);
					MimeBodyPart attachmentBodyPart = null;
					String name = dmsInfo[2];
					
					attachmentBodyPart = new MimeBodyPart();
					String path = dmsDir + dmsInfo[0]+ File.separator + dmsInfo[1];
					attachmentBodyPart.setFileName(MimeUtility.encodeWord(name, "utf-8", "B"));
					FileDataSource fds = new FileDataSource(path);
					attachmentBodyPart.setDataHandler(new DataHandler(fds));
					mp.addBodyPart(attachmentBodyPart);
				}
			}
		}
		
		//태그프리 본문 첨부파일  처리(CID)
		if(util.getDecodedFileList()!=null){
			Enumeration em = util.getDecodedFileList();	//첨부파일 파일리스트
			while(em.hasMoreElements()){
				String tgFileName = (String)em.nextElement();
				String[] tmpStr = tgFileName.split("[.]");
				if(tmpStr.length<2) continue;
				
				 // Create part for the image
			    MimeBodyPart imageBodyPart = new MimeBodyPart();

			    // Fetch the image and associate to part
			    DataSource fds = new FileDataSource(imsiPath + File.separator + tgFileName);
			    imageBodyPart.setDataHandler(new DataHandler(fds));

			    // Add a header to connect to the HTML
				String cid = tmpStr[0] + "@GARAMSYSTEM.CO.KR";
			    imageBodyPart.setDisposition(MimeBodyPart.INLINE);
			    imageBodyPart.setHeader("Content-ID", cid);
// 			    imageBodyPart.setDisposition("attachment; filename=" + tgFileName);
				imageBodyPart.setFileName(MimeUtility.encodeWord(tgFileName, "utf-8", "B"));
			    //imageBodyPart.setHeader("Content-ID","the-img-1");
			    
			    mp.addBodyPart(imageBodyPart);
			    
			    new File(imsiPath + tgFileName).delete();
			}
		}
	
		//다음 editor Image 처리
		if(browser.equals("")){
			File folderFile[] = null;
			ImgFileDir = new File(htmlImgUploadPath);
			if (ImgFileDir.exists()){
				int count = 0;
				String cidStr = formatter.format(new java.util.Date());
					
			    //본문 이미지 SRC 변경
			    Document doc = Jsoup.parse(body);
				Elements imgs = doc.select("IMG");
				int i=1;
				for(Element e: imgs) {
					String src = e.attr("src");
					int srcIndex = src.indexOf("imageupload?getfile=");
					if(srcIndex > -1){
						String imageName = src.substring(srcIndex + 20);
						String cid = "";
					    if(imageName.indexOf(".")>-1){
							cid = imageName.substring(0, imageName.indexOf("."));
						}
					    cid = cid+ i + "@GARAMSYSTEM.CO.KR";
						e.attr("src", "cid:" + cid);
						
						MimeBodyPart imageBodyPart = new MimeBodyPart();
						DataSource fds = new FileDataSource(htmlImgUploadPath + File.separator + imageName);
						imageBodyPart.setDataHandler(new DataHandler(fds));
					    imageBodyPart.setDisposition(MimeBodyPart.INLINE);
					    imageBodyPart.setHeader("Content-ID", cid);
// 					    imageBodyPart.setDisposition("attachment; filename=" + imageName);
					    imageBodyPart.setFileName(MimeUtility.encodeWord(imageName, "utf-8", "B"));
					    mp.addBodyPart(imageBodyPart);
					    i++;
					}
				}
				body = doc.html();
			    //new File(htmlImgUploadPath + File.separator + name).delete();
			}
		}
		
		mbp.setContent(body, "text/html; charset=utf-8");
// 		mp.addBodyPart(mbp);

		msg.setContent(mp);
		//body & attachments ends ----------------------------------------------

		
		//메일주소 저장 mail_recipients
		String receive_to_datas = mr.getParameter("receive_to_datas");
		String receive_cc_datas = mr.getParameter("receive_cc_datas");
		String receive_bcc_datas = mr.getParameter("receive_bcc_datas");
		
		JSONArray ja = new JSONArray();
		if (StringUtils.isNotBlank(receive_to_datas)) ja = new JSONArray(receive_to_datas);
		StringBuffer receiveDisplayTo = new StringBuffer();
		for(int i = 0, len = ja.length(); i < len; i++) {
			JSONObject jo = ja.getJSONObject(i);
			if (i != 0) receiveDisplayTo.append(", ");
			if (jo.has("personal") && StringUtils.isNotEmpty(jo.getString("personal"))) {
				receiveDisplayTo.append(jo.getString("personal"));
			} else {
				receiveDisplayTo.append(jo.getString("address"));
			}
		}
		
		MailEnvelope envelope = new MailEnvelope(msg);
		envelope.setImportance(importance);
		envelope.setSaveAfterSent(saveAfterSent);
		envelope.setCheckReceipt(checkReceipt);
// 		envelope.setCheckReceipt(true);	//하나로 수신확인 무조건 확인 수정 (수신확인 기본값  true)
		if (receive_to_datas != null) envelope.setReceiveDisplayTo(receiveDisplayTo.toString());

		MailEnvelope oldEnvelope = null;
		//MailRepository repository = new MailRepository(application.getInitParameter("nek.mail.inbox"));

		
		if (!cmd.startsWith("reply")) {
			if (messageName != null && messageName.length() > 0) {
				oldEnvelope = repository.retrieve(con, loginuser.emailId, messageName, domainName);
				if (oldEnvelope != null) {
					Collection attachments = oldEnvelope.getAttachments();
					if (attachments != null) {
						Iterator iter = attachments.iterator();
						imsiFiles = new ArrayList<String>();
						while (iter.hasNext()) {
							Attachment attachment = (Attachment) iter.next();
							String cid = attachment.getContentID();
							//일부 확장자는 표시되도록 함(예외인경우)
							String fileExt = "";
							String fileName = attachment.getFileName();
							if(fileName.lastIndexOf(".")>-1){
								fileExt = fileName.substring(fileName.lastIndexOf(".")+1, fileName.length());
							}
							if (cid != null){
								//2013-02-08 가람시스템 본문 이미지만 제외함.
// 								if(cid.indexOf("GARAMSYSTEM")>-1){
									String[] passList = new String[]{"docx","doc","pptx","ppt","xlsx","xls","pdf","hwp"};
									boolean isCheck = false;
									for(String item : passList) {
										if (item.equals(fileExt)) {
											isCheck = true;
										}
									}
									if(!isCheck) continue;
// 								}
							}
							
							if (drops == null || !drops.contains(attachment.getPath())) {
								MimeBodyPart attachmentBodyPart = new MimeBodyPart();
								DataHandler dh = attachment.getPart().getDataHandler();
								String path = tmpPath + File.separator + attachment.getFileName();
								
						        FileOutputStream fos = new FileOutputStream(path); 
								try{
						        	dh.writeTo(fos);
						        }catch(Exception e){}
						        fos.close();
						        File f = new File(path);
						        
						        if(f.isFile()){
						        	imsiFiles.add(attachment.getFileName());	//마지막에 임시파일 삭제하기 위함.
						        	
						        	attachmentBodyPart.setFileName(MimeUtility.encodeWord(attachment.getFileName(), "utf-8", "B"));
									FileDataSource fds = new FileDataSource(path);
									attachmentBodyPart.setDataHandler(new DataHandler(fds));
									mp.addBodyPart(attachmentBodyPart);
						        }
							}
						}
					}
				}
			}
		}

		//신규작성이 아닌 회신시 다음에디터
		if (messageName != null && messageName.length() > 0) {
			oldEnvelope = repository.retrieve(con, loginuser.emailId, messageName, domainName);
			if (oldEnvelope != null) {
				Collection attachments = oldEnvelope.getAttachments();
				if (attachments != null) {
					Iterator iter = attachments.iterator();
					//이미지 첨부파일 중복제거
					List<Attachment> attrList = new ArrayList<Attachment>();
					List<String> tmpList = new ArrayList<String>();
					while (iter.hasNext()) {
						Attachment attachment = (Attachment) iter.next();
						if(!tmpList.contains(attachment.getPath())){
							attrList.add(attachment);
							tmpList.add(attachment.getPath());
						}
					}
					int num = 0;
					for (Attachment attachment : attrList) {
					//while (iter.hasNext()) {
						//Attachment attachment = (Attachment) iter.next();
						
						String cid = attachment.getContentID();
						if (cid != null) {	//이미지 파일
							if(imgHidList != null){
								for(String hisTemp : imgHidList){
									String[] tmp = hisTemp.split("／");
									String origPath = tmp[0].substring(tmp[0].indexOf("path=")+5);
									String origFileName = tmp[1];
									BodyPart bdPart = (BodyPart)attachment.getPart();
								
									if(!origPath.equals(attachment.getPath())) continue;
									if (drops == null || !drops.contains(attachment.getPath())) {
										cid = "";
									    if(origFileName.indexOf(".")>-1){
											cid = origFileName.substring(0, origFileName.indexOf("."));
										}
									    java.util.Date now = new java.util.Date();
									    cid = formatter.format(now);
										cid = cid + String.valueOf(num) + "@GARAMSYSTEM.CO.KR";
										bdPart.setDisposition(MimeBodyPart.INLINE);
										bdPart.setHeader("Content-ID", cid);
//	 									bdPart.setDisposition("attachment; filename=" + origFileName);
										bdPart.setFileName(MimeUtility.encodeWord(origFileName, "utf-8", "B"));
									    mp.addBodyPart(bdPart);
									    
									  //본문 이미지 SRC 변경
									    Document doc = Jsoup.parse(body);
										Elements imgs = doc.select("img[src=/mail/mail_dn_attachment.jsp?message_name="+messageName+"&path=" + origPath+ "]");
										for(Element e: imgs) {
											String src = e.attr("src");
											e.attr("src", "cid:" + cid);
// 											int srcIndex = src.indexOf("mail_dn_attachment.jsp?message_name="+messageName+"&path=" + origPath);
// 											System.out.println(src + " : " + srcIndex);
// 											if (srcIndex > -1) {
// 												e.attr("src", "cid:" + cid);
// 											}
										}
										body = doc.html();
										num++;
									}
								}
							}
						}
					}
					mbp.setContent(body, "text/html; charset=utf-8");
				}
			}
		}

		msg.saveChanges();

		envelope.setReserved(reserved);

		redirectMailbox = Mailbox.OUTBOX;

		//메일주소 자동완성 저장
// 		repository.setAutoCompleteMail(con, loginuser.uid,autoEmailList);
		
		
		if (isDraft) {
			//임시저장인 경우
			envelope.setRead(true);
			if (oldEnvelope != null && oldEnvelope.getMailboxID() == Mailbox.DRAFT) {
				//임시저장한 파일을 편집하여 다시 임시저장한 경우
				envelope.setMailboxID(Mailbox.DRAFT);
				envelope.setMessageName(oldEnvelope.getMessageName());
				
// 				System.out.println("["+logString+"]  MAIL - message_name: " + envelope.getMessageName());
// 				System.out.println("["+logString+"]  MAIL - nek_msgid: " + oldEnvelope.getNek_msgid());
				
				repository.update(con, loginuser.emailId, envelope, domainName);
				if (receive_to_datas != null) {
					if (StringUtils.isNotBlank(oldEnvelope.getNek_msgid())) repository.setRecipientsMail(con, oldEnvelope.getNek_msgid(), loginuser.uid, receive_to_datas, receive_cc_datas, receive_bcc_datas);
				}
			} else {
				//새 임시저장				
				envelope.setMessageName("Mail" + loginuser.uid + System.currentTimeMillis());
				
// 				System.out.println("["+logString+"]  MAIL - message_name: " + envelope.getMessageName());
// 				System.out.println("["+logString+"]  MAIL - nek_msgid: " + nekMsgID);
				
				repository.store(con, loginuser.emailId, Mailbox.DRAFT, envelope, nekMsgID, domainName);
				if (receive_to_datas != null) {
					if (StringUtils.isNotBlank(nekMsgID)) repository.setRecipientsMail(con, nekMsgID, loginuser.uid, receive_to_datas, receive_cc_datas, receive_bcc_datas);
				}
			}
			redirectMailbox = Mailbox.DRAFT;
		} else {
			//발송인 경우
			envelope.setMessageName(newMessageName);
			
// 			System.out.println("["+logString+"]  MAIL - message_name: " + newMessageName);

			boolean failed = false;
			//int size = msg.getSize();
			//if (size != -1 && size <= uservariable.sendMailSize) {
			//	if (size == -1)
			//	try {
			//		Transport.send(msg);
			//	} catch (Exception ex) {
			//		failed = true;
			//	}
			//} else {
			//일단 Mailbox.PENDING에 임시 저장

			repository.store(con, loginuser.emailId, Mailbox.PENDING, envelope, nekMsgID, domainName);
			if (receive_to_datas != null) {
				if (StringUtils.isNotBlank(nekMsgID)) repository.setRecipientsMail(con, nekMsgID, loginuser.uid, receive_to_datas, receive_cc_datas, receive_bcc_datas);
				repository.setReceiveMember(con, envelope.getMessageName(), domainName, loginuser.uid, reTO, reCC, reBCC);
			}

			long size = repository.getMessageSize(loginuser.emailId, newMessageName, domainName);
			///if (size > uservariable.sendMailSize) { 최대 메일크기가 40MB이면 MIME변환시 더 커진다.
			if (size > 60000000) {
				failed = true;
			} else {
				if (checkReceipt) {
					int index = mbp.getContent().toString().lastIndexOf("</body>");
					if (index == -1) {
						index = mbp.getContent().toString().lastIndexOf("</BODY>");
					}

					if (index != -1) {
						/*
						StringBuffer newBody = new StringBuffer()
							.append(mbp.getContent().toString().substring(0, index))
							.append("<img style='display:hidden' width='0' height='0' src='")
							.append(homePath)
							.append("mail/mail_chkreceipt.jsp?message_name=")
							.append(newMessageName)
							.append("&recipient=$_RCPT_$'></body></html>");

						mbp.setContent(newBody.toString(), "text/html; charset=utf-8");
						msg.saveChanges();
						 */
					}
				}

				if (reserved == null) {
					try {
						Transport.send(msg);
// 						System.out.println("["+logString+"]  MAIL SEND Success");
					} catch (Exception ex) {
						System.out.println("["+logString+"]  MAIL SEND FAIL - " + ex);
						failed = true;
					}
				}

				if (failed) {
					repository.move(con, loginuser.emailId, newMessageName, Mailbox.DRAFT, domainName);
				} else {
					if(isReply == true){
						repository.setReply(con, reply_userName, reply_messageName, reply_domainName);
					}
					if (reserved == null) {
						if (saveAfterSent) {
							repository.move(con, loginuser.emailId, newMessageName, Mailbox.OUTBOX, domainName);
							//메일 아카이빙 - 스타리온 저널링 설정인경우 적용
							if(repository.getUserMailArchive(con, loginuser.emailId)){
								repository.storeArchive(con, loginuser.emailId, Mailbox.OUTBOX, envelope, nekMsgID, domainName);
							}
						} else {
							repository.delete(con, loginuser.emailId, newMessageName, domainName);
						}
					} else {
						redirectMailbox = Mailbox.RESERVED;
						repository.move(con, loginuser.emailId, newMessageName, Mailbox.RESERVED, domainName);
					}

					if (oldEnvelope != null&& oldEnvelope.getMailboxID() == Mailbox.DRAFT) {
						//만약 임시저장한 파일을 편집하여 발송한 경우는 원본 임시저장파일을 삭제한다.
						repository.delete(con, loginuser.emailId, oldEnvelope.getMessageName(), domainName);
					}
				}
			}
		}

		//delete temp files  ------------------------------------------------------------
		names = mr.getFileNames(); // 폼의 이름 반환
		while (names.hasMoreElements()) {
			String name = (String) names.nextElement();
			String fsName = mr.getFilesystemName(name);
			if (fsName != null) {
				String path = tmpPath + File.separator + fsName;
				new File(path).delete();
			}
		}
		
		if(imsiFiles != null){
			for(String tmp : imsiFiles){
				String path = tmpPath + File.separator + tmp;
				new File(path).delete();
			}
		}
		
		deleteFolder(fileDir);
		deleteFolder(ImgFileDir);
		File imgFiles = new File(imsiPath);
		if(imgFiles.isDirectory()){
			deleteFolder(new File(imsiPath));
		}

		//response.sendRedirect("mail_list.jsp?box=" + redirectMailbox);
	} finally {
		if (db != null && con != null) {
			db.freeDbConnection();
		}
	}
	
	String userAgent = request.getHeader("user-agent").toUpperCase();
	boolean mobile1 = userAgent.matches(".*(IPHONE|IPOD|ANDROID|WINDOWS CE|BLACKBERRY|SYMBIAN|WINDOWS PHONE|WEBOS|OPERA MINI|OPERA MOBI|POLARIS|IEMOBILE|LGTELECOM|NOKIA|SONYERICSSON).*");
	boolean mobile2 = userAgent.matches(".*(LG|SAMSUNG).*");
	
	if (mobile1 || mobile2) {
		response.sendRedirect("/mobile/mail/list.jsp?box=2");
	} else { 
%>
<script src="/common/scripts/parent_reload.js"></script>
<script>
// var browserCheckText = new Array('iPhone', 'iPod', 'BlackBerry', 'Android', 'Windows CE', 'LG', 'MOT', 'SAMSUNG', 'SonyEricsson');
// var navigatorUserAgent = navigator.userAgent.toUpperCase();
// for(var word in browserCheckText){
// 	if (navigatorUserAgent.match(browserCheckText[word].toUpperCase()) != null){
// 		location.href = "/mobile/mail/list.jsp?box=2";
// 		break;
// 	}
// }

// var deviceAgent = navigator.userAgent.toLowerCase();
// if (deviceAgent.match(/(iphone|ipod|android|blackberry|samsung|lg|sonyericsson)/)) { //ipad|
// 	location.href = "/mobile/mail/list.jsp?box=2";
// } else {
	var redirectMailbox = "<%=redirectMailbox%>";
	var url = "/mail/mail_list.jsp?box=" + redirectMailbox;
	
	try {
		if (window.opener) {
// 			opener.top.showMailMenu(); 2014-08-14 메일개선 작업(left.jsp호출 최소화)
// 		 	parentReload(url);
// 			opener.$("#dataGrid").trigger("reloadGrid");
		} else {
// 			top.showMailMenu();
// 		 	parentReload(url);
// 			parent.$("#dataGrid").trigger("reloadGrid");
		}
	} catch(e) {}
	
	try {
		closeWindow();
	} catch(e) {
		window.open('', '_self', '').close();
	}
// }
</script>
<%	} %>