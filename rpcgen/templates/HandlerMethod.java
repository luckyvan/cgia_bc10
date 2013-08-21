<%

out_type = rpc_type( method_type )

args = []
call_args = []
arguments.each { |arg|

  type = arg.type

  name = arg.name

  args.push( "#{type} #{name}" )
  call_args.push( "#{name}" )
}
%>
  public <%= out_type %> <%= method_name %>( <%= args.join( ", " ) %> )
  {
    <%= class_name %> obj = new <%= class_name %>();
    return new <%= out_type %>( obj.<%= method_name %>( <%= call_args.join( ", " ) %> ) );
  }
