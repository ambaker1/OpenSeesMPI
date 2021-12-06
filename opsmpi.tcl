# opsmpi.tcl
# OpenSeesMP MPI commands via the TclMPI package.
################################################################################
# Copyright 2021 Alex Baker <ambaker1@mtu.edu>
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors 
# may be used to endorse or promote products derived from this software without 
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
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
    namespace export getPID getNP send recv barrier bcast; # Parallel commands
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
# Send message to specified PID
# send <-pid> $pid $data
proc ::opsmpi::send {args} {
    variable rank
    variable size
    # Switch for arity
    if {[llength $args] == 3} {
        lassign $args -pid pid data
    } elseif {[llength $args] == 2} {
        lassign $args pid data
    } else {
        return -code error "Incorrect number of arguments"
    }
    # Check validity of pid input
    if {![string is integer -strict $pid]} {
        return -code error "pid must be integer"
    } elseif {$pid < 0 || $pid >= $size} {
        return -code error "pid out of range"
    } elseif {$pid == $rank} {
        return -code error "cannot send to self"
    }
    ::tclmpi::send $data tclmpi::auto $pid 0 tclmpi::comm_world
    return
}

# recv --
# Receive message to specified PID (or any PID)
# recv <-pid> $pid <$varName>
proc ::opsmpi::recv {args} {
    variable rank
    variable size
    # Check for optional -pid argument, and strip arg list.
    if {[lindex $args 0] eq {-pid}} {
        set args [lrange $args 1 end]
    }
    # Check arity
    if {[llength $args] < 1 || [llength $args] > 2} {
        return -code error "Incorrect number of arguments"
    }
    # Check validity of pid input
    set pid [lindex $args 0]
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
    # Option to link to variable
    if {[llength $args] == 2} {
        set varName [lindex $args 1]
        upvar $varName message
    }
    # Call TclMPI binding, saving to message variable and returning the value
    set message [::tclmpi::recv tclmpi::auto $pid tclmpi::any_tag \
            tclmpi::comm_world]
}

# bcast --
# Broadcast data from PID 0 to all other processes
# bcast <$data>
proc ::opsmpi::bcast {{data ""}} {
    ::tclmpi::bcast $data tclmpi::auto 0 tclmpi::comm_world
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
interp alias {} Bcast {} bcast; # Alias maintained for backwards-compatibility

# Strip "filename" argument from argv
set argv [lassign $argv filename]

# Source the file, with error control
if {[catch {source $filename} result options]} {
    puts "Error in process [getPID]: [dict get $options -errorinfo]"
    ::tclmpi::abort tclmpi::comm_world [dict get $options -code]
}

# Call modified exit command (finalizes tclmpi environment)
exit
