OpenSeesMPI is a batch file that emulates the message passing functionality of
OpenSeesMP, often used for parameter studies, without the need for a parallel
version of OpenSees. 

This is accomplished with tclmpi, a Tcl package that provides MPI bindings 
through a dynamic linker library (.dll) or shared object (.so) file.

To run, one must have mpiexec installed and on the path, OpenSees installed and
on the path, and the TclMPI package installed in the Tcl library 

calls MPI and OpenSees, using an intermediate
Tcl file (opsmpi.tcl) to create the OpenSeesMP MPI commands (getPID, getNP, 
send, recv, and barrier)

OpenSeesMPI is simply a batch file that calls MPI and OpenSees, using a wrapper
Tcl file to create the OpenSeesMP MPI commands (getPID, getNP, send, recv, and barrier)tcl and batch files provide an interface for running the OpenSees Tcl
interpreter in parallel with mpi, without the need for a parallel version of 
OpenSees. This is accomplished with tclmpi, a Tcl package that provides mpi 
bindings through a dynamic linker library (.dll) or shared object (.so) file.
OpenSeesMPI does not 