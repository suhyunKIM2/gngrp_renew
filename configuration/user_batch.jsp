<%@page import="java.util.regex.Pattern"%>
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.io.*"%> 
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="nek.common.*"%>
<%@ page import="nek.configuration.*"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<% 	request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!

ArrayList<String> arrList = new ArrayList<String>();
boolean isChk = false;

//디렉토리의 존재여부를 체크
private void checkSaveDir(String saveDir)
{
  File dir = new File(saveDir);
  if (!dir.exists()) dir.mkdirs();
}

private String getTime(){	
	SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmssSS");
	java.util.Date today = new java.util.Date();
	String docid = format.format(today);
	return docid;
}

private String getCheck(String docid){
	docid = getTime();
	for(String str : arrList){
		if(str.equals(docid)){
			docid = getCheck(docid);
		}
	}
	return docid;
}

private String getDocNumber(){
	SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmssSS");
	String docid = format.format(new java.util.Date());
	
	for(String str : arrList){
		if(str.equals(docid)){
			docid = getCheck(docid);
			isChk = true;
		}
	}
	
	if(isChk){
		for(String str : arrList){
			if(str.equals(docid)){
				docid = getCheck(docid);
			}
		}
	}
	
	//System.out.println(oldDocid + " " + docid);
	
	arrList.add(docid);
	
	return docid.substring(0,14);
}

private String getBirth(String birth){
	String reVal = "";
	birth = getNumber(birth);
	if(birth.length()==8){
		reVal = birth.substring(0,4) + "-";
		reVal += birth.substring(4,6) + "-";
		reVal += birth.substring(6,8);
	}else{
		return null;
	}
	return reVal;
}

private String getNumber(String str){
	if ( str == null ) return "";
	  
	StringBuffer sb = new StringBuffer();
	for(int i = 0; i < str.length(); i++){
		if( Character.isDigit( str.charAt(i) ) ) {
			sb.append( str.charAt(i) );
		}
	}
	return sb.toString();
}

%>
<% 

MultipartRequest multi =  null ; 
String saveDir = application.getRealPath("/");
saveDir = saveDir + "addressbook" + File.separator + "temp" + File.separator;
String cmd = "";
FileReader testRead;
int tempChar;
StringBuffer sbuf = new StringBuffer();
boolean chkVal= false;
int count = 0;
checkSaveDir(saveDir);
UserItem userItem = new UserItem();
UserWrite userWrite = null;
String sLocale ="ko";
try{
	multi = new MultipartRequest(request, saveDir, 1024*1024*1024, "utf-8");
	cmd = multi.getParameter("cmd");
	if(cmd == null) cmd ="";
	
	if(cmd.equals("insert")){
		// csv 파일 읽어들이기
		Enumeration fileNames = multi.getFileNames();
		String fileName ;
		File attachFile;
		if(fileNames.hasMoreElements())
		{
			fileName = (String)fileNames.nextElement();
			if(multi.getFilesystemName(fileName) != null){
				attachFile	= multi.getFile(fileName);
				testRead = new FileReader (attachFile);
				//StringBuffer sbuf 에 저장
				do {
				tempChar = testRead.read();
				if (tempChar == -1) break;
				sbuf.append((char)tempChar);
				} while(true);
				testRead.close();
				attachFile.delete();
			}
		}
		
		String tmp = "";
		//StringBuffer 를 한줄씩 끊어 읽고 ',' 구분해서 순차적으로 메일보내기
		StringTokenizer sto = new StringTokenizer(sbuf.toString(),"\n");
		int cnt = 1; //갯수 체크
		long sNewId = Long.parseLong(getDocNumber());
		while(sto.hasMoreElements()) {
			tmp = sto.nextElement().toString();
			String[] str = tmp.split(",");
// 			if(str.length>10||str.length<9){
// 				out.print("<script language='javascript'>alert('CSV파일 형식이 틀립니다.');history.back();</script>");
// 				//out.close();
// 				return;
// 			}
			if(count ==0){	//첫번째 행이 구분자 일때 패스
				count++;
				continue;
			}
			
			/**
			* 사용자 순차별 정보
			0. 이름
			1. 사번
			2. 생년월일
			3. 부서코드
			4. 부서명
			5. 직위
			6. 메일계정
			7. 로그인ID
			8. 패스워드
			9. 결재패스워드
			*/
// 			Thread.sleep(100);
			try{
				userWrite = new UserWrite(loginuser);
				userWrite.getDBConnection();
				userItem.uid			= String.valueOf(sNewId++);
				userItem.mainUserId= userItem.uid;
				userItem.nName		= str[0];
				userItem.eName		= str[1];
				userItem.sabun		= str[2];
				userItem.loginId		= str[15];
				System.out.println("------------------------------------------------------");
				userItem.pwdHash	= CommonTool.getSHAHashedString(str[16].trim());
				userItem.udId		= "NN";
				userItem.upId		= userWrite.getUserUpCode(str[4]);
				userItem.dpId		= str[7];
				userItem.addJob		= "";
				userItem.mainJob	= "";
				userItem.telNo		= str[13];
				userItem.faxNo		= "";
				userItem.homeTel	= "";
				userItem.cellTel	= str[14];
				userItem.zipCode	= str[11];
				userItem.address	= str[12];
				userItem.address2	= "";
				userItem.email		= "";
				userItem.sex		= 0;
				userItem.birthDay	= getBirth(str[3]);
				userItem.userName	= str[15];
				userItem.securityId	= 1;
				userItem.internetMail	= "";
				userItem.domainName = "ekp.htns.com";
				sLocale = "ko";
				if(sLocale.equals("ko")){
					userItem.psType = 1;
				}else{
					userItem.psType = 0;
				}
								
				System.out.println(cnt+" "+userItem.uid+" "+str[0]+" "+str[1]+" "+userItem.birthDay+" "+userItem.dpId+" "+str[4]+" "+userItem.userName+ " "+str[6]+" "+str[7] + " : " + sLocale);
				
				int returnValue = 0;
// 				String userId = userWrite.getIsSabunExist(userItem.sabun);
// 				if(!userId.equals("")){	//해당 사용자의 사번이 존재하면 수정 아니면  신규등록
// 					returnValue = userWrite.updateBatchUserItemOnDB(userItem);
// 					userItem.uid = userId;
// 				}else{
// 					returnValue = userWrite.insertBatchUserItemToDB(userItem);
// 				}
				returnValue = userWrite.insertBatchUserItemToDB(userItem);
				System.out.println(" returnValue : " + returnValue);
				if(returnValue == UserReturnType.INSERT_OK || returnValue == UserReturnType.UPDATE_OK)
				{
					long longValue = 0;
					ConfigItem cfItem = new ConfigItem();
					cfItem.cfName	= "MAILDOMAIN";
					cfItem.cfValue	= userItem.domainName;
					cfItem.cfType	= "STRING";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					
					cfItem.cfName	= application.getInitParameter("CONF.LIST_P_PAGE");
					cfItem.cfValue	= "10";
					cfItem.cfType	= "INT";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					cfItem.cfName	= application.getInitParameter("CONF.BLOCK_P_PAGE");
					cfItem.cfValue	= "10";
					cfItem.cfType	= "INT";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					cfItem.cfName	= application.getInitParameter("CONF.MAIL_BOX_SIZE");
					longValue		= (Long.parseLong("1000")) * (1024*1024);
					cfItem.cfValue	= Long.toString(longValue);
					cfItem.cfType	= "LONG";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					cfItem.cfName	= application.getInitParameter("CONF.SEND_MAIL_SIZE");
					longValue		= (Long.parseLong("10")) * (1024*1024);
					cfItem.cfValue	= Long.toString(longValue);
					cfItem.cfType	= "LONG";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					
					cfItem.cfName	= "ISMULTILOGIN";
					String multiLogin = "true";
					if (multiLogin == null || "".equals(multiLogin)) multiLogin = "0";
					cfItem.cfValue	= multiLogin;
					cfItem.cfType	= "BOOLEAN";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					
					cfItem.cfName	= "LOCALE";
					cfItem.cfValue	= sLocale;
					cfItem.cfType	= "STRING";
					userWrite.setUserConfigValue(userItem.uid, cfItem);
					
				}
				cnt++;
			}catch(Exception ex){
				System.out.println(ex);
			}finally{
				userWrite.freeDBConnection();
			}
		}
		
		out.print("<script language='javascript'>alert('"+(cnt-1)+"명의 사용자 등록에 성공 하였습니다.');location.href='./user_batch_form.jsp';</script>");
	}
}catch(Exception ex){
	System.out.println(ex);
}finally{
}

%>

