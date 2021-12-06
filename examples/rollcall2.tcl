# Roll call! Using OpenSeesMPI simplified send/recv syntax
barrier
if {[getPID] == 0} {
    send 1 [getPID]
    set attendance [recv [expr {[getNP] - 1}]]
    puts "Attendance: $attendance"
} else {
    set attendance [recv [expr {[getPID] - 1}]]
    lappend attendance [getPID]
    if {[getPID] == ([getNP] - 1)} {
        send 0 $attendance
    } else {
        send [expr {[getPID] + 1}] $attendance
    }
}
barrier
