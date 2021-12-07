# Roll call! Using OpenSeesMPI alternative send/recv syntax
barrier
if {[getPID] == 0} {
    send -pid 1 [getPID]
    set attendance [recv -pid [expr {[getNP] - 1}]]
    puts "Attendance: $attendance"
} else {
    set attendance [recv -pid [expr {[getPID] - 1}]]
    lappend attendance [getPID]
    if {[getPID] == ([getNP] - 1)} {
        send -pid 0 $attendance
    } else {
        send -pid [expr {[getPID] + 1}] $attendance
    }
}
barrier
