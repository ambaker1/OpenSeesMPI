# OpenSeesMPI
OpenSeesMPI uses the TclMPI package [1] to replicate the message passing functionality of OpenSeesMP [2], without requiring a parallel version of OpenSees. 

## Requirements
Must have mpiexec and OpenSees installed and on the path. OpenSees must be installed with a complete Tcl installation, and the TclMPI package must be installed and available via "package require". 

## Installation and Basic Use
Run the installer in the latest release.
Then, OpenSeesMPI can be called as shown below, where $np represents the number of parallel processes, and $inputFile represents the Tcl input script.

`OpenSeesMPI -n $np $inputfile`
  
## Advanced Use
Arguments up to the last argument or up to "--" are taken as mpiexec options.
The remaining arguments are taken as the input file and the input arguments.
If input arguments are desired, the option terminator "--" must be used.

`OpenSeesMPI <$opt1 $opt2 ...> <--> $inputFile <$arg1 $arg2 ...>`
  
## Command Documentation
Functionality is compatible with OpenSeesMP, with a few additional features.
  
* The command _getPID_ returns the integer rank of the process, using the TclMPI binding _::tclmpi::comm_rank_.
  
  `getPID` 
  
* The command _getNP_ returns the number of parallel processes, using the TclMPI binding _::tclmpi::comm_size_.
  
  `getNP` 
  
* The command _send_ either sends $data from the current process to process $pid, or broadcasts $data to all other processes (must be called from process 0), using the TclMPI bindings _::tclmpi::send_ and _::tclmpi::bcast_.
  
  `send <-pid $pid> $data`
  
* The command _recv_ either returns data sent from pid $pid (if $pid is "ANY", it will receive data from any process), or returns data broadcast from process 0, using the TclMPI bindings _::tclmpi::recv_ and _::tclmpi::bcast_. Optionally, the received data can be stored in a variable with the $varName argument. Note that the $varName argument is optional with OpenSeesMPI but mandatory in OpenSeesMP.
  
  `recv <-pid $pid> <$varName>`
  
* The command _barrier_ waits for all processes to reach the barrier, using the TclMPI binding _::tclmpi::barrier_.
  
  `barrier`
  
More advanced MPI functionality is available with the TclMPI package, which is automatically loaded when using OpenSeesMPI. TclMPI commands are documented here: https://akohlmey.github.io/tclmpi/

## Citations
1. Axel Kohlmeyer. (2021). TclMPI: Release 1.2 [Data set]. Zenodo. DOI: 10.5281/zenodo.5637677
2. Mckenna, F. (2011). OpenSees: A Framework for Earthquake Engineering Simulation. Computing in Science & Engineering, 13(4), 58–66. https://doi.org/10.1109/MCSE.2011.66

## Acknowledgements
Thanks to Dr. Axel Kohlmeyer for making TclMPI available on Windows.

## To Do:
* Provide Linux and Mac OS equivalents of OpenSeesMPI.bat
