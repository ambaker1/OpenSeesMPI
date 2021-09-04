# Roll call!
barrier
if {[getPID] == 0} {
    send -pid 1 [getPID]
    recv -pid [expr {[getNP] - 1}] attendance
    puts "Attendance: $attendance"
} else {
    recv -pid [expr {[getPID] - 1}] attendance
    lappend attendance [getPID]
    if {[getPID] == ([getNP] - 1)} {
        send -pid 0 $attendance
    } else {
        send -pid [expr {[getPID] + 1}] $attendance
    }
}
barrier
# puts "hello world"
# barrier

