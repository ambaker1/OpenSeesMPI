OpenSeesMPI is a simple alternative to OpenSeesMP, the parallel interpreter version of OpenSees that allows for message passing and parallelization of the finite element domain [1]. 
OpenSeesMPI is easy to set up because it does not require compiling a parallel version of OpenSees. 
OpenSeesMPI instead uses TclMPI, a Tcl package that provides MPI bindings through a dynamic linker library (.dll) or shared object (.so) file [2].
Because of this, OpenSeesMPI only replicates the message-passing functionality of OpenSeesMP (getPID, getNP, send, recv and barrier). 
If parallelization of the finite element domain is required, OpenSeesSP or OpenSeesMP can be used. 

# Requirements:
Must have mpiexec and OpenSees installed and on the path. OpenSees must be installed within a complete Tcl installation (not the light-weight version included with OpenSees download), and the TclMPI package must be installed and available via "package require".

# Basic Use
Linking to TclMPI is accomplished with the wrapper script opsmpi.tcl. To run a file in OpenSeesMPI, place opsmpi.tcl in the same directory as your Tcl input script, and call the following, where <np> represents the number of parallel processes, and <inputFile> represents the Tcl input script.
  
`
mpiexec -n <np> OpenSees opsmpi.tcl <inputfile> 
`

# Windows Batch File
Alternatively, a batch file has been included for ease of use on Windows. 
To use this method, place OpenSeesMPI.bat and opsmpi.tcl in your Tcl installation binary folder.
Then, OpenSeesMPI can be called as shown below. 
Other MPI options can also be included, as long as the last argument is the input file.
  
`
OpenSeesMPI -n <np> <inputfile>
`

# Citations
1. Mckenna, F. (2011). OpenSees: A Framework for Earthquake Engineering Simulation. Computing in Science & Engineering, 13(4), 58–66. https://doi.org/10.1109/MCSE.2011.66
2. Axel Kohlmeyer. (2021). TclMPI: Release 1.1 [Data set]. Zenodo. DOI: 10.5281/zenodo.545847

# Acknowledgements
Thanks to Dr. Axel Kohlmeyer for helping me compile TclMPI on Windows, and thanks to Dr. Daniel M. Dowden for being a supportive research advisor.
