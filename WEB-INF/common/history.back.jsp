<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>
</head>
<body>
<script type="text/javascript">
<c:if test="${message != null || message != ''}" >
var msg = "${message}";
msg = msg.replace("\\n", "\n");
alert(msg);
//alert("${message}");
</c:if>
history.back(-2);
</script>
</body>
</html>