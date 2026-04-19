[CmdletBinding()]
param(
    [int]$IntervaloSegundos = 3
)

$ErrorActionPreference = "SilentlyContinue"

$vpnPat = '(?i)vpn|wireguard|wintun|openvpn|tailscale|zerotier|tap|tun|ppp|forti|cisco|anyconnect|hamachi'

function Get-PanelIps {
    Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
    ForEach-Object {
        $if = Get-NetAdapter -InterfaceIndex $_.InterfaceIndex
        [PSCustomObject]@{
            Tipo     = if (($_.InterfaceAlias -match $vpnPat) -or ($if.InterfaceDescription -match $vpnPat)) { 'VPN' } else { 'Local' }
            Interfaz = $_.InterfaceAlias
            IP       = $_.IPAddress
            Prefijo  = $_.PrefixLength
            Estado   = $if.Status
        }
    } |
    Sort-Object Tipo, Interfaz, IP
}

while ($true) {
    Clear-Host
    $ahora = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "Panel de IPs (actualizado: $ahora, cada $IntervaloSegundos s)" -ForegroundColor Cyan
    Write-Host ""

    $datos = Get-PanelIps
    $local = $datos | Where-Object { $_.Tipo -eq 'Local' }
    $vpn   = $datos | Where-Object { $_.Tipo -eq 'VPN' }

    Write-Host "=== LOCAL ===" -ForegroundColor Green
    if ($local) {
        $local | Format-Table Interfaz, IP, Prefijo, Estado -AutoSize
    } else {
        Write-Host "Sin IPs locales activas."
    }

    Write-Host ""
    Write-Host "=== VPN ===" -ForegroundColor Yellow
    if ($vpn) {
        $vpn | Format-Table Interfaz, IP, Prefijo, Estado -AutoSize
    } else {
        Write-Host "Sin IPs VPN activas."
    }

    Start-Sleep -Seconds $IntervaloSegundos
}
