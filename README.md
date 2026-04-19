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

## Integración de `server/`
La carpeta `server/` se integra con una estrategia de versionado selectivo:
- Se versionan archivos reproducibles (plantillas, scripts y documentación).
- Se excluye estado runtime (mundo, logs, binarios y datos generados).

Archivos clave añadidos:
- `server/README.md`
- `server/start-server.ps1`
- `server/server.properties.example`
- `.gitignore` (con reglas de exclusión para runtime del servidor)

## Setup del servidor Minecraft
### Prerrequisitos
- Java 17+ instalado y disponible en `PATH` (o indicar ruta con `-JavaPath`).
- Archivo `server.jar` presente en `server/`.

### Primer inicio (setup)
1. Entrar a la carpeta del servidor:
   - `cd .\server`
2. Crear tu configuración local desde la plantilla:
   - `Copy-Item .\server.properties.example .\server.properties`
3. Editar `server.properties` según tu entorno (puerto, whitelist, etc.).
4. Asegurar aceptación de EULA local:
   - `eula=true` en `eula.txt`
5. Iniciar servidor:
   - `.\start-server.ps1`

### Arranques posteriores
Con la configuración ya creada:
- `cd .\server`
- `.\start-server.ps1`

### Verificación de arranque
Durante el inicio, validar en consola o en `server/logs/latest.log` la línea:
- `Done (...)! For help, type "help"`
Si aparece, el servidor quedó inicializado correctamente.

### Detener el servidor
- En la consola del servidor, usar `Ctrl + C` para apagarlo de forma controlada.

### Parámetros útiles del script de arranque
- Cambiar memoria:
  - `.\start-server.ps1 -MinMemory 2G -MaxMemory 4G`
- Especificar ruta del jar:
  - `.\start-server.ps1 -JarPath .\server.jar`
- Especificar ejecutable Java:
  - `.\start-server.ps1 -JavaPath "C:\Program Files\Java\bin\java.exe"`
