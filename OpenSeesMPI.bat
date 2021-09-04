@ECHO off
SET batdir=%~dp0
REM Split input arguments for application (last arg is input file)
SET mpiargs=
:loop
SET lastarg=%1
SHIFT
IF "%1"=="" GOTO continue
SET mpiargs=%mpiargs% %lastarg%
GOTO loop
:continue
REM Dummy call to OpenSees to get header, then call in parallel with opsmpi.
OpenSees %batdir%\opsmpi.tcl
mpiexec %mpiargs% OpenSees %batdir%\opsmpi.tcl %lastarg% 2>NUL
