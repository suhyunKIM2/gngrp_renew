<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.approval.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>

<%
    String sUid = loginuser.uid ;  //
    String cmd = ApprUtil.setnullvalue(request.getParameter("cmd"), ApprDocCode.APPR_NEW) ; //신규-> null, 수정 -> edit,    

    AppBujaeInfo appbujaeInfo = null ;
    ApprBuJae bujaeObj = null ; 
    String schbujae = "" ; 
    String sCheckSelect = "" ; 
    String sDaeNo = "" ; 
    try
    {

        if(cmd.equals(ApprDocCode.APPR_EDIT))
        {
            appbujaeInfo = new AppBujaeInfo() ;

            sCheckSelect = ApprUtil.nullCheck(request.getParameter("selectcheck")) ;
            schbujae = ApprUtil.setnullvalue(request.getParameter("chbujae"), ApprDocCode.APPR_SETTING_F) ;

            appbujaeInfo.setCheck( schbujae) ; //값이 있으면 T, 없으면 F
            appbujaeInfo.setBuJaeUID(ApprUtil.nullCheck(request.getParameter("uid"))) ;
            appbujaeInfo.setUID(sUid) ;
            appbujaeInfo.setReason(ApprUtil.nullCheck(request.getParameter("reason"))) ;
            appbujaeInfo.setDaeID(ApprUtil.nullCheck(request.getParameter("apprdaeno"))) ; //부재자 NO
//Debug.println(sCheckSelect+"    "+appbujaeInfo.getCheck() +"   "+request.getParameter("apprdaeno")+"  "+request.getParameter("uid")) ; 

            bujaeObj = new ApprBuJae() ;
            sDaeNo = bujaeObj.ApprBujaeSetting( sCheckSelect, appbujaeInfo ) ; 
        }        

    }catch(Exception e){
        Debug.println (e) ;
    } finally {        
        bujaeObj.freeConnecDB() ; 

        appbujaeInfo = null ; 
        bujaeObj = null ; 
    }
%>
<SCRIPT LANGUAGE="JavaScript">
<!--
<%
    if (schbujae.equals(ApprDocCode.APPR_SETTING_F)) {  //부재 해제
%>
//         parent.main.gohaeje() ; 
        alert("<%=msglang.getString("t.was.released") /* 해제되었습니다. */ %>");
        document.location.href = "appr_bujaeja.jsp";
<%

    } else if (sDaeNo.equals("")){ //부재자로 설정하신 임직원이 부재자로 등록되어 있는 경우
%>
//         parent.main.gohaeje() ; 
        alert("<%=msglang.getString("appr.reg.absentee") /* 부재자로 설정하신 임직원이 부재자로 등록되어있습니다. */ %>\n\n"
        	+ "<%=msglang.getString("t.select.other.employees") /* 다른 임직원을 선택 하십시오. */ %>");
        document.location.href = "appr_bujaeja.jsp";
<%
    } else { //부재 설정 
       //설정되지 않은 상태에서 저장 후 해제를 하면 apprdaeno, selectcheck의 값이 없어 해제가 안된다 이를 방지 하기 위해 설정
%>
<%--         parent.main.mainForm.selectcheck.value = "<%= ApprDocCode.APPR_SETTING_SEL %>" ; --%>
<%--         parent.main.mainForm.apprdaeno.value = "<%= sDaeNo %>" ; --%>
        alert("<%=msglang.getString("t.save.ok") /* 저장되었습니다. */ %>");
        document.location.href = "appr_bujaeja.jsp";
<%
    }
%>
//-->
</SCRIPT>
