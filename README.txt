OpenSeesMPI is a simple alternative to OpenSeesMP, the parallel interpreter version of OpenSees that allows for message passing and parallelization of the finite element domain [1]. 
OpenSeesMPI is easy to set up because it does not require compiling a parallel version of OpenSees. 
OpenSeesMPI instead uses TclMPI, a Tcl package that provides MPI bindings through a dynamic linker library (.dll) or shared object (.so) file [2].
Because of this, OpenSeesMPI only replicates the message-passing functionality of OpenSeesMP (getPID, getNP, send, recv and barrier). 
If parallelization of the finite element domain is required, OpenSeesSP or OpenSeesMP must be used. 

# Compiling

To compile on Windows, install ps2exe as a powershell module, and run the following command in the source directory: 
`
ps2exe .\OpenSeesMPI.ps1 .\OpenSeesMPI.exe
`

# Installation
To install, place OpenSeesMPI.exe and opsmpi.tcl in your Tcl installation binary folder. 
Must have a complete Tcl installation (not the light-weight version included with OpenSees download), and TclMPI installed in the Tcl lib folder. 

# Use
To use, simply call as if calling mpiexec, with the last argument being the .tcl input file, as shown below:
`
OpenSeesMPI -n 5 input.tcl
`

# Citing
Baker, A. (2021). OpenSeesMPI (0.0) [Windows].

# Citations
1. Mckenna, F. (2011). OpenSees: A Framework for Earthquake Engineering Simulation. Computing in Science & Engineering, 13(4), 58–66. https://doi.org/10.1109/MCSE.2011.66
2. Axel Kohlmeyer. (2021). TclMPI: Release 1.1 [Data set]. Zenodo. DOI: 10.5281/zenodo.545847

# Acknowledgements
Thanks to Dr. Daniel M. Dowden for being a supportive research advisor, and thanks to Dr. Axel Kohlmeyer for putting in the work to make TclMPI work on Windows, and guiding me in this process.