# Ensure that enough arguments are provided
if ($args.count -lt 3) 
{
    Write-Host "Insufficient number of arguments"
    Exit 1
}
# Split arguments
$mpiargs = $args[0..($args.count-2)]
$filename = $args[-1]
# Get location of opsmpi script
$exepath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
$exedir = [System.IO.Path]::GetDirectoryName($exepath)
$opsmpi = "$exedir\opsmpi.tcl"
# Run opensees via mpiexec with opsmpi, redirecting stderr to null
# To do: Display OpenSees header without throwing nasty error to terminal
mpiexec @mpiargs opensees $opsmpi $filename 2> $null
