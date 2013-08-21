<%
args = []

elements = []

arguments.each { |arg|
  type = arg.type
  rtype = rpc_type( type )
  name = arg.name

  args.push( "#{type} #{name}" )

  if ( rtype != type )

    elements.push( "new #{rtype}( #{name} )" )
  
  else

    elements.push( name )

  end
}
%>
  public <%= method_type %> <%= method_name %>( <%= args.join( ", " ) %> ) throws XmlRpcException, IOException
  {
    Vector params = new Vector();
<% elements.each { |elem| %>
    params.addElement( <%= elem.to_s %> );<% } %>

    Object result = _client.execute( "<%= class_name %>.<%= method_name %>", params );
<% if ( method_type != rpc_type( method_type ) ) %>
    return ((<%= rpc_type( method_type ) %>)result).<%= method_type %>Value();
<% else %>
    return (<%= method_type %>)result;
<% end %>
  }
