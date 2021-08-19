<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %> --%>

<!-- Load jqGrid jQuery Plugin -->
<link rel="stylesheet" href="/common/jquery/plugins/ui.jqgrid.css">
<script src="/common/jquery/js/i18n/grid.locale-<c:out value="${sessionScope.userConfig.locale }" />.js"></script>
<script src="/common/jquery/plugins/jquery.jqGrid.min.js"></script>

<!-- Load Multiselect jQuery UI -->
<link rel="stylesheet" href="/common/jquery/plugins/ui.multiselect.css">
<script src="/common/jquery/plugins/ui.multiselect.js"></script>

<script>$.jgrid.no_legacy_api = true; $.jgrid.useJSON = true;</script>

<style type="text/css"> 
	#search_dataGrid .ui-pg-div { display: none; }					/* jqgrid search hidden */
	#dataGridPager { height: 30px; }								/* jqgrid pager height */
	.ui-jqgrid .ui-pg-selbox { height: 23px; line-height: 23px; min-width: 30px; }	/* jqgrid pager select height */
	.ui-widget-content { border:none; }
</style>
