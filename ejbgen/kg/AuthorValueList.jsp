<%
// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
%>
<%@ page language="java" %>
<%@ page import="gen.*" %>
<%@ page import="java.util.*" %>

<%
  AuthorSS ssb = 
    SSFactory.createAuthor();
  String query = request.getParameter("query");
  Collection coll = null;

  if(query != null){
  }

  if(coll == null) coll = ssb.getAllAuthorValue();
%>

<html>
<head>
<title>AuthorValue List</title>
</head>
<body>
<h1>AuthorValue List</h1>
<table border=1>
  <tr>
  <td><b>Update</b></td>
  <td><b>Delete</b></td>
    <td><b>authorID</b></td>
    <td><b>name</b></td>
    <td><b>penName</b></td>
  </tr>
<%
  for(Iterator i = coll.iterator(); i.hasNext(); ){
    AuthorValue val = (AuthorValue)i.next();
%>
  <tr>
  <td><a href="AuthorUpdate.jsp?authorID=<%= val.getAuthorID() %>&return=AuthorValueList.jsp">Update</a></td>
  <td><a href="AuthorDelete.jsp?authorID=<%= val.getAuthorID() %>&return=AuthorValueList.jsp">Delete</a></td>
    <td><%= val.getAuthorID() %></td>
    <td><%= val.getName() %></td>
    <td><%= val.getPenName() %></td>
  </tr>
<%
  }
%>
</table>
<a href="AuthorAdd.jsp?return=AuthorValueList.jsp">Add Author</a>
<br>
<a href="index.jsp">List Page Index</a>
<p>
 
</body>
</html>
<%
  ssb.remove();
%>

<%
// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
%>
