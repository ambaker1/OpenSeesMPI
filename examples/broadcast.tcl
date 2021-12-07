# Simple demonstration of broadcasting using send/recv
if {[getPID] == 0} {
    send "Hello World"
} else {
    recv msg
    puts "$msg from [getPID]"
}
