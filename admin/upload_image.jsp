<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");

/* 1. STRICT ADMIN ROLE AUTHORIZATION GUARD */
Map<String, Object> adminUser = (Map<String, Object>) session.getAttribute("adminUser");
if (adminUser == null || !"ADMIN".equalsIgnoreCase((String) adminUser.get("role"))) {
    out.print("{\"success\": false, \"error\": \"Unauthorized access. Admin privileges required.\"}");
    return;
}

String fileName = request.getParameter("fileName");
String base64 = request.getParameter("base64");

String responseJson = "";

if (fileName != null && base64 != null && !fileName.trim().isEmpty()) {
    try {
        // 2. PATH TRAVERSAL PROTECTION & FILENAME SANITIZATION
        fileName = new File(fileName.trim()).getName().replaceAll("[^a-zA-Z0-9\\._-]", "_");
        String lowerName = fileName.toLowerCase();
        
        // 3. STRICT FILE EXTENSION WHITELIST
        if (!lowerName.endsWith(".png") && !lowerName.endsWith(".jpg") && !lowerName.endsWith(".jpeg") && !lowerName.endsWith(".webp")) {
            fileName += ".png";
        }

        if (base64.contains(",")) {
            base64 = base64.substring(base64.indexOf(",") + 1);
        }

        byte[] imageBytes = Base64.getDecoder().decode(base64.trim());

        // 4. FILE SIZE LIMIT (MAX 5 MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
            out.print("{\"success\": false, \"error\": \"Image file size exceeds maximum limit of 5MB.\"}");
            return;
        }

        // Save to Tomcat 9.0 webapps/Daynemic_web/images
        String targetPath1 = application.getRealPath("/images");
        File destDir1 = new File(targetPath1);
        if (!destDir1.exists()) destDir1.mkdirs();
        File destFile1 = new File(destDir1, fileName);
        FileOutputStream fos1 = new FileOutputStream(destFile1);
        fos1.write(imageBytes);
        fos1.close();

        // Save to XAMPP Tomcat webapps/Daynemic_web/images
        try {
            File destDir2 = new File("C:/xampp/tomcat/webapps/Daynemic_web/images");
            if (destDir2.exists()) {
                File destFile2 = new File(destDir2, fileName);
                FileOutputStream fos2 = new FileOutputStream(destFile2);
                fos2.write(imageBytes);
                fos2.close();
            }
        } catch(Exception e2) {}

        responseJson = "{\"success\": true, \"fileName\": \"" + fileName + "\"}";
    } catch(Exception e) {
        responseJson = "{\"success\": false, \"error\": \"" + e.getMessage().replace("\"", "'") + "\"}";
    }
} else {
    responseJson = "{\"success\": false, \"error\": \"Missing or invalid file data.\"}";
}

out.print(responseJson);
%>
