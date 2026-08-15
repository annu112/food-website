<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String cartJson = request.getParameter("cart_json");

    if (cartJson == null || cartJson.trim().isEmpty()) {
        try {
            StringBuilder sb = new StringBuilder();
            java.io.BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String body = sb.toString().trim();
            if (body.startsWith("cart_json=")) {
                cartJson = java.net.URLDecoder.decode(body.substring(10), "UTF-8");
            } else if (body.startsWith("[") && body.endsWith("]")) {
                cartJson = body;
            }
        } catch(Exception e) {}
    }

    if (cartJson != null && !cartJson.trim().isEmpty() && !cartJson.trim().equals("null")) {
        session.setAttribute("cart_json", cartJson.trim());
        out.print("{\"status\":\"success\",\"message\":\"Cart synced to session\",\"count\":" + cartJson.trim().length() + "}");
    } else {
        out.print("{\"status\":\"error\",\"message\":\"Cart JSON parameter missing\"}");
    }
%>
