# Ensure that enough arguments are provided
if ($args.count -lt 3) 
{
    Write-Host 'Insufficient number of arguments'
    Exit 1
}
# Split arguments
$mpiargs = $args[0..($args.count-2)]
$filename = $args[-1]
# Get location of executable (or powershell script)
if ([System.IO.Path]::GetExtension($PSCommandPath) -eq '.ps1') {
    $path = $PSCommandPath
} else {
    $path = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
}
$dir = [System.IO.Path]::GetDirectoryName($path)
$opsmpi = "$dir\opsmpi.tcl"
# Get header by performing a dummy call to OpenSees
Invoke-Expression 'OpenSees $opsmpi' -ErrorVariable header
Write-Host -NoNewLine $header
# Run opensees via mpiexec with opsmpi, redirecting stderr to null
mpiexec @mpiargs OpenSees $opsmpi $filename 2> $null
