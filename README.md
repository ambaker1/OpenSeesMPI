OpenSeesMPI is a simple alternative to OpenSeesMP, the parallel interpreter version of OpenSees that allows for message passing and parallelization of the finite element domain [1]. 
OpenSeesMPI is easy to set up because it does not require compiling a parallel version of OpenSees. 
OpenSeesMPI instead uses TclMPI, a Tcl package that provides MPI bindings through a dynamic linker library (.dll) or shared object (.so) file [2].
Because of this, OpenSeesMPI only replicates the message-passing functionality of OpenSeesMP (getPID, getNP, send, recv and barrier). 
If parallelization of the finite element domain is required, OpenSeesSP or OpenSeesMP can be used. 

# Requirements:
Must have mpiexec and OpenSees installed and on the path. OpenSees must be installed within a complete Tcl installation (not the light-weight version included with OpenSees download), and the TclMPI package must be installed and available via "package require". 

# Installation and Use:
For Windows, copy "OpenSeesMPI.bat" and "opsmpi.tcl" to your Tcl installation binary folder.
Then, OpenSeesMPI can be called as shown below, where <np> represents the number of parallel processes, and <inputFile> represents the Tcl input script.
Other MPI options can also be included, as long as the last argument is the input file.
  
`
OpenSeesMPI -n <np> <inputfile>
`

If someone wants to contribute the equivalent of "OpenSeesMPI.bat" for Linux and Mac OS, that would be fantastic! It just parses inputs and passes them to mpiexec and OpenSees.
  
# Command Documentation
Functionality is compatible with OpenSeesMP, with a few minor changes.
  
* The command _getPID_ returns the integer rank of the process, using the TclMPI binding _::tclmpi::comm_rank_.
  
  `getPID` 
  
* The command _getNP_ returns the number of parallel processes, using the TclMPI binding _::tclmpi::comm_size_.
  
  `getNP` 
  
* The command _send_ sends $data from the current process to process $pid, using the TclMPI binding _::tclmpi::send_. Note that the prefix "-pid" is optional with OpenSeesMPI but mandatory in OpenSeesMP.
  
  `send <-pid> $pid $data`
  
* The command _recv_ receives data from process $pid, and stores it in variable $varName, using the TclMPI binding _::tclmpi::recv_. If $pid is "ANY", it will receive from any process. Note that the prefix "-pid" is optional with OpenSeesMPI but mandatory in OpenSeesMP.
  
  `recv <-pid> $pid $varName`
  
* The command _barrier_ waits for all processes to reach the barrier, using the TclMPI binding _::tclmpi::barrier_.
  
  `barrier`

# Citations
1. Mckenna, F. (2011). OpenSees: A Framework for Earthquake Engineering Simulation. Computing in Science & Engineering, 13(4), 58–66. https://doi.org/10.1109/MCSE.2011.66
2. Axel Kohlmeyer. (2021). TclMPI: Release 1.1 [Data set]. Zenodo. DOI: 10.5281/zenodo.598343

# Acknowledgements
Thanks to Dr. Axel Kohlmeyer for helping me compile TclMPI on Windows, and thanks to Dr. Daniel M. Dowden for being a supportive research advisor.
