@ECHO off
REM ----------------------------------------------------------------------------
REM OpenSeesMPI, Portable MPI for OpenSees
REM Copyright (C) 2021 Alex Baker, ambaker1@mtu.edu
REM All rights reserved. 
REM 
REM See the file "opsmpi.tcl" for information on usage, 
REM redistribution, and for a DISCLAIMER OF ALL WARRANTIES.
REM ----------------------------------------------------------------------------

REM Initialize variables
SET batdir=%~dp0
SET mpiargs=
SET opsargs=

REM Parse mpiexec arguments
:ParseMPI
REM Look ahead to find mpiexec cut-off
IF "%~2"=="" (
    REM Last argument is OpenSees file
    GOTO ParseOPS
) ELSE (
    SET mpiargs=%mpiargs% "%~1"
    SHIFT
)
REM Option to have extra OpenSees arguments
IF "%~1"=="--" (
    SHIFT
    GOTO ParseOPS
)
GOTO ParseMPI 

REM Parse OpenSees arguments
:ParseOPS
IF "%~1"=="" (
    GOTO Run
) ELSE (
    SET opsargs=%opsargs% "%~1"
    SHIFT
)
GOTO ParseOPS

REM Finally, run OpenSeesMPI
:Run
REM Dummy call to OpenSees to get header, then call in parallel with opsmpi.
OpenSees NUL
mpiexec %mpiargs% OpenSees "%batdir%\opsmpi.tcl" %opsargs% 2>NUL
