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
  BookSS ssb = 
    SSFactory.createBook();
  String query = request.getParameter("query");
  Collection coll = null;

  if(query != null){
    if(query.equals("getAllByTitle")){
      String title = (request.getParameter("title"));
      coll = ssb.getAllByTitle(
        title
        );
    }
    if(query.equals("getAllByAuthorName")){
      String authorName = (request.getParameter("authorName"));
      coll = ssb.getAllByAuthorName(
        authorName
        );
    }
  }

  if(coll == null) coll = ssb.getAllBookWithNamesValue();
%>

<html>
<head>
<title>BookWithNamesValue List</title>
</head>
<body>
<h1>BookWithNamesValue List</h1>
<table border=1>
  <tr>
  <td><b>Update</b></td>
  <td><b>Delete</b></td>
    <td><b>bookID</b></td>
    <td><b>title</b></td>
    <td><b>ISBN</b></td>
    <td><b>authorID</b></td>
    <td><b>publisherID</b></td>
    <td><b>status</b></td>
    <td><b>numCopies</b></td>
    <td><b>author_Name</b></td>
    <td><b>author_PenName</b></td>
    <td><b>publisher_Name</b></td>
  </tr>
<%
  for(Iterator i = coll.iterator(); i.hasNext(); ){
    BookWithNamesValue val = (BookWithNamesValue)i.next();
%>
  <tr>
  <td><a href="BookUpdate.jsp?bookID=<%= val.getBookID() %>&return=BookWithNamesValueList.jsp">Update</a></td>
  <td><a href="BookDelete.jsp?bookID=<%= val.getBookID() %>&return=BookWithNamesValueList.jsp">Delete</a></td>
    <td><%= val.getBookID() %></td>
    <td><%= val.getTitle() %></td>
    <td><%= val.getISBN() %></td>
    <td><%= val.getAuthorID() %></td>
    <td><%= val.getPublisherID() %></td>
    <td><%= val.getStatus() %></td>
    <td><%= val.getNumCopies() %></td>
    <td><%= val.getAuthor_Name() %></td>
    <td><%= val.getAuthor_PenName() %></td>
    <td><%= val.getPublisher_Name() %></td>
  </tr>
<%
  }
%>
</table>
<a href="BookAdd.jsp?return=BookWithNamesValueList.jsp">Add Book</a>
<br>
<a href="index.jsp">List Page Index</a>
<p>
<br>URL query available: append to URL <a href="BookWithNamesValueList.jsp?query=getAllByTitle&title=XXX">?query=getAllByTitle&title=XXX</a>
<br>URL query available: append to URL <a href="BookWithNamesValueList.jsp?query=getAllByAuthorName&authorName=XXX">?query=getAllByAuthorName&authorName=XXX</a>
 
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