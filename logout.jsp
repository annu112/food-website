<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
session.invalidate();
response.sendRedirect("login.jsp?msg=" + java.net.URLEncoder.encode("You have been logged out successfully.", "UTF-8"));
%>
