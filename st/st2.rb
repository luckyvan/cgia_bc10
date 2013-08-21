name = "Jack"
cost = "$20"

format = 'Dear #{name}, You owe us #{cost}'

str = eval( '"'+format+'"' )

print "#{str}\n"
