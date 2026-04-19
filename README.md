# SvMincraft

## Panel de IPs (Local y VPN)
Este repositorio incluye el script `panel-ips.ps1`, que muestra las IPv4 del equipo en un panel separado por tipo de interfaz:
- `LOCAL`
- `VPN`

El panel se refresca automáticamente según el intervalo configurado.

## Requisitos
- PowerShell con acceso a los cmdlets de red (`Get-NetIPAddress`, `Get-NetAdapter`).

## Uso
Desde la raíz del repositorio, ejecutar:

```powershell
.\panel-ips.ps1
```

Con intervalo personalizado (en segundos):

```powershell
.\panel-ips.ps1 -IntervaloSegundos 5
```

## Detener ejecución
Presiona `Ctrl + C` para finalizar el refresco continuo del panel.
