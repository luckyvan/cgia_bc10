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

  if(request.getParameter("doSubmit") != null){
    AuthorValue val = new AuthorValue();
    val.setName(request.getParameter("name").equals("") ? null : (request.getParameter("name")));
    val.setPenName(request.getParameter("penName").equals("") ? null : (request.getParameter("penName")));

    ssb.add(val);
    ssb.remove();
%>
    <jsp:forward page="AuthorValueList.jsp" />
<%
  }
%>
<head>
<title>Add Author</title>
</head>
<body>
<h1>Add Author</h1>
<form>
<table border=0>
<tr>
  <td>authorID</td>
  <td>
  &nbsp;

  <td>
  integer 
  
  
  not null
  
  </td>
</tr>
<tr>
  <td>name</td>
  <td>
  <input type=text name=name>

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
  <input type=text name=penName>

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
