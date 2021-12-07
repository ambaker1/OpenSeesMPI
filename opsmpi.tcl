# opsmpi.tcl
# OpenSeesMP MPI commands via the TclMPI package.
################################################################################
# Copyright (C) 2021 Alex Baker, ambaker1@mtu.edu
# All rights reserved. 
# 
# See the file "LICENSE.txt" for information on usage, redistribution, and for 
# a DISCLAIMER OF ALL WARRANTIES.
################################################################################

# Uses the TclMPI package for MPI bindings
# Axel Kohlmeyer. (2021). TclMPI: Release 1.2 [Data set]. Zenodo. 
# DOI: 10.5281/zenodo.5637677

# This file replicates the message-passing functionality provided in OpenSeesMP.
# Additional MPI functionality can be accessed with TclMPI commands.

# To prevent the command-window from being cluttered from the unbuffered 
# OpenSees error channel (especially the header), the "puts" and "logFile" 
# commands are modified, so that OpenSees warnings will only show in log files.

# To ensure that the TclMPI environment is properly handled, the "exit" command
# is modified to display a "Process terminating" message and to call 
# ::tclmpi::finalize before calling the real "exit" command.

# Ensure that an input arg exists
if {[llength $argv] == 0} {
    return -code error "Must specify OpenSees file"
}

# Require the package and initialize the mpi environment
package require tclmpi 1.2
::tclmpi::init

# Define the namespace for opsmpi
namespace eval ::opsmpi {
    variable rank [::tclmpi::comm_rank tclmpi::comm_world]
    variable size [::tclmpi::comm_size tclmpi::comm_world]
    variable log 0; # Whether stderr (and puts) are redirected to log
    variable echo 1; # Whether output goes to screen
    namespace export getPID getNP send recv barrier; # Parallel commands
    namespace export puts logFile exit; # Modified OpenSees commands
}

# getPID --
# Return the rank of the process
proc ::opsmpi::getPID {} {
    variable rank
    return $rank
}

# getNP --
# Return the size of the parallel pool
proc ::opsmpi::getNP {} {
    variable size
    return $size
}

# send --
# Send message to specified PID or broadcast to all from process 0.
# send <-pid $pid> $data
proc ::opsmpi::send {args} {
    variable rank
    variable size
    # Switch for send type
    if {[llength $args] == 3} {
        # Send to specific process
        if {[lindex $args 0] ne "-pid"} {
            return -code error "want send <-pid pid?> data?"
        }
        set pid [lindex $args 1]
        set data [lindex $args 2]
        # Check validity of pid input
        if {![string is integer -strict $pid]} {
            return -code error "pid must be integer"
        } elseif {$pid < 0 || $pid >= $size} {
            return -code error "pid out of range"
        } elseif {$pid == $rank} {
            return -code error "cannot send to self"
        }
        ::tclmpi::send $data tclmpi::auto $pid 0 tclmpi::comm_world
    } elseif {[llength $args] == 1} {
        # Send broadcast message (only for process 0)
        if {$rank != 0} {
            return -code error "only process 0 can send broadcast"
        }
        set data [lindex $args 0]
        ::tclmpi::bcast $data tclmpi::auto 0 tclmpi::comm_world
    } else {
        return -code error "incorrect number of arguments"
    }
    return
}

# recv --
# Receive message to specified PID (or any PID), or receive broadcast from pid 0
# recv <-pid $pid> <$varName>
proc ::opsmpi::recv {args} {
    variable rank
    variable size
    # Check arity
    if {[llength $args] > 3} {
        return -code error "incorrect number of arguments"
    }
    # Switch for receive type
    if {[llength $args] > 1} {
        # Receive from specific process
        if {[lindex $args 0] ne "-pid"} {
            return -code error "want recv <-pid pid?> <varName?>"
        }
        # Check validity of pid input
        set pid [lindex $args 1]
        if {![string is integer -strict $pid]} {
            if {$pid in {ANY ANY_SOURCE MPI_ANY_SOURCE}} {
                set pid tclmpi::any_source
            } else {
                return -code error "pid must be integer or \"ANY\""
            }
        } elseif {$pid < 0 || $pid >= $size} {
            return -code error "pid out of range"
        } elseif {$pid == $rank} {
            return -code error "cannot receive from self"
        }
        set message [::tclmpi::recv tclmpi::auto $pid tclmpi::any_tag \
            tclmpi::comm_world]
    } else {
        # Receive from broadcast
        if {$rank == 0} {
            return -code error "cannot receive from self"
        }
        set message [::tclmpi::bcast "" tclmpi::auto 0 tclmpi::comm_world]
    }
    # Option to link to variable
    if {[llength $args] % 2 == 1} {
        set varName [lindex $args end]
        upvar $varName var
        set var $message
    }
    return $message
}

# barrier --
# Wait until all processes reach barrier
proc ::opsmpi::barrier {} {
    ::tclmpi::barrier tclmpi::comm_world
}

# Redefine puts command to send results to stdout
rename puts ::opsmpi::ops_puts
proc ::opsmpi::puts {args} {
    variable log
    variable echo
    set nonewline 0
    set chan stdout; # Default channel (different than traditional OpenSees)
    set string [lindex $args end]
    switch [llength $args] {
        1 { # puts $string (normal case)
        }
        2 { # puts -nonewline $string || puts $chan $string
            set arg [lindex $args 0]
            if {$arg eq "-nonewline"} {
                set nonewline 1
            } else {
                set chan $arg
            }
        }
        3 { # puts -nonewline $chan $string
            lassign $args option chan
            if {$option eq "-nonewline"} {
                set nonewline 1
            } else {
                # Invalid option
                return -code error "wrong # args: should be \"puts ?-nonewline?\
                        ?channelId? string\""
            }
        }
        default {
            # Wrong number of arguments
            return -code error "wrong # args: should be \"puts ?-nonewline?\
                    ?channelId? string\""
        }
    }
    # Switch for channel (stdout is the usual case)
    if {$chan eq "stdout"} {
        # send to opserr and stdout
        if {$nonewline} {
            if {$log} {
                ops_puts -nonewline $string
            }
            if {$echo} {
                oldputs -nonewline $string
            }
        } else {
            if {$log} {
                ops_puts $string
            }
            if {$echo} {
                oldputs $string
            }
        }
    } else {
        # write to specified channel
        if {$nonewline} {
            oldputs -nonewline $chan $string
        } else {
            oldputs $chan $string
        }
    }
    return
}

# Redefine OpenSees logFile command to prevent unneeded stderr buffer
rename logFile ::opsmpi::ops_logFile
proc ::opsmpi::logFile {args} {
    variable log 1
    variable echo
    if {"-noEcho" in $args} {
        set echo 0
    }
    ops_logFile {*}$args -noEcho
    return
}

# Redefine exit to finalize MPI environment
rename exit ::opsmpi::ops_exit
proc ::opsmpi::exit {args} {
    variable rank
    variable echo 1
    puts "Process $rank terminating"
    ::tclmpi::finalize
    ops_exit {*}$args
}

# Import all commands into global (force)
namespace import -force ::opsmpi::*

# Strip "filename" argument from argv
set argv [lassign $argv filename]

# Source the file, with error control
if {[catch {source $filename} result options]} {
    puts "Error in process [getPID]: [dict get $options -errorinfo]"
    ::tclmpi::abort tclmpi::comm_world [dict get $options -code]
}

# Call modified exit command (finalizes tclmpi environment)
exit
