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
  Integer pk =
    Integer.valueOf(request.getParameter("bookID"));
  ssb.delete(pk);
  ssb.remove();
%>
  <jsp:forward page="BookValueList.jsp" />

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