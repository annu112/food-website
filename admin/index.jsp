<%@ page import="java.util.*" %>
<%
Map<String, Object> adminUser = (Map<String, Object>) session.getAttribute("adminUser");
if (adminUser != null && "ADMIN".equalsIgnoreCase((String) adminUser.get("role"))) {
    response.sendRedirect("dashbord.jsp");
} else {
    response.sendRedirect("login.jsp");
}
%>