# Integración de `server/` en Git

## Estrategia
Se versiona únicamente la parte **reproducible** del servidor (configuración base y scripts), y se excluye el estado **runtime** (mundo, logs, binarios y datos generados).

## Qué se versiona
- `version.txt`: versión objetivo del servidor.
- `server.properties.example`: plantilla base de configuración.
- `start-server.ps1`: script de arranque local.
- `README.md`: documentación operativa de esta carpeta.

## Qué NO se versiona
- Mundo (`world/`)
- Logs (`logs/`, `startup-test*.log`)
- Binarios (`*.jar`, `versions/`)
- Estado generado por ejecución (`eula.txt`, `usercache.json`, `ops.json`, `whitelist.json`, `banned-*.json`)
- Configuración local final (`server.properties`)

## Uso rápido
1. Copiar la plantilla:
   - `Copy-Item .\server.properties.example .\server.properties`
2. Ajustar `server.properties` según tu entorno.
3. Aceptar EULA en tu instalación local (`eula=true` en `eula.txt`).
4. Ejecutar:
   - `.\start-server.ps1`
