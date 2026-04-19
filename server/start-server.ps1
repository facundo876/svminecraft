[CmdletBinding()]
param(
    [string]$JavaPath = "java",
    [string]$JarPath = ".\server.jar",
    [string]$MinMemory = "1G",
    [string]$MaxMemory = "2G",
    [switch]$NoGui = $true
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $JarPath)) {
    throw "No se encontró el archivo del servidor en '$JarPath'."
}

$args = @("-Xms$MinMemory", "-Xmx$MaxMemory", "-jar", $JarPath)
if ($NoGui) {
    $args += "nogui"
}

Write-Host "Iniciando servidor Minecraft con: $JavaPath $($args -join ' ')" -ForegroundColor Cyan
& $JavaPath @args
