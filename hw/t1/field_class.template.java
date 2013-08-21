// =======================================================================
// Warning. Do not edit this file directly.  This file was built with the
// t1 generator. You should edit the data.xml file and re-run the generator.
// =======================================================================

public class <%= class_name %> {
<% fields.each { |field| %>
  protected String _<%= field %>;<% } %>

  public <%= class_name %>()
  { <% fields.each { |field| %>
    _<%= field %> = new String();<% } %>
  }
<% fields.each { |field| %>
  public String get<%= field.capitalize %>() { return _<%= field %>; }
  public void set<%= field.capitalize %>( String value ) { _<%= field %> = value; }
<% } %>
}

// =======================================================================
// Warning. Do not edit this file directly.  This file was built with the
// t1 generator. You should edit the data.xml file and re-run the generator.
// =======================================================================
