OpenSeesMPI is a simple alternative to OpenSeesMP, the parallel interpreter version of OpenSees that allows for message passing and parallelization of the finite element domain [1]. 
OpenSeesMPI is easy to set up because it does not require compiling a parallel version of OpenSees. 
OpenSeesMPI instead uses TclMPI, a Tcl package that provides MPI bindings through a dynamic linker library (.dll) or shared object (.so) file [2].
Because of this, OpenSeesMPI only replicates the message-passing functionality of OpenSeesMP (getPID, getNP, send, recv and barrier). 
If parallelization of the finite element domain is required, OpenSeesSP or OpenSeesMP can be used. 

# Requirements:
Must have mpiexec and OpenSees installed and on the path. OpenSees must be installed with a complete Tcl installation, and the TclMPI package must be installed and available via "package require". 

# Installation and Basic Use:
Run the installer in the latest release.
Then, OpenSeesMPI can be called as shown below, where *np* represents the number of parallel processes, and *inputFile* represents the Tcl input script.

`
OpenSeesMPI **-n** *np* *inputfile*
`
  
# Advanced Use:
Arguments up to the last argument or up to **--** are taken as mpiexec options.
The remaining arguments are taken as the input file and the input arguments.
If input arguments are desired, the option terminator **--** must be used.

`
OpenSeesMPI ?*options*? ?**--**? *inputFile* ?*inputArgs*?
`
  
# Command Documentation
Functionality is compatible with OpenSeesMP, with a few additional features.
  
* The command _getPID_ returns the integer rank of the process, using the TclMPI binding _::tclmpi::comm_rank_.
  
  `getPID` 
  
* The command _getNP_ returns the number of parallel processes, using the TclMPI binding _::tclmpi::comm_size_.
  
  `getNP` 
  
* The command _send_ sends $data from the current process to process $pid, using the TclMPI binding _::tclmpi::send_. Note that the prefix "-pid" is optional with OpenSeesMPI but mandatory in OpenSeesMP.
  
  `send <-pid> $pid $data`
  
* The command _recv_ returns data received from process $pid, and optionally stores it in variable $varName, using the TclMPI binding _::tclmpi::recv_. If $pid is "ANY", it will receive from any process. Note that the prefix "-pid" and the variable name $varName are optional with OpenSeesMPI but mandatory in OpenSeesMP.
  
  `recv <-pid> $pid <$varName>`
  
* The command _bcast_ broadcasts data from process 0 to all other processes and returns the same value on all processes, using the TclMPI binding _::tclmpi::bcast_. The alternate spelling _Bcast_ is also valid. This command is not available on older versions of OpenSeesMP.

  `bcast <$data>`
  
* The command _barrier_ waits for all processes to reach the barrier, using the TclMPI binding _::tclmpi::barrier_.
  
  `barrier`
  
Additionally, more advanced MPI commands are available through the TclMPI package, which is documented here: https://akohlmey.github.io/tclmpi/

# Citations
1. Mckenna, F. (2011). OpenSees: A Framework for Earthquake Engineering Simulation. Computing in Science & Engineering, 13(4), 58–66. https://doi.org/10.1109/MCSE.2011.66
2. Axel Kohlmeyer. (2021). TclMPI: Release 1.1 [Data set]. Zenodo. DOI: 10.5281/zenodo.598343

# Acknowledgements
Thanks to Dr. Axel Kohlmeyer for making TclMPI available on Windows.

# To Do:
* Provide Linux and Mac OS equivalents of OpenSeesMPI.bat
