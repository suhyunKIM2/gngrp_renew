<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="t"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<t:insertAttribute name="head"/>
<body>
<div id="bg">
  <div id="warp"> 
<t:insertAttribute name="header" />
<t:insertAttribute name="content" />
<t:insertAttribute name="footer" />
 </div>
</div>
</body>
</html>