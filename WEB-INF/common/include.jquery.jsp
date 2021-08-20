<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- Load jQuery -->
<script src="/common/jquery/js/jquery-1.6.4.min.js"></script>

<!-- Load jQuery UI -->
<link rel="stylesheet" href="/common/jquery/ui/1.8.16/themes/redmond/jquery-ui.css" />
<link rel="stylesheet" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" />
<script src="/common/jquery/ui/1.8.16/jquery-ui.min.js"></script>

<c:set var="locale" value="${sessionScope.userConfig.locale }" />
<c:if test="${locale eq null }"><c:set var="locale" value="ko" /></c:if>
<script src="/common/jquery/ui/1.8.16/i18n/jquery.ui.datepicker-${locale }.js"></script>

<!-- Load qTip2 jQuery Plugin -->
<link rel="stylesheet" href="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.css">
<script src="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.js"></script>

<!-- Load BlockUI jQuery Plugin -->
<script src="/common/jquery/plugins/BlockUI/jquery.blockUI.js"></script>

<!-- Load ModalDialog jQuery UI : Remove -->
<script src="/common/jquery/plugins/modaldialogs.js"></script>

<!-- DHTML Window Widget -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- DHTML Modal window  -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>
