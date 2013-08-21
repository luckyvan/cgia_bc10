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
    Integer pk =
      Integer.valueOf(request.getParameter("authorID"));
  AuthorValue val = ssb.getAuthorValue(pk);

  if(request.getParameter("doSubmit") != null){
    val.setName(request.getParameter("name").equals("") ? null : (request.getParameter("name")));
    val.setPenName(request.getParameter("penName").equals("") ? null : (request.getParameter("penName")));

    ssb.update(val);
    ssb.remove();
%>
    <jsp:forward page="AuthorValueList.jsp" />
<%
  }
%>
<head>
<title>Update Author</title>
</head>
<body>
<h1>Update Author</h1>
<form>
<table border=0>
<tr>
  <td>authorID</td>
  <td>
  <%= val.getAuthorID() %>
      <input type="hidden" name="authorID" value="<%= val.getAuthorID() %>">

  </td>
  <td>
  integer 
  
  
  not null
  
  </td>
</tr>
<tr>
  <td>name</td>
  <td>
  <input type="text" name="name" value="<%= ((val.getName() == null) ? "" : val.getName().toString())  %>">

  </td>
  <td>
  varchar 
  (80)
  unique
  not null
  
  </td>
</tr>
<tr>
  <td>penName</td>
  <td>
  <input type="text" name="penName" value="<%= ((val.getPenName() == null) ? "" : val.getPenName().toString())  %>">

  </td>
  <td>
  varchar 
  (80)
  
  
  
  </td>
</tr>

</table>
<input type="submit" name="doSubmit">
</form>
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
