<html>
<head>
<title>Edit Name</title>
</head>
<body>
<form action="form2.jsp" method="post">
<table>

<tr><td>First Name</td><td><edit name="first" value="<% myBean.getFirst() %>">
</td></tr>

<tr><td>Middle Initial</td><td><edit name="middle" value="<% myBean.getMiddle() %>">
</td></tr>

<tr><td>Last Name</td><td><edit name="last" value="<% myBean.getLast() %>">
</td></tr>

</table>
</form>
</body>
</html>
