# Example from OpenSeesMP presentation by Frank McKenna
set pid [getPID]
set np [getNP]
if {$pid == 0} {
    puts "Random:"
    for {set i 1 } {$i < $np} {incr i 1} {
        recv -pid ANY msg
        puts "$msg"
    }
} else {
    send -pid 0 "Hello from $pid"
}
barrier
if {$pid == 0 } {
    puts "\nOrdered:"
    for {set i 1 } {$i < $np} {incr i 1} {
        recv -pid $i msg
        puts "$msg"
    }
} else {
    send -pid 0 "Hello from $pid"
}
barrier
