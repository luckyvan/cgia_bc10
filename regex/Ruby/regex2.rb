"a=1;b=2;c=3;".scan( /(.*?)=(.*?);/ ) { |key,value|

  print "#{key} : #{value}\n"

}
