[CmdletBinding()]
param(
    [string]$JavaPath = "java",
    [string]$JarPath = ".\server.jar",
    [string]$MinMemory = "1G",
    [string]$MaxMemory = "2G",
    [switch]$NoGui = $true,
    [switch]$AllowAlreadyRunning
)

$ErrorActionPreference = "Stop"

function Get-ServerPort {
    param(
        [string]$PropertiesPath = ".\server.properties"
    )

    if (-not (Test-Path $PropertiesPath)) {
        return 25565
    }

    foreach ($line in Get-Content $PropertiesPath) {
        if ($line -match '^\s*server-port\s*=\s*(\d+)\s*$') {
            return [int]$matches[1]
        }
    }

    return 25565
}

function Test-PortInUse {
    param(
        [int]$Port
    )

    $listener = $null
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
        $listener.Start()
        return $false
    } catch {
        return $true
    } finally {
        if ($listener -ne $null) {
            try { $listener.Stop() } catch {}
        }
    }
}

function Test-FileLocked {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return $false
    }

    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        return $false
    } catch {
        return $true
    } finally {
        if ($stream -ne $null) {
            $stream.Dispose()
        }
    }
}

try {
    $null = Get-Command $JavaPath -ErrorAction Stop
} catch {
    throw "No se encontró Java en '$JavaPath'. Instala Java 17+ o usa -JavaPath con la ruta completa."
}

$resolvedJarPath = $JarPath
try {
    $resolvedJarPath = (Resolve-Path $JarPath -ErrorAction Stop).Path
} catch {
    throw "No se encontró el archivo del servidor en '$JarPath'."
}

$jarFileName = [System.IO.Path]::GetFileName($resolvedJarPath)
$javaProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match '^java(\.exe)?$' -and
    ($_.CommandLine -match [Regex]::Escape($resolvedJarPath) -or $_.CommandLine -match [Regex]::Escape($jarFileName))
}

if ($javaProcesses -and -not $AllowAlreadyRunning) {
    $pids = ($javaProcesses | ForEach-Object { $_.ProcessId }) -join ", "
    throw "Ya hay una instancia del servidor en ejecución (PID: $pids). Deténla primero o usa -AllowAlreadyRunning."
}
if ($javaProcesses -and $AllowAlreadyRunning) {
    $pids = ($javaProcesses | ForEach-Object { $_.ProcessId }) -join ", "
    Write-Warning "Se detectó una instancia activa (PID: $pids) y se omiten validaciones de conflicto por -AllowAlreadyRunning."
} else {
    $serverPort = Get-ServerPort
    if (Test-PortInUse -Port $serverPort) {
        throw "El puerto $serverPort está en uso. Revisa si el servidor ya está corriendo o cambia server-port en server.properties."
    }

    $latestLogPath = Join-Path (Get-Location) "logs\\latest.log"
    if (Test-FileLocked -Path $latestLogPath) {
        throw "El archivo de log '$latestLogPath' está bloqueado por otro proceso. Cierra el proceso que lo usa y vuelve a intentar."
    }
    throw "El archivo de log '$latestLogPath' está bloqueado por otro proceso. Cierra el proceso que lo usa y vuelve a intentar."
}

$eulaPath = Join-Path (Get-Location) "eula.txt"
if (-not (Test-Path $eulaPath)) {
    Write-Warning "No existe eula.txt. El primer arranque podría requerir aceptar la EULA."
} else {
    $eulaAccepted = Select-String -Path $eulaPath -Pattern '^\s*eula\s*=\s*true\s*$' -Quiet
    if (-not $eulaAccepted) {
        Write-Warning "eula.txt no tiene eula=true. El servidor no iniciará hasta aceptar la EULA."
    }
}

$args = @("-Xms$MinMemory", "-Xmx$MaxMemory", "-jar", $resolvedJarPath)
if ($NoGui) {
    $args += "nogui"
}

Write-Host "Iniciando servidor Minecraft con: $JavaPath $($args -join ' ')" -ForegroundColor Cyan
& $JavaPath @args
if ($LASTEXITCODE -ne 0) {
    throw "El proceso Java finalizó con código $LASTEXITCODE."
}
