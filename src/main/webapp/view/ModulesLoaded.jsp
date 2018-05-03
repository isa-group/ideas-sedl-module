<%-- 
    Document   : ModulesLoaded
    Created on : 03-may-2018, 0:21:50
    Author     : japarejo
--%>

<%@page import="es.us.isa.sedl.module.SEDLModuleRegistry"%>
<%@page contentType="text/html" pageEncoding="windows-1252"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
        <title>Modules loaded</title>
    </head>
    <body>
        <h1>Modules loaded</h1>
        <ul>
            <%for(Class c:new SEDLModuleRegistry().getSubClasses()){%>
            <li><%=c.getName()%></li>
            <%}%>
        </ul>
    </body>
</html>
