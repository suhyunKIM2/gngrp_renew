<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script language="javascript" type="text/javascript">
$(function() {
	//$("#dialog:ui-dialog" ).dialog("destroy");
	$("#viewDialog:ui-dialog").dialog("destroy");
	$("#viewDialog").dialog({
		//autoOpen:false,
		autoOpen:true,
		modal:true,
		width:600,
		height:400
	});
});
</script>
<div id="tttttt">
${viewData.code}<br />
${viewData.name}<br />
${viewData.gender}<br />
<a href="http://garamsystem">go garam</a>
</div>