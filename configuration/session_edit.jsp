<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page isThreadSafe="false" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.configuration.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="nek.common.NoAdminAuthorityException" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="java.io.File" %>
<%@ page import="org.jdom.Document"%>
<%@ page import="org.jdom.Element"%>
<%@ page import="org.jdom.Attribute"%>
<%@ page import="org.jdom.input.SAXBuilder"%>
<%@ page import="org.jdom.output.XMLOutputter"%>
<%@ page import="org.jdom.output.Format"%>

<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!
	//Session Time 변경
	public void setSessionTime(String sessionValue, String tomcatXmlSource){
		try{
			SAXBuilder builder = new SAXBuilder();
			tomcatXmlSource += "web.xml";
			Document doc = builder.build(tomcatXmlSource);
			
			Element root = doc.getRootElement();
			System.out.println(doc.getRootElement());
			root = root.getChild("session-config");
			
			List children = root.getChildren();
			Iterator iterator = children.iterator();
			while(iterator.hasNext()) {
				Element child = (Element)iterator.next();
				root.removeContent(child);
				break;
			}
			Element appchild= new Element("session-timeout");
			appchild.setText(sessionValue);
			root.addContent(appchild);
			
			marshalling(doc, tomcatXmlSource);
			
		}catch(Exception ex){
			System.out.println("environment setSessionTime(): " + ex.getMessage());
		}
	}
	//xml 파일을 저장
	private static void marshalling(Document doc, String xmlSoruce)
	throws FileNotFoundException, IOException {
		FileOutputStream fout =
			new FileOutputStream(xmlSoruce);
		
		XMLOutputter fmt = new XMLOutputter(Format.getPrettyFormat());
		fmt.output(doc, fout);
		
		fout.close();
	}
%>
<%
	String saveDir = "";
	saveDir = application.getRealPath("/");
	saveDir = saveDir + "userdata" + File.separator;

	MultipartRequest multi = new MultipartRequest(request, saveDir, 1024*1024, "utf-8");

	String cfNames[];
	String cfValues[];

	cfNames		= multi.getParameterValues("cfname");
	cfValues		= multi.getParameterValues("cfvalue");

	ConfigEnv cfEnv = null;
	ArrayList cfList = null;
	try
	{
		cfEnv = new ConfigEnv(loginuser);

		cfList = new ArrayList();
		for (int i=0; i<cfNames.length;i++)
		{
			ConfigItem cfItem = new ConfigItem();
			cfItem.cfName = cfNames[i];
			if(cfItem.cfName.equals(application.getInitParameter("CONF.SESSIONTIME"))){
				setSessionTime(cfValues[i], application.getInitParameter("tomcat"));
				cfItem.cfValue = cfValues[i];
				cfList.add(cfItem);
			}
			
		}
		cfEnv.getDBConnection();
		cfEnv.setConfigs(cfList);
		response.sendRedirect("./environment.jsp");

	}
	catch(NoAdminAuthorityException ex)
	{
		out.write("<script language='javascript'>alert('관리권한이 없습니다');history.back();</script>");
		//out.close();
		return;
	}
	finally
	{
		cfEnv.freeDBConnection();
	}


%>
