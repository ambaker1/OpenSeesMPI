# Simple demonstration of broadcast (bcast) command
if {[getPID] == 0} {
    bcast "Hello World"
} else {
    set msg [bcast]
    puts "$msg from [getPID]"
}
